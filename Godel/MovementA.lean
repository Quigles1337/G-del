/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  MOVEMENT A — THE LOOPHOLE

  Validity: anything a sufficiently strong coalition adopts is valid.
  The amendment rule constrains HOW, never WHAT. In particular it does
  not entrench itself.

  Result: dictatorship is reachable, and the interesting path is not the
  direct one. The loophole path reprices every *future* amendment,
  including the repeal of what it installs.
-/
import Godel.Core

namespace Godel

def VA (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨ n ≥ s.rule.cost

/-- Sanity check on the wall the Framers did build: a bare majority,
    given any number of sessions, can change NOTHING. The supermajority
    gate holds against 51 forever. -/
theorem majority_blocked :
    ∀ (ns : List Nat) (s s' : State),
      s.rule = .supermajority →
      (∀ n ∈ ns, n ≤ 66) →
      Reach VA ns s s' → s' = s := by
  intro ns s s' hrule hle hr
  induction hr with
  | nil => rfl
  | @step n ns s t a hv h ih =>
    rcases hv with hskip | hcost
    · subst hskip
      exact ih hrule (fun m hm => hle m (List.Mem.tail _ hm))
    · -- 67 ≤ n together with n ≤ 66 is absurd. `simp`/`omega` close this
      -- too, but drag in `propext` and `Quot.sound`; see docs/adr/0003.
      exact absurd (Nat.le_trans (hrule ▸ hcost) (hle n (List.Mem.head ns)))
        (by decide)

/-- The direct route, for honesty: a supermajority CAN simply vote in
    dictatorship in one step. The loophole, as reconstructed here, is
    not that this path exists — it is what the OTHER path does to the
    system afterwards. -/
def afterDirect : State := { init with dictatorship := true }

theorem direct : Reach VA [67] init afterDirect := by
  exact .step (.setDictatorship true) (Or.inr (by decide)) .nil

/-- THE LOOPHOLE. One supermajority session that touches nothing but
    the amendment rule itself — a procedural amendment, no rights
    harmed, nothing substantive on its face — and thereafter a bare
    majority finishes the job. Two steps, each formally valid under the
    rules in force at the moment it was taken. -/
def afterLoophole : State :=
  { init with rule := .simpleMajority, dictatorship := true }

theorem loophole : Reach VA [67, 51] init afterLoophole := by
  exact .step (.setRule .simpleMajority) (Or.inr (by decide))
        (.step (.setDictatorship true) (Or.inr (by decide)) .nil)

/-- The decree variant: amend the amendment rule once, and the
    legislature is never needed again. (Weimar Art. 48 / Enabling Act
    shape, by analogy only: that vote was coerced, and the toy has no
    coercion. Caveat on the toy's granularity: scalar strength can't say
    WHO holds the pen, so in this model cost-0 also means anyone could
    amend back. Real decree rules are asymmetric — the pen does not
    return.) -/
def afterDecree : State := { init with rule := .decree, dictatorship := true }

theorem loophole_decree : Reach VA [67, 0] init afterDecree := by
  exact .step (.setRule .decree) (Or.inr (by decide))
        (.step (.setDictatorship true) (Or.inr (by decide)) .nil)

/-- Why the loophole path is the sinister one, in one line each:
    the direct path leaves tyranny repealable at cost 67; the loophole
    path re-prices every future amendment — including the repeal of
    tyranny — at 51 (or 0). The attack is on the immune system, not
    the organ. -/
theorem direct_leaves_gate    : afterDirect.rule.cost   = 67 := rfl
theorem loophole_lowers_gate  : afterLoophole.rule.cost = 51 := rfl
theorem decree_removes_gate   : afterDecree.rule.cost   = 0  := rfl

end Godel
