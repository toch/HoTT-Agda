{-# OPTIONS --without-K #-}

open import lib.Basics
open import lib.types.Paths
open import lib.types.Pi
open import lib.types.Unit

module lib.types.Circle where

{-
Idea :

data S¹ : Type₀ where
  base : S¹
  loop : base == base

I’m using Dan Licata’s trick to have a higher inductive type with definitional
reduction rule for [base]
-}

private
  data #S¹ : Type₀ where
    #base : #S¹

S¹ : Type₀
S¹ = #S¹

base : S¹
base = #base

postulate  -- HIT
  loop : base == base

S¹-elim : ∀ {i} {A : S¹ → Type i} (base* : A base)
  (loop* : base* == base* [ A ↓ loop ])
  → Π S¹ A
S¹-elim base* loop* #base = base*

postulate  -- HIT
  loop-β : ∀ {i} {A : S¹ → Type i} (base* : A base)
    (loop* : base* == base* [ A ↓ loop ])
    → apd (S¹-elim base* loop*) loop == loop*

S¹-rec : ∀ {i} {A : Type i} (base* : A) (loop* : base* == base*) → (S¹ → A)
S¹-rec base* loop* #base = base*

postulate  -- HIT
  loop-β' : ∀ {i} {A : Type i} (base* : A) (loop* : base* == base*)
    → ap (S¹-rec base* loop*) loop == loop*


module _ {i} {A : Type i} (f : A ≃ A) where

  private
    P = S¹-rec A (ua f)

  coe-loop-β' : (a : A) → coe (ap P loop) a == –> f a
  coe-loop-β' a =
    coe (ap P loop) a =⟨ loop-β' A (ua f) |in-ctx (λ u → coe u a) ⟩
    coe (ua f) a      =⟨ coe-β f a ⟩
    –> f a ∎

  coe!-loop-β' : (a : A) → coe! (ap P loop) a == <– f a
  coe!-loop-β' a =
    coe! (ap P loop) a =⟨ loop-β' A (ua f) |in-ctx (λ u → coe! u a) ⟩
    coe! (ua f) a =⟨ coe!-β f a ⟩
    <– f a ∎

  ↓-loop-out : {a a' : A} → a == a' [ P ↓ loop ] → –> f a == a'
  ↓-loop-out {a} {a'} p =
    –> f a =⟨ ! (coe-loop-β' a) ⟩
    coe (ap P loop) a =⟨ to-transp p ⟩
    a' ∎

{- Flattening -}
module FlatteningS¹ {i} (A : Type i) (f : A ≃ A) where

  private
    P = S¹-rec A (ua f)

  open import lib.types.Flattening
    Unit Unit (idf _) (idf _) (cst A) (cst f) public

  flattening-S¹ : Σ S¹ P == Wt
  flattening-S¹ = eqv-tot f ∙ ua flattening-equiv  where

    to : S¹ → W
    to = S¹-rec (cc tt) (pp tt)

    from : W → S¹
    from = W-rec (cst base) (cst loop)

    abstract
      to-from : (x : W) → to (from x) == x
      to-from = W-elim (λ _ → idp) (λ _ → ↓-∘=id-in from to
        (ap to (ap from (pp tt)) =⟨ pp-β' (cst base) (cst loop) tt |in-ctx ap to ⟩
        ap to loop =⟨ loop-β' (cc tt) (pp tt) ⟩
        pp tt ∎))

      from-to : (x : S¹) → from (to x) == x
      from-to = S¹-elim idp (↓-∘=id-in to from
        (ap from (ap to loop) =⟨ loop-β' (cc tt) (pp tt) |in-ctx ap from ⟩
        ap from (pp tt) =⟨ pp-β' (cst base) (cst loop) tt ⟩
        loop ∎))

    eqv : S¹ ≃ W
    eqv = equiv to from to-from from-to

    eqv-fib : ∀ {i} {A : Type i} (e : A ≃ A) →
      S¹-rec A (ua e) == W-rec (cst A) (cst (ua e)) [ (λ X → (X → Type _)) ↓ ua eqv ]
    eqv-fib e = ↓-app→cst-in (λ {t} p → S¹-elim {A = λ t → S¹-rec _ (ua e) t == W-rec (cst _) (cst (ua e)) (–> eqv t)} idp (↓-='-in
      (ap (W-rec (cst _) (cst (ua e)) ∘ (–> eqv)) loop =⟨ ap-∘ (W-rec (cst _) (cst (ua e))) (–> eqv) loop ⟩
      ap (W-rec (cst _) (cst (ua e))) (ap (–> eqv) loop) =⟨ loop-β' (cc tt) (pp tt) |in-ctx ap (W-rec (cst _) (cst (ua e))) ⟩
      ap (W-rec (cst _) (cst (ua e))) (pp tt) =⟨ pp-β' (cst _) (cst (ua e)) tt ⟩
      ua e =⟨ ! (loop-β' _ (ua e)) ⟩
      ap (S¹-rec _ (ua e)) loop ∎))
      t ∙ (ap (W-rec (cst _) (cst (ua e))) (↓-idf-ua-out eqv p)))

    eqv-tot : ∀ {i} {A : Type i} (e : A ≃ A)
      → Σ S¹ (S¹-rec A (ua e)) == Σ W (W-rec (cst A) (cst (ua e)))
    eqv-tot e = ap (uncurry Σ) (pair= (ua eqv) (eqv-fib e))


{- -}

-- S¹-rec-nondep : ∀ {i} (A : Type i) (x : A) (p : x ≡ x) → (S¹ → A)
-- S¹-rec-nondep A x p = S¹-rec (λ _ → A) x (trans-cst loop x ∘ p)

-- β-nondep : ∀ {i} (A : Type i) (x : A) (p : x ≡ x)
--   → ap (S¹-rec-nondep A x p) loop ≡ p
-- β-nondep A x p =
--   apd-trivial (S¹-rec-nondep A x p) loop ∘
--   (whisker-left (! (trans-cst loop _)) (β (λ _ → A) x (trans-cst loop _ ∘ p))
--   ∘ (! (concat-assoc (! (trans-cst loop _)) (trans-cst loop _) p)
--   ∘ whisker-right p (opposite-left-inverse (trans-cst loop _))))