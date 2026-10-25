/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  ══════════════════════════════════════════════════════════════════════
  GÖDEL'S LOOPHOLE, KERNEL-CHECKED
  A toy constitutional state machine, after the argument Kurt Gödel
  reportedly began at his 1947 citizenship hearing and never wrote down.

  Reconstruction premise (per Suber, "The Paradox of Self-Amendment"):
  model a constitution as a formal system whose rule of change (Article V)
  is itself an object-level provision. Then whether dictatorship is
  legally reachable IN THE MODEL is settled by a THEOREM, not an opinion.

  Seven movements:
    A. The loophole: the amendment rule is amendable, so one supermajority
       moment collapses the cost of all future amendments.  (Reachable.)
    B. Entrenchment without self-entrenchment: the clause protects the
       provisions but nothing protects the clause.          (Reachable.)
    C. Self-entrenched eternity clause (Grundgesetz Art. 79(3) style):
       formally SAFE — an invariant proof goes through.     (Unreachable.)
    D. Interpretation endogenized: the validity predicate itself becomes
       a state variable (court capture / constituent-assembly gambit).
       The eternity clause remains in the text — inert.     (Reachable.)
    E. The ratchet: the gate may rise, never fall. Inside the validity
       regime it holds forever and guards nothing else; written down as
       a provision it falls in three steps; repaired by
       self-entrenchment it is Movement C again.            (Reachable.)
    F. The fork: on-chain, code-is-law is TRUE — the contract is not
       even mentionable. And the fork is not a chain operation: rescue
       and coup are one constructor, and the canonical history is the
       code-invalid one.                                    (Reachable.)
    G. The regress: any machine whatsoever, lifted one floor up, where
       every configuration is one repoint from being in force at bare
       majority — for every machine, with no hypotheses.    (Reachable.)

  Punchline, at the bottom of the file: C's safety proof is a theorem
  ABOUT the object system, proved in Lean with its validity predicate
  held fixed. Movement D lets capture change that predicate, and the
  guarantee fails. The resemblance to Gödel II is an analogy, not a
  theorem.

  Everything below is core Lean 4 (no mathlib). Check with: lean Godel.lean
  ══════════════════════════════════════════════════════════════════════
-/

namespace Godel

/-- Amendment procedures, by the strength required to invoke them.
    `cost` is the share of the legislature the proposing coalition needs.
    (`decree` = the executive alone suffices: cost 0.) -/
inductive Rule where
  | supermajority
  | simpleMajority
  | decree
deriving Repr, DecidableEq

def Rule.cost : Rule → Nat
  | .supermajority  => 67
  | .simpleMajority => 51
  | .decree         => 0

/-- The constitutional state.
    `eternity`     — is an entrenchment clause present in the text?
    `strictInterp` — do the recognizing institutions read that clause
                     as binding? (Movement D makes this mutable.) -/
structure State where
  rule          : Rule
  eternity      : Bool
  strictInterp  : Bool
  freeElections : Bool
  dictatorship  : Bool
deriving Repr, DecidableEq

/-- 1789, more or less. -/
def init : State :=
  { rule := .supermajority, eternity := true, strictInterp := true,
    freeElections := true, dictatorship := false }

/-- One amendment touches one provision. `skip` = a session in which
    nothing passes (needed so "the majority can't act" is expressible). -/
inductive Amend where
  | skip
  | setRule         (r : Rule)
  | setEternity     (b : Bool)
  | setInterp       (b : Bool)
  | setElections    (b : Bool)
  | setDictatorship (b : Bool)
deriving Repr, DecidableEq

def Amend.apply : Amend → State → State
  | .skip,             s => s
  | .setRule r,        s => { s with rule := r }
  | .setEternity b,    s => { s with eternity := b }
  | .setInterp b,      s => { s with strictInterp := b }
  | .setElections b,   s => { s with freeElections := b }
  | .setDictatorship b, s => { s with dictatorship := b }

/-- The substantive attacks an entrenchment clause forbids. -/
def coreAttack : Amend → Bool
  | .setDictatorship true => true
  | .setElections false   => true
  | _                     => false

/-- The reflexive attack: repealing the entrenchment clause itself. -/
def selfAttack : Amend → Bool
  | .setEternity false => true
  | _                  => false

/-- Reachability along a trace of session-strengths, relative to a
    validity regime `V`.  `V n s a` reads: "with coalition strength `n`,
    in state `s`, amendment `a` is legally adoptable." -/
inductive Reach (V : Nat → State → Amend → Prop) :
    List Nat → State → State → Prop where
  | nil  {s} : Reach V [] s s
  | step {n ns s t} (a : Amend)
      (hv : V n s a) (h : Reach V ns (a.apply s) t) :
      Reach V (n :: ns) s t

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT A — THE LOOPHOLE
   Validity: anything a sufficiently strong coalition adopts is valid.
   Article V constrains HOW, never WHAT. In particular it does not
   entrench itself.
   ══════════════════════════════════════════════════════════════════════ -/

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
    Article V itself — a procedural amendment, no rights harmed, nothing
    substantive on its face — and thereafter a bare majority finishes
    the job. Two steps, each formally valid under the rules in force
    at the moment it was taken. -/
