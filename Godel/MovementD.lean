/-
  MOVEMENT D — THE VALIDITY PREDICATE IS A STATE VARIABLE

  C's proof held `V` fixed. But in the world, `V` is applied by
  institutions that live INSIDE the system: courts, commissions,
  constituent assemblies. Capture the recognizer, and the eternity
  clause remains in the text — as ink.

  The capture move is not an Article-V amendment at all; that is the
  point. It is modelled as always-available precisely because no clause
  of the object text governs it. (Hungary 2010–13, Venezuela 2017,
  Honduras 2009: "a new constitution is not an amendment to the old.")
-/
import Godel.Core

namespace Godel

def VD (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨
  a = .setInterp true ∨ a = .setInterp false ∨
  (n ≥ s.rule.cost ∧
    (s.eternity = true ∧ s.strictInterp = true →
      coreAttack a = false ∧ selfAttack a = false))

/-- While the recognizer is faithful, D behaves exactly like C: the
    frontal assault fails even at strength 100. -/
theorem D_blocks_while_strict : ¬ VD 100 init (.setDictatorship true) := by
  intro h
  rcases h with h | h | h | ⟨_, hg⟩
  · exact absurd h (by decide)
  · exact absurd h (by decide)
  · exact absurd h (by decide)
  · exact absurd (hg ⟨rfl, rfl⟩).1 (by decide)

/-- Capture the interpreter (cost: outside the model, because outside
    the text), then adopt what the clause "no longer applies" to. -/
def afterCapture : State :=
  { init with strictInterp := false, dictatorship := true }

theorem interpretation_attack : Reach VD [0, 67] init afterCapture := by
  exact .step (.setInterp false) (Or.inr (Or.inr (Or.inl rfl)))
        (.step (.setDictatorship true) (Or.inr (Or.inr (Or.inr (by decide)))) .nil)

/-- The epitaph. The eternity clause is still in the document at the end
    of the attack — verbatim, uninfringed, and load-bearing for nothing. -/
theorem clause_still_there : afterCapture.eternity = true := rfl

end Godel
