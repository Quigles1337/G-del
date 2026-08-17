/-
  Godel.Receipts — the axiom ledger, enforced.

  `#print axioms` on its own only PRINTS a claim. Wrapped in
  `#guard_msgs`, each line below becomes a test: if any proof ever
  starts leaning on an axiom it did not lean on before — `sorryAx`
  included — this module fails to compile and CI goes red. The
  development cannot silently drift into a weaker result.

  THE LEDGER IS UNIFORM: every theorem in this development, attack and
  defence alike, depends on ZERO axioms. No `propext`, no `Quot.sound`,
  no `Classical.choice`, and — the one that matters for trust — no
  `sorryAx`. The results are closed terms the kernel accepts outright.

  A NEGATIVE RESULT, recorded because it is tempting and false.

  An earlier draft of this development observed a pleasing asymmetry:
  the attacks came out axiom-free while the defences needed `propext`
  (and `majority_blocked` also `Quot.sound`), suggesting that breaking a
  constitution is somehow cheaper than defending one — existential
  witness versus universal invariant.

  It does not survive. The asymmetry was an artifact of TACTIC CHOICE,
  not of logic. `simp` and `omega` are classical by construction;
  replacing three of their uses with `Bool.noConfusion` and
  `Nat.le_trans` — no change to a single theorem STATEMENT — moves all
  three defences to zero axioms. The full diff is in
  docs/adr/0003-axiom-asymmetry-refuted.md so the experiment can be
  re-run by reverting three lines.

  The honest reading is the duller one: this development is small enough
  and decidable enough that everything in it is constructive. Nothing
  about the constitutional argument follows from the axiom counts.
-/
import Godel.Core
import Godel.MovementA
import Godel.MovementB
import Godel.MovementC
import Godel.MovementD
import Godel.Executable
import Godel.MovementE
import Godel.MovementF

namespace Godel

/-! ### ATTACKS — hand-built derivations. -/

/-- info: 'Godel.direct' does not depend on any axioms -/
#guard_msgs in
#print axioms direct

/-- info: 'Godel.loophole' does not depend on any axioms -/
#guard_msgs in
#print axioms loophole

/-- info: 'Godel.loophole_decree' does not depend on any axioms -/
#guard_msgs in
#print axioms loophole_decree

/-- info: 'Godel.entrenchment_bypassed' does not depend on any axioms -/
#guard_msgs in
#print axioms entrenchment_bypassed

/-- info: 'Godel.interpretation_attack' does not depend on any axioms -/
#guard_msgs in
#print axioms interpretation_attack

/-! ### THE REPRICING, and the epitaph. Pure computation (`rfl`). -/

/-- info: 'Godel.direct_leaves_gate' does not depend on any axioms -/
#guard_msgs in
#print axioms direct_leaves_gate

/-- info: 'Godel.loophole_lowers_gate' does not depend on any axioms -/
#guard_msgs in
#print axioms loophole_lowers_gate

/-- info: 'Godel.decree_removes_gate' does not depend on any axioms -/
#guard_msgs in
#print axioms decree_removes_gate

/-- info: 'Godel.clause_still_there' does not depend on any axioms -/
#guard_msgs in
#print axioms clause_still_there

/-! ### POINT REFUTATIONS — the defences doing their job against one assault. -/

/-- info: 'Godel.B_blocks_direct' does not depend on any axioms -/
#guard_msgs in
#print axioms B_blocks_direct

/-- info: 'Godel.D_blocks_while_strict' does not depend on any axioms -/
#guard_msgs in
#print axioms D_blocks_while_strict

/-! ### THE CERTIFIED CHECKER — soundness, every executed trace, every certificate. -/

/-- info: 'Godel.runTrace_sound' does not depend on any axioms -/
#guard_msgs in
#print axioms runTrace_sound

/-- info: 'Godel.loophole_runs' does not depend on any axioms -/
#guard_msgs in
#print axioms loophole_runs

/-- info: 'Godel.bypass_runs' does not depend on any axioms -/
#guard_msgs in
#print axioms bypass_runs

/-- info: 'Godel.C_refuses_direct' does not depend on any axioms -/
#guard_msgs in
#print axioms C_refuses_direct

/-- info: 'Godel.C_refuses_selfrepeal' does not depend on any axioms -/
#guard_msgs in
#print axioms C_refuses_selfrepeal