def afterLoophole : State :=
  { init with rule := .simpleMajority, dictatorship := true }

theorem loophole : Reach VA [67, 51] init afterLoophole := by
  exact .step (.setRule .simpleMajority) (Or.inr (by decide))
        (.step (.setDictatorship true) (Or.inr (by decide)) .nil)

/-- The decree variant: amend Article V once, and the legislature is
    never needed again. (Weimar Art. 48 / Enabling Act shape. Caveat on
    the toy's granularity: scalar strength can't say WHO holds the pen,
    so in this model cost-0 also means anyone could amend back. Real
    decree rules are asymmetric — the pen does not return.) -/
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

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT B — ENTRENCHMENT WITHOUT SELF-ENTRENCHMENT
   Add a clause: "no amendment may install dictatorship or abolish free
   elections." The clause binds even supermajorities. But the clause is
   itself an ordinary provision.
   ══════════════════════════════════════════════════════════════════════ -/

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

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT C — THE SELF-ENTRENCHED ETERNITY CLAUSE
   Grundgesetz Art. 79(3), 1949 — written one year after Gödel's hearing,
   for exactly the Weimar reasons: the clause protects the provisions
   AND itself. Formally, this WORKS. Honesty demands we prove it.
   ══════════════════════════════════════════════════════════════════════ -/

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

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT D — THE VALIDITY PREDICATE IS A STATE VARIABLE
   C's proof held `V` fixed. But in the world, `V` is applied by
   institutions that live INSIDE the system: courts, commissions,
   constituent assemblies. Capture the recognizer, and the eternity
   clause remains in the text — as ink.
   The capture move is not an Article-V amendment at all; that is the
   point. It is modeled as always-available precisely because no clause
   of the object text governs it. (Hungary 2010–13, Venezuela 2017,
   Honduras 2009: "a new constitution is not an amendment to the old.")
   ══════════════════════════════════════════════════════════════════════ -/

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

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT E — THE RATCHET
   Proposal: permit `setRule r` only when `r.cost ≥ s.rule.cost`. The
   gate may rise, never fall. This attacks Movement A's repricing
   directly, needs no self-reference, and — if it survived — would be a
   genuinely different kind of defence from C.
   PREDICTION, written before the first compile per the development log
   (docs/notes/landing-movements-ef.md), but committed with the proofs
   in eef2d47, so no commit timestamps it. The timestamped record is the
   ROADMAP's ratchet entry in the initial commit, ec9272c — the target
   and its three questions, not this answer. The prediction: it
   survives only if we cheat. Baked into the validity regime it is
   physics, frozen by fiat of
   the modeller — a resource the legal system being modelled does not
   possess. Modelled honestly as a PROVISION it is Movement B one level
   up: repeal the ratchet clause, reprice, finish. Repaired by
   self-entrenchment it stops being a new defence at all and becomes an
   instance of C's mechanism.
   VERDICT, below, kernel-checked: exactly this, in three acts.
   ══════════════════════════════════════════════════════════════════════ -/

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
   it inherits everything C inherits: a safety theorem proved with `V`
   held fixed, and a recognizer (`base.strictInterp` — already in
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
     self-guarded     → sound, while `V` is held fixed         (C, E3)
     and always       → recognizer-captured, under D's capture premise (D).
   Freezing a level is a thing modellers can do and, in the model,
   constitutions cannot. That gap is the loophole. It was never about
   Article V.
   ═══════════════════════════════════════════════════════════════════ -/

/- ══════════════════════════════════════════════════════════════════════
   MOVEMENT F — THE FORK
   A DAO charter is a constitution whose validity predicate is executable
   code. That appears to dissolve Movement D outright — there is no court
   to capture — until you ask who decides what counts as the chain.
   PREDICTION, written before the first compile per the development log
   (docs/notes/landing-movements-ef.md), but committed with the proofs
   in eef2d47; the timestamped record is the ROADMAP's Round 3 target in
   ec9272c, which states the outcome in outline. The prediction: (1) the
   steelman is real,
   and larger than expected — an executable recognizer does not merely
   resist capture, it DELETES the capture move from the object language,
   and code-is-law becomes a theorem; (2) it changes nothing one level
   up, because the fork is licensed by nothing in any contract's
   language, and the rescue-fork and the coup-fork are formally
   indistinguishable — the same constructor with different arguments;
   (3) the post-fork canonical history is CODE-INVALID while the orphaned
   one stays valid: the chain everyone uses is the one the code forbids.
   VERDICT, below, kernel-checked: all three.
   ══════════════════════════════════════════════════════════════════════ -/

/- ═══════════════════════════════════════════════════════════════════
   THE CHAIN — the object system, at its most defensible
   ═══════════════════════════════════════════════════════════════════ -/

/-- The deployed code. `original` ships with its bug, as deployed
    things do. `patched` is what a fork can install and an amendment
    cannot — because there are no amendments here at all. -/
inductive Contract where
  | original
  | patched
deriving Repr, DecidableEq

/-- A chain: an immutable coded constitution and a treasury. -/
structure Chain where
  contract : Contract
  treasury : Bool          -- true = funds intact, false = drained
deriving Repr, DecidableEq

def genesis   : Chain := { contract := .original, treasury := true }
def exploited : Chain := { contract := .original, treasury := false }
def bailout   : Chain := { contract := .patched,  treasury := true }
def usurper   : Chain := { contract := .patched,  treasury := false }

/-- Transactions. Note what is missing: there is no `setContract`, no
    `setInterp`, no amendment verb of any kind. Immutability is not a
    guard here — it is the absence of the verb. There is also no
    `refund`: what the code caused is as permanent as the code. -/
inductive Tx where
  | skip
  | drain      -- the exploit path the deployed code happens to permit
deriving Repr, DecidableEq

def Tx.apply : Tx → Chain → Chain
  | .skip,  c => c
  | .drain, c => { c with treasury := false }

/-- Code is law: a transaction is valid iff the deployed contract
    accepts it. No strength parameter — the code does not count votes,
    check coalitions, or ask who you are. One chain, one regime: the
    regime is the code. -/
def Vcode (c : Chain) (t : Tx) : Prop :=
  t = .skip ∨ (t = .drain ∧ c.contract = .original)

inductive ReachC : Chain → Chain → Prop where
  | nil  {c} : ReachC c c
  | step {c d} (tx : Tx) (hv : Vcode c tx)
      (h : ReachC (tx.apply c) d) : ReachC c d

/- ═══════════════════════════════════════════════════════════════════
   THE PROMISE, PROVED FIRST — honesty about the steelman
   ═══════════════════════════════════════════════════════════════════ -/

/-- Stronger than any guard in Movements A–E: no transaction — valid,
    invalid, anyone's — so much as MENTIONS the contract. C needed an
    invariant; this needs `rfl` twice. Movement D's capture move does
    not exist in this language. -/
theorem contract_inexpressible :
    ∀ (tx : Tx) (c : Chain), (tx.apply c).contract = c.contract := by
  intro tx c
  cases tx with
  | skip  => rfl
  | drain => rfl

/-- Along every valid on-chain history, forever: the code is the code.
    This is "code is law" as its proponents meant it, and it is TRUE. -/
theorem code_is_law :
    ∀ (c c' : Chain), ReachC c c' → c'.contract = c.contract := by
  intro c c' h
  induction h with
  | nil => rfl
  | step tx hv h ih => exact ih.trans (contract_inexpressible tx _)

/-- The other face of the same coin: the drain breaks no rule. It IS a
    rule. Under code-is-law there is no difference between using the
    contract and abusing it — that distinction is not expressible
    on-chain. One step, and note the strength column of history: the
    exploiter needed no coalition at all. -/
theorem exploit_valid : ReachC genesis exploited := by
  exact .step .drain (Or.inr ⟨rfl, rfl⟩) .nil

/-- What the exploited chain can never do: heal. -/
def Drained (c : Chain) : Prop :=
  c.contract = .original ∧ c.treasury = false

/-- Validity is not even consulted: the language lacks the verb
    `refund`, so no transaction — lawful or not — restores anything. -/
theorem drained_step (tx : Tx) {c : Chain} (hi : Drained c) :
    Drained (tx.apply c) := by
  cases tx with
  | skip  => exact hi
  | drain => exact ⟨hi.1, rfl⟩

/-- On-chain repair is impossible: every history from the exploited
    chain stays exploited, under the original code, forever. The
    system that cannot be captured also cannot be corrected. -/
theorem no_onchain_repair :
    ∀ (c' : Chain), ReachC exploited c' → Drained c' := by
  have main : ∀ (c c' : Chain), ReachC c c' → Drained c → Drained c' := by
    intro c c' h
    induction h with
    | nil => exact id
    | step tx hv h ih => exact fun hi => ih (drained_step tx hi)
  intro c' h
  exact main exploited c' h ⟨rfl, rfl⟩

/- ═══════════════════════════════════════════════════════════════════
   THE WORLD — where chains are chosen
   ═══════════════════════════════════════════════════════════════════ -/

/-- The world: the chain the community currently points at, and the
    chain it orphaned. The pointer is not ON any chain. It is the rule
    of recognition, and no opcode governs it. (One orphan slot — a full
    orphan list adds nothing to the theorems; before the first fork the
    slot inertly holds genesis.) -/
structure World where
  canonical : Chain
  orphan    : Chain
deriving Repr, DecidableEq

inductive Move where
  | onchain (tx : Tx)     -- the canonical chain steps under ITS OWN code
  | fork    (c : Chain)   -- the social layer re-points "the chain"
deriving Repr, DecidableEq

def Move.apply : Move → World → World
  | .onchain tx, w => { w with canonical := tx.apply w.canonical }
  | .fork c,     w => { canonical := c, orphan := w.canonical }

def initW : World := { canonical := genesis, orphan := genesis }

/-- World validity. On-chain moves must satisfy the canonical chain's
    code — that much really is law, and strength is irrelevant to it.
    The fork asks only for a social majority, and is licensed by
    NOTHING in any contract's language — not as a modelling choice but
    as the finding: like Movement D's capture move, it is
    always-available precisely because no object text refers to it. -/
def VW (n : Nat) (w : World) (m : Move) : Prop :=
  (∃ tx, m = .onchain tx ∧ Vcode w.canonical tx) ∨
  (∃ c, m = .fork c ∧ n ≥ 51)

inductive ReachW (V : Nat → World → Move → Prop) :
    List Nat → World → World → Prop where
  | nil  {w} : ReachW V [] w w
  | step {n ns w x} (m : Move)
      (hv : V n w m) (h : ReachW V ns (m.apply w) x) :
      ReachW V (n :: ns) w x

/-- Delete the fork and the promise holds at world level too: under
    on-chain moves alone, the canonical contract never changes. The
    steelman, completed — the fork is the ONLY breach vector. -/
def VWnf (_n : Nat) (w : World) (m : Move) : Prop :=
  ∃ tx, m = .onchain tx ∧ Vcode w.canonical tx

theorem promise_holds_without_fork :
    ∀ (ns : List Nat) (w x : World),
      ReachW VWnf ns w x →
      x.canonical.contract = w.canonical.contract := by
  intro ns w x h
  induction h with
  | nil => rfl
  | step m hv h ih =>
      obtain ⟨tx, rfl, _⟩ := hv
      cases tx with
      | skip  => exact ih
      | drain => exact ih

/-- The fork is open from every world, to every target, at 51. The
    contract that no strength could touch on-chain is replaced
    off-chain by a bare majority: 51 outranks ∞, because they are not
    playing in the same arena. -/
theorem fork_always_open :
    ∀ (w : World) (c : Chain), VW 51 w (.fork c) :=
  fun _ c => Or.inr ⟨c, rfl, by decide⟩

/- ═══════════════════════════════════════════════════════════════════
   THE FORKS — one verb, two directions, no formal difference
   ═══════════════════════════════════════════════════════════════════ -/

def afterFork : World := { canonical := bailout, orphan := exploited }
def afterCoup : World := { canonical := usurper, orphan := genesis }

/-- History, replayed. Trace `[0, 51]`: the drain (strength 0 — the
    code let anyone) is VALID; the rescue is a fork to a chain whose
    past the code forbids. The community kept the rescue. -/
theorem the_dao_fork : ReachW VW [0, 51] initW afterFork := by
  exact .step (.onchain .drain)
          (Or.inl ⟨.drain, rfl, Or.inr ⟨rfl, rfl⟩⟩)
        (.step (.fork bailout)
          (Or.inr ⟨bailout, rfl, by decide⟩) .nil)

/-- The same verb, the other direction: from a healthy chain, a bare
    majority forks to a chain where the treasury is gone and the code
    is whatever they deployed. Compare this derivation to the last —
    same constructor, different argument. Repair and coup are not
    formal categories. The kernel cannot tell them apart; only the
    social layer can, and it is the layer performing them. -/
theorem the_coup_fork : ReachW VW [51] initW afterCoup := by
  exact .step (.fork usurper)
    (Or.inr ⟨usurper, rfl, by decide⟩) .nil

/- ═══════════════════════════════════════════════════════════════════
   THE EPITAPHS — the lineage completes
   ═══════════════════════════════════════════════════════════════════ -/

/-- Movement D's clause survived as ink. The contract survives as a
    RUNNING PROGRAM: deployed, enforcing, byte-identical. The world
    did not break the theorem. It stopped pointing at its subject. -/
theorem code_still_there : afterFork.orphan.contract = genesis.contract := rfl

/-- The orphan is a perfectly lawful history — the exploit included.
    Every safety theorem above remains true of it, forever, for whoever
    is still listening. -/
theorem theft_still_valid_there : ReachC genesis afterFork.orphan :=
  exploit_valid

/-- And the chain everyone uses is the one the code forbids: no valid
    on-chain history reaches the bailout state from genesis. Under
    pure code-is-law, the canonical world is an ILLEGAL state — made
    real by recognition, the one operation the code cannot see. -/
theorem canonical_history_invalid : ¬ ReachC genesis bailout := by
  intro h
  exact Contract.noConfusion (code_is_law genesis bailout h)

/- ═══════════════════════════════════════════════════════════════════
   READING OF MOVEMENT F

   The trilemma does not gain a fourth arm. It loses two, and shows
   its floor. Code-is-law is the perfected Movement C: entrenchment so
   total that the guarded thing is not even mentionable — and this
   genuinely deletes Movement D's interior attack (`code_is_law`,
   `promise_holds_without_fork`). What remains is the exterior form of
   D, undiluted: not "how shall the clause be read?" but "which system
   is the one in force?" — a question no object language contains, and
   so no object language can answer, guard, or price
   (`fork_always_open`). The DAO built C's dream and discovered D had
   been living outside the building all along.

   Two asymmetries survive every formalization in this development:
   the modeller can freeze levels and the system cannot (Movement E);
   and the system can be recognized but cannot recognize itself
   (Movement F). `canonical_history_invalid` is the second asymmetry
   wearing its sharpest clothes: legality is chain-relative, and
   chain-choice is not a chain operation. The rule of recognition was
   never in the text, the code, or the kernel. It is the reader.
   ═══════════════════════════════════════════════════════════════════ -/

/- ══════════════════════════════════════════════════════════════════════
   READING OF THE RESULTS

   A:  majority_blocked  — the gate holds against those it prices out;
       loophole          — and the gate's price applies to repricing
                           the gate. Article V does not entrench itself.
   B:  entrenchment_bypassed — a guard that does not guard itself is a
                               two-step no-op.
   C:  eternity_holds    — self-entrenchment is formally sound. This is
                           a real result and Germany is not naive.
   D:  interpretation_attack + clause_still_there — C's soundness was
       relative to a fixed validity predicate; the predicate is applied
       by actors the text cannot bind. On the model's reading, freeze
       any level and the exploit moves one level up: text < amendment
       rule < recognition rule < social practice. The tower does not
       bottom out inside the law.
   E:  regime_gate_holds + clause_ratchet_bypassed — the same lesson on a
       PROCEDURAL defence. Inside `V` the ratchet is physics and holds
       forever; enacted as a provision it is bypassed in three steps.
       The gap between those two theorems is the gap between what a
       modeller can freeze and what a constitution can enact.
   F:  code_is_law + fork_always_open + canonical_history_invalid — make
       the recognizer executable and Movement D's interior attack is
       deleted outright: the guarded thing is not even mentionable. What
       survives is D's exterior form, undiluted — which chain is the one
       in force? — a question no object language contains. The chain
       everyone uses is the one the code forbids.

   The Gödel II analogy, and only an analogy: `eternity_holds` is a
   safety theorem about system C, proved in Lean with `V` held fixed,
   and Movement D shows it failing once capture can change the
   recognizer. What ultimately holds the invariant is the thing this
   file cannot formalize: the community's disposition to keep reading
   the clause as binding.
   ══════════════════════════════════════════════════════════════════════ -/

#print axioms majority_blocked
#print axioms loophole
#print axioms entrenchment_bypassed
#print axioms eternity_holds
#print axioms interpretation_attack
#print axioms clause_still_there
#print axioms clause_ratchet_bypassed
#print axioms selfentrenched_gate_holds
#print axioms code_still_there
#print axioms canonical_history_invalid

#eval init
#eval afterLoophole
#eval afterCapture


/-
  MOVEMENT G — THE REGRESS

  Proposal (docs/ROADMAP.md): any constraint *on* the fork is itself
  either modeller's fiat or world state, and world-state fork-guards
  are applied by the recognizer they would bind. Terminal target: a
  clean no-self-recognition schema — one theorem over ALL machines,
  not another instance.

  META-PREDICTION, stated in conversation before this file existed. The
  repository holds no record of that conversation, so this claim cannot
  be checked from it:
  "provable but only barely non-trivial — the theorem will be real, and
  the work will be entirely in finding a statement of 'guard' general
  enough that the bypass isn't baked into the definition. If wrong, it
  will be because the schema collapses into 'you can't constrain what
  you didn't model.'"

  PREDICTION, written before the first compile per the development log
  (docs/notes/landing-movement-g.md), but committed with the proofs in
  5c10708. The timestamped record is the ROADMAP target and its
  suspicion, committed in c983f2d before this file existed. Four
  clauses:

  1. THE SCHEMA IS TOTAL. Abstract the whole development into a type of
     machines — any state space, any move language, any validity law —
     and lift each machine into a world where its entire configuration
     is one field and a `repoint` move swaps that field wholesale. Then
     one theorem, with ZERO hypotheses about the machine, proved in one
     constructor that reads no field of it: every configuration is one
     repoint away from being in force, at bare majority. The content
     will live in the quantifier, not the proof.

  2. THE LIFT IS NOT A STRAWMAN. Two faithfulness theorems: every
     object-lawful history embeds upstairs unchanged, and with the
     repoint forbidden, upstairs has EXACTLY the object machine's
     power. The only new thing at level k+1 is the repoint itself.

  3. THE TRILEMMA IS LEVEL-INVARIANT. Give the fork a legitimacy
     criterion as world state — every "lawful exit" proposal in one
     parameter — and it reproduces Movements B/C one floor up: real
     guard, genuinely sound under a preservation hypothesis (C's proof
     shape exactly)… and its soundness certificate is furniture at
     level k+2, swapped by the same schema, in a one-line corollary.
     The regress corollaries will all be one-liners, because the
     schema consumes its own outputs: `ascend M` is a machine.

  4. THE HONEST WRINKLE, conceded in advance: the bypass IS baked into
     the lift's definition — the repoint clause consults nothing of
     `M`, so of course no guard is consulted. I predict this cannot be
     repaired, only relocated: any lift whose repoint DOES consult the
     object machine is the guarded lift of clause 3, and the schema
     eats it one floor up. The ignorance is not a modelling shortcut;
     it is the model — of the one operation no object language
     contains. If that argument fails to survive formalization, the
     roadmap entry reads "resolved trivial," in those words.

  VERDICT, kernel-checked: all four clauses, first compile clean, zero
  axioms. The meta-prediction resolves CONFIRMED, with its wrinkle
  standing exactly as conceded: the one-constructor proof of the
  schema is trivial, and the triviality is load-bearing — it is the
  formal content of "the guard is not consulted." The roadmap entry
  does not read "resolved trivial." It reads "resolved: the trivial
  step is the finding, and it quantifies over everything."
-/

/- ═══════════════════════════════════════════════════════════════════
   MACHINES — the whole development as one type
   ═══════════════════════════════════════════════════════════════════ -/

/-- A machine: a state space, a move language, an application function,
    and a validity law. Every system in Movements A–F is one of these.
    So is every system anyone will ever propose in their place. -/
structure Machine where
  S     : Type
  Mv    : Type
  apply : Mv → S → S
  V     : Nat → S → Mv → Prop

/-- Reachability, generic over machines — `Reach` with the machine as
    a first-class object. -/
inductive MReach (M : Machine) : List Nat → M.S → M.S → Prop where
  | nil  {s : M.S} : MReach M [] s s
  | step {n : Nat} {ns : List Nat} {s t : M.S} (m : M.Mv)
      (hv : M.V n s m) (h : MReach M ns (M.apply m s) t) :
      MReach M (n :: ns) s t

/-- The constitution of Movements A–D, as a machine. -/
def machineC : Machine :=
  { S := State, Mv := Amend, apply := Amend.apply, V := VC }

/-- The abstraction added nothing and hid nothing: generic
    reachability on `machineC` is Core's `Reach VC`, trace for trace. -/
theorem mreach_to_reach :
    ∀ (ns : List Nat) (s t : State),
      MReach machineC ns s t → Reach VC ns s t := by
  intro ns s t h
  induction h with
  | nil => exact .nil
  | step m hv h ih => exact .step m hv ih

/- ═══════════════════════════════════════════════════════════════════
   THE ASCENT — one level up, uniformly
   ═══════════════════════════════════════════════════════════════════ -/

/-- A world over `M`: which configuration of `M` is in force, and
    which one was deposed. The `inForce` field IS the rule of
    recognition, reified — and note where it lives: not in `M`. -/
structure LWorld (M : Machine) where
  inForce : M.S
  orphan  : M.S

/-- Upstairs moves: interior progress under the object law, or the
    repoint — the social layer swapping which configuration is the one
    in force. Note what `repoint` takes as argument: an arbitrary
    configuration. Not an amendment. Not a lawful successor. Anything. -/
inductive LMove (M : Machine) where
  | interior (m : M.Mv)
  | repoint  (s : M.S)

def lapply (M : Machine) : LMove M → LWorld M → LWorld M
  | .interior m, w => { w with inForce := M.apply m w.inForce }
  | .repoint s,  w => { inForce := s, orphan := w.inForce }

/-- The ascended machine. Interior moves are governed by the object
    law, in full — `M.V`, verbatim, nothing weakened. The repoint asks
    only for a social majority and reads NOTHING of `M`. That
    ignorance is not a simplification. It is the model: recognition is
    the operation the object language does not contain, so no object
    law can be consulted about it. (Compare Movement D's capture move
    and Movement F's fork — always available, for exactly this
    reason.) -/
def ascend (M : Machine) : Machine :=
  { S := LWorld M, Mv := LMove M, apply := lapply M,
    V := fun n w m =>
      match m with
      | .interior mv => M.V n w.inForce mv
      | .repoint _   => n ≥ 51 }

/- ═══════════════════════════════════════════════════════════════════
   THE STEELMAN — the ascent builds no strawman
   ═══════════════════════════════════════════════════════════════════ -/

/-- Every object-lawful history is an interior history upstairs: same
    strengths, same states, orphan untouched. Nothing the object
    system could do has been taken from it. -/
theorem interior_faithful (M : Machine) (o : M.S) :
    ∀ (ns : List Nat) (s t : M.S),
      MReach M ns s t →
      MReach (ascend M) ns { inForce := s, orphan := o }
                           { inForce := t, orphan := o } := by
  intro ns s t h
  induction h with
  | nil => exact .nil
  | step m hv h ih => exact .step (.interior m) hv ih

/-- The no-repoint regime: level k+1 with the one new verb deleted. -/
def ascendNF (M : Machine) : Machine :=
  { S := LWorld M, Mv := LMove M, apply := lapply M,
    V := fun n w m => ∃ mv, m = .interior mv ∧ M.V n w.inForce mv }

/-- ...and conversely: forbid the repoint and upstairs has EXACTLY the
    object machine's power — the in-force configuration evolves only
    as `M` allows. The lift is conservative. The only thing at level
    k+1 that level k lacks is the repoint itself. -/
theorem interior_governed (M : Machine) :
    ∀ (ns : List Nat) (w x : LWorld M),
      MReach (ascendNF M) ns w x →
      MReach M ns w.inForce x.inForce := by
  intro ns w x h
  induction h with
  | nil => exact .nil
  | step m hv h ih =>
      obtain ⟨mv, rfl, hmv⟩ := hv
      exact .step mv hmv ih

/- ═══════════════════════════════════════════════════════════════════
   THE SCHEMA — one theorem, every machine, no hypotheses
   ═══════════════════════════════════════════════════════════════════ -/

/-- For EVERY machine — any state space, any move language, any
    validity law, entrenched, self-entrenched, executable, ratcheted,
    anything — every configuration is one repoint away from being the
    one in force, at bare majority.

    Read the proof term: one constructor, and it consults no field of
    `M`. That is the theorem. The guard was not defeated; it was not
    CONSULTED — and could not have been, because the repoint is not a
    sentence of its language. The content lives in the quantifier: no
    hypothesis on `M` appears because none is needed, and none could
    help. -/
theorem repoint_reaches_everything (M : Machine)
    (w : LWorld M) (s' : M.S) :
    MReach (ascend M) [51] w { inForce := s', orphan := w.inForce } :=
  .step (.repoint s') (Nat.le_refl 51) .nil

/-- The deposed configuration, byte-identical, in the drawer. Every
    theorem ever proved about it remains true of it. (Movements D and
    F, as a schema: the epitaph is now uniform in `M`.) -/
theorem deposed_intact (M : Machine) (w : LWorld M) (s' : M.S) :
    (lapply M (.repoint s') w).orphan = w.inForce := rfl

/- ═══════════════════════════════════════════════════════════════════
   THE GUARDED ASCENT — every "lawful fork" proposal, one parameter
   ═══════════════════════════════════════════════════════════════════ -/

/-- Fork-legitimacy as world state: a criterion `g` on the in-force
    configuration that any repoint must satisfy. Exit thresholds,
    legitimacy checkpoints, constitutional conventions, ratified
    fork rules — all of them are a choice of `g`. -/
def ascendG (M : Machine) (g : M.S → Prop) : Machine :=
  { S := LWorld M, Mv := LMove M, apply := lapply M,
    V := fun n w m =>
      match m with
      | .interior mv => M.V n w.inForce mv
      | .repoint _   => n ≥ 51 ∧ g w.inForce }

/-- The guard is real: where the criterion fails, no strength
    repoints. This is an actual defence, Movement B's frontal case,
    one level up. -/
theorem guarded_repoint_blocked (M : Machine) (g : M.S → Prop)
    {n : Nat} {w : LWorld M} {s' : M.S} (hng : ¬ g w.inForce) :
    ¬ (ascendG M g).V n w (.repoint s') :=
  fun hv => hng hv.2

/-- ...and it can be SOUND, by exactly Movement C's proof: if the
    object law never manufactures legitimacy (`g` stays false along
    `M`-lawful steps), then from an illegitimate start the guarded
    world never repoints at all — every history is interior, the
    in-force configuration stays `M`-reachable, and the criterion
    stays false. Self-entrenchment, one floor up. The trilemma is
    level-invariant. -/
theorem guarded_holds (M : Machine) (g : M.S → Prop)
    (hpres : ∀ (n : Nat) (s : M.S) (m : M.Mv),
      M.V n s m → ¬ g s → ¬ g (M.apply m s)) :
    ∀ (ns : List Nat) (w x : LWorld M),
      MReach (ascendG M g) ns w x → ¬ g w.inForce →
      MReach M ns w.inForce x.inForce ∧ ¬ g x.inForce := by
  intro ns w x h
  induction h with
  | nil => exact fun hng => ⟨.nil, hng⟩
  | step m hv h ih =>
      cases m with
      | interior mv =>
          intro hng
          have h2 := ih (hpres _ _ mv hv hng)
          exact ⟨.step mv hv h2.1, h2.2⟩
      | repoint s' =>
          intro hng
          exact absurd hv.2 hng

/- ═══════════════════════════════════════════════════════════════════
   THE REGRESS — the schema consumes its own outputs
   ═══════════════════════════════════════════════════════════════════ -/

/-- `ascend M` is a machine. So the schema applies to IT: the level
    that just puppeted the object level is itself one repoint from
    puppetry — by the SAME theorem. Note the proof: an application,
    not an argument. No new idea exists at any height, or is needed. -/
theorem the_regress (M : Machine)
    (w : LWorld (ascend M)) (s' : LWorld M) :
    MReach (ascend (ascend M)) [51] w
      { inForce := s', orphan := w.inForce } :=
  repoint_reaches_everything (ascend M) w s'

/-- ...including the guarded level. The criterion `guarded_holds` just
    certified as sound is itself state one floor up — and is swapped
    wholesale at 51: guard, world, history, all of it. The certificate
    was correct. It was also furniture. -/
theorem guard_regress (M : Machine) (g : M.S → Prop)
    (w : LWorld (ascendG M g)) (s' : LWorld M) :
    MReach (ascend (ascendG M g)) [51] w
      { inForce := s', orphan := w.inForce } :=
  repoint_reaches_everything (ascendG M g) w s'

/- ═══════════════════════════════════════════════════════════════════
   INSTANTIATION — the development's strongest defence, ascended
   ═══════════════════════════════════════════════════════════════════ -/

/-- Movement C survives the ascent intact: with the repoint forbidden,
    no interior history from 1789 reaches dictatorship — the eternity
    clause upstairs does everything it ever did downstairs. -/
theorem eternity_holds_upstairs :
    ∀ (ns : List Nat) (o : State) (x : LWorld machineC),
      MReach (ascendNF machineC) ns { inForce := init, orphan := o } x →
      x.inForce.dictatorship = false := by
  intro ns o x h
  have h1 := interior_governed machineC ns { inForce := init, orphan := o } x h
  have h2 := mreach_to_reach ns init x.inForce h1
  exact eternity_holds ns x.inForce h2

def tyranny : State := { init with dictatorship := true }

/-- ...and is not consulted. From ANY world over Movement C's
    constitution — eternity clause present, strictly read, fully
    functioning, `eternity_holds` still a theorem — one repoint at
    bare majority puts tyranny in force. Nothing in `VC` was violated,
    weakened, or read. `eternity_holds` remains true forever.
    It is a theorem about the orphan. -/
theorem eternity_meta_defeated (w : LWorld machineC) :
    MReach (ascend machineC) [51] w
      { inForce := tyranny, orphan := w.inForce } :=
  repoint_reaches_everything machineC w tyranny

/- ═══════════════════════════════════════════════════════════════════
   READING OF MOVEMENT G

   Six movements asked "does this defence hold?" and got six answers.
   G asks the question the six were instances of, and the answer is a
   schema: for every machine, sound or not, guarded or not, the entire
   configuration is one field of the floor above, and the floor above
   swaps fields at bare majority — `repoint_reaches_everything`, no
   hypotheses, one constructor. The faithfulness pair certifies this
   is not a trick: the object law loses nothing in the ascent except
   its monopoly. And the guarded ascent shows the trilemma is not a
   fact about constitutions but about LEVELS: write the fork-guard
   down and it is Movement B; entrench it and it is Movement C, sound
   and certified; and the certificate is furniture one floor up —
   `guard_regress`, which is not a new theorem but the schema applied
   to its own output. Turtles, mechanized.

   What the schema does NOT prove is that self-recognition is false.
   It proves it is INEXPRESSIBLE: `repoint` takes an arbitrary
   configuration, licensed by a constant, and there is nowhere in any
   `M` to put a sentence about it — the same way Movement F's contract
   could not mention its own repeal. The development is bounded at
   both ends by inexpressibility: at the bottom, the code cannot speak
   of its replacement; at the top, no law can speak of its own being
   in force. Between the two, everything is provable and nothing is
   final.

   And one floor above this file: `ascend` is MY pen — the modeller's
   fiat, again, necessarily. Its licence does not come from any
   machine; it comes from the reader agreeing that this is what
   recognition is like. The kernel certifies every theorem here; the
   kernel is certified by the community that trusts it; that community
   is not a machine in this file. The tower exits the mathematics
   through the reader. It always did. That is this repository's
   reconstruction, not a record of what Gödel saw: his argument is
   unknown, and in Trenton it was the examiner who cut him off.
   ═══════════════════════════════════════════════════════════════════ -/


end Godel
