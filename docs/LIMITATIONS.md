# Limitations

This is a **toy**: a five-field constitutional state — later joined by
chains, worlds, and finally a type of all machines — a scalar, and ten
hand-written validity regimes plus three regime operators. The theorems are real — the kernel checked them — but a
theorem is only ever about the system it is stated over. This file
enumerates the places where a reader could mistake a modelling choice for
a result. It is meant to be read *before* quoting anything from here.

## 1. Reachability is not lawfulness

Every result in Movements A, B, and D has the form "there is a derivation
in this transition system." That is a claim about the model. It is **not**
a claim that the corresponding real-world sequence would be lawful, would
survive judicial review, or would be recognised by anyone. The gap
between "derivable in a formalization of Article V" and "lawful under
Article V" is the entire subject matter of constitutional law, and none
of it is in this repository.

## 2. There are no actors

The model has no agents: no legislature that must be re-elected, no
president, no court with an incentive, no public. A "session" is a
strength and an amendment, nothing else. Consequences:

- **Nothing about likelihood.** The model says a path exists. It says
  nothing about whether anyone would take it, could assemble the
  coalition, or would survive doing so.
- **A clause cannot be *wielded*.** Honduras 2009 (see
  [SOURCES.md](SOURCES.md) §7) is a case where an eternity clause was the
  *instrument* of a seizure rather than its target. The toy cannot
  represent that at all.
- **No elections between sessions.** `Reach` permits any strength at any
  step with no continuity requirement. Much of the real protection in
  constitutional design comes from the fact that a coalition must survive
  an intervening election; that mechanism is absent here.

## 3. Scalar strength cannot say *who* holds the pen

`Rule.cost` is a number. That is enough to express "how hard is it to
amend" and nothing about "who may propose". The visible consequence is in
`loophole_decree`: in this model, cost 0 means *anyone* may amend, so the
decree state is symmetric and the pen returns. **Real decree rules are
asymmetric — the pen does not return.** The toy therefore *understates*
the decree variant. This is flagged in the source comment as well.

## 4. `dictatorship` is a target predicate, not an institution

`setDictatorship true` as a single amendment is, as law, absurd. The
boolean is a stand-in for a bundle of changes whose conjunction the
entrenchment clause is meant to forbid. Similarly `coreAttack` is a
hand-written two-case list, not a derived notion. Choosing what counts as
the forbidden set is a substantive move made **by us, outside the model**,
and a different choice yields different theorems.

## 5. The regimes are ours, and are not exhaustive

`VA`, `VB`, `VC`, `VD` are four points in a large space. Nothing here
proves they are the interesting four, that they exhaust the design space,
or that a fifth regime would not defeat Movement D. In particular:

- **Movement D's capture is modelled as always available at any
  strength, including 0.** That is a deliberately strong assumption. Its
  justification is jurisprudential (Hart: the rule of recognition is a
  social practice, not a legal norm — see [SOURCES.md](SOURCES.md) §6),
  not formal. A reader who rejects that premise should reject Movement D,
  and Movement C's result then stands unqualified.
- **Movement C is stronger than Art. 79(3) as literally written.** The
  German text does not name itself; the doctrine supplies the
  self-entrenchment. See [SOURCES.md](SOURCES.md) §5.

Movement G retires part of this caveat and relocates the rest: the
schema quantifies over every `Machine`, so "a fifth regime might defeat
the pattern" is now answered for regimes *of that shape*. But `Machine`
itself is a shape choice, and `ascend` is ours. See §12.

## 6. Movement D is unfalsifiable *within* the model, by construction

Because capture is ungoverned by the amendment rule, no clause added to
the object text can block it — that is the point being made, but it also
means Movement D cannot be *tested* inside the model. Its content is the
modelling choice itself. The formalization makes the choice explicit and
its consequence exact; it does not argue for it. Anyone wanting to
disagree with Movement D should disagree with `VD`'s second and third
disjuncts, which is a one-line edit.

