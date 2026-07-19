import openfl.errors.Error;
import classes.Alert;
import classes.Language;
import com.flashfla.utils.NumberUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class Updater
{
    private static var _lang : Language = Language.instance;
    private static var didUpdate : Bool = false;
    
    public static function handle(siteVersion : String, updateURL : String) : Void
    {
        if (siteVersion == null || updateURL == null || didUpdate || skipUpdate())
        {
            return;
        }
        
        // Only Update check once
        didUpdate = true;
        
        var airUpdateCheck : Int = compareVersions(siteVersion);
        
        // No Update
        if (airUpdateCheck >= 0)
        {
            return;
        }
        
        //Alert.add(siteVersion + " " + (airUpdateCheck == -1 ? "&gt;" : (airUpdateCheck == 1 ? "&lt;" : "==")) + " " + Constant.AIR_VERSION, 240);
        
        var swfDownload : URLLoader = new URLLoader();
        swfDownload.dataFormat = URLLoaderDataFormat.BINARY;
        swfDownload.addEventListener(Event.COMPLETE, e_onComplete);
        swfDownload.addEventListener(IOErrorEvent.IO_ERROR, e_onError);
        swfDownload.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_onError);
        swfDownload.load(new URLRequest(URLs.resolve(updateURL)));
        
        var e_onComplete : Event->Void = function(e : Event) : Void
        {
            e_removeEvents();
            var data : ByteArray = e.target.data;
            Logger.info("Updater", "Game Download Finished [" + NumberUtil.bytesToString(data.length) + "]");
            
            try
            {
                AirContext.writeFile(Main.SWF_FILE, data, 0, e_writeError);
                Alert.add(sprintf(_lang.string("air_game_update_complete"), {
                                    old : Constant.AIR_VERSION,
                                    "new" : siteVersion
                                }), 240, Alert.DARK_GREEN);
            }
            catch (e : Error)
            {
                Logger.error("Updater", "Update SWF Write Exception Error:" + Logger.exception_error(e));
                Alert.add(_lang.string("air_game_update_error"), 240, Alert.RED);
            }
        }
        
        var e_onError : ErrorEvent->Void = function(e : ErrorEvent) : Void
        {
            e_removeEvents();
            Logger.error("Updater", "SWF Download Error:" + Logger.event_error(e));
            Alert.add(_lang.string("air_game_update_error"), 240, Alert.RED);
        }
        
        var e_writeError : ErrorEvent->Void = function(e : ErrorEvent) : Void
        {
            Logger.error("Updater", "Update SWF Write Error Event:" + Logger.event_error(e));
            Alert.add(_lang.string("air_game_update_error"), 240, Alert.RED);
        }
        
        var e_removeEvents : Void->Void = function() : Void
        {
            swfDownload.removeEventListener(Event.COMPLETE, e_onComplete);
            swfDownload.removeEventListener(IOErrorEvent.IO_ERROR, e_onError);
            swfDownload.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_onError);
        }
    }
    
    public static function compareVersions(serverVersionString : String) : Int
    {
        var gameVersion : Array<Dynamic> = Constant.AIR_VERSION.split(".").map(function(item : Dynamic, index : Int, array : Array<Dynamic>) : Int
                {
                    return as3hx.Compat.parseInt(item);
                });
        
        var serverVersion : Array<Dynamic> = serverVersionString.split(".").map(function(item : Dynamic, index : Int, array : Array<Dynamic>) : Int
                {
                    return as3hx.Compat.parseInt(item);
                });
        
        var length : Int = Math.max(gameVersion.length, serverVersion.length);
        for (i in 0...length)
        {
            var thisPart : Int = (i < gameVersion.length) ? gameVersion[i] : 0;
            var thatPart : Int = (i < serverVersion.length) ? serverVersion[i] : 0;
            
            if (thisPart < thatPart)
            {
                return -1;
            }
            if (thisPart > thatPart)
            {
                return 1;
            }
        }
        return 0;
    }
    
    private static function skipUpdate() : Bool
    {
        return AirContext.doesFileExist("skip_update.txt") || false;
    }

    public function new()
    {
    }
}

