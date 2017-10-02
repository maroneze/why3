(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Reals.Rbasic_fun.
Require Reals.R_sqrt.
Require Reals.Rtrigo_def.
Require Reals.Rtrigo1.
Require Reals.Ratan.
Require BuiltIn.
Require real.Real.
Require real.RealInfix.
Require real.Abs.
Require real.FromInt.
Require int.Int.
Require real.Truncate.
Require real.Square.
Require real.Trigonometry.
Require ieee_float.GenericFloat.
Require bv.Pow2int.

Axiom t : Type.
Parameter t_WhyType : WhyType t.
Existing Instance t_WhyType.

Parameter t'real: t -> R.

Parameter t'isFinite: t -> Prop.

Axiom t'axiom : forall (x:t), (t'isFinite x) ->
  (((-(16777215 * 20282409603651670423947251286016)%R)%R <= (t'real x))%R /\
  ((t'real x) <= (16777215 * 20282409603651670423947251286016)%R)%R).

(* Why3 assumption *)
Inductive mode :=
  | RNE : mode
  | RNA : mode
  | RTP : mode
  | RTN : mode
  | RTZ : mode.
Axiom mode_WhyType : WhyType mode.
Existing Instance mode_WhyType.

(* Why3 assumption *)
Definition to_nearest (m:mode): Prop := (m = RNE) \/ (m = RNA).

Parameter zeroF: t.

Parameter add: mode -> t -> t -> t.

Parameter sub: mode -> t -> t -> t.

Parameter mul: mode -> t -> t -> t.

Parameter div: mode -> t -> t -> t.

Parameter abs: t -> t.

Parameter neg: t -> t.

Parameter fma: mode -> t -> t -> t -> t.

Parameter sqrt: mode -> t -> t.

Parameter roundToIntegral: mode -> t -> t.

Parameter min: t -> t -> t.

Parameter max: t -> t -> t.

Parameter le: t -> t -> Prop.

Parameter lt: t -> t -> Prop.

Parameter eq: t -> t -> Prop.

Parameter is_normal: t -> Prop.

Parameter is_subnormal: t -> Prop.

Parameter is_zero: t -> Prop.

Parameter is_infinite: t -> Prop.

Parameter is_nan: t -> Prop.

Parameter is_positive: t -> Prop.

Parameter is_negative: t -> Prop.

(* Why3 assumption *)
Definition is_plus_infinity (x:t): Prop := (is_infinite x) /\ (is_positive
  x).

(* Why3 assumption *)
Definition is_minus_infinity (x:t): Prop := (is_infinite x) /\ (is_negative
  x).

(* Why3 assumption *)
Definition is_plus_zero (x:t): Prop := (is_zero x) /\ (is_positive x).

(* Why3 assumption *)
Definition is_minus_zero (x:t): Prop := (is_zero x) /\ (is_negative x).

(* Why3 assumption *)
Definition is_not_nan (x:t): Prop := (t'isFinite x) \/ (is_infinite x).

Axiom is_not_nan1 : forall (x:t), (is_not_nan x) <-> ~ (is_nan x).

Axiom is_not_finite : forall (x:t), (~ (t'isFinite x)) <-> ((is_infinite
  x) \/ (is_nan x)).

Axiom zeroF_is_positive : (is_positive zeroF).

Axiom zeroF_is_zero : (is_zero zeroF).

Axiom zero_to_real : forall (x:t), (is_zero x) <-> ((t'isFinite x) /\
  ((t'real x) = 0%R)).

Parameter of_int: mode -> Z -> t.

Parameter to_int: mode -> t -> Z.

Axiom zero_of_int : forall (m:mode), (zeroF = (of_int m 0%Z)).

Parameter round: mode -> R -> R.

Parameter max_int: Z.

Axiom max_real_int : ((33554430 * 10141204801825835211973625643008)%R = (Reals.Raxioms.IZR max_int)).

(* Why3 assumption *)
Definition in_range (x:R): Prop :=
  ((-(33554430 * 10141204801825835211973625643008)%R)%R <= x)%R /\
  (x <= (33554430 * 10141204801825835211973625643008)%R)%R.

(* Why3 assumption *)
Definition in_int_range (i:Z): Prop := ((-max_int)%Z <= i)%Z /\
  (i <= max_int)%Z.

Axiom is_finite : forall (x:t), (t'isFinite x) -> (in_range (t'real x)).

(* Why3 assumption *)
Definition no_overflow (m:mode) (x:R): Prop := (in_range (round m x)).

Axiom Bounded_real_no_overflow : forall (m:mode) (x:R), (in_range x) ->
  (no_overflow m x).

Axiom Round_monotonic : forall (m:mode) (x:R) (y:R), (x <= y)%R -> ((round m
  x) <= (round m y))%R.

