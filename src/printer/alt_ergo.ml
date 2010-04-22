(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

open Format
open Pp
open Ident
open Ty
open Term
open Decl
open Task

let ident_printer = 
  let bls = [
    "ac"; "and"; "array"; "as"; "axiom"; "bool"; "else"; "exists";
    "false"; "forall"; "function"; "goal"; "if"; "int"; "bitv";
    "logic"; "not"; "or"; "parameter"; "predicate";
    "prop"; "real"; "then"; "true"; "type"; "unit"; "void";
  ] 
  in
  let san = sanitizer char_to_alpha char_to_alnumus in
  create_ident_printer bls ~sanitizer:san

let print_ident fmt id =
  fprintf fmt "%s" (id_unique ident_printer id)

let print_tvsymbols fmt tv =
  let sanitize n = "'" ^ n in
  let n = id_unique ident_printer ~sanitizer:sanitize tv.tv_name in
  fprintf fmt "%s" n

let forget_var v = forget_id ident_printer v.vs_name

let rec print_type drv fmt ty = match ty.ty_node with
  | Tyvar id -> 
      print_tvsymbols fmt id
  | Tyapp (ts, tl) -> begin match drv.Driver.query_syntax ts.ts_name with
      | Some s -> Driver.syntax_arguments s (print_type drv) fmt tl
      | None -> fprintf fmt "%a%a" (print_tyapp drv) tl print_ident ts.ts_name
    end

and print_tyapp drv fmt = function
  | [] -> ()
  | [ty] -> fprintf fmt "%a " (print_type drv) ty
  | tl -> fprintf fmt "(%a) " (print_list comma (print_type drv)) tl

let rec print_term drv fmt t = match t.t_node with
  | Tbvar _ -> 
      assert false
  | Tconst c ->
      Pretty.print_const fmt c
  | Tvar { vs_name = id } ->
      print_ident fmt id
  | Tapp (ls, tl) -> begin match drv.Driver.query_syntax ls.ls_name with
      | Some s -> Driver.syntax_arguments s (print_term drv) fmt tl
      | None -> fprintf fmt "%a%a" print_ident ls.ls_name (print_tapp drv) tl
    end
  | Tlet (t1, tb) ->
      let v, t2 = t_open_bound tb in
      fprintf fmt "@[(let %a = %a@ in %a)@]" print_ident v.vs_name
        (print_term drv) t1 (print_term drv) t2;
      forget_var v
  | Tif _ ->
      assert false
  | Tcase _ ->
      assert false
  | Teps _ ->
      assert false

and print_tapp drv fmt = function
  | [] -> ()
  | tl -> fprintf fmt "(%a)" (print_list comma (print_term drv)) tl

let rec print_fmla drv fmt f = match f.f_node with
  | Fapp ({ ls_name = id }, []) ->
      print_ident fmt id
  | Fapp (ls, tl) -> begin match drv.Driver.query_syntax ls.ls_name with
      | Some s -> Driver.syntax_arguments s (print_term drv) fmt tl
      | None -> fprintf fmt "%a(%a)" print_ident ls.ls_name 
                    (print_list comma (print_term drv)) tl
    end
  | Fquant (q, fq) ->
      let q = match q with Fforall -> "forall" | Fexists -> "exists" in
      let vl, tl, f = f_open_quant fq in
      let forall fmt v = 
	fprintf fmt "%s %a:%a" q print_ident v.vs_name (print_type drv) v.vs_ty
      in
      fprintf fmt "@[(%a%a.@ %a)@]" (print_list dot forall) vl
        (print_triggers drv) tl (print_fmla drv) f;
      List.iter forget_var vl
  | Fbinop (Fand, f1, f2) ->
      fprintf fmt "(%a and@ %a)" (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (For, f1, f2) ->
      fprintf fmt "(%a or@ %a)" (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (Fimplies, f1, f2) ->
      fprintf fmt "(%a ->@ %a)" (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (Fiff, f1, f2) ->
      fprintf fmt "(%a <->@ %a)" (print_fmla drv) f1 (print_fmla drv) f2
  | Fnot f ->
      fprintf fmt "(not %a)" (print_fmla drv) f
  | Ftrue ->
      fprintf fmt "true"
  | Ffalse ->
      fprintf fmt "false"
  | Fif (f1, f2, f3) ->
      fprintf fmt "((%a and %a) or (not %a and %a))"
	(print_fmla drv) f1 (print_fmla drv) f2 (print_fmla drv)
        f1 (print_fmla drv) f3
  | Flet _ ->
      assert false
  | Fcase _ ->
      assert false

and print_expr drv fmt = e_apply (print_term drv fmt) (print_fmla drv fmt)

and print_triggers drv fmt tl =
  let tl = List.map (List.filter (function Term _ -> true | Fmla _ -> false)) tl in
  let tl = List.filter (function [] -> false | _::_ -> true) tl in
  if tl = [] then () else fprintf fmt "@ [%a]"
    (print_list alt (print_list comma (print_expr drv))) tl

let print_logic_binder drv fmt v =
  fprintf fmt "%a: %a" print_ident v.vs_name (print_type drv) v.vs_ty

let print_type_decl fmt ts = match ts.ts_args with
  | [] -> fprintf fmt "type %a" print_ident ts.ts_name
  | tl -> fprintf fmt "type (%a) %a" 
      (print_list comma print_tvsymbols) tl print_ident ts.ts_name

let print_type_decl drv fmt = function
  | ts, Tabstract when drv.Driver.query_syntax ts.ts_name <> None -> false
  | ts, Tabstract -> print_type_decl fmt ts; true
  | _, Talgebraic _ -> assert false

let ac_th = ["algebra";"AC"]

let print_logic_decl drv fmt (ls,ld) =
  let tags = drv.Driver.query_tags ls.ls_name in
  match ld with
    | None ->
        let sac = if Util.Sstr.mem "AC" tags then "ac " else "" in
        fprintf fmt "@[<hov 2>logic %s%a : %a%s%a@]@\n"
          sac print_ident ls.ls_name
          (print_list comma (print_type drv)) ls.ls_args 
          (if ls.ls_args = [] then "" else " -> ")
          (print_option_or_default "prop" (print_type drv)) ls.ls_value
    | Some ld ->
        let vl,e = open_ls_defn ld in
        begin match e with
          | Term t ->
              (* TODO AC? *)
              fprintf fmt "@[<hov 2>function %a(%a) : %a =@ %a@]@\n" 
                print_ident ls.ls_name
                (print_list comma (print_logic_binder drv)) vl 
                (print_type drv) (Util.of_option ls.ls_value) 
                (print_term drv) t
          | Fmla f ->
              fprintf fmt "@[<hov 2>predicate %a(%a) =@ %a@]"
                print_ident ls.ls_name 
                (print_list comma (print_logic_binder drv)) vl 
                (print_fmla drv) f
        end;
        List.iter forget_var vl

let print_logic_decl drv fmt d =
  match drv.Driver.query_syntax (fst d).ls_name with
  | Some _ -> false
  | None -> print_logic_decl drv fmt d; true

let print_decl drv fmt d = match d.d_node with
  | Dtype dl ->
      print_list_opt newline (print_type_decl drv) fmt dl
  | Dlogic dl ->
      print_list_opt newline (print_logic_decl drv) fmt dl
  | Dind _ -> assert false (* TODO *)
  | Dprop (Paxiom, pr, _) when drv.Driver.query_remove pr.pr_name -> false
  | Dprop (Paxiom, pr, f) ->
      fprintf fmt "@[<hov 2>axiom %a :@ %a@]@\n" 
        print_ident pr.pr_name (print_fmla drv) f; true
  | Dprop (Pgoal, pr, f) ->
      fprintf fmt "@[<hov 2>goal %a :@ %a@]@\n"
        print_ident pr.pr_name (print_fmla drv) f; true
  | Dprop (Plemma, _, _) ->
      assert false

let print_task drv fmt task = 
  let decls = Task.task_decls task in
  ignore (print_list_opt (add_flush newline2) (print_decl drv) fmt decls)

let () = Driver.register_printer "alt-ergo" 
  (fun drv fmt task -> 
     forget_all ident_printer;
     print_task drv fmt task)

let print_goal drv fmt (id, f, task) =
  print_task drv fmt task;
  fprintf fmt "@\n@[<hov 2>goal %a : %a@]@\n" print_ident id (print_fmla drv) f

