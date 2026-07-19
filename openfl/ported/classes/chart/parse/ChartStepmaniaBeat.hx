package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartStepmaniaBeat extends ChartBase
{
    public var chart_bpms(get, never)                             : Dynamic;
    public var chart_stops(get, never)                             : Dynamic;
    public var hasWarp(get, never)                             : Dynamic;

    private static inline var NOTE_TYPE_4TH                             : Dynamic= 0;
    private static inline var NOTE_TYPE_8TH                             : Dynamic= 1;
    private static inline var NOTE_TYPE_12TH                             : Dynamic= 2;
    private static inline var NOTE_TYPE_16TH                             : Dynamic= 3;
    private static inline var NOTE_TYPE_24TH                             : Dynamic= 4;
    private static inline var NOTE_TYPE_32ND                             : Dynamic= 5;
    private static inline var NOTE_TYPE_48TH                             : Dynamic= 6;
    private static inline var NOTE_TYPE_64TH                             : Dynamic= 7;
    private static inline var NOTE_TYPE_192ND                             : Dynamic= 8;
    private static inline var NOTE_TYPE_INVALID                             : Dynamic= 9;
    
    private static inline var ROWS_PER_MEASURE                             : Dynamic= 192;
    
    private var fields_array                             : Dynamic= ["title", 
        "subtitle", 
        "artist", 
        "titletranslit", 
        "subtitletranslit", 
        "artisttranslit", 
        "credit", 
        "banner", 
        "background", 
        "cdtitle", 
        "music", 
        "offset", 
        "samplestart", 
        "samplelength", 
        "bpms", 
        "stops", 
        "freezes", 
        "notes"
    ];
    
    private var fields_number                             : Dynamic= ["offset", 
        "samplestart", 
        "samplelength"
    ];
    
    private var bpms                             : Dynamic= [];
    private var stops                             : Dynamic= [];
    
    private var _hasWarp                             : Dynamic= false;
    
    override public function load(fileData                             : Dynamic, fileName                             : Dynamic= null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff                             : Dynamic= new as3hx.Compat.Regex('\\r\\n|\\r', "gm").replace(fileData.readUTFBytes(fileData.length), "\n");
            
            // Get All Matches
            var matches                             : Dynamic= [];
            var sI                             : Dynamic= -1;
            var sE                             : Dynamic= -1;
            while (as3hx.Compat.truthy(true))
            {
                sI = buff.indexOf("#", sE);
                sE = buff.indexOf(";", sI);
                
                if (as3hx.Compat.truthy(sI >= 0 && sE > sI))
                {
                    var matchString                             : Dynamic= buff.substring(sI, sE);
                    
                    var split                             : Dynamic= matchString.indexOf(":");
                    var key                             : Dynamic= matchString.substring(1, split).toLowerCase();
                    var value                             : Dynamic= matchString.substr(split + 1);
                    
                    matches[matches.length] = [key, value];
                }
                else
                {
                    break;
                }
            }
            
            // Build Data Structure
            var notes                             : Dynamic= null;
            for (match in as3hx.Compat.iter(matches))
            {
                if (as3hx.Compat.truthy(Lambda.indexOf(fields_array, as3hx.Compat.field(match, 0)) <= -1))
                {
                    continue;
                }
                
                var _sw3_ = (as3hx.Compat.field(match, 0));                

                switch (_sw3_)
                {
                    case "bpms", "stops", "freezes":
                        Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), getListValues(as3hx.Compat.field(match, 1), true));
                        checkWarps(Reflect.field(data, Std.string(as3hx.Compat.field(match, 0))));
                    
                    case "notes":
                        notes = { };
                        
                        var notesValues                             : Dynamic= as3hx.Compat.field(match, 1).split(":");
                        for (i in 0...notesValues.length)
                        {
                            notesValues[i] = StringTools.trim(notesValues[i]);
                        }
                        
                        Reflect.setField(notes, "type", standardType(notesValues[0]));  // dance-single, dance-double, dance-couple, dance-solo  
                        Reflect.setField(notes, "desc", notesValues[1]);  // ???  
                        Reflect.setField(notes, "class", notesValues[2]);  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                        Reflect.setField(notes, "class_color", notesValues[2]);  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                        Reflect.setField(notes, "difficulty", notesValues[3]);  // [0-9]+  
                        Reflect.setField(notes, "radar_values", notesValues[4]);  // 0.000,0.000,0.000,0.000,0.000  
                        
                        // check type for valid
                        if (as3hx.Compat.truthy(!ignoreValidation && (Lambda.indexOf(validColumnCounts, Reflect.field(notes, "type")) == -1)))
                        {
                            trace("SM: Invalid: [", notesValues[0], Reflect.field(notes, "type"), "]");
                            continue;
                        }
                        
                        // filter out anything except notes and commas
                        var notesData                             : Dynamic= notesValues[5].split("\n");
                        for (i in 0...notesData.length)
                        {
                            var pos                             : Dynamic= Lambda.indexOf(notesData[i], "//");
                            
                            if (as3hx.Compat.truthy(pos != -1))
                            {
                                notesData[i] = notesData[i].substr(0, pos);
                            }
                            
                            notesData[i] = StringTools.trim(notesData[i]);
                        }
                        Reflect.setField(notes, "data", notesData.join(""));
                        
                        // count arrows, holds, mines
                        Reflect.setField(notes, "arrows", getCharacterCount(Reflect.field(notes, "data"), "1"));
                        Reflect.setField(notes, "holds", getCharacterCount(Reflect.field(notes, "data"), "2"));
                        Reflect.setField(notes, "mines", getCharacterCount(Reflect.field(notes, "data"), "M"));
                        
                        Reflect.field(data, "notes").push(notes);
                    default:
                        if (as3hx.Compat.truthy(Lambda.indexOf(fields_number, as3hx.Compat.field(match, 0)) != -1))
                        {
                            Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), as3hx.Compat.parseFloat(as3hx.Compat.field(match, 1)));
                        }
                        else
                        {
                            Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), as3hx.Compat.field(match, 1));
                        }
                }
            }
            
            // Setup BPMS
            this.bpms = as3hx.Compat.orValue(Reflect.field(this.data, "bpms"), []);
            this.bpms.sort(keyPairSort);
            if (as3hx.Compat.truthy(this.bpms.length <= 0))
            {
                this.bpms[0] = [0, 60];
            }  // No BPM, default to 60.  
            this.bpms[0][0] = 0;  // First BPM starts at beat 0.  
            
            // Setup Stops
            this.stops = as3hx.Compat.orValue(Reflect.field(this.data, "stops"), as3hx.Compat.orValue(Reflect.field(this.data, "freezes"), []));
            this.stops.sort(keyPairSort);
            
            // Finalize Charts
            for (chart in 0...Reflect.field(data, "notes").length)
            {
                notes = Reflect.field(data, "notes")[chart];
                Reflect.setField(notes, "time_sec", getChartTimeFast(chart));
                Reflect.setField(notes, "nps", ((Reflect.field(notes, "arrows") + Reflect.field(notes, "holds")) / (Reflect.field(notes, "time_sec"))));
            }
            
            Reflect.setField(data, "stepauthor", Reflect.field(data, "credit"));
            
            // Validation
            if (as3hx.Compat.truthy(Reflect.field(data, "music") == null))
            {
                Reflect.setField(data, "music", fileName.substr(0, fileName.lastIndexOf(".")) + ".mp3");
            }
            
            var audioExt                           : Dynamic= Std.string(as3hx.Compat.orValue(Reflect.field(data, "music"), "")).substr(-3).toLowerCase();
            if (as3hx.Compat.truthy(!ignoreValidation && (audioExt != "mp3")))
            {
                trace("SM: Invalid: [", audioExt, "]");
                return false;
            }
            
            // No valid charts found.
            if (as3hx.Compat.truthy(Reflect.field(data, "notes").length <= 0))
            {
                trace("SM: No Charts");
                return false;
            }
        }
        catch (e : Error)
        {
            trace("SM: Error Catch: " + e);
            return false;
        }
        
        this.loaded = true;
        
        return true;
    }
    
    /**
     * Fully parse the chart data if applicable.
     */
    override public function parse() : Void
    {
        if (as3hx.Compat.truthy(!loaded || this.parsed))
        {
            return;
        }
        
        // Fully Parse Charts
        for (chartData/* AS3HX WARNING could not determine type for var: chartData exp: EArray(EIdent(data),EConst(CString(notes))) type: ByteArray */ in as3hx.Compat.iter(Reflect.field(data, "notes")))
        {
            this.charts[this.charts.length] = parseNoteData(chartData);
        }
        
        this.parsed = true;
    }
    
    /**
     * Do a full parse of the provided chart data.
     * This also removes the raw chart data string from the passed object.
     * @param chartData
     * @return
     */
    private function parseNoteData(chartData                             : Dynamic) : Dynamic
    {
        var t                             : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
        
        var columnCount                             : Dynamic= Reflect.field(chartData, "type");
        var columnMap                           : Dynamic= as3hx.Compat.orValue(as3hx.Compat.field(COLUMNS, Reflect.field(chartData, "type")), []);
        
        var out                             : Dynamic= {
            data : chartData,
            columns : columnCount
        };
        
        var pre_holds                             : Dynamic= { };
        var notes                             : Dynamic= [];
        var mines                             : Dynamic= [];
        
        var currentRow                             : Dynamic= 0;
        var currentTime                             : Dynamic= 0;
        
        var measureArray                             : Dynamic= Reflect.field(chartData, "data").split(",");
        var measureCount                             : Dynamic= measureArray.length;
        
        for (currentMeasure in 0...measureCount)
        {
            currentRow = as3hx.Compat.parseInt(currentMeasure * ROWS_PER_MEASURE);
            
            var measure                             : Dynamic= measureArray[currentMeasure];
            var notebarOffset                             : Dynamic= 0;
            
            var barsPerMeasure                             : Dynamic= as3hx.Compat.parseInt(measure.length / columnCount);
            
            for (currentNoteBar in 0...barsPerMeasure)
            {
                var measureBeat                             : Dynamic= (currentMeasure * 4) + (((192 / barsPerMeasure) / 48) * currentNoteBar);
                
                for (column in 0...columnCount)
                {
                    var noteStr                             : Dynamic= measure.charAt(notebarOffset + column);
                    
                    if (as3hx.Compat.truthy(noteStr == "0"))
                    {
                        continue;
                    }
                    
                    if (as3hx.Compat.truthy(noteStr == "1" || noteStr == "2" || noteStr == "4"))
                    {
                        if (as3hx.Compat.truthy(noteStr == "2" || noteStr == "4"))
                        {
                            Reflect.setField(pre_holds, Std.string(column), notes.length);
                        }
                        
                        var noteColor                             : Dynamic= noteTypeToColor(getNoteType(currentNoteBar * (ROWS_PER_MEASURE / barsPerMeasure)));
                        
                        notes[notes.length] = [measureBeat, column, noteColor, 0];
                    }
                    else if (as3hx.Compat.truthy(noteStr == "3"))
                    {
                        if (as3hx.Compat.truthy(as3hx.Compat.field(pre_holds, column) != null))
                        {
                            var holdStart                             : Dynamic= as3hx.Compat.field(pre_holds, column);
                            var holdStartData                             : Dynamic= notes[holdStart];
                            notes[holdStart][3] = measureBeat;
                            Reflect.deleteField(pre_holds, Std.string(column));
                        }
                    }
                    else if (as3hx.Compat.truthy(noteStr == "M"))
                    {
                        mines[mines.length] = [measureBeat, column];
                    }
                }
                
                // Update String Offset
                notebarOffset += columnCount;
            }
        }
        
        // sort data array so time is in order
        as3hx.Compat.sortOn(notes, "0", as3hx.Compat.ARRAY_NUMERIC);
        as3hx.Compat.sortOn(mines, "0", as3hx.Compat.ARRAY_NUMERIC);
        Reflect.setField(out, "notes", notes);
        Reflect.setField(out, "mines", mines);
        
        Reflect.deleteField(chartData, "data"); // Clear Vectors for GC  ;
        
        
        
        measureArray = null;
        pre_holds = null;
        
        //trace("parsed in", (getTimer() - t), notes[notes.length - 1][0]);
        
        return out;
    }
    
    /**
     * Computes a charts expected length using measure count and BPM.
     * @param chart_index
     * @return
     */
    override public function getChartTimeFast(chart_index                             : Dynamic= null) : Float
    // Cached Time
    {
        
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "time_sec") != null))
        {
            return Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "time_sec");
        }
        
        // Calculate
        //var t                            : Dynamic= getTimer();
        
        var currentTime                             : Dynamic= 0;
        var currentBPM                             : Dynamic= null;
        
        var measureCount                             : Dynamic= as3hx.Compat.parseInt(getCharacterCount(Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "data"), ",") + 1);
        var maxRows                             : Dynamic= as3hx.Compat.parseInt(ROWS_PER_MEASURE * measureCount);
        
        var msBeatIncrement                             : Dynamic= null;
        var lastBPMIndex                             : Dynamic= 0;
        var currentRow                             : Dynamic= 0;
        
        var timeSeq                             : Dynamic= (4 / ROWS_PER_MEASURE);
        
        // BPMs need to be handled on every 192nd, skipping any row will result in
        // off-sync if a BPM change lands on a row not handled by the measure.
        while (as3hx.Compat.truthy(currentRow < maxRows))
        {
            lastBPMIndex = bpm_at_row_index(currentRow, lastBPMIndex);
            currentBPM = bpms[lastBPMIndex][1];
            
            // Increase Time
            msBeatIncrement = 1000 / (currentBPM / 60);
            currentTime += (timeSeq * msBeatIncrement);
            
            currentRow++;
        }
        
        // Stops
        if (as3hx.Compat.truthy(stops.length > 0))
        {
            var i                             : Dynamic= as3hx.Compat.parseInt(stops.length - 1);
            while (as3hx.Compat.truthy(i >= 0))
            {
                currentTime += stops[i][1] * 1000;
                i--;
            }
        }
        
        // Offset
        currentTime += (Reflect.field(data, "offset") * -1000);
        
        // MS -> Seconds
        currentTime /= 1000;
        
        //trace("time parsed in", (getTimer() - t), currentTime);
        
        return currentTime;
    }
    
    /**
     * Mark a file for have some element that would cause a beat warp.
     * @param array
     */
    private function checkWarps(array                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_hasWarp))
        {
            return;
        }
        
        var len                             : Dynamic= array.length;
        for (index in 0...len)
        {
            if (as3hx.Compat.truthy(array[index][1] < 0))
            {
                _hasWarp = true;
                break;
            }
        }
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
            case "dance-single":
                return 4;
            case "dance-double", "dance-couple", "dance-routine":
                return 8;
            case "dance-solo", "pump-halfdouble":
                return 6;
            
            case "pump-single":
                return 5;
            case "pump-double", "pump-couple":
                return 10;
        }
        
        return 0;
    }
    
    /**
     * Get a note type given it's placement within a measure.
     * @param noteIndex
     * @return
     */
    private function getNoteType(noteIndex                             : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 4) == 0))
        {
            return NOTE_TYPE_4TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 8) == 0))
        {
            return NOTE_TYPE_8TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 12) == 0))
        {
            return NOTE_TYPE_12TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 16) == 0))
        {
            return NOTE_TYPE_16TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 24) == 0))
        {
            return NOTE_TYPE_24TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 32) == 0))
        {
            return NOTE_TYPE_32ND;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 48) == 0))
        {
            return NOTE_TYPE_48TH;
        }
        else if (as3hx.Compat.truthy(noteIndex % (ROWS_PER_MEASURE / 64) == 0))
        {
            return NOTE_TYPE_64TH;
        }
        else
        {
            return NOTE_TYPE_INVALID;
        }
    }
    
    /**
     * Converts a note type into a given color.
     */
    private function noteTypeToColor(noteType                             : Dynamic) : String
    {
        switch (noteType)
        {
            case NOTE_TYPE_4TH:
                return "red";
            case NOTE_TYPE_8TH:
                return "blue";
            case NOTE_TYPE_12TH:
                return "purple";
            case NOTE_TYPE_16TH:
                return "yellow";
            case NOTE_TYPE_24TH:
                return "pink";
            case NOTE_TYPE_32ND:
                return "orange";
            case NOTE_TYPE_48TH:
                return "cyan";
            case NOTE_TYPE_64TH:
                return "green";  // fall through  
            case NOTE_TYPE_192ND, NOTE_TYPE_INVALID:
                return "white";
            default:
                return "white";
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * Sorts an array based on the first item.
     */
    private function keyPairSort(a                             : Dynamic, b                             : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(a[0] < b[0]))
        {
            return -1;
        }
        if (as3hx.Compat.truthy(a[0] > b[0]))
        {
            return 1;
        }
        return 0;
    }
    
    /**
     * Find the current BPM index for the current beat.
     * This searches forward starting from the given index until the BPM
     * beat is ahead of the current beat.
     * @param currentBeat
     * @param startIndex
     * @return
     */
    private function bpm_at_row_index(currentRow                             : Dynamic, startIndex                             : Dynamic= 0) : Int
    {
        var bpm                             : Dynamic= startIndex;
        var len                             : Dynamic= bpms.length;
        
        for (i in startIndex...len)
        {
            if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(bpms[i][0]) > as3hx.Compat.parseFloat(currentRow)))
            {
                break;
            }
            
            bpm = i;
        }
        return bpm;
    }
    
    /**
     * Builds an array of key=value pairs.
     * @param input List of pairs.
     * @param isNumber Parse value as a number.
     * @return
     */
    private function getListValues(input                             : Dynamic, isNumber                             : Dynamic= false) : Array<Dynamic>
    {
        var tmp_array                             : Dynamic= [];
        input = StringTools.trim(input);
        
        if (as3hx.Compat.truthy(input.length == 0))
        {
            return tmp_array;
        }
        
        var arrayValues                             : Dynamic= input.split(",");
        
        if (as3hx.Compat.truthy(arrayValues.length == 0))
        {
            return tmp_array;
        }
        
        var splitIndex                             : Dynamic= null;
        for (arrayList in as3hx.Compat.iter(arrayValues))
        {
            arrayList = StringTools.trim(arrayList);
            splitIndex = arrayList.indexOf("=");
            
            if (as3hx.Compat.truthy(splitIndex >= 1))
            {
                if (as3hx.Compat.truthy(isNumber))
                {
                    tmp_array[tmp_array.length] = [as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), as3hx.Compat.parseFloat(arrayList.substr(splitIndex + 1))];
                }
                else
                {
                    tmp_array[tmp_array.length] = ([as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), arrayList.substr(splitIndex + 1)] : Array<Dynamic>);
                }
            }
        }
        return tmp_array;
    }
    
    /**
     * Gets a count of the given pattern in the input.
     * Quickest way to get the note counts without parsing anything.
     * @param input
     * @param pattern
     * @return
     */
    private function getCharacterCount(input                             : Dynamic, pattern                             : Dynamic) : Float
    {
        var count                             : Dynamic= 0;
        var index                             : Dynamic= -1;
        
        while (as3hx.Compat.truthy((index = input.indexOf(pattern, index + 1)) >= 0))
        {
            count++;
        }
        
        return count;
    }
    
    private function get_chart_bpms() : Array<Dynamic>
    {
        return bpms;
    }
    
    private function get_chart_stops() : Array<Dynamic>
    {
        return stops;
    }
    
    private function get_hasWarp() : Bool
    {
        return _hasWarp;
    }

    public function new()
    {
        super();
    }
}

