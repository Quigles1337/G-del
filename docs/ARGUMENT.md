# The argument, at length

The README states the results. This is the reading.

## Why formalize first

The tempting order is to argue about defences and then, maybe, formalize
the winner. That order is backwards, and the reason is not rigour for its
own sake.

If the state machine is built **first**, then every proposed defence
becomes a *modification to the transition relation*, and "does this
defence work?" stops being a matter of taste and becomes a theorem with a
yes or a no. The machine is the instrument. The movements are not the
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

## E — the ratchet, or the modeller's pen

The first four movements attack and defend *content*. Movement E asks
whether *procedure* hides a new kind of defence: a rule that the
amendment threshold may rise but never fall. The loophole is a
repricing attack; forbid downward repricing and the loophole dies.

Three acts. In the first, the ratchet is written into the validity
regime itself — `VE` — and it works perfectly: `regime_gate_holds`
proves the gate never falls, under any trace, forever. But look where
the rule lives. Not in the state; in `V`. No amendment can reach it
because no amendment can reach *anything* in `V`. That is not
constitutional drafting; it is the modeller's pen — physics, not law.
And `regime_guards_nothing_else` collects the fee: the gate is eternal
and dictatorship is still one supermajority away. Price is not content.

The second act writes the ratchet honestly, as a provision: a `ratchet`
bit of the state that `VR` consults. It dies in three moves —
`clause_ratchet_bypassed`, trace `[67, 67, 0]`: repeal the ratchet
clause, reprice to decree, finish at strength zero. Movement B, one
level up. A guard that does not guard itself is a two-step no-op, and
it does not matter whether the thing it guards is a right or a
threshold.

The third act self-entrenches the repair, `VRS`, and it holds — by
exactly Movement C's proof, invariant induction and all
(`selfentrenched_gate_holds`). Which is the finding: **this is not a
new defence.** It is Movement C with a procedural payload, and it
inherits everything — C's soundness, C's externally-proved certificate,
and Movement D's appetite, since `strictInterp` is already sitting in
the state, waiting.

So procedure-space contains no third thing. Unguarded procedural rules
are Movement B; self-guarded ones are Movement C; all of them answer to
Movement D, under its capture premise. And the gap between the first act and the second — the rule
as regime versus the rule as clause — is the gap the whole development
keeps finding: **the modeller can freeze a level; the system cannot.**

## F — the fork, or the recognizer perfected

A DAO charter looks like the way out of Movement D: make `V`
*executable*. If the recognizer is a machine running bytecode, there is
no discretion to capture, no court to lean on, no `strictInterp` to
flip.

Honesty first, because the steelman is stronger than its critics allow.
On the chain, `Vcode` achieves what no regime in Movements A–E could:
`contract_inexpressible` proves that no transaction changes the
contract — the language has no verb for it. Not guarded —
**unguardable**, because immutability here is the absence of the verb. Movement D's capture move
is not blocked in this language; it does not exist in it. `code_is_law`
is true along every valid history, and `promise_holds_without_fork`
completes the picture: delete the fork and the promise holds at the
world level too. Within its frame, code-is-law is a theorem — and now
it is *their* theorem, kernel-checked, sitting at the top of the file
where it belongs.

Then 2016, replayed. The treasury drains through a reentrancy bug, and
under code-is-law the drain is **valid** — `exploit_valid`, at strength
zero, because the code does not count votes. The drain breaks no rule;
it exercises one. On-chain there is no difference between using the
contract and abusing it, because that distinction is not expressible in
the language either. And the same rigidity cuts the other way:
`no_onchain_repair` — the language has no `refund` verb. The system
that cannot be captured cannot be corrected.

What the community actually did was fork: the social layer re-pointed
the phrase "the chain" at a different chain. `fork_always_open` proves
the fork is available from every world, to every target, at bare
majority — licensed by nothing on any chain, for exactly the reason
Movement D's capture move was: no object text refers to it. Fifty-one
outranks infinity because they are not playing in the same arena. The
historical trace is `the_dao_fork`, `[0, 51]`: the theft needed no one;
the rescue needed a majority.

Two epitaphs, the second worse than the first:

```lean
theorem code_still_there : afterFork.orphan.contract = genesis.contract := rfl
theorem canonical_history_invalid : ¬ ReachC genesis bailout
```

Movement D's clause survived as ink. The orphaned contract survives as
a **running program** — deployed, enforcing, byte-identical, satisfying
every safety theorem above, for whoever is still listening;
`theft_still_valid_there` confirms the orphan is a perfectly *lawful*
history. And the second line is the crown of the movement: no valid
on-chain sequence reaches the bailout state from genesis. **The chain
everyone uses is the one the code forbids.** The canonical world is,
under its own law, an illegal state — made real by recognition, the one
operation the code cannot see.

Last, a symmetry the kernel insists on: `the_dao_fork` and
`the_coup_fork` are the same constructor with different arguments.
Rescue and robbery are not formal categories. Only the social layer can
tell them apart, and it is the layer performing them — judge and actor
coincide. Code-is-law did not escape the recognizer. It is a **total
delegation** to the recognizer, with the interpretive shock-absorbers
removed.

## G — the regress, or the schema

Six movements asked "does this defence hold?" and got six answers.
Movement G asks the question the six were instances of.

`Machine` abstracts the entire development into one type: a state
space, a move language, an application function, a validity law. Every
system in Movements A–F can be written as an inhabitant, and so can any
proposed in their place that has this shape (LIMITATIONS §12).
`ascend M` builds the floor above any of them: the machine's whole configuration becomes one field, `inForce`;
interior moves obey `M`'s law verbatim; and a `repoint` swaps the field
wholesale, at bare majority, reading nothing of `M`.