Axiom Round_idempotent : forall (m1:mode) (m2:mode) (x:R), ((round m1
  (round m2 x)) = (round m2 x)).

Axiom Round_to_real : forall (m:mode) (x:t), (t'isFinite x) -> ((round m
  (t'real x)) = (t'real x)).

Axiom Round_down_le : forall (x:R), ((round RTN x) <= x)%R.

Axiom Round_up_ge : forall (x:R), (x <= (round RTP x))%R.

Axiom Round_down_neg : forall (x:R), ((round RTN (-x)%R) = (-(round RTP
  x))%R).

Axiom Round_up_neg : forall (x:R), ((round RTP (-x)%R) = (-(round RTN x))%R).

(* Why3 assumption *)
Definition in_safe_int_range (i:Z): Prop := ((-16777216%Z)%Z <= i)%Z /\
  (i <= 16777216%Z)%Z.

Axiom Exact_rounding_for_integers : forall (m:mode) (i:Z), (in_safe_int_range
  i) -> ((round m (Reals.Raxioms.IZR i)) = (Reals.Raxioms.IZR i)).

(* Why3 assumption *)
Definition same_sign (x:t) (y:t): Prop := ((is_positive x) /\ (is_positive
  y)) \/ ((is_negative x) /\ (is_negative y)).

(* Why3 assumption *)
Definition diff_sign (x:t) (y:t): Prop := ((is_positive x) /\ (is_negative
  y)) \/ ((is_negative x) /\ (is_positive y)).

Axiom feq_eq : forall (x:t) (y:t), (t'isFinite x) -> ((t'isFinite y) ->
  ((~ (is_zero x)) -> ((eq x y) -> (x = y)))).

Axiom eq_feq : forall (x:t) (y:t), (t'isFinite x) -> ((t'isFinite y) ->
  ((x = y) -> (eq x y))).

