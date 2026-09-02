Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$BaseSize = 2170880
$TargetW = 1920
$TargetH = 1080
$AspectScale = ($TargetW / $TargetH) / (4.0 / 3.0)

$Hud = @(
    @{ Offset = 0x1A700C; Original = 0.75;  Target = 0.75  / $AspectScale },
    @{ Offset = 0x1A70EC; Original = 0.65;  Target = 0.65  / $AspectScale },
    @{ Offset = 0x1A7EAC; Original = 0.71;  Target = 0.71  / $AspectScale },
    @{ Offset = 0x1A82B8; Original = 0.72;  Target = 0.72  / $AspectScale },
    @{ Offset = 0x1A82BC; Original = 0.68;  Target = 0.68  / $AspectScale },
    @{ Offset = 0x1A82D0; Original = 0.725; Target = 0.725 / $AspectScale },
    @{ Offset = 0x1A82D4; Original = 0.685; Target = 0.685 / $AspectScale },
    @{ Offset = 0x1A82EC; Original = 0.69;  Target = 0.69  / $AspectScale }
)

function Read-U32([byte[]]$b, [int]$o) { [BitConverter]::ToUInt32($b, $o) }
function Write-U32([byte[]]$b, [int]$o, [uint32]$v) {
    $x = [BitConverter]::GetBytes($v); [Array]::Copy($x, 0, $b, $o, 4)
}
function Read-F32([byte[]]$b, [int]$o) { [BitConverter]::ToSingle($b, $o) }
function Write-F32([byte[]]$b, [int]$o, [single]$v) {
    $x = [BitConverter]::GetBytes($v); [Array]::Copy($x, 0, $b, $o, 4)
}
function Near([double]$a, [double]$b) { [Math]::Abs($a - $b) -lt 0.0001 }

function Find-ResolutionTables([byte[]]$b) {
    $hits = New-Object System.Collections.Generic.List[int]
    for ($i = 0; $i -le $BaseSize - 12; $i++) {
        if ((Read-U32 $b $i) -eq 640 -and (Read-U32 $b ($i+4)) -eq 480 -and (Read-U32 $b ($i+8)) -eq 16) {
            if ($i + 68 -lt $b.Length) { $hits.Add($i) }
        }
    }
    return $hits.ToArray()
}

function Patch-Exe([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { throw 'Файл не найден.' }
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt $BaseSize) { throw "Файл слишком маленький. Ожидается совместимый zanthp.exe не меньше $BaseSize байт." }
    if ($bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) { throw 'Это не Windows EXE (нет сигнатуры MZ).' }

    foreach ($h in $Hud) {
        $cur = Read-F32 $bytes $h.Offset
        if (-not (Near $cur $h.Original) -and -not (Near $cur $h.Target)) {
            throw ('Неизвестная версия HUD в zanthp.exe. Смещение 0x{0:X}: найдено {1}. Файл не изменён.' -f $h.Offset, $cur)
        }
    }

    $tables = @(Find-ResolutionTables $bytes)
    if ($tables.Count -ne 3) {
        throw "Не удалось однозначно найти таблицы разрешений Zanzarah (найдено: $($tables.Count), ожидается: 3). Файл не изменён."
    }

    foreach ($t in $tables) {
        $slot = $t + 12
        $w = Read-U32 $bytes $slot
        $h = Read-U32 $bytes ($slot + 4)
        $bpp = Read-U32 $bytes ($slot + 8)
        if (($w -ne 800 -or $h -ne 600) -and ($w -ne $TargetW -or $h -ne $TargetH)) {
            throw "Слот разрешения уже изменён неизвестным патчем ($w x $h x $bpp). Файл не изменён."
        }
        Write-U32 $bytes $slot $TargetW
        Write-U32 $bytes ($slot + 4) $TargetH
    }

    foreach ($h in $Hud) { Write-F32 $bytes $h.Offset ([single]$h.Target) }

    $backup = "$path.zdf.bak"
    if (-not (Test-Path -LiteralPath $backup)) { [IO.File]::Copy($path, $backup, $false) }
    [IO.File]::WriteAllBytes($path, $bytes)
    return $backup
}

$form = New-Object Windows.Forms.Form
$form.Text = 'Zanzarah Display Fixer v0.1.0'
$form.Size = New-Object Drawing.Size(620,245)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$title = New-Object Windows.Forms.Label
$title.Text = 'Zanzarah: 1920x1080 + Battle HUD Fix'
$title.Font = New-Object Drawing.Font('Segoe UI', 14, [Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object Drawing.Point(18,16)
$form.Controls.Add($title)

$desc = New-Object Windows.Forms.Label
$desc.Text = "Добавляет 1920x1080 в zanthp.exe и исправляет боевой HUD:`r`nHP, энергию прыжка, выбранные заклинания и оставшиеся заряды."
$desc.AutoSize = $true
$desc.Location = New-Object Drawing.Point(20,52)
$form.Controls.Add($desc)

$text = New-Object Windows.Forms.TextBox
$text.Location = New-Object Drawing.Point(20,100)
$text.Size = New-Object Drawing.Size(465,25)
$text.ReadOnly = $true
$form.Controls.Add($text)

$browse = New-Object Windows.Forms.Button
$browse.Text = 'Выбрать zanthp.exe'
$browse.Location = New-Object Drawing.Point(493,98)
$browse.Size = New-Object Drawing.Size(105,28)
$form.Controls.Add($browse)

$apply = New-Object Windows.Forms.Button
$apply.Text = 'Применить фикс'
$apply.Location = New-Object Drawing.Point(20,143)
$apply.Size = New-Object Drawing.Size(180,36)
$apply.Enabled = $false
$form.Controls.Add($apply)

$status = New-Object Windows.Forms.Label
$status.Text = 'Выберите zanthp.exe.'
$status.AutoSize = $true
$status.Location = New-Object Drawing.Point(215,153)
$form.Controls.Add($status)

$browse.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Title = 'Выберите zanthp.exe'
    $dlg.Filter = 'Zanzarah executable (zanthp.exe)|zanthp.exe|EXE files (*.exe)|*.exe'
    $dlg.FileName = 'zanthp.exe'
    if ($dlg.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $text.Text = $dlg.FileName
        $apply.Enabled = $true
        $status.Text = 'Готово к применению.'
    }
})

$apply.Add_Click({
    try {
        $apply.Enabled = $false
        $status.Text = 'Патчим...'
        $bak = Patch-Exe $text.Text
        $status.Text = 'Готово. 1920x1080 + HUD fix применены.'
        [Windows.Forms.MessageBox]::Show(
            "Готово!`r`n`r`n1920x1080 добавлено.`r`nBattle HUD исправлен.`r`n`r`nРезервная копия:`r`n$bak",
            'Zanzarah Display Fixer', 'OK', 'Information') | Out-Null
    } catch {
        $status.Text = 'Ошибка. Файл не изменён.'
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Zanzarah Display Fixer', 'OK', 'Error') | Out-Null
    } finally {
        $apply.Enabled = $true
    }
})

[void]$form.ShowDialog()
