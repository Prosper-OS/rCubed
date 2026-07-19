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
    public static var instance(get, never)                              : Dynamic;

    ///- Singleton Instance
    private static var _instance                              : Dynamic= null;
    
    ///- Private Locals
    private var _gvars                              : Dynamic= GlobalVariables.instance;
    private var _loader                              : Dynamic;
    private var _isLoaded                              : Dynamic= false;
    private var _isLoading                              : Dynamic= false;
    private var _loadError                              : Dynamic= false;
    
    public var data                              : Dynamic;
    public var indexed                              : Dynamic;
    
    ///- Constructor
    public function new(en                              : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(en == null))
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    private static function get_instance() : Language
    {
        if (as3hx.Compat.truthy(_instance == null))
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
    public function font(testStr                              : Dynamic= "") : String
    {
        return (Text.isUnicode(testStr)) ? Fonts.BASE_FONT_CJK : Fonts.BASE_FONT;
    }
    
    public function wrapFont(text                              : Dynamic) : String
    {
        return "<font face=\"" + font(text) + "\">" + text + "</font>";
    }
    
    public function string(id                              : Dynamic) : String
    {
        return string2(id, (_gvars.playerUser) ? _gvars.playerUser.language : "us");
    }
    
    public function string2(id                              : Dynamic, lang                              : Dynamic) : String
    // Get Text
    {
        
        var text                              : Dynamic= id;
        if (as3hx.Compat.truthy(data == null))
        {
        }
        else if (as3hx.Compat.truthy(Reflect.field(data, lang) != null && Reflect.field(Reflect.field(data, lang), id) != null))
        {
            text = Reflect.field(Reflect.field(data, lang), id);
        }
        else if (as3hx.Compat.truthy(Reflect.field(Reflect.field(data, "us"), id) != null))
        {
            text = Reflect.field(Reflect.field(data, "us"), id);
        }
        if (as3hx.Compat.truthy(data != null && text == id))
        {
            trace(id);
        }
        return wrapFont(text);
    }
    
    public function stringSimple(id                              : Dynamic) : String
    {
        return string2Simple(id, (_gvars.playerUser) ? _gvars.playerUser.language : "us");
    }
    
    public function string2Simple(id                              : Dynamic, lang                              : Dynamic) : String
    // Get Text
    {
        
        var text                              : Dynamic= id;
        if (as3hx.Compat.truthy(data == null))
        {
        }
        else if (as3hx.Compat.truthy(Reflect.field(data, lang) != null && Reflect.field(Reflect.field(data, lang), id) != null))
        {
            text = Reflect.field(Reflect.field(data, lang), id);
        }
        else if (as3hx.Compat.truthy(Reflect.field(Reflect.field(data, "us"), id) != null))
        {
            text = Reflect.field(Reflect.field(data, "us"), id);
        }
        if (as3hx.Compat.truthy(data != null && text == id))
        {
            trace(id);
        }
        return text;
    }
    
    ///- Language Loading
    public function load() : Void
    // Kill old Loading Stream
    {
        
        if (as3hx.Compat.truthy(_loader != null && _isLoading))
        {
            removeLoaderListeners();
            _loader.close();
        }
        
        // Load New
        _isLoaded = false;
        _loadError = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                              : Dynamic= new URLRequest(URLs.resolve(URLs.SITE_LANGUAGE_URL) + "?d=" + Date.now().getTime());
        _loader.load(req);
        _isLoading = true;
    }
    
    private function languageLoadComplete(e                              : Dynamic) : Void
    {
        Logger.info(this, "Data Loaded");
        removeLoaderListeners();
        
        // Parse Response
        var siteDataString                              : Dynamic= e.target.data;
        var xmlChildren                              : Dynamic= null;
        try
        {
            var xmlMain                              : Dynamic= new FastXML(siteDataString);
            xmlChildren = xmlMain.node.children.innerData();
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
var lang                              : Dynamic= Std.string(xmlChildren[a].attribute("id"));
            if (as3hx.Compat.truthy(Reflect.field(data, lang) == null))
            {
                Reflect.setField(data, lang, {});
            }
            
            // Add Attributes to Object
            var langAttr                              : Dynamic= xmlChildren[a].attributes();
            for (b in 0...langAttr.length())
            {
                Reflect.setField(Reflect.field(data, lang), Std.string("_" + langAttr.get(b).node.name.innerData()), langAttr.get(b).node.name.innerData());
            }
            
            // Add Text to Object
            var langNodes                              : Dynamic= xmlChildren[a].children();
            for (c in 0...langNodes.length())
            {
                Reflect.setField(Reflect.field(data, lang), Std.string(Std.string(langNodes.get(c).node.attribute.innerData("id"))), new as3hx.Compat.Regex('\\r\\n', "gi").replace(Std.string(langNodes.get(c).node.children.innerData()[0]), "\n"));
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
        if (as3hx.Compat.truthy(isLoaded()))
        {
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
    }
    
    private function languageLoadError(err                              : Dynamic= null) : Void
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
