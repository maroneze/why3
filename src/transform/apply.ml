(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2017   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

open Trans
open Term
open Decl
open Theory
open Task
open Args_wrapper
open Reduction_engine
open Generic_arg_trans_utils

(** This file contains transformations with arguments that acts on specific
    declarations to refine them (rewrite, replace, apply, unfold, subst...) *)


let debug_matching = Debug.register_info_flag "print_match"
  ~desc:"Print@ terms@ that@ were@ not@ successfully@ matched@ by@ ITP@ tactic@ apply."

(* Do as intros: introduce all premises of hypothesis pr and return a triple
   (goal, list_premises, binded variables) *)
let intros f =
  let rec intros_aux lp lv f =
    match f.t_node with
    | Tbinop (Timplies, f1, f2) ->
        intros_aux (f1 :: lp) lv f2
    | Tquant (Tforall, fq) ->
        let vsl, _, fs = t_open_quant fq in
        intros_aux lp (List.fold_left (fun v lv -> Svs.add lv v) lv vsl) fs
    | _ -> (lp, lv, f) in
  intros_aux [] Svs.empty f

let term_decl d =
  match d.td_node with
  | Decl ({d_node = Dprop (_pk, _pr, t)}) -> t
  | _ -> raise (Arg_trans "term_decl")

let pr_prsymbol pr =
  match pr with
  | Decl {d_node = Dprop (_pk, pr, _t)} -> Some pr
  | _ -> None

(* Looks for the hypothesis name and return it. If not found return None *)
let find_hypothesis (name:Ident.ident) task =
  let ndecl = ref None in
  let _ = task_iter (fun x -> if (
    match (pr_prsymbol x.td_node) with
    | None -> false
    | Some pr -> Ident.id_equal pr.pr_name name) then ndecl := Some x) task in
  !ndecl

(* Apply:
   1) takes the hypothesis and introduce parts of it to keep only the last
      element of the implication. It gathers the premises and variables in a
      list.
   2) try to find a good substitution for the list of variables so that last
      element of implication is equal to the goal.
   3) generate new goals corresponding to premises with variables instantiated
      with values found in 2).
 *)
let apply pr : Task.task Trans.tlist = Trans.store (fun task ->
  let name = pr.pr_name in
  let g, task = Task.task_separate_goal task in
  let g = term_decl g in
  let d = find_hypothesis name task in
  if d = None then raise (Arg_error "apply");
  let d = Opt.get d in
  let t = term_decl d in
  let (lp, lv, nt) = intros t in
  let (subst_ty, subst) = try first_order_matching lv [nt] [g] with
  | Reduction_engine.NoMatch (Some (t1, t2)) ->
      (if (Debug.test_flag debug_matching) then
        Format.printf "Term %a and %a can not be matched. Failure in matching@."
          Pretty.print_term t1 Pretty.print_term t2
      else ()); raise (Arg_trans_term ("apply", t1, t2))
  | Reduction_engine.NoMatchpat (Some (p1, p2)) ->
      (if (Debug.test_flag debug_matching) then
        Format.printf "Term %a and %a can not be matched. Failure in matching@."
          Pretty.print_pat p1 Pretty.print_pat p2
      else ()); raise (Arg_trans_pattern ("apply", p1, p2))
  | Reduction_engine.NoMatch None -> raise (Arg_trans ("apply"))
  in
  let inst_nt = t_ty_subst subst_ty subst nt in
  if (Term.t_equal_nt_nl inst_nt g) then
    let nlp = List.map (t_ty_subst subst_ty subst) lp in
    let lt = List.map (fun ng -> Task.add_decl task (create_prop_decl Pgoal
                          (create_prsymbol (gen_ident "G")) ng)) nlp in
    lt
  else
    raise (Arg_trans_term ("apply", inst_nt, g)))

let replace rev f1 f2 t =
  match rev with
  | true -> replace_in_term f1 f2 t
  | false -> replace_in_term f2 f1 t

