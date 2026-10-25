# Changelog

All notable changes to "Gödel's Loophole, kernel-checked". Versions
follow [Semantic Versioning](https://semver.org/); the theorem
statements are the public interface.

## 1.0.1 — 2026-10-25

Documentation only, after an external review found prose that claimed
more than the theorems prove, one historical episode mischaracterized,
and an earlier formalization of the same anecdote uncited.
No theorem statement, proof, or definition changed.
The ledger is still 56 theorems, zero axioms, zero `sorry`, and with
comments stripped every `.lean` file is identical to 1.0.0.

### Corrections (factual)

- The README's opening had Gödel telling Einstein and Morgenstern of
  the flaw on the drive to Trenton. Per Morgenstern's memorandum he told
  Morgenstern, months before the hearing; Morgenstern told Einstein, and
  both urged him not to raise it; in Trenton the examiner cut him off.
  "He never wrote it up" — and "never wrote it down" in SOURCES, the
  standalone header and `CITATION.cff` — is now "no written version is
  known". Movement G's closing no longer says Einstein and Morgenstern
  stopped him.
- Basic Law timing. Movement C's header said Art. 79(3) was "written one
  year after Gödel's hearing"; the hearing is dated December 1947 (1946
  in the memorandum) and the Basic Law is 1949. That header and
  ARGUMENT also said the clause protects itself; that is German
  doctrine, not the text (SOURCES §5), and they now say so.
- The Enabling Act was called "a procedurally valid amendment", and the
  Basic Law's authors were said to have watched Article 76 "be used as
  designed". SOURCES §4 now records the coercion around the vote of
  23 March 1933 — the 81 KPD mandates annulled, 26 SPD deputies in
  custody or fled, the standing orders changed so that absentees counted
  as present, the SS and armed SA at the Kroll Opera House — citing the
  Bundestag, the USHMM and the Anne Frank House, and keeps the episode
  only as an analogy for a transfer of rule-making authority.
- "Article V constrains HOW, never WHAT" (Movement A, THEOREMS) is false
  of Article V, whose equal-suffrage proviso is Movement B's subject. It
  now reads "the amendment rule", and Movement A no longer calls the
  model's amendment rule "Article V".

### Clarifications

- Gödel II. `eternity_holds` is a safety guarantee over `VC`-legal
  histories, proved in Lean about system C with `V` held fixed. It was
  called a "consistency certificate" proved in "a strictly stronger
  metasystem", and the README called the Gödel II rhyme "precise",
  against LIMITATIONS §7. The parallel is now an analogy everywhere,
  with no ordering of proof-theoretic strength. ARGUMENT's section is
  "The Gödel II analogy, and its limits", and states the theorem with
  its standard conditions.
- Inexpressibility. Nothing defines a language of recognition
  statements or proves non-expressibility; Movement G adds recognition
  as an operation outside the move interface. The README, ARGUMENT,
  `MovementG.lean`, `Receipts.lean` and the ROADMAP now call that the
  model's boundary, and no longer say the guard "could not have been"
  consulted. `contract_inexpressible` is unchanged; its gloss says what
  it states — no transaction changes the contract — not that none
  "mentions" it.
- The guard. In `guard_regress`, `g` is a parameter of `ascendG`, not
  world state, and the outer repoint replaces the guarded level's world
  without consulting it. The guard is bypassed, not "swapped wholesale —
  guard, world, history, all of it".
- Movement G's scope. The schema is about the `ascend` construction,
  which adds an unrestricted repoint at 51 that never consults the
  machine's law; it does not show that real institutions have such a
  move, or that every conceivable defence fails (LIMITATIONS §12). The
  README's G row and prose, ARGUMENT, THEOREMS, the ROADMAP and the
  `CITATION.cff` abstract say so. "Every system anyone will ever
  propose" is now "any with this shape", and lawful-exit proposals "can
  be modelled as" a predicate `g`.
- Zero axioms. The README says the count is about the proofs' logical
  dependencies; the model's assumptions live in its definitions.
