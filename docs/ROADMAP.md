# Roadmap

The instrument works. These are the things worth playing on it. Each
entry is phrased so that "did it work?" has a yes-or-no answer.

Every defence this file proposed has now been played, and the tower
item closed with it (Movements E, F, G). What remains below is of two
kinds: **defences not yet tried**, which are cheap edits to `V` plus an
attempted invariant — and **realism**, which is a different and much
larger project. The register of a resolved entry is kept as written,
prediction and all, so the record shows what was expected before the
kernel answered. The commits are the timestamps: the Round 3 target and
the ratchet entry are in the initial commit, `ec9272c`, before
Movements E and F landed in `eef2d47`; the Movement G target is in
`c983f2d`, before Movement G landed in `5c10708`.

From 1.0.0 on, a new movement's prediction is committed on its own,
before any proof.

## Round 3 — on-chain governance, where `V` is executable — **resolved**

> **Resolved by Movement F** — `Godel/MovementF.lean`, with the registered
> target below (committed in `ec9272c`, before Movement F landed in
> `eef2d47`) hit as specified. Interpretive capture is not merely
> blocked but *inexpressible*: no transaction mentions the contract
> (`contract_inexpressible`), so `code_is_law` holds along every valid
> history and Movement D's interior attack is deleted rather than
> defended against. The fork goes through anyway — every world, every
> target, bare majority (`fork_always_open`) — and the epitaph survives in
> the shape this section asked for,
> `code_still_there : afterFork.orphan.contract = genesis.contract := rfl`.
> Rescue and coup are the same constructor (`the_dao_fork`,
> `the_coup_fork`): the kernel cannot tell them apart, and the layer that
> can is the layer performing them. Sharper than the target asked for,
> `canonical_history_invalid` shows that *no* valid on-chain path reaches
> the post-fork canonical world — the chain everyone uses is the one the
> code forbids. The conclusion is the one this section predicted:
> mechanizing the recognizer **relocates** the vulnerability to the fork
> choice rather than removing it.
>
> Naming note: the regimes delivered are `Vcode` (on-chain) and `VW`
> (world level); the `VE` named below is now Movement E's ratchet regime.
> Full record: [notes/landing-movements-ef.md](notes/landing-movements-ef.md).

The registered target, kept as written in the initial commit, `ec9272c`:

The natural next target, and the one this repository was built toward.

A DAO charter is a constitution whose validity predicate is **executable
code**. That looks like it dissolves Movement D outright: there is no
court to capture, because the recognizer is a machine that simply runs.
No interpretive community, no `strictInterp`, no gap between the text and
its application.

The dissolution does not survive one question: **who decides what counts
as the chain?**

The 2016 DAO fork was `setInterp false`, executed by social consensus
over the head of the code. The code did precisely what it said. A
community decided that what it said would not count, and the ledger on
which the contract had executed became the minority one. The recognizer
did not disappear when it was mechanized — it moved to the fork choice,
which is a social practice among validators and clients, exactly Hart's
rule of recognition wearing different clothes.

**Concrete formal target.** Add a state variable for which fork counts,
and a regime `VE` in which:

- amendment is governed by an on-chain rule (`V` is total, executable,
  and cannot be captured by interpretation — Movement D's move is
  genuinely blocked);
- but a `setChain` move exists, ungoverned by the contract, because no
  provision of the contract can bind the clients that decide which
  history is canonical.

Then attempt both:

```lean
theorem code_immune      : -- no trace under VE captures the recognizer
theorem fork_attack      : Reach VE [...] init afterFork
theorem code_still_there : afterFork.contract = init.contract := rfl
```

If `fork_attack` goes through with the epitaph intact, the conclusion is
that mechanizing the recognizer **relocates** the vulnerability rather
than removing it — and the toy will have said something non-obvious about
on-chain governance rather than merely restating Movement D. If it does
*not* go through, that is more interesting still: it would identify a
class of systems where the tower does bottom out.

