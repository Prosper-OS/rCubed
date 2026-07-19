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
    private static var _lang                              : Dynamic= Language.instance;
    private static var didUpdate                              : Dynamic= false;
    
    public static function handle(siteVersion                              : Dynamic, updateURL                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(siteVersion == null || updateURL == null || didUpdate || skipUpdate()))
        {
            return;
        }
        
        // Only Update check once
        didUpdate = true;
        
        var airUpdateCheck                              : Dynamic= compareVersions(siteVersion);
        
        // No Update
        if (as3hx.Compat.truthy(airUpdateCheck >= 0))
        {
            return;
        }
        
        //Alert.add(siteVersion + " " + (airUpdateCheck == -1 ? "&gt;" : (airUpdateCheck == 1 ? "&lt;" : "==")) + " " + Constant.AIR_VERSION, 240);
        var e_onComplete            : Dynamic= null;
        var e_onError            : Dynamic= null;
        var e_writeError            : Dynamic= null;
        var e_removeEvents            : Dynamic= null;
        var swfDownload            : Dynamic= new URLLoader();
        swfDownload.dataFormat = URLLoaderDataFormat.BINARY;
        swfDownload.addEventListener(Event.COMPLETE, e_onComplete);
        swfDownload.addEventListener(IOErrorEvent.IO_ERROR, e_onError);
        swfDownload.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_onError);
        swfDownload.load(new URLRequest(URLs.resolve(updateURL)));
        
        e_onComplete = function(e                            : Dynamic) : Void
        {
            e_removeEvents();
            var data                              : Dynamic= e.target.data;
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
        
        e_onError = function(e                            : Dynamic) : Void
        {
            e_removeEvents();
            Logger.error("Updater", "SWF Download Error:" + Logger.event_error(e));
            Alert.add(_lang.string("air_game_update_error"), 240, Alert.RED);
        }
        
        e_writeError = function(e                            : Dynamic) : Void
        {
            Logger.error("Updater", "Update SWF Write Error Event:" + Logger.event_error(e));
            Alert.add(_lang.string("air_game_update_error"), 240, Alert.RED);
        }
        
        e_removeEvents = function() : Void
        {
            swfDownload.removeEventListener(Event.COMPLETE, e_onComplete);
            swfDownload.removeEventListener(IOErrorEvent.IO_ERROR, e_onError);
            swfDownload.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_onError);
        }
    }
    
    public static function compareVersions(serverVersionString                              : Dynamic) : Int
    {
        var gameVersion                              : Dynamic= Constant.AIR_VERSION.split(".").map(function(item                              : Dynamic, index                              : Dynamic, array                              : Dynamic) : Int
                {
                    return as3hx.Compat.parseInt(item);
                });
        
        var serverVersion                              : Dynamic= serverVersionString.split(".").map(function(item                              : Dynamic, index                              : Dynamic, array                              : Dynamic) : Int
                {
                    return as3hx.Compat.parseInt(item);
                });
        
        var length                              : Dynamic= Math.max(gameVersion.length, serverVersion.length);
        for (i in 0...length)
        {
            var thisPart                              : Dynamic= (i < gameVersion.length) ? gameVersion[i] : 0;
            var thatPart                              : Dynamic= (i < serverVersion.length) ? serverVersion[i] : 0;
            
            if (as3hx.Compat.truthy(thisPart < thatPart))
            {
                return -1;
            }
            if (as3hx.Compat.truthy(thisPart > thatPart))
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

