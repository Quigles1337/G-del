# Roadmap

The instrument works. These are the things worth playing on it. Each
entry is phrased so that "did it work?" has a yes-or-no answer.

## Round 3 — on-chain governance, where `V` is executable

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

## Movement E candidates — defences not yet tested

Each is a small edit to `V` plus an attempted invariant. Cheap to try,
and a failure is as publishable as a success.

**The ratchet.** Permit `setRule` only when the new cost is **at least**
the old cost — the amendment rule may be made harder but never easier.
This directly targets Movement A's repricing, and unlike an entrenchment
clause it needs no self-reference. Open questions: does it defeat A alone?
Does it survive B without an entrenchment clause? Does the combination
ratchet + self-entrenchment buy anything over C? First thing to build.

**Temporal entrenchment.** Require an amendment to pass in *k* separate
sessions, or impose a delay. Adds real structure to `Reach`, which
currently has no notion of time, and models a defence that many real
constitutions actually use.

**Distributed recognition.** Replace the boolean `strictInterp` with
*k*-of-*n* recognizers. Does raising *k* raise the cost of Movement D, or
merely rename it? The most directly relevant to Round 3, since consensus
systems are exactly *k*-of-*n* recognizers.

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

- **ADR-0002's unresolved drift.** On Lean 4.33.0, 13 of 24 theorems
  acquire `propext` — precisely those touching a validity regime that
  contains an implication (`VB`, `VC`, `VD`), and none of those confined
  to `VA`. The characterization is airtight; the mechanism is unknown,
  and minimal reproductions of that exact shape do not drift. Good first
  issue: it needs patience with `set_option pp.all` and bisection over
  toolchains, not deep knowledge.
- **Is Movement B's two-step derivable in a model faithful to Article V's
  actual ratification requirements** (three-quarters of the states, two
  proposal routes)? The current model has no federal structure at all.
- **Can the ratchet be defeated?** If not, it would be the first defence
  in this repository that survives without self-reference, which is a
  meaningfully different kind of protection.

## Non-goals

- Claiming Gödel's actual argument has been recovered. It has not; nobody
  knows what it was. See SOURCES §1.
- Any formal reduction of Gödel II to the constitutional case.
  LIMITATIONS §7.
- Any claim about the likelihood of any of this. The model has no actors
  and cannot support one.
