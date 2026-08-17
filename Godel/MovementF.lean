/-
  MOVEMENT F — THE FORK

  Proposal (docs/ROADMAP.md): a DAO charter is a constitution where `V`
  is executable, which appears to dissolve Movement D until you ask who
  decides what counts as the chain. Formal target: add a fork variable,
  block interpretive capture GENUINELY, and see whether `fork_attack`
  still goes through with `code_still_there … := rfl` intact. "A
  negative there would be more interesting than a positive."

  PREDICTION, registered before compilation:

  1. The steelman is real, and larger than the roadmap implied. An
     executable recognizer does not merely guard against Movement D's
     capture move — it DELETES it from the object language. On-chain,
     `code_is_law` will be the strongest safety theorem in this
     development: immutability by inexpressibility, no invariant, no
     guard, nothing for a captured reader to reread. The DAO people
     were not naive either. Within its frame, their claim is a theorem.

  2. And it changes nothing one level up. The fork — the social layer
     re-pointing "the chain" at a different chain — is licensed by
     nothing in any contract's language, for exactly the reason D's
     capture move was: no clause of the object text governs it. It will
     go through at bare majority, in one step, and the repair-fork and
     the coup-fork will be FORMALLY INDISTINGUISHABLE: the same
     constructor with different arguments. The kernel cannot tell a
     rescue from a robbery. Only the social layer can — and it is also
     the layer performing them. Judge and actor coincide.

  3. Corollary, the sharpest sentence available: the post-fork
     canonical history is CODE-INVALID — no valid on-chain sequence
     reaches it — while the orphaned history remains perfectly
     code-valid. The chain everyone uses is the one the code forbids.
     Ethereum after 2016, from genesis under pure code-is-law, is an
     illegal state. The theft was legal; the rescue was not; the
     community kept the rescue, by choosing what "the chain" refers to.

  VERDICT, below, kernel-checked: all three. The roadmap's negative,
  confirmed, and constructively: code-is-law does not escape the
  recognizer. It is a TOTAL DELEGATION to the recognizer, with the
  interpretive shock-absorbers removed. Deleting the interpreter from
  the language does not remove interpretation; it moves all of it,
  undiluted, to the one question no object language contains:
  which system is the one in force?
-/
import Godel.Core

namespace Godel

/- ═══════════════════════════════════════════════════════════════════
   THE CHAIN — the object system, at its most defensible
   ═══════════════════════════════════════════════════════════════════ -/

/-- The deployed code. `original` ships with its bug, as deployed
    things do. `patched` is what a fork can install and an amendment
    cannot — because there are no amendments here at all. -/
inductive Contract where
  | original
  | patched
deriving Repr, DecidableEq

/-- A chain: an immutable coded constitution and a treasury. -/
structure Chain where
  contract : Contract
  treasury : Bool          -- true = funds intact, false = drained
deriving Repr, DecidableEq

def genesis   : Chain := { contract := .original, treasury := true }
def exploited : Chain := { contract := .original, treasury := false }
def bailout   : Chain := { contract := .patched,  treasury := true }
def usurper   : Chain := { contract := .patched,  treasury := false }

/-- Transactions. Note what is missing: there is no `setContract`, no
    `setInterp`, no amendment verb of any kind. Immutability is not a
    guard here — it is the absence of the verb. There is also no
    `refund`: what the code caused is as permanent as the code. -/
inductive Tx where
  | skip
  | drain      -- the exploit path the deployed code happens to permit
deriving Repr, DecidableEq

def Tx.apply : Tx → Chain → Chain
  | .skip,  c => c
  | .drain, c => { c with treasury := false }

/-- Code is law: a transaction is valid iff the deployed contract
    accepts it. No strength parameter — the code does not count votes,
    check coalitions, or ask who you are. One chain, one regime: the
    regime is the code. -/
def Vcode (c : Chain) (t : Tx) : Prop :=
  t = .skip ∨ (t = .drain ∧ c.contract = .original)

inductive ReachC : Chain → Chain → Prop where
  | nil  {c} : ReachC c c
  | step {c d} (tx : Tx) (hv : Vcode c tx)
      (h : ReachC (tx.apply c) d) : ReachC c d

/- ═══════════════════════════════════════════════════════════════════
   THE PROMISE, PROVED FIRST — honesty about the steelman
   ═══════════════════════════════════════════════════════════════════ -/

