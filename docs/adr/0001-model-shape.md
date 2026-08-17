# ADR-0001 — Model shape: what the state machine is allowed to say

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

The reconstruction premise (Suber) is that a constitution can be modelled
as a formal system whose rule of change is an object-level provision.
That premise does not by itself fix a model. Several choices had to be
made before any theorem could be stated, and each of them decides in
advance what kinds of result are reachable. Recording them here means a
later disagreement can be aimed at the choice rather than at the proof.

## Decision

**1. Validity is a predicate `V : Nat → State → Amend → Prop`, and the
four movements differ *only* in `V`.**

This is the load-bearing choice. It makes "does this defence work?" a
question about a transition relation, so a proposed defence becomes an
edit to `V` and the answer becomes a theorem rather than an argument. It
is also what makes Movement D expressible at all: once `V` is a
parameter, making part of it depend on `State` is a small step, and that
step *is* the movement.

**2. Coalition strength is a scalar `Nat`; `Rule.cost` is a threshold.**

Enough to express "how hard is it to amend," which is the quantity the
loophole attacks. Deliberately not enough to express *who* may propose.
Accepted cost: `loophole_decree` understates the decree variant, because
in this model cost 0 is symmetric and the pen returns. Flagged in the
source and in LIMITATIONS §3.

**3. `Reach` is indexed by a list of strengths, one per session.**

A trace is a sequence of legislative moments. No continuity requirement
links them — any strength may appear at any step. This is weaker than
reality (no intervening elections) and the weakness favours the attacker.
Stated in LIMITATIONS §2.

**4. The forbidden set is a hand-written `coreAttack`, and the target is
a boolean `dictatorship`.**

Both are stand-ins. `setDictatorship true` is not a plausible legal
instrument; it abbreviates a bundle. Choosing the forbidden set is a
substantive move made outside the model, and a different choice yields
different theorems. LIMITATIONS §4.

**5. In Movement D, capture is available at any strength including 0.**

The strongest and most contestable choice. Its warrant is
jurisprudential, not formal: on Hart's account the rule of recognition is
a social practice among officials, not a norm validated by a higher norm,
so no clause of the object text can govern it. Modelling capture as
ungoverned is the formal image of that claim.

The consequence is that Movement D cannot be falsified *within* the
model — no added clause blocks it. That is the point being made and also
a limit on what the movement can be evidence for. A reader who rejects
the premise should edit the second and third disjuncts of `VD`; it is a
one-line change and the rest of the development stands.

**6. Movement C models a clause that names itself.**

Stronger than Grundgesetz Art. 79(3) as literally written, and faithful
to it as the dominant doctrine reads it. Chosen deliberately: it is more
interesting to defeat a defence at its strongest. SOURCES §5.

## Consequences

- Defences are cheap to propose and cheap to test. Adding a fifth
  movement means writing a `V` and attempting an invariant.
- Every result is relative to these six choices, and none of them is
  neutral. LIMITATIONS exists so that this is visible rather than buried.
- Nothing in the model licenses a claim about *likelihood*. There are no
  actors, so reachability is the only question it can answer.

## Alternatives considered

- **`V` as a `Bool` function.** Would have made everything decidable by
  construction and removed the need for the instances in
  `Godel/Executable.lean`. Rejected: `Prop` keeps the statements readable
  as *claims about legality*, and decidability was recovered anyway —
  with `runTrace_sound` as the explicit, proved bridge rather than an
  identification assumed at the start.
- **Richer states (courts, actors, time).** Rejected for this round. The
  instrument should be small enough that a defence can be proposed and
  answered in an afternoon. See ROADMAP for what a second round would
  need.
