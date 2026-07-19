package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartOSU extends ChartBase
{
    public var COLORS : Dynamic = {
            "4" : ["white", "pink", "pink", "white"],
            "5" : ["white", "pink", "purple", "pink", "white"],
            "6" : ["white", "pink", "white", "white", "pink", "white"],
            "7" : ["white", "pink", "white", "purple", "white", "pink", "white"],
            "8" : ["white", "pink", "pink", "white", "white", "pink", "pink", "white"],
            "9" : ["white", "pink", "pink", "white", "purple", "white", "pink", "pink", "white"]
        };
    
    private static var COLLECT_ARRAY_TYPES : Array<Dynamic> = ["Events", "TimingPoints", "HitObjects"];
    private static var COLLECT_KEY_TYPES : Array<Dynamic> = ["General", "Editor", "Metadata", "Difficulty"];
    
    private var collections : Dynamic;
    
    override public function load(fileData : ByteArray, fileName : String = null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff : String = fileData.readUTFBytes(fileData.length).replace(new as3hx.Compat.Regex('\\r\\n|\\r', "gm"), "\n");
            
            var bufflines : Array<Dynamic> = buff.split("\n");
            
            collections = { };
            
            // Read File Basic
            var line : String;
            var collection_key : String;
            var collection_current : Dynamic;
            var collection_array : Array<Dynamic>;
            
            var isKeyPair : Bool = false;
            
            for (l in 0...bufflines.length)
            {
                line = bufflines[l];
                
                // Comment Lines
                if (line.substr(0, 2) == "//")
                {
                    continue;
                }
                
                // New Group
                if (line.charAt(0) == "[")
                {
                    collection_key = line.substr(1, line.length - 2);
                    if (Lambda.indexOf(COLLECT_KEY_TYPES, collection_key) != -1)
                    {
                        isKeyPair = true;
                        collection_current = { };
                        Reflect.setField(collections, collection_key, collection_current);
                    }
                    else if (Lambda.indexOf(COLLECT_ARRAY_TYPES, collection_key) != -1)
                    {
                        isKeyPair = false;
                        collection_array = [];
                        Reflect.setField(collections, collection_key, collection_array);
                    }
                    else
                    {
                        collection_key = null;
                    }
                    continue;
                }
                
                if (collection_key == null || line.length <= 0)
                {
                    continue;
                }
                
                // Get Values
                if (isKeyPair)
                {
                    var sep : Float = line.indexOf(":");
                    if (sep != -1)
                    {
                        var key : String = line.substr(0, sep);
                        var value : String = StringTools.trim(line.substr(sep + 1));
                        Reflect.setField(collection_current, key, value);
                    }
                }
                else
                {
                    collection_array[collection_array.length] = line.split(",");
                }
            }
            
            // Check for osu!mania
            var gameMode : Int = as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "General"), "Mode"));
            var columnCount : Int = as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "Difficulty"), "CircleSize"));
            var audioExt : String = Reflect.field(Reflect.field(collections, "General"), "AudioFilename").substr(-3).toLowerCase();
            if (!ignoreValidation && (gameMode != 3 || Lambda.indexOf(validColumnCounts, columnCount) == -1 || audioExt != "mp3"))
            {
                trace("OSU: Invalid: [", gameMode, columnCount, audioExt, "]");
                return false;
            }
            
            Reflect.setField(data, "music", Reflect.field(Reflect.field(collections, "General"), "AudioFilename"));
            Reflect.setField(data, "title", Reflect.field(Reflect.field(collections, "Metadata"), "Title") || fileName);
            Reflect.setField(data, "artist", Reflect.field(Reflect.field(collections, "Metadata"), "Artist"));
            Reflect.setField(data, "stepauthor", Reflect.field(Reflect.field(collections, "Metadata"), "Creator"));
            Reflect.setField(data, "difficulty", as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "Difficulty"), "OverallDifficulty")) * 16);
            
            if (Reflect.field(collections, "Events").length > 0)
            {
                for (event/* AS3HX WARNING could not determine type for var: event exp: EArray(EIdent(collections),EConst(CString(Events))) type: Dynamic */ in Reflect.field(collections, "Events"))
                {
                    if (event[0] == "0")
                    {
                        var filename : String = event[2];
                        
                        if (filename.charAt(0) == "\"")
                        {
                            filename = filename.substr(1, filename.length - 2);
                        }
                        
                        Reflect.setField(data, "banner", filename);
                        Reflect.setField(data, "background", filename);
                        break;
                    }
                }
            }
            
            // Build NoteMap Object
            var columnWidth : Float = 512 / columnCount;
            var noteCollection : Array<Dynamic> = Reflect.field(collections, "HitObjects");
            var noteArray : Array<Dynamic> = [];
            var collectionEntry : Array<Dynamic>;
            for (l in 0...noteCollection.length)
            {
                collectionEntry = noteCollection[l];
                
                var noteTime : Float = as3hx.Compat.parseFloat(collectionEntry[2]) / 1000;
                var noteType : Int = as3hx.Compat.parseInt(collectionEntry[3]);
                var column : Int = (Math.max(0, Math.min(columnCount, Math.floor(as3hx.Compat.parseInt(collectionEntry[0]) / columnWidth))));
                
                var noteHeldTime : Float = 0;
                
                // Held Note
                if ((noteType & 128) != 0)
                {
                    var noteExtra : Array<Dynamic> = (Std.string(collectionEntry[5])).split(":");
                    noteHeldTime = (as3hx.Compat.parseFloat(noteExtra[0]) / 1000) - noteTime;
                }
                
                noteArray[noteArray.length] = [noteTime, Reflect.field(Reflect.field(COLUMNS, Std.string(columnCount)), Std.string(column)), Reflect.field(Reflect.field(COLORS, Std.string(columnCount)), Std.string(column)), noteHeldTime];
            }
            
            // No Notes in the file.
            if (noteArray.length <= 0)
            {
                trace("OSU: Invalid: [No Notes]");
                return false;
            }
            
            // Determine File Time
            var maxChartTime : Float = 1;
            var i : Int = as3hx.Compat.parseInt(noteArray.length - 1);
            while (i >= 0)
            {
                maxChartTime = Math.max(maxChartTime, noteArray[i][0] + noteArray[i][3]);
                if (Math.isNaN(maxChartTime))
                {
                    maxChartTime = 1;
                    break;
                }
                i--;
            }
            
            // Determine Hold Count
            var maxHoldCount : Int = 0;
            var h : Int = as3hx.Compat.parseInt(noteArray.length - 1);
            while (h >= 0)
            {
                if (noteArray[h][3] > 0)
                {
                    maxHoldCount++;
                }
                h--;
            }
            
            Reflect.setField(data, "nps", (noteArray.length / maxChartTime));
            
            var noteArrayObject : Dynamic = {
                "class" : Reflect.field(Reflect.field(collections, "Metadata"), "Version"),
                class_color : getDifficultyClass(as3hx.Compat.parseFloat(Reflect.field(Reflect.field(collections, "Difficulty"), "OverallDifficulty"))),
                desc : "",
                difficulty : Reflect.field(Reflect.field(collections, "Difficulty"), "OverallDifficulty"),
                arrows : noteArray.length,
                holds : maxHoldCount,
                mines : 0,
                radar_values : "0,0,0,0,0",
                type : columnCount,
                time_sec : maxChartTime,
                nps : Reflect.field(data, "nps"),
                stepauthor : Reflect.field(Reflect.field(collections, "Metadata"), "Creator")
            };
            
            var chartArrayObject : Dynamic = {
                columns : columnCount,
                data : noteArrayObject,
                notes : noteArray,
                mines : []
            };
            
            Reflect.field(data, "notes").push(noteArrayObject);
            charts.push(chartArrayObject);
        }
        catch (e : Error)
        {
            trace("OSU: Error Catch: " + e);
            return false;
        }
        
        this.loaded = true;
        this.parsed = true;
        return true;
    }
    
    private function getDifficultyClass(val : Float) : String
    {
        if (val >= 9)
        {
            return "Edit";
        }
        if (val >= 7)
        {
            return "Challenge";
        }
        if (val >= 5)
        {
            return "Hard";
        }
        if (val >= 4)
        {
            return "Medium";
        }
        if (val >= 3)
        {
            return "Easy";
        }
        
        return "Beginner";
    }

    public function new()
    {
        super();
    }
}

