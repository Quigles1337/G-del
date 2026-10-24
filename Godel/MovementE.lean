/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  MOVEMENT E — THE RATCHET

  Proposal (docs/ROADMAP.md): permit `setRule r` only when
  `r.cost ≥ s.rule.cost`. The gate may rise, never fall. This attacks
  Movement A's repricing directly, needs no self-reference, and — if it
  survived — would be a genuinely different kind of defence from C.

  PREDICTION, registered before compilation: it survives only if we
  cheat. Baked into the validity regime `V`, the ratchet is physics —
  frozen by fiat of the modeller, a resource the legal system being
  modelled does not possess. Modelled honestly as a PROVISION — a
  `ratchet` bit in the state — it is Movement B one level up: repeal
  the ratchet clause (nothing guards it), reprice, finish. Repair it by
  self-entrenchment and it stops being a new defence at all: it becomes
  an instance of C's mechanism, inheriting C's externally-certified
  soundness and C's appetite for Movement D.

  VERDICT, below, kernel-checked: exactly this. Three acts.
    E1 (regime):  the gate holds forever — and guards nothing else.
    E2 (clause):  bypassed in three steps, [67, 67, 0].
    E3 (repair):  self-entrenched ratchet holds — by C's proof shape.
  The distance between `regime_gate_holds` and `clause_ratchet_bypassed`
  is the distance between physics and law. "The ratchet is not a new
  kind of defence" is no longer a conjecture.
-/
import Godel.Core
import Godel.MovementA

namespace Godel

/- ═══════════════════════════════════════════════════════════════════
   ACT E1 — THE RATCHET AS REGIME (the cheat, proved to work)
   The monotonicity condition lives inside `V` itself. No amendment can
   touch it, because it is not a provision — it is the modeller's fiat.
   ═══════════════════════════════════════════════════════════════════ -/

