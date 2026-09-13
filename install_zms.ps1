param([string]$gameroot = "")

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($gameroot) -or !(Test-Path -LiteralPath $gameroot)) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Выберите папку Steam игры ZanZarah"
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 1 }
    $gameroot = $dialog.SelectedPath
}
$gameroot = $gameroot.TrimEnd('\','/')
$cleanExeHash = "1e90cb72ab83c88c74bf3488d9c9e56dd9fd18abf6e66c4fe98f375b9f6e2cdc"
$languageExeHash = "079146303da352df5b83e846c8acb44e0a4f481990027c717345da3949389c0e"
$displayFixerExeHash = "285756c3745dd1f801819b7ff9f92dafbfea96438f0759d903e5d925f82e3000"
$cleanPakHash = "c1ce0ab5fbaf0e4ef9e03461070865314743689531e959083f6460b938334432"
$ruPakHash = "4f348acfa91e87f99cb73945eb841b2e0040bc46340f4ccc7370d77fcb18ea44"

function hash([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() }
function log([string]$text) { Write-Host "[zms] $text" }

$scriptdir = Split-Path -Parent $MyInvocation.MyCommand.Path
$systemdir = Join-Path $gameroot "system"
$datadir = Join-Path $gameroot "data"
$resourcesdir = Join-Path $gameroot "resources"
$localizationdir = Join-Path $gameroot "localization"
$pakdir = Join-Path $localizationdir "pak"
$backupdir = Join-Path $gameroot "zms_backup"
$exe = Join-Path $systemdir "zanthp.exe"
$pak = Join-Path $resourcesdir "data_0.pak"
$payloadexe = Join-Path $scriptdir "zanthp_language.exe"
$payloaddll = Join-Path $scriptdir "zms_language_exp41.dll"
$compatbink = Join-Path $scriptdir "binkw32_compat.dll"
$displaydir = Join-Path $scriptdir "display_fixer"
$builder = Join-Path $scriptdir "build_overlay_pak.ps1"
$existingCleanExe = Join-Path $systemdir "zanthp_zms_original.exe"

Write-Host ""
Write-Host "zanzarah patch - display fixer + english + russian + ukrainian + czech + polish + french"
Write-Host ""

foreach ($required in @($exe, $pak, $payloadexe, $payloaddll, $builder, $compatbink, (Join-Path $displaydir "D3D8.dll"), (Join-Path $displaydir "D3DImm.dll"), (Join-Path $displaydir "DDraw.dll"), (Join-Path $displaydir "dgVoodooCpl.exe"))) {
    if (!(Test-Path -LiteralPath $required -PathType Leaf)) { throw "required file not found: $required" }
}

$exeHash = hash $exe
if ($exeHash -notin @($cleanExeHash, $languageExeHash, $displayFixerExeHash)) { throw "unsupported zanthp.exe sha256: $exeHash" }
if ((hash $payloadexe) -ne $languageExeHash) { throw "corrupt language-enabled zanthp.exe" }

New-Item -ItemType Directory -Force -Path $localizationdir,$pakdir,$backupdir | Out-Null

$bink = Join-Path $systemdir "binkw32.dll"
$binkbackup = Join-Path $backupdir "binkw32_original.dll"
if (!(Test-Path -LiteralPath $binkbackup -PathType Leaf)) { Copy-Item -LiteralPath $bink -Destination $binkbackup -Force }
Copy-Item -LiteralPath $compatbink -Destination $bink -Force
$displayFiles = @("D3D8.dll","D3DImm.dll","DDraw.dll","dgVoodooCpl.exe")
foreach ($name in $displayFiles) {
    $target = Join-Path $systemdir $name
    $backup = Join-Path $backupdir ("original_" + $name)
    if (!(Test-Path -LiteralPath $backup -PathType Leaf) -and (Test-Path -LiteralPath $target -PathType Leaf)) { Copy-Item -LiteralPath $target -Destination $backup -Force }
    Copy-Item -LiteralPath (Join-Path $displaydir $name) -Destination $target -Force
}

$backupExe = Join-Path $backupdir "zanthp_clean.exe"
if (!(Test-Path -LiteralPath $backupExe)) {
    if ($exeHash -eq $cleanExeHash) {
        Copy-Item -LiteralPath $exe -Destination $backupExe
    } elseif ((Test-Path -LiteralPath $existingCleanExe -PathType Leaf) -and ((hash $existingCleanExe) -eq $cleanExeHash)) {
        log "using existing clean exe backup from system\zanthp_zms_original.exe"
        Copy-Item -LiteralPath $existingCleanExe -Destination $backupExe
    } elseif (($exeHash -eq $displayFixerExeHash) -and (Test-Path -LiteralPath "$exe.zdf.bak" -PathType Leaf) -and ((hash "$exe.zdf.bak") -eq $cleanExeHash)) {
        log "using clean backup from Display Fixer: zanthp.exe.zdf.bak"
        Copy-Item -LiteralPath "$exe.zdf.bak" -Destination $backupExe
    } else {
        throw "clean exe backup is missing; verify game files in steam first"
    }
}
if ((hash $backupExe) -ne $cleanExeHash) { throw "invalid clean exe backup: $backupExe" }

$enPak = Join-Path $pakdir "en.pak"
if (!(Test-Path -LiteralPath $enPak)) {
    $pakHash = hash $pak
    if ($pakHash -eq $cleanPakHash) {
        log "saving clean english pak (about 774 mb)..."
        Copy-Item -LiteralPath $pak -Destination $enPak
    } else {
        $cleanPakSource = $null
        $searchDirs = @($resourcesdir, "d:\steam\steamapps\common\zanzarah\resources") | Select-Object -Unique
        $candidates = @()
        foreach ($searchDir in $searchDirs) {
            if (Test-Path -LiteralPath $searchDir -PathType Container) {
                $candidates += Get-ChildItem -LiteralPath $searchDir -File -Force | Where-Object { $_.Name -like "data_0*" }
            }
        }
        foreach ($candidate in $candidates) {
            if ((Test-Path -LiteralPath $candidate.FullName -PathType Leaf) -and ((hash $candidate.FullName) -eq $cleanPakHash)) {
                $cleanPakSource = $candidate.FullName
                break
            }
        }
        if ($null -eq $cleanPakSource) { throw "clean steam data_0.pak required; actual sha256: $pakHash" }
        log "using existing clean english pak backup: $cleanPakSource"
        Copy-Item -LiteralPath $cleanPakSource -Destination $enPak
    }
}
if ((hash $enPak) -ne $cleanPakHash) { throw "invalid english pak backup: $enPak" }

log "installing language payload..."
foreach ($lang in @("en", "ru", "uk", "cz", "pl", "fr")) {
    $source = Join-Path $scriptdir "localization\$lang"
    if (!(Test-Path -LiteralPath $source -PathType Container)) { throw "language payload not found: $source" }
    Copy-Item -Path (Join-Path $source "*") -Destination (New-Item -ItemType Directory -Force -Path (Join-Path $localizationdir $lang)) -Recurse -Force
}
$czPayload = Join-Path $scriptdir "localization\cz"
foreach ($required in @("_fb0x02.fbs", "_fb0x06.fbs", "RESOURCES\BITMAPS\FNT000M.BMP", "RESOURCES\BITMAPS\FNT000T.BMP", "RESOURCES\BITMAPS\FNT001M.BMP", "RESOURCES\BITMAPS\FNT001T.BMP", "RESOURCES\BITMAPS\FNT002M.BMP", "RESOURCES\BITMAPS\FNT002T.BMP", "RESOURCES\BITMAPS\FNT003M.BMP", "RESOURCES\BITMAPS\FNT003T.BMP", "RESOURCES\BITMAPS\FNT004M.BMP", "RESOURCES\BITMAPS\FNT004T.BMP")) {
    if (!(Test-Path -LiteralPath (Join-Path $czPayload $required) -PathType Leaf)) { throw "czech payload file not found: $(Join-Path $czPayload $required)" }
}
$plPayload = Join-Path $scriptdir "localization\pl"
foreach ($required in @("_fb0x02.fbs", "_fb0x06.fbs")) {
    if (!(Test-Path -LiteralPath (Join-Path $plPayload $required) -PathType Leaf)) { throw "polish payload file not found: $(Join-Path $plPayload $required)" }
}
$frPayload = Join-Path $scriptdir "localization\fr"
foreach ($required in @("_fb0x02.fbs", "_fb0x06.fbs", "System\binkw32.dll")) {
    if (!(Test-Path -LiteralPath (Join-Path $frPayload $required) -PathType Leaf)) { throw "french payload file not found: $(Join-Path $frPayload $required)" }
}
if (!(Test-Path -LiteralPath (Join-Path $frPayload "video") -PathType Container) -or ((Get-ChildItem -LiteralPath (Join-Path $frPayload "video") -Filter "*.bik" -File).Count -ne 9)) {
    throw "french payload must contain 9 video files"
}
if (!(Test-Path -LiteralPath (Join-Path $frPayload "audio\SFX\VOICES\AMY") -PathType Container) -or ((Get-ChildItem -LiteralPath (Join-Path $frPayload "audio\SFX\VOICES\AMY") -Filter "*.WAV" -File).Count -ne 30)) {
    throw "french payload must contain 30 voice files"
}
$overlay = Join-Path $scriptdir "localization\overlay_ru"
if (!(Test-Path -LiteralPath $overlay -PathType Container)) { throw "russian overlay not found: $overlay" }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $builder -basepak $enPak -overlaydir $overlay -output (Join-Path $pakdir "ru.pak")
Copy-Item -LiteralPath (Join-Path $scriptdir "localization\zms_apply_language.ps1") -Destination $localizationdir -Force
Copy-Item -LiteralPath $payloaddll -Destination (Join-Path $systemdir "zms_language_exp41.dll") -Force
Copy-Item -LiteralPath $payloadexe -Destination $exe -Force

Copy-Item -Path (Join-Path $localizationdir "en\*.fbs") -Destination $datadir -Force
Copy-Item -LiteralPath $enPak -Destination $pak -Force
Set-Content -LiteralPath (Join-Path $localizationdir "zms_language.ini") -Encoding ascii -Value "[zms]`r`nlanguage=en"

Write-Host ""
log "installed successfully; active language: english"
Write-Host "Start with Steam, open Settings, select English, Russian, Ukrainian, Czech, Polish, or French, and press Apply."


