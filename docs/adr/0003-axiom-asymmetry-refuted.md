# ADR-0003 — The "attacks are cheaper than defences" reading is withdrawn

- **Status:** Accepted (negative result)
- **Date:** 2026-08-16

## Context

The first working version of this development produced a striking axiom
ledger:

```
'Godel.majority_blocked'      depends on axioms: [propext, Quot.sound]
'Godel.loophole'              does not depend on any axioms
'Godel.entrenchment_bypassed' does not depend on any axioms
'Godel.eternity_holds'        depends on axioms: [propext]
'Godel.interpretation_attack' does not depend on any axioms
'Godel.clause_still_there'    does not depend on any axioms
```

Every attack was axiom-free. Every defence was not. The reading almost
writes itself, and it is a good one: an attack is **existential** —
exhibit one trace, and the witness *is* the proof, so it reduces to
computation. A defence is **universal** — quantify over every trace of
every length, which needs induction, and the induction needs classical
axioms. Breaking a constitution is a finite object you can hand someone;
defending one is a claim about an infinite space. There was something
darkly fitting about the exploit being cheaper than the guarantee.

It was also observed that the two *point* refutations —
`B_blocks_direct`, `D_blocks_while_strict` — were axiom-free, which
seemed to confirm the story: those are finite checks, not invariants.

## Decision

**The reading is withdrawn. It is an artifact of tactic choice, not of
logic.**

`simp` and `omega` are classical by construction. Replacing three of
their uses closes the gap entirely, with **no change to any theorem
statement**:

```diff
  -- Godel/MovementA.lean, majority_blocked
- · exfalso
-   have h66 : n ≤ 66 := hle n (List.Mem.head ns)
-   rw [hrule] at hcost
-   simp [Rule.cost] at hcost
-   omega
+ · exact absurd (Nat.le_trans (hrule ▸ hcost) (hle n (List.Mem.head ns)))
+     (by decide)

  -- Godel/MovementC.lean, VC_preserves
- | false => simp [selfAttack] at hg
+ | false => exact Bool.noConfusion hg.2
- | false => simp [coreAttack] at hg
+ | false => exact Bool.noConfusion hg.1
- | true  => simp [coreAttack] at hg
+ | true  => exact Bool.noConfusion hg.1
```

Result: `majority_blocked`, `VC_preserves` and `eternity_holds` all move
to **zero axioms**, and the ledger becomes uniform across the whole
development. The same lesson applied to `runTrace_sound`, whose original
proof used `simp only [runTrace, Option.some.injEq]`; `Option.some.injEq`
is itself proved *using* `propext`, and swapping it for the
`noConfusion`-based `Option.some.inj` made that theorem axiom-free too.

The experiment is reproducible by reverting the diff above.

## Consequences

- The development is now uniformly axiom-free, which is a stronger and
  simpler artifact: no `propext`, no `Quot.sound`, no `Classical.choice`,
  no `sorryAx`.
- **Nothing about the constitutional argument follows from axiom counts.**
  Any future prose in this repository that reaches for the
  attacks-are-cheaper moral is wrong, and this ADR is the reason.
- The honest reading is duller: this model is small and decidable
  throughout, so constructive proofs exist for everything in it. The
  uniformity is a fact about the toy.
- A methodological point worth keeping: `#print axioms` measures **the
  proof you wrote**, not the theorem you proved. Two proofs of the same
  statement can differ in axiom profile, so an axiom ledger is a
  regression tripwire — it detects change — and not a measure of
  mathematical depth. Compare [ADR-0002](0002-toolchain-pin.md), where the
  same number moved under a *toolchain* change with no source change at
  all.

## Why this is recorded rather than quietly fixed

The withdrawn reading is more memorable than the correct one and would
have survived indefinitely in a README. Recording the refutation with its
diff is the only thing that stops it coming back.
