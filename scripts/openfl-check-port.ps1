[CmdletBinding()]
param(
    [ValidateSet("windows", "html5")]
    [string]$Target = "windows",
    [string]$HaxeHome = "C:\Dev\tools\haxe-4.3.7",
    [string]$NekoHome = "C:\Dev\tools\neko-2.4.1"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$HaxeExe = Join-Path $HaxeHome "haxe.exe"
$HaxelibExe = Join-Path $HaxeHome "haxelib.exe"
$NekoDll = Join-Path $NekoHome "neko.dll"
$ProjectPath = Join-Path $RepoRoot "openfl\project.xml"

if (-not (Test-Path -LiteralPath $HaxeExe)) {
    throw "Haxe was not found at '$HaxeHome'. Install Haxe or pass -HaxeHome."
}

if (-not (Test-Path -LiteralPath $HaxelibExe)) {
    throw "Haxelib was not found at '$HaxeHome'. Install Haxe or pass -HaxeHome."
}

if (-not (Test-Path -LiteralPath $NekoDll)) {
    throw "Neko was not found at '$NekoHome'. Install Neko or pass -NekoHome."
}

$env:NEKO_INSTPATH = $NekoHome
$env:PATH = "$NekoHome;$HaxeHome;$env:PATH"

& $HaxelibExe run openfl build $ProjectPath $Target `
    --source=ported `
    --haxeflag="--macro include('', true, [], ['src','ported'])"
