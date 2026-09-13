param([string]$gameroot = "d:\steam\steamapps\common\zanzarah")
$ErrorActionPreference = "Stop"
$backupdir = Join-Path $gameroot "zms_backup"
$cleanexe = Join-Path $backupdir "zanthp_clean.exe"
$cleanpak = Join-Path $gameroot "localization\pak\en.pak"
$binkbackup = Join-Path $backupdir "binkw32_original.dll"
if (!(Test-Path -LiteralPath $cleanexe)) { throw "clean exe backup not found: $cleanexe" }
if (!(Test-Path -LiteralPath $cleanpak)) { throw "clean pak backup not found: $cleanpak" }
Copy-Item -LiteralPath $cleanexe -Destination (Join-Path $gameroot "system\zanthp.exe") -Force
Copy-Item -LiteralPath $cleanpak -Destination (Join-Path $gameroot "resources\data_0.pak") -Force
if (Test-Path -LiteralPath $binkbackup) { Copy-Item -LiteralPath $binkbackup -Destination (Join-Path $gameroot "system\binkw32.dll") -Force }
foreach ($name in @("D3D8.dll","D3DImm.dll","DDraw.dll","dgVoodooCpl.exe")) {
    $backup = Join-Path $backupdir ("original_" + $name)
    if (Test-Path -LiteralPath $backup) { Copy-Item -LiteralPath $backup -Destination (Join-Path $gameroot "system\$name") -Force }
}
Remove-Item -LiteralPath (Join-Path $gameroot "system\zms_language_exp41.dll") -Force -ErrorAction SilentlyContinue
Write-Host "[zms] clean exe and english pak restored."
