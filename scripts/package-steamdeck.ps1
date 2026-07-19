param(
    [string]$Distro = "Ubuntu-24.04",
    [string]$AirHome = "",
    [string]$Version = "2.0.4",
    [string]$ScoreSaveSalt = "",
    [switch]$SkipCompile,
    [switch]$Check
)

$ErrorActionPreference = "Stop"

function ConvertTo-BashSingleQuoted {
    param([string]$Value)
    return "'" + $Value.Replace("'", "'`"`"'`"'") + "'"
}

function ConvertTo-WslPath {
    param([string]$Path)
    $quoted = ConvertTo-BashSingleQuoted $Path
    $converted = (& wsl.exe -d $Distro -- bash -lc "wslpath -a $quoted").Trim()
    if (-not $converted) {
        throw "Could not translate path for WSL: $Path"
    }
    return $converted
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "wsl.exe was not found. Install WSL with an Ubuntu distro before building the native Steam Deck package."
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$repoWsl = ConvertTo-WslPath $repoRoot

$envParts = @("R3_VERSION=$(ConvertTo-BashSingleQuoted $Version)")

if ($ScoreSaveSalt) {
    $envParts += "SCORE_SAVE_SALT=$(ConvertTo-BashSingleQuoted $ScoreSaveSalt)"
}

if ($AirHome) {
    if ($AirHome -match "^[A-Za-z]:") {
        $airHomeWsl = ConvertTo-WslPath $AirHome
    } else {
        $airHomeWsl = $AirHome
    }
    $envParts += "AIR_HOME=$(ConvertTo-BashSingleQuoted $airHomeWsl)"
}

$scriptArgs = @()
if ($SkipCompile) {
    $scriptArgs += "--skip-compile"
}
if ($Check) {
    $scriptArgs += "--check"
}

$command = "cd $(ConvertTo-BashSingleQuoted $repoWsl) && " + ($envParts -join " ") + " bash scripts/package-steamdeck.sh " + ($scriptArgs -join " ")
& wsl.exe -d $Distro -- bash -lc $command
exit $LASTEXITCODE
