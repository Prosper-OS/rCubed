package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartStepmania extends ChartBase
{
    private static inline var NOTE_TYPE_4TH : Int = 0;
    private static inline var NOTE_TYPE_8TH : Int = 1;
    private static inline var NOTE_TYPE_12TH : Int = 2;
    private static inline var NOTE_TYPE_16TH : Int = 3;
    private static inline var NOTE_TYPE_24TH : Int = 4;
    private static inline var NOTE_TYPE_32ND : Int = 5;
    private static inline var NOTE_TYPE_48TH : Int = 6;
    private static inline var NOTE_TYPE_64TH : Int = 7;
    private static inline var NOTE_TYPE_192ND : Int = 8;
    private static inline var NOTE_TYPE_INVALID : Int = 9;
    
    private static inline var ROWS_PER_MEASURE : Int = 192;
    
    private var fields_array : Array<Dynamic> = ["title", 
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
    
    private var fields_number : Array<Dynamic> = ["offset", 
        "samplestart", 
        "samplelength"
    ];
    
    private var bpms : Array<Dynamic> = [];
    private var stops : Array<Dynamic> = [];
    
    override public function load(fileData : ByteArray, fileName : String = null) : Bool
    {
        try
        {
            fileData.position = 0;
            
            var buff : String = fileData.readUTFBytes(fileData.length).replace(new as3hx.Compat.Regex('\\r\\n|\\r', "gm"), "\n");
            
            // Get All Matches
            var matches : Array<Dynamic> = [];
            var sI : Int = -1;
            var sE : Int = -1;
            while (true)
            {
                sI = buff.indexOf("#", sE);
                sE = buff.indexOf(";", sI);
                
                if (sI >= 0 && sE > sI)
                {
                    var matchString : String = buff.substring(sI, sE);
                    
                    var split : Int = matchString.indexOf(":");
                    var key : String = matchString.substring(1, split).toLowerCase();
                    var value : String = matchString.substr(split + 1);
                    
                    matches[matches.length] = [key, value];
                }
                else
                {
                    break;
                }
            }
            
            // Build Data Structure
            var notes : Dynamic;
            for (match in matches)
            {
                if (Lambda.indexOf(fields_array, Reflect.field(match, Std.string(0))) <= -1)
                {
                    continue;
                }
                
                var _sw2_ = (Reflect.field(match, Std.string(0)));                

                switch (_sw2_)
                {
                    case "bpms", "stops", "freezes":
                        Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), getListValues(Reflect.field(match, Std.string(1)), true));
                    
                    case "notes":
                        notes = { };
                        
                        var notesValues : Array<Dynamic> = Reflect.field(match, Std.string(1)).split(":");
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
                        if (!ignoreValidation && (Lambda.indexOf(validColumnCounts, Reflect.field(notes, "type")) == -1))
                        {
                            trace("SM: Invalid: [", notesValues[0], Reflect.field(notes, "type"), "]");
                            continue;
                        }
                        
                        // filter out anything except notes and commas
                        var notesData : Array<Dynamic> = notesValues[5].split("\n");
                        for (i in 0...notesData.length)
                        {
                            var pos : Int = Lambda.indexOf(notesData[i], "//");
                            
                            if (pos != -1)
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
                        if (Lambda.indexOf(fields_number, Reflect.field(match, Std.string(0))) != -1)
                        {
                            Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), as3hx.Compat.parseFloat(Reflect.field(match, Std.string(1))));
                        }
                        else
                        {
                            Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), Reflect.field(match, Std.string(1)));
                        }
                }
            }
            
            // Setup BPMS
            this.bpms = this.data["bpms"] || [];
            this.bpms.sort(keyPairSort);
            if (this.bpms.length <= 0)
            {
                this.bpms[0] = [0, 60];
            }  // No BPM, default to 60.  
            this.bpms[0][0] = 0;  // First BPM starts at beat 0.  
            
            // Setup Stops
            this.stops = this.data["stops"] || this.data["freezes"] || [];
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
            if (Reflect.field(data, "music") == null || Reflect.field(data, "music") == "")
            {
                Reflect.setField(data, "music", fileName.substr(0, fileName.lastIndexOf(".")) + ".mp3");
            }
            
            if (Reflect.field(data, "title") == null || Reflect.field(data, "title") == "")
            {
                Reflect.setField(data, "title", fileName);
            }
            
            var audioExt : String = (Reflect.field(data, "music") || "").substr(-3).toLowerCase();
            if (!ignoreValidation && (audioExt != "mp3"))
            {
                trace("SM: Invalid: [", audioExt, "]");
                return false;
            }
            
            // No valid charts found.
            if (Reflect.field(data, "notes").length <= 0)
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
        if (!loaded || this.parsed)
        {
            return;
        }
        
        // Fully Parse Charts
        for (chartData/* AS3HX WARNING could not determine type for var: chartData exp: EArray(EIdent(data),EConst(CString(notes))) type: ByteArray */ in Reflect.field(data, "notes"))
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
    private function parseNoteData(chartData : Dynamic) : Dynamic
    //var t:Number = getTimer();
    {
        
        
        var columnCount : Int = Reflect.field(chartData, "type");
        var columnMap : Array<Dynamic> = Reflect.field(COLUMNS, Std.string(Reflect.field(chartData, "type"))) || [];
        
        var offset : Float = Reflect.field(data, "offset") * -1000;
        
        var out : Dynamic = {
            data : chartData,
            columns : columnCount
        };
        
        var notes : Array<Dynamic> = [];
        var mines : Array<Dynamic> = [];
        
        var pre_notes : Array<ChartStepmaniaChartObject> = [];
        var pre_mines : Array<ChartStepmaniaChartObject> = [];
        var pre_holds : Dynamic = { };
        
        var currentRow : Int = 0;
        var currentTime : Float = 0;
        
        var measureArray : Array<Dynamic> = Reflect.field(chartData, "data").split(",");
        var measureCount : Int = measureArray.length;
        var notebarOffset : Int = 0;
        
        var msBeatIncrement : Float;
        var lastBPMIndex : Int = 0;
        var lastStopIndex : Int = 0;
        var lastStop : Array<Dynamic>;
        
        var warpStart : Float = -1;
        var isWarping : Bool = false;
        
        for (currentMeasure in 0...measureCount)
        {
            currentRow = as3hx.Compat.parseInt(currentMeasure * ROWS_PER_MEASURE);
            
            var measure : String = measureArray[currentMeasure];
            notebarOffset = 0;
            
            var barsPerMeasure : Int = as3hx.Compat.parseInt(measure.length / columnCount);
            var measureBeat : Int = as3hx.Compat.parseInt(currentMeasure * 4);
            
            for (currentNoteBar in 0...barsPerMeasure)
            {
                lastBPMIndex = bpm_at_row_index(currentRow, lastBPMIndex);
                var currentBPM : Float = bpms[lastBPMIndex][1];
                
                // Stops
                if (stops.length > 0 && lastStopIndex < stops.length)
                {
                    if (lastStop == null)
                    {
                        lastStop = stops[0];
                    }
                    
                    while (lastStop[0] < currentRow)
                    {
                        currentTime += lastStop[1] * 1000;
                        lastStopIndex++;
                        if (lastStopIndex >= stops.length)
                        {
                            break;
                        }
                        
                        lastStop = stops[lastStopIndex];
                    }
                }
                
                // Start Warp
                if (currentBPM < 0 && !isWarping)
                {
                    warpStart = currentTime;
                    isWarping = true;
                }
                
                // No Notes during Warps
                if (!isWarping)
                {
                    for (column in 0...columnCount)
                    {
                        var noteStr : String = measure.charAt(notebarOffset + column);
                        
                        if (noteStr == "0")
                        {
                            continue;
                        }
                        
                        if (noteStr == "1" || noteStr == "2" || noteStr == "4")
                        {
                            if (noteStr == "2" || noteStr == "4")
                            {
                                Reflect.setField(pre_holds, Std.string(column), pre_notes.length);
                            }
                            
                            var noteColor : String = noteTypeToColor(getNoteType(currentNoteBar * (ROWS_PER_MEASURE / barsPerMeasure)));
                            
                            pre_notes[pre_notes.length] = new ChartStepmaniaChartObject(as3hx.Compat.parseInt(currentTime), columnMap[column], noteColor);
                        }
                        else if (noteStr == "3")
                        {
                            if (Reflect.field(pre_holds, Std.string(column)) != null)
                            {
                                var holdStart : Int = Reflect.field(pre_holds, Std.string(column));
                                var holdStartData : ChartStepmaniaChartObject = pre_notes[holdStart];
                                pre_notes[holdStart].tail = (currentTime - holdStartData.time);
                                Reflect.deleteField(pre_holds, Std.string(column));
                            }
                        }
                        else if (noteStr == "M")
                        {
                            pre_mines[pre_mines.length] = new ChartStepmaniaChartObject(as3hx.Compat.parseInt(currentTime), columnMap[column]);
                        }
                    }
                }
                
                // Update String Offset
                notebarOffset += columnCount;
                
                // BPMs need to be handled on every 192nd, skipping any row will result in
                // off-sync if a BPM change lands on a row not handled by the measure.
                var rowUpdates : Int = as3hx.Compat.parseInt(ROWS_PER_MEASURE / barsPerMeasure);
                for (row in 0...rowUpdates)
                {
                    lastBPMIndex = bpm_at_row_index(currentRow, lastBPMIndex);
                    currentBPM = bpms[lastBPMIndex][1];
                    
                    // Start Warp
                    if (currentBPM < 0 && !isWarping)
                    {
                        warpStart = currentTime;
                        isWarping = true;
                    }
                    
                    // Increase Time
                    msBeatIncrement = 1000 / (currentBPM / 60);
                    currentTime += ((4 / ROWS_PER_MEASURE) * msBeatIncrement);
                    
                    currentRow++;
                }
                
                // End Warp
                if (isWarping)
                {
                    if (as3hx.Compat.parseInt(currentTime) >= as3hx.Compat.parseInt(warpStart)) {
{
                            warpStart = -1;
                            isWarping = false;
                        }
                    }
                }
            }
        }
        
        // finalize notes
        var i : Int;
        var elm : ChartStepmaniaChartObject;
        for (i in 0...pre_notes.length)
        {
            elm = pre_notes[i];
            
            elm.time = (offset + elm.time) / 1000;
            
            notes[notes.length] = [elm.time, elm.dir, elm.color, (!(Math.isNaN(elm.tail)) ? (as3hx.Compat.parseInt(elm.tail) / 1000) : 0)];
        }
        
        // finalize mines
        for (i in 0...pre_mines.length)
        {
            elm = pre_mines[i];
            
            elm.time = (offset + elm.time) / 1000;
            
            mines[mines.length] = [elm.time, elm.dir];
        }
        
        // sort data array so time is in order
        notes.sortOn("0", Array.NUMERIC);
        mines.sortOn("0", Array.NUMERIC);
        
        Reflect.setField(out, "notes", notes);
        Reflect.setField(out, "mines", mines);
        
        Reflect.deleteField(chartData, "data"); // Clear Vectors for GC  ;
        
        
        
        measureArray = null;
        pre_notes = null;
        pre_holds = null;
        pre_mines = null;
        
        //trace("parsed in", (getTimer() - t), notes[notes.length - 1][0]);
        
        return out;
    }
    
    /**
     * Computes a charts expected length using measure count and BPM.
     * @param chart_index
     * @return
     */
    override public function getChartTimeFast(chart_index : Dynamic = null) : Float
    // Cached Time
    {
        
        if (Reflect.field(data, "notes")[chart_index]["time_sec"] != null)
        {
            return Reflect.field(data, "notes")[chart_index]["time_sec"];
        }
        
        // Calculate
        //var t:Number = getTimer();
        
        var currentTime : Float = 0;
        var currentBPM : Float;
        
        var measureCount : Int = as3hx.Compat.parseInt(getCharacterCount(Reflect.field(data, "notes")[chart_index]["data"], ",") + 1);
        var maxRows : Int = as3hx.Compat.parseInt(ROWS_PER_MEASURE * measureCount);
        
        var msBeatIncrement : Float;
        var lastBPMIndex : Int = 0;
        var currentRow : Int = 0;
        
        var timeSeq : Float = (4 / ROWS_PER_MEASURE);
        
        // BPMs need to be handled on every 192nd, skipping any row will result in
        // off-sync if a BPM change lands on a row not handled by the measure.
        while (currentRow < maxRows)
        {
            lastBPMIndex = bpm_at_row_index(currentRow, lastBPMIndex);
            currentBPM = bpms[lastBPMIndex][1];
            
            // Increase Time
            msBeatIncrement = 1000 / (currentBPM / 60);
            currentTime += (timeSeq * msBeatIncrement);
            
            currentRow++;
        }
        
        // Stops
        if (stops.length > 0)
        {
            var i : Int = as3hx.Compat.parseInt(stops.length - 1);
            while (i >= 0)
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
    private function getNoteType(noteIndex : Int) : Int
    {
        if (noteIndex % (ROWS_PER_MEASURE / 4) == 0)
        {
            return NOTE_TYPE_4TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 8) == 0)
        {
            return NOTE_TYPE_8TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 12) == 0)
        {
            return NOTE_TYPE_12TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 16) == 0)
        {
            return NOTE_TYPE_16TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 24) == 0)
        {
            return NOTE_TYPE_24TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 32) == 0)
        {
            return NOTE_TYPE_32ND;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 48) == 0)
        {
            return NOTE_TYPE_48TH;
        }
        else if (noteIndex % (ROWS_PER_MEASURE / 64) == 0)
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
    private function noteTypeToColor(noteType : Int) : String
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
    private function keyPairSort(a : Array<Dynamic>, b : Array<Dynamic>) : Int
    {
        if (a[0] < b[0])
        {
            return -1;
        }
        if (a[0] > b[0])
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
    private function bpm_at_row_index(currentRow : Float, startIndex : Int = 0) : Int
    {
        var bpm : Int = startIndex;
        var len : Int = bpms.length;
        
        for (i in startIndex...len)
        {
            if (bpms[i][0] > currentRow)
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
    private function getListValues(input : String, isNumber : Bool = false) : Array<Dynamic>
    {
        var tmp_array : Array<Dynamic> = [];
        input = StringTools.trim(input);
        
        if (input.length == 0)
        {
            return tmp_array;
        }
        
        var arrayValues : Array<Dynamic> = input.split(",");
        
        if (arrayValues.length == 0)
        {
            return tmp_array;
        }
        
        var splitIndex : Int;
        for (arrayList in arrayValues)
        {
            arrayList = StringTools.trim(arrayList);
            splitIndex = arrayList.indexOf("=");
            
            if (splitIndex >= 1)
            {
                if (isNumber)
                {
                    tmp_array[tmp_array.length] = [Math.round(48 * as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex))), as3hx.Compat.parseFloat(arrayList.substr(splitIndex + 1))];
                }
                else
                {
                    tmp_array[tmp_array.length] = [Math.round(48 * as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex))), arrayList.substr(splitIndex + 1)];
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
    private function getCharacterCount(input : String, pattern : String) : Float
    {
        var count : Float = 0;
        var index : Int = -1;
        
        while ((index = input.indexOf(pattern, index + 1)) >= 0)
        {
            count++;
        }
        
        return count;
    }

    public function new()
    {
        super();
    }
}


class ChartStepmaniaChartObject
{
    public var time : Float;
    public var color : String;
    public var dir : String;
    public var tail : Float;
    
    @:allow(classes.chart.parse)
    private function new(time : Float, dir : String, color : String = null)
    {
        this.time = time;
        this.dir = dir;
        this.color = color;
    }
}