A live constitutional DAO's amendment provisions are the natural test
case. Does the amendment article self-entrench? Who is the recognizer,
and what is the cost of capturing them? That is a real audit, not a toy.

## Movement G — the fork-guard regress — **resolved**

The target and its suspicion are kept as committed in `c983f2d`, before
Movement G landed in `5c10708`; the resolution follows them.

The natural successor to Movement F, and the item that would close the
tower if anything can.

Movement F leaves the fork ungoverned by design: no clause of any
contract binds the clients that decide which history is canonical. The
obvious repair is a **fork guard** — a constraint on when re-pointing
"the chain" is legitimate. Suspicion, worth falsifying: any such guard is
either the modeller's fiat, baked into the world-level regime where
nothing enacted can reach it (Movement E's first act, one level up), or a
piece of world state — in which case it is applied by the very recognizer
it would bind (Movement D, one level up). The guard has nowhere else to
live.

If that is right, the two asymmetries Movements E and F leave standing
are one asymmetry seen twice: the modeller can freeze a level and the
system cannot (E); the system is recognized and cannot recognize itself
(F).

**Concrete formal target.** A **no-self-recognition schema**: for any
regime whose recognition rule is itself part of the state it recognizes,
no guard expressible in that state constrains the recognition move.
Stating it cleanly is the whole difficulty. A negative — an expressible
class of guards that does bind — would be the more interesting outcome,
and would identify exactly where the tower bottoms out.

**Resolution (`Godel/MovementG.lean`).** Stated and proved, as a schema
over a first-class type of machines: `repoint_reaches_everything` — for
*every* machine, with zero hypotheses about it, every configuration is
one repoint from being in force at bare majority, by a one-constructor
proof that consults no field of the machine. The triviality of that
step is the finding, not a failure: it is the formal content of "the
guard is not consulted." The suspicion above is now two theorems: a
fork-guard in the world-level regime is the modeller's fiat (the
`ascend` operator itself), and a fork-guard in world state (`ascendG`)
is real, can be *sound* by exactly Movement C's argument
(`guarded_holds`) — and is furniture one floor up (`guard_regress`,
which is the schema applied to its own output). The "more interesting
negative" also landed, in refined form: an expressible class of guards
that binds *does* exist, and it binds only its own floor. The tower
bottoms out nowhere inside the mathematics — bounded below and above by
inexpressibility (F's contract cannot mention its repeal; no level's
law can mention its own being-in-force). Faithfulness pair
(`interior_faithful`, `interior_governed`) certifies the ascent is
conservative: not a strawman. The development closes.

## Defences tested

**The ratchet — resolved by Movement E**, and negatively, exactly as the
prediction in `Godel/MovementE.lean`'s header said it would be. That
prediction was written before the first compile, per the development
log, but committed with the proofs in `eef2d47`; what the initial
commit, `ec9272c`, timestamps is this entry's target and its three
questions, not the answer. Baked
into the validity regime, the gate holds forever (`regime_gate_holds`)
— and guards nothing else: dictatorship still arrives in one step at 67
(`regime_guards_nothing_else`). Written down honestly as a provision, a
`ratchet` bit of the state, it falls in three steps, `[67, 67, 0]`
(`clause_ratchet_bypassed`) — nothing guards the ratchet clause, which is
Movement B one level up. Self-entrench it and it does hold
(`selfentrenched_gate_holds`), by exactly Movement C's proof shape: its
sound form is not a new kind of defence but an instance of the old one,
inheriting C's externally-certified soundness and C's exposure to
Movement D.

The three questions this entry asked, answered. Does it defeat A alone?
Only as the modeller's fiat, which is not a resource a constitution has.
Does it survive B without an entrenchment clause? No. Does ratchet +
self-entrenchment buy anything over C? Nothing. The distance between
`regime_gate_holds` and `clause_ratchet_bypassed` is the distance between
physics and law.

## Defences not yet tested

Each is a small edit to `V` plus an attempted invariant. Cheap to try,
and a failure is as publishable as a success.

