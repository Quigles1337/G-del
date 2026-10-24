#!/usr/bin/env bash
# THEOREMS.md promises that every theorem in the library has exactly one
# receipt in Godel/Receipts.lean. This enforces it: the theorem names
# declared in Godel/*.lean — `private` and other modifiers included —
# must match the names under `#print axioms` in the ledger, one for one.
# A theorem with no receipt, a receipt with no theorem, or a receipt
# listed twice fails the check.
#
# Comments are stripped first, so a docstring line that happens to begin
# with the word "theorem" is not mistaken for a declaration.
set -euo pipefail
cd "$(dirname "$0")/.."

# Lean source with comments removed: nestable /- ... -/ blocks (so /--
# and /-! too) and -- line comments. String literals are stepped over,
# so a "--" inside one is kept.
strip_comments() {
  LC_ALL=C awk '
    BEGIN { depth = 0; instr = 0 }
    {
      line = $0; out = ""; i = 1; n = length(line)
      while (i <= n) {
        c = substr(line, i, 1); c2 = substr(line, i, 2)
        if (depth > 0) {
          if (c2 == "/-") { depth++; i += 2; continue }
          if (c2 == "-/") { depth--; i += 2; continue }
          i++; continue
        }
        if (instr) {
          out = out c
          if (c == "\\") { out = out substr(line, i + 1, 1); i += 2; continue }
          if (c == "\"") instr = 0
          i++; continue
        }
        if (c2 == "/-") { depth = 1; i += 2; continue }
        if (c2 == "--") break
        if (c == "\"") instr = 1
        out = out c; i++
      }
      print out
    }' "$@"
}

declared=$(strip_comments Godel/*.lean |
  sed -nE 's/^[[:space:]]*(@\[[^]]*\][[:space:]]*)*((private|protected|noncomputable|nonrec|unsafe)[[:space:]]+)*theorem[[:space:]]+([^[:space:]:({]+).*/\4/p' |
  sort)
receipted=$(strip_comments Godel/Receipts.lean |
  sed -nE 's/^[[:space:]]*#print[[:space:]]+axioms[[:space:]]+([^[:space:]]+).*/\1/p' |
  sed 's/^Godel\.//' |
  sort)

if [ -z "$declared" ]; then
  echo "RECEIPTS FAIL: no theorem declarations found in Godel/*.lean."
  exit 1
fi

if [ "$declared" != "$receipted" ]; then
  echo "RECEIPTS FAIL: Godel/*.lean and Godel/Receipts.lean disagree."
  echo "  < declared, no receipt     > receipt, no theorem (or listed twice)"
  diff <(echo "$declared") <(echo "$receipted") || true
  exit 1
fi

echo "receipts ok ($(echo "$declared" | wc -l | tr -d ' ') theorems, one receipt each)"
