package classes.chart.parse;

import by.blooddy.crypto.MD5;
import classes.chart.parse.ChartBase;
import classes.chart.parse.ChartOSU;
import classes.chart.parse.ChartQuaver;
import classes.chart.parse.ChartSSC;
import classes.chart.parse.ChartStepmania;
import com.flashfla.utils.TimeUtil;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import r3.air.filesystem.File;
import r3.air.filesystem.FileMode;
import r3.air.filesystem.FileStream;
import openfl.utils.ByteArray;

class ExternalChartBase
{
    public static var VALID_CHART_EXTENSIONS : Array<Dynamic> = ["sm", "ssc", "osu", "qua"];
    
    public var ID : String;
    public var DATE : Float;
    
    public var DEFAULT_CHART_ID : Int = 0;
    
    private var CHART_BYTES : ByteArray;
    private var AUDIO_BYTES : ByteArray;
    
    private var fileQueue : Array<Dynamic> = [];
    
    private var info : Dynamic = {
            name : "External File",
            display : "???",
            difficulty : 1,
            author : "???",
            stepauthor : "???",
            description : "???"
        };
    
    public var parser : ChartBase;
    
    public function parseData() : Void
    {
        if (!parser.parsed)
        {
            parser.parse();
        }
    }
    
    public function getInfo() : Dynamic
    {
        return info;
    }
    
    public function getAudioData() : ByteArray
    {
        return AUDIO_BYTES;
    }
    
    public function getChartData() : ByteArray
    {
        return CHART_BYTES;
    }
    
    public function getAllCharts() : Array<Dynamic>
    {
        return parser.data["notes"];
    }
    
    public function getValidChartData(chart_index : Dynamic = null) : Dynamic
    {
        if (parser.charts[chart_index] != null)
        {
            return parser.charts[chart_index];
        }
        
        return parser.charts[DEFAULT_CHART_ID];
    }
    
    public function getNoteData(chart_index : Dynamic = null) : Array<Dynamic>
    {
        return getValidChartData(chart_index)["notes"];
    }
    
    public function getMineData(chart_index : Dynamic = null) : Array<Dynamic>
    {
        return getValidChartData(chart_index)["mines"];
    }
    
    public function getColumnCount(chart_index : Dynamic = null) : Int
    {
        return getValidChartData(chart_index)["columns"];
    }
    
    public function getChartTime(chart_index : Dynamic = null) : Float
    {
        if (!this.parser.parsed)
        {
            return this.parser.getChartTimeFast(chart_index);
        }
        
        // We have parsed data, use note timings.
        var nd : Array<Dynamic> = getNoteData(chart_index);
        var md : Array<Dynamic> = getMineData(chart_index);
        
        if (nd.length <= 0)
        {
            return 0;
        }
        
        var maxTime : Float = 0;
        var i : Int = as3hx.Compat.parseInt(nd.length - 1);
        while (i >= 0)
        {
            maxTime = Math.max(maxTime, nd[i][0] + nd[i][3]);
            i--;
        }
        
        if (md.length > 0)
        {
            maxTime = Math.max(maxTime, md[md.length - 1][0]);
        }
        
        return maxTime;
    }
    
    public function getChartTimeFormat(maxTime : Float) : String
    {
        if (Math.isNaN(maxTime) || maxTime < 0)
        {
            return "0:00";
        }
        
        var s : Float = maxTime % 60;
        var m : Float = Math.floor((maxTime % 3600) / 60);
        var h : Float = Math.floor(maxTime / (60 * 60));
        
        var hourStr : String = ((h == 0)) ? "" : (h) + ":";
        var minuteStr : String = ((h == 0)) ? (m + ":") : (TimeUtil.doubleDigitFormat(m) + ":");
        var secondsStr : String = TimeUtil.doubleDigitFormat(s);
        
        return hourStr + minuteStr + secondsStr;
    }
    
    //----------------------------------------------------------------------------------------------------------//
    
