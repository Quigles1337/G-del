/-
  ══════════════════════════════════════════════════════════════════════
  GÖDEL'S LOOPHOLE, KERNEL-CHECKED
  A toy constitutional state machine, after the argument Kurt Gödel
  reportedly began at his 1947 citizenship hearing and never wrote down.

  Reconstruction premise (per Suber, "The Paradox of Self-Amendment"):
  model a constitution as a formal system whose rule of change (Article V)
  is itself an object-level provision. Then legal reachability of
  dictatorship is a THEOREM, not an opinion.

  Four movements:
    A. The loophole: the amendment rule is amendable, so one supermajority
       moment collapses the cost of all future amendments.  (Reachable.)
    B. Entrenchment without self-entrenchment: the clause protects the
       provisions but nothing protects the clause.          (Reachable.)
    C. Self-entrenched eternity clause (Grundgesetz Art. 79(3) style):
       formally SAFE — an invariant proof goes through.     (Unreachable.)
    D. Interpretation endogenized: the validity predicate itself becomes
       a state variable (court capture / constituent-assembly gambit).
       The eternity clause remains in the text — inert.     (Reachable.)

  Punchline, made precise at the bottom of the file: C's safety proof is
  conducted HERE, in Lean — i.e., outside the object system. The object
  system cannot hold its own validity predicate fixed (that is D). This
  is the constitutional rhyme of Gödel II: consistency is certified one
  level up, or not at all.

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
    dictatorship in one step. Gödel's observation is not that this path
    exists — it is what the OTHER path does to the system afterwards. -/
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
       by actors the text cannot bind. Freeze any level, and the exploit
       moves one level up: text < amendment rule < recognition rule <
       social practice. The tower does not bottom out inside the law.

   The Gödel II rhyme, stated exactly: `eternity_holds` is a consistency
   certificate for system C, and it was proved in Lean — a strictly
   stronger metasystem — not inside C. The object system's own resources
   (movement D) cannot even keep the certificate's hypotheses true.
   A constitution can no more secure its own interpretation than a
   theory can prove its own consistency. What ultimately holds the
   invariant is the thing this file cannot formalize: the community's
   disposition to keep reading the clause as binding.
   ══════════════════════════════════════════════════════════════════════ -/

#print axioms majority_blocked
#print axioms loophole
#print axioms entrenchment_bypassed
#print axioms eternity_holds
#print axioms interpretation_attack
#print axioms clause_still_there

#eval init
#eval afterLoophole
#eval afterCapture

end Godel
