# Gödel's Loophole, kernel-checked

[![verify](https://github.com/Quigles1337/G-del/actions/workflows/verify.yml/badge.svg)](https://github.com/Quigles1337/G-del/actions/workflows/verify.yml)
[![Lean](https://img.shields.io/badge/Lean-4.15.0-blue)](lean-toolchain)
[![axioms](https://img.shields.io/badge/axioms-zero-brightgreen)](Godel/Receipts.lean)
[![sorry](https://img.shields.io/badge/sorry-none-brightgreen)](scripts/verify.sh)
[![license](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-blue)](LICENSE)

At his U.S. citizenship hearing on 5 December 1947, Kurt Gödel told
Einstein and Oskar Morgenstern — on the drive to Trenton — that he had
found an inconsistency in the Constitution allowing the United States to
become a dictatorship by entirely legal means. He began to make the
argument in front of the judge. He was talked down. He never wrote it up.

This repository is a **toy constitutional state machine** that makes the
shape of that argument precise, in seven movements, entirely in core
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
lake exe godel   # runs Movements A–D through the certified checker
```

Or check the single-file edition with no build system at all:

```bash
lean standalone/Godel.lean
```

Full local verification (build, run, standalone, `sorry` sweep, parity,
one receipt per theorem):
`scripts/verify.sh` (or `scripts/verify.ps1` on Windows).

## The seven movements

| | The system | The guarded thing | Flagship |
|---|---|---|---|
| **A** | Amendment rule is itself amendable | **repriced** — and the repeal with it | `loophole` |
| **B** | Entrenchment clause, not self-entrenched | **falls in two** | `entrenchment_bypassed` |
| **C** | Self-entrenched eternity clause (Art. 79(3) shape) | **holds, forever** | `eternity_holds` |
| **D** | C, but the *interpreter* is a state variable | **outlived — survives as ink** | `interpretation_attack` |
| **E** | The gate may only rise, written as a clause | **falls in three** | `clause_ratchet_bypassed` |
| **F** | Code is law; the amendment verb does not exist | **outlived — survives as a running program** | `canonical_history_invalid` |
| **G** | Any machine whatsoever, one level up | **swapped wholesale, always** | `repoint_reaches_everything` |

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

**E — the ratchet.** The procedural hope: a rule that the amendment
threshold may rise but never fall. Written into the validity regime
itself (`VE`) it holds perfectly — and guards nothing else, because it
lives where no amendment lives. Written honestly, as a `ratchet` bit of
the state, it dies in three moves — `clause_ratchet_bypassed`, trace
`[67, 67, 0]`: repeal the clause, reprice to decree, finish at strength
zero. Movement B, one level up. Self-entrenched (`VRS`) it holds by
exactly C's proof, which is the finding: procedure-space hides no new
kind of defence, only Movement C with a procedural payload, Movement
D's appetite included. The gap between the first act and the second is
the gap the whole development keeps finding: **the modeller can freeze
a level; the system cannot.**

**F — the fork.** The executable recognizer, given its full due first:
on-chain, `contract_inexpressible` — no transaction so much as
*mentions* the contract. Movement D's capture move is not blocked in
this language; it does not exist in it, and `code_is_law` is a theorem.
It is the whole story only until someone forks. The 2016 trace replays
as `the_dao_fork`, `[0, 51]`: the drain is **valid** (strength zero —
the code does not count votes), on-chain repair is **impossible**
(`no_onchain_repair` — the language has no `refund` verb either), and
the rescue is a fork licensed by nothing on any chain. Then the
epitaphs:

```lean
theorem code_still_there : afterFork.orphan.contract = genesis.contract := rfl
theorem canonical_history_invalid : ¬ ReachC genesis bailout
```

Movement D's clause survived as ink. The orphaned contract survives as
a **running program** — deployed, enforcing, satisfying every safety
theorem above, for whoever is still listening. And no valid on-chain
history reaches the canonical state: **the chain everyone uses is the
one the code forbids.** Rescue-fork and coup-fork are the same
constructor with different arguments; the kernel cannot tell them
apart, and the layer that can is the layer performing them.

**G — the regress.** The question the six were instances of. `Machine`
abstracts the whole development — any state space, any move language,
any validity law — and `ascend M` puts a machine's entire configuration
into one field of the floor above, where interior moves obey `M`'s law
verbatim and a `repoint` swaps the field at bare majority:

```lean
theorem repoint_reaches_everything (M : Machine) (w : LWorld M) (s' : M.S) :
    MReach (ascend M) [51] w { inForce := s', orphan := w.inForce } :=
  .step (.repoint s') (Nat.le_refl 51) .nil
```

Every machine, zero hypotheses, one constructor consulting no field of
`M`. The triviality is load-bearing: it is "the guard was not
consulted," formalized — a hard proof would have meant the guard put up
a fight. The faithfulness pair (`interior_faithful`,
`interior_governed`) certifies the ascent is conservative, so the floor
above is no strawman; the guarded ascent (`ascendG`) shows
fork-legitimacy criteria are real, can be **sound** by exactly C's
argument (`guarded_holds`) — the trilemma is level-invariant — and are
furniture one floor up (`guard_regress`, the schema applied to its own
output). The closing pair is the development in two lines:
`eternity_holds_upstairs` and `eternity_meta_defeated` — Movement C's
certificate survives the ascent intact, and one repoint puts tyranny in
force anyway. `eternity_holds` remains true forever. **It is a theorem
about the orphan.** What the schema does not prove is that
self-recognition is false; it proves it is **inexpressible**. The
development is bounded at both ends by inexpressibility: at the bottom,
the code cannot speak of its replacement; at the top, no law can speak
of its own being in force.

## The exploit is a program

For Movements A–D, `Godel/Executable.lean` does the same work
mechanically. Each of their validity regimes is shown decidable,
`runTrace` walks a trace refusing the first illegal step, and:

```lean
theorem runTrace_sound {V} [∀ n s a, Decidable (V n s a)] :
    ∀ (tr : List Session) (s t : State),
      runTrace V s tr = some t → Reach V (tr.map Prod.fst) s t
```

If the checker accepts, a legal derivation **exists** — so acceptance is
a certificate, not a claim about one. `lake exe godel` runs those
movements through `runTrace` itself: every state it prints is
`runTrace V init` applied to a prefix of the trace, on exactly the traces
of `loophole_runs`, `bypass_runs`, `C_refuses_direct`,
`C_refuses_selfrepeal` and `capture_runs`. The printout is compiled
output, not a proof; the certificates are those theorems, and the run
shows what they are about. Movement C gets two runs, one per door, and
they are the ones worth watching: the checker *refuses* the frontal
assault at strength 100, then refuses the repeal of the clause itself at
strength 100 — and then Movement D, having captured the recognizer,
walks through the frontal door at 67. Movements E–G have no checker;
their results are the theorems in [THEOREMS.md](THEOREMS.md).

## The axiom ledger

`Godel/Receipts.lean` wraps every `#print axioms` in `#guard_msgs`, which
turns a printed claim into a **test**. If any proof ever starts leaning on
an axiom it did not lean on before — `sorryAx` included — the module
fails to compile and CI goes red. The receipt is load-bearing: tamper
with one expected line and the build breaks.

All 56 theorems depend on **zero axioms**. See [THEOREMS.md](THEOREMS.md).

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
`stable`. The sources are kept portable — Movements A–F and the checker
compile on newer toolchains; **Movement G currently does not**, which
[ADR-0002](docs/adr/0002-toolchain-pin.md) records as an open defect —
but the **ledger does not survive them**: on Lean 4.33.0, **13 of the 24
theorems then in the development acquire `propext`** from identical
source.

The split is not scattered — every drifting theorem touches `VB`, `VC`,
`VD`, or (15 of 43 at the Movements E–F snapshot) Movement E's `VRS` —
but the tidy structural story did not survive contact with the probe.
ADR-0002's addendum locates the drift in **elaboration**, not the core
library: 37 core constants are byte-identical across the two
toolchains, while identical source reaches `propext`-backed lemmas only
on the newer one. And the implication-shape characterization is
**falsified by Movement E's own regimes** — `VR` has exactly the
suspected shape and does not drift; `VRS` differs from it by one
conjunct and does. A narrower predicate fitting all current points is
recorded, flagged as fitted rather than verified. Still open — now
sharper. Movement F, for what it is worth, does not drift at all: the
movement about being at the mercy of one's recognizer is the one both
recognizers agree on completely.

CI runs a non-blocking `drift-watch` job against current stable as a
canary, and it paid for itself on the first run by catching a
portability break (`Option.noConfusion` cannot infer its motive on 4.33+;
the proof now uses `nomatch`). Details: [ADR-0002](docs/adr/0002-toolchain-pin.md).

There is a joke here that the repository did not plan. `#print axioms` is
this development's own validity predicate, and it is applied by an
institution the file cannot bind — the elaborator. Freeze the object
system and the exploit moves one level up. That is Movement D, and it
turned up in our own build logs.

Movement G makes the joke exact without making it a claim. The ledger is
a guard in world state; the elaborator is the recognizer that applies
it; and the toolchain pin is a fork-legitimacy criterion, enforced by
convention outside every file it protects. `guard_regress` is the
general shape of what a version bump does to us. That is an instance of
the schema, not evidence for it — but it is the one instance we did not
choose, and it arrived by itself.

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

Movements E–G finish the sentence. The two asymmetries the middle
movements leave standing — the modeller can freeze a level and the
system cannot (E); the system can be recognized and cannot recognize
itself (F) — are one asymmetry seen twice, and Movement G states it as
a schema over every machine at once, its own outputs included. One
floor above the schema sits this repository: `ascend` is the modeller's
pen, necessarily, and its licence comes from the reader agreeing that
this is what recognition is like. The kernel certifies the theorems;
the community certifies the kernel; the community is not a machine in
any file. **The tower exits the mathematics through the reader.** It
always did.

This is a **toy**. Its constitution is four booleans and a scalar, and
its final movement quantifies over every machine you could put in
their place. It still does not model
federalism, ratification, courts as agents, time, or who holds the pen.
Its honest boundaries are enumerated in
[docs/LIMITATIONS.md](docs/LIMITATIONS.md), including the places where a
reader could mistake a modelling choice for a result.

## Repository map

| Path | What it is |
|---|---|
| `Godel/Core.lean` | The object system: states, amendments, `Reach` |
| `Godel/MovementA–G.lean` | The seven movements and their theorems |
| `Godel/Executable.lean` | Decidable checker + soundness bridge |
| `Godel/Receipts.lean` | The axiom ledger, enforced by `#guard_msgs` |
| `Main.lean` | `lake exe godel` |
| `standalone/Godel.lean` | Single-file edition; `lean standalone/Godel.lean` |
| `THEOREMS.md` | Every theorem, glossed, with its axiom cost |
| `scripts/` | `verify.sh` / `verify.ps1` (full verification), `check-parity.sh`, `check-receipts.sh` (one receipt per theorem) |
| `CHANGELOG.md` | What changed in each release |
| `CITATION.cff` | Citation metadata; see [How to cite](#how-to-cite) |
| `docs/ARGUMENT.md` | Long-form reading of the seven movements |
| `docs/SOURCES.md` | Where the history and the law come from |
| `docs/LIMITATIONS.md` | What the model does not model |
| `docs/ROADMAP.md` | Closed through Movement G; what remains |
| `docs/adr/` | Decisions, with the evidence behind them |

## Sources

The hearing, Morgenstern's memorandum, Suber on self-amendment,
Guerra-Pujol's reconstruction, Grundgesetz Art. 79(3), Weimar Art. 76 and
the Enabling Act, Hart's rule of recognition, and the modern
recognizer-capture cases are all cited in
[docs/SOURCES.md](docs/SOURCES.md), with the places we are *not* certain
marked as such.

## Provenance

Alexander David Zalewski is the project's creator and architect. He
designed its formal development and verified its proofs in Lean 4.

Development was AI-assisted (Claude, by Anthropic). The AI is not
listed as an author in [CITATION.cff](CITATION.cff); commit trailers are
how its involvement is disclosed. Before 1.0.0 that disclosure is
inconsistent: the first three commits carry a `Co-Authored-By` trailer,
and the commits that landed Movements E–G do not, although that work was
AI-assisted too ([docs/notes/](docs/notes/) records how it was handed
off). From 1.0.0 on, every commit made with AI assistance carries the
trailer.

None of this bears on whether the proofs are valid. Every theorem is
checked by the Lean kernel, and every axiom claim is a build-breaking
test, so the results stand or fall by the same check whoever wrote them
— and anyone can run it. With [elan](https://github.com/leanprover/elan)
installed (it fetches the toolchain pinned in `lean-toolchain` on first
use):

```bash
git clone https://github.com/Quigles1337/G-del.git && cd G-del
bash scripts/verify.sh          # on Windows: pwsh scripts/verify.ps1
```

That script kernel-checks every theorem on the pinned toolchain, fails
if any proof's axiom dependencies differ from its receipt in
`Godel/Receipts.lean` (`sorryAx` included), checks the single-file
edition, sweeps the sources for `sorry`, checks that both editions
declare the same theorem names, and checks that every theorem has
exactly one receipt. The single-file edition also checks on
its own, with no build system: `lean standalone/Godel.lean`.

What the kernel does not check is whether each theorem says what its
English gloss says. That part is the reader's: [THEOREMS.md](THEOREMS.md)
glosses every theorem by name, beside the file that states it, and
[docs/LIMITATIONS.md](docs/LIMITATIONS.md) lists where a modelling
choice could be mistaken for a result.

## How to cite

Cite the release, not the branch. [CITATION.cff](CITATION.cff) carries
the metadata, and GitHub's "Cite this repository" button reads it:

> Zalewski, A. D. (2026). *Gödel's Loophole, kernel-checked* (Version
> 1.0.0) [Computer software]. https://github.com/Quigles1337/G-del

A DOI will be added here once the release is archived.

## License

Copyright 2026 Alexander David Zalewski.

The whole repository — code and documentation — is licensed under the
[PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0)
(SPDX `PolyForm-Noncommercial-1.0.0`); the full text is in
[LICENSE](LICENSE).

In plain terms: anyone may use, modify, and redistribute this work for
research, teaching, and other noncommercial purposes. Commercial use is
not permitted. This summary is a convenience, not a grant — the
[LICENSE](LICENSE) text governs.