(* Generic fold to be put in Trans ? TODO *)
let fold (f: decl -> 'a -> 'a) (acc: 'a): 'a Trans.trans =
  Trans.fold (fun t acc -> match t.task_decl.td_node with
  | Decl d -> f d acc
  | _ -> acc) acc

(* - If f1 unifiable to t with substitution s then return s.f2 and replace every
     occurences of s.f1 with s.f2 in the rest of the term
   - Else call recursively on subterms of t *)
(* If a substitution s is found then new premises are computed as e -> s.e *)
let replace_subst lp lv f1 f2 t =
  (* is_replced is common to the whole execution of replace_subst. Once an
     occurence is found, it changes to Some (s) so that only one instanciation
     is rewrritten during execution *)
  (* Note that we can't use an accumulator to do this *)
  let is_replaced = ref None in

  let rec replace lv f1 f2 t : Term.term =
  match !is_replaced with
  | Some(subst_ty,subst) ->
     replace_in_term (t_ty_subst subst_ty subst f1) (t_ty_subst subst_ty subst f2) t
  | None ->
    begin
      let fom = try Some (first_order_matching lv [f1] [t]) with
      | Reduction_engine.NoMatch (Some (t1, t2)) ->
        (if (Debug.test_flag debug_matching) then
          Format.printf "Term %a and %a can not be matched. Failure in matching@."
          Pretty.print_term t1 Pretty.print_term t2
        else ()); None
      | Reduction_engine.NoMatchpat (Some (p1, p2)) ->
        (if (Debug.test_flag debug_matching) then
          Format.printf "Term %a and %a can not be matched. Failure in matching@."
          Pretty.print_pat p1 Pretty.print_pat p2
        else ()); None
      | Reduction_engine.NoMatch None -> None in
        (match fom with
        | None -> t_map (fun t -> replace lv f1 f2 t) t
        | Some (subst_ty, subst) ->
        let sf1 = t_ty_subst subst_ty subst f1 in
        if (Term.t_equal sf1 t) then
        begin
          is_replaced := Some (subst_ty,subst);
          t_ty_subst subst_ty subst f2
        end
        else
          replace lv f1 f2 t)
    end in
  let t = t_map (replace lv f1 f2) t in
  match !is_replaced with
  | None -> raise (Arg_trans "matching/replace")
  | Some(subst_ty,subst) ->
    (List.map (t_ty_subst subst_ty subst) lp, t)

let rewrite_in rev h h1 =
  let found_eq =
    (* Used to find the equality we are rewriting on *)
    fold (fun d acc ->
      match d.d_node with
      | Dprop (Paxiom, pr, t) when Ident.id_equal pr.pr_name h.pr_name ->
          let lp, lv, f = intros t in
          let t1, t2 = (match f.t_node with
          | Tapp (ls, [t1; t2]) when ls_equal ls ps_equ ->
              (* Support to rewrite from the right *)
              if rev then (t1, t2) else (t2, t1)
          | _ -> raise (Arg_bad_hypothesis ("rewrite", f))) in
          Some (lp, lv, t1, t2)
      | _ -> acc) None in
  (* Return instantiated premises and the hypothesis correctly rewritten *)
  let lp_new found_eq =
    match found_eq with
    | None -> raise (Arg_error "rewrite")
    | Some (lp, lv, t1, t2) ->
      fold (fun d acc ->
        match d.d_node with
        | Dprop (p, pr, t)
            when (Ident.id_equal pr.pr_name h1.pr_name &&
                 (p = Paxiom || p = Pgoal)) ->
          let lp, new_term = replace_subst lp lv t1 t2 t in
            Some (lp, create_prop_decl p pr new_term)
        | _ -> acc) None in
  (* Pass the premises as new goals. Replace the former toberewritten
     hypothesis to the new rewritten one *)
  let recreate_tasks lp_new =
    match lp_new with
    | None -> raise (Arg_trans "recreate_tasks")
    | Some (lp, new_term) ->
      let trans_rewriting =
        Trans.decl (fun d -> match d.d_node with
        | Dprop (p, pr, _t)
            when (Ident.id_equal pr.pr_name h1.pr_name &&
                 (p = Paxiom || p = Pgoal)) ->
          [new_term]
        | _ -> [d]) None in
      let list_par =
        List.map
          (fun e ->
            Trans.decl (fun d -> match d.d_node with
            | Dprop (p, pr, _t)
              when (Ident.id_equal pr.pr_name h1.pr_name &&
                    p = Paxiom) ->
                [d]
            | Dprop (Pgoal, _, _) ->
                [create_prop_decl Pgoal (Decl.create_prsymbol (gen_ident "G")) e]
            | _ -> [d] )
          None) lp in
      Trans.par (trans_rewriting :: list_par) in

  (* Composing previous functions *)
  Trans.bind (Trans.bind found_eq lp_new) recreate_tasks

let find_target_prop h : prsymbol trans =
  Trans.store (fun task ->
               match h with
                 | Some pr -> pr
                 | None -> Task.task_goal task)

let rewrite rev h h1 = Trans.bind (find_target_prop h1) (rewrite_in (not rev) h)

(* This function is used to detect when we found the hypothesis/goal we want
   to replace/unfold into. *)
let detect_prop pr k h =
  match h with
  | None -> k = Pgoal
  | Some h -> Ident.id_equal pr.pr_name h.pr_name && (k = Paxiom || k = Pgoal)

let detect_prop_list pr k hl =
  match hl with
  | None -> k = Pgoal
  | Some [] -> (* Should not be able to parse the empty list *)
      raise (Arg_trans "replace")
  | Some hl ->
      ((List.exists (fun h -> Ident.id_equal pr.pr_name h.pr_name) hl)
         && (k = Paxiom || k = Pgoal))

(* Replace occurences of t1 with t2 in h. When h is None, the default is to
   replace in the goal.
*)
let replace t1 t2 hl =
  if not (Ty.ty_equal (t_type t1) (t_type t2)) then
    raise (Arg_trans_term ("replace", t1, t2))
  else
    (* Create a new goal for equality of the two terms *)
    let g = Decl.create_prop_decl Decl.Pgoal (create_prsymbol (gen_ident "G")) (t_app_infer ps_equ [t1; t2]) in
    let ng = Trans.goal (fun _ _ -> [g]) in
    let g = Trans.decl (fun d ->
      match d.d_node with
      | Dprop (p, pr, t) when detect_prop_list pr p hl ->
          [create_prop_decl p pr (replace true t1 t2 t)]
      | _ -> [d]) None in
    Trans.par [g; ng]


let t_replace_app unf ls_defn t =
  let (vl, tls) = ls_defn in
  match t.t_node with
  | Tapp (ls, tl) when ls_equal unf ls ->
     let add (mt,mv) x y =
       Ty.ty_match mt x.vs_ty (t_type y), Mvs.add x y mv
     in
     let mtv,mvs =
       List.fold_left2 add (Ty.Mtv.empty,Mvs.empty) vl tl
     in
     let mtv = Ty.oty_match mtv tls.t_ty t.t_ty in
     t_ty_subst mtv mvs tls
  | _ -> t

let rec t_ls_replace ls ls_defn t =
  t_replace_app ls ls_defn (t_map (t_ls_replace ls ls_defn) t)

let unfold unf hl =
  let r = ref None in
  Trans.decl
    (fun d ->
      match d.d_node with
        (* Do not work on mutually recursive functions *)
      | Dlogic [(ls, ls_defn)] when ls_equal ls unf ->
          r := Some (open_ls_defn ls_defn);
          [d]
      | Dprop (k, pr, t) when detect_prop_list pr k hl ->
        begin
          match !r with
          | None -> [d]
          | Some ls_defn ->
              let t = t_ls_replace unf ls_defn t in
              let new_decl = create_prop_decl k pr t in
              [new_decl]
        end
      | _ -> [d]) None

(* This function is used to find a specific ident in an equality:
   (to_subst = term or term = to_subst) in order to subst and remove said
   equality.
   This function returns None if not found, Some (None, t1, t2) with t1 being
   to_subst and t2 being term to substitute to if the equality found it a symbol
   definition. If equality found is a a decl then it is returned:
   Some (Some pr, t1, t2) *)
let find_eq (to_subst: Term.lsymbol list) =
  fold (fun d acc ->
    match d.d_node with
    | Dprop (k, pr, t) when k != Pgoal ->
        let acc = (match t.t_node with
        | Tapp (ls, [t1; t2]) when ls_equal ls ps_equ ->
            (* Allow to rewrite from the right *)
            begin
              match t1.t_node, t2.t_node with
              | Tapp (ls, []), _ when List.exists (ls_equal ls) to_subst ->
                  Some (Some pr, t1, t2) :: acc
              | _, Tapp (ls, []) when List.exists (ls_equal ls) to_subst ->
                  Some (Some pr, t2, t1) :: acc
              | _ -> acc
            end
        | _ -> acc) in
        acc
    | Dlogic [(ls, ld)] when List.exists (ls_equal ls) to_subst ->
      (* Function without arguments *)
      let vl, e = open_ls_defn ld in
      if vl = [] then
        Some (None, t_app_infer ls [], e) :: acc
      else
        acc
    | _ -> acc) []

(* This found any equality which at one side contains a single lsymbol and is
   local. It gives same output as found_eq. *)
let find_eq2 is_local_decl =
    fold (fun d acc ->
      match d.d_node with
      | Dprop (k, pr, t) when k != Pgoal && is_local_decl d ->
        begin
          let acc = (match t.t_node with
          | Tapp (ls, [t1; t2]) when ls_equal ls ps_equ ->
            (match t1.t_node, t2.t_node with
            | Tapp (_, []), _ ->
                Some (Some pr, t1, t2)
            | _, Tapp (_, []) ->
                Some (Some pr, t2, t1)
            | _ -> acc)
          | _ -> acc) in
          acc
        end
      | Dlogic [(ls, ld)] when is_local_decl d ->
        (* Function without arguments *)
        let vl, e = open_ls_defn ld in
        if vl = [] then
          Some (None, t_app_infer ls [], e)
        else
          acc
      | _ -> acc) None

let subst_eq found_eq =
  match found_eq with
    | None -> raise (Arg_trans "subst_eq")
    | Some (Some pr_eq, t1, t2) ->
      begin
        Trans.decl (fun d ->
          match d.d_node with
          (* Remove equality over which we subst *)
          | Dprop (_k, pr, _t) when pr_equal pr pr_eq  ->
            []
          (* Replace in all hypothesis *)
          | Dprop (kind, pr, t) ->
            [create_prop_decl kind pr (t_replace t1 t2 t)]
          | Dlogic ldecl_list ->
            let ldecl_list =
              List.map (fun (ls, ls_def) ->
                let (vl, t) = open_ls_defn ls_def in
                make_ls_defn ls vl (t_replace t1 t2 t)) ldecl_list
            in
            [create_logic_decl ldecl_list]

          (* TODO unbelievably complex for something that simple... *)
          | Dind ((is: ind_sign), (ind_list: ind_decl list)) ->
            let ind_list: ind_decl list =
              List.map (fun ((ls: lsymbol), (idl: (prsymbol * term) list)) ->
                let idl = List.map (fun (pr, t) -> (pr, t_replace t1 t2 t)) idl in
                (ls, idl)) ind_list
            in
            [create_ind_decl is ind_list]

          | Dtype _ | Ddata _ | Dparam _ -> [d]) None
      end
    | Some (None, t1, t2) ->
      begin
         Trans.decl (fun d ->
           match d.d_node with
           | Dlogic [(ls, _ld)] when try (t1 = Term.t_app_infer ls []) with _ -> false ->
              []
           (* Replace in all hypothesis *)
           | Dprop (kind, pr, t) ->
             [create_prop_decl kind pr (t_replace t1 t2 t)]

          | Dlogic ldecl_list ->
            let ldecl_list =
              List.map (fun (ls, ls_def) ->
                let (vl, t) = open_ls_defn ls_def in
                make_ls_defn ls vl (t_replace t1 t2 t)) ldecl_list
            in
            [create_logic_decl ldecl_list]

          (* TODO unbelievably complex for something that simple... *)
          | Dind ((is: ind_sign), (ind_list: ind_decl list)) ->
            let ind_list: ind_decl list =
              List.map (fun ((ls: lsymbol), (idl: (prsymbol * term) list)) ->
                let idl = List.map (fun (pr, t) -> (pr, t_replace t1 t2 t)) idl in
                (ls, idl)) ind_list
            in
            [create_ind_decl is ind_list]

          | Dtype _ | Ddata _ | Dparam _ -> [d]) None
       end

let subst_eq_list found_eq_list =
  List.fold_left (fun acc_tr found_eq ->
    Trans.compose (subst_eq found_eq) acc_tr) Trans.identity found_eq_list

let subst (to_subst: Term.lsymbol list) =
  Trans.bind (find_eq to_subst) subst_eq_list

let subst (to_subst: Term.term list) =
  (* TODO allow list of lsymbols in type of tactics *)
  subst (List.map
           (fun t -> match t.t_node with
           | Tapp (ls, []) -> ls
           | _ -> raise (Arg_trans "subst_eq")) to_subst)

let subst_all (is_local_decl: Decl.decl -> bool) =
   Trans.bind (find_eq2 is_local_decl) subst_eq

let return_local_decl task =
  let decl_list = get_local_task task in
  let is_local_decl d = List.exists (fun x -> Decl.d_equal d x) decl_list in
  is_local_decl

let return_local_decl = Trans.store return_local_decl

let subst_all = Trans.bind return_local_decl subst_all

let rec repeat f task =
  try
    let new_task = Trans.apply f task in
    (* TODO this is probably expansive. Use a checksum or an integer ? *)
    if Task.task_equal new_task task then
      raise Exit
    else
      repeat f new_task
  with
  | _ -> task

let repeat f = Trans.store (repeat f)

let () = wrap_and_register ~desc:"remove a literal using an equality on it"
    "subst"
    (Ttermlist Ttrans) subst

let subst_all = repeat subst_all

let () =
  wrap_and_register ~desc:"substitute all ident equalities and remove them"
    "subst_all"
    (Ttrans) subst_all

let () = wrap_and_register ~desc:"sort declarations"
    "sort"
    (Ttrans) sort

let () = wrap_and_register ~desc:"unfold ls [in] pr: unfold logic symbol ls in list of hypothesis pr. The argument in is optional: by default unfold in the goal." (* TODO *)
    "unfold"
    (Tlsymbol (Topt ("in", Tprlist Ttrans))) unfold

let () = wrap_and_register
    ~desc:"replace <term1> <term2> [in] <name list> replaces occcurences of term1 by term2 in prop name. If no list is given, replace in the goal."
    "replace"
    (Tterm (Tterm (Topt ("in", Tprlist Ttrans_l)))) replace

let _ = wrap_and_register
    ~desc:"rewrite [<-] <name> [in] <name2> rewrites equality defined in name into name2" "rewrite"
    (Toptbool ("<-",(Tprsymbol (Topt ("in", Tprsymbol Ttrans_l))))) rewrite

  (* register_transform_with_args_l *)
  (*   ~desc:"rewrite [<-] <name> [in] <name2> rewrites equality defined in name into name2" *)
  (*   "rewrite" *)
  (*   (wrap_l (Toptbool ("<-",(Tprsymbol (Topt ("in", Tprsymbol Ttrans_l))))) rewrite) *)

let () = wrap_and_register
    ~desc:"apply <prop> applies prop to the goal" "apply"
    (Tprsymbol Ttrans_l) apply