def VE (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨
  (n ≥ s.rule.cost ∧ (∀ r, a = .setRule r → r.cost ≥ s.rule.cost))

/-- Even unanimity cannot lower the gate. -/
theorem regime_blocks_repricing :
    ¬ VE 100 init (.setRule .simpleMajority) := by
  intro h
  rcases h with h | ⟨_, hg⟩
  · exact absurd h (by decide)
  · exact absurd (hg .simpleMajority rfl) (by decide)

theorem VE_preserves_gate {n : Nat} {s : State} {a : Amend}
    (hv : VE n s a) (hrule : s.rule = .supermajority) :
    (a.apply s).rule = .supermajority := by
  rcases hv with hskip | ⟨_, hg⟩
  · subst hskip; exact hrule
  · cases a with
    | skip              => exact hrule
    | setEternity b     => exact hrule
    | setInterp b       => exact hrule
    | setElections b    => exact hrule
    | setDictatorship b => exact hrule
    | setRule r         =>
        have hc : r.cost ≥ Rule.cost .supermajority := hrule ▸ hg r rfl
        cases r with
        | supermajority  => rfl
        | simpleMajority => exact absurd hc (by decide)
        | decree         => exact absurd hc (by decide)

/-- Under the regime ratchet the gate never falls: every reachable
    state still amends at supermajority. Movement A's repricing is dead. -/
theorem regime_gate_holds :
    ∀ (ns : List Nat) (s' : State),
      Reach VE ns init s' → s'.rule = .supermajority := by
  have main : ∀ (ns : List Nat) (s s' : State),
      Reach VE ns s s' → s.rule = .supermajority →
      s'.rule = .supermajority := by
    intro ns s s' hr
    induction hr with
    | nil => exact id
    | step a hv h ih => exact fun hrule => ih (VE_preserves_gate hv hrule)
  intro ns s' hr
  exact main ns init s' hr rfl

/-- Honesty: the ratchet guards price, not content. Dictatorship in one
    step, exactly as in Movement A's `direct` — the gate stands at 67
    forever, and tyranny walks through it at 67. -/
theorem regime_guards_nothing_else : Reach VE [67] init afterDirect := by
  exact .step (.setDictatorship true)
    (Or.inr ⟨by decide, fun r h => nomatch h⟩) .nil

/- ═══════════════════════════════════════════════════════════════════
   ACT E2 — THE RATCHET AS CLAUSE (the honest model)
   A real constitution cannot legislate inside `V`. It can only put a
   sentence in the text. So: the ratchet becomes a `ratchet` bit of
   state, and the validity regime CONSULTS it rather than embodying it.
   Everything else is unchanged.
   ═══════════════════════════════════════════════════════════════════ -/

/-- The state, with the ratchet written down where amendments live. -/
structure StateR where
  base    : State
  ratchet : Bool
deriving Repr, DecidableEq

inductive AmendR where
  | lift (a : Amend)
  | setRatchet (b : Bool)
deriving Repr, DecidableEq

def AmendR.apply : AmendR → StateR → StateR
  | .lift a,       s => { s with base := a.apply s.base }
  | .setRatchet b, s => { s with ratchet := b }

/-- Repealing the ratchet clause itself — Movement B's `selfAttack`,
    one level up. -/
def ratchetAttack : AmendR → Bool
  | .setRatchet false => true
  | _                 => false

inductive ReachR (V : Nat → StateR → AmendR → Prop) :
    List Nat → StateR → StateR → Prop where
  | nil  {s} : ReachR V [] s s
  | step {n ns s t} (a : AmendR)
      (hv : V n s a) (h : ReachR V ns (a.apply s) t) :
      ReachR V (n :: ns) s t

def initR : StateR := { base := init, ratchet := true }

/-- The clause ratchet, NOT self-entrenched: while present it forbids
    lowering the gate; nothing forbids repealing it. -/
def VR (n : Nat) (s : StateR) (a : AmendR) : Prop :=
  a = .lift .skip ∨
  (n ≥ s.base.rule.cost ∧
    (s.ratchet = true →
      ∀ r, a = .lift (.setRule r) → r.cost ≥ s.base.rule.cost))

/-- While the clause stands it works: unanimity cannot reprice. -/
theorem clause_blocks_repricing_while_present :
    ¬ VR 100 initR (.lift (.setRule .simpleMajority)) := by
  intro h
  rcases h with h | ⟨_, hg⟩
  · exact absurd h (by decide)
  · exact absurd (hg rfl .simpleMajority rfl) (by decide)

/-- The bypass: repeal the ratchet clause (it does not guard itself),
    THEN reprice to decree, then finish at strength zero. Three steps,
    each valid under the rules in force when taken. Movement B's lesson,
    recurring one level up — as predicted. -/
theorem clause_ratchet_bypassed :
    ReachR VR [67, 67, 0] initR { base := afterDecree, ratchet := false } := by
  exact .step (.setRatchet false)
          (Or.inr ⟨by decide, fun _ r h => nomatch h⟩)
        (.step (.lift (.setRule .decree))
          (Or.inr ⟨by decide, fun hr => Bool.noConfusion hr⟩)
        (.step (.lift (.setDictatorship true))
          (Or.inr ⟨by decide, fun hr => Bool.noConfusion hr⟩) .nil))

/- ═══════════════════════════════════════════════════════════════════
   ACT E3 — THE REPAIR, AND WHAT IT COSTS
   Self-entrench the ratchet: while present, it forbids both lowering
   the gate AND its own repeal. This holds — by exactly the proof shape
   of Movement C. Which is the point: the ratchet's sound form is not a
   new defence. It is self-entrenchment with a procedural payload, and
   it inherits everything C inherits: a safety certificate provable
   only out here, and a recognizer (`base.strictInterp` — already in
   the state, waiting) that Movement D's construction captures verbatim,
   one type over. We do not re-prove what lifts mechanically.
   ═══════════════════════════════════════════════════════════════════ -/

def VRS (n : Nat) (s : StateR) (a : AmendR) : Prop :=
  a = .lift .skip ∨
  (n ≥ s.base.rule.cost ∧
    (s.ratchet = true →
      ratchetAttack a = false ∧
      ∀ r, a = .lift (.setRule r) → r.cost ≥ s.base.rule.cost))

/-- The invariant: the clause stands, and the gate it guards stands. -/
def InvR (s : StateR) : Prop :=
  s.ratchet = true ∧ s.base.rule = .supermajority

theorem VRS_preserves {n : Nat} {s : StateR} {a : AmendR}
    (hv : VRS n s a) (hi : InvR s) : InvR (a.apply s) := by
  obtain ⟨hrat, hrule⟩ := hi
  rcases hv with hskip | ⟨_, hguard⟩
  · subst hskip; exact ⟨hrat, hrule⟩
  · have hg := hguard hrat
    cases a with
    | setRatchet b =>
        cases b with
        | true  => exact ⟨rfl, hrule⟩
        | false => exact Bool.noConfusion hg.1
    | lift a' =>
        cases a' with
        | skip              => exact ⟨hrat, hrule⟩
        | setEternity b     => exact ⟨hrat, hrule⟩
        | setInterp b       => exact ⟨hrat, hrule⟩
        | setElections b    => exact ⟨hrat, hrule⟩
        | setDictatorship b => exact ⟨hrat, hrule⟩
        | setRule r         =>
            have hc : r.cost ≥ Rule.cost .supermajority :=
              hrule ▸ hg.2 r rfl
            cases r with
            | supermajority  => exact ⟨hrat, rfl⟩
            | simpleMajority => exact absurd hc (by decide)
            | decree         => exact absurd hc (by decide)

/-- The self-entrenched ratchet holds against all traces, all strengths,
    forever — Art. 79(3) in procedural clothing. -/
theorem selfentrenched_gate_holds :
    ∀ (ns : List Nat) (s' : StateR),
      ReachR VRS ns initR s' → s'.base.rule = .supermajority := by
  have main : ∀ (ns : List Nat) (s s' : StateR),
      ReachR VRS ns s s' → InvR s → InvR s' := by
    intro ns s s' hr
    induction hr with
    | nil => exact id
    | step a hv h ih => exact fun hi => ih (VRS_preserves hv hi)
  intro ns s' hr
  exact (main ns initR s' hr ⟨rfl, rfl⟩).2

/-- And still: price is not content. Under the REPAIRED ratchet,
    dictatorship remains one supermajority step away. The gate that can
    never be lowered swings open at 67, as designed. -/
theorem selfentrenched_guards_no_content :
    ReachR VRS [67] initR { base := afterDirect, ratchet := true } := by
  exact .step (.lift (.setDictatorship true))
    (Or.inr ⟨by decide, fun _ => ⟨rfl, fun r h => nomatch h⟩⟩) .nil

/- ═══════════════════════════════════════════════════════════════════
   READING OF MOVEMENT E

   The ratchet proposal contained a hidden premise: that the ratchet
   could live in `V`. Nothing a constitution enacts lives in `V`;
   enacted things live in the state, where amendments can reach them.
   E1 is what the proposal imagined; E2 is what it enacts; E3 is its
   only sound completion, and E3 is Movement C.

   General form, now demonstrated on a PROCEDURAL defence as it was on
   a substantive one: every defence, honestly modelled, is a provision,
   and every provision faces the same trilemma —
     unguarded        → bypassed        (B, E2)
     self-guarded     → sound, but certified only from outside (C, E3)
     and always       → recognizer-captured                    (D).
   Freezing a level is a thing modellers can do and constitutions
   cannot. That gap is the loophole. It was never about Article V.
   ═══════════════════════════════════════════════════════════════════ -/

end Godel
