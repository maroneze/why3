(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.
Require map.Occ.
Require map.MapInjection.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map.Map.map Z a) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a} (v:(array a)): (map.Map.map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type} {a_WT:WhyType a} (v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get {a:Type} {a_WT:WhyType a} (a1:(array a)) (i:Z): a :=
  (map.Map.get (elts a1) i).

(* Why3 assumption *)
Definition set {a:Type} {a_WT:WhyType a} (a1:(array a)) (i:Z) (v:a): (array
  a) := (mk_array (length a1) (map.Map.set (elts a1) i v)).

(* Why3 assumption *)
Inductive sparse_array
  (a:Type) :=
  | mk_sparse_array : (array a) -> (array Z) -> (array Z) -> Z -> a ->
      sparse_array a.
Axiom sparse_array_WhyType : forall (a:Type) {a_WT:WhyType a},
  WhyType (sparse_array a).
Existing Instance sparse_array_WhyType.
Implicit Arguments mk_sparse_array [[a]].

(* Why3 assumption *)
Definition def {a:Type} {a_WT:WhyType a} (v:(sparse_array a)): a :=
  match v with
  | (mk_sparse_array x x1 x2 x3 x4) => x4
  end.

(* Why3 assumption *)
Definition card {a:Type} {a_WT:WhyType a} (v:(sparse_array a)): Z :=
  match v with
  | (mk_sparse_array x x1 x2 x3 x4) => x3
  end.

(* Why3 assumption *)
Definition back {a:Type} {a_WT:WhyType a} (v:(sparse_array a)): (array Z) :=
  match v with
  | (mk_sparse_array x x1 x2 x3 x4) => x2
  end.

(* Why3 assumption *)
Definition index {a:Type} {a_WT:WhyType a} (v:(sparse_array a)): (array Z) :=
  match v with
  | (mk_sparse_array x x1 x2 x3 x4) => x1
  end.

(* Why3 assumption *)
Definition values {a:Type} {a_WT:WhyType a} (v:(sparse_array a)): (array
  a) := match v with
  | (mk_sparse_array x x1 x2 x3 x4) => x
  end.

(* Why3 assumption *)
Definition is_elt {a:Type} {a_WT:WhyType a} (a1:(sparse_array a))
  (i:Z): Prop := ((0%Z <= (get (index a1) i))%Z /\ ((get (index a1)
  i) < (card a1))%Z) /\ ((get (back a1) (get (index a1) i)) = i).

Parameter value: forall {a:Type} {a_WT:WhyType a}, (sparse_array a) -> Z ->
  a.

Axiom value_def : forall {a:Type} {a_WT:WhyType a}, forall (a1:(sparse_array
  a)) (i:Z), ((is_elt a1 i) -> ((value a1 i) = (get (values a1) i))) /\
  ((~ (is_elt a1 i)) -> ((value a1 i) = (def a1))).

(* Why3 assumption *)
Definition length1 {a:Type} {a_WT:WhyType a} (a1:(sparse_array a)): Z :=
  (length (values a1)).

Require Import Why3.
Ltac ae := why3 "Alt-Ergo,0.99.1," timelimit 5; admit.

(* Why3 goal *)
Theorem permutation : forall {a:Type} {a_WT:WhyType a},
  forall (a1:(sparse_array a)), (((0%Z <= (card a1))%Z /\
  (((card a1) <= (length (values a1)))%Z /\
  ((length (values a1)) <= 1000%Z)%Z)) /\
  ((((length (values a1)) = (length (index a1))) /\
  ((length (index a1)) = (length (back a1)))) /\ forall (i:Z),
  ((0%Z <= i)%Z /\ (i < (card a1))%Z) -> (((0%Z <= (get (back a1) i))%Z /\
  ((get (back a1) i) < (length (values a1)))%Z) /\ ((get (index a1)
  (get (back a1) i)) = i)))) -> (((card a1) = (length1 a1)) -> forall (i:Z),
  ((0%Z <= i)%Z /\ (i < (length1 a1))%Z) -> (is_elt a1 i)).
(* Why3 intros a a_WT a1 ((h1,(h2,h3)),((h4,h5),h6)) h7 i (h8,h9). *)
intros a _a a1.
destruct a1 as ((n0, a_values), (n1, a_index), (n2, a_back), a_card, a_def); simpl.
unfold is_elt, length1, get; simpl.
intro H; decompose [and] H; clear H.
subst n1 n2.
intros. subst a_card.
assert (inj: MapInjection.injective a_back n0) by ae.
assert (rng: MapInjection.range a_back n0) by ae.
generalize (MapInjection.injective_surjective a_back n0 inj rng); intro surj.
destruct (surj i H1) as (j, (hj1, hj2)).
ae.
Admitted.