- Model-relative wording. The README makes "one reconstruction" of
  Gödel's argument precise, and no text says what Gödel saw. Legal
  reachability is decided "inside the model"; the `CITATION.cff`
  abstract no longer says reachability of dictatorship "is a theorem",
  which Movement C contradicts. Article V's double amendment carries its
  qualification beside the claim: its lawfulness is disputed, and
  Movement B formalizes one reading. Freezing every level is "the
  model's reading"; recognizer capture holds "under D's capture
  premise"; what constitutions cannot freeze is "in the model"; Movement
  F's fork clause is a modelling choice, not "the finding".
- Prediction blocks stay as recorded. Where one uses wording this
  release corrects, the verdict of Movement E, F or G carries a
  "1.0.1 note". The ROADMAP's Movement G resolution is aligned; the
  preregistered target above it is unchanged.

### Added

- Related work: Zahoransky and Benzmüller, "Modelling the US
  Constitution to Establish Constitutional Dictatorship" (MIREL 2019,
  CEUR-WS vol. 2632), an earlier machine-checked model of the same
  anecdote in Isabelle/HOL, with Zahoransky's 2019 thesis and the public
  LogiKEy theory files. SOURCES §9 compares the two; the README's
  Sources paragraph points there.
- LIMITATIONS §2: a "No coercion" bullet.
- The README subtitle "A Lean 4 study of self-amendment, entrenchment,
  and recognition", and sources for Judge Forman's name (Lipton and
  Regan) and its spelling (the Federal Judicial Center).
