/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  MOVEMENT C — THE SELF-ENTRENCHED ETERNITY CLAUSE

  Grundgesetz Art. 79(3), 1949 — written after Weimar, for Weimar's
  reasons: the clause protects the provisions AND, as German doctrine
  reads it, itself (docs/SOURCES.md §5).

  Result: formally this WORKS. Honesty demands we prove the defence
  succeeds before showing what it does not reach.
-/
import Godel.Core

namespace Godel

def VC (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨
  (n ≥ s.rule.cost ∧
    (s.eternity = true → coreAttack a = false ∧ selfAttack a = false))

/-- The safety invariant: the clause stands, and what it guards stands. -/
def Inv (s : State) : Prop :=
  s.eternity = true ∧ s.dictatorship = false ∧ s.freeElections = true

theorem VC_preserves {n : Nat} {s : State} {a : Amend}
    (hv : VC n s a) (hi : Inv s) : Inv (a.apply s) := by
  obtain ⟨he, hd, hf⟩ := hi
  rcases hv with hskip | ⟨_, hguard⟩
  · subst hskip; exact ⟨he, hd, hf⟩
  · have hg := hguard he
    cases a with
    | skip              => exact ⟨he, hd, hf⟩
    | setRule r         => exact ⟨he, hd, hf⟩
    | setInterp b       => exact ⟨he, hd, hf⟩
    | setEternity b     =>
        cases b with
        | true  => exact ⟨rfl, hd, hf⟩
        | false => exact Bool.noConfusion hg.2
    | setElections b    =>
        cases b with
        | true  => exact ⟨he, hd, rfl⟩
        | false => exact Bool.noConfusion hg.1
    | setDictatorship b =>
        cases b with
        | true  => exact Bool.noConfusion hg.1
        | false => exact ⟨he, rfl, hf⟩

/-- No trace of any strengths — unanimity included, forever — reaches
    dictatorship under VC. Within the frozen system, Art. 79(3) holds. -/
theorem eternity_holds :
    ∀ (ns : List Nat) (s' : State),
      Reach VC ns init s' → s'.dictatorship = false := by
  have main : ∀ (ns : List Nat) (s s' : State),
      Reach VC ns s s' → Inv s → Inv s' := by
    intro ns s s' hr
    induction hr with
    | nil => exact id
    | step a hv h ih => exact fun hi => ih (VC_preserves hv hi)
  intro ns s' hr
  exact (main ns init s' hr ⟨rfl, rfl, rfl⟩).2.1

end Godel
