param([Parameter(Mandatory=$true)][string]$basepak,[string]$overlaydir,[string]$output)
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if(!$overlaydir){$overlaydir=Join-Path $root 'localization\overlay_ru'}
if(!$output){$output=Join-Path $root 'localization\pak\ru_overlay.pak'}
$fs=[IO.File]::OpenRead($basepak); $br=[IO.BinaryReader]::new($fs)
$id=$br.ReadUInt32(); $count=$br.ReadUInt32(); $entries=@()
for($i=0;$i -lt $count;$i++){ $len=$br.ReadUInt32(); $name=[Text.Encoding]::ASCII.GetString($br.ReadBytes($len)); $off=$br.ReadUInt32(); $size=$br.ReadUInt32(); $entries += [pscustomobject]@{name=$name;off=$off;size=$size} }
$head=$fs.Position; $blocks=@(); foreach($e in $entries){$rel=$e.name -replace '^\.\.\\','' -replace '/','\\'; $src=Join-Path $overlaydir $rel; if(Test-Path -LiteralPath $src){$data=[IO.File]::ReadAllBytes($src); $blocks += ,$data} else {$fs.Position=$head+$e.off; $blocks += ,$br.ReadBytes($e.size)}}; $br.Dispose();$fs.Dispose()
$dir=Split-Path $output; New-Item -ItemType Directory -Path $dir -Force|Out-Null
$header=[IO.MemoryStream]::new();$bw=[IO.BinaryWriter]::new($header);$bw.Write($id);$bw.Write($count);$offset=0; for($i=0;$i -lt $count;$i++){ $e=$entries[$i]; $nb=[Text.Encoding]::ASCII.GetBytes($e.name);$bw.Write($nb.Length);$bw.Write($nb);$bw.Write($offset);$bw.Write($blocks[$i].Length);$offset += $blocks[$i].Length };$bw.Flush();$outfs=[IO.File]::Create($output);$header.WriteTo($outfs); foreach($b in $blocks){$outfs.Write($b,0,$b.Length)};$outfs.Dispose();$bw.Dispose();$header.Dispose(); Write-Host "built $output"
