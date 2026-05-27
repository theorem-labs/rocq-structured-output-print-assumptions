From PrintAssumptionsJSON Require Import PrintAssumptionsJSON.

(* Test: closed term with no assumptions *)
Definition foo := 1 + 1.
Print Assumptions JSON foo.
Print Assumptions JSON Pretty foo.
Print Assumptions JSONL foo.

(* Test: term depending on an axiom *)
Axiom my_axiom : nat.
Definition bar := my_axiom + 1.
Print Assumptions JSON bar.
Print Assumptions JSON Pretty bar.
Print Assumptions JSONL bar.

(* Test: multiple axioms *)
Axiom ax1 : nat.
Axiom ax2 : nat -> nat.
Definition baz := ax2 (ax1 + my_axiom).
Print Assumptions JSON baz.
Print Assumptions JSON Pretty baz.
Print Assumptions JSONL baz.

(* Test: opaque proof *)
Lemma opaque_lemma : forall n : nat, n + 0 = n.
Proof. induction n; simpl; auto. Qed.
Definition uses_opaque := opaque_lemma 3.
Print Opaque Dependencies JSON uses_opaque.
Print Opaque Dependencies JSON Pretty uses_opaque.

(* Test: transparent dependencies *)
Print Transparent Dependencies JSON bar.
Print Transparent Dependencies JSON Pretty bar.
Print Transparent Dependencies JSONL bar.

(* Test: all dependencies *)
Print All Dependencies JSON bar.
Print All Dependencies JSON Pretty bar.
Print All Dependencies JSONL bar.

(* Test: multiple references at once *)
Print Assumptions JSON foo bar.
Print Assumptions JSON Pretty foo bar.
Print Assumptions JSONL foo bar.

(* Test: section variables *)
Section S.
  Variable x : nat.
  Definition sec_def := x + 1.
  Print Assumptions JSON sec_def.
  Print Assumptions JSON Pretty sec_def.
  Print Assumptions JSONL sec_def.
End S.
