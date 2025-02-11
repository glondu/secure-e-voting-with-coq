Require Import Bool.
Require Import Setoid.
Require Import Ring.
Require Import Field.

(** We start by defining a Monoid *)

Class Monoid (A:Set)(dot : A -> A -> A)(one : A)(bool_eq : A-> A-> bool) := {

    dot_assoc : forall x y z : A, dot x (dot y z) = dot (dot x y) z;
    one_left : forall x : A, dot one x = x;
    one_right : forall x : A, dot x one = x;

    (** The set equality should be boolean decidable
        pretty sure ssreflect provides a better way to do this *)

    bool_eq_corr: forall a b : A, bool_eq a b = true <-> a=b;
    bool_neq_corr: forall a b : A, bool_eq a b = false <-> a <> b;
}.

(** We now extend Monoids to various types of groups *)

Class Group (A:Set)(dot : A -> A -> A) (one : A) (bool_eq : A-> A-> bool) (inv : A -> A) := {
  grp_mon :> Monoid A dot one bool_eq;
  inv_left: forall x : A, one =  dot (inv x) x;
  inv_right: forall x : A, one =  dot x (inv x);
}.

Class AbeGroup (A:Set)(dot : A -> A -> A) (one : A) (bool_eq : A-> A-> bool) (inv : A -> A) := {
  abegrp_grp :> Group A dot one bool_eq inv;
  comm : forall a b : A, dot a b = dot b a;
}.

Section AdditionalGroupProperties. 

