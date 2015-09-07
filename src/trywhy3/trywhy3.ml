
(*

  module for generating HTML elements

*)

module Html = struct

let d = Dom_html.document

let node x = (x : #Dom.node Js.t :> Dom.node Js.t)

let of_string s = node (d##createTextNode (Js.string s))

let par nl =
  let x = d##createElement (Js.string "p") in
  List.iter (Dom.appendChild x) nl;
  node x

let ul nl =
  let x = d##createElement (Js.string "ul") in
  List.iter
    (fun n ->
      let y =  d##createElement (Js.string "li") in
      List.iter (Dom.appendChild y) n;
      Dom.appendChild x (node y))
    nl;
  node x

end

let get_opt o =
  Js.Opt.get o (fun () -> assert false)

let log s =
  Firebug.console ## log (Js.string s)

let temp_file_name = "/input.mlw"
let why3_conf_file = "/why3.conf"

let () =
  Sys_js.register_file ~name:temp_file_name ~content:""

open Why3
open Format

(* reads the config file *)
let config : Whyconf.config = Whyconf.read_config (Some why3_conf_file)
(* the [main] section of the config file *)
let main : Whyconf.main = Whyconf.get_main config
(* all the provers detected, from the config file *)
let provers : Whyconf.config_prover Whyconf.Mprover.t =
  Whyconf.get_provers config

(* One prover named Alt-Ergo in the config file *)
let alt_ergo : Whyconf.config_prover =
  if Whyconf.Mprover.is_empty provers then begin
    eprintf "Prover Alt-Ergo not installed or not configured@.";
    exit 0
  end else snd (Whyconf.Mprover.choose provers)

(* builds the environment from the [loadpath] *)
let env : Env.env = Env.create_env (Whyconf.loadpath main)


let alt_ergo_driver : Driver.driver =
  try
    Printexc.record_backtrace true;
    Driver.load_driver env alt_ergo.Whyconf.driver []
  with e ->
    let s = Printexc.get_backtrace () in
    eprintf "Failed to load driver for alt-ergo: %a@.%s@."
      Exn_printer.exn_printer e s;
  exit 1


let run_alt_ergo_on_task t =
  (* printing the task in a string *)
  Driver.print_task alt_ergo_driver str_formatter t;
  let text = flush_str_formatter () in
  (* TODO ! *)
(* from Alt-Ergo:
  let a = Why_parser.file Why_lexer.token lb in
  let ltd, typ_env = Why_typing.file false Why_typing.empty_env a in
  let declss = Why_typing.split_goals ltd in
  SAT.start ();
  let declss = List.map (List.map fst) declss in
  let report = FE.print_status in
  let pruning =
    List.map
      (fun d ->
        if select () > 0 then Pruning.split_and_prune (select ()) d
        else [List.map (fun f -> f,true) d])
  in
  List.iter
    (List.iter
       (fun dcl ->
	 let cnf = Cnf.make dcl in
	 ignore (Queue.fold (FE.process_decl report)
		   (SAT.empty (), true, Explanation.empty) cnf)
       )) (pruning declss)
*)
  text

let split_trans = Trans.lookup_transform_l "split_goal_wp" env

let why3_prove theories =
  let theories =
    Stdlib.Mstr.fold
      (fun thname th acc ->
        let tasks = Task.split_theory th None None in
        let tasks = List.map
          (fun t ->
            let (id,expl,_) = Termcode.goal_expl_task ~root:true t in
            let expl = match expl with
              | Some s -> s
              | None -> id.Ident.id_string
            in
            let tl = Trans.apply split_trans t in
            let tasks =
              List.map
                (fun task ->
                  let (id,expl,_) = Termcode.goal_expl_task ~root:false task in
                  let expl = match expl with
                    | Some s -> s
                    | None -> id.Ident.id_string
                  in
                  let result = run_alt_ergo_on_task task in
                  let result =
                    if String.length result > 80 then
                      "..." ^ String.sub result (String.length result - 80) 80
                    else result
                  in
                  [Html.of_string (expl ^" : " ^ result)])
                tl
            in
            [Html.of_string expl; Html.ul tasks])
          tasks
        in
        [ Html.of_string ("Theory " ^ thname); Html.ul tasks]
        :: acc)
      theories []
  in
  Html.ul theories

let why3_execute (modules,_theories) =
  let mods =
    Stdlib.Mstr.fold
      (fun _k m acc ->
        let th = m.Mlw_module.mod_theory in
        let name = th.Theory.th_name.Ident.id_string in
        [Html.of_string ("Module " ^ name)] :: acc)
      modules []
  in
  Html.ul mods

(* from ../tools/why3execute.ml

  let do_exec (mid,name) =
    let m = try Mstr.find mid mm with Not_found ->
      eprintf "Module '%s' not found.@." mid;
      exit 1 in
    let ps =
      try Mlw_module.ns_find_ps m.Mlw_module.mod_export [name]
      with Not_found ->
        eprintf "Function '%s' not found in module '%s'.@." name mid;
        exit 1 in
    match Mlw_decl.find_definition m.Mlw_module.mod_known ps with
    | None ->
      eprintf "Function '%s.%s' has no definition.@." mid name;
      exit 1
    | Some d ->
      try
        printf "@[<hov 2>Execution of %s.%s ():@\n" mid name;
        Mlw_interp.eval_global_symbol env m d;
      with e when Debug.test_noflag Debug.stack_trace ->
        printf "@\n@]@.";
        raise e in
  Queue.iter do_exec opt_exec

*)

let run_why3 f lang global text =
  let ch = open_out temp_file_name in
  output_string ch text;
  close_out ch;
  try
    (* TODO: add a function Env.read_string or Env.read_from_lexbuf ? *)
    let theories = Env.read_file lang env temp_file_name in
    f theories
  with
(*
  | Loc.Located(loc,Parser.Error) ->
    let (_,l,b,e) = Loc.get loc in
    Html.par
      [Html.of_string
          (Pp.sprintf "syntax error line %d, columns %d-%d" l b e)]
*)
  | Loc.Located(loc,e') ->
    let (_,l,b,e) = Loc.get loc in
    ignore (Js.Unsafe.meth_call global "highlightError"
	      (Array.map Js.Unsafe.inject [| l-1; b; l-1; e |]));
    Html.par
      [Html.of_string
          (Pp.sprintf
             "error line %d, columns %d-%d: %a" l b e
             Exn_printer.exn_printer e')]
  | e ->
    Html.par
      [Html.of_string
          (Pp.sprintf
             "unexpected exception: %a (%s)" Exn_printer.exn_printer e
             (Printexc.to_string e))]

let add_why3_cmd buttonname f lang =
  let handler = Dom.handler
    (fun _ev ->
      log "why3 prove is running";
      let global = Js.Unsafe.global in
      let editor = Js.Unsafe.get global (Js.string "editor") in
      let code = Js.to_string (Js.Unsafe.meth_call editor "getValue" [| |]) in
      let answer = run_why3 f lang global code in
      (* remove the previous answer if any *)
      let console =
        get_opt (Dom_html.document ## getElementById (Js.string "console"))
      in
      Js.Opt.iter (console##lastChild) (Dom.removeChild console);
      (* put the new answer *)
      Dom.appendChild console answer;
      ignore (Js.Unsafe.meth_call editor "focus" [| |]);
      Js._false)
  in
  let button =
    get_opt (Dom_html.document ## getElementById (Js.string buttonname))
  in
  button ## onclick <- handler

let () =
  add_why3_cmd "prove" why3_prove Env.base_language;
  add_why3_cmd "run" why3_execute Mlw_module.mlw_language

let add_file_example buttonname file =
  let handler = Dom.handler
    (fun _ev ->
      let text = Sysutil.file_contents file in
      let global = Js.Unsafe.global in
      let editor = Js.Unsafe.get global (Js.string "editor") in
      Js.Unsafe.set global (Js.string "loadedBuffer") (Js.string text);
      let loaded = Filename.basename file in
      Js.Unsafe.set global (Js.string "loadedFilename") (Js.string loaded);
      ignore (Js.Unsafe.meth_call global "replaceWithLoaded" [| |]);
      ignore (Js.Unsafe.meth_call editor "focus" [| |]);
      Js._false)
  in
  let button =
    get_opt (Dom_html.document ## getElementById (Js.string buttonname))
  in
  button ## onclick <- handler

let () =
  add_file_example "drinkers" "/drinkers.why";
  add_file_example "simplearith" "/simplearith.why";
  add_file_example "isqrt" "/isqrt.mlw"


(*
Local Variables:
compile-command: "unset LANG; make -C ../.. src/trywhy3/trywhy3.js"
End:
*)
