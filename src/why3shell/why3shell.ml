

module Unix_scheduler = struct

    (* the private list of functions to call on idle, sorted higher
       priority first. *)
    let idle_handler = ref []

    (* [insert_idle_handler p f] inserts [f] as a new function to call
       on idle, with priority [p] *)
    let insert_idle_handler p f =
      let rec aux l =
        match l with
          | [] -> [p,f]
          | (p1,_) as hd :: rem ->
             if p > p1 then (p,f) :: l else hd :: aux rem
      in
      idle_handler := aux !idle_handler

    (* the private list of functions to call on timeout, sorted on
       earliest trigger time first. *)
    let timeout_handler = ref []

    (* [insert_timeout_handler ms t f] inserts [f] as a new function to call
       on timeout, with time step of [ms] and first call time as [t] *)
    let insert_timeout_handler ms t f =
      let rec aux l =
        match l with
          | [] -> [ms,t,f]
          | (_,t1,_) as hd :: rem ->
             if t < t1 then (ms,t,f) :: l else hd :: aux rem
      in
      timeout_handler := aux !timeout_handler

    (* public function to register a task to run on idle *)
    let idle ~(prio:int) f = insert_idle_handler prio f

    (* public function to register a task to run on timeout *)
    let timeout ~ms f =
      assert (ms > 0);
      let ms = float ms /. 1000.0 in
      let time = Unix.gettimeofday () in
      insert_timeout_handler ms (time +. ms) f

     (* buffer for storing character read on stdin *)
     let buf = Bytes.create 256

     let show_prompt = ref true
     let prompt = ref "> "

     (* [main_loop interp] starts the scheduler. On idle, standard input is
        read.  When a complete line is read from stdin, it is passed
        as a string to the function [interp] *)
     let main_loop interp =
       try
         while true do
           if !show_prompt then begin
               Format.printf "%s@?" !prompt;
               show_prompt := false;
             end;
           (* attempt to run the first timeout handler *)
           let time = Unix.gettimeofday () in
           match !timeout_handler with
           | (ms,t,f) :: rem when t <= time ->
              timeout_handler := rem;
              let b = f () in
              let time = Unix.gettimeofday () in
              if b then insert_timeout_handler ms (ms +. time) f
           | _ ->
              (* time is not yet passed *)
              (* attempt to run the first idle handler *)
              match !idle_handler with
              | (p,f) :: rem ->
                 idle_handler := rem;
                 let b = f () in
                 if b then insert_idle_handler p f
              | [] ->
                 (* no idle handler *)
                 (* check stdin for a some delay *)
                 let delay =
                   match !timeout_handler with
                   | [] -> 0.125
                   (* 1/8 second by default *)
                   | (_,t,_) :: _ -> t -. time
                   (* or the time left until the next timeout otherwise *)
                 in
                 let a,_,_ = Unix.select [Unix.stdin] [] [] delay in
                 match a with
                 | [_] ->
                    let n = Unix.read Unix.stdin buf 0 256 in
                    interp (Bytes.sub_string buf 0 (n-1));
                    show_prompt := true
                 | [] -> () (* nothing read *)
                 | _ -> assert false
         done
       with Exit -> ()

end



(************************)
(* parsing command line *)
(************************)

open Why3
open Format

let files = Queue.create ()

let spec = Arg.align [
]

let usage_str = Format.sprintf
  "Usage: %s [options] [ <file.xml> | <f1.why> <f2.mlw> ...]"
  (Filename.basename Sys.argv.(0))


let config, base_config, _env =
  Why3.Whyconf.Args.initialize spec (fun f -> Queue.add f files) usage_str

let main : Whyconf.main = Whyconf.get_main config
(* all the provers detected, from the config file *)
let provers : Whyconf.config_prover Whyconf.Mprover.t =
  Whyconf.get_provers config

(* builds the environment from the [loadpath] *)
let env : Env.env = Env.create_env (Whyconf.loadpath main)


module C = Why3.Controller_itp.Make(Unix_scheduler)

