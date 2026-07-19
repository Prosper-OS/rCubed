[CmdletBinding()]
param(
    [string]$SourceDir = "src",
    [string]$OutputDir = "openfl\ported",
    [string]$HaxeHome = "C:\Dev\tools\haxe-4.3.7",
    [string]$NekoHome = "C:\Dev\tools\neko-2.4.1",
    [switch]$PostprocessOnly
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

function Write-ActionScriptStub {
    param(
        [string]$RelativePath,
        [string]$OutputFile
    )

    $packagePath = Split-Path $RelativePath -Parent
    $packageName = $packagePath.Replace("\", ".").Replace("/", ".")
    $className = [System.IO.Path]::GetFileNameWithoutExtension($RelativePath)

    if ($className -eq "TweenLite") {
        $stub = @"
package $packageName {
    public class TweenLite {
        public static var defaultOverwrite:*;
        public static function to(target:*, duration:*, vars:*):* { return null; }
        public static function killTweensOf(target:*, onlyActive:* = false, vars:* = null):void {}
        public static function activate(plugins:Array):void {}
    }
}
"@
    }
    elseif ($className -eq "TweenMax") {
        $stub = @"
package $packageName {
    public class TweenMax extends TweenLite {
        public static function to(target:*, duration:*, vars:*):* { return null; }
    }
}
"@
    }
    else {
        $stub = @"
package $packageName {
    public class $className {
        public function $className() {}
    }
}
"@
    }

    Set-Content -LiteralPath $OutputFile -Value $stub -NoNewline
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

    $nativeShimSources = @(
        "com\flashfla\net\MultipartURLLoader.as",
        "com\flashfla\net\WebRequest.as",
        "com\flashfla\parser\YAML.as",
        "com\flashfla\utils\ArrayUtil.as",
        "com\flashfla\utils\Crypt.as",
        "com\flashfla\utils\DateUtil.as",
        "com\flashfla\utils\ExtraMath.as",
        "com\flashfla\utils\GameNotePool.as",
        "com\flashfla\utils\NumberUtil.as",
        "com\flashfla\utils\sprintf.as",
        "com\flashfla\utils\StringUtil.as",
        "com\flashfla\utils\TimeUtil.as",
        "com\flashfla\utils\VectorUtil.as"
    )
    if ($relative.StartsWith("com\greensock\", [System.StringComparison]::OrdinalIgnoreCase) -or
        $relative.StartsWith("game\graph\", [System.StringComparison]::OrdinalIgnoreCase) -or
        $nativeShimSources -contains $relative) {
        Write-ActionScriptStub -RelativePath $relative -OutputFile $outFile
        return
    }

    $text = [System.IO.File]::ReadAllText($InputPath)
    $text = Convert-CompilerConstants $text
    $text = Convert-ParseIntRadix $text
    $text = Convert-ArrayHoles $text
    $text = $text -replace "\bprotected\b", "public"
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
    $Text = $Text -replace "(?m)^(\s*)public\s+static\s+var\s+(_(?:gvars|mp|lang)\s+:)", '$1public var $2'
    $Text = $Text -replace "(?m)^(\s*)public\s+static\s+var\s+(COLUMNS\s+:)", '$1public var $2'
    $Text = $Text -replace "\bArray\.NUMERIC\b", "as3hx.Compat.ARRAY_NUMERIC"
    $Text = $Text -replace "\bArray\.CASEINSENSITIVE\b", "as3hx.Compat.ARRAY_CASEINSENSITIVE"
    $Text = $Text -replace "\bArray\.DESCENDING\b", "as3hx.Compat.ARRAY_DESCENDING"
    $Text = [regex]::Replace($Text, "(?m)^(\s*)([A-Za-z_][A-Za-z0-9_]*)\.sortOn\((.+?)\);\s*$", '$1as3hx.Compat.sortOn($2, $3);')
    $Text = [regex]::Replace($Text, "as3hx\.Compat\.sortOn\(as3hx\.Compat,\s*as3hx\.Compat,\s*as3hx\.Compat,\s*as3hx\.Compat,\s*([^,]+),\s*([^,]+),\s*([^)]+)\);", 'as3hx.Compat.sortOn($1, $2, $3);')
    $Text = [regex]::Replace($Text, "as3hx\.Compat\.sortOn\(as3hx\.Compat,\s*([^,]+),\s*([^,]+),\s*([^)]+)\);", 'as3hx.Compat.sortOn($1, $2, $3);')
    $Text = [regex]::Replace($Text, "Reflect\.field\(match,\s*Std\.string\((\d+)\)\)", 'as3hx.Compat.field(match, $1)')
    $Text = [regex]::Replace($Text, "Reflect\.field\(beat,\s*Std\.string\((\d+)\)\)", 'as3hx.Compat.field(beat, $1)')
    $Text = [regex]::Replace($Text, "Reflect\.field\(COLUMNS,\s*Std\.string\(Reflect\.field\(chartData,\s*`"type`"\)\)\)", 'as3hx.Compat.field(COLUMNS, Reflect.field(chartData, "type"))')
    if ($Text -like "*class ScrollBar extends Slider*") {
        $Text = $Text -replace "\bHORIZONTAL\b", "Slider.HORIZONTAL"
    }
    if ($Text.Contains(".replace(new as3hx.Compat.Regex")) {
        $Text = [regex]::Replace(
            $Text,
            "([A-Za-z_][A-Za-z0-9_\.]*(?:\([^\r\n;]*?\))?)\.replace\(new as3hx\.Compat\.Regex\(([^\)]*)\),\s*([^\)]*)\)",
            'new as3hx.Compat.Regex($2).replace($1, $3)'
        )
    }
    if ($Text -like "*class Screenshots*") {
        $Text = [regex]::Replace(
            $Text,
            "new as3hx\.Compat\.Regex\(':'\, `"g`"\)\.replace\(_file\.save\(PNGEncoder\.encode\(b\), AirContext\.createFileName\(\(\(filename != null\) \? filename : `"R\^3 - `" \+ DateUtil\.toRFC822\(Date\.now\(\)\), `"\.`"\)\) \+ `"\.png`"\)\);",
            '_file.save(PNGEncoder.encode(b), AirContext.createFileName(((filename != null) ? filename : "R^3 - " + new as3hx.Compat.Regex('':'', "g").replace(DateUtil.toRFC822(Date.now()), ".")) + ".png"));'
        )
    }
    if ($Text -like "*class SettingsTabNoteskin*") {
        $Text = $Text.Replace(
            'var nsName  : Dynamic= (new as3hx.Compat.Regex(''^\\s+|\\s+$'', "gs").replace(ns.data.name.indexOf("Custom Export") != -(1) ? ns.file.substr(0, ns.file.length - 4) : ns.data.name), "");',
            'var nsName  : Dynamic= new as3hx.Compat.Regex(''^\\s+|\\s+$'', "gs").replace((ns.data.name.indexOf("Custom Export") != -(1) ? ns.file.substr(0, ns.file.length - 4) : ns.data.name), "");'
        )
        $Text = [regex]::Replace(
            $Text,
            'var nsName\s+: Dynamic=\s*\(new as3hx\.Compat\.Regex\(''\^\\\\s\+\|\\\\s\+\$'', "gs"\)\.replace\((.*?)\), ""\);',
            'var nsName  : Dynamic= new as3hx.Compat.Regex(''^\\s+|\\s+$$'', "gs").replace((${1}), "");'
        )
        $Text = [regex]::Replace($Text, '_noteskins\.data\[0\]\["notes"\]\["blue"\]', 'as3hx.Compat.field(as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes"), "blue")')
        $Text = [regex]::Replace($Text, '_noteskins\.data\[0\]\["notes"\]', 'as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes")')
    }
    if ($Text -like "*class Language*") {
        $Text = $Text.Replace(
            'new as3hx.Compat.Regex(''\\r\\n'', "gi").replace(Reflect.setField(Reflect.field(data, lang), Std.string(Std.string(langNodes.get(c).node.attribute.innerData("id"))), Std.string(langNodes.get(c).node.children.innerData()[0]), "\n"));',
            'Reflect.setField(Reflect.field(data, lang), Std.string(Std.string(langNodes.get(c).node.attribute.innerData("id"))), new as3hx.Compat.Regex(''\\r\\n'', "gi").replace(Std.string(langNodes.get(c).node.children.innerData()[0]), "\n"));'
        )
    }
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

function Convert-AS3TypeStrictness {
    param([string]$Text)

    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        $line = [regex]::Replace(
            $line,
            "(\bvar\s+[A-Za-z_][A-Za-z0-9_]*(?:\([^\)]*\))?\s*):\s*[^=;`r`n]+",
            '$1 : Dynamic'
        )

        if ($line -match "\bfunction\b") {
            $line = [regex]::Replace(
                $line,
                "([\(\,]\s*[A-Za-z_][A-Za-z0-9_]*\s*):\s*[^,\)=`r`n]+",
                '$1 : Dynamic'
            )
        }

        $line = $line -replace "\s*=\s*Math\.NaN", " = null"
        $lines[$i] = $line
    }

    return ($lines -join "`n")
}

function Convert-FinalGeneratedFixes {
    param(
        [string]$Text,
        [string]$FilePath
    )

    $fileName = [System.IO.Path]::GetFileName($FilePath)

    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]

        if ($line -match "^(\s*for\s*\(.+?\s+in\s+)(.+?)(\)\s*\{?\s*)$") {
            $iterable = $matches[2].Trim()
            if (-not $iterable.Contains("...") -and -not $iterable.StartsWith("as3hx.Compat.iter(")) {
                $line = $matches[1] + "as3hx.Compat.iter($iterable)" + $matches[3]
            }
        }

        if ($line -notmatch "\?" -and $line -match "^(\s*[A-Za-z_][A-Za-z0-9_\.]*\s*=\s*)(.+)\s+\|\|\s+(.+);\s*$") {
            $leftExpr = $matches[2].Trim()
            $rightExpr = $matches[3].Trim()
            if ($leftExpr -notmatch "(^\(|!|==|!=|<=|>=|<|>|\&\&)" -and $rightExpr -notmatch "(!|==|!=|<=|>=|<|>|\&\&)") {
                $line = $matches[1] + "as3hx.Compat.orValue(" + $leftExpr + ", " + $rightExpr + ");"
            }
        }
        elseif ($line -notmatch "\?" -and $line -match "^(\s*Reflect\.setField\([^,]+,\s*`"[^`"]+`",\s*)(.+)\s+\|\|\s+(.+)\);\s*$") {
            $line = $matches[1] + "as3hx.Compat.orValue(" + $matches[2].Trim() + ", " + $matches[3].Trim() + "));"
        }

        if ($line -match "^(\s*)(else\s+)?if\s*\((.*)\)(\s*\{?\s*)$") {
            $condition = $matches[3].Trim()
            if (-not $condition.StartsWith("as3hx.Compat.truthy(")) {
                $line = $matches[1] + $matches[2] + "if (as3hx.Compat.truthy($condition))" + $matches[4]
            }
        }
        elseif ($line -match "^(\s*)while\s*\((.*)\)(\s*\{?\s*)$") {
            $condition = $matches[2].Trim()
            if (-not $condition.StartsWith("as3hx.Compat.truthy(")) {
                $line = $matches[1] + "while (as3hx.Compat.truthy($condition))" + $matches[3]
            }
        }

        $line = [regex]::Replace($line, "\|\|\s*(\[\]|`"[^`"]*`"|\d+(?:\.\d+)?|\{\s*\})", "|| `$1")
        $line = [regex]::Replace($line, "([A-Za-z_][A-Za-z0-9_\.]*(?:\[[^\]]+\])*)\s+\|\|\s*(\[\]|`"[^`"]*`"|\d+(?:\.\d+)?|\{\s*\})", "as3hx.Compat.orValue(`$1, `$2)")

        $lines[$i] = $line
    }
    $Text = $lines -join "`n"
    $Text = [regex]::Replace($Text, "as3hx\.Compat\.sortOn\(as3hx\.Compat,\s*([^,]+),\s*([^,]+),\s*([^)]+)\);", 'as3hx.Compat.sortOn($1, $2, $3);')
    $Text = [regex]::Replace($Text, 'Reflect\.field\(([A-Za-z_][A-Za-z0-9_\.]*(?:\[[^\]]+\])?), Std\.string\(([^()]+)\)\)', 'as3hx.Compat.field($1, $2)')
    $Text = [regex]::Replace($Text, 'Reflect\.setField\(([^,\r\n]+),\s*"([^"]+)",\s*([^\r\n;]+?)\s*\|\|\s*("[^"]*"|\d+(?:\.\d+)?|\[\]|\{\s*\})\);(?<comment>\s*//[^\r\n]*)?', 'Reflect.setField($1, "$2", as3hx.Compat.orValue($3, $4));${comment}')

    $handlerNamePattern = '(?:[ec]_[A-Za-z0-9_]+|avatarLoadComplete|mergeIntoArray|closePrompt|dragStart|dragEnd|onComplete|onFailure|displayAvatarComplete|e_backgroundLoaded|e_searchTimer)'
    $handlerMatches = @()
    $handlerMatches += [regex]::Matches($Text, "(?m)^\s*var\s+($handlerNamePattern)\s+: Dynamic=\s*function")
    $handlerMatches += [regex]::Matches($Text, "(?m)^\s*function\s+($handlerNamePattern)\s*\(")
    if ($handlerMatches.Count -gt 0) {
        $handlerNames = @()
        foreach ($match in $handlerMatches) {
            $name = $match.Groups[1].Value
            if ($handlerNames -notcontains $name) {
                $handlerNames += $name
            }
        }
        foreach ($name in $handlerNames) {
            $escapedName = [regex]::Escape($name)
            $Text = [regex]::Replace($Text, "(?m)^\s*private static var $escapedName\s+: Dynamic;\s*`r?`n", "")
            $Text = [regex]::Replace($Text, "(?m)^(\s*)var\s+$escapedName\s+: Dynamic=\s*function", "`${1}$name = function")
            $Text = [regex]::Replace($Text, "(?m)^(\s*)function\s+$escapedName\s*\(", "`${1}$name = function(")
        }
        $declarations = ($handlerNames | ForEach-Object { "    private static var $_      : Dynamic;" }) -join "`n"
        $Text = [regex]::Replace($Text, "(?m)^(\s*class\s+[A-Za-z_][A-Za-z0-9_]*(?:\s+extends\s+[A-Za-z0-9_\.]+)?\s*\{)\s*$", "`$1`n$declarations", 1)
    }

    $Text = $Text -replace "Reflect\.setField\(match, Std\.string\(0\), \)", "Reflect.field(match, Std.string(0))"
    $Text = [regex]::Replace($Text, 'haxe\.Json\.stringify\(([^,\r\n]+), null, 2\)', 'haxe.Json.stringify($1, null, "  ")')
    $Text = [regex]::Replace($Text, '(?m)^(\s{8,}var\s+[A-Za-z_][A-Za-z0-9_]*\s+: Dynamic);', '$1= null;')
    $Text = [regex]::Replace($Text, 'Flags\.VALUES\[(Flags\.[A-Za-z0-9_]+)\]\s*=\s*([^;\r\n]+);', 'Reflect.setField(Flags.VALUES, $1, $2);')
    $Text = [regex]::Replace($Text, 'Flags\.VALUES\[(Flags\.[A-Za-z0-9_]+)\]', 'as3hx.Compat.field(Flags.VALUES, $1)')
    $Text = $Text.Replace('.toLocaleUpperCase()', '.toUpperCase()')
    $Text = $Text.Replace('.toLocaleLowerCase()', '.toLowerCase()')
    $Text = $Text.Replace('this.parent && this.parent.stage', 'this.parent != null && this.parent.stage != null')
    $Text = $Text.Replace('!this.parent || !this.parent.stage', 'this.parent == null || this.parent.stage == null')
    $Text = $Text.Replace('!this.parent ||', 'this.parent == null ||')
    $Text = $Text.Replace('!stage ||', 'stage == null ||')
    $Text = $Text.Replace('(stage) ? stage.', '(stage != null) ? stage.')

    if ($Text.Contains('Reflect.setField(data, "notes"')) {
        $Text = [regex]::Replace(
            $Text,
            'Reflect\.setField\(data, "notes", (.+)\)\[chart\]\[(.+?)\];',
            'Reflect.setField(Reflect.field(data, "notes")[chart], Std.string($2), $1);'
        )
        $Text = [regex]::Replace(
            $Text,
            'Reflect\.setField\(data, "notes", (.+)\)\[chart\];',
            'Reflect.field(data, "notes")[chart] = $1;'
        )
    }

    if ($fileName -eq "SettingsTabNoteskin.hx") {
        $Text = [regex]::Replace($Text, '(SettingsTabBase\.)+DEFAULT_OPTIONS', 'SettingsTabBase.DEFAULT_OPTIONS')
        $Text = [regex]::Replace($Text, '(?<!SettingsTabBase\.)\bDEFAULT_OPTIONS\b', 'SettingsTabBase.DEFAULT_OPTIONS')
        $Text = [regex]::Replace($Text, '(SettingsTabBase\.)+DEFAULT_OPTIONS', 'SettingsTabBase.DEFAULT_OPTIONS')
        $Text = [regex]::Replace(
            $Text,
            'var nsName\s+: Dynamic=\s*\(new as3hx\.Compat\.Regex\(''\^\\\\s\+\|\\\\s\+\$'', "gs"\)\.replace\((.*?)\), ""\);',
            'var nsName  : Dynamic= new as3hx.Compat.Regex(''^\\s+|\\s+$$'', "gs").replace((${1}), "");'
        )
    }
    elseif ($fileName -eq "MPUserMessagesView.hx") {
        $Text = [regex]::Replace($Text, "(?m)^\s*private static var _mp\s+: Dynamic= Multiplayer\.instance;\s*`r?`n", "")
    }
    elseif ($fileName -eq "Alert.hx") {
        $Text = [regex]::Replace($Text, "(?m)^\s*this\.message = message;\s*`r?`n", "")
    }
    elseif ($fileName -eq "RenderQuality.hx") {
        $Text = $Text.Replace(
            "new BitmapData(source.width * SUPERSAMPLE_SCALE, source.height * SUPERSAMPLE_SCALE, true, 0)",
            "new BitmapData(Std.int(source.width * SUPERSAMPLE_SCALE), Std.int(source.height * SUPERSAMPLE_SCALE), true, 0)"
        )
    }
    elseif ($fileName -eq "Language.hx") {
        $Text = $Text.Replace(
            "try`n        {`n            var xmlMain  : Dynamic= new FastXML(siteDataString);`n            var xmlChildren  : Dynamic= xmlMain.node.children.innerData();",
            "var xmlChildren  : Dynamic= null;`n        try`n        {`n            var xmlMain  : Dynamic= new FastXML(siteDataString);`n            xmlChildren = xmlMain.node.children.innerData();"
        )
    }
    elseif ($fileName -eq "GameOptions.hx") {
        $Text = [regex]::Replace($Text, "\n\s*public function new\(\)\s*\{\s*super\(\);\s*\}\s*(?=\n\})", "`n    public function new()`n    {`n    }`n")
        $Text = $Text.Replace(
            'receptorSpacing = (Reflect.field(settings, "gap") || 80) ? 1 : 0;',
            'receptorSpacing = as3hx.Compat.orValue(Reflect.field(settings, "gap"), 80);'
        )
        $Text = $Text.Replace(
            'receptorSpacing = as3hx.Compat.orValue((Reflect.field(settings, "gap"), 80) ? 1 : 0);',
            'receptorSpacing = as3hx.Compat.orValue(Reflect.field(settings, "gap"), 80);'
        )
        $Text = $Text.Replace(
            'isolationOffset = (Reflect.field(settings, "isolationOffset") || 0) ? 1 : 0;',
            'isolationOffset = as3hx.Compat.orValue(Reflect.field(settings, "isolationOffset"), 0);'
        )
        $Text = $Text.Replace(
            'isolationOffset = as3hx.Compat.orValue((Reflect.field(settings, "isolationOffset"), 0) ? 1 : 0);',
            'isolationOffset = as3hx.Compat.orValue(Reflect.field(settings, "isolationOffset"), 0);'
        )
        $Text = $Text.Replace(
            'isolationLength = (Reflect.field(settings, "isolationLength") || 0) ? 1 : 0;',
            'isolationLength = as3hx.Compat.orValue(Reflect.field(settings, "isolationLength"), 0);'
        )
        $Text = $Text.Replace(
            'isolationLength = as3hx.Compat.orValue((Reflect.field(settings, "isolationLength"), 0) ? 1 : 0);',
            'isolationLength = as3hx.Compat.orValue(Reflect.field(settings, "isolationLength"), 0);'
        )
    }
    elseif ($fileName -eq "Constant.hx") {
        $Text = [regex]::Replace($Text, '(?m)^(\s*var\s+[A-Za-z_][A-Za-z0-9_]*\s+: Dynamic)= null;', '$1;')
    }
    elseif ($fileName -eq "AirContext.hx") {
        $Text = $Text.Replace('storeData[bi] = storeData[bi] ^ (key + bi) % 0xFF;', 'storeData.position = as3hx.Compat.parseInt(bi);' + "`n            var encodedByte                            : Dynamic= storeData.readUnsignedByte() ^ as3hx.Compat.parseInt((key + bi) % 0xFF);" + "`n            storeData.position = as3hx.Compat.parseInt(bi);" + "`n            storeData.writeByte(encodedByte);")
    }
    elseif ($fileName -eq "Noteskins.hx") {
        $Text = $Text.Replace(
            'var note  : Dynamic= new Data()[noteskin]["notes"][color][direction];',
            'var note  : Dynamic= Type.createInstance(Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, Std.string(noteskin)), "notes"), color), direction), []);'
        )
        $Text = $Text.Replace(
            'var receptor  : Dynamic= new Data()[noteskin]["receptor"][direction];',
            'var receptor  : Dynamic= Type.createInstance(Reflect.field(Reflect.field(Reflect.field(_data, Std.string(noteskin)), "receptor"), direction), []);'
        )
        $Text = $Text.Replace(
            'if (as3hx.Compat.truthy(note_pos[0] > dim_w || note_pos[1] > dim_h))',
            'if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(note_pos[0]) > as3hx.Compat.parseFloat(dim_w) || as3hx.Compat.parseFloat(note_pos[1]) > as3hx.Compat.parseFloat(dim_h)))'
        )
        $Text = $Text.Replace(
            'var note_canvas          : Dynamic= new BitmapData(cell_width * scale, cell_height * scale, true, 0);',
            'var note_canvas          : Dynamic= new BitmapData(Std.int(cell_width * scale), Std.int(cell_height * scale), true, 0);'
        )
        $Text = [regex]::Replace(
            $Text,
            'var note_canvas\s+: Dynamic=\s*new BitmapData\(cell_width \* scale, cell_height \* scale, true, 0\);',
            'var note_canvas          : Dynamic= new BitmapData(Std.int(cell_width * scale), Std.int(cell_height * scale), true, 0);'
        )
    }
    elseif ($fileName -eq "PAWindow.hx") {
        $Text = $Text.Replace(
            'checkLabels.checked = as3hx.Compat.orValue((editorLayout.show_labels == null, editorLayout.show_labels));',
            'checkLabels.checked = editorLayout.show_labels == null || as3hx.Compat.truthy(editorLayout.show_labels);'
        )
        $Text = [regex]::Replace($Text, 'new TextFormat\(_lang\.font\(\),\s*scoreSize--,\s*label\.color,\s*true\)', 'new TextFormat(_lang.font(), as3hx.Compat.parseInt(scoreSize--), label.color, true)')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(!((i + 1) % 3)))', 'if (as3hx.Compat.truthy(((i + 1) % 3) == 0))')
    }
    elseif ($fileName -eq "ScrollPaneContent.hx") {
        $Text = $Text.Replace(
            '_child.visible = as3hx.Compat.orValue(((_child.y >= maskY, _child.y + _child.height >= maskY) && _child.y < maskY + maskHeight));',
            '_child.visible = ((_child.y >= maskY || _child.y + _child.height >= maskY) && _child.y < maskY + maskHeight);'
        )
    }
    elseif ($fileName -eq "SongItem.hx") {
        $Text = $Text.Replace(
            'isLocked = as3hx.Compat.orValue(!(!songInfo.access, songInfo.access == GlobalVariables.SONG_ACCESS_PLAYABLE));',
            'isLocked = !(!as3hx.Compat.truthy(songInfo.access) || songInfo.access == GlobalVariables.SONG_ACCESS_PLAYABLE);'
        )
        $Text = $Text.Replace('_lblSongName = as3hx.Compat.orValue(new Text(this, 0, 0, songname, "", 14));', '_lblSongName = new Text(this, 0, 0, songname, 14);')
        $Text = $Text.Replace('this.contextMenu = val;', 'Reflect.setField(this, "contextMenu", val);')
    }
    elseif ($fileName -eq "ChartStepmania.hx" -or $fileName -eq "ChartStepmaniaBeat.hx" -or $fileName -eq "ChartSSC.hx") {
        $Text = [regex]::Replace(
            $Text,
            'var audioExt\s+: Dynamic=\s*\(Reflect\.field\(data, "music"\)\s*\|\|\s*""\)\.substr\(-3\)\.toLowerCase\(\);',
            'var audioExt      : Dynamic= Std.string(as3hx.Compat.orValue(Reflect.field(data, "music"), "")).substr(-3).toLowerCase();'
        )
        $Text = [regex]::Replace(
            $Text,
            'var columnMap\s+: Dynamic=\s*as3hx\.Compat\.field\(COLUMNS, Reflect\.field\(chartData, "type"\)\)\s*\|\|\s*\[\];',
            'var columnMap      : Dynamic= as3hx.Compat.orValue(as3hx.Compat.field(COLUMNS, Reflect.field(chartData, "type")), []);'
        )
        $Text = [regex]::Replace(
            $Text,
            'var bpms\s+: Dynamic=\s*Reflect\.field\(chartData, "bpms"\)\s*\|\|\s*this\.data\["bpms"\]\s*\|\|\s*\[\[0, 60\]\];',
            'var bpms      : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "bpms"), as3hx.Compat.orValue(Reflect.field(this.data, "bpms"), [[0, 60]]));'
        )
        $Text = [regex]::Replace(
            $Text,
            'var stops\s+: Dynamic=\s*Reflect\.field\(chartData, "stops"\)\s*\|\|\s*as3hx\.Compat\.orValue\(this\.data\["stops"\], \[\]\);',
            'var stops      : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "stops"), as3hx.Compat.orValue(Reflect.field(this.data, "stops"), []));'
        )
        $Text = [regex]::Replace(
            $Text,
            'var warps\s+: Dynamic=\s*Reflect\.field\(chartData, "warps"\)\s*\|\|\s*as3hx\.Compat\.orValue\(this\.data\["warps"\], \[\]\);',
            'var warps      : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "warps"), as3hx.Compat.orValue(Reflect.field(this.data, "warps"), []));'
        )
        $Text = $Text.Replace(
            'this.bpms = as3hx.Compat.orValue(this.data["bpms"], []);',
            'this.bpms = as3hx.Compat.orValue(Reflect.field(this.data, "bpms"), []);'
        )
        $Text = $Text.Replace(
            'this.stops = as3hx.Compat.orValue(as3hx.Compat.orValue(this.data["stops"], this.data["freezes"], []));',
            'this.stops = as3hx.Compat.orValue(Reflect.field(this.data, "stops"), as3hx.Compat.orValue(Reflect.field(this.data, "freezes"), []));'
        )
        $Text = $Text.Replace(
            'currentTime += ((Reflect.field(chartData, "offset") || Reflect.field(data, "offset") || 0) * -1000);',
            'currentTime += (as3hx.Compat.parseFloat(as3hx.Compat.orValue(Reflect.field(chartData, "offset"), as3hx.Compat.orValue(Reflect.field(data, "offset"), 0))) * -1000);'
        )
        $Text = [regex]::Replace($Text, 'Reflect\.field\(data, "notes"\)\[chart_index\]', 'Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)]')
        $Text = [regex]::Replace($Text, 'Reflect\.field\(data, "notes"\)\[as3hx\.Compat\.parseInt\(chart_index\)\]\["([^"]+)"\]', 'Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "$1")')
        $Text = [regex]::Replace($Text, 'Reflect\.field\(data, "notes"\)\[chart\]\["data"\]', 'Reflect.field(Reflect.field(data, "notes")[chart], "data")')
        $Text = [regex]::Replace($Text, 'lastStop\[0\]\s*<=\s*currentBeat', 'as3hx.Compat.parseFloat(lastStop[0]) <= as3hx.Compat.parseFloat(currentBeat)')
        $Text = [regex]::Replace($Text, 'lastStop\[0\]\s*<\s*currentRow', 'as3hx.Compat.parseFloat(lastStop[0]) < as3hx.Compat.parseFloat(currentRow)')
        $Text = [regex]::Replace($Text, 'bpms\[i\]\[0\]\s*>\s*currentRow', 'as3hx.Compat.parseFloat(bpms[i][0]) > as3hx.Compat.parseFloat(currentRow)')
        $Text = [regex]::Replace($Text, 'Math\.round\(bpms\[i\]\[0\]\)', 'Math.round(as3hx.Compat.parseFloat(bpms[i][0]))')
        $Text = $Text.Replace(
            'tmp_array[tmp_array.length] = [Math.round(48 * as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex))), arrayList.substr(splitIndex + 1)];',
            'tmp_array[tmp_array.length] = ([Math.round(48 * as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex))), arrayList.substr(splitIndex + 1)] : Array<Dynamic>);'
        )
        $Text = $Text.Replace(
            'tmp_array[tmp_array.length] = [as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), arrayList.substr(splitIndex + 1)];',
            'tmp_array[tmp_array.length] = ([as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), arrayList.substr(splitIndex + 1)] : Array<Dynamic>);'
        )
    }
    elseif ($fileName -eq "ExternalChartBase.hx") {
        $Text = $Text.Replace('return parser.data["notes"];', 'return Reflect.field(parser.data, "notes");')
        $Text = $Text.Replace('return getValidChartData(chart_index)["notes"];', 'return Reflect.field(getValidChartData(chart_index), "notes");')
        $Text = $Text.Replace('return getValidChartData(chart_index)["mines"];', 'return Reflect.field(getValidChartData(chart_index), "mines");')
        $Text = $Text.Replace('return getValidChartData(chart_index)["columns"];', 'return Reflect.field(getValidChartData(chart_index), "columns");')
        $Text = $Text.Replace('maxTime = Math.max(maxTime, nd[i][0] + nd[i][3]);', 'maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][0]) + as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][3]));')
        $Text = $Text.Replace('maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(nd[i][0]) + as3hx.Compat.parseFloat(nd[i][3]));', 'maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][0]) + as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][3]));')
        $Text = $Text.Replace('maxTime = Math.max(maxTime, md[md.length - 1][0]);', 'maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(md[as3hx.Compat.parseInt(md.length - 1)][0]));')
        $Text = $Text.Replace('maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(md[md.length - 1][0]));', 'maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(md[as3hx.Compat.parseInt(md.length - 1)][0]));')
        $Text = $Text.Replace(
            'fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);',
            'var e_error      : Dynamic= function(e      : Dynamic) : Void { };' + "`n        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);"
        )
        $Text = [regex]::Replace(
            $Text,
            '(?m)^(\s*)var e_error\s+: Dynamic=\s*function\(e\s+: Dynamic\)\s*: Void\s*\{\s*\};\r?\n(?:\s*var e_error\s+: Dynamic=\s*function\(e\s+: Dynamic\)\s*: Void\s*\{\s*\};\r?\n)+',
            '$1var e_error      : Dynamic= function(e      : Dynamic) : Void { };' + "`n"
        )
        $Text = [regex]::Replace(
            $Text,
            '\n\s*var e_error\s+: Dynamic=\s*function\(e\s+: Dynamic\)\s*: Void\s*\n\s*\{\s*\n\s*\}\s*(?=\n\s*\})',
            ''
        )
    }
    elseif ($fileName -eq "NoteMod.hx") {
        $Text = $Text.Replace("`n        super();", "")
        $Text = $Text.Replace('notes[notes.length - 1]', 'notes[as3hx.Compat.parseInt(notes.length - 1)]')
        $Text = $Text.Replace('var note                : Dynamic= notes[index];', 'var note                : Dynamic= notes[as3hx.Compat.parseInt(index)];')
        $Text = [regex]::Replace($Text, 'var note\s+: Dynamic=\s*notes\[index\];', 'var note                : Dynamic= notes[as3hx.Compat.parseInt(index)];')
        $Text = $Text.Replace('COLUMN_COLOR[dir % 4]', 'COLUMN_COLOR[as3hx.Compat.parseInt(dir % 4)]')
        $Text = $Text.Replace('return Math.min(options.isolationLength, Math.max(1, notes.length - options.isolationOffset));', 'return as3hx.Compat.parseInt(Math.min(options.isolationLength, Math.max(1, notes.length - options.isolationOffset)));')
        $Text = $Text.Replace('return Math.max(1, notes.length - options.isolationOffset);', 'return as3hx.Compat.parseInt(Math.max(1, notes.length - options.isolationOffset));')
        $Text = $Text.Replace('firstNote = notes[Math.min(notes.length - 1, options.isolationOffset)];', 'firstNote = notes[as3hx.Compat.parseInt(Math.min(notes.length - 1, options.isolationOffset))];')
        $Text = $Text.Replace('lastNote = notes[Math.min(notes.length - 1, options.isolationOffset + options.isolationLength)];', 'lastNote = notes[as3hx.Compat.parseInt(Math.min(notes.length - 1, options.isolationOffset + options.isolationLength))];')
        $Text = $Text.Replace('lastNote = notes[Math.max(0, notes.length - 1 - options.isolationOffset)];', 'lastNote = notes[as3hx.Compat.parseInt(Math.max(0, notes.length - 1 - options.isolationOffset))];')
    }
    elseif ($fileName -eq "Playlist.hx") {
        $Text = [regex]::Replace($Text, '\bescape\(([^()]+)\)', 'StringTools.urlEncode(Std.string($1))')
    }
    elseif ($fileName -eq "Beatbox.hx") {
        $Text = [regex]::Replace($Text, 'var actionRegisters\s+: Dynamic=\s*new Array<Dynamic>\(4\);', 'var actionRegisters         : Dynamic= []; as3hx.Compat.setArrayLength(actionRegisters, 4);')
        $Text = [regex]::Replace($Text, 'actionStack\[actionStack\.length - 1\]', 'actionStack[as3hx.Compat.parseInt(actionStack.length - 1)]')
        $Text = [regex]::Replace($Text, 'var _root\s+: Dynamic=\s*Reflect\.field\(actionVariables, "_root"\)\s*\|\|\s*\{\s*\};', 'var _root         : Dynamic= as3hx.Compat.orValue(Reflect.field(actionVariables, "_root"), { });')
    }
    elseif ($fileName -eq "SwfParser.hx") {
        $Text = [regex]::Replace($Text, 'var ret\s+: Dynamic=\s*new String\(\);', 'var ret         : Dynamic= "";')
    }
    elseif ($fileName -eq "ChartFFRLegacy.hx") {
        $Text = [regex]::Replace($Text, 'var urls\s+: Dynamic=\s*Site\.instance\.data\["alt_engine_list"\];', 'var urls          : Dynamic= Reflect.field(Site.instance.data, "alt_engine_list");')
        $Text = $Text.Replace('as3hx.Compat.field(beat, 2) || "blue"', 'as3hx.Compat.orValue(as3hx.Compat.field(beat, 2), "blue")')
    }
    elseif ($fileName -eq "BoxIcon.hx") {
        $Text = $Text.Replace('if (as3hx.Compat.truthy(this.parent && this.parent.stage))', 'if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))')
    }
    elseif ($fileName -eq "ScrollPane.hx") {
        $Text = $Text.Replace('return Math.max(Math.min(height / content.height, 1), 0) || 0;', 'return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(height / content.height, 1), 0), 0));')
    }
    elseif ($fileName -eq "FileBrowserList.hx") {
        $Text = $Text.Replace('return Math.max(Math.min(_height / _calcHeight, 1), 0) || 0;', 'return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(_height / _calcHeight, 1), 0), 0));')
    }
    elseif ($fileName -eq "FileBrowserItem.hx") {
        $Text = $Text.Replace('Reflect.field(COLUMN_COUNTS, Std.string(Reflect.field(chartLookData[chartLookChartIndex], "type")))++;', 'Reflect.setField(COLUMN_COUNTS, Std.string(Reflect.field(chartLookData[chartLookChartIndex], "type")), as3hx.Compat.parseInt(as3hx.Compat.field(COLUMN_COUNTS, Reflect.field(chartLookData[chartLookChartIndex], "type"))) + 1);')
        $Text = $Text.Replace('_color = (as3hx.Compat.field(EXT_COLORS, songData.ext) || 0) ? 1 : 0;', '_color = as3hx.Compat.parseInt(as3hx.Compat.orValue(as3hx.Compat.field(EXT_COLORS, songData.ext), 0));')
    }
    elseif ($fileName -eq "FileBrowserDifficultyItem.hx") {
        $Text = $Text.Replace("this.cache_info = cache_info;`n        `n        super(index, Reflect.field(cache_info, `"info`")[`"chart`"][index]);", "super(index, Reflect.field(Reflect.field(cache_info, `"info`"), `"chart`")[as3hx.Compat.parseInt(index)]);`n        this.cache_info = cache_info;")
        $Text = $Text.Replace('super(index, Reflect.field(cache_info, "info")["chart"][index]);', 'super(index, Reflect.field(Reflect.field(cache_info, "info"), "chart")[as3hx.Compat.parseInt(index)]);')
    }
    elseif ($fileName -eq "MenuPanel.hx") {
        $Text = $Text.Replace('return my_Parent.addPopup(_panel, newLayer);', 'my_Parent.addPopup(_panel, newLayer);')
        $Text = $Text.Replace('return my_Parent.removePopup();', 'my_Parent.removePopup();')
    }
    elseif ($fileName -eq "Multiplayer.hx") {
        $Text = $Text.Replace('new WebSocketURI(_site.data["game_mp_host"], _site.data["game_mp_port"])', 'new WebSocketURI(Reflect.field(_site.data, "game_mp_host"), as3hx.Compat.parseInt(Reflect.field(_site.data, "game_mp_port")))')
        $Text = $Text.Replace('Reflect.setField(users, Std.string(i), true).isStale;', 'users[as3hx.Compat.parseInt(i)].isStale = true;')
        $Text = $Text.Replace('Reflect.setField(rooms, Std.string(i), true).isStale;', 'rooms[as3hx.Compat.parseInt(i)].isStale = true;')
    }
    elseif ($fileName -eq "Component.hx") {
        $Text = $Text.Replace('    public function invalidate() : Void', '    override public function invalidate() : Void')
    }
    elseif ($fileName -eq "ScrollBar.hx") {
        $Text = [regex]::Replace($Text, '(Slider\.)+HORIZONTAL', 'Slider.HORIZONTAL')
        $Text = [regex]::Replace($Text, '(?<!Slider\.)\bHORIZONTAL\b', 'Slider.HORIZONTAL')
    }
    elseif ($fileName -eq "MainMenu.hx") {
        $Text = [regex]::Replace($Text, 'private var mmc_icons\(default, never\)\s+: Dynamic=\s*\[new IconPlay\(\), new IconPause\(\), new IconStop\(\), new IconDelete\(\)\];', 'private var mmc_icons     : Dynamic= [];')
        $Text = [regex]::Replace($Text, 'private var mmc_functions\(default, never\)\s+: Dynamic=\s*\[playMusic, pauseMusic, stopMusic, deleteMusic\];', 'private var mmc_functions     : Dynamic= [];')
        $Text = $Text.Replace('super(myParent);' + "`n        " + "`n        ArcGlobals.instance.resetConfig();", 'super(myParent);' + "`n        mmc_icons = [new IconPlay(), new IconPause(), new IconStop(), new IconDelete()];" + "`n        mmc_functions = [playMusic, pauseMusic, stopMusic, deleteMusic];" + "`n        " + "`n        ArcGlobals.instance.resetConfig();")
    }
    elseif ($fileName -eq "Main.hx") {
        $Text = [regex]::Replace($Text, 'var nextPanel\s+: Dynamic;', 'var nextPanel                     : Dynamic= null;')
        $Text = $Text.Replace('VSYNC_SUPPORT = stage.exists("vsyncEnabled");', 'VSYNC_SUPPORT = false;')
        $Text = $Text.Replace('this.contextMenu = cm;', 'Reflect.setField(this, "contextMenu", cm);')
        $Text = [regex]::Replace($Text, 'stage\.vsyncEnabled = [^;\r\n]+;', '// vsyncEnabled is AIR-only; OpenFL uses the window FPS cap.')
        $Text = $Text.Replace('Updater.handle(_site.data["update_version"], _site.data["update_url"]);', 'Updater.handle(Reflect.field(_site.data, "update_version"), Reflect.field(_site.data, "update_url"));')
        $Text = [regex]::Replace($Text, '_gvars\.air_windowProperties\["([^"]+)"\]', 'Reflect.field(_gvars.air_windowProperties, "$1")')
        $Text = [regex]::Replace($Text, 'Reflect\.field\(_gvars\.air_windowProperties, "([^"]+)"\) = ([^;\r\n]+);', 'Reflect.setField(_gvars.air_windowProperties, "$1", $2);')
    }
    elseif ($fileName -eq "SettingsWindow.hx") {
        $Text = [regex]::Replace(
            $Text,
            'super\(\);\s*\n\s*this\.win = win;\s*\n\s*super\(win, 450, 200\);',
            'super(win, 450, 200);' + "`n        this.win = win;"
        )
    }
    elseif ($fileName -eq "GameControl.hx") {
        $Text = [regex]::Replace(
            $Text,
            'var out\s+: Dynamic=\s*new GameControlEditor\(editorWidth\);(?:\n\s*var inputX\s+: Dynamic= null;\n\s*var inputY\s+: Dynamic= null;\n\s*var inputWidth\s+: Dynamic= null;\n\s*var inputHeight\s+: Dynamic= null;\n\s*var sliderScale\s+: Dynamic= null;\n\s*var sliderScaleDisplay\s+: Dynamic= null;\n\s*var sliderScaleReset\s+: Dynamic= null;\n\s*var sliderRotate\s+: Dynamic= null;\n\s*var sliderRotateDisplay\s+: Dynamic= null;\n\s*var sliderRotateReset\s+: Dynamic= null;\n\s*var sliderOpacity\s+: Dynamic= null;\n\s*var sliderOpacityDisplay\s+: Dynamic= null;\n\s*var sliderOpacityReset\s+: Dynamic= null;)?',
            'var out        : Dynamic= new GameControlEditor(editorWidth);' + "`n        var inputX        : Dynamic= null;" + "`n        var inputY        : Dynamic= null;" + "`n        var inputWidth        : Dynamic= null;" + "`n        var inputHeight        : Dynamic= null;" + "`n        var sliderScale        : Dynamic= null;" + "`n        var sliderScaleDisplay        : Dynamic= null;" + "`n        var sliderScaleReset        : Dynamic= null;" + "`n        var sliderRotate        : Dynamic= null;" + "`n        var sliderRotateDisplay        : Dynamic= null;" + "`n        var sliderRotateReset        : Dynamic= null;" + "`n        var sliderOpacity        : Dynamic= null;" + "`n        var sliderOpacityDisplay        : Dynamic= null;" + "`n        var sliderOpacityReset        : Dynamic= null;"
        )
        foreach ($localName in @("inputX", "inputY", "inputWidth", "inputHeight", "sliderScale", "sliderScaleDisplay", "sliderScaleReset", "sliderRotate", "sliderRotateDisplay", "sliderRotateReset", "sliderOpacity", "sliderOpacityDisplay", "sliderOpacityReset")) {
            $escapedName = [regex]::Escape($localName)
            $Text = [regex]::Replace($Text, "(?m)^(\s*)var\s+$escapedName\s+: Dynamic=\s*new\b", "`${1}$localName = new")
        }
    }
    elseif ($fileName -eq "AccuracyBar.hx") {
        $Text = $Text.Replace('FLAG_POSITION | FLAG_SIZE | FLAG_ROTATE | FLAG_OPACITY', 'GameControl.FLAG_POSITION | GameControl.FLAG_SIZE | GameControl.FLAG_ROTATE | GameControl.FLAG_OPACITY')
        $Text = [regex]::Replace($Text, 'for \(jn in 1\.\.\.judge\.length - 1\)', 'for (jn in 1...as3hx.Compat.parseInt(judge.length - 1))')
    }
    elseif ($fileName -like "SettingsTab*.hx" -and $fileName -ne "SettingsTabBase.hx") {
        $Text = [regex]::Replace($Text, '(?<!SettingsTabBase\.)\bDEFAULT_OPTIONS\b', 'SettingsTabBase.DEFAULT_OPTIONS')
        $Text = [regex]::Replace($Text, '(SettingsTabBase\.)+DEFAULT_OPTIONS', 'SettingsTabBase.DEFAULT_OPTIONS')
        if ($fileName -eq "SettingsTabColors.hx") {
            $Text = [regex]::Replace($Text, 'Reflect\.setField\((option[A-Za-z]+Colors\[[^\]]+\]), "text", ([^\r\n;]+)\)\.text;', 'Reflect.field($1, "text").text = $2;')
            $Text = [regex]::Replace($Text, 'Reflect\.setField\((option[A-Za-z]+Colors\[[^\]]+\]), "display", ([^\r\n;]+)\)\.color;', 'Reflect.field($1, "display").color = $2;')
            $Text = [regex]::Replace($Text, 'Reflect\.setField\((option[A-Za-z]+Colors\[[^\]]+\]), "enable", ([^\r\n;]+)\)\.checked;', 'Reflect.field($1, "enable").checked = $2;')
        }
        elseif ($fileName -eq "SettingsTabGeneral.hx") {
            $Text = $Text.Replace('optionAutofailInput = new ValidatedText', 'var optionAutofailInput            : Dynamic= new ValidatedText')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["autofail" \+ StringUtil\.upperCase\(item\.autofail\)\]', 'as3hx.Compat.field(_gvars.activeUser, "autofail" + StringUtil.upperCase(item.autofail))')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["autofail" \+ autofail\] = ([^;\r\n]+);', 'Reflect.setField(_gvars.activeUser, "autofail" + autofail, $1);')
        }
        elseif ($fileName -eq "SettingsTabInput.hx") {
            $Text = $Text.Replace('gameKeyInput = new BoxText', 'var gameKeyInput            : Dynamic= new BoxText')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["key" \+ StringUtil\.upperCase\(item\.key\)\]', 'as3hx.Compat.field(_gvars.activeUser, "key" + StringUtil.upperCase(item.key))')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["key" \+ StringUtil\.upperCase\(keyListenerTarget\.key\)\] = ([^;\r\n]+);', 'Reflect.setField(_gvars.activeUser, "key" + StringUtil.upperCase(keyListenerTarget.key), $1);')
        }
        elseif ($fileName -eq "SettingsTabMisc.hx") {
            $Text = [regex]::Replace($Text, '_lang\.data\[lang\]\["([^"]+)"\]', 'as3hx.Compat.field(as3hx.Compat.field(_lang.data, lang), "$1")')
            $Text = [regex]::Replace($Text, '_gvars\.air_windowProperties\["([^"]+)"\] = ([^;\r\n]+);', 'Reflect.setField(_gvars.air_windowProperties, "$1", $2);')
            $Text = [regex]::Replace($Text, '_gvars\.air_windowProperties\["([^"]+)"\]', 'as3hx.Compat.field(_gvars.air_windowProperties, "$1")')
            $Text = [regex]::Replace($Text, '_avars\.configLegacy\["id"\]', 'as3hx.Compat.field(_avars.configLegacy, "id")')
            $Text = [regex]::Replace($Text, '_avars\.legacyDefaultEngine\["id"\]', 'as3hx.Compat.field(_avars.legacyDefaultEngine, "id")')
            $Text = $Text.Replace('for (i in 0..._avars.legacyEngines.length)', 'var i            : Dynamic= 0;' + "`n        while (as3hx.Compat.truthy(i < _avars.legacyEngines.length))")
            $Text = $Text.Replace('                break;' + "`n            }" + "`n        }" + "`n        if (as3hx.Compat.truthy(i == _avars.legacyEngines.length))", '                break;' + "`n            }" + "`n            i++;" + "`n        }" + "`n        if (as3hx.Compat.truthy(i == _avars.legacyEngines.length))")
        }
        elseif ($fileName -eq "SettingsTabNoteskin.hx") {
            $Text = [regex]::Replace($Text, '_noteskins\.data\[0\]\["notes"\]\["blue"\]', 'as3hx.Compat.field(as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes"), "blue")')
            $Text = [regex]::Replace($Text, '_noteskins\.data\[0\]\["notes"\]', 'as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes")')
        }
        elseif ($fileName -eq "SettingsTabVisuals.hx") {
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["DISPLAY_" \+ item\.display\]', 'as3hx.Compat.field(_gvars.activeUser, "DISPLAY_" + item.display)')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["DISPLAY_" \+ e\.target\.display\] = ([^;\r\n]+);', 'Reflect.setField(_gvars.activeUser, "DISPLAY_" + e.target.display, $1);')
            $Text = [regex]::Replace($Text, '_gvars\.activeUser\["DISPLAY_" \+ e\.target\.display\]', 'as3hx.Compat.field(_gvars.activeUser, "DISPLAY_" + e.target.display)')
            $Text = [regex]::Replace($Text, '\(([^()\r\n]+)\)\.toFixed\((\d+)\)', 'as3hx.Compat.toFixed($1, $2)')
            $Text = [regex]::Replace($Text, '([A-Za-z0-9_\.]+)\.toFixed\((\d+)\)', 'as3hx.Compat.toFixed($1, $2)')
        }
    }
    elseif ($fileName -eq "UserSongNotes.hx") {
        $Text = $Text.Replace('haxe.Json.stringify(sql_data, null, 2)', 'haxe.Json.stringify(sql_data, null, "  ")')
        $Text = $Text.Replace('parsed_data.song_details[engine_id] = { };', 'Reflect.setField(parsed_data.song_details, Std.string(engine_id), { });')
        $Text = $Text.Replace('var engine             : Dynamic= obj.song_details[engine_id];', 'var engine             : Dynamic= as3hx.Compat.field(obj.song_details, engine_id);')
        $Text = $Text.Replace('parsed_data.song_details[engine_id][level_id] = new UserSongData(engine_id, level_id, Reflect.field(engine, level_id));', 'Reflect.setField(as3hx.Compat.field(parsed_data.song_details, engine_id), Std.string(level_id), new UserSongData(engine_id, level_id, Reflect.field(engine, Std.string(level_id))));')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(sql_data.song_details[engine_id] == null || sql_data.song_details[engine_id][level_id] == null))', 'if (as3hx.Compat.truthy(as3hx.Compat.field(sql_data.song_details, engine_id) == null || as3hx.Compat.field(as3hx.Compat.field(sql_data.song_details, engine_id), level_id) == null))')
        $Text = $Text.Replace('return (try cast(sql_data.song_details[engine_id][level_id], UserSongData) catch(e:Dynamic) null);', 'return (try cast(as3hx.Compat.field(as3hx.Compat.field(sql_data.song_details, engine_id), level_id), UserSongData) catch(e:Dynamic) null);')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(sql_data.song_details[engine_id] == null))', 'if (as3hx.Compat.truthy(as3hx.Compat.field(sql_data.song_details, engine_id) == null))')
        $Text = $Text.Replace('sql_data.song_details[engine_id] = { };', 'Reflect.setField(sql_data.song_details, Std.string(engine_id), { });')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(sql_data.song_details[engine_id][level_id] == null))', 'if (as3hx.Compat.truthy(as3hx.Compat.field(as3hx.Compat.field(sql_data.song_details, engine_id), level_id) == null))')
        $Text = $Text.Replace('sql_data.song_details[engine_id][level_id] = new UserSongData(engine_id, level_id, null);', 'Reflect.setField(as3hx.Compat.field(sql_data.song_details, engine_id), Std.string(level_id), new UserSongData(engine_id, level_id, null));')
    }
    elseif ($fileName -eq "LocalOptions.hx") {
        $Text = $Text.Replace('haxe.Json.stringify(LOCAL_SO.data, null, 2)', 'haxe.Json.stringify(LOCAL_SO.data, null, "  ")')
        $Text = $Text.Replace('haxe.Json.stringify(SO_OBJECT, null, 2)', 'haxe.Json.stringify(SO_OBJECT, null, "  ")')
    }
    elseif ($fileName -eq "EngineLevelFilter.hx") {
        $Text = $Text.Replace('userData.skill_rating_levelranks[userData.skill_rating_levelranks.length - 1].equiv', 'userData.skill_rating_levelranks[as3hx.Compat.parseInt(userData.skill_rating_levelranks.length - 1)].equiv')
    }
    elseif ($fileName -eq "User.hx") {
        $Text = $Text.Replace('skill_rating_levelranks[skill_rating_top_count - 1]', 'skill_rating_levelranks[as3hx.Compat.parseInt(skill_rating_top_count - 1)]')
    }
    elseif ($fileName -eq "FileCache.hx") {
        $Text = $Text.Replace('(Reflect.field(FILE_CACHE, "cache_version") || 0)', 'as3hx.Compat.orValue(Reflect.field(FILE_CACHE, "cache_version"), 0)')
    }
    elseif ($fileName -eq "Song.hx") {
        $Text = [regex]::Replace($Text, 'var chartData\s+: Dynamic;', 'var chartData                      : Dynamic= null;')
        $Text = [regex]::Replace($Text, 'var storeChartData\s+: Dynamic;', 'var storeChartData                       : Dynamic= null;')
        $Text = $Text.Replace('TimeUtil.convertToHHMMSS(chart.Notes[chart.Notes.length - 1].time)', 'TimeUtil.convertToHHMMSS(as3hx.Compat.parseInt(chart.Notes[as3hx.Compat.parseInt(chart.Notes.length - 1)].time))')
        $Text = $Text.Replace('(try cast(baseSound, Dynamic) catch(e:Dynamic) null).extract(rateSamples, 4096, (seekExtract) ? sample * mp3Rate : -1)', 'baseSound.extract(rateSamples, 4096, as3hx.Compat.parseFloat((seekExtract) ? sample * mp3Rate : -1))')
        $Text = $Text.Replace('chart.Notes[chart.Notes.length - 1].frame', 'chart.Notes[as3hx.Compat.parseInt(chart.Notes.length - 1)].frame')
        $Text = $Text.Replace('chart.Notes[Math.max(0, chart.Notes.length - 1 - options.isolationOffset)]', 'chart.Notes[as3hx.Compat.parseInt(Math.max(0, chart.Notes.length - 1 - options.isolationOffset))]')
        $Text = $Text.Replace('chart.Notes[options.isolationOffset]', 'chart.Notes[as3hx.Compat.parseInt(options.isolationOffset)]')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(!chart.Notes || chart.Notes.length <= 0))', 'if (as3hx.Compat.truthy(chart.Notes == null || chart.Notes.length <= 0))')
    }
    elseif ($fileName -eq "MPMatchResultsFFR.hx") {
        $Text = [regex]::Replace($Text, 'DateUtil\.format\(new Date\(info\.timestamp\), "Y-m-d H:i:s"\)', 'DateUtil.format(Date.fromTime(as3hx.Compat.parseFloat(info.timestamp)), "Y-m-d H:i:s")')
        $Text = [regex]::Replace($Text, 'TimeUtil\.getFormattedDate\(new Date\(info\.timestamp\)\)', 'TimeUtil.getFormattedDate(Date.fromTime(as3hx.Compat.parseFloat(info.timestamp)))')
    }
    elseif ($fileName -eq "GameScoreResult.hx") {
        $Text = $Text.Replace('time > j.t', 'as3hx.Compat.parseFloat(time) > as3hx.Compat.parseFloat(j.t)')
    }
    elseif ($fileName -eq "ReplayPack.hx") {
        $Text = $Text.Replace('// Write Note Judements' + "`n        binReplay.writeInt(binNotes.length);", '// Write Note Judements' + "`n        binReplay.writeInt(binNotes.length);" + "`n        var nx             : Dynamic= 0;")
        $Text = $Text.Replace('for (nx in x...4)', 'nx = as3hx.Compat.parseInt(x);' + "`n                while (as3hx.Compat.truthy(nx < 4))")
        $Text = $Text.Replace('for (nx in 0...binBoos.length)', 'nx = 0;' + "`n        while (as3hx.Compat.truthy(nx < binBoos.length))")
        $Text = $Text.Replace('LAST_TIME = CUR_TIME;' + "`n            booCount++;", 'LAST_TIME = CUR_TIME;' + "`n            booCount++;" + "`n            nx++;")
    }
    elseif ($fileName -eq "Replay.hx") {
        $Text = $Text.Replace('data.judgements["perfect"]', 'as3hx.Compat.field(data.judgements, "perfect")')
        $Text = $Text.Replace('data.judgements["amazing"]', 'as3hx.Compat.field(data.judgements, "amazing")')
        $Text = $Text.Replace('data.judgements["good"]', 'as3hx.Compat.field(data.judgements, "good")')
        $Text = $Text.Replace('data.judgements["average"]', 'as3hx.Compat.field(data.judgements, "average")')
        $Text = $Text.Replace('data.judgements["miss"]', 'as3hx.Compat.field(data.judgements, "miss")')
        $Text = $Text.Replace('data.judgements["boo"]', 'as3hx.Compat.field(data.judgements, "boo")')
        $Text = $Text.Replace('data.judgements["maxcombo"]', 'as3hx.Compat.field(data.judgements, "maxcombo")')
    }
    elseif ($fileName -eq "PopupFileBrowser.hx") {
        $Text = [regex]::Replace($Text, 'for \(i in 0\.\.\.arLen - 1\)', 'for (i in 0...as3hx.Compat.parseInt(arLen - 1))')
        $Text = [regex]::Replace($Text, 'for \(n in i \+ 1\.\.\.arLen\)', 'n = as3hx.Compat.parseInt(i + 1);' + "`n            while (as3hx.Compat.truthy(n < arLen))")
        $Text = $Text.Replace('                    break;' + "`n                }" + "`n            }" + "`n        }" + "`n        " + "`n        // Sorting", '                    break;' + "`n                }" + "`n                n++;" + "`n            }" + "`n        }" + "`n        " + "`n        // Sorting")
        $Text = $Text.Replace('listFilter.type = e.target.selectedItem["data"];', 'listFilter.type = Reflect.field(e.target.selectedItem, "data");')
        $Text = [regex]::Replace($Text, 'var imageLoader\s+: Dynamic=\s*new Loader\(\);', 'var imageLoader         : Dynamic= new Loader();' + "`n                var e_bannerLoaded         : Dynamic= null;")
        $Text = $Text.Replace('function e_bannerLoaded(e         : Dynamic) : Void', 'e_bannerLoaded = function(e         : Dynamic) : Void')
        $Text = $Text.Replace('var infoDisplay         : Dynamic= [[Reflect.field(info, "data")[0]["info"]["name"], 14], [Reflect.field(info, "data")[0]["info"]["author"], 12]];', 'var infoData         : Dynamic= as3hx.Compat.field(info, "data");' + "`n        var infoZero         : Dynamic= as3hx.Compat.field(infoData, 0);" + "`n        var infoInfo         : Dynamic= as3hx.Compat.field(infoZero, `"info`");" + "`n        var infoDisplay         : Dynamic= [[as3hx.Compat.field(infoInfo, `"name`"), 14], [as3hx.Compat.field(infoInfo, `"author`"), 12]];")
        $Text = [regex]::Replace($Text, 'var infoDisplay\s+: Dynamic=\s*\[\[Reflect\.field\(info, "data"\)\[0\]\["info"\]\["name"\], 14\], \[Reflect\.field\(info, "data"\)\[0\]\["info"\]\["author"\], 12\]\];', 'var infoData         : Dynamic= as3hx.Compat.field(info, "data");' + "`n        var infoZero         : Dynamic= as3hx.Compat.field(infoData, 0);" + "`n        var infoInfo         : Dynamic= as3hx.Compat.field(infoZero, `"info`");" + "`n        var infoDisplay         : Dynamic= [[as3hx.Compat.field(infoInfo, `"name`"), 14], [as3hx.Compat.field(infoInfo, `"author`"), 12]];")
        $Text = $Text.Replace('Reflect.field(infoDisplay, item)[0]', 'as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 0)')
        $Text = $Text.Replace('Reflect.field(infoDisplay, item)[1]', 'as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 1)')
        $Text = $Text.Replace('i = songDifficulties.length - 1;', 'var i         : Dynamic= songDifficulties.length - 1;')
    }
    elseif ($fileName -eq "PopupQueueManager.hx") {
        $Text = $Text.Replace('private var CURRENT_TAB         : Dynamic= TAB_MAIN;', 'private var CURRENT_TAB         : Dynamic;')
        $Text = [regex]::Replace($Text, 'private var CURRENT_TAB\s+: Dynamic=\s*TAB_MAIN;', 'private var CURRENT_TAB         : Dynamic;')
        $Text = $Text.Replace('super(myParent);', 'super(myParent);' + "`n        CURRENT_TAB = TAB_MAIN;")
        $Text = $Text.Replace('Reflect.field(songlist, rank)', 'Reflect.field(songlist, Std.string(rank))')
    }
    elseif ($fileName -eq "PopupSongNotes.hx") {
        $Text = $Text.Replace('_gvars.playerUser.songRatings[Reflect.setField(songInfo, "level", sRating.value)];', 'Reflect.setField(_gvars.playerUser.songRatings, Std.string(Reflect.field(songInfo, "level")), sRating.value);')
        $Text = $Text.Replace('_playlist.playList[Reflect.setField(songInfo, "level", Reflect.field(_data, "new_value"))]["song_rating"];', 'Reflect.setField(as3hx.Compat.field(_playlist.playList, Reflect.field(songInfo, "level")), "song_rating", Reflect.field(_data, "new_value"));')
    }
    elseif ($fileName -eq "MenuSongSelection.hx") {
        $Text = $Text.Replace('return item.difficulty <= 0 || item.difficulty >= _gvars.DIFFICULTY_RANGES[genre_index][0];', 'return as3hx.Compat.parseFloat(item.difficulty) <= 0 || as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][0]);')
        $Text = $Text.Replace('return item.difficulty >= _gvars.DIFFICULTY_RANGES[genre_index][0] && item.difficulty <= _gvars.DIFFICULTY_RANGES[genre_index][1];', 'return as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][0]) && as3hx.Compat.parseFloat(item.difficulty) <= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][1]);')
        $Text = $Text.Replace('return item.difficulty <= 0 || item.difficulty >= _gvars.DIFFICULTY_RANGES[options.activeGenre][0];', 'return as3hx.Compat.parseFloat(item.difficulty) <= 0 || as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][0]);')
        $Text = $Text.Replace('return item.difficulty >= _gvars.DIFFICULTY_RANGES[options.activeGenre][0] && item.difficulty <= _gvars.DIFFICULTY_RANGES[options.activeGenre][1];', 'return as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][0]) && as3hx.Compat.parseFloat(item.difficulty) <= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][1]);')
        $Text = $Text.Replace('return ((!_gvars.activeUser.DISPLAY_LEGACY_SONGS && !_playlist.engine)) ? _gvars.TOTAL_GENRES - 1 : _gvars.TOTAL_GENRES;', 'return as3hx.Compat.parseInt(((!_gvars.activeUser.DISPLAY_LEGACY_SONGS && !_playlist.engine)) ? _gvars.TOTAL_GENRES - 1 : _gvars.TOTAL_GENRES);')
        $Text = $Text.Replace('var noteCount         : Dynamic= song.note_count || songLevelRank.arrows;', 'var noteCount         : Dynamic= as3hx.Compat.orValue(song.note_count, songLevelRank.arrows);')
        $Text = $Text.Replace('var infoRanks         : Dynamic= _gvars.activeUser.getLevelRank(songInfo) || { };', 'var infoRanks         : Dynamic= as3hx.Compat.orValue(_gvars.activeUser.getLevelRank(songInfo), { });')
        $Text = [regex]::Replace($Text, 'var infoRanks\s+: Dynamic=\s*_gvars\.activeUser\.getLevelRank\(songInfo\)\s+\|\|\s+\{ \};', 'var infoRanks         : Dynamic= as3hx.Compat.orValue(_gvars.activeUser.getLevelRank(songInfo), { });')
        $Text = $Text.Replace('infoDetails = as3hx.Compat.orValue(new Text(infoBox, 5, tY, Reflect.field(infoDisplay, item)[1], ""));', 'infoDetails = new Text(infoBox, 5, tY, as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 1), "");')
        $Text = $Text.Replace('Reflect.field(infoDisplay, item)[0]', 'as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 0)')
        $Text = $Text.Replace('Reflect.field(infoDisplay, item)[1]', 'as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 1)')
        $Text = $Text.Replace('Math.min(100, Math.max(0, (infoRanks.perfect + infoRanks.good + infoRanks.average + infoRanks.miss) / songInfo.note_count * 100)).toFixed(2)', 'as3hx.Compat.toFixed(Math.min(100, Math.max(0, (infoRanks.perfect + infoRanks.good + infoRanks.average + infoRanks.miss) / songInfo.note_count * 100)), 2)')
        $Text = $Text.Replace('options.last_search_type = searchTypeBox.selectedItem["data"];', 'options.last_search_type = Reflect.field(searchTypeBox.selectedItem, "data");')
        $Text = [regex]::Replace($Text, 'var searchTypeParam\s+: Dynamic=\s*searchTypeBox\.selectedItem\["data"\];', 'var searchTypeParam         : Dynamic= Reflect.field(searchTypeBox.selectedItem, "data");')
        $Text = $Text.Replace('options.last_search_type = e.target.selectedItem["data"];', 'options.last_search_type = Reflect.field(e.target.selectedItem, "data");')
        $Text = $Text.Replace('options.last_sort_type = e.target.selectedItem["data"];', 'options.last_sort_type = Reflect.field(e.target.selectedItem, "data");')
        $Text = $Text.Replace('options.last_sort_order = e.target.selectedItem["data"];', 'options.last_sort_order = Reflect.field(e.target.selectedItem, "data");')
        $Text = $Text.Replace('return Math.ceil(genreLength / ITEM_PER_PAGE);', 'return as3hx.Compat.parseInt(Math.ceil(genreLength / ITEM_PER_PAGE));')
        $Text = $Text.Replace('return Math.min(Math.ceil(genreLength / 12), 20);', 'return as3hx.Compat.parseInt(Math.min(Math.ceil(genreLength / 12), 20));')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(this.parent && this.parent.stage))', 'if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(!this.parent || !this.parent.stage))', 'if (as3hx.Compat.truthy(this.parent == null || this.parent.stage == null))')
    }
    elseif ($fileName -eq "PopupFilterManager.hx") {
        $Text = $Text.Replace('_gvars.activeFilter = _gvars.activeUser.filters[_gvars.activeUser.filters.length - 1];', '_gvars.activeFilter = _gvars.activeUser.filters[as3hx.Compat.parseInt(_gvars.activeUser.filters.length - 1)];')
        $Text = $Text.Replace('SELECTED_FILTER = (try cast(e.target, BoxButton) catch(e:Dynamic) null).tag;', 'var filterButton         : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null);' + "`n        SELECTED_FILTER = (filterButton != null) ? filterButton.tag : null;")
        $Text = $Text.Replace('var filter          : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null).tag;', 'var removeFilterButton         : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null);' + "`n        var filter          : Dynamic= (removeFilterButton != null) ? removeFilterButton.tag : null;")
        $Text = [regex]::Replace($Text, 'var filter\s+: Dynamic=\s*\(try cast\(e\.target, BoxButton\) catch\(e:Dynamic\) null\)\.tag;', 'var removeFilterButton         : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null);' + "`n        var filter          : Dynamic= (removeFilterButton != null) ? removeFilterButton.tag : null;")
    }
    elseif ($fileName -eq "ReplayHistoryWindow.hx") {
        $Text = $Text.Replace('_gvars.options.layout = _gvars.playerUser.gameLayout["sp"];', '_gvars.options.layout = Reflect.field(_gvars.playerUser.gameLayout, "sp");')
    }
    elseif ($fileName -eq "ZipHeader.hx") {
        $Text = $Text.Replace('return new Date(year, month - 1, day, hour, minute, second);', 'return new Date(as3hx.Compat.parseInt(year), as3hx.Compat.parseInt(month - 1), as3hx.Compat.parseInt(day), as3hx.Compat.parseInt(hour), as3hx.Compat.parseInt(minute), as3hx.Compat.parseInt(second));')
        $Text = $Text.Replace('var date               : Dynamic= new Date(year, month - 1, day, hour, min, sec, 0);', 'var date               : Dynamic= new Date(as3hx.Compat.parseInt(year), as3hx.Compat.parseInt(month - 1), as3hx.Compat.parseInt(day), as3hx.Compat.parseInt(hour), as3hx.Compat.parseInt(min), as3hx.Compat.parseInt(sec));')
        $Text = [regex]::Replace($Text, 'var date\s+: Dynamic=\s*new Date\(year, month - 1, day, hour, min, sec, 0\);', 'var date               : Dynamic= new Date(as3hx.Compat.parseInt(year), as3hx.Compat.parseInt(month - 1), as3hx.Compat.parseInt(day), as3hx.Compat.parseInt(hour), as3hx.Compat.parseInt(min), as3hx.Compat.parseInt(sec));')
    }
    elseif ($fileName -eq "ZipCRC32.hx") {
        $Text = $Text.Replace('var arr             : Dynamic= new Array<Dynamic>(256);', 'var arr             : Dynamic= [];' + "`n        as3hx.Compat.setArrayLength(arr, 256);")
        $Text = [regex]::Replace($Text, 'var arr\s+: Dynamic=\s*new Array<Dynamic>\(256\);', 'var arr             : Dynamic= [];' + "`n        as3hx.Compat.setArrayLength(arr, 256);")
    }
    elseif ($fileName -eq "ZipCrypto.hx") {
        $Text = $Text.Replace('_key = new Array<Dynamic>(3);', '_key = [];' + "`n        as3hx.Compat.setArrayLength(_key, 3);")
        $Text = $Text.Replace('var ret             : Dynamic= as3hx.Compat.parseInt((temp * (temp ^ 1)) >> 8) & 0xFF;', 'var ret             : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(temp * (temp ^ 1)) >> 8) & 0xFF;')
        $Text = [regex]::Replace($Text, 'var ret\s+: Dynamic=\s*as3hx\.Compat\.parseInt\(\(temp \* \(temp \^ 1\)\) >> 8\) & 0xFF;', 'var ret             : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(temp * (temp ^ 1)) >> 8) & 0xFF;')
        $Text = $Text.Replace('return b;', 'return as3hx.Compat.parseInt(b);')
        $Text = $Text.Replace('var b             : Dynamic= cryptHeader.readUnsignedByte();', 'b = cryptHeader.readUnsignedByte();')
        $Text = $Text.Replace('cryptHeader.position = 0;', 'cryptHeader.position = 0;' + "`n        var b             : Dynamic= 0;")
    }
    elseif ($fileName -eq "Judge.hx") {
        $Text = $Text.Replace('Judge_Tweens', 'JudgeTweens')
        $Text = $Text.Replace('new TextFormat(Fonts.AACHEN_LIGHT, 42 * options.judgeScale, 0xffffff, true)', 'new TextFormat(Fonts.AACHEN_LIGHT, as3hx.Compat.parseInt(42 * options.judgeScale), 0xffffff, true)')
        $Text = $Text.Replace('FLAG_POSITION | FLAG_ROTATE | FLAG_OPACITY', 'GameControl.FLAG_POSITION | GameControl.FLAG_ROTATE | GameControl.FLAG_OPACITY')
    }
    elseif ($fileName -eq "GameMultiplayerWait.hx") {
        $Text = $Text.Replace('_gvars.songResults[_gvars.songResults.length - 1]', '_gvars.songResults[as3hx.Compat.parseInt(_gvars.songResults.length - 1)]')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(user.rate < lowestRate))', 'if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(user.rate) < as3hx.Compat.parseFloat(lowestRate)))')
        $Text = $Text.Replace('Math.ceil(userResult.song.chart.Notes[userResult.song.chart.Notes.length - 1].time)', 'as3hx.Compat.parseInt(Math.ceil(userResult.song.chart.Notes[as3hx.Compat.parseInt(userResult.song.chart.Notes.length - 1)].time))')
    }
    elseif ($fileName -eq "GameResults.hx") {
        $Text = $Text.Replace('songResults[songResults.length - 1]', 'songResults[as3hx.Compat.parseInt(songResults.length - 1)]')
    }
    elseif ($fileName -eq "Fonts.hx") {
        $Text = [regex]::Replace($Text, '\n\s*private static var Fonts_static_initializer = \{.*?\n\s*\}\s*(?=\n\})', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
    elseif ($fileName -eq "GlobalVariables.hx") {
        $Text = $Text.Replace('if (as3hx.Compat.truthy(level >= divisionLevels[div]))', 'if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(level) >= as3hx.Compat.parseFloat(divisionLevels[as3hx.Compat.parseInt(div)])))')
        $Text = $Text.Replace('Reflect.setField(TOKENS, Std.string(Reflect.field(Reflect.field(TOKENS_TYPE, type), id).level), 1).unlock;', 'Reflect.setField(as3hx.Compat.field(TOKENS, Reflect.field(Reflect.field(TOKENS_TYPE, type), id).level), "unlock", 1);')
    }
    elseif ($fileName -eq "LocalStore.hx") {
        $Text = $Text.Replace('Reflect.setField(out, key, SO_OBJECT.data[key]);', 'Reflect.setField(out, Std.string(key), as3hx.Compat.field(SO_OBJECT.data, key));')
    }
    elseif ($fileName -eq "PopupMessage.hx") {
        $Text = [regex]::Replace($Text, 'private var _lang\s+: Dynamic=\s*Language\.instance;', 'private var _lang            : Dynamic;')
        $Text = [regex]::Replace($Text, 'private var dislayText\s+: Dynamic=\s*_lang\.string\("popup_message_missing_error_text"\);', 'private var dislayText            : Dynamic= "";')
        $Text = $Text.Replace('super(myParent);', 'super(myParent);' + "`n        _lang = Language.instance;")
    }
    elseif ($fileName -eq "NoteBox.hx") {
        $Text = $Text.Replace('FLAG_POSITION | FLAG_ROTATE | FLAG_SCALE', 'GameControl.FLAG_POSITION | GameControl.FLAG_ROTATE | GameControl.FLAG_SCALE')
        $Text = $Text.Replace('sliderRotate.slideValue = this.rotationX;', 'sliderRotate.slideValue = as3hx.Compat.parseFloat(as3hx.Compat.orValue(Reflect.field(this, "rotationX"), 0));')
        $Text = [regex]::Replace($Text, '\bself\.rotationX\s*=\s*([^;\r\n]+);', 'Reflect.setField(self, "rotationX", $1);')
    }
    elseif ($fileName -eq "PAWindow.hx") {
        $Text = [regex]::Replace($Text, 'new TextFormat\(_lang\.font\(\), scoreSize--, label\.color, true\)', 'new TextFormat(_lang.font(), as3hx.Compat.parseInt(scoreSize--), label.color, true)')
        $Text = [regex]::Replace($Text, 'new TextFormat\(_lang\.font\(\),\s*scoreSize--,\s*label\.color,\s*true\)', 'new TextFormat(_lang.font(), as3hx.Compat.parseInt(scoreSize--), label.color, true)')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(!((i + 1) % 3)))', 'if (as3hx.Compat.truthy(((i + 1) % 3) == 0))')
    }
    elseif ($fileName -eq "GamePlaybackReader.hx") {
        $Text = $Text.Replace('lastIndex = output[output.length - 1].index;', 'lastIndex = output[as3hx.Compat.parseInt(output.length - 1)].index;')
    }
    elseif ($fileName -eq "GameplayDisplay.hx") {
        $Text = $Text.Replace('options.modCache["mirror"] = true;', 'Reflect.setField(options.modCache, "mirror", true);')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(song.songInfo.difficulty <= options.autofail[7]))', 'if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(song.songInfo.difficulty) <= as3hx.Compat.parseFloat(options.autofail[7])))')
        $Text = $Text.Replace('_laneGuideLastDisplayState = (stage) ? stage.displayState : "";', '_laneGuideLastDisplayState = (stage != null) ? stage.displayState : "";')
        $Text = $Text.Replace('_laneGuideLastStageWidth = (stage) ? stage.stageWidth : 0;', '_laneGuideLastStageWidth = (stage != null) ? stage.stageWidth : 0;')
        $Text = $Text.Replace('_laneGuideLastStageHeight = (stage) ? stage.stageHeight : 0;', '_laneGuideLastStageHeight = (stage != null) ? stage.stageHeight : 0;')
        $Text = $Text.Replace('new Date(options.replay.timestamp * 1000)', 'Date.fromTime(as3hx.Compat.parseFloat(options.replay.timestamp) * 1000)')
        $Text = $Text.Replace('_gvars.playerUser.gameLayout["sp"]', 'Reflect.field(_gvars.playerUser.gameLayout, "sp")')
        $Text = $Text.Replace('switch (keyCode)' + "`n                {`n                    case _gvars.activeUser.keyLeft:`n                        dir = `"L`";`n                    `n                    case _gvars.activeUser.keyRight:`n                        dir = `"R`";`n                    `n                    case _gvars.activeUser.keyUp:`n                        dir = `"U`";`n                    `n                    case _gvars.activeUser.keyDown:`n                        dir = `"D`";`n                }", 'if (keyCode == _gvars.activeUser.keyLeft) { dir = "L"; }' + "`n                else if (keyCode == _gvars.activeUser.keyRight) { dir = `"R`"; }" + "`n                else if (keyCode == _gvars.activeUser.keyUp) { dir = `"U`"; }" + "`n                else if (keyCode == _gvars.activeUser.keyDown) { dir = `"D`"; }")
        $Text = $Text.Replace('switch (keyCode)' + "`n        {`n            case _gvars.playerUser.keyLeft:`n                dir = `"L`";`n            `n            case _gvars.playerUser.keyRight:`n                dir = `"R`";`n            `n            case _gvars.playerUser.keyUp:`n                dir = `"U`";`n            `n            case _gvars.playerUser.keyDown:`n                dir = `"D`";`n        }", 'if (keyCode == _gvars.playerUser.keyLeft) { dir = "L"; }' + "`n        else if (keyCode == _gvars.playerUser.keyRight) { dir = `"R`"; }" + "`n        else if (keyCode == _gvars.playerUser.keyUp) { dir = `"U`"; }" + "`n        else if (keyCode == _gvars.playerUser.keyDown) { dir = `"D`"; }")
        $Text = $Text.Replace('for (n in 0...notes.length)' + "`n        {", 'var n         : Dynamic= 0;' + "`n        while (as3hx.Compat.truthy(n < notes.length))`n        {")
        $Text = $Text.Replace('for (n in 0...notes.length)' + "`n            {", 'var n         : Dynamic= 0;' + "`n            while (as3hx.Compat.truthy(n < notes.length))`n            {")
        $Text = [regex]::Replace($Text, '(\n\s*else\s*\{\s*\n\s*break;\s*\n\s*\})(\s*\n\s*\})', '$1' + "`n            n++;`$2")
        $Text = $Text.Replace('var score          : Dynamic= 0;' + "`n        for (note/* AS3HX WARNING could not determine type for var: note exp: EField(EIdent(uiNoteField),notes) type: null */ in as3hx.Compat.iter(uiNoteField.notes))", 'var score          : Dynamic= 0;' + "`n        var note          : Dynamic= null;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))")
        $Text = $Text.Replace('var frame          : Dynamic= 0;' + "`n        var booConflict          : Dynamic= false;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))" + "`n        {", 'var frame          : Dynamic= 0;' + "`n        var booConflict          : Dynamic= false;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))`n        {`n            note = noteCandidate;")
        $Text = $Text.Replace('var score          : Dynamic= 0;' + "`n        var note          : Dynamic= null;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))" + "`n        {", 'var score          : Dynamic= 0;' + "`n        var note          : Dynamic= null;" + "`n        var diff          : Dynamic= 0;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))`n        {`n            note = noteCandidate;")
        $Text = $Text.Replace('var diff          : Dynamic= as3hx.Compat.parseInt(frame + JUDGE_OFFSET_FRAMES - note.FRAME);', 'diff = as3hx.Compat.parseInt(frame + JUDGE_OFFSET_FRAMES - note.FRAME);')
        $Text = $Text.Replace('if (as3hx.Compat.truthy(judgeAccuracy > j.time))', 'if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(judgeAccuracy) > as3hx.Compat.parseFloat(j.time)))')
        $Text = $Text.Replace('else if (as3hx.Compat.truthy(judgeAccuracy <= judgeSettings[0].time))', 'else if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(judgeAccuracy) <= as3hx.Compat.parseFloat(judgeSettings[0].time)))')
        $Text = $Text.Replace('else if (as3hx.Compat.truthy(count > 0 && note.FRAME > noteFrame))', 'else if (as3hx.Compat.truthy(count > 0 && as3hx.Compat.parseFloat(note.FRAME) > as3hx.Compat.parseFloat(noteFrame)))')
        $Text = [regex]::Replace($Text, 'var score\s+: Dynamic=\s*0;\s*\n\s*var frame\s+: Dynamic=\s*0;\s*\n\s*var booConflict\s+: Dynamic=\s*false;\s*\n\s*for \(note/\* AS3HX WARNING could not determine type for var: note exp: EField\(EIdent\(uiNoteField\),notes\) type: null \*/ in as3hx\.Compat\.iter\(uiNoteField\.notes\)\)\s*\n\s*\{', 'var score          : Dynamic= 0;' + "`n        var frame          : Dynamic= 0;" + "`n        var booConflict          : Dynamic= false;" + "`n        var note          : Dynamic= null;" + "`n        var rawAccuracy          : Dynamic= 0;" + "`n        var judgeAccuracy          : Dynamic= 0;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))`n        {`n            note = noteCandidate;")
        $Text = [regex]::Replace($Text, 'var score\s+: Dynamic=\s*0;\s*\n\s*for \(note/\* AS3HX WARNING could not determine type for var: note exp: EField\(EIdent\(uiNoteField\),notes\) type: null \*/ in as3hx\.Compat\.iter\(uiNoteField\.notes\)\)\s*\n\s*\{', 'var score          : Dynamic= 0;' + "`n        var note          : Dynamic= null;" + "`n        var diff          : Dynamic= 0;" + "`n        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))`n        {`n            note = noteCandidate;")
        $Text = [regex]::Replace($Text, 'var rawAccuracy\s+: Dynamic=\s*note\.POSITION - position;', 'rawAccuracy = note.POSITION - position;')
        $Text = [regex]::Replace($Text, 'var judgeAccuracy\s+: Dynamic=\s*positionJudged - note\.POSITION;', 'judgeAccuracy = positionJudged - note.POSITION;')
        $Text = [regex]::Replace($Text, 'var diff\s+: Dynamic=\s*as3hx\.Compat\.parseInt\(frame \+ JUDGE_OFFSET_FRAMES - note\.FRAME\);', 'diff = as3hx.Compat.parseInt(frame + JUDGE_OFFSET_FRAMES - note.FRAME);')
        $Text = [regex]::Replace($Text, 'note = \(\(noteIndex < uiNoteField\.notes\.length - 1\) \? uiNoteField\.notes\[noteIndex\+\+\] : uiNoteField\.spawnNextNote\(\)\);', 'note = ((as3hx.Compat.parseInt(noteIndex) < as3hx.Compat.parseInt(uiNoteField.notes.length - 1)) ? uiNoteField.notes[as3hx.Compat.parseInt(noteIndex++)] : uiNoteField.spawnNextNote());')
        $Text = $Text.Replace('_gvars.playerUser.gameLayout["mp"]', 'Reflect.field(_gvars.playerUser.gameLayout, "mp")')
    }
    elseif ($fileName -eq "WebSocketClientHandler.hx") {
        $Text = [regex]::Replace($Text, 'var input\s+: Dynamic;', 'var input                      : Dynamic= null;')
        $Text = $Text.Replace('socketBytes.length > MAX_SOCKET_BYTE_SIZE', 'socketBytes.length > SocketClientHandler.MAX_SOCKET_BYTE_SIZE')
        $Text = $Text.Replace('0x100000000000000', 'Math.pow(2, 56)')
        $Text = $Text.Replace('0x1000000000000', 'Math.pow(2, 48)')
        $Text = $Text.Replace('0x10000000000', 'Math.pow(2, 40)')
        $Text = $Text.Replace('0x100000000', 'Math.pow(2, 32)')
    }
    elseif ($fileName -eq "MPBrowserScrollpane.hx" -or $fileName -eq "MPUserlistScrollpane.hx" -or $fileName -eq "ReplayHistoryScrollpane.hx") {
        $Text = $Text.Replace('return Math.max(Math.min(height / _calcHeight, 1), 0) || 0;', 'return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(height / _calcHeight, 1), 0), 0));')
    }
    elseif ($fileName -eq "MPViewChatLogRoom.hx" -or $fileName -eq "MPViewChatLogUser.hx") {
        $Text = $Text.Replace('_cachePositions[_cachePositions.length - 1]', '_cachePositions[as3hx.Compat.parseInt(_cachePositions.length - 1)]')
        if ($fileName -eq "MPViewChatLogUser.hx") {
            $Text = $Text.Replace('for (i in (found) ? i + 1 : 0...history.messages.length)' + "`n        {`n            addItem(history.messages[i]);`n        }", 'i = (found) ? i + 1 : 0;' + "`n        while (as3hx.Compat.truthy(i < history.messages.length))`n        {`n            addItem(history.messages[as3hx.Compat.parseInt(i)]);`n            i++;`n        }")
        }
    }
    elseif ($fileName -eq "MPViewUserListRoom.hx") {
        $Text = [regex]::Replace($Text, 'try cast\(vec, Array/\*Vector\.<T> call\?\*/\) catch', 'try cast(vec, Array<Dynamic>) catch')
    }
    elseif ($fileName -eq "ScoreHandler.hx") {
        $Text = [regex]::Replace($Text, '\(\(gameResult\.legacyLastRank = _avars\.legacyLevelRanksGet\(gameResult\.songInfo\)\) \|\| \{\s*score : 0\s*\}\)\.score < gameResult\.score', 'as3hx.Compat.parseFloat(as3hx.Compat.field(as3hx.Compat.orValue(gameResult.legacyLastRank = _avars.legacyLevelRanksGet(gameResult.songInfo), { score : 0 }), "score")) < as3hx.Compat.parseFloat(gameResult.score)')
        $Text = $Text.Replace('Reflect.field(newLevelRanks, "plays") += Reflect.field(previousLevelRanks, "plays");', 'Reflect.setField(newLevelRanks, "plays", as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "plays")) + as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "plays")));')
        $Text = $Text.Replace('Reflect.field(newLevelRanks, "aaas") += Reflect.field(previousLevelRanks, "aaas");', 'Reflect.setField(newLevelRanks, "aaas", as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "aaas")) + as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "aaas")));')
        $Text = $Text.Replace('Reflect.field(newLevelRanks, "fcs") += Reflect.field(previousLevelRanks, "fcs");', 'Reflect.setField(newLevelRanks, "fcs", as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "fcs")) + as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "fcs")));')
        $Text = $Text.Replace('Reflect.field(previousLevelRanks, "plays") += Reflect.field(newLevelRanks, "plays");', 'Reflect.setField(previousLevelRanks, "plays", as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "plays")) + as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "plays")));')
        $Text = $Text.Replace('Reflect.field(previousLevelRanks, "aaas") += Reflect.field(newLevelRanks, "aaas");', 'Reflect.setField(previousLevelRanks, "aaas", as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "aaas")) + as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "aaas")));')
        $Text = $Text.Replace('Reflect.field(previousLevelRanks, "fcs") += Reflect.field(newLevelRanks, "fcs");', 'Reflect.setField(previousLevelRanks, "fcs", as3hx.Compat.parseInt(Reflect.field(previousLevelRanks, "fcs")) + as3hx.Compat.parseInt(Reflect.field(newLevelRanks, "fcs")));')
    }
    elseif ($fileName -eq "Logger.hx") {
        $Text = [regex]::Replace($Text, '\n\s*var e_logFileFail\s+: Dynamic= null;', '')
        $Text = [regex]::Replace($Text, 'public static function initLogFile\(\) : Void\s*\{', 'public static function initLogFile() : Void' + "`n    {`n        var e_logFileFail            : Dynamic= null;", 1)
        $Text = [regex]::Replace($Text, 'var e_logFileFail\s+: Dynamic=\s*function\(e\s+: Dynamic\) : Void', 'e_logFileFail = function(e            : Dynamic) : Void')
    }
    elseif ($fileName -eq "Updater.hx") {
        $Text = [regex]::Replace($Text, '\n\s*var e_onComplete\s+: Dynamic= null;', '')
        $Text = [regex]::Replace($Text, '\n\s*var e_onError\s+: Dynamic= null;', '')
        $Text = [regex]::Replace($Text, '\n\s*var e_writeError\s+: Dynamic= null;', '')
        $Text = [regex]::Replace($Text, '\n\s*var e_removeEvents\s+: Dynamic= null;', '')
        $Text = [regex]::Replace($Text, 'var swfDownload\s+: Dynamic=\s*new URLLoader\(\);', 'var e_onComplete            : Dynamic= null;' + "`n        var e_onError            : Dynamic= null;" + "`n        var e_writeError            : Dynamic= null;" + "`n        var e_removeEvents            : Dynamic= null;" + "`n        var swfDownload            : Dynamic= new URLLoader();")
        $Text = [regex]::Replace($Text, 'var e_onComplete\s+: Dynamic=\s*function\(e\s+: Dynamic\) : Void', 'e_onComplete = function(e            : Dynamic) : Void')
        $Text = [regex]::Replace($Text, 'var e_onError\s+: Dynamic=\s*function\(e\s+: Dynamic\) : Void', 'e_onError = function(e            : Dynamic) : Void')
        $Text = [regex]::Replace($Text, 'var e_writeError\s+: Dynamic=\s*function\(e\s+: Dynamic\) : Void', 'e_writeError = function(e            : Dynamic) : Void')
        $Text = [regex]::Replace($Text, 'var e_removeEvents\s+: Dynamic=\s*function\(\) : Void', 'e_removeEvents = function() : Void')
    }

    return $Text
}

