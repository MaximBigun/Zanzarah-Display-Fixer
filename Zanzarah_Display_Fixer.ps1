Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$TargetW = 1920
$TargetH = 1080

$Profiles = @(
    @{
        Name = 'Legacy'
        MinSize = 2170880
        ExactSize = $null

        Hud = @(
            @{ Offset = 0x1A700C; Original = 0.75;  Target = 0.5625 },
            @{ Offset = 0x1A70EC; Original = 0.65;  Target = 0.4875 },
            @{ Offset = 0x1A7EAC; Original = 0.71;  Target = 0.5325 },
            @{ Offset = 0x1A82B8; Original = 0.72;  Target = 0.54 },
            @{ Offset = 0x1A82BC; Original = 0.68;  Target = 0.51 },
            @{ Offset = 0x1A82D0; Original = 0.725; Target = 0.54375 },
            @{ Offset = 0x1A82D4; Original = 0.685; Target = 0.51375 },
            @{ Offset = 0x1A82EC; Original = 0.69;  Target = 0.5175 }
        )
    },

    @{
        Name = 'Steam'
        MinSize = $null
        ExactSize = 2166784

        Hud = @(
            @{ Offset = 0x1A5FCC; Original = 0.75;  Target = 0.5625 },
            @{ Offset = 0x1A60AC; Original = 0.65;  Target = 0.4875 },
            @{ Offset = 0x1A6E6C; Original = 0.71;  Target = 0.5325 },
            @{ Offset = 0x1A7278; Original = 0.72;  Target = 0.54 },
            @{ Offset = 0x1A727C; Original = 0.68;  Target = 0.51 },
            @{ Offset = 0x1A7290; Original = 0.725; Target = 0.54375 },
            @{ Offset = 0x1A7294; Original = 0.685; Target = 0.51375 },
            @{ Offset = 0x1A72AC; Original = 0.69;  Target = 0.5175 }
        )
    }
)

function Read-U32([byte[]]$b, [int]$o) {
    return [BitConverter]::ToUInt32($b, $o)
}

function Write-U32([byte[]]$b, [int]$o, [uint32]$v) {
    $x = [BitConverter]::GetBytes($v)
    [Array]::Copy($x, 0, $b, $o, 4)
}

function Read-F32([byte[]]$b, [int]$o) {
    return [BitConverter]::ToSingle($b, $o)
}

function Write-F32([byte[]]$b, [int]$o, [single]$v) {
    $x = [BitConverter]::GetBytes($v)
    [Array]::Copy($x, 0, $b, $o, 4)
}

function Near([double]$a, [double]$b) {
    return ([Math]::Abs($a - $b) -lt 0.0001)
}

function Find-ResolutionTables([byte[]]$b) {
    $hits = New-Object System.Collections.Generic.List[int]

    for ($i = 0; $i -le $b.Length - 12; $i++) {
        if (
            (Read-U32 $b $i) -eq 640 -and
            (Read-U32 $b ($i + 4)) -eq 480 -and
            (Read-U32 $b ($i + 8)) -eq 16
        ) {
            if (($i + 24) -lt $b.Length) {
                $hits.Add($i)
            }
        }
    }

    return $hits.ToArray()
}

function Test-HudProfile([byte[]]$bytes, $profile) {
    foreach ($entry in $profile.Hud) {
        if (($entry.Offset + 4) -gt $bytes.Length) {
            return $false
        }

        $cur = Read-F32 $bytes $entry.Offset

        if (
            -not (Near $cur $entry.Original) -and
            -not (Near $cur $entry.Target)
        ) {
            return $false
        }
    }

    return $true
}

function Detect-Profile([byte[]]$bytes) {
    foreach ($profile in $Profiles) {

        if ($null -ne $profile.ExactSize) {
            if ($bytes.Length -ne $profile.ExactSize) {
                continue
            }
        }

        if ($null -ne $profile.MinSize) {
            if ($bytes.Length -lt $profile.MinSize) {
                continue
            }
        }

        if (Test-HudProfile $bytes $profile) {
            return $profile
        }
    }

    return $null
}