- DOIs. This release is
  [10.5281/zenodo.23648908](https://doi.org/10.5281/zenodo.23648908);
  the concept DOI,
  [10.5281/zenodo.23629066](https://doi.org/10.5281/zenodo.23629066),
  covers all versions and resolves to the latest. `CITATION.cff` gives
  the version DOI as `doi` and the concept DOI under `identifiers`; the
  README's badge points at the concept DOI, and "How to cite" lists the
  version DOIs of 1.0.0 and 1.0.1.

## 1.0.0 — 2026-10-24

The first citable release. No theorem statement or proof changed; the
ledger is still 56 theorems, zero axioms, zero `sorry`.

### Licensing

- Relicensed from MIT to PolyForm Noncommercial 1.0.0. Versions before
  1.0.0 were distributed under the MIT License.
- Copyright: Alexander David Zalewski, 2026. `LICENSE` carries the
  `Required Notice:` line followed by the license text, verbatim.
- Every `.lean` file opens with the required notice and the SPDX
  identifier `PolyForm-Noncommercial-1.0.0`, so a file copied on its own
  — `standalone/Godel.lean` above all — carries its terms with it.
- `CITATION.cff` names the author (with ORCID) and the new license;
  `lakefile.toml` declares the license.

### The executable says only what is true

- `lake exe godel` used to re-implement the trace loop, and its banner
  called each ACCEPT "a kernel-checked theorem, not a print" — while
  printing ADOPT, from compiled code no kernel checks. `walk` in
  `Main.lean` now asks `runTrace` itself for every prefix of the trace,
  so each printed state is `runTrace V init (tr.take k)`, on exactly the
  traces of `loophole_runs`, `bypass_runs`, `C_refuses_direct`,
  `C_refuses_selfrepeal` and `capture_runs`. The banner and header say
  so, and say that the printout is compiled output, not a proof.
- Movement C now runs once per door. The old single run stopped at its
  first refusal, so the second door was never shown.
- The README's Quickstart and "The exploit is a program" are scoped to
  Movements A–D, the only ones with a checker.
- Movements A, B and D print byte-for-byte what they printed before.

### One set of numbers

- Seven movements (A–G) and 56 theorems everywhere they are stated.
  `CITATION.cff`'s abstract still described four movements; it now
  describes all seven. The standalone edition's opening comment listed
  six; it now lists G as well.
- `CITATION.cff`: `version: "1.0.0"`, `type: software`,
  `date-released` set to the release date. `lakefile.toml`:
  `version = "1.0.0"`.
- README: a "How to cite" section, and `CHANGELOG.md` and
  `CITATION.cff` in the repository map.
- The release's Zenodo DOI,
  [10.5281/zenodo.23629067](https://doi.org/10.5281/zenodo.23629067),
  is `doi` in `CITATION.cff` and appears in the README's badge and
  "How to cite".

### The drift canary, recorded honestly

- The `drift-watch` comment in CI named two drifting theorems; it now
  gives ADR-0002's figures (13 of 24 when first measured, 15 of 43 at
  the Movements E–F snapshot).
- It also said the sources compile on newer toolchains. Since Movement
  G landed they do not: `Godel/MovementG.lean` fails on Lean 4.33.0 and
  4.35.0 with an internal `mkElimApp` error, so the canary dies at
  compile and never reaches the ledger. ADR-0002 now carries the
  evidence inline (addendum 2) and states that its decision 4 is unmet;
  the README's pin section says so too; and the ROADMAP has the repair
  as an open item. No proof changed — the pinned ledger is unaffected.

### Provenance, and what "registered" means

- README: a Provenance section — the author's role; that development
  was AI-assisted (Claude, by Anthropic), that the AI is not listed as
  an author, and that commit trailers disclosing it were inconsistent
  before 1.0.0 and are consistent from 1.0.0 on; why the validity of
  the proofs does not depend on authorship; and the commands to check
  them independently.
- `docs/notes/`: each development log now opens with its date and a
  note that its patch files and hand-off decisions describe the
  workflow at the time.
- Preregistration claims say only what the history shows. The ROADMAP
  targets are cited by commit (`ec9272c` for Round 3 and the ratchet,
  `c983f2d` for Movement G), all committed before the movements they
  target. The in-file "registered before compilation" headers landed in
  the same commits as their proofs, so they now read "written before
  the first compile, per the development log", with the ROADMAP commit
  as the timestamped record; for the ratchet that record is the target
  and its questions, not the predicted answer. Movement G's
  meta-prediction is stated in conversation and says plainly that the
  repository cannot check it. Comment-only in `.lean` files.
- ROADMAP: from 1.0.0 on, a new movement's prediction is committed on
  its own, before any proof.

### Sources, checked

- Guerra-Pujol: full citation, *Capital University Law Review* 41
  (2013): 637–673, with its SSRN record; the "given from memory"
  caveat is gone.
- Morgenstern's memorandum: dated 13 September 1971; the Institute for
  Advanced Study's copy is in the Dorothy Morgenstern Thomas collection
  at the Shelby White and Leon Levy Archives Center (not "Morgenstern's
  papers"), cited by its persistent handle.
- The date 5 December 1947 is attributed to Dawson. The memorandum
  itself, read from the Institute's scan, gives a year but no day, and
  the year is 1946 — matching the Institute's catalogue record and
  Lipton and Regan (2013), not the St Andrews transcription or the
  Institute's finding aid, which give 1947.
- Kegler: his page replaces "'The Gödel Document' (2010)", which could
  not be confirmed; Mark Dominus was reporting the find on 21 January
  2009. Lipton and Regan's 2013 post, which quotes the memorandum, is
  added.

### One receipt per theorem, enforced

- `THEOREMS.md` promised that every theorem has exactly one receipt,
  but nothing checked it: a new theorem without a receipt would have
  passed CI. New `scripts/check-receipts.sh` compares the theorem names
  declared in `Godel/*.lean` (modifiers such as `private` included,
  comments stripped first) with the names under `#print axioms` in
  `Godel/Receipts.lean`, and fails with a diff on any difference,
  including a receipt listed twice.
- It is step 6 of `scripts/verify.sh`, mirrored in `scripts/verify.ps1`,
  and a step of CI's gating `kernel-check` job.

### Erratum, recorded after release (2026-10-24)

- Under *Provenance, and what "registered" means*, the first bullet says
  commit trailers "are consistent from 1.0.0 on". Three merge commits
  lack the trailer: 86d6713, 20b0bd3 and 6f99fa6, the merges of pull
  requests #3–#5, created with GitHub's default message. The README's
  Provenance section states this. The bullet is left as released; the
  `CHANGELOG.md` in the 1.0.0 archive predates this erratum.