**Temporal entrenchment.** Require an amendment to pass in *k* separate
sessions, or impose a delay. Adds real structure to `Reach`, which
currently has no notion of time, and models a defence that many real
constitutions actually use.

**Distributed recognition.** Replace the boolean `strictInterp` with
*k*-of-*n* recognizers. Does raising *k* raise the cost of Movement D, or
merely rename it? Sharpened by Movement G rather than answered: any
*k*-of-*n* scheme is a `Machine`, so the schema applies to it wholesale
and the interesting question is now the *interior* one — whether
raising *k* changes anything **below** the repoint, which
`repoint_reaches_everything` does not address and cannot.

**External guarantor.** A second polity whose recognition is required.
Models treaty regimes and supranational courts. Suspicion, worth
falsifying: it relocates the recognizer rather than securing it.

## Model realism

Ordered by how much each would change the results.

1. **Actors and elections between sessions.** Currently `Reach` places no
   continuity requirement on coalitions. Adding one is the single change
   most likely to alter which attacks succeed, because it is where real
   constitutions get much of their protection. LIMITATIONS §2.
2. **Asymmetric rules — who holds the pen.** Would fix the known
   understatement of `loophole_decree`. LIMITATIONS §3.
3. **A derived rather than hand-written forbidden set.** LIMITATIONS §4.

## Open questions

- **ADR-0002's unresolved drift.** On Lean 4.33.0, identical source
  gives some theorems a `propext` dependency (13 of 24 when first
  measured; 15 of 43 at the Movements E–F snapshot). The probe recorded
  in ADR-0002's addendum settled the *location* — elaboration, not the
  core library: 37 core constants are byte-identical across both
  toolchains, while the drifting proofs reach `eq_true`/`eq_false`/
  `and_self` only on the newer one. It also **falsified** the original
  implication-shape characterization, using Movement E's own regimes:
  `VR` has exactly that shape and does not drift, `VRS` differs by one
  conjunct and does. A narrower predicate fitting all current points is
  recorded and explicitly flagged as *fitted, not verified* — falsifying
  it is the next move, and Movement F (which does not drift at all) is
  the obvious control. Good first issue: it needs patience with
  `set_option pp.all` and bisection over toolchains, not deep knowledge.
- **Restore Movement G's portability on current stable.** Since
  Movement G landed, `Godel/MovementG.lean` fails to compile on Lean
  4.33.0 and on 4.35.0 — an internal `mkElimApp` error at its three
  `induction` sites on `MReach` at a defined machine — so `drift-watch`
  no longer reaches the ledger and ADR-0002's decision 4 is unmet. The
  evidence is recorded inline in ADR-0002, addendum 2. Target, after
  1.0.0 and in its own PR: Movement G compiles on current stable, no
  theorem statement changes, and the pinned-toolchain ledger is still at
  zero axioms. It may be an upstream Lean regression rather than a
  defect in the source: worth minimizing, and reporting if the minimal
  case reproduces.
- **Is Movement B's two-step derivable in a model faithful to Article V's
  actual ratification requirements** (three-quarters of the states, two
  proposal routes)? The current model has no federal structure at all.

## Non-goals

- Claiming Gödel's actual argument has been recovered. It has not; nobody
  knows what it was. See SOURCES §1.
- Any formal reduction of Gödel II to the constitutional case.
  LIMITATIONS §7.
- Any claim about the likelihood of any of this. The model has no actors
  and cannot support one.

## Remaining

**Prose wrap — done.** The narrative documents now carry all seven
movements: README (the movement table, the E/F/G readings, the drift
section corrected), `docs/ARGUMENT.md` (three new long-form sections and
a closing on where the tower ends), `docs/LIMITATIONS.md` (§§11–12 for
Movement F's compression of 2016 and Movement G's lift, §5 and §8
amended), and ADR-0001 (an append-only addendum scoping decision 1 to
A–D and recording that the model shape survived three extensions
unamended).

**What is genuinely open** is listed above: the defences not yet tried,
the realism items in the order they would change results, and the drift
question — now sharper, having had its first explanation falsified.
