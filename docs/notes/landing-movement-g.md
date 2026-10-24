> Development log, dated 2026-08-17. Development was AI-assisted (see
> [README, Provenance](../../README.md#provenance)). References to patch
> files, paste-ready rows, and hand-off decisions describe the workflow
> at the time; those patches were applied and are not part of this
> repository.

# Movement G + receipt restoration + prose wrap — landing notes

Built and verified in a fresh clone of landed `main` (1422d94) on the
pinned toolchain. `scripts/verify.sh` green end-to-end: build, certified
checker, standalone edition, `sorry` sweep, parity (46 theorems in both
editions). **Self-contained** — code, docs, scripts, and standalone
mirror are all inside the one patch. Nothing left to author after
applying.

**Ledger: 56 theorems. Zero axioms. Zero `sorry`. The 1:1
declaration↔receipt invariant is restored** — the two Movement E
invariant lemmas (`VE_preserves_gate`, `VRS_preserves`) are now guarded
like everything else, and THEOREMS.md's caveat paragraph is replaced
accordingly. Every declaration in the library has a receipt again.

## Movement G — the regress (11 theorems, all receipted)

Prediction written in the file header before the first compile, and
committed with the proofs in `5c10708`; the timestamped record is the
ROADMAP target and its suspicion, committed in `c983f2d` before Movement
G existed. Verdict: four clauses for four, first compile clean, zero
axioms. The meta-prediction ("provable but barely non-trivial; the work
is in the statement, not the proof") — stated in conversation, so not
checkable from the repository — resolves confirmed, with its conceded
wrinkle intact.

- `Machine` abstracts the whole development — any state space, move
  language, apply function, validity law. `mreach_to_reach` proves the
  abstraction is exact on the Movements A–D constitution.
- `ascend M` builds the floor above any machine. Faithfulness pair
  (`interior_faithful`, `interior_governed`): every object-lawful
  history embeds upstairs unchanged, and with the repoint forbidden,
  upstairs has *exactly* the object machine's power. Not a strawman.
- **`repoint_reaches_everything`** — the schema: for every machine,
  zero hypotheses, every configuration is one repoint from being in
  force at 51. One constructor, consulting no field of `M`. The
  triviality is load-bearing: it is "the guard was not consulted,"
  formalized.
- `ascendG` — fork-legitimacy as world state. A real guard
  (`guarded_repoint_blocked`), *sound* by exactly Movement C's argument
  (`guarded_holds`): the trilemma is level-invariant. Then
  `guard_regress` and `the_regress` — the schema applied to its own
  outputs, one line each.
- The closing pair: `eternity_holds_upstairs` (C survives the ascent
  intact) and `eternity_meta_defeated` (one repoint puts tyranny in
  force from any world over C). `eternity_holds` stays true forever —
  it is a theorem about the orphan.

Self-recognition is not refuted; it is shown **inexpressible**. The
development is bounded at both ends by inexpressibility: the code
cannot speak of its replacement (F), and no law can speak of its own
being in force (G).

## Prose wrap — the last roadmap item, closed

- **README** — seven-movement table recast around *the guarded thing*
  (repriced / falls in two / holds / outlived-as-ink /
  outlived-as-running-program / swapped wholesale), long readings for
  E, F, G, corrected drift section, and a closing that names the
  reader as the exit from the tower.
- **docs/ARGUMENT.md** — three new long-form sections in the existing
  voice ("the modeller's pen", "the recognizer perfected", "the
  schema") plus a closing section, *Where the tower ends*.
- **docs/LIMITATIONS.md** — §5 and §8 amended (the drift
  characterization was falsified by our own probe; §8 now says so),
  new §11 (Movement F compresses history past recognition — no miners,
  no clients, strength 51 is a stand-in) and §12 (Movement G's schema
  is as strong as its lift; `Machine` is a shape choice and `ascend` is
  ours).
- **docs/adr/0001** — append-only addendum: decision 1 scoped to A–D,
  three notes on how E/F/G extended the shape without amending it.
- **docs/ROADMAP.md** — G resolved with full verdict; Round 3 marked
  resolved; the drift open-question rewritten (its original
  "airtight" characterization is now recorded as falsified, with
  Movement F as the control); *Distributed recognition* sharpened
  rather than claimed-answered; prose-wrap item closed.

One deliberate non-edit: LIMITATIONS §8 and ROADMAP keep "13 of the 24
theorems **then** in the development" as historically-scoped
measurements rather than restating them with today's numerator.

## Ritual

Tamper-tested (falsified `the_regress` receipt → build red → restored,
`git diff` clean). No proof content altered outside the new file. Every
internal doc link checked. No push from this side — landing judgment is
the maintainer's.
