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
