package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.parser.YAML;
import openfl.utils.ByteArray;

/**
 * Quaver actually just uses a standard YAML serializion format.
 * Flash doesn't have one of those, and the only one I found made the game just crash.
 * I wrote my own that should be good enough for Quaver Files unless it does some really crazy things.
 * - Velocity
 */
class ChartQuaver extends ChartBase
{
    public var COLORS : Dynamic = {
            "4" : ["white", "blue", "blue", "white"],
            "7" : ["white", "blue", "white", "red", "white", "blue", "white"]
        };
    
    public var collections : Dynamic;
    
    override public function load(fileData : ByteArray, fileName : String = null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff : String = fileData.readUTFBytes(fileData.length).replace(new as3hx.Compat.Regex('\\r\\n|\\r', "gm"), "\n");
            
            // Decode YAML
            collections = YAML.decode(buff);
            
            // Build data
            var audioExt : String = Reflect.field(collections, "AudioFile").substr(-3).toLowerCase();
            if (!ignoreValidation && (audioExt != "mp3"))
            {
                trace("QUA: Invalid: [", audioExt, "]");
                return false;
            }
            
            Reflect.setField(data, "music", Reflect.field(collections, "AudioFile"));
            Reflect.setField(data, "title", Reflect.field(collections, "Title") || fileName);
            Reflect.setField(data, "artist", Reflect.field(collections, "Artist"));
            Reflect.setField(data, "stepauthor", Reflect.field(collections, "Creator"));
            
            if (Reflect.field(collections, "BackgroundFile") != null)
            {
                Reflect.setField(data, "banner", Reflect.field(collections, "BackgroundFile"));
                Reflect.setField(data, "background", Reflect.field(collections, "BackgroundFile"));
            }
            
            // Build NoteMap Object
            var columnCount : Int = standardType(Reflect.field(collections, "Mode"));
            var noteCollection : Array<Dynamic> = Reflect.field(collections, "HitObjects");
            var noteArray : Array<Dynamic> = [];
            var collectionEntry : Dynamic;
            for (note in 0...noteCollection.length)
            {
                collectionEntry = noteCollection[note];
                
                var noteTime : Float = as3hx.Compat.parseFloat(Reflect.field(collectionEntry, "StartTime"));
                var noteColumn : Int = as3hx.Compat.parseInt(Reflect.field(collectionEntry, "Lane")) - 1;
                
                if (Math.isNaN(noteTime))
                {
                    noteTime = 0;
                }
                
                var noteHeldTime : Float = 0;
                
                // Held Note
                if (Reflect.field(collectionEntry, "EndTime") != null)
                {
                    noteHeldTime = ((as3hx.Compat.parseFloat(Reflect.field(collectionEntry, "EndTime"))) - noteTime) / 1000;
                }
                
                noteArray[noteArray.length] = [noteTime / 1000, Reflect.field(Reflect.field(COLUMNS, Std.string(columnCount)), Std.string(noteColumn)), Reflect.field(Reflect.field(COLORS, Std.string(columnCount)), Std.string(noteColumn)), noteHeldTime];
            }
            
            // Invalid Column Count
            if (Lambda.indexOf(validColumnCounts, columnCount) == -1)
            {
                trace("QUA: Invalid: [ Keys", columnCount, "]");
                return false;
            }
            
            // No Notes in the file.
            if (noteArray.length <= 0)
            {
                trace("QUA: Invalid: [ No Notes ]");
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
            
            // Calculate some Difficulty, just so we can "sort" charts.
            Reflect.setField(data, "nps", (noteArray.length / maxChartTime));
            Reflect.setField(data, "difficulty", Math.round(Reflect.field(data, "nps")));
            
            // Fill Chart Data
            var noteArrayObject : Dynamic = {
                "class" : Reflect.field(collections, "DifficultyName"),
                class_color : getDifficultyClass(Reflect.field(data, "difficulty")),
                desc : Reflect.field(collections, "Description"),
                difficulty : Reflect.field(data, "difficulty"),
                arrows : noteArray.length,
                holds : maxHoldCount,
                mines : 0,
                radar_values : "0,0,0,0,0",
                type : columnCount,
                time_sec : maxChartTime,
                nps : Reflect.field(data, "nps"),
                stepauthor : Reflect.field(collections, "Creator")
            };
            /*
               if (collections["SliderVelocities"] != null)
               {
               noteArrayObject["slider_velocities"] = sliderVelocityList(collections["SliderVelocities"]);
               }
             */
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
            trace("QUA: Error Catch: " + e);
            return false;
        }
        
        this.loaded = true;
        this.parsed = true;
        return true;
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * Converts a given chart type into it's respective column count.
     * @param type
     * @return
     */
    private function standardType(type : String) : Int
    {
        switch (type)
        {
            case "Keys4":
                return 4;
            
            case "Keys7":
                return 7;
        }
        
        return 0;
    }
    
    private function getDifficultyClass(val : Float) : String
    {
        if (val >= 14)
        {
            return "Edit";
        }
        if (val >= 11)
        {
            return "Challenge";
        }
        if (val >= 9)
        {
            return "Hard";
        }
        if (val >= 6.5)
        {
            return "Medium";
        }
        if (val >= 3.5)
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

