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

(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require list.List.
Require option.Option.

(* Why3 assumption *)
Definition hd {a:Type} {a_WT:WhyType a} (l:(list a)): (option a) :=
  match l with
  | Init.Datatypes.nil => Init.Datatypes.None
  | (Init.Datatypes.cons h _) => (Init.Datatypes.Some h)
  end.

(* Why3 assumption *)
Definition tl {a:Type} {a_WT:WhyType a} (l:(list a)): (option (list a)) :=
  match l with
  | Init.Datatypes.nil => Init.Datatypes.None
  | (Init.Datatypes.cons _ t) => (Init.Datatypes.Some t)
  end.

