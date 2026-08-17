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

## Addendum — the drift is in elaboration, not upstream (probe, 2026-08-17)

Run when Movements E and F landed, to answer the open question above in
at least one direction. Method: a scratch file (not committed) running
`#print axioms` on the core lemmas these proofs actually invoke, executed
under both toolchains via `elan run` and diffed; then the library itself
rebuilt under 4.33.0; then a transitive dependency walk over the proof
terms. Both toolchains as reported by `lean --version`: 4.15.0
(`11651562caae`) and 4.33.0 (`d8b18978322d`).

### 1. The core lemmas do not differ

`of_decide_eq_true`, `decide_eq_true`, `decide_eq_true_eq`,
`of_decide_eq_false`, `eq_true`, the `And` and `Or` introduction and
elimination rules (`And.intro/left/right/elim/rec`,
`Or.inl/inr/elim/rec`), `Bool.noConfusion`, `Bool.noConfusionType`,
`Bool.decEq`, `Nat.le_trans`, `Nat.decLe`, `Nat.decEq`, `Nat.le`,
`List.mem_cons_self`, `List.Mem.head`, `List.Mem.tail`,
`Option.noConfusion`, `Option.noConfusionType`, `Option.some.inj`,
`Option.some.injEq`, `absurd`, `Eq.mpr/symm/trans/subst`, `id`,
`instDecidableAnd/Or/Not` — 37 constants, including every lemma named in
the breakages above and in [ADR-0003](0003-axiom-asymmetry-refuted.md).

**The two outputs are byte-identical.** Three of the 37 carry `propext`
on *both* versions (`decide_eq_true_eq`, `eq_true`, `Option.some.injEq`);
the other 34 are axiom-free on both. Nothing moved.

The derived instances the drifting proofs go through are identical too:
`instDecidableEqAmend`, `instDecidableEqState`, `instDecidableEqRule`,
`instDecidableEqBool`, `instDecidableNot` are axiom-free on both.

### 2. The ledger, remeasured on the larger development

The library was rebuilt from the committed source under 4.33.0, with
`Godel/Receipts.lean` excluded (its `#guard_msgs` are what the drift
breaks). Everything else — Movements A–F, the checker — compiles clean,
so the portability fixes still hold with E and F in.

**15 of the 43 ledger entries acquire `propext` on 4.33.0.** The original
13 reproduce exactly, name for name. The two new ones are Movement E's
`selfentrenched_gate_holds` and `selfentrenched_guards_no_content`.
Movement F does not drift at all: all 12 entries stay axiom-free.

### 3. Where the `propext` enters

A transitive walk over each theorem's proof term, collecting every
constant that cites `propext` directly:

| Theorem | 4.15.0 | 4.33.0 |
|---|---|---|
| `B_blocks_direct` | none (162 constants reached) | `eq_true`, `eq_false`, `and_self` (467) |
| `C_refuses_direct` | none (269) | `eq_true`, `eq_false`, `and_self` (515) |
| `selfentrenched_gate_holds` | none (166) | `eq_true`, `eq_false`, `and_self` (422) |
| `clause_ratchet_bypassed` | none (156) | none (173) |

`eq_true`, `eq_false` and `and_self` all exist on both toolchains and all
depend on `propext` on both. They are not new and they did not change.
The 4.33.0 elaborator simply routes through them, from identical syntax,
where 4.15.0 does not — and drags in roughly three times the dependency
closure doing it.

### 4. Verdict

**The drift is in elaboration, not upstream.** The core lemmas are
identical on both toolchains; the elaborator emits different terms from
the same source, and those terms reach `propext` through three ordinary
`Prop`/`Bool` simp lemmas that were always classical. This narrows the
open question from "where does `propext` come from?" — answered: `eq_true`,
`eq_false`, `and_self` — to "what changed in `decide`'s elaboration
between 4.15.0 and 4.33.0 such that it now normalizes through them?",
which this probe did not determine and did not try to fix.

### 5. A correction the probe forced

The structural explanation offered above — that the drift follows *an
implication with a `Bool` equation as antecedent* — **does not survive
Movement E.** Regime `VR` has exactly that shape
(`s.ratchet = true → ∀ r, ...`) and does **not** drift. Regime `VRS`
differs from `VR` only by adding `ratchetAttack a = false ∧` to the
consequent, and it **does** drift.

Across all 43 entries the predicate that currently fits every data point
is narrower: a theorem drifts when its regime's guard contains a
**`Bool`-valued equation on an attack predicate applied to the
amendment** — `coreAttack a = false` (`VB`, `VC`, `VD`),
`selfAttack a = false` (`VC`, `VD`), `ratchetAttack a = false` (`VRS`).
`VA`, `VE` and `VR` contain no such equation and none of their theorems
drift.

That is a better-fitting characterization, not a verified rule: it is
fitted to 43 points and has not been tested against a regime built to
falsify it. The lesson of ADR-0003 applies to this paragraph too.

The decision above is unchanged. The pin stands.
