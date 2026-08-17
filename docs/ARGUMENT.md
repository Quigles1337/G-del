# The argument, at length

The README states the results. This is the reading.

## Why formalize first

The tempting order is to argue about defences and then, maybe, formalize
the winner. That order is backwards, and the reason is not rigour for its
own sake.

If the state machine is built **first**, then every proposed defence
becomes a *modification to the transition relation*, and "does this
defence work?" stops being a matter of taste and becomes a theorem with a
yes or a no. The machine is the instrument. Movements A–D are not the
finding; they are the demonstration that the instrument plays.

That framing also disciplines the author. Building Movement C forced a
conjecture to be abandoned — the prediction going in was that no
dictator-proof clause exists, and that prediction is **wrong**, provably.
An argument would have let it survive. A proof did not.

## A — the loophole

Regime `VA` says: anything a sufficiently strong coalition adopts is
valid. The amendment rule constrains *how*, never *what*, and — the whole
point — it does not exempt itself from its own procedure.

Begin with the wall, honestly. `majority_blocked` proves that under a
supermajority gate, a coalition of strength ≤ 66 changes **nothing**,
across any number of sessions, forever. The Framers' wall is real and the
formalization confirms it rather than assuming it away.

Then `loophole`, the trace `[67, 51]`:

1. A supermajority amends **only the amendment rule**. Nothing
   substantive. No right infringed on its face. A procedural
   housekeeping measure.
2. A bare majority does everything else.

Each step is valid under the rules in force at the moment it is taken.
There is no illegal step to point at.

Now the part that makes it worth the name. A supermajority could always
have voted in tyranny directly — `direct` proves it in one step. So why
is the two-step the sinister one? Because of what each leaves behind:

```lean
theorem direct_leaves_gate   : afterDirect.rule.cost   = 67 := rfl
theorem loophole_lowers_gate : afterLoophole.rule.cost = 51 := rfl
theorem decree_removes_gate  : afterDecree.rule.cost   = 0  := rfl
```

The direct path installs tyranny and leaves it **repealable at cost 67**.
The loophole path reprices *every future amendment* — including the
repeal of the tyranny — at 51, or with `loophole_decree`, at 0.

The attack is on the immune system, not the organ. That is the shape
worth naming, and it is why Weimar's Article 76 — amendment by two-thirds
with no substantive limits, the exact regime `VA` — matters more to the
history than any single substantive decree did.

## B — a guard that does not guard itself

Add the obvious patch: a clause forbidding the installation of
dictatorship or the abolition of free elections, binding even
supermajorities.

It works against the frontal assault. `B_blocks_direct` shows that not
even strength 100 can adopt the forbidden amendment. This is a real
protection and it should be credited.

And `entrenchment_bypassed` walks around it in two moves: repeal the
guard, then walk through the open door. Both steps valid, because the
guard is an ordinary provision and nothing guards it.

This is not an invented weakness. Article V of the U.S. Constitution
entrenches equal state suffrage in the Senate and **does not entrench
itself**. The configuration in Movement B is the configuration in the
document.

## C — the defence that works

Movement C is where honesty is expensive, and it is the reason to trust
the rest.

Grundgesetz Art. 79(3), written in 1949 by people who had just watched
Article 76 be used as designed, protects the core provisions **and
itself**. Regime `VC` adds `selfAttack` to the forbidden set: the clause
covers its own repeal.

`eternity_holds` proves, by invariant induction, that no trace of any
strengths — unanimity, forever, any length — reaches dictatorship under
`VC`. Not "unlikely". Unreachable.

**Self-entrenchment is formally sound. Germany is not naive.** The going-in
conjecture that no dictator-proof clause exists is false, and it had to
be proved false before anything else could be said.

## D — the level the defence does not reach

`eternity_holds` holds `V` fixed. That is a hypothesis, and in the world
it is a hypothesis about people. `V` is not self-executing: it is applied
by institutions living *inside* the system — courts, commissions,
constituent assemblies.

Regime `VD` makes the recognizer a state variable: `strictInterp` records
whether the recognizing institutions read the clause as binding.
Crucially, changing it is modelled as **always available, at any
strength, including zero** — not because capture is easy, but because no
clause of the object text governs it. The capture move is not an
Article-V amendment at all. That is the point. "A new constitution is not
an amendment to the old" is the doctrine, and it is doctrine precisely
because the amendment rule has nothing to say about it.

While the recognizer is faithful, D behaves exactly like C:
`D_blocks_while_strict` shows strength 100 still fails. Then
`interpretation_attack` reaches dictatorship on the trace `[0, 67]`.

And the epitaph:

```lean
theorem clause_still_there : afterCapture.eternity = true := rfl
```

The eternity clause is in the final state of the successful attack.
Verbatim. Uninfringed. Load-bearing for nothing. Proof by reflexivity
that the parchment survived its own irrelevance — the machine can compute
that the text is still there, which is exactly all that being still there
is worth.

## The Gödel II rhyme, stated exactly

`eternity_holds` is a **consistency certificate for system C**, and it
was proved *here*, in Lean — a strictly stronger metasystem — not inside
C. System C cannot conduct that proof about itself. Worse: system C's own
resources, which is what Movement D formalizes, cannot even keep the
certificate's **hypotheses** true.

A constitution can no more secure its own interpretation than a theory
can prove its own consistency. Consistency is certified one level up, or
not at all.

Two disciplines about that sentence. First, it is a **rhyme, not a
reduction** — there is no diagonalization here, no arithmetic, no
self-referential sentence, no incompleteness theorem. Nobody should cite
this repository for the claim that Gödel's theorem applies to law
(LIMITATIONS §7). Second, the structural parallel is nevertheless exact
and mechanically checkable, which is more than the usual invocation of
Gödel in a legal argument can say.

## What the conjecture becomes

Not "no dictator-proof clause exists." That is false, and C proves it
false.

Instead: **you can freeze any given level, and freezing all of them is
not something a text can do.** The tower runs

> text < amendment rule < recognition rule < social practice

and it does not bottom out inside the law. Each defence is a correct
patch of the level it patches; the exploit moves up one.

What ultimately holds the invariant is the thing this repository cannot
formalize, and says so: the interpretive community's disposition to keep
reading the clause as binding. Dictator-proofness is a property of a
community, not of a document.

Which is, in the end, the practical conclusion — and the uncomfortable
one, because it is not amenable to drafting.
