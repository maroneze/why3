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
Require int.Int.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.
Require list.Reverse.

(* Why3 goal *)
Lemma rev_append_def1 : forall {a:Type} {a_WT:WhyType a},
  forall (s:(list a)) (t:(list a)),
   ((Lists.List.rev_append s t) = match s with
                                  | (Init.Datatypes.cons x r) =>
                                      (Lists.List.rev_append r (Init.Datatypes.cons x t))
                                  | Init.Datatypes.nil => t
                                  end).
intros a a_WT s t.
destruct s; simpl; auto.
Qed.

(* Why3 goal *)
Lemma rev_append_append_l :
forall {a:Type} {a_WT:WhyType a},
forall (r:(list a)) (s:(list a)) (t:(list a)),
 ((Lists.List.rev_append (Init.Datatypes.app r s) t) = (Lists.List.rev_append s (Lists.List.rev_append r t))).
Proof.
intros a a_WT r s.
induction r as [|rh rt IHr].
easy.
now simpl.
Qed.

(* Why3 goal *)
Lemma rev_append_length :
forall {a:Type} {a_WT:WhyType a},
forall (s:(list a)) (t:(list a)),
 ((list.Length.length (Lists.List.rev_append s t)) = ((list.Length.length s) + 
 (list.Length.length t))%Z).
Proof.
intros a a_WT s.
induction s as [|sh st IHs].
easy.
intros t.
simpl List.rev_append.
rewrite IHs.
change (Length.length (sh :: t)) with (1 + Length.length t)%Z.
change (Length.length (sh :: st)) with (1 + Length.length st)%Z.
ring.
Qed.

(* Why3 goal *)
Lemma rev_append_def :
forall {a:Type} {a_WT:WhyType a},
forall (r:(list a)) (s:(list a)),
 ((Lists.List.rev_append r s) = (Init.Datatypes.app (Lists.List.rev r) s)).
Proof.
induction r; simpl.
now auto.
intro s; rewrite IHr.
rewrite <- Append.Append_assoc.
simpl. reflexivity.
Qed.

(* Why3 goal *)
Lemma rev_append_append_r :
forall {a:Type} {a_WT:WhyType a},
forall (r:(list a)) (s:(list a)) (t:(list a)),
 ((Lists.List.rev_append r (Init.Datatypes.app s t)) = (Lists.List.rev_append (Lists.List.rev_append s r) t)).
Proof.
intros a a_WT r s t.
revert r.
induction s as [|sh st IHs].
easy.
intros r.
simpl.
now rewrite <- IHs.
Qed.

