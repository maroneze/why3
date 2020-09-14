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
Require Reals.Rbasic_fun.
Require BuiltIn.
Require AnyFunction.
Require int.Int.
Require real.Real.
Require real.Abs.
Require real.FromInt.
Require floating_point.Rounding.
Require floating_point.SingleFormat.

Require Import floating_point.GenFloat.

(* Why3 goal *)
Definition round :
  floating_point.Rounding.mode -> Reals.Rdefinitions.R ->
  Reals.Rdefinitions.R.
Proof.
exact (round 24 128).
Defined.

(* Why3 goal *)
Definition value :
  floating_point.SingleFormat.single -> Reals.Rdefinitions.R.
Proof.
exact (value 24 128).
Defined.

(* Why3 goal *)
Definition exact :
  floating_point.SingleFormat.single -> Reals.Rdefinitions.R.
Proof.
exact (exact 24 128).
Defined.

(* Why3 goal *)
Definition model :
  floating_point.SingleFormat.single -> Reals.Rdefinitions.R.
Proof.
exact (model 24 128).
Defined.

(* Why3 assumption *)
Definition round_error (x:floating_point.SingleFormat.single) :
    Reals.Rdefinitions.R :=
  Reals.Rbasic_fun.Rabs ((value x) - (exact x))%R.

(* Why3 assumption *)
Definition total_error (x:floating_point.SingleFormat.single) :
    Reals.Rdefinitions.R :=
  Reals.Rbasic_fun.Rabs ((value x) - (model x))%R.

(* Why3 assumption *)
Definition no_overflow (m:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R) : Prop :=
  ((Reals.Rbasic_fun.Rabs (round m x)) <=
   (33554430 * 10141204801825835211973625643008)%R)%R.

Lemma max_single_eq: (33554430 * 10141204801825835211973625643008 = max 24 128)%R.
Proof.
unfold max, Defs.F2R.
simpl Raux.bpow.
now rewrite <- 2!mult_IZR.
Qed.

(* Why3 goal *)
Lemma Bounded_real_no_overflow :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R),
  ((Reals.Rbasic_fun.Rabs x) <=
   (33554430 * 10141204801825835211973625643008)%R)%R ->
  no_overflow m x.
Proof.
intros m x Hx.
unfold no_overflow.
rewrite max_single_eq in *.
exact (Bounded_real_no_overflow 24 128 (refl_equal true) (refl_equal true) m x Hx).
Qed.

(* Why3 goal *)
Lemma Round_monotonic :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R)
    (y:Reals.Rdefinitions.R),
  (x <= y)%R -> ((round m x) <= (round m y))%R.
Proof.
apply Round_monotonic.
easy.
Qed.

(* Why3 goal *)
Lemma Round_idempotent :
  forall (m1:floating_point.Rounding.mode) (m2:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R),
  ((round m1 (round m2 x)) = (round m2 x)).
Proof.
now apply Round_idempotent.
Qed.

(* Why3 goal *)
Lemma Round_value :
  forall (m:floating_point.Rounding.mode)
    (x:floating_point.SingleFormat.single),
  ((round m (value x)) = (value x)).
Proof.
now apply Round_value.
Qed.

(* Why3 goal *)
Lemma Bounded_value :
  forall (x:floating_point.SingleFormat.single),
  ((Reals.Rbasic_fun.Rabs (value x)) <=
   (33554430 * 10141204801825835211973625643008)%R)%R.
Proof.
rewrite max_single_eq.
now apply Bounded_value.
Qed.

(* Why3 goal *)
Lemma Exact_rounding_for_integers :
  forall (m:floating_point.Rounding.mode) (i:Numbers.BinNums.Z),
  ((-16777216%Z)%Z <= i)%Z /\ (i <= 16777216%Z)%Z ->
  ((round m (BuiltIn.IZR i)) = (BuiltIn.IZR i)).
Proof.
intros m i Hi.
now apply Exact_rounding_for_integers.
Qed.

(* Why3 goal *)
Lemma Round_down_le :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Down x) <= x)%R.
Proof.
now apply Round_down_le.
Qed.

(* Why3 goal *)
Lemma Round_up_ge :
  forall (x:Reals.Rdefinitions.R),
  (x <= (round floating_point.Rounding.Up x))%R.
Proof.
now apply Round_up_ge.
Qed.

(* Why3 goal *)
Lemma Round_down_neg :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Down (-x)%R) =
   (-(round floating_point.Rounding.Up x))%R).
Proof.
now apply Round_down_neg.
Qed.

(* Why3 goal *)
Lemma Round_up_neg :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Up (-x)%R) =
   (-(round floating_point.Rounding.Down x))%R).
Proof.
now apply Round_up_neg.
Qed.

(* Why3 goal *)
Definition round_logic :
  floating_point.Rounding.mode -> Reals.Rdefinitions.R ->
  floating_point.SingleFormat.single.
Proof.
exact (round_logic 24 128 (refl_equal true) (refl_equal true)).
Defined.

(* Why3 goal *)
Lemma Round_logic_def :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R),
  no_overflow m x -> ((value (round_logic m x)) = (round m x)).
Proof.
intros m x.
unfold no_overflow.
rewrite max_single_eq.
exact (Round_logic_def 24 128 (refl_equal true) (refl_equal true) m x).
Qed.

(* Why3 assumption *)
Definition of_real_post (m:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R) (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (round m x)) /\ ((exact res) = x) /\ ((model res) = x).

(* Why3 assumption *)
Definition add_post (m:floating_point.Rounding.mode)
    (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single)
    (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (round m ((value x) + (value y))%R)) /\
  ((exact res) = ((exact x) + (exact y))%R) /\
  ((model res) = ((model x) + (model y))%R).

(* Why3 assumption *)
Definition sub_post (m:floating_point.Rounding.mode)
    (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single)
    (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (round m ((value x) - (value y))%R)) /\
  ((exact res) = ((exact x) - (exact y))%R) /\
  ((model res) = ((model x) - (model y))%R).

(* Why3 assumption *)
Definition mul_post (m:floating_point.Rounding.mode)
    (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single)
    (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (round m ((value x) * (value y))%R)) /\
  ((exact res) = ((exact x) * (exact y))%R) /\
  ((model res) = ((model x) * (model y))%R).

(* Why3 assumption *)
Definition div_post (m:floating_point.Rounding.mode)
    (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single)
    (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (round m ((value x) / (value y))%R)) /\
  ((exact res) = ((exact x) / (exact y))%R) /\
  ((model res) = ((model x) / (model y))%R).

(* Why3 assumption *)
Definition neg_post (x:floating_point.SingleFormat.single)
    (res:floating_point.SingleFormat.single) : Prop :=
  ((value res) = (-(value x))%R) /\
  ((exact res) = (-(exact x))%R) /\ ((model res) = (-(model x))%R).

(* Why3 assumption *)
Definition lt (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single) : Prop :=
  ((value x) < (value y))%R.

(* Why3 assumption *)
Definition gt (x:floating_point.SingleFormat.single)
    (y:floating_point.SingleFormat.single) : Prop :=
  ((value y) < (value x))%R.
