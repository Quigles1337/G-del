#!/usr/bin/env bash
# The standalone single-file edition and the modular library under
# Godel/ hold the same seven movements. This checks their THEOREM NAMES
# agree, so the pasteable copy cannot quietly lose a result.
#
# It does NOT check the proofs are identical — see docs/LIMITATIONS.md §9.
# Godel/Executable.lean and Godel/Receipts.lean are library-only and are
# deliberately excluded.
set -euo pipefail
cd "$(dirname "$0")/.."

names() { grep -hoE '^theorem [A-Za-z_][A-Za-z0-9_'"'"']*' "$@" | awk '{print $2}' | sort; }

lib=$(names Godel/MovementA.lean Godel/MovementB.lean Godel/MovementC.lean \
            Godel/MovementD.lean Godel/MovementE.lean Godel/MovementF.lean \
            Godel/MovementG.lean)
alone=$(names standalone/Godel.lean)

if [ "$lib" != "$alone" ]; then
  echo "PARITY FAIL: standalone/Godel.lean and Godel/Movement*.lean disagree."
  diff <(echo "$lib") <(echo "$alone") || true
  exit 1
fi

echo "parity ok ($(echo "$lib" | wc -l | tr -d ' ') theorems in both editions)"