let cont =
  if Queue.is_empty files then Why3.Whyconf.Args.exit_with_usage spec usage_str;
  let fname = Queue.pop files in
  let ses =
    if Filename.check_suffix fname ".xml" then
      Session_itp.load_session fname
    else
      begin
        Queue.push fname files;
        Session_itp.empty_session ()
      end
  in
  let c = Controller_itp.create_controller env ses in
  Queue.iter (fun fname -> C.add_file c fname) files;
  c

(* loading the drivers *)
let () =
  Whyconf.Mprover.iter
    (fun _ p ->
      try
        let d = Driver.load_driver env p.Whyconf.driver [] in
        Whyconf.Hprover.add cont.Controller_itp.controller_provers p.Whyconf.prover (p,d)
      with e ->
        let p = p.Whyconf.prover in
        eprintf "Failed to load driver for %s %s: %a@."
          p.Whyconf.prover_name p.Whyconf.prover_version
          Exn_printer.exn_printer e)
    provers

(* One prover named Alt-Ergo in the config file *)
let alt_ergo =
  let fp = Whyconf.parse_filter_prover "Alt-Ergo" in
  (** all provers that have the name "Alt-Ergo" *)
  let provers = Whyconf.filter_provers config fp in
  if Whyconf.Mprover.is_empty provers then begin
    eprintf "Prover Alt-Ergo not installed or not configured@.";
    exit 0
  end else
    snd (Whyconf.Mprover.choose provers)

let test_idle fmt _args =
  Unix_scheduler.idle
    ~prio:0
    (fun () -> fprintf fmt "idle@."; false)

let test_timeout fmt _args =
  Unix_scheduler.timeout
    ~ms:1000
    (let c = ref 10 in
     fun () -> decr c;
               if !c > 0 then
                 (fprintf fmt "%d@." !c; true)
               else
                 (fprintf fmt "boom!@."; false))

let list_provers _fmt _args =
  let l =
    Whyconf.Hprover.fold
      (fun p _ acc -> (Pp.sprintf "%a" Whyconf.print_prover p)::acc)
      cont.Controller_itp.controller_provers
      []
  in
  let l = List.sort String.compare l in
  printf "@[<hov 2>== Known provers ==@\n%a@]@."
          (Pp.print_list Pp.newline Pp.string) l

let sort_pair (x,_) (y,_) = String.compare x y

let list_transforms _fmt _args =
  let l =
    List.rev_append (Trans.list_transforms ()) (Trans.list_transforms_l ())
  in
  let print_trans_desc fmt (x,r) =
    fprintf fmt "@[<hov 2>%s@\n@[<hov>%a@]@]" x Pp.formatted r in
  printf "@[<hov 2>== Known transformations ==@\n%a@]@\n@."
         (Pp.print_list Pp.newline2 print_trans_desc)
         (List.sort sort_pair l)

let dump_session_raw fmt _args =
  fprintf fmt "%a@." Session_itp.print_session cont.Controller_itp.controller_session

open Controller_itp
open Session_itp

(* type proof_cursor = Th of theory | Pn of proofNodeID | Tn of transID *)

type proof_hole =
    Th of theory list * theory * theory list |
    Pn of proofNodeID list * proofNodeID * proofNodeID list |
    Tn of transID list * transID * transID list

type proof_zipper = { mutable cursor : proof_hole; ctxt : proof_hole Queue.t }

let ctxt = Queue.create ()

let zipper =
  let files =
    get_files cont.Controller_itp.controller_session
  in
  let file = ref None in
  Stdlib.Hstr.iter (fun _ f -> file := Some f) files;
  let file = Opt.get !file in
  match file.file_theories with
  | th :: tail -> { cursor = (Th ([], th, tail)); ctxt }
  | _ -> assert false

let zipper_init () =
  let files =
    get_files cont.Controller_itp.controller_session
  in
  let file = ref None in
  Stdlib.Hstr.iter (fun _ f -> file := Some f) files;
  let file = Opt.get !file in
  match file.file_theories with
  | th :: tail -> zipper.cursor <- (Th ([], th, tail));
      while not (Queue.is_empty zipper.ctxt) do ignore (Queue.pop zipper.ctxt) done
  | _ -> assert false


