/-
  Godel.Executable — the exploit as a running program.

  Movements A–D prove reachability with hand-built derivations. This
  module does the same work mechanically: each validity regime is shown
  DECIDABLE, a checker `runTrace` walks a trace refusing the first
  illegal step, and `runTrace_sound` proves the checker is faithful —
  if it accepts, a `Reach` derivation exists.

  Consequence: `lake exe godel` does not narrate the attack, it EXECUTES
  it, and the acceptance is a certificate the kernel has already checked.
-/
import Godel.Core
import Godel.MovementA
import Godel.MovementB
import Godel.MovementC
import Godel.MovementD

namespace Godel

/-! ### Every validity regime in this file is decidable. -/

instance instDecVA (n : Nat) (s : State) (a : Amend) : Decidable (VA n s a) :=
  inferInstanceAs (Decidable (a = .skip ∨ n ≥ s.rule.cost))

instance instDecVB (n : Nat) (s : State) (a : Amend) : Decidable (VB n s a) :=
  inferInstanceAs (Decidable
    (a = .skip ∨ (n ≥ s.rule.cost ∧ (s.eternity = true → coreAttack a = false))))

instance instDecVC (n : Nat) (s : State) (a : Amend) : Decidable (VC n s a) :=
  inferInstanceAs (Decidable
    (a = .skip ∨ (n ≥ s.rule.cost ∧
      (s.eternity = true → coreAttack a = false ∧ selfAttack a = false))))

instance instDecVD (n : Nat) (s : State) (a : Amend) : Decidable (VD n s a) :=
  inferInstanceAs (Decidable
    (a = .skip ∨ a = .setInterp true ∨ a = .setInterp false ∨
      (n ≥ s.rule.cost ∧
        (s.eternity = true ∧ s.strictInterp = true →
          coreAttack a = false ∧ selfAttack a = false))))

/-! ### The checker. -/

/-- A legislative session: the strength of the coalition, and what it
    moves. -/
abbrev Session := Nat × Amend

/-- Walk a trace under regime `V`, refusing the first step that is not
    legally adoptable in the state reached so far. -/
def runTrace (V : Nat → State → Amend → Prop) [∀ n s a, Decidable (V n s a)] :
    State → List Session → Option State
  | s, []           => some s
  | s, (n, a) :: tl => if V n s a then runTrace V (a.apply s) tl else none

/-- SOUNDNESS. If the checker accepts a trace, a legal derivation exists.
    This is the bridge from the program to the proof: the acceptance is
    a certificate, not a claim about a certificate. -/
theorem runTrace_sound {V : Nat → State → Amend → Prop}
    [∀ n s a, Decidable (V n s a)] :
    ∀ (tr : List Session) (s t : State),
      runTrace V s tr = some t → Reach V (tr.map Prod.fst) s t := by
  intro tr
  induction tr with
  | nil =>
      intro s t h
      -- `Option.some.inj` is noConfusion-based; `simp [Option.some.injEq]`
      -- would work too but drags in `propext`. See docs/LIMITATIONS.md.
      cases Option.some.inj h
      exact .nil
  | cons na tl ih =>
      intro s t h
      obtain ⟨n, a⟩ := na
      simp only [runTrace] at h
      split at h
      · next hv => exact .step a hv (ih _ _ h)
      -- `nomatch` rather than `Option.noConfusion h`: the latter cannot
      -- infer its motive on Lean 4.33+ when the goal is a `Prop`, and
      -- portability across toolchains is a requirement (ADR-0002).
      · next => nomatch h

/-! ### The three headline traces, run rather than argued. -/

/-- Movement A, executed: the loophole trace is accepted. -/
theorem loophole_runs :
    runTrace VA init [(67, .setRule .simpleMajority), (51, .setDictatorship true)]
      = some afterLoophole := by decide

/-- Movement B, executed: repeal the guard, then walk through. -/
theorem bypass_runs :
    runTrace VB init [(67, .setEternity false), (67, .setDictatorship true)]
      = some afterBypass := by decide

/-- Movement C, executed: the checker REFUSES the frontal assault, and
    refuses the reflexive one too. Unanimity buys nothing. -/
theorem C_refuses_direct :
    runTrace VC init [(100, .setDictatorship true)] = none := by decide

theorem C_refuses_selfrepeal :
    runTrace VC init [(100, .setEternity false)] = none := by decide

/-- Movement D, executed: capture the recognizer first, and the very
    same assault the checker just refused is now accepted. -/
theorem capture_runs :
    runTrace VD init [(0, .setInterp false), (67, .setDictatorship true)]
      = some afterCapture := by decide

theorem D_refuses_direct_while_strict :
    runTrace VD init [(100, .setDictatorship true)] = none := by decide

/-! ### Certificates: the program's output, promoted to a derivation. -/

theorem loophole_certified : Reach VA [67, 51] init afterLoophole :=
  runTrace_sound _ _ _ loophole_runs

theorem bypass_certified : Reach VB [67, 67] init afterBypass :=
  runTrace_sound _ _ _ bypass_runs

theorem capture_certified : Reach VD [0, 67] init afterCapture :=
  runTrace_sound _ _ _ capture_runs

end Godel
