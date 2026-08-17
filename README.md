# Gödel's Loophole, kernel-checked

[![verify](https://github.com/Quigles1337/G-del/actions/workflows/verify.yml/badge.svg)](https://github.com/Quigles1337/G-del/actions/workflows/verify.yml)
[![Lean](https://img.shields.io/badge/Lean-4.15.0-blue)](lean-toolchain)
[![axioms](https://img.shields.io/badge/axioms-zero-brightgreen)](Godel/Receipts.lean)
[![sorry](https://img.shields.io/badge/sorry-none-brightgreen)](scripts/verify.sh)

At his U.S. citizenship hearing on 5 December 1947, Kurt Gödel told
Einstein and Oskar Morgenstern — on the drive to Trenton — that he had
found an inconsistency in the Constitution allowing the United States to
become a dictatorship by entirely legal means. He began to make the
argument in front of the judge. He was talked down. He never wrote it up.

This repository is a **toy constitutional state machine** that makes the
shape of that argument precise, in four movements, entirely in core
Lean 4. No `mathlib`, no dependencies, no `sorry`, **zero axioms**.

The premise is Peter Suber's (*The Paradox of Self-Amendment*, 1990):
model a constitution as a formal system whose **rule of change is itself
an object-level provision**. Once you do that, "can this constitution be
turned into a dictatorship legally?" stops being a matter of opinion and
becomes a reachability question — with a yes or no.

## Quickstart

```bash
git clone https://github.com/Quigles1337/G-del.git && cd G-del
lake build       # kernel-checks everything AND enforces the axiom ledger
lake exe godel   # runs the attacks through the certified checker
```

Or check the single-file edition with no build system at all:

```bash
lean standalone/Godel.lean
```

Full local verification (build, run, standalone, `sorry` sweep):
`scripts/verify.sh` (or `scripts/verify.ps1` on Windows).

## The four movements

| | The system | Dictatorship | The result |
|---|---|---|---|
| **A** | Amendment rule is itself amendable | **reachable** | `loophole` |
| **B** | Entrenchment clause, not self-entrenched | **reachable** | `entrenchment_bypassed` |
| **C** | Self-entrenched eternity clause (Art. 79(3) shape) | **unreachable** | `eternity_holds` |
| **D** | C, but the *interpreter* is a state variable | **reachable** | `interpretation_attack` |

**A — the loophole.** `majority_blocked` first proves the wall works as
advertised: a 51-strength faction, given unlimited sessions, changes
*nothing*. Then `loophole` exhibits the trace `[67, 51]` — one
supermajority session touching **only** the amendment rule, procedurally
spotless, no right infringed on its face — after which a bare majority
finishes the job.

The point is not that a supermajority *could* have voted in tyranny
directly; it could, and `direct` proves it. The point is what the two
paths leave behind:

```lean
theorem direct_leaves_gate   : afterDirect.rule.cost   = 67 := rfl
theorem loophole_lowers_gate : afterLoophole.rule.cost = 51 := rfl
theorem decree_removes_gate  : afterDecree.rule.cost   = 0  := rfl
```

The direct path leaves tyranny repealable at cost 67. The loophole path
**reprices every future amendment, including the repeal**. It is an
attack on the immune system, not on the organ.

**B — a guard that does not guard itself.** `B_blocks_direct`: the clause
stops even a unanimous frontal assault. `entrenchment_bypassed`: two
moves — repeal the guard, walk through the door — and both steps are
valid under the rules in force when taken. This is not hypothetical.
Article V of the U.S. Constitution entrenches equal state suffrage in
the Senate and **does not entrench itself**; see [docs/SOURCES.md](docs/SOURCES.md).

**C — the defence that works.** Honesty first: the self-entrenched
eternity clause is **formally sound**, and we prove it before undermining
it. `eternity_holds` shows by invariant induction that under `VC`, no
trace of any strengths — unanimity, forever — reaches dictatorship. The
Grundgesetz's Art. 79(3) is not naive. It is a correct patch of the level
it patches.

**D — and the level it does not patch.** C's proof holds `V` fixed. In
the world, `V` is applied by institutions living *inside* the system:
courts, commissions, constituent assemblies. Movement D makes the
recognizer a state variable. The capture move is modelled as
always-available precisely because **no clause of the object text governs
it**. Then the epitaph:

```lean
theorem clause_still_there : afterCapture.eternity = true := rfl
```

Proof by reflexivity that the parchment survived its own irrelevance.
The eternity clause is in the final state, verbatim, uninfringed, and
load-bearing for nothing.

## The exploit is a program

`Godel/Executable.lean` does the same work mechanically. Every validity
regime is shown decidable, `runTrace` walks a trace refusing the first
illegal step, and:

```lean
theorem runTrace_sound {V} [∀ n s a, Decidable (V n s a)] :
    ∀ (tr : List Session) (s t : State),
      runTrace V s tr = some t → Reach V (tr.map Prod.fst) s t
```

If the checker accepts, a legal derivation **exists** — so acceptance is
a certificate, not a claim about one. `lake exe godel` therefore does not
narrate the attack, it executes it, and each `ADOPT` corresponds to a
theorem the kernel has already checked. Movement C's run is the one worth
watching: the checker *refuses* both doors at strength 100, and then
Movement D walks through the same door it just refused.

## The axiom ledger

`Godel/Receipts.lean` wraps every `#print axioms` in `#guard_msgs`, which
turns a printed claim into a **test**. If any proof ever starts leaning on
an axiom it did not lean on before — `sorryAx` included — the module
fails to compile and CI goes red. The receipt is load-bearing: tamper
with one expected line and the build breaks.

All 24 theorems depend on **zero axioms**. See [THEOREMS.md](THEOREMS.md).

### A negative result we are keeping

An earlier draft observed a pleasing asymmetry: the attacks came out
axiom-free while the defences needed `propext` (and `majority_blocked`
also `Quot.sound`). It read beautifully — breaking a constitution is an
existential witness you can hand someone, defending one is a universal
claim about an infinite space — and there was something darkly fitting
about the attacks being cheaper than the defence.

**It is false.** The asymmetry was an artifact of *tactic choice*, not of
logic. `simp` and `omega` are classical by construction; replacing three
of their uses with `Bool.noConfusion` and `Nat.le_trans` — changing no
theorem statement whatsoever — moves all three defences to zero axioms.
The experiment and the exact three-line diff are recorded in
[ADR-0003](docs/adr/0003-axiom-asymmetry-refuted.md) so anyone can re-run
it by reverting.

Nothing about the constitutional argument follows from axiom counts. We
would rather publish the dull true version than the pretty false one.

## Why the toolchain is pinned

`lean-toolchain` pins `leanprover/lean4:v4.15.0` exactly — never
`stable`. The sources compile on newer toolchains, but the **ledger does
not survive them**: on Lean 4.33.0, `entrenchment_bypassed`,
`interpretation_attack`, and `eternity_holds` each acquire `propext` from
identical source. (4.33.0 also renamed `List.mem_cons_self`'s arguments
to implicit; the proofs here use the `List.Mem` constructors instead, so
they are portable across both.) CI runs a non-blocking `drift-watch` job
against current stable as a canary. Details: [ADR-0002](docs/adr/0002-toolchain-pin.md).

There is a joke here that the repository did not plan. `#print axioms` is
this development's own validity predicate, and it is applied by an
institution the file cannot bind — the elaborator. Freeze the object
system and the exploit moves one level up. That is Movement D, and it
turned up in our own build logs. It is a rhyme, not a theorem.

## What is proven, and what is not

`eternity_holds` is a consistency certificate for system C, and it was
proved **here, in Lean** — a strictly stronger metasystem — not inside C.
The object system cannot even keep the certificate's hypotheses true;
that is exactly what Movement D demonstrates. The constitutional rhyme of
Gödel's second incompleteness theorem is precise: **consistency is
certified one level up, or not at all.**

So the conjecture resolves sharper than "no dictator-proof clause
exists." You *can* freeze any given level — C is a real result.
Dictator-proofness would require freezing *all* levels, and the tower —
text < amendment rule < recognition rule < social practice — does not
bottom out inside the law. What ultimately holds the invariant is the
thing this repository cannot formalize: the interpretive community's
disposition to keep reading the clause as binding.

This is a **toy**. It is four booleans and a scalar. It does not model
federalism, ratification, courts as agents, time, or who holds the pen.
Its honest boundaries are enumerated in
[docs/LIMITATIONS.md](docs/LIMITATIONS.md), including the places where a
reader could mistake a modelling choice for a result.

## Repository map

| Path | What it is |
|---|---|
| `Godel/Core.lean` | The object system: states, amendments, `Reach` |
| `Godel/MovementA–D.lean` | The four regimes and their theorems |
| `Godel/Executable.lean` | Decidable checker + soundness bridge |
| `Godel/Receipts.lean` | The axiom ledger, enforced by `#guard_msgs` |
| `Main.lean` | `lake exe godel` |
| `standalone/Godel.lean` | Single-file edition; `lean standalone/Godel.lean` |
| `THEOREMS.md` | Every theorem, glossed, with its axiom cost |
| `docs/ARGUMENT.md` | Long-form reading of the four movements |
| `docs/SOURCES.md` | Where the history and the law come from |
| `docs/LIMITATIONS.md` | What the model does not model |
| `docs/ROADMAP.md` | Round 3: on-chain governance |
| `docs/adr/` | Decisions, with the evidence behind them |

## Sources

The hearing, Morgenstern's memorandum, Suber on self-amendment,
Guerra-Pujol's reconstruction, Grundgesetz Art. 79(3), Weimar Art. 76 and
the Enabling Act, Hart's rule of recognition, and the modern
recognizer-capture cases are all cited in
[docs/SOURCES.md](docs/SOURCES.md), with the places we are *not* certain
marked as such.

## License

MIT — see [LICENSE](LICENSE).
