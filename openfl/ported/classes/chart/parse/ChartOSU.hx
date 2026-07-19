package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartOSU extends ChartBase
{
    public var COLORS                             : Dynamic= {
            "4" : ["white", "pink", "pink", "white"],
            "5" : ["white", "pink", "purple", "pink", "white"],
            "6" : ["white", "pink", "white", "white", "pink", "white"],
            "7" : ["white", "pink", "white", "purple", "white", "pink", "white"],
            "8" : ["white", "pink", "pink", "white", "white", "pink", "pink", "white"],
            "9" : ["white", "pink", "pink", "white", "purple", "white", "pink", "pink", "white"]
        };
    
    private static var COLLECT_ARRAY_TYPES                             : Dynamic= ["Events", "TimingPoints", "HitObjects"];
    private static var COLLECT_KEY_TYPES                             : Dynamic= ["General", "Editor", "Metadata", "Difficulty"];
    
    private var collections                             : Dynamic;
    
    override public function load(fileData                             : Dynamic, fileName                             : Dynamic= null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff                             : Dynamic= new as3hx.Compat.Regex('\\r\\n|\\r', "gm").replace(fileData.readUTFBytes(fileData.length), "\n");
            
            var bufflines                             : Dynamic= buff.split("\n");
            
            collections = { };
            
            // Read File Basic
            var line                             : Dynamic= null;
            var collection_key                             : Dynamic= null;
            var collection_current                             : Dynamic= null;
            var collection_array                             : Dynamic= null;
            
            var isKeyPair                             : Dynamic= false;
            
            for (l in 0...bufflines.length)
            {
                line = bufflines[l];
                
                // Comment Lines
                if (as3hx.Compat.truthy(line.substr(0, 2) == "//"))
                {
                    continue;
                }
                
                // New Group
                if (as3hx.Compat.truthy(line.charAt(0) == "["))
                {
                    collection_key = line.substr(1, line.length - 2);
                    if (as3hx.Compat.truthy(Lambda.indexOf(COLLECT_KEY_TYPES, collection_key) != -1))
                    {
                        isKeyPair = true;
                        collection_current = { };
                        Reflect.setField(collections, collection_key, collection_current);
                    }
                    else if (as3hx.Compat.truthy(Lambda.indexOf(COLLECT_ARRAY_TYPES, collection_key) != -1))
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
                
                if (as3hx.Compat.truthy(collection_key == null || line.length <= 0))
                {
                    continue;
                }
                
                // Get Values
                if (as3hx.Compat.truthy(isKeyPair))
                {
                    var sep                             : Dynamic= line.indexOf(":");
                    if (as3hx.Compat.truthy(sep != -1))
                    {
                        var key                             : Dynamic= line.substr(0, sep);
                        var value                             : Dynamic= StringTools.trim(line.substr(sep + 1));
                        Reflect.setField(collection_current, key, value);
                    }
                }
                else
                {
                    collection_array[collection_array.length] = line.split(",");
                }
            }
            
            // Check for osu!mania
            var gameMode                             : Dynamic= as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "General"), "Mode"));
            var columnCount                             : Dynamic= as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "Difficulty"), "CircleSize"));
            var audioExt                             : Dynamic= Reflect.field(Reflect.field(collections, "General"), "AudioFilename").substr(-3).toLowerCase();
            if (as3hx.Compat.truthy(!ignoreValidation && (gameMode != 3 || Lambda.indexOf(validColumnCounts, columnCount) == -1 || audioExt != "mp3")))
            {
                trace("OSU: Invalid: [", gameMode, columnCount, audioExt, "]");
                return false;
            }
            
            Reflect.setField(data, "music", Reflect.field(Reflect.field(collections, "General"), "AudioFilename"));
            Reflect.setField(data, "title", as3hx.Compat.orValue(Reflect.field(Reflect.field(collections, "Metadata"), "Title"), fileName));
            Reflect.setField(data, "artist", Reflect.field(Reflect.field(collections, "Metadata"), "Artist"));
            Reflect.setField(data, "stepauthor", Reflect.field(Reflect.field(collections, "Metadata"), "Creator"));
            Reflect.setField(data, "difficulty", as3hx.Compat.parseInt(Reflect.field(Reflect.field(collections, "Difficulty"), "OverallDifficulty")) * 16);
            
            if (as3hx.Compat.truthy(Reflect.field(collections, "Events").length > 0))
            {
                for (event/* AS3HX WARNING could not determine type for var: event exp: EArray(EIdent(collections),EConst(CString(Events))) type: Dynamic */ in as3hx.Compat.iter(Reflect.field(collections, "Events")))
                {
                    if (as3hx.Compat.truthy(event[0] == "0"))
                    {
                        var filename                             : Dynamic= event[2];
                        
                        if (as3hx.Compat.truthy(filename.charAt(0) == "\""))
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
            var columnWidth                             : Dynamic= 512 / columnCount;
            var noteCollection                             : Dynamic= Reflect.field(collections, "HitObjects");
            var noteArray                             : Dynamic= [];
            var collectionEntry                             : Dynamic= null;
            for (l in 0...noteCollection.length)
            {
                collectionEntry = noteCollection[l];
                
                var noteTime                             : Dynamic= as3hx.Compat.parseFloat(collectionEntry[2]) / 1000;
                var noteType                             : Dynamic= as3hx.Compat.parseInt(collectionEntry[3]);
                var column                             : Dynamic= (Math.max(0, Math.min(columnCount, Math.floor(as3hx.Compat.parseInt(collectionEntry[0]) / columnWidth))));
                
                var noteHeldTime                             : Dynamic= 0;
                
                // Held Note
                if (as3hx.Compat.truthy((noteType & 128) != 0))
                {
                    var noteExtra                             : Dynamic= (Std.string(collectionEntry[5])).split(":");
                    noteHeldTime = (as3hx.Compat.parseFloat(noteExtra[0]) / 1000) - noteTime;
                }
                
                noteArray[noteArray.length] = [noteTime, Reflect.field(as3hx.Compat.field(COLUMNS, columnCount), Std.string(column)), Reflect.field(as3hx.Compat.field(COLORS, columnCount), Std.string(column)), noteHeldTime];
            }
            
            // No Notes in the file.
            if (as3hx.Compat.truthy(noteArray.length <= 0))
            {
                trace("OSU: Invalid: [No Notes]");
                return false;
            }
            
            // Determine File Time
            var maxChartTime                             : Dynamic= 1;
            var i                             : Dynamic= as3hx.Compat.parseInt(noteArray.length - 1);
            while (as3hx.Compat.truthy(i >= 0))
            {
                maxChartTime = Math.max(maxChartTime, noteArray[i][0] + noteArray[i][3]);
                if (as3hx.Compat.truthy(Math.isNaN(maxChartTime)))
                {
                    maxChartTime = 1;
                    break;
                }
                i--;
            }
            
            // Determine Hold Count
            var maxHoldCount                             : Dynamic= 0;
            var h                             : Dynamic= as3hx.Compat.parseInt(noteArray.length - 1);
            while (as3hx.Compat.truthy(h >= 0))
            {
                if (as3hx.Compat.truthy(noteArray[h][3] > 0))
                {
                    maxHoldCount++;
                }
                h--;
            }
            
            Reflect.setField(data, "nps", (noteArray.length / maxChartTime));
            
            var noteArrayObject                             : Dynamic= {
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
            
            var chartArrayObject                             : Dynamic= {
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
    
    private function getDifficultyClass(val                             : Dynamic) : String
    {
        if (as3hx.Compat.truthy(val >= 9))
        {
            return "Edit";
        }
        if (as3hx.Compat.truthy(val >= 7))
        {
            return "Challenge";
        }
        if (as3hx.Compat.truthy(val >= 5))
        {
            return "Hard";
        }
        if (as3hx.Compat.truthy(val >= 4))
        {
            return "Medium";
        }
        if (as3hx.Compat.truthy(val >= 3))
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

