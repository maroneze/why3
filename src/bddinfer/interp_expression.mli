(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2023 --  Inria - CNRS - Paris-Saclay University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

(** {1 Translation between expressions and abstract states} *)

(*
val to_expr :
  old:Abstract.why_env -> Abstract.why_env -> Apron.Environment.t -> Ast.expression -> Apron.Texpr1.t

val interp_bool_expr :
  old:Abstract.why_env -> Abstract.why_env -> Ast.expression -> Abstract.B.t
*)

val meet_condition :
  old:Abstract.why_env -> Abstract.t -> Ast.condition -> Abstract.t
(** reduce the given state to the subset satisfying the given condition *)

(* val meet_with_variable_equality :
 *   Abstract.t -> Abstract.why_var -> Abstract.why_var -> Abstract.t *)
(** reduce the given state with the equality between to two given variables *)

val abstract_state_to_conditions : Abstract.t -> Ast.condition list
(** convert the given state to a set of conditions *)
