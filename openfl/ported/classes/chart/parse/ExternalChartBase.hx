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
    private static var e_error      : Dynamic;
    public static var VALID_CHART_EXTENSIONS                             : Dynamic= ["sm", "ssc", "osu", "qua"];
    
    public var ID                             : Dynamic;
    public var DATE                             : Dynamic;
    
    public var DEFAULT_CHART_ID                             : Dynamic= 0;
    
    private var CHART_BYTES                             : Dynamic;
    private var AUDIO_BYTES                             : Dynamic;
    
    private var fileQueue                             : Dynamic= [];
    
    private var info                             : Dynamic= {
            name : "External File",
            display : "???",
            difficulty : 1,
            author : "???",
            stepauthor : "???",
            description : "???"
        };
    
    public var parser                             : Dynamic;
    
    public function parseData() : Void
    {
        if (as3hx.Compat.truthy(!parser.parsed))
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
        return Reflect.field(parser.data, "notes");
    }
    
    public function getValidChartData(chart_index                             : Dynamic= null) : Dynamic
    {
        if (as3hx.Compat.truthy(parser.charts[chart_index] != null))
        {
            return parser.charts[chart_index];
        }
        
        return parser.charts[DEFAULT_CHART_ID];
    }
    
    public function getNoteData(chart_index                             : Dynamic= null) : Array<Dynamic>
    {
        return Reflect.field(getValidChartData(chart_index), "notes");
    }
    
    public function getMineData(chart_index                             : Dynamic= null) : Array<Dynamic>
    {
        return Reflect.field(getValidChartData(chart_index), "mines");
    }
    
    public function getColumnCount(chart_index                             : Dynamic= null) : Int
    {
        return Reflect.field(getValidChartData(chart_index), "columns");
    }
    
    public function getChartTime(chart_index                             : Dynamic= null) : Float
    {
        if (as3hx.Compat.truthy(!this.parser.parsed))
        {
            return this.parser.getChartTimeFast(chart_index);
        }
        
        // We have parsed data, use note timings.
        var nd                             : Dynamic= getNoteData(chart_index);
        var md                             : Dynamic= getMineData(chart_index);
        
        if (as3hx.Compat.truthy(nd.length <= 0))
        {
            return 0;
        }
        
        var maxTime                             : Dynamic= 0;
        var i                             : Dynamic= as3hx.Compat.parseInt(nd.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][0]) + as3hx.Compat.parseFloat(nd[as3hx.Compat.parseInt(i)][3]));
            i--;
        }
        
        if (as3hx.Compat.truthy(md.length > 0))
        {
            maxTime = Math.max(maxTime, as3hx.Compat.parseFloat(md[as3hx.Compat.parseInt(md.length - 1)][0]));
        }
        
        return maxTime;
    }
    
    public function getChartTimeFormat(maxTime                             : Dynamic) : String
    {
        if (as3hx.Compat.truthy(Math.isNaN(maxTime) || maxTime < 0))
        {
            return "0:00";
        }
        
        var s                             : Dynamic= maxTime % 60;
        var m                             : Dynamic= Math.floor((maxTime % 3600) / 60);
        var h                             : Dynamic= Math.floor(maxTime / (60 * 60));
        
        var hourStr                             : Dynamic= ((h == 0)) ? "" : (h) + ":";
        var minuteStr                             : Dynamic= ((h == 0)) ? (m + ":") : (TimeUtil.doubleDigitFormat(m) + ":");
        var secondsStr                             : Dynamic= TimeUtil.doubleDigitFormat(s);
        
        return hourStr + minuteStr + secondsStr;
    }
    
    //----------------------------------------------------------------------------------------------------------//
    
    public function load(folder                             : Dynamic, skipMusicLoad                             : Dynamic= false) : Bool
    // Search Folder for Parseable Files
    {
        
        if (as3hx.Compat.truthy(folder.isDirectory))
        {
            for (file/* AS3HX WARNING could not determine type for var: file exp: ECall(EField(EIdent(folder),getDirectoryListing),[]) type: null */ in as3hx.Compat.iter(folder.getDirectoryListing()))
            {
                if (as3hx.Compat.truthy(Lambda.indexOf(VALID_CHART_EXTENSIONS, file.extension.toLowerCase()) != -1))
                {
                    fileQueue.push(file);
                }
            }
        }
        // Given File, Assume Good
        else
        {
            
            {
                if (as3hx.Compat.truthy(Lambda.indexOf(VALID_CHART_EXTENSIONS, folder.extension.toLowerCase()) != -1))
                {
                    fileQueue.push(folder);
                }
            }
        }
        
        // Validate and Load File Queue, Stop after first valid chart.
        while (as3hx.Compat.truthy(fileQueue.length > 0))
        {
            var firstFile                             : Dynamic= fileQueue.pop();
            
            if (as3hx.Compat.truthy(!firstFile.exists))
            {
                continue;
            }
            
            Reflect.setField(info, "filename", firstFile.name);
            
            parser = getParser(firstFile.extension.toLowerCase());
            
            CHART_BYTES = readFile(firstFile);
            
            if (as3hx.Compat.truthy(parser.load(CHART_BYTES, Reflect.field(info, "filename"))))
            {
                Reflect.setField(info, "ext", firstFile.extension.toLowerCase());
                Reflect.setField(info, "name", as3hx.Compat.orValue(parser.data.title, "???"));
                Reflect.setField(info, "display", as3hx.Compat.orValue(parser.data.title, "???"));
                Reflect.setField(info, "author", as3hx.Compat.orValue(parser.data.artist, "???"));
                Reflect.setField(info, "stepauthor", as3hx.Compat.orValue(parser.data.stepauthor, "???"));
                Reflect.setField(info, "difficulty", as3hx.Compat.orValue(parser.data.difficulty, 1));
                Reflect.setField(info, "arrows", parser.data.notes[DEFAULT_CHART_ID].arrows);
                Reflect.setField(info, "holds", parser.data.notes[DEFAULT_CHART_ID].holds);
                Reflect.setField(info, "mines", parser.data.notes[DEFAULT_CHART_ID].mines);
                Reflect.setField(info, "time_secs", getChartTime(DEFAULT_CHART_ID));
                Reflect.setField(info, "time", getChartTimeFormat(Reflect.field(info, "time_secs")));
                Reflect.setField(info, "music", as3hx.Compat.orValue(parser.data.music, ""));
                Reflect.setField(info, "banner", as3hx.Compat.orValue(parser.data.banner, ""));
                Reflect.setField(info, "background", as3hx.Compat.orValue(parser.data.background, ""));
                
                ID = MD5.hashBytes(CHART_BYTES);
                DATE = firstFile.modificationDate.getTime();
                
                // Folder Path
                var path                             : Dynamic= firstFile.nativePath;
                var endOfFolder                             : Dynamic= as3hx.Compat.parseInt(path.lastIndexOf(File.separator) + 1);
                Reflect.setField(info, "folder", path.substr(0, endOfFolder));
                
                // Music Validation
                if (as3hx.Compat.truthy(parser.data.music.length < 4 || parser.data.music.substr(-3).toLowerCase() != "mp3"))
                {
                    return false;
                }
                
                if (as3hx.Compat.truthy(!skipMusicLoad))
                {
                    var musicFile                             : Dynamic= firstFile.parent.resolvePath(parser.data.music);
                    
                    if (as3hx.Compat.truthy(!musicFile.exists))
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
    
    public function getParser(ext                             : Dynamic) : ChartBase
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
    
    public function readFile(file                             : Dynamic) : ByteArray
    {
        if (as3hx.Compat.truthy(!file.exists))
        {
            return null;
        }
        
        var fileStream                             : Dynamic= new FileStream();
        e_error = function(e                      : Dynamic) : Void { };
        e_error = function(e                     : Dynamic) : Void { };
        e_error = function(e                    : Dynamic) : Void { };
        e_error = function(e                   : Dynamic) : Void { };
        e_error = function(e                  : Dynamic) : Void { };
        e_error = function(e                 : Dynamic) : Void { };
        e_error = function(e                : Dynamic) : Void { };
        e_error = function(e               : Dynamic) : Void { };
        e_error = function(e              : Dynamic) : Void { };
        e_error = function(e             : Dynamic) : Void { };
        e_error = function(e            : Dynamic) : Void { };
        e_error = function(e           : Dynamic) : Void { };
        e_error = function(e          : Dynamic) : Void { };
        e_error = function(e         : Dynamic) : Void { };
        e_error = function(e        : Dynamic) : Void { };
        e_error = function(e       : Dynamic) : Void { };
        var e_error      : Dynamic= function(e      : Dynamic) : Void { };
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, e_error);
        var readData                             : Dynamic= new ByteArray();
        fileStream.open(file, FileMode.READ);
        fileStream.readBytes(readData);
        fileStream.close();
        
        return readData;
    }

    public function new()
    {
    }
}

