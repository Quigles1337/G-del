# ADR-0002 — Pin the toolchain exactly; never track `stable`

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

The repository's headline property is not just "it compiles" but "here
is exactly what it depends on" — the axiom ledger in
`Godel/Receipts.lean`. That ledger is only meaningful if the thing
producing it is fixed.

Two independent breakages were observed while setting the repository up,
both by direct experiment on Lean 4.15.0 and 4.33.0.

### Breakage 1 — `List.mem_cons_self` changed arity

On 4.33.0 the explicit-argument form fails:

```
error: Function expected at List.mem_cons_self
  but this term has type ?m ∈ ?m :: ?m
```

Worse than a build failure: the error recovery injected `sorryAx` into
`majority_blocked`'s axiom set, so a *silent weakening* was one ignored
error away.

**Fixed forward, portably.** The proofs now use the `List.Mem`
constructors directly — `List.Mem.head` and `List.Mem.tail` — instead of
the named lemmas. Constructors are stable across both toolchains, and the
sources now compile on 4.15.0 and 4.33.0 alike.

### Breakage 2 — the axiom ledger does not survive the version bump

This one cannot be fixed forward, and it is the reason for the pin. From
**identical** source, after the portable fix:

| Theorem | 4.15.0 | 4.33.0 |
|---|---|---|
| `entrenchment_bypassed` | none | `[propext]` |
| `interpretation_attack` | none | `[propext]` |
| `eternity_holds` | none | `[propext]` |
| everything else | none | none |

The uniform zero-axiom result — the thing THEOREMS.md and the README
claim — holds **only on the pinned toolchain**.

**The cause was investigated and not isolated.** Minimal reproductions of
each suspected shape were built and run on both toolchains, and none
exhibited the drift:

- `decide` on a bare `Nat` comparison, on a `Bool` equation, on a
  conjunction, on an implication, and on a conjunction-with-implication;
- `decide` on a projection of a structure-update (`{ base with a := false }`);
- an implication with a false antecedent over such a projection.

All returned "does not depend on any axioms" on both versions. So the
drift is real, reproducible in situ, and not explained by the obvious
candidates. It is recorded as an open question rather than guessed at.

## Decision

1. `lean-toolchain` pins **`leanprover/lean4:v4.15.0`** exactly. Never
   `stable`, never a floating channel. A floating toolchain would turn
   every upstream release into an unreviewed change to this repository's
   central claim.
2. CI's gating job uses the pinned toolchain only.
3. CI additionally runs a **non-blocking `drift-watch` job** against
   current stable. It is a canary, not a gate: red there means the drift
   is still present or has changed shape, and is a prompt to look, not to
   block a merge.
4. Sources are kept portable anyway (breakage 1's fix), so that raising
   the pin later is an ADR decision rather than a rewrite.

## Consequences

- The ledger is trustworthy *as a regression tripwire on a fixed
  toolchain*, which is what it is for.
- No claim is made — and none should be read — that the axiom profile is
  intrinsic to the proofs. It is not; see also
  [ADR-0003](0003-axiom-asymmetry-refuted.md), where the profile turned
  out to be sensitive to tactic choice as well as to toolchain.
- Raising the pin requires re-running the ledger and updating
  `Godel/Receipts.lean` deliberately, which is exactly the friction
  wanted.

## Open question

Why do those three theorems acquire `propext` on 4.33.0 when isolated
reproductions of their shape do not? Unresolved. A good first issue.
