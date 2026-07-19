[CmdletBinding()]
param(
    [string]$SourceDir = "src",
    [string]$OutputDir = "openfl\ported",
    [string]$HaxeHome = "C:\Dev\tools\haxe-4.3.7",
    [string]$NekoHome = "C:\Dev\tools\neko-2.4.1"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SourcePath = Resolve-Path (Join-Path $RepoRoot $SourceDir)
$OutputPath = Join-Path $RepoRoot $OutputDir
$HaxelibExe = Join-Path $HaxeHome "haxelib.exe"
$NekoDll = Join-Path $NekoHome "neko.dll"

if (-not (Test-Path -LiteralPath $HaxelibExe)) {
    throw "Haxelib was not found at '$HaxeHome'. Install Haxe or pass -HaxeHome."
}

if (-not (Test-Path -LiteralPath $NekoDll)) {
    throw "Neko was not found at '$NekoHome'. Install Neko or pass -NekoHome."
}

$env:NEKO_INSTPATH = $NekoHome
$env:PATH = "$NekoHome;$HaxeHome;$env:PATH"

$WorkRoot = Join-Path $env:TEMP ("r3-as3hx-" + [guid]::NewGuid().ToString("N"))
$PreparedRoot = Join-Path $WorkRoot "src"
New-Item -ItemType Directory -Path $PreparedRoot | Out-Null

function Convert-CompilerConstants {
    param([string]$Text)

    $Text = $Text -replace "CONFIG::debug", "false"
    $Text = $Text -replace "CONFIG::release", "false"
    $Text = $Text -replace "CONFIG::timeStamp", '"9999-12-31"'

    $Text = $Text -replace "R3::HASH_STRING", '"hashstring"'
    $Text = $Text -replace "R3::BRAND_NAME_LONG", '"FlashFlashRevolution"'
    $Text = $Text -replace "R3::BRAND_NAME_SHORT", '"FFR"'
    $Text = $Text -replace "R3::ROOT_URL", '"www.flashflashrevolution.com"'
    $Text = $Text -replace "R3::VERSION_PREFIX", '""'
    $Text = $Text -replace "R3::VERSION_SUFFIX", '"D"'
    $Text = $Text -replace "R3::VERSION", '"0.0.0"'

    return $Text
}

function Convert-ParseIntRadix {
    param([string]$Text)

    $pattern = "parseInt\(((?:[^()]|\([^()]*\))*)\s*,\s*([0-9a-zA-Z_]+)\)"
    do {
        $before = $Text
        $Text = [regex]::Replace($Text, $pattern, 'parseInt($1)')
    } while ($Text -ne $before)

    return $Text
}

function Convert-ArrayHoles {
    param([string]$Text)

    do {
        $before = $Text
        $Text = $Text -replace "\[(\s*),", "[null,"
        $Text = $Text -replace ",(\s*),", ", null,"
        $Text = $Text -replace ",(\s*)\]", ", null]"
    } while ($Text -ne $before)

    return $Text
}

function Prepare-ActionScriptFile {
    param(
        [string]$InputPath,
        [string]$OutputPath
    )

    $sourceRoot = $SourcePath.Path.TrimEnd("\", "/")
    $relative = $InputPath.Substring($sourceRoot.Length).TrimStart("\", "/")
    $outFile = Join-Path $PreparedRoot $relative
    $outDir = Split-Path $outFile
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    if ($relative -eq "com\coltware\airxzip\zip_internal.as") {
        $zipNamespace = @'
package com.coltware.airxzip {
    public class zip_internal {
    }
}
'@
        Set-Content -LiteralPath $outFile -Value $zipNamespace -NoNewline
        return
    }

    $text = [System.IO.File]::ReadAllText($InputPath)
    $text = Convert-CompilerConstants $text
    $text = Convert-ParseIntRadix $text
    $text = Convert-ArrayHoles $text
    $text = $text -replace "(?m)^\s*import\s+com\.greensock(?:\.[a-zA-Z0-9_]+)?\.~~;\s*(?:<br\s*/>)?\s*$", ""
    $text = $text -replace "(?m)^\s*use\s+namespace\s+zip_internal;\s*$", ""
    $text = $text -replace "\bzip_internal\s+(var|function|const)\b", 'public $1'
    $text = $text -replace "\{\s*// not the best method, i know", "{`n// not the best method, i know"

    Set-Content -LiteralPath $outFile -Value $text -NoNewline
}

function Convert-OpenFLImports {
    param([string]$Text)

    $mappings = @{
        "flash.display." = "openfl.display."
        "flash.events." = "openfl.events."
        "flash.external." = "openfl.external."
        "flash.filters." = "openfl.filters."
        "flash.geom." = "openfl.geom."
        "flash.media." = "openfl.media."
        "flash.net." = "openfl.net."
        "flash.system." = "openfl.system."
        "flash.text." = "openfl.text."
        "flash.ui." = "openfl.ui."
        "flash.utils." = "openfl.utils."
        "flash.errors." = "openfl.errors."
        "flash.desktop." = "r3.air.desktop."
        "flash.filesystem." = "r3.air.filesystem."
    }

    foreach ($key in $mappings.Keys) {
        $Text = $Text.Replace($key, $mappings[$key])
    }

    $Text = $Text -replace "import\s+com\.flashfla\.utils\.Sprintf;", "import com.flashfla.utils.Sprintf.sprintf;"
    $Text = $Text -replace "Array</\*AS3HX WARNING no type\*/>", "Array<Dynamic>"
    $Text = $Text -replace ":\s*Dictionary\b(?!<)", ": Dictionary<Dynamic, Dynamic>"
    $Text = $Text -replace "new Dictionary\(", "new Dictionary<Dynamic, Dynamic>("
    $Text = $Text -replace "\s+extends\s+Dynamic\b", ""
    $Text = $Text -replace "\bEvent\.EXITING\b", "NativeApplication.EXITING"
    $Text = $Text -replace "(?m)^(\s*)(-?\d+)\s*:", '$1"$2" :'
    $Text = $Text -replace "(?m)^(\s*)class\s*:", '$1"class" :'
    $Text = $Text -replace "(?m)^(\s*)new\s*:", '$1"new" :'
    $Text = $Text -replace "(?m)^\s*This is an intentional compilation error\. See the README for handling the delete keyword\s*`r?`n", ""
    $Text = $Text -replace "(?m)^(\s*)delete\s+([A-Za-z_][\w\.]*)\.([A-Za-z_]\w*)\s*;", '$1Reflect.deleteField($2, "$3");'
    $Text = $Text -replace "(?m)^(\s*)delete\s+([A-Za-z_][\w\.]*)\[(.+?)\]\s*;", '$1Reflect.deleteField($2, Std.string($3));'
    $Text = $Text -replace "(Reflect\.deleteField\([^\r\n;]+?\))\s+(//)", '$1; $2'
    $Text = $Text -replace "(?m)^(\s*(?:[A-Za-z_][\w\.]*|super)\([^\r\n;]*\))\s+(//.*;)\s*$", '$1; $2'
    $Text = $Text -replace "(?m)^\s{8,};\s*`r?`n", ""
    $Text = $Text -replace "`r?`n\s+import openfl\.display\.LoaderInfo;`r?`n\s+`r?`n", "`n"
    if ($Text -like "*ClassForGetDefinitionNames*") {
        return @'
package com.flashfla.utils;

class ClassForGetDefinitionNames
{
    public function new()
    {
    }

    public function getDefinitionNames(data : Dynamic, extended : Bool = false, linkedOnly : Bool = false) : Array<Dynamic>
    {
        return [];
    }
}
'@
    }
    if ($Text -like "*ClassForGetDefinitionNames*" -and $Text -notlike "*import openfl.display.LoaderInfo;*") {
        $Text = $Text -replace "(import openfl\.utils\.Endian;`r?`n)", "`$1import openfl.display.LoaderInfo;`n"
    }
    if ($Text -like "*ClassForGetDefinitionNames*") {
        $Text = $Text -replace "if \(name\)\s+// not the best method, i know\{\s+", "if (name != null && name != """") {`n"
    }
    if ($Text -like "*NativeApplication.nativeApplication.applicationDescriptor*") {
        $restartPattern = "public function restartApplication\(\) : Void\s*\{.*?NativeApplication\.nativeApplication\.exit\(\);\s*\}"
        $restartReplacement = @'
public function restartApplication() : Void
    {
        Logger.warning(this, "restartApplication is not implemented in the OpenFL port yet.");
    }
'@
        $Text = [regex]::Replace($Text, $restartPattern, $restartReplacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    if ($Text -like "*typedef JudgeWindowTypedef*") {
        $Text = [regex]::Replace(
            $Text,
            "^\s*(typedef JudgeWindowTypedef = \{.*?\}\s*)((?:import [^\r\n]+;[\r\n]+)+)",
            "`$2`n`$1",
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
    }
    if ($Text -like "*flash.xml.XMLDocument*" -or $Text -like "*XMLNodeType.TEXT_NODE*") {
        $Text = $Text -replace "(?m)^\s*import\s+flash\.xml\.(XMLDocument|XMLNode|XMLNodeType);\s*`r?`n", ""
        $Text = [regex]::Replace(
            $Text,
            "public static function htmlEscape\(str : String\) : String\s*\{.*?\n\s*\}",
            "public static function htmlEscape(str : String) : String`n    {`n        return StringTools.htmlEscape(str, true);`n    }",
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
        $Text = [regex]::Replace(
            $Text,
            "public static function htmlUnescape\(str : String\) : String\s*\{.*?\n\s*public static function stripMessage",
            "public static function htmlUnescape(str : String) : String`n    {`n        return StringTools.htmlUnescape(str);`n    }`n    `n    public static function stripMessage",
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
    }
    if ($Text.Contains("_decryptors[i]")) {
        $decryptorLoopPattern = "for \(i in 0\.\.\.\{\s*var _decrypt : ICrypto = _decryptors\[i\];\s*if \(_decrypt\.checkDecrypt\(entry\)\)\s*\{\s*decrypt = _decrypt;\s*\}\s*\}"
        $decryptorLoopReplacement = @'
var i : Int = 0;
            while (i < _decryptors.length && decrypt == null) {
                var _decrypt : ICrypto = _decryptors[i];
                if (_decrypt.checkDecrypt(entry)) {
                    decrypt = _decrypt;
                }
                i++;
            }
'@
        $Text = [regex]::Replace($Text, $decryptorLoopPattern, $decryptorLoopReplacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    $Text = $Text -replace "TweenLite\._plugins\[\(new Type\.getClass\(plugins\[i\]\)\(\)\(\)\)\._propName\] = plugins\[i\];", "var pluginInstance : TweenPlugin = Type.createInstance(plugins[i], []);`n                TweenLite._plugins[pluginInstance._propName] = plugins[i];"
    $Text = $Text -replace "preexisting\s*:\s*5,\s*true\s*:\s*1,\s*false\s*:\s*0\s*\};", "preexisting : 5`n                    };`n            Reflect.setField(_overwriteLookup, `"true`", 1);`n            Reflect.setField(_overwriteLookup, `"false`", 0);"
    $Text = $Text -replace "if \(([^\r\n]+?)\)\s+//[^\r\n]*\{\s+", "if (`$1) {`n"
    $Text = $Text -replace "for \(([^\r\n]+?)\)\s+//[^\r\n]*\{\s+", "for (`$1) {`n"
    $Text = $Text -replace "while \(([^\r\n]+?)\)\s+//[^\r\n]*\{\s+", "while (`$1) {`n"
    $Text = $Text -replace "catch \(([^\r\n]+?)\)\s+//[^\r\n]*\{\s+", "catch (`$1) {`n"
    $Text = $Text -replace "try\s+//[^\r\n]*\{\s+", "try {`n"
    $Text = $Text -replace "(?m)^(\s*)((?:(?:override|public|private|static|inline)\s+)*function[^\r\n]+)\s+//[^\r\n]*\{\s+", "`$1`$2`n`$1{`n"
    return $Text
}

function Convert-LocalHelperClasses {
    param(
        [string]$Text,
        [string]$FilePath
    )

    $className = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $helperNames = @("SingletonEnforcer", "ChartObject", "CLItemCache", "UserLabel")

    foreach ($helperName in $helperNames) {
        if ($Text -match "\bclass\s+$helperName\b") {
            $uniqueName = $className + $helperName
            $Text = $Text -replace "\b$helperName\b", $uniqueName
        }
    }

    return $Text
}

Get-ChildItem -LiteralPath $SourcePath -Recurse -Filter *.as | ForEach-Object {
    Prepare-ActionScriptFile -InputPath $_.FullName -OutputPath $PreparedRoot
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

Write-Host "Prepared AS3 source: $PreparedRoot"
Write-Host "Generating Haxe source: $OutputPath"
& $HaxelibExe run as3hx -func2dyn $PreparedRoot $OutputPath

Get-ChildItem -LiteralPath $OutputPath -Recurse -Filter *.hx | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName)
    $text = Convert-OpenFLImports $text
    $text = Convert-LocalHelperClasses -Text $text -FilePath $_.FullName
    Set-Content -LiteralPath $_.FullName -Value $text -NoNewline
}

$sourceCount = (Get-ChildItem -LiteralPath $SourcePath -Recurse -Filter *.as | Measure-Object).Count
$portedCount = (Get-ChildItem -LiteralPath $OutputPath -Recurse -Filter *.hx | Measure-Object).Count

Write-Host "AS3 source files: $sourceCount"
Write-Host "Generated Haxe files: $portedCount"
Write-Host "Output: $OutputPath"
