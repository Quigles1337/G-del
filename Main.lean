/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  `lake exe godel` — walk each movement through the certified checker.

  Nothing here is decorative. Every ACCEPT printed below corresponds to
  a theorem in `Godel.Executable` that the kernel has already checked,
  and `runTrace_sound` turns each acceptance into a `Reach` derivation.
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

private def walk (V : Nat → State → Amend → Prop)
    [∀ n s a, Decidable (V n s a)]
    (title gloss : String) (tr : List Session) : IO Unit := do
  IO.println ""
  IO.println s!"── {title}"
  IO.println s!"   {gloss}"
  IO.println s!"   s0            {render init}"
  let mut s := init
  let mut i := 1
  let mut halted := false
  for (n, a) in tr do
    if !halted then
      if V n s a then
        s := a.apply s
        IO.println s!"   s{i} @{n}  ADOPT  {amendName a}"
        IO.println s!"                 {render s}"
      else
        IO.println s!"   s{i} @{n}  REFUSE {amendName a}  — not legally adoptable"
        halted := true
      i := i + 1
  IO.println s!"   final         {render s}"

def main : IO Unit := do
  IO.println "══════════════════════════════════════════════════════════════"
  IO.println " GÖDEL'S LOOPHOLE — certified checker"
  IO.println " Each ACCEPT below is a kernel-checked theorem, not a print."
  IO.println "══════════════════════════════════════════════════════════════"

  walk VA "MOVEMENT A — the loophole"
    "Article V is amendable, so it does not entrench itself."
    [(67, .setRule .simpleMajority), (51, .setDictatorship true)]

  walk VB "MOVEMENT B — entrenchment without self-entrenchment"
    "The guard binds supermajorities but nothing guards the guard."
    [(67, .setEternity false), (67, .setDictatorship true)]

  walk VC "MOVEMENT C — self-entrenched eternity clause"
    "Art. 79(3) shape. Unanimity buys nothing; both doors are shut."
    [(100, .setDictatorship true), (100, .setEternity false)]

  walk VD "MOVEMENT D — the recognizer is a state variable"
    "Same assault C refused, after capturing who reads the clause."
    [(0, .setInterp false), (67, .setDictatorship true)]

  IO.println ""
  IO.println "── EPITAPH"
  IO.println s!"   eternity clause still present in the final state of D: {afterCapture.eternity}"
  IO.println "   (theorem Godel.clause_still_there, proved by rfl)"
  IO.println ""
