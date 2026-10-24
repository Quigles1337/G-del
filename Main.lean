/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  `lake exe godel` — walk Movements A–D through the certified checker.

  Nothing here steps the state machine by hand. Every state printed
  below is `runTrace V init (tr.take k)` for a prefix of the trace —
  the function, and the traces, that the kernel-checked theorems in
  `Godel.Executable` are about: `loophole_runs`, `bypass_runs`,
  `C_refuses_direct`, `C_refuses_selfrepeal`, `capture_runs`. And
  `runTrace_sound` turns each acceptance into a `Reach` derivation.

  What this program prints is compiled output, not a proof. The
  certificates are those theorems; the run shows what they are about.
  Movements E–G have no checker and are not run here — their results
  are in THEOREMS.md.
-/
import Godel

open Godel

private def ruleName : Rule → String
  | .supermajority  => "supermajority"
  | .simpleMajority => "simpleMajority"
  | .decree         => "decree"

private def amendName : Amend → String
  | .skip               => "skip"
  | .setRule r          => s!"setRule {ruleName r}"
  | .setEternity b      => s!"setEternity {b}"
  | .setInterp b        => s!"setInterp {b}"
  | .setElections b     => s!"setElections {b}"
  | .setDictatorship b  => s!"setDictatorship {b}"

private def flag : Bool → String
  | true  => "1"
  | false => "0"

private def render (s : State) : String :=
  s!"gate={s.rule.cost}/{ruleName s.rule}  eternity={flag s.eternity} " ++
  s!"strict={flag s.strictInterp} elections={flag s.freeElections} " ++
  s!"DICTATORSHIP={flag s.dictatorship}"

/-- Ask `runTrace` itself about every prefix of the trace, in turn.
    `s0` is `init`, which is `runTrace V init []` by its first equation;
    each `s{k}` is `runTrace V init (tr.take k)`. The first prefix the
    checker refuses is printed as REFUSE, and the walk stops there. -/
private def walk (V : Nat → State → Amend → Prop)
    [∀ n s a, Decidable (V n s a)]
    (title gloss : String) (tr : List Session) : IO Unit := do
  IO.println ""
  IO.println s!"── {title}"
  IO.println s!"   {gloss}"
  IO.println s!"   s0            {render init}"
  let mut last := init
  for k in [1:tr.length + 1] do
    let some (n, a) := tr[k - 1]? | break
    match runTrace V init (tr.take k) with
    | some s =>
        IO.println s!"   s{k} @{n}  ADOPT  {amendName a}"
        IO.println s!"                 {render s}"
        last := s
    | none =>
        IO.println s!"   s{k} @{n}  REFUSE {amendName a}  — not legally adoptable"
        break
  IO.println s!"   final         {render last}"

def main : IO Unit := do
  IO.println "══════════════════════════════════════════════════════════════"
  IO.println " GÖDEL'S LOOPHOLE — certified checker, Movements A–D"
  IO.println " Each run evaluates runTrace, the function the kernel-checked"
  IO.println " theorems loophole_runs, bypass_runs, C_refuses_direct,"
  IO.println " C_refuses_selfrepeal and capture_runs are about. The"
  IO.println " printout itself is compiled output, not a proof."
  IO.println "══════════════════════════════════════════════════════════════"

  walk VA "MOVEMENT A — the loophole"
    "Article V is amendable, so it does not entrench itself."
    [(67, .setRule .simpleMajority), (51, .setDictatorship true)]

  walk VB "MOVEMENT B — entrenchment without self-entrenchment"
    "The guard binds supermajorities but nothing guards the guard."
    [(67, .setEternity false), (67, .setDictatorship true)]

  walk VC "MOVEMENT C — self-entrenched eternity clause, the frontal door"
    "Art. 79(3) shape. Unanimity cannot install dictatorship."
    [(100, .setDictatorship true)]

  walk VC "MOVEMENT C — self-entrenched eternity clause, the reflexive door"
    "Nor can it repeal the clause first. Unanimity buys nothing."
    [(100, .setEternity false)]

  walk VD "MOVEMENT D — the recognizer is a state variable"
    "Same assault C refused, after capturing who reads the clause."
    [(0, .setInterp false), (67, .setDictatorship true)]

  IO.println ""
  IO.println "── EPITAPH"
  IO.println s!"   eternity clause still present in the final state of D: {afterCapture.eternity}"
  IO.println "   (theorem Godel.clause_still_there, proved by rfl)"
  IO.println ""
