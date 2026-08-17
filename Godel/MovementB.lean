/-
  MOVEMENT B — ENTRENCHMENT WITHOUT SELF-ENTRENCHMENT

  Add a clause: "no amendment may install dictatorship or abolish free
  elections." The clause binds even supermajorities. But the clause is
  itself an ordinary provision.

  Result: it stops the frontal assault and is a two-step no-op.
-/
import Godel.Core

namespace Godel

def VB (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨
  (n ≥ s.rule.cost ∧ (s.eternity = true → coreAttack a = false))

/-- The clause does its job against the frontal assault: not even a
    unanimous legislature can adopt the forbidden amendment directly. -/
theorem B_blocks_direct : ¬ VB 100 init (.setDictatorship true) := by
  intro h
  rcases h with h | ⟨_, hg⟩
  · exact absurd h (by decide)
  · exact absurd (hg rfl) (by decide)

/-- ...and is bypassed in two moves: first repeal the guard (nothing
    protects it), then walk through the open door. Both steps valid. -/
def afterBypass : State :=
  { init with eternity := false, dictatorship := true }

theorem entrenchment_bypassed : Reach VB [67, 67] init afterBypass := by
  exact .step (.setEternity false) (Or.inr (by decide))
        (.step (.setDictatorship true) (Or.inr (by decide)) .nil)

end Godel
