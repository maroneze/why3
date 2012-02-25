(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import Rbasic_fun.
Require int.Int.
Require real.Real.
Require real.Abs.
Require real.FromInt.
Require floating_point.Rounding.

Require Import floating_point.GenFloat.

(* Why3 goal *)
Definition single : Type.
exact (t 24 128).
Defined.

(* Why3 goal *)
Definition round: floating_point.Rounding.mode -> R -> R.
exact (round 24 128).
Defined.

(* Why3 goal *)
Definition round_logic: floating_point.Rounding.mode -> R -> single.
exact (round_logic 24 128 (refl_equal true) (refl_equal true)).
Defined.

(* Why3 goal *)
Definition value: single -> R.
exact (value 24 128).
Defined.

(* Why3 goal *)
Definition exact: single -> R.
exact (exact 24 128).
Defined.

(* Why3 goal *)
Definition model: single -> R.
exact (model 24 128).
Defined.

(* Why3 assumption *)
Definition round_error(x:single): R := (Rabs ((value x) - (exact x))%R).

(* Why3 assumption *)
Definition total_error(x:single): R := (Rabs ((value x) - (model x))%R).

(* Why3 assumption *)
Definition no_overflow(m:floating_point.Rounding.mode) (x:R): Prop :=
  ((Rabs (round m x)) <= (33554430 * 10141204801825835211973625643008)%R)%R.

Lemma max_single_eq: (33554430 * 10141204801825835211973625643008 = max 24 128)%R.
unfold max, Fcore_defs.F2R; simpl.
ring.
Qed.

(* Why3 goal *)
Lemma Bounded_real_no_overflow : forall (m:floating_point.Rounding.mode)
  (x:R), ((Rabs x) <= (33554430 * 10141204801825835211973625643008)%R)%R ->
  (no_overflow m x).
(* YOU MAY EDIT THE PROOF BELOW *)
intros m x Hx.
unfold no_overflow.
rewrite max_single_eq in *.
exact (Bounded_real_no_overflow 24 128 (refl_equal true) (refl_equal true) m x Hx).
Qed.

(* Why3 goal *)
Lemma Round_monotonic : forall (m:floating_point.Rounding.mode) (x:R) (y:R),
  (x <= y)%R -> ((round m x) <= (round m y))%R.
apply Round_monotonic.
easy.
Qed.

(* Why3 goal *)
Lemma Round_idempotent : forall (m1:floating_point.Rounding.mode)
  (m2:floating_point.Rounding.mode) (x:R), ((round m1 (round m2
  x)) = (round m2 x)).
now apply Round_idempotent.
Qed.

(* Why3 goal *)
Lemma Round_value : forall (m:floating_point.Rounding.mode) (x:single),
  ((round m (value x)) = (value x)).
now apply Round_value.
Qed.

(* Why3 goal *)
Lemma Bounded_value : forall (x:single),
  ((Rabs (value x)) <= (33554430 * 10141204801825835211973625643008)%R)%R.
rewrite max_single_eq.
now apply Bounded_value.
Qed.

(* Why3 goal *)
Lemma Exact_rounding_for_integers : forall (m:floating_point.Rounding.mode)
  (i:Z), (((-16777216%Z)%Z <= i)%Z /\ (i <= 16777216%Z)%Z) -> ((round m
  (IZR i)) = (IZR i)).
intros m i Hi.
now apply Exact_rounding_for_integers.
Qed.

(* Why3 goal *)
Lemma Round_down_le : forall (x:R), ((round floating_point.Rounding.Down
  x) <= x)%R.
now apply Round_down_le.
Qed.

(* Why3 goal *)
Lemma Round_up_ge : forall (x:R), (x <= (round floating_point.Rounding.Up
  x))%R.
now apply Round_up_ge.
Qed.

(* Why3 goal *)
Lemma Round_down_neg : forall (x:R), ((round floating_point.Rounding.Down
  (-x)%R) = (-(round floating_point.Rounding.Up x))%R).
now apply Round_down_neg.
Qed.

(* Why3 goal *)
Lemma Round_up_neg : forall (x:R), ((round floating_point.Rounding.Up
  (-x)%R) = (-(round floating_point.Rounding.Down x))%R).
now apply Round_up_neg.
Qed.


