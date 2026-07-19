package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartSSC extends ChartBase
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
    
    private var fields_number : Array<Dynamic> = ["offset", 
        "samplestart", 
        "samplelength", 
        "version", 
        "meter"
    ];
    
    override public function load(fileData : ByteArray, fileName : String = null) : Bool
    // Validation
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
            
            var tmp_array : Array<Dynamic>;
            var chart : Int = -1;
            
            // Build Data Structure
            for (match in matches)
            {
                if (Reflect.field(match, Std.string(0)) == "notedata")
                {
                    chart++;
                    Reflect.setField(data, "notes", { })[chart];
                    continue;
                }
                
                if (chart > -1)
                {
                    var _sw0_ = (Reflect.field(match, Std.string(0)));                    

                    switch (_sw0_)
                    {
                        case "labels", "speeds", "timesignatures":
                            Reflect.setField(data, "notes", getListValues(Reflect.field(match, Std.string(1)), false))[chart][Reflect.setField(match, Std.string(0), )];
                        case "bpms", "stops", "delays", "warps", "tickcounts", "combos", "scrolls":
                            Reflect.setField(data, "notes", getListValues(Reflect.field(match, Std.string(1)), true))[chart][Reflect.setField(match, Std.string(0), )];
                        
                        case "notes":
                            // filter out anything except notes and commas
                            var notesData : Array<Dynamic> = StringTools.trim(Reflect.field(match, Std.string(1))).split("\n");
                            for (i in 0...notesData.length)
                            {
                                var pos : Int = Lambda.indexOf(notesData[i], "//");
                                
                                if (pos != -1)
                                {
                                    notesData[i] = notesData[i].substr(0, pos);
                                }
                                
                                notesData[i] = StringTools.trim(notesData[i]);
                            }
                            Reflect.setField(data, "notes", notesData.join(""))[chart]["data"];
                            
                            // count arrows, holds, mines
                            Reflect.setField(data, "notes", getCharacterCount(Reflect.field(data, "notes")[chart]["data"], "1"))[chart]["arrows"];
                            Reflect.setField(data, "notes", getCharacterCount(Reflect.field(data, "notes")[chart]["data"], "2"))[chart]["holds"];
                            Reflect.setField(data, "notes", getCharacterCount(Reflect.field(data, "notes")[chart]["data"], "M"))[chart]["mines"];
                        default:
                            if (Lambda.indexOf(fields_number, Reflect.field(match, Std.string(0))) != -1)
                            {
                                Reflect.setField(data, "notes", as3hx.Compat.parseFloat(StringTools.trim(Reflect.field(match, Std.string(1)))))[chart][Reflect.setField(match, Std.string(0), )];
                            }
                            else
                            {
                                Reflect.setField(data, "notes", StringTools.trim(Reflect.field(match, Std.string(1))))[chart][Reflect.setField(match, Std.string(0), )];
                            }
                    }
                }
                else
                {
                    var _sw1_ = (Reflect.field(match, Std.string(0)));                    

                    switch (_sw1_)
                    {
                        case "labels", "speeds", "timesignatures":
                            tmp_array = getListValues(Reflect.field(match, Std.string(1)), false);
                            
                            if (tmp_array.length > 0)
                            {
                                Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), tmp_array);
                            }
                        case "bpms", "stops", "delays", "warps", "tickcounts", "combos", "scrolls":
                            tmp_array = getListValues(Reflect.field(match, Std.string(1)), true);
                            
                            if (tmp_array.length > 0)
                            {
                                Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), tmp_array);
                            }
                        default:
                            if (Lambda.indexOf(fields_number, Reflect.field(match, Std.string(0))) != -1)
                            {
                                Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), as3hx.Compat.parseFloat(StringTools.trim(Reflect.field(match, Std.string(1)))));
                            }
                            else
                            {
                                Reflect.setField(data, Std.string(Reflect.field(match, Std.string(0))), StringTools.trim(Reflect.field(match, Std.string(1))));
                            }
                    }
                }
            }
            
            // Finalize Charts
            chart = as3hx.Compat.parseInt(Reflect.field(data, "notes").length - 1);
            while (chart >= 0)
            {
                var notes : Dynamic = Reflect.field(data, "notes")[chart];
                
                Reflect.setField(notes, "type", standardType(Reflect.field(notes, "stepstype")));  // dance-single, dance-double, dance-couple, dance-solo, etc.  
                Reflect.setField(notes, "desc", "");  // ???  
                Reflect.setField(notes, "class", Reflect.field(notes, "difficulty") || "Easy");  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                Reflect.setField(notes, "class_color", Reflect.field(notes, "difficulty") || "Easy");  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                Reflect.setField(notes, "difficulty", Reflect.field(notes, "meter") || 1);  // [0-9]+  
                Reflect.setField(notes, "radar_values", Reflect.field(notes, "radarvalues") || "");  // 0.000,0.000,0.000,0.000,0.000  
                Reflect.setField(notes, "time_sec", getChartTimeFast(chart));
                Reflect.setField(notes, "nps", ((Reflect.field(notes, "arrows") + Reflect.field(notes, "holds")) / (Reflect.field(notes, "time_sec"))));
                
                if (Reflect.field(notes, "credit") != null)
                {
                    Reflect.setField(notes, "stepauthor", Reflect.field(notes, "credit"));
                    Reflect.deleteField(notes, "credit");
                }
                
                if (!ignoreValidation && (Lambda.indexOf(validColumnCounts, Reflect.field(notes, "type")) == -1))
                {
                    trace("SSC: Invalid: [", Reflect.field(notes, "stepstype"), Reflect.field(notes, "type"), "]");
                    Reflect.field(data, "notes").removeAt(chart);
                    {chart--;continue;
                    }
                }
                
                Reflect.deleteField(notes, "stepstype");
                Reflect.deleteField(notes, "meter");
                chart--;
            }
            
            // Match Stepmania Variables
            Reflect.setField(data, "stepauthor", Reflect.field(data, "credit"));
        }
        catch (e : Error)
        {
            trace("SSC: Error Catch: " + e);
            return false;
        }
        
        
        
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
            trace("SSC: Invalid: [", audioExt, "]");
            return false;
        }
        
        // No valid charts found.
        if (Reflect.field(data, "notes").length <= 0)
        {
            trace("SSC: No Charts");
            return false;
        }
        
        this.loaded = true;
        
        return true;
    }
    
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
        var holds : Array<Dynamic> = [];
        var mines : Array<Dynamic> = [];
        
        var pre_notes : Array<ChartSSCChartObject> = [];
        var pre_mines : Array<ChartSSCChartObject> = [];
        var pre_holds : Dynamic = { };
        
        var currentBeat : Float = 0;
        var currentTime : Float = 0;
        
        var measureArray : Array<Dynamic> = Reflect.field(chartData, "data").split(",");
        var measureCount : Int = measureArray.length;
        var notebarOffset : Int = 0;
        var rowValue : Int = 0;
        
        var row : Int;
        var rowUpdates : Int;
        
        var msBeatIncrement : Float;
        var lastBPMIndex : Int = 0;
        var lastStopIndex : Int = 0;
        var lastStop : Array<Dynamic>;
        
        var warpStart : Float = -1;
        var isWarping : Bool = false;
        
        // Setup BPMs
        var bpms : Array<Dynamic> = Reflect.field(chartData, "bpms") || this.data["bpms"] || [[0, 60]];
        bpms.sort(keyPairSort);
        bpms[0][0] = 0;  // First BPM starts at beat 0.  
        
        // Setup Stops
        var stops : Array<Dynamic> = Reflect.field(chartData, "stops") || this.data["stops"] || [];
        stops.sort(keyPairSort);
        
        // Setup Warps
        var warps : Array<Dynamic> = Reflect.field(chartData, "warps") || this.data["warps"] || [];
        warps.sort(keyPairSort);
        
        for (currentMeasure in 0...measureCount)
        {
            rowValue = as3hx.Compat.parseInt(currentMeasure * ROWS_PER_MEASURE);
            
            var measure : String = measureArray[currentMeasure];
            notebarOffset = 0;
            
            var barsPerMeasure : Int = as3hx.Compat.parseInt(measure.length / columnCount);
            var measureBeat : Int = as3hx.Compat.parseInt(currentMeasure * 4);
            
            for (currentNoteBar in 0...barsPerMeasure) {
currentBeat = measureBeat + ((currentNoteBar / barsPerMeasure) * 4);
                
                lastBPMIndex = bpm_at_beat_index(bpms, currentBeat, lastBPMIndex);
                var currentBPM : Float = bpms[lastBPMIndex][1];
                
                // Stops
                if (stops.length > 0 && lastStopIndex < stops.length)
                {
                    if (lastStop == null)
                    {
                        lastStop = stops[0];
                    }
                    
                    while (lastStop[0] <= currentBeat)
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
                            
                            pre_notes[pre_notes.length] = new ChartSSCChartObject(as3hx.Compat.parseInt(currentTime), columnMap[column], noteColor);
                        }
                        else if (noteStr == "3")
                        {
                            if (Reflect.field(pre_holds, Std.string(column)) != null)
                            {
                                var holdStart : Int = Reflect.field(pre_holds, Std.string(column));
                                var holdStartData : ChartSSCChartObject = pre_notes[holdStart];
                                pre_notes[holdStart].tail = (currentTime - holdStartData.time);
                                Reflect.deleteField(pre_holds, Std.string(column));
                            }
                        }
                        else if (noteStr == "M")
                        {
                            pre_mines[pre_mines.length] = new ChartSSCChartObject(as3hx.Compat.parseInt(currentTime), columnMap[column]);
                        }
                    }
                }
                
                // Update String Offset
                notebarOffset += columnCount;
                
                // BPMs need to be handled on every 192nd, skipping any row will result in
                // off-sync if a BPM change lands on a row not handled by the measure.
                rowUpdates = as3hx.Compat.parseInt(ROWS_PER_MEASURE / barsPerMeasure);
                for (row in 0...rowUpdates)
                {
                    rowValue++;
                    currentBeat = measureBeat + (((currentNoteBar / barsPerMeasure) + (row / ROWS_PER_MEASURE)) * 4);
                    lastBPMIndex = bpm_at_beat_index(bpms, currentBeat, lastBPMIndex);
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
        var elm : ChartSSCChartObject;
        for (i in 0...pre_notes.length)
        {
            elm = pre_notes[i];
            
            elm.time = (offset + elm.time) / 1000;
            
            notes[notes.length] = [elm.time, elm.dir, elm.color];
            
            if (!Math.isNaN(elm.tail))
            {
                holds[holds.length] = [elm.time, elm.dir, elm.color, (as3hx.Compat.parseInt(elm.tail) / 1000)];
            }
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
        Reflect.setField(out, "holds", holds);
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
        
        var chartData : Dynamic = Reflect.field(data, "notes")[chart_index];
        
        var currentBeat : Float = 0;
        var currentTime : Float = 0;
        var currentBPM : Float;
        
        var measureCount : Int = as3hx.Compat.parseInt(getCharacterCount(Reflect.field(chartData, "data"), ",") + 1);
        var maxRows : Int = as3hx.Compat.parseInt(ROWS_PER_MEASURE * measureCount);
        
        var msBeatIncrement : Float;
        var lastBPMIndex : Int = 0;
        
        var timeSeq : Float = (4 / ROWS_PER_MEASURE);
        
        // Setup BPMs
        var bpms : Array<Dynamic> = Reflect.field(chartData, "bpms") || this.data["bpms"] || [[0, 60]];
        bpms.sort(keyPairSort);
        bpms[0][0] = 0;  // First BPM starts at beat 0.  
        
        // Setup Stops
        var stops : Array<Dynamic> = Reflect.field(chartData, "stops") || this.data["stops"] || [];
        stops.sort(keyPairSort);
        
        // Setup Warps
        var warps : Array<Dynamic> = Reflect.field(chartData, "warps") || this.data["warps"] || [];
        warps.sort(keyPairSort);
        
        // BPMs need to be handled on every 192nd, skipping any row will result in
        // off-sync if a BPM change lands on a row not handled by the measure.
        for (row in 0...maxRows)
        {
            currentBeat = (row / 48);
            lastBPMIndex = bpm_at_beat_index(bpms, currentBeat, lastBPMIndex);
            currentBPM = bpms[lastBPMIndex][1];
            
            // Increase Time
            msBeatIncrement = 1000 / (currentBPM / 60);
            currentTime += (timeSeq * msBeatIncrement);
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
        currentTime += ((Reflect.field(chartData, "offset") || Reflect.field(data, "offset") || 0) * -1000);
        
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
    private function bpm_at_beat_index(bpms : Array<Dynamic>, currentBeat : Float, startIndex : Int = 0) : Int
    {
        currentBeat = Math.round(currentBeat * 48);  // round to nearest row  
        
        var bpm : Int = startIndex;
        var len : Int = bpms.length;
        
        for (i in startIndex...len)
        {
            if (Math.round(bpms[i][0]) * 48 > currentBeat)
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
                    tmp_array[tmp_array.length] = [as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), as3hx.Compat.parseFloat(arrayList.substr(splitIndex + 1))];
                }
                else
                {
                    tmp_array[tmp_array.length] = [as3hx.Compat.parseFloat(arrayList.substr(0, splitIndex)), arrayList.substr(splitIndex + 1)];
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


class ChartSSCChartObject
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