/-- info: 'Godel.capture_runs' does not depend on any axioms -/
#guard_msgs in
#print axioms capture_runs

/-- info: 'Godel.D_refuses_direct_while_strict' does not depend on any axioms -/
#guard_msgs in
#print axioms D_refuses_direct_while_strict

/-- info: 'Godel.loophole_certified' does not depend on any axioms -/
#guard_msgs in
#print axioms loophole_certified

/-- info: 'Godel.bypass_certified' does not depend on any axioms -/
#guard_msgs in
#print axioms bypass_certified

/-- info: 'Godel.capture_certified' does not depend on any axioms -/
#guard_msgs in
#print axioms capture_certified

/-! ### DEFENCES — universally quantified over every trace of every length. -/

/-- info: 'Godel.majority_blocked' does not depend on any axioms -/
#guard_msgs in
#print axioms majority_blocked

/-- info: 'Godel.VC_preserves' does not depend on any axioms -/
#guard_msgs in
#print axioms VC_preserves

/-- info: 'Godel.eternity_holds' does not depend on any axioms -/
#guard_msgs in
#print axioms eternity_holds


/-! ### MOVEMENT E — the ratchet, both models. Registered prediction,
    kernel-checked verdict: regime holds, clause falls, repair is C. -/

/-- info: 'Godel.regime_blocks_repricing' does not depend on any axioms -/
#guard_msgs in
#print axioms regime_blocks_repricing

/-- info: 'Godel.regime_gate_holds' does not depend on any axioms -/
#guard_msgs in
#print axioms regime_gate_holds

/-- info: 'Godel.regime_guards_nothing_else' does not depend on any axioms -/
#guard_msgs in
#print axioms regime_guards_nothing_else

/-- info: 'Godel.clause_blocks_repricing_while_present' does not depend on any axioms -/
#guard_msgs in
#print axioms clause_blocks_repricing_while_present

/-- info: 'Godel.clause_ratchet_bypassed' does not depend on any axioms -/
#guard_msgs in
#print axioms clause_ratchet_bypassed

/-- info: 'Godel.selfentrenched_gate_holds' does not depend on any axioms -/
#guard_msgs in
#print axioms selfentrenched_gate_holds

/-- info: 'Godel.selfentrenched_guards_no_content' does not depend on any axioms -/
#guard_msgs in
#print axioms selfentrenched_guards_no_content

/-! ### MOVEMENT F — the fork. Registered prediction, kernel-checked
    verdict: the steelman is real (immutability by inexpressibility,
    D's interior attack deleted), the fork goes through at 51 anyway,
    repair and coup are the same constructor, and the canonical
    post-fork history is code-invalid. -/

/-- info: 'Godel.contract_inexpressible' does not depend on any axioms -/
#guard_msgs in
#print axioms contract_inexpressible

/-- info: 'Godel.code_is_law' does not depend on any axioms -/
#guard_msgs in
#print axioms code_is_law

/-- info: 'Godel.exploit_valid' does not depend on any axioms -/
#guard_msgs in
#print axioms exploit_valid

/-- info: 'Godel.drained_step' does not depend on any axioms -/
#guard_msgs in
#print axioms drained_step

/-- info: 'Godel.no_onchain_repair' does not depend on any axioms -/
#guard_msgs in
#print axioms no_onchain_repair

/-- info: 'Godel.promise_holds_without_fork' does not depend on any axioms -/
#guard_msgs in
#print axioms promise_holds_without_fork

/-- info: 'Godel.fork_always_open' does not depend on any axioms -/
#guard_msgs in
#print axioms fork_always_open

/-- info: 'Godel.the_dao_fork' does not depend on any axioms -/
#guard_msgs in
#print axioms the_dao_fork

/-- info: 'Godel.the_coup_fork' does not depend on any axioms -/
#guard_msgs in
#print axioms the_coup_fork

/-- info: 'Godel.code_still_there' does not depend on any axioms -/
#guard_msgs in
#print axioms code_still_there

/-- info: 'Godel.theft_still_valid_there' does not depend on any axioms -/
#guard_msgs in
#print axioms theft_still_valid_there

/-- info: 'Godel.canonical_history_invalid' does not depend on any axioms -/
#guard_msgs in
#print axioms canonical_history_invalid

end Godel
