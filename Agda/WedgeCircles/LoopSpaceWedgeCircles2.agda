{-# OPTIONS --without-K #-}

open import Base

module WedgeCircles.LoopSpaceWedgeCircles2 {i} (A : Set i) (eq : dec-eq A) where

import WedgeCircles.WedgeCircles
import FreeGroup.FreeGroup
import FreeGroup.FreeGroupProps
import FreeGroup.FreeGroupAsReducedWords
import WedgeCircles.LoopSpaceWedgeCircles

open WedgeCircles.LoopSpaceWedgeCircles A eq
open WedgeCircles.WedgeCircles A renaming (wedge-circles to WA)
open FreeGroup.FreeGroup A renaming (freegroup to FA)
open FreeGroup.FreeGroupProps A
open FreeGroup.FreeGroupAsReducedWords A eq

-- We can now prove that [tot-cover] is contractible using [CA-rec]
-- (because [CA-rec] means that [tot-cover] is the Cayley graph of FA)
P-CA-contr : (x : tot-cover) → Set _
P-CA-contr x = x ≡ CA-z e

-- We first prove it on points coming from reduced words
CA-contr-base-reduced-word : (w : reduced-word)
  → P-CA-contr (CA-z (reduced-to-freegroup w))
CA-contr-base-reduced-word (ε , red) = refl _
CA-contr-base-reduced-word ((x ∷ w) , red) =
  ! (CA-e x _)
  ∘ CA-contr-base-reduced-word (w , tail-is-reduced x w red)
CA-contr-base-reduced-word ((x ′∷ w) , red) =
  (CA-e x _ ∘ map CA-z (right-inverse-· x _))
  ∘ CA-contr-base-reduced-word (w , tail'-is-reduced x w red)

-- Then on every point
CA-contr-base : (u : FA) → P-CA-contr (CA-z u)
CA-contr-base u =
  map CA-z (! (inv₂ u)) ∘ (CA-contr-base-reduced-word (freegroup-to-reduced u))

-- Now we prove that it’s true on paths, coming from reduced words
abstract
  CA-contr-loop-reduced-word : (t : A) (w : reduced-word) →
    (map CA-z (reduced-to-freegroup-mul-reduce t w)
    ∘ ! (CA-e t (reduced-to-freegroup w)))
    ∘ (CA-contr-base-reduced-word w)
    ≡ CA-contr-base-reduced-word (mul-reduce t w)
  CA-contr-loop-reduced-word t (ε , red) = refl _
  CA-contr-loop-reduced-word t ((x ∷ w) , red) = refl _
  CA-contr-loop-reduced-word t ((x ′∷ w) , red) with (eq t x)
  CA-contr-loop-reduced-word x ((.x ′∷ w) , red) | inl (refl .x) =
    -- With the notations below, what we have to prove
    -- is [ (map CA-z (! p) ∘ ! q) ∘ ((q ∘ map CA-z p) ∘ r) ≡ r ]
    concat-assoc (map CA-z (! p)) _ _
    ∘ (map (λ t₁ → t₁ ∘ (! q ∘ ((q ∘ map CA-z p) ∘ r))) (map-opposite CA-z p)
    ∘ move!-right-on-left (map CA-z p) (! q ∘ ((q ∘ map CA-z p) ∘ r)) r
      (move!-right-on-left q ((q ∘ map CA-z p) ∘ r) (map CA-z p ∘ r)
      (concat-assoc q _ _))) where
    fw : FA
    fw = reduced-to-freegroup (w , tail'-is-reduced x w red)
  
    p : x · (x ⁻¹· fw) ≡ fw
    p = right-inverse-· x fw
  
    q : CA-z (x ⁻¹· fw) ≡ CA-z (x · (x ⁻¹· fw))
    q = CA-e x (x ⁻¹· fw)
  
    r : CA-z fw ≡ CA-z e
    r = CA-contr-base-reduced-word (w , tail'-is-reduced x w red)
  CA-contr-loop-reduced-word t ((x ′∷ w) , red) | inr different = refl _

-- And finally for every path
CA-contr-loop : (t : A) (u : FA)
  → transport P-CA-contr (CA-e t u) (CA-contr-base u) ≡ (CA-contr-base (t · u))
CA-contr-loop t u =
  -- Idea:
  --
  -- We need to prove
  --   [p u ∘ (map CA-z (q u) ∘ for-red u)
  --    ≡ map CA-z (q (t · u)) ∘ for-red (t · u)]
  --
  -- [CA-contr-loop-reduced-word] gives
  -- that [(map CA-z comp ∘ p (k u)) ∘ for-red u ≡ for-red (t · u)]

  trans-x≡a (CA-e t u) (CA-contr-base u)
  ∘ (! (concat-assoc (p u) (map CA-z (q u)) (for-red u))
  ∘ (whisker-right (for-red u) {q = p u ∘ map CA-z (q u)}
       {r = map CA-z (q (t · u)) ∘ (map CA-z comp ∘ p (k u))}
    (! (homotopy-naturality f g p (q u))
    ∘ (whisker-right (p (k u)) {q = map f (q u)}
         {r = map CA-z (q (t · u)) ∘ map CA-z comp}
      (map-compose CA-z (λ u₁ → t · u₁) (q u)
      ∘ (map (map CA-z) (π₁ (freegroup-is-set _ _ _ _))
      ∘ map-concat CA-z (q (t · u)) comp))
    ∘ concat-assoc (map CA-z (q (t · u))) (map CA-z comp) (p (k u))))
  ∘ (concat-assoc (map CA-z (q (t · u))) (map CA-z comp ∘ p (k u))
       (for-red u)
       ∘ whisker-left (map CA-z (q (t · u)))
           auie))) where
  f : FA → tot-cover
  f u = CA-z (t · u)

  g : FA → tot-cover
  g u = CA-z u

  p : (u : FA) → f u ≡ g u
  p u = ! (CA-e t u)

  k : FA → FA
  k u = reduced-to-freegroup (freegroup-to-reduced u)

  q : (u : FA) → u ≡ k u
  q u = ! (inv₂ u)

  for-red : (u : FA) → CA-z (k u) ≡ CA-z e
  for-red u = CA-contr-base-reduced-word (freegroup-to-reduced u)

  comp : k (t · u) ≡ t · (k u)
  comp = reduced-to-freegroup-mul-reduce t (freegroup-to-reduced u)

  auie : (map CA-z comp ∘ p (k u)) ∘ for-red u ≡ for-red (t · u)
  auie = CA-contr-loop-reduced-word t (freegroup-to-reduced u)

-- Hence, [CA] is contractible
CA-contr : (x : tot-cover) → P-CA-contr x
CA-contr = equivCA.CA-rec P-CA-contr CA-contr-base CA-contr-loop

abstract
  tot-cover-is-contr : is-contr tot-cover
  tot-cover-is-contr = (CA-z e , λ x → CA-contr x)

-- We define now a fiberwise map between the two fibrations [path-fib]
-- and [universal-cover]
fiberwise-map : (x : WA) → (path-fib x → universal-cover x)
fiberwise-map x q = transport universal-cover (! q) e

-- This induces an equivalence on the total spaces, because both total spaces
-- are contractible
total-equiv : is-equiv (total-map fiberwise-map)
total-equiv = contr-to-contr-is-equiv (total-map fiberwise-map)
                                      tot-path-fib-is-contr
                                      tot-cover-is-contr

-- Hence an equivalence fiberwise
fiberwise-map-is-equiv : (x : WA) → is-equiv (fiberwise-map x)
fiberwise-map-is-equiv x = fiberwise-is-equiv fiberwise-map total-equiv x

-- We can then conclude that the based loop space of the wedge of circles is
-- equivalent to the free group
π₁WA≃FA : (base ≡ base) ≃ FA
π₁WA≃FA = (fiberwise-map base , fiberwise-map-is-equiv base)