let zipper_down () =
  match zipper.cursor with
  | Th (_,th,_) ->
    (match theory_goals th with
    | pn::l ->
      Queue.add zipper.cursor zipper.ctxt;
      zipper.cursor <- Pn ([],pn,l);
      true
    | _ -> false)
  | Pn (_,pn,_) ->
    (match get_transformations cont.controller_session pn with
    | tn::l ->
      Queue.add zipper.cursor zipper.ctxt;
      zipper.cursor <- Tn ([],tn,l);
      true
    | _ -> false)
  | Tn (_,tn,_) ->
    (match get_sub_tasks cont.controller_session tn with
    | pn::l ->
      Queue.add zipper.cursor zipper.ctxt;
      zipper.cursor <- Pn ([],pn,l);
      true
    | _ -> false)

let zipper_up () =
  if not (Queue.is_empty zipper.ctxt) then begin
    zipper.cursor <- Queue.pop zipper.ctxt;
    true
  end else
    false

let zipper_right () =
  match zipper.cursor with
  | Th (l,cs,hd::r) ->
    zipper.cursor <- Th (cs::l,hd,r);
    true
  | Pn (l,cs,hd::r) ->
    zipper.cursor <- Pn (cs::l,hd,r);
    true
  | Tn (l,cs,hd::r) ->
    zipper.cursor <- Tn (cs::l,hd,r);
    true
  | _ -> false

let zipper_left () =
  match zipper.cursor with
  | Th (hd::l,cs,r) ->
    zipper.cursor <- Th (l,hd,cs::r);
    true
  | Pn (hd::l,cs,r) ->
    zipper.cursor <- Pn (l,hd,cs::r);
    true
  | Tn (hd::l,cs,r) ->
    zipper.cursor <- Tn (l,hd,cs::r);
    true
  | _ -> false

let rec next_node () =
  zipper_down () || zipper_right () || (zipper_up () && next_node_no_down ())
and next_node_no_down () =
  zipper_right () || (zipper_up () && next_node_no_down ())

let prev_node = zipper_left () || zipper_up ()

(* This function always move from current position to the next goal even when on a goal *)
let rec nearest_goal_right () =
  if next_node () then
    match zipper.cursor with
    | Pn (_,pn,_) -> Some pn
    | _  -> nearest_goal_right ()
  else
    None

let print_position (s: session) (cursor: proof_zipper) fmt: unit =
  match cursor.cursor with
  | Th (_, th, _) -> fprintf fmt "%a@." (print_theory s) th
  | Pn (_, pn, _) -> fprintf fmt "%a@." (print_proof_node s) pn
  | Tn (_, tn, _) -> fprintf fmt "%a@." (print_trans_node s) tn

let print_position_p s cursor fmt _ = print_position s cursor fmt

(* This function try to get the id of the nearest goal right. If it can't, it tries
   to get you to the first goal of the session. If this is still not possible,
   it returns an error. *)
let ngr_ret () =
  match
    (match nearest_goal_right () with
    | None -> Printf.eprintf "No more goal right. You might want to go back to the root@.";
	zipper_init(); nearest_goal_right ()
    | Some id -> Some id) with
  | None -> failwith "After initialization there is no goal to go to@."
  | Some id -> id

(* The cursor of the zipper is on a goal *)
let is_goal_cursor () =
  match zipper.cursor with
  | Pn (_, pn, _) -> Some pn
  | _ -> None

let ngr_ret_p _ _ = ignore (ngr_ret ())

(* If on goal, do nothing else go to next_goal *)
let nearest_goal () =
  match (is_goal_cursor ()) with
  | None -> ngr_ret ()
  | Some id -> id

