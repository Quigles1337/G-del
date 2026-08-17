# ADR-0002 — Pin the toolchain exactly; never track `stable`

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

The repository's headline property is not just "it compiles" but "here
is exactly what it depends on" — the axiom ledger in
`Godel/Receipts.lean`. That ledger is only meaningful if the thing
producing it is fixed.

Three independent breakages were observed, all by direct experiment on
Lean 4.15.0 and 4.33.0 — the third of them caught by CI rather than by
inspection.

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

### Breakage 2 — `Option.noConfusion` loses its motive

Found by the `drift-watch` canary on its first CI run, which is the
justification for having it. `Godel/Executable.lean` used
`exact Option.noConfusion h` to discharge `h : none = some t`. On 4.33+
the elaborator cannot infer the motive when the goal is a `Prop`:

```
Application type mismatch: the argument h has type Eq.{1} none (some t)
but is expected to have type Eq.{?u.32 + 2} ?m.121 ?m.123
```

**Fixed forward, portably:** `nomatch h`. Compiles on both toolchains and
does not change the axiom profile on either.

### Breakage 3 — the axiom ledger does not survive the version bump

This one cannot be fixed forward, and it is the reason for the pin. From
**identical** source, after the two portability fixes above, 13 of the 24
theorems acquire `propext` on 4.33.0:

| | axiom-free on 4.33.0 | acquires `propext` on 4.33.0 |
|---|---|---|
| | `direct`, `loophole`, `loophole_decree`, `loophole_runs`, `loophole_certified`, `majority_blocked`, `runTrace_sound`, `direct_leaves_gate`, `loophole_lowers_gate`, `decree_removes_gate`, `clause_still_there` | `B_blocks_direct`, `entrenchment_bypassed`, `bypass_runs`, `bypass_certified`, `VC_preserves`, `eternity_holds`, `C_refuses_direct`, `C_refuses_selfrepeal`, `D_blocks_while_strict`, `interpretation_attack`, `capture_runs`, `capture_certified`, `D_refuses_direct_while_strict` |

The uniform zero-axiom result — the thing THEOREMS.md and the README
claim — holds **only on the pinned toolchain**.

#### The drift is exactly characterized, and still unexplained

The split is not scattered. It falls on a single line, with no
exceptions in either direction:

> **Every theorem that drifts touches `VB`, `VC`, or `VD`. Every theorem
> that does not drift is confined to `VA`, is proved by `rfl`, or is
> generic in the regime.**

And the one structural difference between the regimes is that `VA` is a
plain disjunction —

```lean
def VA (n : Nat) (s : State) (a : Amend) : Prop :=
  a = .skip ∨ n ≥ s.rule.cost
```

— while `VB`, `VC` and `VD` each contain an **implication with a `Bool`
equation as antecedent** (`s.eternity = true → ...`). Deciding or
destructing such a regime is what costs `propext` on 4.33.0 and does not
on 4.15.0.

That is a clean empirical characterization. It is **not** an explanation,
and the mechanism was not isolated. Minimal reproductions of the very
shape the characterization points at were built and run on both
toolchains, and **none** drifted:

- `decide` on a bare `Nat` comparison, a `Bool` equation, a conjunction,
  an implication, and a conjunction-with-implication;
- `decide` on a projection of a structure-update (`{ base with a := false }`);
- an implication with a false antecedent over such a projection.

All returned "does not depend on any axioms" on both versions. So the
drift needs something about how the `Decidable` instance for these
implications is synthesized *in context* that the isolated cases do not
reproduce. Recorded as an open question rather than guessed at.

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
4. Sources are kept portable anyway (the fixes to breakages 1 and 2), so
   that raising the pin later is an ADR decision rather than a rewrite,
   and so that `drift-watch` reports the *ledger* rather than being
   swamped by compile errors.

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

Why does deciding or destructing a validity regime that contains an
implication cost `propext` on 4.33.0, when isolated reproductions of that
exact shape do not? The characterization is airtight and the mechanism is
unknown. A good first issue: it needs patience with `set_option pp.all`
and bisection over toolchains, not deep knowledge.
