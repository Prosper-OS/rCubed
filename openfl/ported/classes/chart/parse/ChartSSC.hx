package classes.chart.parse;

import openfl.errors.Error;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;

class ChartSSC extends ChartBase
{
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
    
    private var fields_number                             : Dynamic= ["offset", 
        "samplestart", 
        "samplelength", 
        "version", 
        "meter"
    ];
    
    override public function load(fileData                             : Dynamic, fileName                             : Dynamic= null) : Bool
    // Validation
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
            
            var tmp_array                             : Dynamic= null;
            var chart                             : Dynamic= -1;
            
            // Build Data Structure
            for (match in as3hx.Compat.iter(matches))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.field(match, 0) == "notedata"))
                {
                    chart++;
                    Reflect.field(data, "notes")[chart] = { };
                    continue;
                }
                
                if (as3hx.Compat.truthy(chart > -1))
                {
                    var _sw0_ = (as3hx.Compat.field(match, 0));                    

                    switch (_sw0_)
                    {
                        case "labels", "speeds", "timesignatures":
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string(as3hx.Compat.field(match, 0)), getListValues(as3hx.Compat.field(match, 1), false));
                        case "bpms", "stops", "delays", "warps", "tickcounts", "combos", "scrolls":
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string(as3hx.Compat.field(match, 0)), getListValues(as3hx.Compat.field(match, 1), true));
                        
                        case "notes":
                            // filter out anything except notes and commas
                            var notesData                             : Dynamic= StringTools.trim(as3hx.Compat.field(match, 1)).split("\n");
                            for (i in 0...notesData.length)
                            {
                                var pos                             : Dynamic= Lambda.indexOf(notesData[i], "//");
                                
                                if (as3hx.Compat.truthy(pos != -1))
                                {
                                    notesData[i] = notesData[i].substr(0, pos);
                                }
                                
                                notesData[i] = StringTools.trim(notesData[i]);
                            }
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string("data"), notesData.join(""));
                            
                            // count arrows, holds, mines
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string("arrows"), getCharacterCount(Reflect.field(Reflect.field(data, "notes")[chart], "data"), "1"));
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string("holds"), getCharacterCount(Reflect.field(Reflect.field(data, "notes")[chart], "data"), "2"));
                            Reflect.setField(Reflect.field(data, "notes")[chart], Std.string("mines"), getCharacterCount(Reflect.field(Reflect.field(data, "notes")[chart], "data"), "M"));
                        default:
                            if (as3hx.Compat.truthy(Lambda.indexOf(fields_number, as3hx.Compat.field(match, 0)) != -1))
                            {
                                Reflect.setField(Reflect.field(data, "notes")[chart], Std.string(as3hx.Compat.field(match, 0)), as3hx.Compat.parseFloat(StringTools.trim(as3hx.Compat.field(match, 1))));
                            }
                            else
                            {
                                Reflect.setField(Reflect.field(data, "notes")[chart], Std.string(as3hx.Compat.field(match, 0)), StringTools.trim(as3hx.Compat.field(match, 1)));
                            }
                    }
                }
                else
                {
                    var _sw1_ = (as3hx.Compat.field(match, 0));                    

                    switch (_sw1_)
                    {
                        case "labels", "speeds", "timesignatures":
                            tmp_array = getListValues(as3hx.Compat.field(match, 1), false);
                            
                            if (as3hx.Compat.truthy(tmp_array.length > 0))
                            {
                                Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), tmp_array);
                            }
                        case "bpms", "stops", "delays", "warps", "tickcounts", "combos", "scrolls":
                            tmp_array = getListValues(as3hx.Compat.field(match, 1), true);
                            
                            if (as3hx.Compat.truthy(tmp_array.length > 0))
                            {
                                Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), tmp_array);
                            }
                        default:
                            if (as3hx.Compat.truthy(Lambda.indexOf(fields_number, as3hx.Compat.field(match, 0)) != -1))
                            {
                                Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), as3hx.Compat.parseFloat(StringTools.trim(as3hx.Compat.field(match, 1))));
                            }
                            else
                            {
                                Reflect.setField(data, Std.string(as3hx.Compat.field(match, 0)), StringTools.trim(as3hx.Compat.field(match, 1)));
                            }
                    }
                }
            }
            
            // Finalize Charts
            chart = as3hx.Compat.parseInt(Reflect.field(data, "notes").length - 1);
            while (as3hx.Compat.truthy(chart >= 0))
            {
                var notes                             : Dynamic= Reflect.field(data, "notes")[chart];
                
                Reflect.setField(notes, "type", standardType(Reflect.field(notes, "stepstype")));  // dance-single, dance-double, dance-couple, dance-solo, etc.  
                Reflect.setField(notes, "desc", "");  // ???  
                Reflect.setField(notes, "class", as3hx.Compat.orValue(Reflect.field(notes, "difficulty"), "Easy"));  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                Reflect.setField(notes, "class_color", as3hx.Compat.orValue(Reflect.field(notes, "difficulty"), "Easy"));  // Beginner, Easy, Medium, Hard, Challenge, ...Edit?  
                Reflect.setField(notes, "difficulty", as3hx.Compat.orValue(Reflect.field(notes, "meter"), 1));  // [0-9]+  
                Reflect.setField(notes, "radar_values", as3hx.Compat.orValue(Reflect.field(notes, "radarvalues"), ""));  // 0.000,0.000,0.000,0.000,0.000  
                Reflect.setField(notes, "time_sec", getChartTimeFast(chart));
                Reflect.setField(notes, "nps", ((Reflect.field(notes, "arrows") + Reflect.field(notes, "holds")) / (Reflect.field(notes, "time_sec"))));
                
                if (as3hx.Compat.truthy(Reflect.field(notes, "credit") != null))
                {
                    Reflect.setField(notes, "stepauthor", Reflect.field(notes, "credit"));
                    Reflect.deleteField(notes, "credit");
                }
                
                if (as3hx.Compat.truthy(!ignoreValidation && (Lambda.indexOf(validColumnCounts, Reflect.field(notes, "type")) == -1)))
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
        
        
        
        if (as3hx.Compat.truthy(Reflect.field(data, "music") == null || Reflect.field(data, "music") == ""))
        {
            Reflect.setField(data, "music", fileName.substr(0, fileName.lastIndexOf(".")) + ".mp3");
        }
        
        if (as3hx.Compat.truthy(Reflect.field(data, "title") == null || Reflect.field(data, "title") == ""))
        {
            Reflect.setField(data, "title", fileName);
        }
        
        var audioExt                           : Dynamic= Std.string(as3hx.Compat.orValue(Reflect.field(data, "music"), "")).substr(-3).toLowerCase();
        if (as3hx.Compat.truthy(!ignoreValidation && (audioExt != "mp3")))
        {
            trace("SSC: Invalid: [", audioExt, "]");
            return false;
        }
        
        // No valid charts found.
        if (as3hx.Compat.truthy(Reflect.field(data, "notes").length <= 0))
        {
            trace("SSC: No Charts");
            return false;
        }
        
        this.loaded = true;
        
        return true;
    }
    
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
    //var t                            : Dynamic= getTimer();
    {
        
        
        var columnCount                             : Dynamic= Reflect.field(chartData, "type");
        var columnMap                           : Dynamic= as3hx.Compat.orValue(as3hx.Compat.field(COLUMNS, Reflect.field(chartData, "type")), []);
        
        var offset                             : Dynamic= Reflect.field(data, "offset") * -1000;
        
        var out                             : Dynamic= {
            data : chartData,
            columns : columnCount
        };
        
        var notes                             : Dynamic= [];
        var holds                             : Dynamic= [];
        var mines                             : Dynamic= [];
        
        var pre_notes                             : Dynamic= [];
        var pre_mines                             : Dynamic= [];
        var pre_holds                             : Dynamic= { };
        
        var currentBeat                             : Dynamic= 0;
        var currentTime                             : Dynamic= 0;
        
        var measureArray                             : Dynamic= Reflect.field(chartData, "data").split(",");
        var measureCount                             : Dynamic= measureArray.length;
        var notebarOffset                             : Dynamic= 0;
        var rowValue                             : Dynamic= 0;
        
        var row                             : Dynamic= null;
        var rowUpdates                             : Dynamic= null;
        
        var msBeatIncrement                             : Dynamic= null;
        var lastBPMIndex                             : Dynamic= 0;
        var lastStopIndex                             : Dynamic= 0;
        var lastStop                             : Dynamic= null;
        
        var warpStart                             : Dynamic= -1;
        var isWarping                             : Dynamic= false;
        
        // Setup BPMs
        var bpms                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "bpms"), as3hx.Compat.orValue(Reflect.field(this.data, "bpms"), [[0, 60]]));
        bpms.sort(keyPairSort);
        bpms[0][0] = 0;  // First BPM starts at beat 0.  
        
        // Setup Stops
        var stops                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "stops"), as3hx.Compat.orValue(Reflect.field(this.data, "stops"), []));
        stops.sort(keyPairSort);
        
        // Setup Warps
        var warps                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "warps"), as3hx.Compat.orValue(Reflect.field(this.data, "warps"), []));
        warps.sort(keyPairSort);
        
        for (currentMeasure in 0...measureCount)
        {
            rowValue = as3hx.Compat.parseInt(currentMeasure * ROWS_PER_MEASURE);
            
            var measure                             : Dynamic= measureArray[currentMeasure];
            notebarOffset = 0;
            
            var barsPerMeasure                             : Dynamic= as3hx.Compat.parseInt(measure.length / columnCount);
            var measureBeat                             : Dynamic= as3hx.Compat.parseInt(currentMeasure * 4);
            
            for (currentNoteBar in 0...barsPerMeasure) {
currentBeat = measureBeat + ((currentNoteBar / barsPerMeasure) * 4);
                
                lastBPMIndex = bpm_at_beat_index(bpms, currentBeat, lastBPMIndex);
                var currentBPM                             : Dynamic= bpms[lastBPMIndex][1];
                
                // Stops
                if (as3hx.Compat.truthy(stops.length > 0 && lastStopIndex < stops.length))
                {
                    if (as3hx.Compat.truthy(lastStop == null))
                    {
                        lastStop = stops[0];
                    }
                    
                    while (as3hx.Compat.truthy(as3hx.Compat.parseFloat(lastStop[0]) <= as3hx.Compat.parseFloat(currentBeat)))
                    {
                        currentTime += lastStop[1] * 1000;
                        lastStopIndex++;
                        if (as3hx.Compat.truthy(lastStopIndex >= stops.length))
                        {
                            break;
                        }
                        
                        lastStop = stops[lastStopIndex];
                    }
                }
                
                // Start Warp
                if (as3hx.Compat.truthy(currentBPM < 0 && !isWarping))
                {
                    warpStart = currentTime;
                    isWarping = true;
                }
                
                // No Notes during Warps
                if (as3hx.Compat.truthy(!isWarping))
                {
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
                                Reflect.setField(pre_holds, Std.string(column), pre_notes.length);
                            }
                            
                            var noteColor                             : Dynamic= noteTypeToColor(getNoteType(currentNoteBar * (ROWS_PER_MEASURE / barsPerMeasure)));
                            
                            pre_notes[pre_notes.length] = new ChartSSCChartObject(as3hx.Compat.parseInt(currentTime), columnMap[column], noteColor);
                        }
                        else if (as3hx.Compat.truthy(noteStr == "3"))
                        {
                            if (as3hx.Compat.truthy(as3hx.Compat.field(pre_holds, column) != null))
                            {
                                var holdStart                             : Dynamic= as3hx.Compat.field(pre_holds, column);
                                var holdStartData                             : Dynamic= pre_notes[holdStart];
                                pre_notes[holdStart].tail = (currentTime - holdStartData.time);
                                Reflect.deleteField(pre_holds, Std.string(column));
                            }
                        }
                        else if (as3hx.Compat.truthy(noteStr == "M"))
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
                    if (as3hx.Compat.truthy(currentBPM < 0 && !isWarping))
                    {
                        warpStart = currentTime;
                        isWarping = true;
                    }
                    
                    // Increase Time
                    msBeatIncrement = 1000 / (currentBPM / 60);
                    currentTime += ((4 / ROWS_PER_MEASURE) * msBeatIncrement);
                }
                
                // End Warp
                if (as3hx.Compat.truthy(isWarping))
                {
                    if (as3hx.Compat.truthy(as3hx.Compat.parseInt(currentTime) >= as3hx.Compat.parseInt(warpStart))) {
{
                            warpStart = -1;
                            isWarping = false;
                        }
                    }
                }
            }
        }
        
        // finalize notes
        var i                             : Dynamic= null;
        var elm                             : Dynamic= null;
        for (i in 0...pre_notes.length)
        {
            elm = pre_notes[i];
            
            elm.time = (offset + elm.time) / 1000;
            
            notes[notes.length] = [elm.time, elm.dir, elm.color];
            
            if (as3hx.Compat.truthy(!Math.isNaN(elm.tail)))
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
        as3hx.Compat.sortOn(notes, "0", as3hx.Compat.ARRAY_NUMERIC);
        as3hx.Compat.sortOn(mines, "0", as3hx.Compat.ARRAY_NUMERIC);
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
    override public function getChartTimeFast(chart_index                             : Dynamic= null) : Float
    // Cached Time
    {
        
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "time_sec") != null))
        {
            return Reflect.field(Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)], "time_sec");
        }
        
        // Calculate
        //var t                            : Dynamic= getTimer();
        
        var chartData                             : Dynamic= Reflect.field(data, "notes")[as3hx.Compat.parseInt(chart_index)];
        
        var currentBeat                             : Dynamic= 0;
        var currentTime                             : Dynamic= 0;
        var currentBPM                             : Dynamic= null;
        
        var measureCount                             : Dynamic= as3hx.Compat.parseInt(getCharacterCount(Reflect.field(chartData, "data"), ",") + 1);
        var maxRows                             : Dynamic= as3hx.Compat.parseInt(ROWS_PER_MEASURE * measureCount);
        
        var msBeatIncrement                             : Dynamic= null;
        var lastBPMIndex                             : Dynamic= 0;
        
        var timeSeq                             : Dynamic= (4 / ROWS_PER_MEASURE);
        
        // Setup BPMs
        var bpms                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "bpms"), as3hx.Compat.orValue(Reflect.field(this.data, "bpms"), [[0, 60]]));
        bpms.sort(keyPairSort);
        bpms[0][0] = 0;  // First BPM starts at beat 0.  
        
        // Setup Stops
        var stops                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "stops"), as3hx.Compat.orValue(Reflect.field(this.data, "stops"), []));
        stops.sort(keyPairSort);
        
        // Setup Warps
        var warps                         : Dynamic= as3hx.Compat.orValue(Reflect.field(chartData, "warps"), as3hx.Compat.orValue(Reflect.field(this.data, "warps"), []));
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
        currentTime += (as3hx.Compat.parseFloat(as3hx.Compat.orValue(Reflect.field(chartData, "offset"), as3hx.Compat.orValue(Reflect.field(data, "offset"), 0))) * -1000);
        
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
    private function bpm_at_beat_index(bpms                             : Dynamic, currentBeat                             : Dynamic, startIndex                             : Dynamic= 0) : Int
    {
        currentBeat = Math.round(currentBeat * 48);  // round to nearest row  
        
        var bpm                             : Dynamic= startIndex;
        var len                             : Dynamic= bpms.length;
        
        for (i in startIndex...len)
        {
            if (as3hx.Compat.truthy(Math.round(as3hx.Compat.parseFloat(bpms[i][0])) * 48 > currentBeat))
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

    public function new()
    {
        super();
    }
}


class ChartSSCChartObject
{
    public var time                             : Dynamic;
    public var color                             : Dynamic;
    public var dir                             : Dynamic;
    public var tail                             : Dynamic;
    
    @:allow(classes.chart.parse)
    private function new(time                             : Dynamic, dir                             : Dynamic, color                             : Dynamic= null)
    {
        this.time = time;
        this.dir = dir;
        this.color = color;
    }
}
