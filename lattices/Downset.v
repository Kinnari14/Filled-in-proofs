Require Import RelationClasses.
Require Import Classical.
Require Import ClassicalChoice.
Require Import FunctionalExtensionality.
Require Import PropExtensionality.
Require Import Lattice.


(** * Interface *)

(** The downset lattice over a poset is a completely distributive
  completion that is join dense and completely join prime. We use it
  as an intermediate step in the construction of the free completely
  distributive lattice (see [Morris, 2005]), and it could be used to
  construct traditional strategies which only feature angelic
  nondeterminism. *)

Module Type DownsetSig.

  Parameter F : forall C `{Cpo : Poset C}, Type.
  Parameter lattice : forall `{Poset}, CDLattice (F C).
  Parameter down : forall `{Poset}, C -> F C.
  Existing Instance lattice.

  Axiom down_ref_emb :
    forall `{Poset} c1 c2, down c1 ⊑ down c2 <-> c1 ⊑ c2.

  Axiom down_dense :
    forall `{Poset} x, x = ⋁ {c | down c ⊑ x}; down c.

  Axiom down_prime :
    forall `{Poset} {I} c x, down c ⊑ sup x <-> exists i:I, down c ⊑ x i.

End DownsetSig.


(** * Construction *)

(** Our construction is straightforward. We use predicate
  extensionality to prove antisymmetry, and the axiom of choice to
  prove distributivity. *)

Module Downset : DownsetSig.

  Record downset {C} `{Cpo : Poset C} :=
    {
      has : C -> Prop;
      closed x y : x ⊑ y -> has y -> has x;
    }.

  Arguments downset C {Cpo}.
  Definition F C `{Poset C} := downset C.

  Local Obligation Tactic :=
    cbn; try solve [firstorder].

  Section DOWNSETS.
    Context {C} `{Cpo : Poset C}.

    (** ** Partial order *)

    Program Instance poset : Poset (downset C) :=
      {
        ref x y := forall c, has x c -> has y c;
      }.

    Next Obligation.
      intros [x Hx] [y Hy]. unfold ref. cbn. intros Hxy Hyz.
      assert (x = y).
      {
        apply functional_extensionality. intros c.
        apply propositional_extensionality. firstorder.
      }
      subst. f_equal. apply proof_irrelevance.
    Qed.

    (** ** Distributive lattice *)

    Program Instance lattice : CDLattice (downset C) :=
      {
        sup I x := {| has c := exists i, has (x i) c |};
        inf I x := {| has c := forall i, has (x i) c |};
      }.

    (** [sup] is downward closed. *)
    Next Obligation.
      intros I x c1 c2 Hc [i H2].
      eauto using @closed.
    Qed.

    (** [inf] is downward closed. *)
    Next Obligation.
      intros I x c1 c2 Hc H2 i.
      eauto using @closed.
    Qed.

    (** Distributivity. *)
    Next Obligation.
      intros.
      apply antisymmetry; cbn.
      - firstorder.
      - admit.
    Admitted.

    (** ** Embedding *)

    Program Definition down (c : C) :=
      {|
        has x := x ⊑ c;
      |}.
    Next Obligation.
      intros c x y Hxy Hyc.
      etransitivity; eauto.
    Qed.

    Lemma down_ref_emb c1 c2 :
      down c1 ⊑ down c2 <-> c1 ⊑ c2.
    Proof.
      cbn. firstorder.
      etransitivity; eauto.
    Qed.

    Lemma down_dense :
      forall x, x = ⋁{c : C | down c ⊑ x}; down c.
    Admitted.

    Lemma down_prime {I} c (x : I -> downset C) :
      down c ⊑ sup x <-> exists i, down c ⊑ x i.
    Admitted.

  End DOWNSETS.
End Downset.

Notation downset := Downset.F.