Generalizable Variables A dot Aone Ainv bool_equal.
Context `{AbeGroup A dot Aone bool_equal Ainv}.

Definition abegop `{AbeGroup A dot Aone bool_equal Ainv} := dot.
Definition abegone `{AbeGroup A dot Aone bool_equal Ainv} := Aone.

Infix "*" := abegop.
Notation "1" := Aone.

Notation "- x" :=  (Ainv x).

(** The next three Lemmas simply following proofs *)

Lemma comm_inv : forall a b c x :A,
  a * x * b * -x * c = a * b * c.
Proof. 
  intros. replace (a * x * b) with (a * (x * b)).  replace (x * b) with (b * x).
  rewrite dot_assoc. replace (a * b * x * - x * c) with (a * b * (x * -x * c)).
  rewrite <- inv_right. replace (1 * c) with c. trivial. rewrite one_left.
  trivial. rewrite dot_assoc. rewrite dot_assoc. trivial. apply comm. apply dot_assoc.
Qed.

Lemma comm_inv_wa : forall b c x :A,
  x * b * -x * c =  b * c.
Proof. 
  intros. replace (x * b * - x * c) with (1 * (x * b * - x * c)).
  replace (b * c) with (1 * (b * c)). rewrite dot_assoc. rewrite dot_assoc. rewrite dot_assoc.
  rewrite dot_assoc. apply comm_inv. apply one_left. apply one_left.
Qed.

Lemma comm_inv_wc : forall a b x :A,
  a * x * b * - x = a * b.
Proof. 
  intros. replace (a * x * b * - x ) with (a * x * b * - x * 1).
  replace (a * b) with (a * b * 1). apply comm_inv. apply one_right.
  apply one_right.
Qed.

Lemma left_cancel : forall x y z:A,
 (x * y = x * z) <-> (y = z).
Proof.
  intros. unfold iff. refine (conj _ _). 
  (*Case 1 *)
  intros. assert (- x * (x * y) = - x * (x * z)). rewrite H0. trivial.
  rewrite dot_assoc in H1. rewrite dot_assoc in H1. replace (- x * x) with 1 in H1.
  rewrite one_left in H1. rewrite one_left in H1. apply H1. apply inv_left.
  (*Case 2 *)
  intros.  rewrite H0. trivial.
Qed.
  
Lemma left_cancel_neq : forall x y z:A,
 (x * y <> x * z) <-> (y <> z).
Proof.
  intros. unfold iff. refine (conj _ _). 
  (*Case 1 *)
  intros. unfold not. intros. rewrite H1 in H0. apply H0. trivial. 
  (*Case 2 *)
  intros. unfold not in *. intros. rewrite left_cancel in H1.  rewrite H1 in H0. apply H0. trivial.
Qed.

Lemma right_cancel :  forall x y z:A,
 (y * x = z * x) <-> (y = z).
Proof.
  intros. unfold iff. refine (conj _ _). 
  (*Case 1 *)
  intros. assert (((y * x) * -x ) = ((z * x) * -x)). rewrite H0. trivial.
  replace (y * x * - x) with (y * (x * - x)) in H1. replace (z * x * - x) with (z * (x * - x)) in H1.
  replace (x * -x) with 1 in H1. rewrite one_right in H1.
  rewrite one_right in H1. apply H1. apply inv_right.
  apply dot_assoc. apply dot_assoc.
  (*Case 2 *)
  intros.  rewrite H0. trivial.
Qed.

Lemma comm_inv_wb : forall a c x :A,
  a * x * -x * c = a * c.
Proof. 
  intros. apply right_cancel. rewrite <- dot_assoc. rewrite <- inv_right.
  rewrite one_right. trivial.
Qed.

Lemma comm_inv_wac : forall b x :A,
  x * b *  -x  = b.
Proof. 
  intros. rewrite <- dot_assoc. replace (b * -x) with (-x * b) by apply comm.
  rewrite dot_assoc. rewrite <- one_right. symmetry. rewrite comm.
  apply right_cancel. apply inv_right.
Qed.


Lemma eqImplProd:
  forall a b c d : A,
  a = b /\ c = d -> a * c = b * d.
Proof.
  intros. destruct H0. rewrite H0. rewrite H1. trivial.
Qed.

Lemma dob_neg : forall a : A,
  a = - - a.
Proof.
  intros. apply right_cancel with (x:= -a).
  rewrite <- inv_left. symmetry. apply inv_right.
Qed.

Lemma minus_one : forall a : A,
  a = a * (Ainv 1).
Proof.
  intros. apply right_cancel with (x:=1).
  rewrite one_right. rewrite <- dot_assoc. rewrite <- inv_left.
  rewrite one_right. trivial.
Qed.

Lemma inv_dist : forall a b : A,
  -a * -b = -(a * b).
Proof.
  intros. assert (a * b * -a * -b = a * b * -(a*b)).
  rewrite comm_inv_wa. rewrite <- inv_right. rewrite <- inv_right. 
  trivial. apply left_cancel with (x := a * b).
  rewrite dot_assoc. apply H0.
Qed. 

Lemma inv_dist2 : forall a b : A,
  - a * b = - (a * - b).
Proof.
  intros. remember (-b) as c.
  rewrite <- inv_dist. rewrite Heqc.
  simpl. rewrite <- dob_neg. trivial.
Qed.

Lemma b_equal : forall a b c : A,
  (a = b * c) <-> (a * - c = b).
Proof.
  intros.
  intros. unfold iff. refine (conj _ _).   
  (* case 1 *)
  intros. rewrite H0. rewrite <- dot_assoc.
  rewrite <- inv_right. rewrite one_right. trivial.
  (* case 2 *)
  intros. symmetry in H0. rewrite H0. rewrite <- dot_assoc.
  rewrite <- inv_left. rewrite one_right. trivial.
Qed.


Lemma double_chall :  forall (c a : A),
  c * - (c * - a) = a.
Proof.
  intros. replace (- (c * - a)) with (-c * a).
  replace (c * (- c * a)) with (c * -c * a).
  rewrite <- inv_right. rewrite one_left. trivial.
  rewrite dot_assoc. trivial. apply inv_dist2.
Qed.

Lemma bool_true : forall (c : A),
   (bool_equal c c) = false  -> False.
Proof.
  intros. assert (c <> c).
  apply bool_neq_corr. apply H0. assert False.
  apply H1. trivial. congruence.
Qed.

Lemma chall_dist : forall (c1 c2 e1 e2 e3 e4 : A),
  bool_equal c1 c2 = false ->
  c1 = e1 * e2 ->
  c2 = e3 * e4 ->
   bool_equal e1 e3 = false \/
   bool_equal e2 e4 = false.
Proof.
  intros. case_eq (bool_equal e1 e3).
  (* Case 1 *)  intros. right. rewrite bool_neq_corr in *.
  apply bool_eq_corr in H3. rewrite H3 in H1. rewrite H2 in H0. rewrite H1 in H0.
  rewrite left_cancel_neq in H0. apply H0.
  (* Case 2 *)
  intros. left. trivial.
Qed.

Lemma zero2 : forall (a b : A),
  a <> b ->
  a * - b <> 1.
Proof.
  intros. unfold not. replace 1 with (b * - b).  
  intros. apply right_cancel in H1.
  rewrite H1 in H0. apply H0. trivial. rewrite <- inv_right.
  trivial.
Qed. 

Lemma inv_not_equal_zero : forall (a b :A),
  a <> 1 ->
  - a <> 1.
Proof.
  intros. unfold not in *. intros. 
  apply left_cancel with (x:= a) in H1.
  rewrite <- inv_right in H1. rewrite one_right in H1.
  symmetry in H1. apply H0 in H1. apply H1.
Qed.

Lemma field_additive_abegrp (F:Set)(Fadd : F -> F -> F) (Fzero : F) 
  (Fbool_eq : F-> F-> bool) (Fsub : F -> F -> F)(Finv : F -> F)
  (Fmul : F -> F -> F) (Fone : F)(FmulInv : F -> F)(Fdiv : F-> F-> F) :
  field_theory Fzero Fone Fadd Fmul Fsub Finv Fdiv FmulInv (@eq F) ->
  (forall a b : F, Fbool_eq a b = true <-> a=b) ->
  (forall a b : F, Fbool_eq a b = false <-> a <> b) ->
  AbeGroup F Fadd Fzero Fbool_eq Finv.
Proof.
  intros. constructor. constructor. constructor. 
  intros; rewrite (Radd_assoc (rO := Fzero)); trivial; apply H0.
  intros; rewrite (Radd_0_l); trivial; apply H0.
  intros. rewrite (Radd_comm). rewrite (Radd_0_l). trivial. apply H0. apply H0.
  apply H1. apply H2. intros. rewrite (Radd_comm). rewrite (Ropp_def). trivial.
  apply H0. apply H0.
  intros. rewrite (Ropp_def). trivial. apply H0. intros. rewrite (Radd_comm). trivial. apply H0.
Qed. 

End AdditionalGroupProperties.

(** We now define vector space *)


Class VectorSpace (F:Set)(Fadd : F -> F -> F) (Fzero : F) (Fbool_eq : F-> F-> bool) 
  (Fsub : F -> F -> F)(Finv : F -> F)(Fmul : F -> F -> F) (Fone : F)(FmulInv : F -> F)(Fdiv : F-> F-> F) (G:Set)
  (Gdot : G -> G -> G) (Gone : G) (Gbool_eq : G-> G-> bool) (Ginv : G -> G) (op : G -> F -> G) := {
  vs_field :> field_theory Fzero Fone Fadd Fmul Fsub Finv Fdiv FmulInv (@eq F);
  module_abegrp :> AbeGroup G Gdot Gone Gbool_eq Ginv;

  mod_dist_Gdot : forall (r : F) (x y : G), op (Gdot x y) r = Gdot (op x r) (op y r);
  mod_dist_Fadd : forall (r s : F) (x : G), op x (Fadd r s) = Gdot (op x r) (op x s);
  mod_dist_Fmul : forall (r s: F) (x : G), op x (Fmul r s) = op (op x s) r;
  mod_id : forall (x : G), op x Fone = x;
  mod_ann : forall (x : G), op x Fzero = Gone;

  F_bool_eq_corr: forall a b : F, Fbool_eq a b = true <-> a=b;
  F_bool_neq_corr: forall a b : F, Fbool_eq a b = false <-> a <> b;
}.

Section AddationalGroupLemmas.

Generalizable Variables F Fadd Fzero Fbool_eq Fsub Finv Fmul Fone FmulInv Fdiv G Gdot 
  Gone Gbool_eq Ginv op.

Context `{VectorSpace F Fadd Fzero Fbool_eq Fsub Finv Fmul Fone FmulInv Fdiv G Gdot 
  Gone Gbool_eq Ginv op}.