Axiom eq_refl : forall (x:t), (t'isFinite x) -> (eq x x).

Axiom eq_sym : forall (x:t) (y:t), (eq x y) -> (eq y x).

Axiom eq_trans : forall (x:t) (y:t) (z:t), (eq x y) -> ((eq y z) -> (eq x
  z)).

Axiom eq_zero : (eq zeroF (neg zeroF)).

Axiom eq_to_real_finite : forall (x:t) (y:t), ((t'isFinite x) /\ (t'isFinite
  y)) -> ((eq x y) <-> ((t'real x) = (t'real y))).

Axiom eq_special : forall (x:t) (y:t), (eq x y) -> ((is_not_nan x) /\
  ((is_not_nan y) /\ (((t'isFinite x) /\ (t'isFinite y)) \/ ((is_infinite
  x) /\ ((is_infinite y) /\ (same_sign x y)))))).

Axiom lt_finite : forall (x:t) (y:t), ((t'isFinite x) /\ (t'isFinite y)) ->
  ((lt x y) <-> ((t'real x) < (t'real y))%R).

Axiom le_finite : forall (x:t) (y:t), ((t'isFinite x) /\ (t'isFinite y)) ->
  ((le x y) <-> ((t'real x) <= (t'real y))%R).

Axiom le_lt_trans : forall (x:t) (y:t) (z:t), ((le x y) /\ (lt y z)) -> (lt x
  z).

Axiom lt_le_trans : forall (x:t) (y:t) (z:t), ((lt x y) /\ (le y z)) -> (lt x
  z).

Axiom le_ge_asym : forall (x:t) (y:t), ((le x y) /\ (le y x)) -> (eq x y).

Axiom not_lt_ge : forall (x:t) (y:t), ((~ (lt x y)) /\ ((is_not_nan x) /\
  (is_not_nan y))) -> (le y x).

Axiom not_gt_le : forall (x:t) (y:t), ((~ (lt y x)) /\ ((is_not_nan x) /\
  (is_not_nan y))) -> (le x y).

Axiom le_special : forall (x:t) (y:t), (le x y) -> (((t'isFinite x) /\
  (t'isFinite y)) \/ (((is_minus_infinity x) /\ (is_not_nan y)) \/
  ((is_not_nan x) /\ (is_plus_infinity y)))).

Axiom lt_special : forall (x:t) (y:t), (lt x y) -> (((t'isFinite x) /\
  (t'isFinite y)) \/ (((is_minus_infinity x) /\ ((is_not_nan y) /\
  ~ (is_minus_infinity y))) \/ ((is_not_nan x) /\ ((~ (is_plus_infinity
  x)) /\ (is_plus_infinity y))))).

Axiom lt_lt_finite : forall (x:t) (y:t) (z:t), (lt x y) -> ((lt y z) ->
  (t'isFinite y)).

Axiom positive_to_real : forall (x:t), (t'isFinite x) -> ((is_positive x) ->
  (0%R <= (t'real x))%R).

Axiom to_real_positive : forall (x:t), (t'isFinite x) ->
  ((0%R < (t'real x))%R -> (is_positive x)).

Axiom negative_to_real : forall (x:t), (t'isFinite x) -> ((is_negative x) ->
  ((t'real x) <= 0%R)%R).

Axiom to_real_negative : forall (x:t), (t'isFinite x) ->
  (((t'real x) < 0%R)%R -> (is_negative x)).

Axiom negative_xor_positive : forall (x:t), ~ ((is_positive x) /\
  (is_negative x)).

Axiom negative_or_positive : forall (x:t), (is_not_nan x) -> ((is_positive
  x) \/ (is_negative x)).

Axiom diff_sign_trans : forall (x:t) (y:t) (z:t), ((diff_sign x y) /\
  (diff_sign y z)) -> (same_sign x z).

Axiom diff_sign_product : forall (x:t) (y:t), ((t'isFinite x) /\ ((t'isFinite
  y) /\ (((t'real x) * (t'real y))%R < 0%R)%R)) -> (diff_sign x y).

Axiom same_sign_product : forall (x:t) (y:t), ((t'isFinite x) /\ ((t'isFinite
  y) /\ (same_sign x y))) -> (0%R <= ((t'real x) * (t'real y))%R)%R.

(* Why3 assumption *)
Definition product_sign (z:t) (x:t) (y:t): Prop := ((same_sign x y) ->
  (is_positive z)) /\ ((diff_sign x y) -> (is_negative z)).

(* Why3 assumption *)
Definition overflow_value (m:mode) (x:t): Prop :=
  match m with
  | RTN => ((is_positive x) -> ((t'isFinite x) /\
      ((t'real x) = (33554430 * 10141204801825835211973625643008)%R))) /\
      ((~ (is_positive x)) -> (is_infinite x))
  | RTP => ((is_positive x) -> (is_infinite x)) /\ ((~ (is_positive x)) ->
      ((t'isFinite x) /\
      ((t'real x) = (-(33554430 * 10141204801825835211973625643008)%R)%R)))
  | RTZ => ((is_positive x) -> ((t'isFinite x) /\
      ((t'real x) = (33554430 * 10141204801825835211973625643008)%R))) /\
      ((~ (is_positive x)) -> ((t'isFinite x) /\
      ((t'real x) = (-(33554430 * 10141204801825835211973625643008)%R)%R)))
  | (RNA|RNE) => (is_infinite x)
  end.

(* Why3 assumption *)
Definition sign_zero_result (m:mode) (x:t): Prop := (is_zero x) ->
  match m with
  | RTN => (is_negative x)
  | _ => (is_positive x)
  end.

Axiom add_finite : forall (m:mode) (x:t) (y:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((no_overflow m ((t'real x) + (t'real y))%R) ->
  ((t'isFinite (add m x y)) /\ ((t'real (add m x y)) = (round m
  ((t'real x) + (t'real y))%R))))).

Axiom add_finite_rev : forall (m:mode) (x:t) (y:t), (t'isFinite (add m x
  y)) -> ((t'isFinite x) /\ (t'isFinite y)).

Axiom add_finite_rev_n : forall (m:mode) (x:t) (y:t), (to_nearest m) ->
  ((t'isFinite (add m x y)) -> ((no_overflow m
  ((t'real x) + (t'real y))%R) /\ ((t'real (add m x y)) = (round m
  ((t'real x) + (t'real y))%R)))).

Axiom sub_finite : forall (m:mode) (x:t) (y:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((no_overflow m ((t'real x) - (t'real y))%R) ->
  ((t'isFinite (sub m x y)) /\ ((t'real (sub m x y)) = (round m
  ((t'real x) - (t'real y))%R))))).

Axiom sub_finite_rev : forall (m:mode) (x:t) (y:t), (t'isFinite (sub m x
  y)) -> ((t'isFinite x) /\ (t'isFinite y)).

Axiom sub_finite_rev_n : forall (m:mode) (x:t) (y:t), (to_nearest m) ->
  ((t'isFinite (sub m x y)) -> ((no_overflow m
  ((t'real x) - (t'real y))%R) /\ ((t'real (sub m x y)) = (round m
  ((t'real x) - (t'real y))%R)))).

Axiom mul_finite : forall (m:mode) (x:t) (y:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((no_overflow m ((t'real x) * (t'real y))%R) ->
  ((t'isFinite (mul m x y)) /\ ((t'real (mul m x y)) = (round m
  ((t'real x) * (t'real y))%R))))).

Axiom mul_finite_rev : forall (m:mode) (x:t) (y:t), (t'isFinite (mul m x
  y)) -> ((t'isFinite x) /\ (t'isFinite y)).

Axiom mul_finite_rev_n : forall (m:mode) (x:t) (y:t), (to_nearest m) ->
  ((t'isFinite (mul m x y)) -> ((no_overflow m
  ((t'real x) * (t'real y))%R) /\ ((t'real (mul m x y)) = (round m
  ((t'real x) * (t'real y))%R)))).

Axiom div_finite : forall (m:mode) (x:t) (y:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((~ (is_zero y)) -> ((no_overflow m
  ((t'real x) / (t'real y))%R) -> ((t'isFinite (div m x y)) /\
  ((t'real (div m x y)) = (round m ((t'real x) / (t'real y))%R)))))).

Axiom div_finite_rev : forall (m:mode) (x:t) (y:t), (t'isFinite (div m x
  y)) -> (((t'isFinite x) /\ ((t'isFinite y) /\ ~ (is_zero y))) \/
  ((t'isFinite x) /\ ((is_infinite y) /\ ((t'real (div m x y)) = 0%R)))).

