[CmdletBinding()]
param(
    [ValidateSet("html5", "windows", "linux", "mac", "android", "ios", "hl", "neko")]
    [string]$Target = "html5",

    [ValidateSet("debug", "release")]
    [string]$Configuration = "debug",

    [string]$Project = "",
    [string]$HaxeHome = "C:\Dev\tools\haxe-4.3.7",
    [string]$NekoHome = "C:\Dev\tools\neko-2.4.1"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
if ([string]::IsNullOrWhiteSpace($Project)) {
    $Project = Join-Path $RepoRoot "openfl\project.xml"
}

$ProjectPath = Resolve-Path $Project
$HaxeExe = Join-Path $HaxeHome "haxe.exe"
$HaxelibExe = Join-Path $HaxeHome "haxelib.exe"
$NekoDll = Join-Path $NekoHome "neko.dll"

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

Write-Host "Using Haxe: $(& $HaxeExe --version)"
Write-Host "Using haxelib repo: $(& $HaxelibExe config)"
Write-Host "Building OpenFL target '$Target' from $ProjectPath"

$openflArgs = @("run", "openfl", "build", $ProjectPath.Path, $Target)
if ($Configuration -eq "debug") {
    $openflArgs += "-debug"
}

& $HaxelibExe @openflArgs
