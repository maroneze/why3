(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2020   --   Inria - CNRS - Paris-Sud University  *)
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
Require AnyFunction.
Require int.Int.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.

(* Why3 goal *)
Lemma reverse'def {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a),
  ((Lists.List.rev l) =
   match l with
   | Init.Datatypes.nil => Init.Datatypes.nil
   | Init.Datatypes.cons x r =>
       Init.Datatypes.app (Lists.List.rev r)
       (Init.Datatypes.cons x Init.Datatypes.nil)
   end).
Proof.
now intros [|x l].
Qed.

(* Why3 goal *)
Lemma reverse_append {a:Type} {a_WT:WhyType a} :
  forall (l1:Init.Datatypes.list a) (l2:Init.Datatypes.list a) (x:a),
  ((Init.Datatypes.app (Lists.List.rev (Init.Datatypes.cons x l1)) l2) =
   (Init.Datatypes.app (Lists.List.rev l1) (Init.Datatypes.cons x l2))).
Proof.
intros l1 l2 x.
simpl.
now rewrite <- List.app_assoc.
Qed.

(* Why3 goal *)
Lemma reverse_cons {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a) (x:a),
  ((Lists.List.rev (Init.Datatypes.cons x l)) =
   (Init.Datatypes.app (Lists.List.rev l)
    (Init.Datatypes.cons x Init.Datatypes.nil))).
intros l x.
simpl.
auto.
Qed.

(* Why3 goal *)
Lemma cons_reverse {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a) (x:a),
  ((Init.Datatypes.cons x (Lists.List.rev l)) =
   (Lists.List.rev
    (Init.Datatypes.app l (Init.Datatypes.cons x Init.Datatypes.nil)))).
intros l x.
now rewrite List.rev_unit.
Qed.

(* Why3 goal *)
Lemma reverse_reverse {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a), ((Lists.List.rev (Lists.List.rev l)) = l).
Proof.
intros l.
apply List.rev_involutive.
Qed.

(* Why3 goal *)
Lemma reverse_mem {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a) (x:a),
  list.Mem.mem x l <-> list.Mem.mem x (Lists.List.rev l).
intros l x.
induction l; simpl; intuition.
rewrite Append.mem_append.
right; simpl; now intuition.
rewrite Append.mem_append.
now auto.
assert (Mem.mem x (List.rev l) \/ Mem.mem x (a0 :: nil))%list.
rewrite <- Append.mem_append; assumption.
intuition; simpl in *.
intuition.
Qed.

(* Why3 goal *)
Lemma Reverse_length {a:Type} {a_WT:WhyType a} :
  forall (l:Init.Datatypes.list a),
  ((list.Length.length (Lists.List.rev l)) = (list.Length.length l)).
Proof.
intros l.
rewrite 2!Length.length_std.
now rewrite List.rev_length.
Qed.