Two theorems certify that the ascent is no strawman.
`interior_faithful`: every object-lawful history embeds upstairs
unchanged — same strengths, orphan untouched. `interior_governed`:
delete the repoint and upstairs has *exactly* the object machine's
power. The only thing level k+1 has that level k lacks is the repoint
itself.

Then the schema:

```lean
theorem repoint_reaches_everything (M : Machine) (w : LWorld M) (s' : M.S) :
    MReach (ascend M) [51] w { inForce := s', orphan := w.inForce } :=
  .step (.repoint s') (Nat.le_refl 51) .nil
```

For **every** machine — entrenched, self-entrenched, ratcheted,
executable, anything — every configuration is one repoint from being
the one in force. Read the proof term: one constructor, and it consults
no field of `M`. The triviality is load-bearing. A hard proof would
have meant the guard put up a fight; the one-liner is the formal
content of "the guard was not consulted": `ascend`'s repoint is not a
move of `M`, and its validity reads nothing of `M`. The content lives in
the quantifier: no hypothesis on `M` appears because none could help.
That is a fact about `ascend`, which adds the repoint; it does not show
that real institutions have such a move, or that every conceivable
defence fails (LIMITATIONS §12).

Give the fork a legitimacy criterion, then. Every "lawful exit"
proposal — thresholds, checkpoints, ratified fork rules — can be
modelled as a predicate `g` on the in-force configuration, and
`ascendG` installs it.
The guard is real: `guarded_repoint_blocked`. It can even be **sound**,
by exactly Movement C's argument: `guarded_holds` proves that where the
object law never manufactures legitimacy, the guarded world never
repoints at all. The trilemma is not a fact about constitutions. It is
a fact about **levels**, and it holds on every floor.

And then the regress, which is not a new theorem but an application:
`ascend M` is a machine, so the schema applies to it — `the_regress`,
one line. The guard that `guarded_holds` just certified is not
consulted one floor up: `guard_regress` replaces the guarded level's
world at 51 without evaluating `g` — bypassed, not swapped — also one
line. The certificate was correct. It was also never asked. No new idea exists at any height, or is needed.
Turtles, mechanized.

The instantiation closes the arc. `eternity_holds_upstairs`: Movement C
survives the ascent intact — where the repoint is forbidden, the
eternity clause upstairs does everything it did downstairs.
`eternity_meta_defeated`: from any world over that same constitution,
one repoint at 51 puts tyranny in force. There is no contradiction
between the two, and that is the picture: `eternity_holds` remains true
forever. **It is a theorem about the orphan.**

What the schema does not prove is that self-recognition is false — or
that it is inexpressible; no language of recognition statements is
defined here. It adds recognition as an operation outside the move
interface: `repoint` takes an arbitrary configuration, is licensed by a
constant, and is never put to `M`'s law — as no transaction in
Movement F can change its contract. That is the model's boundary at
both ends: at the bottom, the code has no verb for its replacement; at
the top, no law in the model is consulted about its own being in force.
Between the two, everything is provable and nothing is final.

## The Gödel II analogy, and its limits

`eternity_holds` is a **safety guarantee for system C**: no `VC`-legal
history, of any length or strengths, reaches dictatorship. It was proved
*here*, in Lean, about C — not inside C, which is a transition system,
not a proof system. And it holds `V` fixed: Movement D shows that once
capture can change the recognizer, dictatorship is reachable with the
clause still in the text.

Read as an analogy: Gödel's second incompleteness theorem says a
consistent, effectively axiomatized theory containing enough arithmetic
cannot prove its own consistency; Movement D models a text that cannot
govern its own reading. In both, the assurance comes from outside.

Two disciplines about that sentence. First, it is an **analogy, not a
reduction** — there is no diagonalization here, no arithmetic, no
self-referential sentence, no incompleteness theorem. Nobody should cite
this repository for the claim that Gödel's theorem applies to law
(LIMITATIONS §7). Second, what *is* mechanically checked is the part
that can be: the safety guarantee, and the capture that defeats it once
`V` is no longer fixed — which is more than the usual invocation of
Gödel in a legal argument can say.

## What the conjecture becomes

Not "no dictator-proof clause exists." That is false, and C proves it
false.

Instead, on the model's reading: **you can freeze any given level, and
freezing all of them is not something a text can do.** The tower runs

> text < amendment rule < recognition rule < social practice

and it does not bottom out inside the law. Each defence is a correct
patch of the level it patches; the exploit moves up one.

What ultimately holds the invariant is the thing this repository cannot
formalize, and says so: the interpretive community's disposition to keep
reading the clause as binding. Dictator-proofness is a property of a
community, not of a document.

Which is, in the end, the practical conclusion — and the uncomfortable
one, because it is not amenable to drafting.

## Where the tower ends

Movements E through G sharpen every clause of that. The freezing you
can do (C) turns out to be available for procedure as well as content,
and for nothing else (E). The executable freeze — immutability by
inexpressibility — is a genuine theorem exactly as far as its frame, and the frame is chosen from outside it
(F). And "the exploit moves up one" is not a metaphor but an operator:
`ascend`, with one theorem that consumes every machine, its own outputs
included (G).

One floor above the schema sits this repository. `ascend` is the
modeller's pen, necessarily; its licence does not come from any
machine — it comes from the reader agreeing that this is what
recognition is like. The kernel certifies every theorem here; the
community certifies the kernel; the community is not a machine in any
file. The tower exits the mathematics through the reader. It always
did. Whether that is what Gödel saw, no one knows — his argument is
unrecorded, and this is one reconstruction — but it is the kind of
thing a citizenship hearing was never going to have room for.
