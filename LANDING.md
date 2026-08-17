# Movements E + F — landing notes (supersedes the E-only kit)

Built and verified in a clean clone at the pinned toolchain
(`leanprover/lean4:v4.15.0`, independent tarball install). Status at
handoff: `lake build` green with both movements wired in, all nineteen
new receipts `#guard_msgs`-enforced and **tamper-tested** (one falsified
docstring per movement → build fails → restored),
`scripts/check-parity.sh` passes.

**Ledger after landing: 43 theorems. Zero axioms. Zero `sorry`.**

## Movement E — the ratchet (7 theorems)

Prediction registered in the file header before compiling; verdict:
regime-ratchet holds (`regime_gate_holds`) and guards nothing else;
clause-ratchet bypassed in `[67, 67, 0]` (`clause_ratchet_bypassed`);
self-entrenched repair holds by exactly C's proof shape
(`selfentrenched_gate_holds`). "Not a new kind of defence" is now the
theorem. The E1/E2 gap is the physics/law gap.

## Movement F — the fork (12 theorems)

Prediction registered before compiling; verdict, all three clauses:

| Claim | Theorem |
|---|---|
| Steelman real: immutability by *inexpressibility* — D's interior attack deleted | `contract_inexpressible`, `code_is_law`, `promise_holds_without_fork` |
| The exploit is *valid*, on-chain repair *impossible* | `exploit_valid`, `no_onchain_repair` |
| Fork open from every world, every target, at 51 | `fork_always_open` |
| 2016 replayed: drain (strength 0) then rescue-fork | `the_dao_fork` `[0, 51]` |
| Same verb, other direction — kernel can't tell rescue from robbery | `the_coup_fork` `[51]` |
| Epitaph lineage: ink (D) → running program (F) | `code_still_there := rfl`, `theft_still_valid_there` |
| **The chain everyone uses is the one the code forbids** | `canonical_history_invalid` |

Roadmap's "a negative would be more interesting": confirmed,
constructively. Code-is-law is perfected Movement C — and a total,
undiluted delegation to the recognizer. Two asymmetries survive every
formalization: the modeller freezes levels and the system cannot (E);
the system is recognized and cannot recognize itself (F).

## Changes (also in `movements-ef.patch`)

1. `Godel/MovementE.lean`, `Godel/MovementF.lean` — new, self-contained
   (movement-local `StateR`/`Chain`/`World` types; zero blast radius on
   A–D). F imports only `Core`.
2. `Godel.lean` — two import lines (E, F before `Receipts`).
3. `Godel/Receipts.lean` — two imports + nineteen guarded entries,
   **inside** `namespace Godel` (above `end Godel`), or every name is
   unresolved.

## THEOREMS.md — F rows ready to paste (count 24 → 43 with E's seven)

## Movement F — the fork (`Godel/MovementF.lean`)

Regimes `Vcode` / `VW`: on-chain validity is the deployed code (no
strength parameter — code doesn't count votes); world-level moves are
on-chain steps plus the fork, licensed by nothing on any chain.

| Theorem | Says | Axioms |
|---|---|---|
| `contract_inexpressible` | No transaction mentions the contract: immutability by absence of the verb | none |
| `code_is_law` | Along every valid history the code is the code — the steelman, true | none |
| `exploit_valid` | The drain breaks no rule; it is a rule | none |
| `drained_step` | No transaction, valid or not, refills anything | none |
| `no_onchain_repair` | Uncapturable also means uncorrectable | none |
| `promise_holds_without_fork` | Delete the fork and the promise holds at world level too | none |
| `fork_always_open` | Every world, every target, bare majority: 51 outranks ∞ across arenas | none |
| `the_dao_fork` | 2016: valid theft, invalid rescue, community keeps the rescue | none |
| `the_coup_fork` | Identical constructor, opposite morality; formally indistinguishable | none |
| `code_still_there` | The orphaned contract survives as a running program (`rfl`) | none |
| `theft_still_valid_there` | The orphan is a perfectly lawful history | none |
| `canonical_history_invalid` | No valid on-chain path reaches the canonical world: recognition made an illegal state real | none |

## Decisions left with maintainers

- **Parity**: mirror E+F into `standalone/Godel.lean` + extend the list
  (recommended — the standalone's promise is "the whole development"),
  or scope parity to A–D explicitly.
- **ROADMAP**: both items close — ratchet resolved-negative-as-predicted;
  fork target hit with `code_still_there … := rfl` intact as specified.
  Candidate Movement G, if wanted: the fork-guard regress — any
  constraint *on* the fork is itself either modeller's fiat or world
  state, and world-state fork-guards are applied by the recognizer they
  would bind. The terminal theorem, if it can be stated cleanly, is a
  no-self-recognition schema.
- **ADR-0003 inscription**, still offered: the Σ/Π asymmetry is real as
  logical form, dead as axiom cost — "attacks are data, defences are
  laws — and in a decidable toy, both are free."

No push from this side: write access and landing judgment stay with the
repo's maintainers.