function Remove-PortedCompatibilitySource {
    param([string]$RelativePath)

    $target = Join-Path $OutputPath $RelativePath
    if (-not (Test-Path -LiteralPath $target)) {
        return
    }

    $resolvedOutput = (Resolve-Path -LiteralPath $OutputPath).Path.TrimEnd("\", "/")
    $resolvedTarget = (Resolve-Path -LiteralPath $target).Path
    if (-not $resolvedTarget.StartsWith($resolvedOutput + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove '$resolvedTarget' because it is outside '$resolvedOutput'."
    }

    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}

function Remove-NativeShimGeneratedSources {
    Remove-PortedCompatibilitySource "com\greensock"
    Remove-PortedCompatibilitySource "game\graph"
    Remove-PortedCompatibilitySource "com\flashfla\utils\ArrayUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\Crypt.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\DateUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\ExtraMath.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\GameNotePool.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\NumberUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\Sprintf.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\StringUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\TimeUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\utils\VectorUtil.hx"
    Remove-PortedCompatibilitySource "com\flashfla\parser\YAML.hx"
    Remove-PortedCompatibilitySource "com\flashfla\net\MultipartURLLoader.hx"
    Remove-PortedCompatibilitySource "com\flashfla\net\WebRequest.hx"
}

if (-not $PostprocessOnly) {
    Get-ChildItem -LiteralPath $SourcePath -Recurse -Filter *.as | ForEach-Object {
        Prepare-ActionScriptFile -InputPath $_.FullName -OutputPath $PreparedRoot
    }

    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

    Write-Host "Prepared AS3 source: $PreparedRoot"
    Write-Host "Generating Haxe source: $OutputPath"
    & $HaxelibExe run as3hx -func2dyn $PreparedRoot $OutputPath
}
else {
    Write-Host "Postprocessing existing Haxe source: $OutputPath"
}

Remove-NativeShimGeneratedSources

Get-ChildItem -LiteralPath $OutputPath -Recurse -Filter *.hx | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName)
    $text = Convert-OpenFLImports $text
    $text = Convert-LocalHelperClasses -Text $text -FilePath $_.FullName
    $text = Convert-AS3TypeStrictness $text
    $text = Convert-FinalGeneratedFixes -Text $text -FilePath $_.FullName
    Set-Content -LiteralPath $_.FullName -Value $text -NoNewline
}

Remove-NativeShimGeneratedSources

$sourceCount = (Get-ChildItem -LiteralPath $SourcePath -Recurse -Filter *.as | Measure-Object).Count
$portedCount = (Get-ChildItem -LiteralPath $OutputPath -Recurse -Filter *.hx | Measure-Object).Count

Write-Host "AS3 source files: $sourceCount"
Write-Host "Generated Haxe files: $portedCount"
Write-Host "Output: $OutputPath"