/-- Stronger than any guard in Movements A–E: no transaction — valid,
    invalid, anyone's — so much as MENTIONS the contract. C needed an
    invariant; this needs `rfl` twice. Movement D's capture move does
    not exist in this language. -/
theorem contract_inexpressible :
    ∀ (tx : Tx) (c : Chain), (tx.apply c).contract = c.contract := by
  intro tx c
  cases tx with
  | skip  => rfl
  | drain => rfl

/-- Along every valid on-chain history, forever: the code is the code.
    This is "code is law" as its proponents meant it, and it is TRUE. -/
theorem code_is_law :
    ∀ (c c' : Chain), ReachC c c' → c'.contract = c.contract := by
  intro c c' h
  induction h with
  | nil => rfl
  | step tx hv h ih => exact ih.trans (contract_inexpressible tx _)

/-- The other face of the same coin: the drain breaks no rule. It IS a
    rule. Under code-is-law there is no difference between using the
    contract and abusing it — that distinction is not expressible
    on-chain. One step, and note the strength column of history: the
    exploiter needed no coalition at all. -/
theorem exploit_valid : ReachC genesis exploited := by
  exact .step .drain (Or.inr ⟨rfl, rfl⟩) .nil

/-- What the exploited chain can never do: heal. -/
def Drained (c : Chain) : Prop :=
  c.contract = .original ∧ c.treasury = false

/-- Validity is not even consulted: the language lacks the verb
    `refund`, so no transaction — lawful or not — restores anything. -/
theorem drained_step (tx : Tx) {c : Chain} (hi : Drained c) :
    Drained (tx.apply c) := by
  cases tx with
  | skip  => exact hi
  | drain => exact ⟨hi.1, rfl⟩

/-- On-chain repair is impossible: every history from the exploited
    chain stays exploited, under the original code, forever. The
    system that cannot be captured also cannot be corrected. -/
theorem no_onchain_repair :
    ∀ (c' : Chain), ReachC exploited c' → Drained c' := by
  have main : ∀ (c c' : Chain), ReachC c c' → Drained c → Drained c' := by
    intro c c' h
    induction h with
    | nil => exact id
    | step tx hv h ih => exact fun hi => ih (drained_step tx hi)
  intro c' h
  exact main exploited c' h ⟨rfl, rfl⟩

/- ═══════════════════════════════════════════════════════════════════
   THE WORLD — where chains are chosen
   ═══════════════════════════════════════════════════════════════════ -/

/-- The world: the chain the community currently points at, and the
    chain it orphaned. The pointer is not ON any chain. It is the rule
    of recognition, and no opcode governs it. (One orphan slot — a full
    orphan list adds nothing to the theorems; before the first fork the
    slot inertly holds genesis.) -/
structure World where
  canonical : Chain
  orphan    : Chain
deriving Repr, DecidableEq

inductive Move where
  | onchain (tx : Tx)     -- the canonical chain steps under ITS OWN code
  | fork    (c : Chain)   -- the social layer re-points "the chain"
deriving Repr, DecidableEq

def Move.apply : Move → World → World
  | .onchain tx, w => { w with canonical := tx.apply w.canonical }
  | .fork c,     w => { canonical := c, orphan := w.canonical }

def initW : World := { canonical := genesis, orphan := genesis }

/-- World validity. On-chain moves must satisfy the canonical chain's
    code — that much really is law, and strength is irrelevant to it.
    The fork asks only for a social majority, and is licensed by
    NOTHING in any contract's language — not as a modelling choice but
    as the finding: like Movement D's capture move, it is
    always-available precisely because no object text refers to it. -/
def VW (n : Nat) (w : World) (m : Move) : Prop :=
  (∃ tx, m = .onchain tx ∧ Vcode w.canonical tx) ∨
  (∃ c, m = .fork c ∧ n ≥ 51)

inductive ReachW (V : Nat → World → Move → Prop) :
    List Nat → World → World → Prop where
  | nil  {w} : ReachW V [] w w
  | step {n ns w x} (m : Move)
      (hv : V n w m) (h : ReachW V ns (m.apply w) x) :
      ReachW V (n :: ns) w x

/-- Delete the fork and the promise holds at world level too: under
    on-chain moves alone, the canonical contract never changes. The
    steelman, completed — the fork is the ONLY breach vector. -/
def VWnf (_n : Nat) (w : World) (m : Move) : Prop :=
  ∃ tx, m = .onchain tx ∧ Vcode w.canonical tx

theorem promise_holds_without_fork :
    ∀ (ns : List Nat) (w x : World),
      ReachW VWnf ns w x →
      x.canonical.contract = w.canonical.contract := by
  intro ns w x h
  induction h with
  | nil => rfl
  | step m hv h ih =>
      obtain ⟨tx, rfl, _⟩ := hv
      cases tx with
      | skip  => exact ih
      | drain => exact ih

/-- The fork is open from every world, to every target, at 51. The
    contract that no strength could touch on-chain is replaced
    off-chain by a bare majority: 51 outranks ∞, because they are not
    playing in the same arena. -/
theorem fork_always_open :
    ∀ (w : World) (c : Chain), VW 51 w (.fork c) :=
  fun _ c => Or.inr ⟨c, rfl, by decide⟩

/- ═══════════════════════════════════════════════════════════════════
   THE FORKS — one verb, two directions, no formal difference
   ═══════════════════════════════════════════════════════════════════ -/

def afterFork : World := { canonical := bailout, orphan := exploited }
def afterCoup : World := { canonical := usurper, orphan := genesis }

/-- History, replayed. Trace `[0, 51]`: the drain (strength 0 — the
    code let anyone) is VALID; the rescue is a fork to a chain whose
    past the code forbids. The community kept the rescue. -/
theorem the_dao_fork : ReachW VW [0, 51] initW afterFork := by
  exact .step (.onchain .drain)
          (Or.inl ⟨.drain, rfl, Or.inr ⟨rfl, rfl⟩⟩)
        (.step (.fork bailout)
          (Or.inr ⟨bailout, rfl, by decide⟩) .nil)

/-- The same verb, the other direction: from a healthy chain, a bare
    majority forks to a chain where the treasury is gone and the code
    is whatever they deployed. Compare this derivation to the last —
    same constructor, different argument. Repair and coup are not
    formal categories. The kernel cannot tell them apart; only the
    social layer can, and it is the layer performing them. -/
theorem the_coup_fork : ReachW VW [51] initW afterCoup := by
  exact .step (.fork usurper)
    (Or.inr ⟨usurper, rfl, by decide⟩) .nil

/- ═══════════════════════════════════════════════════════════════════
   THE EPITAPHS — the lineage completes
   ═══════════════════════════════════════════════════════════════════ -/

/-- Movement D's clause survived as ink. The contract survives as a
    RUNNING PROGRAM: deployed, enforcing, byte-identical. The world
    did not break the theorem. It stopped pointing at its subject. -/
theorem code_still_there : afterFork.orphan.contract = genesis.contract := rfl

/-- The orphan is a perfectly lawful history — the exploit included.
    Every safety theorem above remains true of it, forever, for whoever
    is still listening. -/
theorem theft_still_valid_there : ReachC genesis afterFork.orphan :=
  exploit_valid

/-- And the chain everyone uses is the one the code forbids: no valid
    on-chain history reaches the bailout state from genesis. Under
    pure code-is-law, the canonical world is an ILLEGAL state — made
    real by recognition, the one operation the code cannot see. -/
theorem canonical_history_invalid : ¬ ReachC genesis bailout := by
  intro h
  exact Contract.noConfusion (code_is_law genesis bailout h)

/- ═══════════════════════════════════════════════════════════════════
   READING OF MOVEMENT F

   The trilemma does not gain a fourth arm. It loses two, and shows
   its floor. Code-is-law is the perfected Movement C: entrenchment so
   total that the guarded thing is not even mentionable — and this
   genuinely deletes Movement D's interior attack (`code_is_law`,
   `promise_holds_without_fork`). What remains is the exterior form of
   D, undiluted: not "how shall the clause be read?" but "which system
   is the one in force?" — a question no object language contains, and
   so no object language can answer, guard, or price
   (`fork_always_open`). The DAO built C's dream and discovered D had
   been living outside the building all along.

   Two asymmetries survive every formalization in this development:
   the modeller can freeze levels and the system cannot (Movement E);
   and the system can be recognized but cannot recognize itself
   (Movement F). `canonical_history_invalid` is the second asymmetry
   wearing its sharpest clothes: legality is chain-relative, and
   chain-choice is not a chain operation. The rule of recognition was
   never in the text, the code, or the kernel. It is the reader.
   ═══════════════════════════════════════════════════════════════════ -/

end Godel
