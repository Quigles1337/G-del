/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
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
  1.0.1 notes. Clause 3 is wrong in two words: `g` is a parameter of
  `ascendG`, not world state, and `guard_regress`'s outer repoint
  replaces the guarded level's world without consulting it — the guard
  is bypassed, not swapped. In clause 4, "no object language contains"
  means `ascend` places the operation outside the move interface.
-/
import Godel.Core
import Godel.MovementC

namespace Godel

/- ═══════════════════════════════════════════════════════════════════
   MACHINES — the whole development as one type
   ═══════════════════════════════════════════════════════════════════ -/

/-- A machine: a state space, a move language, an application function,
    and a validity law. Every system in Movements A–F can be written as
    one of these (`machineC`, below, is Movement C's), and so can any
    proposed in their place that has this shape — see
    docs/LIMITATIONS.md §12. -/
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
    ignorance is the modelling choice, not an oversight: recognition
    sits outside the object language's moves, and `ascend` consults no
    object law about it (`ascendG`, below, adds a criterion it does
    consult). (Compare Movement D's capture move and Movement F's fork
    — always available, for exactly this reason.) -/
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
    CONSULTED — `ascend`'s repoint is not a move of `M`, and its
    validity reads nothing of `M`. The content lives in the quantifier:
    no hypothesis on `M` appears because none is needed, and none could
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

/-- Fork-legitimacy as a criterion on world state: a predicate `g`,
    fixed with the machine, on the in-force configuration that any
    repoint must satisfy. Exit thresholds, legitimacy checkpoints,
    constitutional conventions, ratified fork rules — all of them can
    be modelled as a choice of `g`. -/
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
    certified as sound is not consulted one floor up: the outer repoint
    replaces the guarded level's world — in-force configuration and
    orphan — at 51, without evaluating `g`. The guard is bypassed, not
    swapped. The certificate was correct. It was also never asked. -/
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
   and certified; and one floor up the guard is bypassed, not swapped
   — `guard_regress`, which is not a new theorem but the schema applied
   to its own output. Turtles, mechanized.

   What the schema does NOT prove is that self-recognition is false —
   or that it is inexpressible: no language of recognition statements
   is defined here. Recognition is an operation outside the move
   interface: `repoint` takes an arbitrary configuration, licensed by
   a constant, and `M`'s law is never asked about it — as no
   transaction in Movement F can change its contract. That is the
   model's boundary at both ends: at the bottom, the code has no verb
   for its replacement; at the top, no law in the model is consulted
   about its own being in force. Between the two, everything is
   provable and nothing is final.

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