    public function load(folder : File, skipMusicLoad : Bool = false) : Bool
    // Search Folder for Parseable Files
    {
        
        if (folder.isDirectory)
        {
            for (file/* AS3HX WARNING could not determine type for var: file exp: ECall(EField(EIdent(folder),getDirectoryListing),[]) type: null */ in folder.getDirectoryListing())
            {
                if (Lambda.indexOf(VALID_CHART_EXTENSIONS, file.extension.toLowerCase()) != -1)
                {
                    fileQueue.push(file);
                }
            }
        }
        // Given File, Assume Good
        else
        {
            
            {
                if (Lambda.indexOf(VALID_CHART_EXTENSIONS, folder.extension.toLowerCase()) != -1)
                {
                    fileQueue.push(folder);
                }
            }
        }
        
        // Validate and Load File Queue, Stop after first valid chart.
        while (fileQueue.length > 0)
        {
            var firstFile : File = fileQueue.pop();
            
            if (!firstFile.exists)
            {
                continue;
            }
            
            Reflect.setField(info, "filename", firstFile.name);
            
            parser = getParser(firstFile.extension.toLowerCase());
            
            CHART_BYTES = readFile(firstFile);
            
            if (parser.load(CHART_BYTES, Reflect.field(info, "filename")))
            {
                Reflect.setField(info, "ext", firstFile.extension.toLowerCase());
                Reflect.setField(info, "name", parser.data.title || "???");
                Reflect.setField(info, "display", parser.data.title || "???");
                Reflect.setField(info, "author", parser.data.artist || "???");
                Reflect.setField(info, "stepauthor", parser.data.stepauthor || "???");
                Reflect.setField(info, "difficulty", parser.data.difficulty || 1);
                Reflect.setField(info, "arrows", parser.data.notes[DEFAULT_CHART_ID].arrows);
                Reflect.setField(info, "holds", parser.data.notes[DEFAULT_CHART_ID].holds);
                Reflect.setField(info, "mines", parser.data.notes[DEFAULT_CHART_ID].mines);
                Reflect.setField(info, "time_secs", getChartTime(DEFAULT_CHART_ID));
                Reflect.setField(info, "time", getChartTimeFormat(Reflect.field(info, "time_secs")));
                Reflect.setField(info, "music", parser.data.music || "");
                Reflect.setField(info, "banner", parser.data.banner || "");
                Reflect.setField(info, "background", parser.data.background || "");
                
                ID = MD5.hashBytes(CHART_BYTES);
                DATE = firstFile.modificationDate.getTime();
                
                // Folder Path
                var path : String = firstFile.nativePath;
                var endOfFolder : Int = as3hx.Compat.parseInt(path.lastIndexOf(File.separator) + 1);
                Reflect.setField(info, "folder", path.substr(0, endOfFolder));
                
                // Music Validation
                if (parser.data.music.length < 4 || parser.data.music.substr(-3).toLowerCase() != "mp3")
                {
                    return false;
                }
                
                if (!skipMusicLoad)
                {
                    var musicFile : File = firstFile.parent.resolvePath(parser.data.music);
                    
                    if (!musicFile.exists)
                    {
                        return false;
                    }
                    
                    AUDIO_BYTES = readFile(firstFile.parent.resolvePath(parser.data.music));
                }
                
                as3hx.Compat.setArrayLength(fileQueue, 0);
                return true;
            }
        }
        
        return false;
    }
    
    public function getParser(ext : String) : ChartBase
    {
        switch (ext)
        {
            case "sm":
                return new ChartStepmania();
            
            case "ssc":
                return new ChartSSC();
            
            case "osu":
                return new ChartOSU();
            
            case "qua":
                return new ChartQuaver();
        }
        
        return null;
    }
    
    public function readFile(file : File) : ByteArray
    {
        if (!file.exists)
        {
            return null;
        }
        
        var fileStream : FileStream = new FileStream();
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, e_error);
        var readData : ByteArray = new ByteArray();
        fileStream.open(file, FileMode.READ);
        fileStream.readBytes(readData);
        fileStream.close();
        
        return readData;
        
        var e_error : ErrorEvent->Void = function(e : ErrorEvent) : Void
        {
        }
    }

    public function new()
    {
    }
}