Axiom div_finite_rev_n : forall (m:mode) (x:t) (y:t), (to_nearest m) ->
  ((t'isFinite (div m x y)) -> ((t'isFinite y) -> ((no_overflow m
  ((t'real x) / (t'real y))%R) /\ ((t'real (div m x y)) = (round m
  ((t'real x) / (t'real y))%R))))).

Axiom neg_finite : forall (x:t), (t'isFinite x) -> ((t'isFinite (neg x)) /\
  ((t'real (neg x)) = (-(t'real x))%R)).

Axiom neg_finite_rev : forall (x:t), (t'isFinite (neg x)) -> ((t'isFinite
  x) /\ ((t'real (neg x)) = (-(t'real x))%R)).

Axiom abs_finite : forall (x:t), (t'isFinite x) -> ((t'isFinite (abs x)) /\
  (((t'real (abs x)) = (Reals.Rbasic_fun.Rabs (t'real x))) /\ (is_positive
  (abs x)))).

Axiom abs_finite_rev : forall (x:t), (t'isFinite (abs x)) -> ((t'isFinite
  x) /\ ((t'real (abs x)) = (Reals.Rbasic_fun.Rabs (t'real x)))).

Axiom abs_universal : forall (x:t), ~ (is_negative (abs x)).

Axiom fma_finite : forall (m:mode) (x:t) (y:t) (z:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((t'isFinite z) -> ((no_overflow m
  (((t'real x) * (t'real y))%R + (t'real z))%R) -> ((t'isFinite (fma m x y
  z)) /\ ((t'real (fma m x y z)) = (round m
  (((t'real x) * (t'real y))%R + (t'real z))%R)))))).

Axiom fma_finite_rev : forall (m:mode) (x:t) (y:t) (z:t), (t'isFinite (fma m
  x y z)) -> ((t'isFinite x) /\ ((t'isFinite y) /\ (t'isFinite z))).

Axiom fma_finite_rev_n : forall (m:mode) (x:t) (y:t) (z:t), (to_nearest m) ->
  ((t'isFinite (fma m x y z)) -> ((no_overflow m
  (((t'real x) * (t'real y))%R + (t'real z))%R) /\ ((t'real (fma m x y
  z)) = (round m (((t'real x) * (t'real y))%R + (t'real z))%R)))).

Axiom sqrt_finite : forall (m:mode) (x:t), (t'isFinite x) ->
  ((0%R <= (t'real x))%R -> ((t'isFinite (sqrt m x)) /\ ((t'real (sqrt m
  x)) = (round m (Reals.R_sqrt.sqrt (t'real x)))))).

Axiom sqrt_finite_rev : forall (m:mode) (x:t), (t'isFinite (sqrt m x)) ->
  ((t'isFinite x) /\ ((0%R <= (t'real x))%R /\ ((t'real (sqrt m
  x)) = (round m (Reals.R_sqrt.sqrt (t'real x)))))).

(* Why3 assumption *)
Definition same_sign_real (x:t) (r:R): Prop := ((is_positive x) /\
  (0%R < r)%R) \/ ((is_negative x) /\ (r < 0%R)%R).

Axiom add_special : forall (m:mode) (x:t) (y:t), let r := (add m x y) in
  ((((is_nan x) \/ (is_nan y)) -> (is_nan r)) /\ ((((t'isFinite x) /\
  (is_infinite y)) -> ((is_infinite r) /\ (same_sign r y))) /\
  ((((is_infinite x) /\ (t'isFinite y)) -> ((is_infinite r) /\ (same_sign r
  x))) /\ ((((is_infinite x) /\ ((is_infinite y) /\ (same_sign x y))) ->
  ((is_infinite r) /\ (same_sign r x))) /\ ((((is_infinite x) /\
  ((is_infinite y) /\ (diff_sign x y))) -> (is_nan r)) /\ ((((t'isFinite
  x) /\ ((t'isFinite y) /\ ~ (no_overflow m ((t'real x) + (t'real y))%R))) ->
  ((same_sign_real r ((t'real x) + (t'real y))%R) /\ (overflow_value m
  r))) /\ (((t'isFinite x) /\ (t'isFinite y)) -> (((same_sign x y) ->
  (same_sign r x)) /\ ((~ (same_sign x y)) -> (sign_zero_result m
  r)))))))))).

Axiom sub_special : forall (m:mode) (x:t) (y:t), let r := (sub m x y) in
  ((((is_nan x) \/ (is_nan y)) -> (is_nan r)) /\ ((((t'isFinite x) /\
  (is_infinite y)) -> ((is_infinite r) /\ (diff_sign r y))) /\
  ((((is_infinite x) /\ (t'isFinite y)) -> ((is_infinite r) /\ (same_sign r
  x))) /\ ((((is_infinite x) /\ ((is_infinite y) /\ (same_sign x y))) ->
  (is_nan r)) /\ ((((is_infinite x) /\ ((is_infinite y) /\ (diff_sign x
  y))) -> ((is_infinite r) /\ (same_sign r x))) /\ ((((t'isFinite x) /\
  ((t'isFinite y) /\ ~ (no_overflow m ((t'real x) - (t'real y))%R))) ->
  ((same_sign_real r ((t'real x) - (t'real y))%R) /\ (overflow_value m
  r))) /\ (((t'isFinite x) /\ (t'isFinite y)) -> (((diff_sign x y) ->
  (same_sign r x)) /\ ((~ (diff_sign x y)) -> (sign_zero_result m
  r)))))))))).

Axiom mul_special : forall (m:mode) (x:t) (y:t), let r := (mul m x y) in
  ((((is_nan x) \/ (is_nan y)) -> (is_nan r)) /\ ((((is_zero x) /\
  (is_infinite y)) -> (is_nan r)) /\ ((((t'isFinite x) /\ ((is_infinite y) /\
  ~ (is_zero x))) -> (is_infinite r)) /\ ((((is_infinite x) /\ (is_zero
  y)) -> (is_nan r)) /\ ((((is_infinite x) /\ ((t'isFinite y) /\ ~ (is_zero
  y))) -> (is_infinite r)) /\ ((((is_infinite x) /\ (is_infinite y)) ->
  (is_infinite r)) /\ ((((t'isFinite x) /\ ((t'isFinite y) /\ ~ (no_overflow
  m ((t'real x) * (t'real y))%R))) -> (overflow_value m r)) /\ ((~ (is_nan
  r)) -> (product_sign r x y))))))))).

Axiom div_special : forall (m:mode) (x:t) (y:t), let r := (div m x y) in
  ((((is_nan x) \/ (is_nan y)) -> (is_nan r)) /\ ((((t'isFinite x) /\
  (is_infinite y)) -> (is_zero r)) /\ ((((is_infinite x) /\ (t'isFinite
  y)) -> (is_infinite r)) /\ ((((is_infinite x) /\ (is_infinite y)) ->
  (is_nan r)) /\ ((((t'isFinite x) /\ ((t'isFinite y) /\ ((~ (is_zero y)) /\
  ~ (no_overflow m ((t'real x) / (t'real y))%R)))) -> (overflow_value m
  r)) /\ ((((t'isFinite x) /\ ((is_zero y) /\ ~ (is_zero x))) -> (is_infinite
  r)) /\ ((((is_zero x) /\ (is_zero y)) -> (is_nan r)) /\ ((~ (is_nan r)) ->
  (product_sign r x y))))))))).

Axiom neg_special : forall (x:t), ((is_nan x) -> (is_nan (neg x))) /\
  (((is_infinite x) -> (is_infinite (neg x))) /\ ((~ (is_nan x)) ->
  (diff_sign x (neg x)))).

Axiom abs_special : forall (x:t), ((is_nan x) -> (is_nan (abs x))) /\
  (((is_infinite x) -> (is_infinite (abs x))) /\ ((~ (is_nan x)) ->
  (is_positive (abs x)))).

Axiom fma_special : forall (m:mode) (x:t) (y:t) (z:t), let r := (fma m x y
  z) in ((((is_nan x) \/ ((is_nan y) \/ (is_nan z))) -> (is_nan r)) /\
  ((((is_zero x) /\ (is_infinite y)) -> (is_nan r)) /\ ((((is_infinite x) /\
  (is_zero y)) -> (is_nan r)) /\ ((((t'isFinite x) /\ ((~ (is_zero x)) /\
  ((is_infinite y) /\ (t'isFinite z)))) -> ((is_infinite r) /\ (product_sign
  r x y))) /\ ((((t'isFinite x) /\ ((~ (is_zero x)) /\ ((is_infinite y) /\
  (is_infinite z)))) -> (((product_sign z x y) -> ((is_infinite r) /\
  (same_sign r z))) /\ ((~ (product_sign z x y)) -> (is_nan r)))) /\
  ((((is_infinite x) /\ ((t'isFinite y) /\ ((~ (is_zero y)) /\ (t'isFinite
  z)))) -> ((is_infinite r) /\ (product_sign r x y))) /\ ((((is_infinite
  x) /\ ((t'isFinite y) /\ ((~ (is_zero y)) /\ (is_infinite z)))) ->
  (((product_sign z x y) -> ((is_infinite r) /\ (same_sign r z))) /\
  ((~ (product_sign z x y)) -> (is_nan r)))) /\ ((((is_infinite x) /\
  ((is_infinite y) /\ (t'isFinite z))) -> ((is_infinite r) /\ (product_sign r
  x y))) /\ ((((t'isFinite x) /\ ((t'isFinite y) /\ (is_infinite z))) ->
  ((is_infinite r) /\ (same_sign r z))) /\ ((((is_infinite x) /\
  ((is_infinite y) /\ (is_infinite z))) -> (((product_sign z x y) ->
  ((is_infinite r) /\ (same_sign r z))) /\ ((~ (product_sign z x y)) ->
  (is_nan r)))) /\ ((((t'isFinite x) /\ ((t'isFinite y) /\ ((t'isFinite z) /\
  ~ (no_overflow m (((t'real x) * (t'real y))%R + (t'real z))%R)))) ->
  ((same_sign_real r (((t'real x) * (t'real y))%R + (t'real z))%R) /\
  (overflow_value m r))) /\ (((t'isFinite x) /\ ((t'isFinite y) /\
  (t'isFinite z))) -> (((product_sign z x y) -> (same_sign r z)) /\
  ((~ (product_sign z x y)) ->
  (((((t'real x) * (t'real y))%R + (t'real z))%R = 0%R) -> (((m = RTN) ->
  (is_negative r)) /\ ((~ (m = RTN)) -> (is_positive r)))))))))))))))))).

Axiom sqrt_special : forall (m:mode) (x:t), let r := (sqrt m x) in (((is_nan
  x) -> (is_nan r)) /\ (((is_plus_infinity x) -> (is_plus_infinity r)) /\
  (((is_minus_infinity x) -> (is_nan r)) /\ ((((t'isFinite x) /\
  ((t'real x) < 0%R)%R) -> (is_nan r)) /\ (((is_zero x) -> (same_sign r
  x)) /\ (((t'isFinite x) /\ (0%R < (t'real x))%R) -> (is_positive r))))))).

Axiom of_int_add_exact : forall (m:mode) (n:mode) (i:Z) (j:Z),
  (in_safe_int_range i) -> ((in_safe_int_range j) -> ((in_safe_int_range
  (i + j)%Z) -> (eq (of_int m (i + j)%Z) (add n (of_int m i) (of_int m
  j))))).

Axiom of_int_sub_exact : forall (m:mode) (n:mode) (i:Z) (j:Z),
  (in_safe_int_range i) -> ((in_safe_int_range j) -> ((in_safe_int_range
  (i - j)%Z) -> (eq (of_int m (i - j)%Z) (sub n (of_int m i) (of_int m
  j))))).

Axiom of_int_mul_exact : forall (m:mode) (n:mode) (i:Z) (j:Z),
  (in_safe_int_range i) -> ((in_safe_int_range j) -> ((in_safe_int_range
  (i * j)%Z) -> (eq (of_int m (i * j)%Z) (mul n (of_int m i) (of_int m
  j))))).

Axiom Min_r : forall (x:t) (y:t), (le y x) -> (eq (min x y) y).

Axiom Min_l : forall (x:t) (y:t), (le x y) -> (eq (min x y) x).

Axiom Max_r : forall (x:t) (y:t), (le y x) -> (eq (max x y) x).

Axiom Max_l : forall (x:t) (y:t), (le x y) -> (eq (max x y) y).

Parameter is_int: t -> Prop.

Axiom zeroF_is_int : (is_int zeroF).

Axiom of_int_is_int : forall (m:mode) (x:Z), (in_int_range x) -> (is_int
  (of_int m x)).

Axiom big_float_is_int : forall (m:mode) (i:t), (t'isFinite i) -> (((le i
  (neg (of_int m 16777216%Z))) \/ (le (of_int m 16777216%Z) i)) -> (is_int
  i)).

Axiom roundToIntegral_is_int : forall (m:mode) (x:t), (t'isFinite x) ->
  (is_int (roundToIntegral m x)).

Axiom eq_is_int : forall (x:t) (y:t), (eq x y) -> ((is_int x) -> (is_int y)).

Axiom add_int : forall (x:t) (y:t) (m:mode), (is_int x) -> ((is_int y) ->
  ((t'isFinite (add m x y)) -> (is_int (add m x y)))).

Axiom sub_int : forall (x:t) (y:t) (m:mode), (is_int x) -> ((is_int y) ->
  ((t'isFinite (sub m x y)) -> (is_int (sub m x y)))).

Axiom mul_int : forall (x:t) (y:t) (m:mode), (is_int x) -> ((is_int y) ->
  ((t'isFinite (mul m x y)) -> (is_int (mul m x y)))).

Axiom fma_int : forall (x:t) (y:t) (z:t) (m:mode), (is_int x) -> ((is_int
  y) -> ((is_int z) -> ((t'isFinite (fma m x y z)) -> (is_int (fma m x y
  z))))).

Axiom neg_int : forall (x:t), (is_int x) -> (is_int (neg x)).

Axiom abs_int : forall (x:t), (is_int x) -> (is_int (abs x)).

Axiom is_int_of_int : forall (x:t) (m:mode) (m':mode), (is_int x) -> (eq x
  (of_int m' (to_int m x))).

Axiom is_int_to_int : forall (m:mode) (x:t), (is_int x) -> (in_int_range
  (to_int m x)).

Axiom is_int_is_finite : forall (x:t), (is_int x) -> (t'isFinite x).

Axiom int_to_real : forall (m:mode) (x:t), (is_int x) ->
  ((t'real x) = (Reals.Raxioms.IZR (to_int m x))).

Axiom truncate_int : forall (m:mode) (i:t), (is_int i) -> (eq
  (roundToIntegral m i) i).

Axiom truncate_neg : forall (x:t), (t'isFinite x) -> ((is_negative x) ->
  ((roundToIntegral RTZ x) = (roundToIntegral RTP x))).

Axiom truncate_pos : forall (x:t), (t'isFinite x) -> ((is_positive x) ->
  ((roundToIntegral RTZ x) = (roundToIntegral RTN x))).

Axiom ceil_le : forall (x:t), (t'isFinite x) -> (le x (roundToIntegral RTP
  x)).

Axiom ceil_lest : forall (x:t) (y:t), ((le x y) /\ (is_int y)) -> (le
  (roundToIntegral RTP x) y).

Axiom ceil_to_real : forall (x:t), (t'isFinite x) ->
  ((t'real (roundToIntegral RTP
  x)) = (Reals.Raxioms.IZR (real.Truncate.ceil (t'real x)))).

Axiom ceil_to_int : forall (m:mode) (x:t), (t'isFinite x) -> ((to_int m
  (roundToIntegral RTP x)) = (real.Truncate.ceil (t'real x))).

Axiom floor_le : forall (x:t), (t'isFinite x) -> (le (roundToIntegral RTN x)
  x).

Axiom floor_lest : forall (x:t) (y:t), ((le y x) /\ (is_int y)) -> (le y
  (roundToIntegral RTN x)).

Axiom floor_to_real : forall (x:t), (t'isFinite x) ->
  ((t'real (roundToIntegral RTN
  x)) = (Reals.Raxioms.IZR (real.Truncate.floor (t'real x)))).

Axiom floor_to_int : forall (m:mode) (x:t), (t'isFinite x) -> ((to_int m
  (roundToIntegral RTN x)) = (real.Truncate.floor (t'real x))).

Axiom RNA_down : forall (x:t), (lt (sub RNE x (roundToIntegral RTN x))
  (sub RNE (roundToIntegral RTP x) x)) -> ((roundToIntegral RNA
  x) = (roundToIntegral RTN x)).

Axiom RNA_up : forall (x:t), (lt (sub RNE (roundToIntegral RTP x) x) (sub RNE
  x (roundToIntegral RTN x))) -> ((roundToIntegral RNA
  x) = (roundToIntegral RTP x)).

Axiom RNA_down_tie : forall (x:t), (eq (sub RNE x (roundToIntegral RTN x))
  (sub RNE (roundToIntegral RTP x) x)) -> ((is_negative x) ->
  ((roundToIntegral RNA x) = (roundToIntegral RTN x))).

Axiom RNA_up_tie : forall (x:t), (eq (sub RNE (roundToIntegral RTP x) x)
  (sub RNE x (roundToIntegral RTN x))) -> ((is_positive x) ->
  ((roundToIntegral RNA x) = (roundToIntegral RTP x))).

Axiom to_int_roundToIntegral : forall (m:mode) (x:t), ((to_int m
  x) = (to_int m (roundToIntegral m x))).

Axiom to_int_monotonic : forall (m:mode) (x:t) (y:t), (t'isFinite x) ->
  ((t'isFinite y) -> ((le x y) -> ((to_int m x) <= (to_int m y))%Z)).

Axiom to_int_of_int : forall (m:mode) (i:Z), (in_safe_int_range i) ->
  ((to_int m (of_int m i)) = i).

Axiom eq_to_int : forall (m:mode) (x:t) (y:t), (t'isFinite x) -> ((eq x y) ->
  ((to_int m x) = (to_int m y))).

Axiom neg_to_int : forall (m:mode) (x:t), (is_int x) -> ((to_int m
  (neg x)) = (-(to_int m x))%Z).

Axiom roundToIntegral_is_finite : forall (m:mode) (x:t), (t'isFinite x) ->
  (t'isFinite (roundToIntegral m x)).

Axiom round_bound_ne : forall (x:R), (no_overflow RNE x) ->
  ((((x - ((1 / 16777216)%R * (Reals.Rbasic_fun.Rabs x))%R)%R - (1 / 1427247692705959881058285969449495136382746624)%R)%R <= (round RNE
  x))%R /\ ((round RNE
  x) <= ((x + ((1 / 16777216)%R * (Reals.Rbasic_fun.Rabs x))%R)%R + (1 / 1427247692705959881058285969449495136382746624)%R)%R)%R).

Axiom round_bound : forall (m:mode) (x:R), (no_overflow m x) ->
  ((((x - ((1 / 8388608)%R * (Reals.Rbasic_fun.Rabs x))%R)%R - (1 / 713623846352979940529142984724747568191373312)%R)%R <= (round m
  x))%R /\ ((round m
  x) <= ((x + ((1 / 8388608)%R * (Reals.Rbasic_fun.Rabs x))%R)%R + (1 / 713623846352979940529142984724747568191373312)%R)%R)%R).

(* Why3 assumption *)
Definition add_pre_ieee (x:t) (y:t): Prop := (t'isFinite (add RNE x y)).

(* Why3 assumption *)
Definition add_post_ieee (x:t) (y:t) (r:t): Prop := (r = (add RNE x y)).

(* Why3 assumption *)
Definition add_pre_real (x:t) (y:t): Prop := (no_overflow RNE
  ((t'real x) + (t'real y))%R).

(* Why3 assumption *)
Definition add_post_real (x:t) (y:t) (r:t): Prop := ((t'real r) = (round RNE
  ((t'real x) + (t'real y))%R)).

(* Why3 assumption *)
Definition sub_pre_ieee (x:t) (y:t): Prop := (t'isFinite (sub RNE x y)).

(* Why3 assumption *)
Definition sub_post_ieee (x:t) (y:t) (r:t): Prop := (r = (sub RNE x y)).

(* Why3 assumption *)
Definition sub_pre_real (x:t) (y:t): Prop := (no_overflow RNE
  ((t'real x) - (t'real y))%R).

(* Why3 assumption *)
Definition sub_post_real (x:t) (y:t) (r:t): Prop := ((t'real r) = (round RNE
  ((t'real x) - (t'real y))%R)).

(* Why3 assumption *)
Definition mul_pre_ieee (x:t) (y:t): Prop := (t'isFinite (mul RNE x y)).

(* Why3 assumption *)
Definition mul_post_ieee (x:t) (y:t) (r:t): Prop := (r = (mul RNE x y)).

(* Why3 assumption *)
Definition mul_pre_real (x:t) (y:t): Prop := (no_overflow RNE
  ((t'real x) * (t'real y))%R).

(* Why3 assumption *)
Definition mul_post_real (x:t) (y:t) (r:t): Prop := ((t'real r) = (round RNE
  ((t'real x) * (t'real y))%R)).

Parameter fliteral: t.

Axiom fliteral_axiom : (t'isFinite fliteral) /\
  ((t'real fliteral) = (1 / 32)%R).

Require Import Interval.Interval_tactic.

(* Why3 goal *)
Theorem VC_my_cosine : forall (x:t), (le (abs x) fliteral) ->
  (((Reals.Rbasic_fun.Rabs (t'real x)) <= (1 / 32)%R)%R ->
  ((Reals.Rbasic_fun.Rabs ((1%R - (((t'real x) * (t'real x))%R * (05 / 10)%R)%R)%R - (Reals.Rtrigo_def.cos (t'real x)))%R) <= (1 / 16777216)%R)%R).
Proof.
intros x h1 h2.
interval with (i_bisect_diff (t'real x)).
Qed.

