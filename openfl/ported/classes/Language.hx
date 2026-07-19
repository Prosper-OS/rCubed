package classes;

import openfl.errors.Error;
import classes.ui.Text;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class Language extends EventDispatcher
{
    public static var instance(get, never) : Language;

    ///- Singleton Instance
    private static var _instance : Language = null;
    
    ///- Private Locals
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _loader : URLLoader;
    private var _isLoaded : Bool = false;
    private var _isLoading : Bool = false;
    private var _loadError : Bool = false;
    
    public var data : Dynamic;
    public var indexed : Array<Dynamic>;
    
    ///- Constructor
    public function new(en : LanguageSingletonEnforcer)
    {
        super();
        if (en == null)
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    private static function get_instance() : Language
    {
        if (_instance == null)
        {
            _instance = new Language(new LanguageSingletonEnforcer());
        }
        
        return _instance;
    }
    
    public function isLoaded() : Bool
    {
        return _isLoaded && !_loadError;
    }
    
    public function isError() : Bool
    {
        return _loadError;
    }
    
    ///- Public Functions
    public function font(testStr : String = "") : String
    {
        return (Text.isUnicode(testStr)) ? Fonts.BASE_FONT_CJK : Fonts.BASE_FONT;
    }
    
    public function wrapFont(text : String) : String
    {
        return "<font face=\"" + font(text) + "\">" + text + "</font>";
    }
    
    public function string(id : String) : String
    {
        return string2(id, (_gvars.playerUser) ? _gvars.playerUser.language : "us");
    }
    
    public function string2(id : String, lang : String) : String
    // Get Text
    {
        
        var text : String = id;
        if (data == null)
        {
        }
        else if (Reflect.field(data, lang) != null && Reflect.field(Reflect.field(data, lang), id) != null)
        {
            text = Reflect.field(Reflect.field(data, lang), id);
        }
        else if (Reflect.field(Reflect.field(data, "us"), id) != null)
        {
            text = Reflect.field(Reflect.field(data, "us"), id);
        }
        if (data != null && text == id)
        {
            trace(id);
        }
        return wrapFont(text);
    }
    
    public function stringSimple(id : String) : String
    {
        return string2Simple(id, (_gvars.playerUser) ? _gvars.playerUser.language : "us");
    }
    
    public function string2Simple(id : String, lang : String) : String
    // Get Text
    {
        
        var text : String = id;
        if (data == null)
        {
        }
        else if (Reflect.field(data, lang) != null && Reflect.field(Reflect.field(data, lang), id) != null)
        {
            text = Reflect.field(Reflect.field(data, lang), id);
        }
        else if (Reflect.field(Reflect.field(data, "us"), id) != null)
        {
            text = Reflect.field(Reflect.field(data, "us"), id);
        }
        if (data != null && text == id)
        {
            trace(id);
        }
        return text;
    }
    
    ///- Language Loading
    public function load() : Void
    // Kill old Loading Stream
    {
        
        if (_loader != null && _isLoading)
        {
            removeLoaderListeners();
            _loader.close();
        }
        
        // Load New
        _isLoaded = false;
        _loadError = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.SITE_LANGUAGE_URL) + "?d=" + Date.now().getTime());
        _loader.load(req);
        _isLoading = true;
    }
    
    private function languageLoadComplete(e : Event) : Void
    {
        Logger.info(this, "Data Loaded");
        removeLoaderListeners();
        
        // Parse Response
        var siteDataString : String = e.target.data;
        try
        {
            var xmlMain : FastXML = new FastXML(siteDataString);
            var xmlChildren : FastXMLList = xmlMain.node.children.innerData();
        }
        catch (err : Error)
        {
            Logger.error(this, "Parse Failure: " + Logger.exception_error(err));
            Logger.error(this, "Wrote invalid response data to log folder. [logs/language.txt]");
            AirContext.writeTextFile(AirContext.getAppFile("logs/language.txt"), siteDataString);
            
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
            return;
        }  // Has Response  
        
        
        
        data = {};
        indexed = new Array<Dynamic>();
        
        for (a in 0...xmlChildren.length()) {
var lang : String = Std.string(xmlChildren[a].attribute("id"));
            if (Reflect.field(data, lang) == null)
            {
                Reflect.setField(data, lang, {});
            }
            
            // Add Attributes to Object
            var langAttr : FastXMLList = xmlChildren[a].attributes();
            for (b in 0...langAttr.length())
            {
                Reflect.setField(Reflect.field(data, lang), Std.string("_" + langAttr.get(b).node.name.innerData()), langAttr.get(b).node.name.innerData());
            }
            
            // Add Text to Object
            var langNodes : FastXMLList = xmlChildren[a].children();
            for (c in 0...langNodes.length())
            {
                Reflect.setField(Reflect.field(data, lang), Std.string(Std.string(langNodes.get(c).node.attribute.innerData("id"))), Std.string(langNodes.get(c).node.children.innerData()[0]).replace(new as3hx.Compat.Regex('\\r\\n', "gi"), "\n"));
            }
            Reflect.setField(indexed, Std.string(Reflect.field(Reflect.field(data, lang), "_index")), lang);
        }
        
        _isLoaded = true;
        _loadError = false;
        Logger.info(this, "Parse Complete");
        checkCompleteLoad();
    }
    
    private function checkCompleteLoad() : Void
    {
        if (isLoaded())
        {
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
    }
    
    private function languageLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Load Failure: " + Logger.event_error(err));
        removeLoaderListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, languageLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, languageLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, languageLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _loadError = true;
        _loader.removeEventListener(Event.COMPLETE, languageLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, languageLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, languageLoadError);
    }
}



class LanguageSingletonEnforcer
{

    public function new()
    {
    }
}