let test_schedule_proof_attempt fmt _args =
  (* temporary : get the first goal *)
  let id = nearest_goal () in
  let callback status =
    fprintf fmt "status: %a@."
            Controller_itp.print_status status
  in
  let limit = Call_provers.{empty_limit with limit_time = 2} in
  C.schedule_proof_attempt
    cont id alt_ergo.Whyconf.prover
    ~limit ~callback

let test_transformation fmt _args =
  (* temporary : apply split on the first goal *)
  let id = nearest_goal () in
  let callback status =
    fprintf fmt "transformation status: %a@."
            Controller_itp.print_trans_status status
  in
  C.schedule_transformation cont id "split_goal_wp" [] ~callback

let test_transformation_with_args fmt args =
  (* temporary : apply duplicate on the first goal *)
  let n =
    match args with
    | [s] -> int_of_string s
    | _ -> assert false
  in
  let id = nearest_goal () in
  let callback status =
    fprintf fmt "transformation status: %a@."
            Controller_itp.print_trans_status status
  in
  C.schedule_transformation cont id "duplicate" [Trans.TAint n] ~callback

let task_driver =
  let d = Filename.concat (Whyconf.datadir main)
                          (Filename.concat "drivers" "why3_itp.drv")
  in
  Driver.load_driver env d []

(* Print current goal or nearest next goal if we are not on a goal *)
let test_print_goal fmt _args =
  (* temporary : get the first goal *)
  let id = nearest_goal () in
  let task = Session_itp.get_task cont.Controller_itp.controller_session id in
  fprintf fmt "@[====================== Task =====================@\n%a@]@."
    (Driver.print_task ~cntexample:false task_driver) task

let test_save_session _fmt args =
  match args with
  | file :: _ ->
    Session_itp.save_session (file ^ ".xml") cont.Controller_itp.controller_session;
    printf "session saved@."
  | [] ->
    printf "missing session file name@."

let test_reload fmt _args =
  fprintf fmt "Reloading... @?";
  C.reload_files cont;
  fprintf fmt "done @."

let commands =
  [
    "list-provers", "list available provers", list_provers;
    "list-transforms", "list available transformations", list_transforms;
    (* temporary *)
    "i", "run a simple test of Unix_scheduler.idle", test_idle;
    "a", "run a simple test of Unix_scheduler.timeout", test_timeout;
    "p", "print the session in raw form", dump_session_raw;
    "t", "test schedule_proof_attempt with alt-ergo on the first goal", test_schedule_proof_attempt;
    "g", "prints the first goal", test_print_goal;
    "r", "reload the session (test only)", test_reload;
    "s", "[s my_session] save the current session in my_session.xml", test_save_session;
    "tr", "test schedule_transformation with split_goal on the current or next right goal (or on the top goal if there is none", test_transformation;
    "tra", "test duplicate transformation", test_transformation_with_args;
    "ngr", "get to the next goal right", ngr_ret_p;
    "pcur", "print tree rooted at current position", (print_position_p cont.controller_session zipper)
  ]

let commands_table = Stdlib.Hstr.create 17
let () =
  List.iter
    (fun (c,_,f) -> Stdlib.Hstr.add commands_table c f)
    commands

let help () =
  printf "== Available commands ==@\n";
  let l = ("q", "exit the shell") ::
            List.rev_map (fun (c,h,_) -> (c,h)) commands
  in
  let l = List.sort sort_pair l in
  List.iter (fun (c,help) -> printf "%20s : %s@\n" c help) l;
  printf "@."


let interp chout fmt s =
  let cmd,args =
    match Strings.split ' ' s with
    | [] -> assert false
    | a::b -> a,b
  in
  match cmd with
    | "?" -> help ()
    | "q" ->
       fprintf fmt "Shell exited@.";
       close_out chout;
       exit 0
    | _ ->
       try
         let f = Stdlib.Hstr.find commands_table cmd in
         f fmt args
       with Not_found ->
         printf "unknown command `%s`@." s


let () =
  printf "Welcome to Why3 shell. Type '?' for help.@.";
  let chout = open_out "why3shell.out" in
  let fmt = formatter_of_out_channel chout in
  Unix_scheduler.main_loop (interp chout fmt)