Infix "+" := Fadd.
Infix "*" := Fmul.
Notation "x / y" := (Fmul x (FmulInv y)). 
Notation "0" := Fzero.
Notation "1" := Fone.
Notation "- x" :=  (Finv x).
Notation "x - y" := (x + (- y)).

Infix "o" := Gdot (at level 50) .
Notation "- x" := (Ginv x).

Infix "^" := op.

Add Field vs_field : vs_field.

(** We will first prove some sublemmas *)

(* Lemma field_mul_comm. *)
  
Lemma shift :
  forall (a b : F),
   a = b <-> a - b = 0.
Proof.
  intros. unfold iff. refine (conj _ _). intros.
  rewrite H0. field; auto. intros. replace b with (b + 0).
  rewrite <- H0. field; auto. field; auto.
Qed.

Lemma inverse :
  forall (a b : F),
  a - b = 0 <-> b - a = 0.
Proof.
  intros. intros. unfold iff. refine (conj _ _).   
  intros. apply shift in H0. rewrite H0. field; auto.
  intros. apply shift in H0. rewrite H0. field; auto. 
Qed.

Lemma mod_dist_FMul2 :
 forall (r s: F) (x : G), op x (Fmul s r) = op (op x s) r.
Proof.
  intros. destruct H. rewrite Rmul_comm. rewrite mod_dist_Fmul. trivial. apply vs_field0.
Qed.

Lemma neg_eq :
forall (a : F)(b : G), -(b^a) = (b^(Finv a)).
Proof. 
  intros. apply right_cancel with (x:= b ^ a). destruct H. 
  replace (abegop (- b ^ a) (b ^ a)) with Gone. rewrite <- mod_dist_Fadd. 
  replace (Finv a + a) with Fzero.
  rewrite mod_ann. trivial. field; auto. apply inv_left.
Qed.

Lemma op_cancel : forall (x : F)(y z : G),
 x <> 0 -> y ^ x = z ^ x -> y = z.
Proof.
  intros. assert ((y ^ x) ^ FmulInv x  = (z ^ x) ^ FmulInv x).
  rewrite H1. trivial. do 2 rewrite <- mod_dist_Fmul in H2. replace (FmulInv x * x) with (Fone) in H2.
  do 2 rewrite mod_id in H2. apply H2. field; auto.
Qed.

Lemma mod_mone : forall (x : F),
  Gone ^ x = Gone.
Proof.
  intros. replace (Gone) with (Gone ^ 0). rewrite <- mod_dist_Fmul.
  replace (x * 0) with 0. trivial. field; auto. apply mod_ann.
Qed.

End AddationalGroupLemmas.