## 7. The rhyme is a rhyme

`eternity_holds` is proved in Lean, a metasystem strictly stronger than
the object system it certifies, and the object system cannot keep the
certificate's hypotheses true. That is a genuine structural parallel to
Gödel's second incompleteness theorem, and it is **only** a parallel.
**No formal reduction of Gödel II to the constitutional case is claimed,
attempted, or implied.** There is no diagonalization here, no arithmetic,
no self-referential sentence, and no incompleteness result. Do not cite
this repository as evidence that Gödel's theorem applies to law.

## 8. The axiom ledger is toolchain-relative

The uniform zero-axiom result holds on the pinned `v4.15.0`. On 4.33.0,
identical source gives **13 of the 24 theorems then in the development**
a `propext` dependency — exactly those touching `VB`, `VC` or `VD`. The
cause was investigated and **not** isolated: minimal reproductions of the
suspected shapes (`decide` over compound goals, over structure-projection
updates, with false antecedents) do **not** exhibit the drift on either
toolchain. See [ADR-0002](adr/0002-toolchain-pin.md). A later probe
(ADR-0002 addendum) sharpened both halves: the drift lives in
**elaboration**, not the core library — 37 core constants are
byte-identical across the two toolchains while identical source reaches
`propext`-backed lemmas only on the newer one — and the
implication-shape characterization is **falsified by Movement E's own
regimes** (`VR` has the shape and does not drift; `VRS` differs by one
conjunct and does). At the Movements E–F snapshot the figure was 15 of
43; Movement F does not drift at all. A narrower predicate fitting all
points is recorded, flagged as fitted rather than verified. Treat the ledger as
a regression tripwire, not as a deep fact.

Note also that `runTrace_sound`'s proof deliberately avoids
`simp [Option.some.injEq]` in favour of `Option.some.inj`, because the
former is proved *using* `propext`. This is the kind of thing the ledger
is for, and the kind of thing that makes the ledger fragile.

## 9. Two copies of the source

`standalone/Godel.lean` and `Godel/*.lean` contain the same development
in two forms — one pasteable, one modular. CI checks that **both**
compile and that their theorem names agree (`scripts/check-parity.sh`),
but it does not check that the two sets of *proofs* are identical. They
can drift in proof detail. The modular library under `Godel/` is
canonical; the standalone edition is a convenience.

## 10. What this repository is actually for

It is an instrument, not a finding. The value is that a proposed defence
can now be stated as a modification to the transition relation and
answered with a theorem instead of an argument. The seven movements are
a demonstration that the instrument works — not the last word on any of
them. See [ROADMAP.md](ROADMAP.md).

## 11. Movement F compresses history past recognition

The chain is two fields; the transaction language is two verbs; there
is one orphan slot. There are no miners, no clients, no hashpower, no
gas — the fork's strength 51 is a stand-in for "a social majority
moved," with no mechanism behind it. The claim Movement F supports is
structural — validity is chain-relative, and chain-choice is not a
chain operation — and nothing finer. It is not a history of 2016, and
the file says so in its own comments. In particular the model cannot
distinguish contentious from uncontentious forks, gradual client
adoption from a clean cut, or any of the things that made the real
event hard.

## 12. Movement G's schema is as strong as its lift

`repoint` reads nothing of `M` and is licensed by a constant. That
ignorance is the formal image of the same Hartian premise Movement D
rests on (§6), promoted from one system to a schema — and it is the
strongest and most contestable choice in the repository. The theorems
are unconditional; the *interpretation* — that `ascend` is what
recognition is like — is not a theorem anywhere, and the faithfulness
pair constrains it without compelling it. A reader who rejects the
premise rejects the reading of Movement G, not its mathematics.
Relatedly: "every machine" means every inhabitant of `Machine` — one
state space, one move language, discrete steps, a scalar strength.
Systems not of that shape (concurrency, continuous time, agents,
mechanisms) are outside the quantifier, and the constant 51 is
arbitrary. The schema ends where the shape does.
