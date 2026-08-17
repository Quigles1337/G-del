#!/usr/bin/env pwsh
# Full verification (Windows). Mirrors scripts/verify.sh.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

Write-Host '== [1/5] lake build (library + receipts) =='
lake build
if ($LASTEXITCODE -ne 0) { throw 'lake build failed' }

Write-Host '== [2/5] lake exe godel (certified checker) =='
lake exe godel | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'lake exe godel failed' }
Write-Host '   ok'

Write-Host '== [3/5] standalone single-file edition =='
lean standalone/Godel.lean | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'standalone check failed' }
Write-Host '   ok'

Write-Host '== [4/5] sorry sweep =='
$hits = Get-ChildItem -Recurse -Filter *.lean |
  Where-Object { $_.FullName -notmatch '\.lake' } |
  Select-String -Pattern 'sorry' |
  Where-Object { $_.Line -notmatch 'sorryAx' }
if ($hits) { $hits; throw "'sorry' found in Lean sources" }
Write-Host '   ok'

Write-Host '== [5/5] standalone/library parity =='
function Get-TheoremNames { param($Paths)
  ($Paths | ForEach-Object { Select-String -Path $_ -Pattern "^theorem\s+([A-Za-z_][A-Za-z0-9_']*)" |
     ForEach-Object { $_.Matches[0].Groups[1].Value } }) | Sort-Object
}
$lib   = Get-TheoremNames @('Godel/MovementA.lean','Godel/MovementB.lean','Godel/MovementC.lean',
                           'Godel/MovementD.lean','Godel/MovementE.lean','Godel/MovementF.lean')
$alone = Get-TheoremNames @('standalone/Godel.lean')
if (Compare-Object $lib $alone) {
  Compare-Object $lib $alone | Format-Table | Out-String | Write-Host
  throw 'PARITY FAIL: standalone and library disagree'
}
Write-Host "   parity ok ($($lib.Count) theorems in both editions)"

Write-Host ''
Write-Host 'VERIFIED. Kernel-checked, axiom ledger enforced, zero sorry, editions in parity.'
