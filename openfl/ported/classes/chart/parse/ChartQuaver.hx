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
    public var COLORS                             : Dynamic= {
            "4" : ["white", "blue", "blue", "white"],
            "7" : ["white", "blue", "white", "red", "white", "blue", "white"]
        };
    
    public var collections                             : Dynamic;
    
    override public function load(fileData                             : Dynamic, fileName                             : Dynamic= null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff                             : Dynamic= new as3hx.Compat.Regex('\\r\\n|\\r', "gm").replace(fileData.readUTFBytes(fileData.length), "\n");
            
            // Decode YAML
            collections = YAML.decode(buff);
            
            // Build data
            var audioExt                             : Dynamic= Reflect.field(collections, "AudioFile").substr(-3).toLowerCase();
            if (as3hx.Compat.truthy(!ignoreValidation && (audioExt != "mp3")))
            {
                trace("QUA: Invalid: [", audioExt, "]");
                return false;
            }
            
            Reflect.setField(data, "music", Reflect.field(collections, "AudioFile"));
            Reflect.setField(data, "title", as3hx.Compat.orValue(Reflect.field(collections, "Title"), fileName));
            Reflect.setField(data, "artist", Reflect.field(collections, "Artist"));
            Reflect.setField(data, "stepauthor", Reflect.field(collections, "Creator"));
            
            if (as3hx.Compat.truthy(Reflect.field(collections, "BackgroundFile") != null))
            {
                Reflect.setField(data, "banner", Reflect.field(collections, "BackgroundFile"));
                Reflect.setField(data, "background", Reflect.field(collections, "BackgroundFile"));
            }
            
            // Build NoteMap Object
            var columnCount                             : Dynamic= standardType(Reflect.field(collections, "Mode"));
            var noteCollection                             : Dynamic= Reflect.field(collections, "HitObjects");
            var noteArray                             : Dynamic= [];
            var collectionEntry                             : Dynamic= null;
            for (note in 0...noteCollection.length)
            {
                collectionEntry = noteCollection[note];
                
                var noteTime                             : Dynamic= as3hx.Compat.parseFloat(Reflect.field(collectionEntry, "StartTime"));
                var noteColumn                             : Dynamic= as3hx.Compat.parseInt(Reflect.field(collectionEntry, "Lane")) - 1;
                
                if (as3hx.Compat.truthy(Math.isNaN(noteTime)))
                {
                    noteTime = 0;
                }
                
                var noteHeldTime                             : Dynamic= 0;
                
                // Held Note
                if (as3hx.Compat.truthy(Reflect.field(collectionEntry, "EndTime") != null))
                {
                    noteHeldTime = ((as3hx.Compat.parseFloat(Reflect.field(collectionEntry, "EndTime"))) - noteTime) / 1000;
                }
                
                noteArray[noteArray.length] = [noteTime / 1000, Reflect.field(as3hx.Compat.field(COLUMNS, columnCount), Std.string(noteColumn)), Reflect.field(as3hx.Compat.field(COLORS, columnCount), Std.string(noteColumn)), noteHeldTime];
            }
            
            // Invalid Column Count
            if (as3hx.Compat.truthy(Lambda.indexOf(validColumnCounts, columnCount) == -1))
            {
                trace("QUA: Invalid: [ Keys", columnCount, "]");
                return false;
            }
            
            // No Notes in the file.
            if (as3hx.Compat.truthy(noteArray.length <= 0))
            {
                trace("QUA: Invalid: [ No Notes ]");
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
            
            // Calculate some Difficulty, just so we can "sort" charts.
            Reflect.setField(data, "nps", (noteArray.length / maxChartTime));
            Reflect.setField(data, "difficulty", Math.round(Reflect.field(data, "nps")));
            
            // Fill Chart Data
            var noteArrayObject                             : Dynamic= {
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
               if (as3hx.Compat.truthy(collections["SliderVelocities"] != null))
               {
               noteArrayObject["slider_velocities"] = sliderVelocityList(collections["SliderVelocities"]);
               }
             */
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
    private function standardType(type                             : Dynamic) : Int
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
    
    private function getDifficultyClass(val                             : Dynamic) : String
    {
        if (as3hx.Compat.truthy(val >= 14))
        {
            return "Edit";
        }
        if (as3hx.Compat.truthy(val >= 11))
        {
            return "Challenge";
        }
        if (as3hx.Compat.truthy(val >= 9))
        {
            return "Hard";
        }
        if (as3hx.Compat.truthy(val >= 6.5))
        {
            return "Medium";
        }
        if (as3hx.Compat.truthy(val >= 3.5))
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

