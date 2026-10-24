# Changelog

All notable changes to "Gödel's Loophole, kernel-checked". Versions
follow [Semantic Versioning](https://semver.org/); the theorem
statements are the public interface.

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
