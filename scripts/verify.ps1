#!/usr/bin/env pwsh
# Full verification (Windows). Mirrors scripts/verify.sh.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

Write-Host '== [1/6] lake build (library + receipts) =='
lake build
if ($LASTEXITCODE -ne 0) { throw 'lake build failed' }

Write-Host '== [2/6] lake exe godel (certified checker) =='
lake exe godel | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'lake exe godel failed' }
Write-Host '   ok'

Write-Host '== [3/6] standalone single-file edition =='
lean standalone/Godel.lean | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'standalone check failed' }
Write-Host '   ok'

Write-Host '== [4/6] sorry sweep =='
$hits = Get-ChildItem -Recurse -Filter *.lean |
  Where-Object { $_.FullName -notmatch '\.lake' } |
  Select-String -Pattern 'sorry' |
  Where-Object { $_.Line -notmatch 'sorryAx' }
if ($hits) { $hits; throw "'sorry' found in Lean sources" }
Write-Host '   ok'

Write-Host '== [5/6] standalone/library parity =='
function Get-TheoremNames { param($Paths)
  ($Paths | ForEach-Object { Select-String -Path $_ -Pattern "^theorem\s+([A-Za-z_][A-Za-z0-9_']*)" |
     ForEach-Object { $_.Matches[0].Groups[1].Value } }) | Sort-Object
}
$lib   = Get-TheoremNames @('Godel/MovementA.lean','Godel/MovementB.lean','Godel/MovementC.lean',
                           'Godel/MovementD.lean','Godel/MovementE.lean','Godel/MovementF.lean',
                           'Godel/MovementG.lean')
$alone = Get-TheoremNames @('standalone/Godel.lean')
if (Compare-Object $lib $alone) {
  Compare-Object $lib $alone | Format-Table | Out-String | Write-Host
  throw 'PARITY FAIL: standalone and library disagree'
}
Write-Host "   parity ok ($($lib.Count) theorems in both editions)"

Write-Host '== [6/6] one receipt per theorem =='
# Mirrors scripts/check-receipts.sh: strip comments (nestable /- -/ and
# --, stepping over string literals), then the theorem names declared in
# Godel/*.lean must equal the names under #print axioms in the ledger.
function Remove-LeanComments { param([string]$Text)
  $sb = [System.Text.StringBuilder]::new()
  $depth = 0; $inStr = $false; $i = 0; $n = $Text.Length
  while ($i -lt $n) {
    $c = $Text[$i]
    $two = if ($i + 1 -lt $n) { $Text.Substring($i, 2) } else { [string]$c }
    if ($depth -gt 0) {
      if ($two -eq '/-') { $depth++; $i += 2; continue }
      if ($two -eq '-/') { $depth--; $i += 2; continue }
      if ($c -eq "`n") { [void]$sb.Append($c) }
      $i++; continue
    }
    if ($inStr) {
      [void]$sb.Append($c)
      if ($c -eq '\' -and $i + 1 -lt $n) { [void]$sb.Append($Text[$i + 1]); $i += 2; continue }
      if ($c -eq '"') { $inStr = $false }
      $i++; continue
    }
    if ($two -eq '/-') { $depth = 1; $i += 2; continue }
    if ($two -eq '--') { while ($i -lt $n -and $Text[$i] -ne "`n") { $i++ }; continue }
    if ($c -eq '"') { $inStr = $true }
    [void]$sb.Append($c); $i++
  }
  $sb.ToString()
}
$declRe = '(?m)^[ \t]*(?:@\[[^\]]*\][ \t]*)*(?:(?:private|protected|noncomputable|nonrec|unsafe)[ \t]+)*theorem[ \t]+([^\s:({]+)'
$rcptRe = '(?m)^[ \t]*#print[ \t]+axioms[ \t]+(\S+)'
$declared = @(Get-ChildItem Godel -Filter *.lean | ForEach-Object {
    [regex]::Matches((Remove-LeanComments (Get-Content -Raw -Encoding UTF8 $_.FullName)), $declRe) |
      ForEach-Object { $_.Groups[1].Value } }) | Sort-Object -CaseSensitive
$receipted = @([regex]::Matches((Remove-LeanComments (Get-Content -Raw -Encoding UTF8 'Godel/Receipts.lean')), $rcptRe) |
    ForEach-Object { $_.Groups[1].Value -replace '^Godel\.', '' }) | Sort-Object -CaseSensitive
if ($declared.Count -eq 0) { throw 'RECEIPTS FAIL: no theorem declarations found in Godel/*.lean' }
$diff = Compare-Object $declared $receipted -CaseSensitive
if ($diff) {
  Write-Host '   <= declared, no receipt     => receipt, no theorem (or listed twice)'
  $diff | Format-Table | Out-String | Write-Host
  throw 'RECEIPTS FAIL: Godel/*.lean and Godel/Receipts.lean disagree'
}
Write-Host "   receipts ok ($($declared.Count) theorems, one receipt each)"

Write-Host ''
Write-Host 'VERIFIED. Kernel-checked, axiom ledger enforced, zero sorry, editions in parity,'
Write-Host 'every theorem receipted.'
