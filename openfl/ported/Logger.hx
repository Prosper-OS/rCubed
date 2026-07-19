import openfl.errors.Error;
import com.flashfla.utils.TimeUtil;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import r3.air.filesystem.File;
import r3.air.filesystem.FileMode;
import r3.air.filesystem.FileStream;
import openfl.system.Capabilities;

class Logger
{
    private static var LOG_FILE : File;
    private static var LOG_STREAM : FileStream;
    
    private static var DEBUG_LINES : Array<Dynamic> = ["Info: ", "Debug: ", "Warning: ", "Error: ", "Success: "];
    private static var DEBUG_COLORS : Array<Dynamic> = ["", "\u001b[1;35m", "\u001b[1;33m", "\u001b[1;31m", "\u001b[1;32m"];
    private static inline var DEBUG_COLOR_RESET : String = "\u001b[0m";
    
    public static inline var INFO : Float = 0;  // Blue  
    public static inline var DEBUG : Float = 1;  // Purple  
    public static inline var WARNING : Float = 2;  // Yellow  
    public static inline var ERROR : Float = 3;  // Red  
    public static inline var SUCCESS : Float = 4;  // Green  
    
    public static var enabled : Bool = false;
    public static var file_log : Bool = false;
    public static var history : Array<Dynamic> = [];
    
    private static var file_log_buffer : String = "";
    private static var file_log_buffer_time : Float = 0;
    
    public static function init() : Void
    // Check for special file to enable file logging.
    {
        
        if (AirContext.doesFileExist("logging.txt"))
        {
            trace("Logging Flag Found, enabling.");
            file_log = true;
            enabled = true;
        }
        
        initLogFile();
    }
    
    public static function initLogFile() : Void
    {
        if (file_log && LOG_STREAM == null)
        {
            var now : Date = Date.now();
            var filename : String = AirContext.createFileName(now.toLocaleString(), " ");
            LOG_FILE = AirContext.getAppFile("logs/" + filename + ".txt");
            LOG_STREAM = new FileStream();
            LOG_STREAM.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_logFileFail);
            LOG_STREAM.addEventListener(IOErrorEvent.IO_ERROR, e_logFileFail);
            LOG_STREAM.open(LOG_FILE, FileMode.WRITE);
            LOG_STREAM.writeUTFBytes("======================" + filename + "======================\n");
            LOG_STREAM.writeUTFBytes("OS: " + Capabilities.os + " | " + Capabilities.version + "\n");
            LOG_STREAM.writeUTFBytes("R3 Version: " + Constant.AIR_VERSION + " | " + "9999-12-31" + " | " + Main.SWF_VERSION + "\n");
            LOG_STREAM.close();
        }
        
        var e_logFileFail : Event->Void = function(e : Event) : Void
        {
            trace("Unable to use file logging.");
            LOG_STREAM.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_logFileFail);
            LOG_STREAM.removeEventListener(IOErrorEvent.IO_ERROR, e_logFileFail);
            LOG_FILE = null;
            LOG_STREAM = null;
        }
    }
    
    public static function enableLogger() : Void
    {
        file_log = true;
        enabled = true;
        initLogFile();
    }
    
    public static function divider(clazz : Dynamic) : Void
    {
        log(clazz, WARNING, "------------------------------------------------------------------------------------------------", true);
    }
    
    public static function info(clazz : Dynamic, text : Dynamic, simple : Bool = false) : Void
    {
        log(clazz, INFO, text, simple);
    }
    
    public static function debug(clazz : Dynamic, text : Dynamic, simple : Bool = false) : Void
    {
        log(clazz, DEBUG, text, simple);
    }
    
    public static function warning(clazz : Dynamic, text : Dynamic, simple : Bool = false) : Void
    {
        log(clazz, WARNING, text, simple);
    }
    
    public static function error(clazz : Dynamic, text : Dynamic, simple : Bool = false) : Void
    {
        log(clazz, ERROR, text, simple);
    }
    
    public static function success(clazz : Dynamic, text : Dynamic, simple : Bool = false) : Void
    {
        log(clazz, SUCCESS, text, simple);
    }
    
    public static function log(clazz : Dynamic, level : Int, text : Dynamic, simple : Bool = false) : Void
    // Check if Logger Enabled
    {
        
        if (!enabled)
        {
            return;
        }
        
        // Store History
        var currentTime : Float = Math.round(haxe.Timer.stamp() * 1000);
        history.push([currentTime, class_name(clazz), level, text, simple]);
        if (history.length > 250)
        {
            history.unshift();
        }
        
        // Create Log Message
        var msg : String = generate_message(text);
        
        msg = ((!(simple) ? "[" + TimeUtil.convertToHHMMSS(currentTime / 1000) + "][" + class_name(clazz) + "] " : "") + msg);
        
        // Display
        //trace(DEBUG_COLORS[level] + msg + DEBUG_COLOR_RESET); // For consoles that support color.
        trace(level + ":" + msg);
        
        if (LOG_STREAM != null)
        {
            file_log_buffer += (msg + "\n");
            
            // Buffer file writes if within the last 150ms of a write to prevent file writing bottlenecks.
            if (currentTime - file_log_buffer_time > 150)
            {
                LOG_STREAM.open(LOG_FILE, FileMode.APPEND);
                LOG_STREAM.writeUTFBytes(file_log_buffer);
                LOG_STREAM.close();
                
                file_log_buffer = "";
                file_log_buffer_time = currentTime;
            }
        }
    }
    
    public static function destroy() : Void
    {
        if (LOG_STREAM != null)
        {
            if (file_log_buffer.length > 0)
            {
                LOG_STREAM.open(LOG_FILE, FileMode.APPEND);
                LOG_STREAM.writeUTFBytes(file_log_buffer);
                LOG_STREAM.close();
            }
        }
    }
    
    public static function generate_message(text : Dynamic) : String
    {
        if (Std.is(text, Error))
        {
            return "Error: " + exception_error(try cast(text, Error) catch(e:Dynamic) null);
        }
        else if (Std.is(text, ErrorEvent))
        {
            return "Error: " + event_error(try cast(text, ErrorEvent) catch(e:Dynamic) null);
        }
        
        return text;
    }
    
    public static function exception_error(err : Error) : String
    {
        return "(" + err.errorID + ") " + err.name + "\n" + err.message + "\n" + err.getStackTrace();
    }
    
    public static function event_error(e : ErrorEvent) : String
    {
        return "(" + e.type + ") " + e.errorID + ": " + e.text;
    }
    
    public static function class_name(clazz : Dynamic) : String
    {
        if (Std.is(clazz, String))
        {
            return clazz;
        }
        var t : String = Std.string(clazz);
        return t.substr(7, t.length - 8);
    }

    public function new()
    {
    }
}

