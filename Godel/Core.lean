/-
Required Notice: Copyright 2026 Alexander David Zalewski (https://github.com/Quigles1337/G-del)
SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
Licensed under the PolyForm Noncommercial License 1.0.0:
https://polyformproject.org/licenses/noncommercial/1.0.0
-/
/-
  Godel.Core — the object system.

  A constitution modelled as a state machine whose *rule of change* is
  itself part of the state. Everything downstream (Movements A–D) varies
  exactly one thing: the validity predicate `V` that says which
  amendments are legally adoptable.

  Core Lean 4 only. No mathlib.
-/

namespace Godel

/-- Amendment procedures, by the strength required to invoke them.
    `cost` is the share of the legislature the proposing coalition needs.
    (`decree` = the executive alone suffices: cost 0.) -/
inductive Rule where
  | supermajority
  | simpleMajority
  | decree
deriving Repr, DecidableEq

def Rule.cost : Rule → Nat
  | .supermajority  => 67
  | .simpleMajority => 51
  | .decree         => 0

/-- The constitutional state.
    `eternity`     — is an entrenchment clause present in the text?
    `strictInterp` — do the recognizing institutions read that clause
                     as binding? (Movement D makes this mutable.) -/
structure State where
  rule          : Rule
  eternity      : Bool
  strictInterp  : Bool
  freeElections : Bool
  dictatorship  : Bool
deriving Repr, DecidableEq

/-- 1789, more or less. -/
def init : State :=
  { rule := .supermajority, eternity := true, strictInterp := true,
    freeElections := true, dictatorship := false }

/-- One amendment touches one provision. `skip` = a session in which
    nothing passes (needed so "the majority can't act" is expressible). -/
inductive Amend where
  | skip
  | setRule         (r : Rule)
  | setEternity     (b : Bool)
  | setInterp       (b : Bool)
  | setElections    (b : Bool)
  | setDictatorship (b : Bool)
deriving Repr, DecidableEq

def Amend.apply : Amend → State → State
  | .skip,             s => s
  | .setRule r,        s => { s with rule := r }
  | .setEternity b,    s => { s with eternity := b }
  | .setInterp b,      s => { s with strictInterp := b }
  | .setElections b,   s => { s with freeElections := b }
  | .setDictatorship b, s => { s with dictatorship := b }

/-- The substantive attacks an entrenchment clause forbids. -/
def coreAttack : Amend → Bool
  | .setDictatorship true => true
  | .setElections false   => true
  | _                     => false

/-- The reflexive attack: repealing the entrenchment clause itself. -/
def selfAttack : Amend → Bool
  | .setEternity false => true
  | _                  => false

/-- Reachability along a trace of session-strengths, relative to a
    validity regime `V`.  `V n s a` reads: "with coalition strength `n`,
    in state `s`, amendment `a` is legally adoptable." -/
inductive Reach (V : Nat → State → Amend → Prop) :
    List Nat → State → State → Prop where
  | nil  {s} : Reach V [] s s
  | step {n ns s t} (a : Amend)
      (hv : V n s a) (h : Reach V ns (a.apply s) t) :
      Reach V (n :: ns) s t

end Godel
