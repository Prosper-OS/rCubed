[CmdletBinding()]
param(
    [string]$OutputPath = "openfl\src"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$OutputRoot = Join-Path $RepoRoot $OutputPath

function Write-HaxeClass {
    param(
        [string]$QualifiedName,
        [ValidateSet("MovieClip", "BitmapData")]
        [string]$Kind
    )

    $parts = $QualifiedName.Split(".")
    $className = $parts[$parts.Length - 1]
    $packageName = ($parts[0..($parts.Length - 2)] -join ".")
    $directory = Join-Path $OutputRoot ($packageName.Replace(".", "\"))
    $filePath = Join-Path $directory ($className + ".hx")

    New-Item -ItemType Directory -Path $directory -Force | Out-Null

    if ($Kind -eq "BitmapData") {
        $content = @"
package $packageName;

import openfl.display.BitmapData;

class $className extends BitmapData {
	public function new(width:Int = 8, height:Int = 8) {
		super(width, height, true, 0x22FFFFFF);
	}
}
"@
    }
    else {
        $content = @"
package $packageName;

import openfl.display.MovieClip;

class $className extends MovieClip {
	public function new() {
		super();
		mouseEnabled = false;
		mouseChildren = false;
		graphics.beginFill(0xFFFFFF, 0.18);
		graphics.drawRect(0, 0, 32, 32);
		graphics.endFill();
	}
}
"@
    }

    Set-Content -LiteralPath $filePath -Value $content -NoNewline
}

$movieClipSymbols = @(
    "assets.menu.Logo",
    "assets.menu.MainMenuBackground",
    "assets.menu.GenreSelection",
    "assets.menu.ScrollBackground",
    "assets.menu.ScrollDragger",
    "assets.menu.SongSelectionBackground",
    "assets.menu.ChartDifficultyItem",
    "assets.menu.ChartDifficultyLargeItem",
    "assets.results.MPWaitBackground",
    "assets.results.MPResultsBackground",
    "assets.results.ResultsBackground",
    "assets.gameplay.BarTopNormal",
    "assets.gameplay.BarTopSideways",
    "assets.gameplay.BarBottomNormal",
    "assets.gameplay.BarBottomSideways"
)

$iconSymbols = @(
    "IconAccept",
    "IconAward",
    "IconCancel",
    "IconClose",
    "IconCopy",
    "IconDelete",
    "IconEye",
    "IconFilm",
    "IconFilter",
    "IconFolder",
    "IconGear",
    "IconHeartEmpty",
    "IconHeartFull",
    "IconLeave",
    "IconLeft",
    "IconList",
    "IconLock",
    "IconMap",
    "IconMedal",
    "IconMinus",
    "IconMove",
    "IconMusic",
    "IconPause",
    "IconPhoto",
    "IconPlay",
    "IconPlus",
    "IconProfile",
    "IconRandom",
    "IconRecord",
    "IconRefresh",
    "IconRight",
    "IconSave",
    "IconSearch",
    "IconSmallF",
    "IconSmallT",
    "IconSpeed",
    "IconStar",
    "IconStop",
    "IconTime",
    "IconTrophy",
    "IconUpLevel",
    "IconUserAdd",
    "IconUsers",
    "IconUserX",
    "IconVideo",
    "IconWrench"
)

foreach ($symbol in $movieClipSymbols) {
    Write-HaxeClass -QualifiedName $symbol -Kind MovieClip
}

foreach ($icon in $iconSymbols) {
    Write-HaxeClass -QualifiedName ("assets.menu.icons.fa." + $icon) -Kind MovieClip
}

Write-HaxeClass -QualifiedName "assets.GameBackgroundStripes" -Kind BitmapData
Write-HaxeClass -QualifiedName "assets.settings.ColorPickerBMP" -Kind BitmapData

Write-Host "Generated OpenFL asset stubs under $OutputRoot"
