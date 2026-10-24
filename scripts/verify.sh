#!/usr/bin/env bash
# Full verification. Exits non-zero on any failure.
#   1. lake build      — kernel-checks the library AND enforces the axiom
#                        ledger in Godel/Receipts.lean (#guard_msgs)
#   2. lake exe godel  — runs the certified checker
#   3. lean standalone — checks the single-file edition
#   4. sorry sweep     — belt-and-braces; the ledger already catches sorryAx
#   5. parity          — the two editions declare the same theorems
#   6. receipts        — every theorem has exactly one receipt in the ledger
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== [1/6] lake build (library + receipts) =="
lake build

echo "== [2/6] lake exe godel (certified checker) =="
lake exe godel > /dev/null
echo "   ok"

echo "== [3/6] standalone single-file edition =="
lean standalone/Godel.lean > /dev/null
echo "   ok"

echo "== [4/6] sorry sweep =="
if grep -rn 'sorry' --include='*.lean' . | grep -v 'sorryAx' | grep -v '^\./\.lake/'; then
  echo "   FAIL: 'sorry' found in Lean sources"
  exit 1
fi
echo "   ok"

echo "== [5/6] standalone/library parity =="
bash scripts/check-parity.sh

echo "== [6/6] one receipt per theorem =="
bash scripts/check-receipts.sh

echo
echo "VERIFIED. Kernel-checked, axiom ledger enforced, zero sorry, editions in parity,"
echo "every theorem receipted."
