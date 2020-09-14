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
Require floating_point.DoubleFormat.

Require Import floating_point.GenFloat.

(* Why3 goal *)
Definition round :
  floating_point.Rounding.mode -> Reals.Rdefinitions.R ->
  Reals.Rdefinitions.R.
exact (round 53 1024).
Defined.

(* Why3 goal *)
Definition value :
  floating_point.DoubleFormat.double -> Reals.Rdefinitions.R.
exact (value 53 1024).
Defined.

(* Why3 goal *)
Definition exact :
  floating_point.DoubleFormat.double -> Reals.Rdefinitions.R.
exact (exact 53 1024).
Defined.

(* Why3 goal *)
Definition model :
  floating_point.DoubleFormat.double -> Reals.Rdefinitions.R.
exact (model 53 1024).
Defined.

(* Why3 assumption *)
Definition round_error (x:floating_point.DoubleFormat.double) :
    Reals.Rdefinitions.R :=
  Reals.Rbasic_fun.Rabs ((value x) - (exact x))%R.

(* Why3 assumption *)
Definition total_error (x:floating_point.DoubleFormat.double) :
    Reals.Rdefinitions.R :=
  Reals.Rbasic_fun.Rabs ((value x) - (model x))%R.

(* Why3 assumption *)
Definition no_overflow (m:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R) : Prop :=
  ((Reals.Rbasic_fun.Rabs (round m x)) <=
   (9007199254740991 * 19958403095347198116563727130368385660674512604354575415025472424372118918689640657849579654926357010893424468441924952439724379883935936607391717982848314203200056729510856765175377214443629871826533567445439239933308104551208703888888552684480441575071209068757560416423584952303440099278848)%R)%R.

(* Why3 goal *)
Lemma Bounded_real_no_overflow :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R),
  ((Reals.Rbasic_fun.Rabs x) <=
   (9007199254740991 * 19958403095347198116563727130368385660674512604354575415025472424372118918689640657849579654926357010893424468441924952439724379883935936607391717982848314203200056729510856765175377214443629871826533567445439239933308104551208703888888552684480441575071209068757560416423584952303440099278848)%R)%R ->
  no_overflow m x.
exact (Bounded_real_no_overflow 53 1024 (refl_equal true) (refl_equal true)).
Qed.

(* Why3 goal *)
Lemma Round_monotonic :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R)
    (y:Reals.Rdefinitions.R),
  (x <= y)%R -> ((round m x) <= (round m y))%R.
now apply Round_monotonic.
Qed.

(* Why3 goal *)
Lemma Round_idempotent :
  forall (m1:floating_point.Rounding.mode) (m2:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R),
  ((round m1 (round m2 x)) = (round m2 x)).
now apply Round_idempotent.
Qed.

(* Why3 goal *)
Lemma Round_value :
  forall (m:floating_point.Rounding.mode)
    (x:floating_point.DoubleFormat.double),
  ((round m (value x)) = (value x)).
now apply Round_value.
Qed.

(* Why3 goal *)
Lemma Bounded_value :
  forall (x:floating_point.DoubleFormat.double),
  ((Reals.Rbasic_fun.Rabs (value x)) <=
   (9007199254740991 * 19958403095347198116563727130368385660674512604354575415025472424372118918689640657849579654926357010893424468441924952439724379883935936607391717982848314203200056729510856765175377214443629871826533567445439239933308104551208703888888552684480441575071209068757560416423584952303440099278848)%R)%R.
now apply Bounded_value.
Qed.

(* Why3 goal *)
Lemma Exact_rounding_for_integers :
  forall (m:floating_point.Rounding.mode) (i:Numbers.BinNums.Z),
  ((-9007199254740992%Z)%Z <= i)%Z /\ (i <= 9007199254740992%Z)%Z ->
  ((round m (BuiltIn.IZR i)) = (BuiltIn.IZR i)).
Proof.
intros m i Hi.
now apply Exact_rounding_for_integers.
Qed.

(* Why3 goal *)
Lemma Round_down_le :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Down x) <= x)%R.
now apply Round_down_le.
Qed.

(* Why3 goal *)
Lemma Round_up_ge :
  forall (x:Reals.Rdefinitions.R),
  (x <= (round floating_point.Rounding.Up x))%R.
now apply Round_up_ge.
Qed.

(* Why3 goal *)
Lemma Round_down_neg :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Down (-x)%R) =
   (-(round floating_point.Rounding.Up x))%R).
now apply Round_down_neg.
Qed.

(* Why3 goal *)
Lemma Round_up_neg :
  forall (x:Reals.Rdefinitions.R),
  ((round floating_point.Rounding.Up (-x)%R) =
   (-(round floating_point.Rounding.Down x))%R).
now apply Round_up_neg.
Qed.

(* Why3 goal *)
Definition round_logic :
  floating_point.Rounding.mode -> Reals.Rdefinitions.R ->
  floating_point.DoubleFormat.double.
exact (round_logic 53 1024 (refl_equal true) (refl_equal true)).
Defined.

(* Why3 goal *)
Lemma Round_logic_def :
  forall (m:floating_point.Rounding.mode) (x:Reals.Rdefinitions.R),
  no_overflow m x -> ((value (round_logic m x)) = (round m x)).
Proof.
exact (Round_logic_def 53 1024 (refl_equal true) (refl_equal true)).
Qed.

(* Why3 assumption *)
Definition of_real_post (m:floating_point.Rounding.mode)
    (x:Reals.Rdefinitions.R) (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (round m x)) /\ ((exact res) = x) /\ ((model res) = x).

(* Why3 assumption *)
Definition add_post (m:floating_point.Rounding.mode)
    (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double)
    (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (round m ((value x) + (value y))%R)) /\
  ((exact res) = ((exact x) + (exact y))%R) /\
  ((model res) = ((model x) + (model y))%R).

(* Why3 assumption *)
Definition sub_post (m:floating_point.Rounding.mode)
    (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double)
    (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (round m ((value x) - (value y))%R)) /\
  ((exact res) = ((exact x) - (exact y))%R) /\
  ((model res) = ((model x) - (model y))%R).

(* Why3 assumption *)
Definition mul_post (m:floating_point.Rounding.mode)
    (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double)
    (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (round m ((value x) * (value y))%R)) /\
  ((exact res) = ((exact x) * (exact y))%R) /\
  ((model res) = ((model x) * (model y))%R).

(* Why3 assumption *)
Definition div_post (m:floating_point.Rounding.mode)
    (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double)
    (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (round m ((value x) / (value y))%R)) /\
  ((exact res) = ((exact x) / (exact y))%R) /\
  ((model res) = ((model x) / (model y))%R).

(* Why3 assumption *)
Definition neg_post (x:floating_point.DoubleFormat.double)
    (res:floating_point.DoubleFormat.double) : Prop :=
  ((value res) = (-(value x))%R) /\
  ((exact res) = (-(exact x))%R) /\ ((model res) = (-(model x))%R).

(* Why3 assumption *)
Definition lt (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double) : Prop :=
  ((value x) < (value y))%R.

(* Why3 assumption *)
Definition gt (x:floating_point.DoubleFormat.double)
    (y:floating_point.DoubleFormat.double) : Prop :=
  ((value y) < (value x))%R.