function Patch-Exe([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw 'File not found.'
    }

    $bytes = [IO.File]::ReadAllBytes($path)

    if ($bytes.Length -lt 2) {
        throw 'Invalid executable.'
    }

    if ($bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
        throw 'Selected file is not a valid Windows EXE.'
    }

    $profile = Detect-Profile $bytes

    if ($null -eq $profile) {
        throw "Unsupported zanthp.exe version. File size: $($bytes.Length) bytes. File was not modified."
    }

    $tables = @(Find-ResolutionTables $bytes)

    if ($tables.Count -ne 3) {
        throw "Could not uniquely locate Zanzarah resolution tables. Found: $($tables.Count), expected: 3. File was not modified."
    }

    foreach ($table in $tables) {
        $slot = $table + 12

        $w = Read-U32 $bytes $slot
        $h = Read-U32 $bytes ($slot + 4)
        $bpp = Read-U32 $bytes ($slot + 8)

        $isOriginal = ($w -eq 800 -and $h -eq 600)
        $isPatched = ($w -eq $TargetW -and $h -eq $TargetH)

        if (-not $isOriginal -and -not $isPatched) {
            throw "Resolution slot contains unknown values: $w x $h x $bpp. File was not modified."
        }

        Write-U32 $bytes $slot $TargetW
        Write-U32 $bytes ($slot + 4) $TargetH
    }

    foreach ($entry in $profile.Hud) {
        $cur = Read-F32 $bytes $entry.Offset

        if (
            -not (Near $cur $entry.Original) -and
            -not (Near $cur $entry.Target)
        ) {
            throw (
                'Unknown HUD value at offset 0x{0:X}: {1}. File was not modified.' -f
                $entry.Offset,
                $cur
            )
        }

        Write-F32 $bytes $entry.Offset ([single]$entry.Target)
    }

    $backup = "$path.zdf.bak"

    if (-not (Test-Path -LiteralPath $backup)) {
        [IO.File]::Copy($path, $backup, $false)
    }

    [IO.File]::WriteAllBytes($path, $bytes)

    return @{
        Backup = $backup
        Version = $profile.Name
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Zanzarah Display Fixer v0.2.0'
$form.Size = New-Object System.Drawing.Size(640, 260)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Zanzarah: 1920x1080 + Battle HUD Fix'
$title.Font = New-Object System.Drawing.Font(
    'Segoe UI',
    14,
    [System.Drawing.FontStyle]::Bold
)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(18, 16)
$form.Controls.Add($title)

$desc = New-Object System.Windows.Forms.Label
$desc.Text = "Supports Legacy and Steam versions.`r`nAdds 1920x1080 and fixes HP, jump energy, spells and charges."
$desc.AutoSize = $true
$desc.Location = New-Object System.Drawing.Point(20, 52)
$form.Controls.Add($desc)

$text = New-Object System.Windows.Forms.TextBox
$text.Location = New-Object System.Drawing.Point(20, 100)
$text.Size = New-Object System.Drawing.Size(470, 25)
$text.ReadOnly = $true
$form.Controls.Add($text)

$browse = New-Object System.Windows.Forms.Button
$browse.Text = 'Select zanthp.exe'
$browse.Location = New-Object System.Drawing.Point(500, 98)
$browse.Size = New-Object System.Drawing.Size(115, 28)
$form.Controls.Add($browse)

$apply = New-Object System.Windows.Forms.Button
$apply.Text = 'Apply Fix'
$apply.Location = New-Object System.Drawing.Point(20, 145)
$apply.Size = New-Object System.Drawing.Size(180, 36)
$apply.Enabled = $false
$form.Controls.Add($apply)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Select zanthp.exe.'
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(215, 155)
$form.Controls.Add($status)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = ''
$versionLabel.AutoSize = $true
$versionLabel.Location = New-Object System.Drawing.Point(20, 195)
$form.Controls.Add($versionLabel)

$browse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = 'Select zanthp.exe'
    $dlg.Filter = 'Zanzarah executable (zanthp.exe)|zanthp.exe|EXE files (*.exe)|*.exe'
    $dlg.FileName = 'zanthp.exe'

    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

        try {
            $bytes = [IO.File]::ReadAllBytes($dlg.FileName)
            $profile = Detect-Profile $bytes

            $text.Text = $dlg.FileName

            if ($null -eq $profile) {
                $apply.Enabled = $false
                $status.Text = 'Unsupported executable.'
                $versionLabel.Text = "Detected size: $($bytes.Length) bytes"
            }
            else {
                $apply.Enabled = $true
                $status.Text = 'Ready.'
                $versionLabel.Text = "Detected version: $($profile.Name)"
            }
        }
        catch {
            $apply.Enabled = $false
            $status.Text = 'Could not read executable.'
            $versionLabel.Text = $_.Exception.Message
        }
    }
})

$apply.Add_Click({
    try {
        $apply.Enabled = $false
        $status.Text = 'Patching...'

        $result = Patch-Exe $text.Text

        $status.Text = 'Done.'
        $versionLabel.Text = "Patched version: $($result.Version)"

        [System.Windows.Forms.MessageBox]::Show(
            "Done!`r`n`r`nVersion: $($result.Version)`r`n1920x1080 added.`r`nBattle HUD fixed.`r`n`r`nBackup:`r`n$($result.Backup)",
            'Zanzarah Display Fixer',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        $status.Text = 'Error. File was not modified.'

        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Zanzarah Display Fixer',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $apply.Enabled = $true
    }
})

[void]$form.ShowDialog()
