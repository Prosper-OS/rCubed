package classes;

import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;

class Site extends EventDispatcher
{
    public static var instance(get, never) : Site;

    ///- Singleton Instance
    private static var _instance : Site = null;
    
    ///- Private Locals
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _loader : URLLoader;
    private var _isLoaded : Bool = false;
    private var _isLoading : Bool = false;
    private var _loadError : Bool = false;
    
    ///- Public Locals
    public var data : Dynamic;
    
    ///- Constructor
    public function new(en : SiteSingletonEnforcer)
    {
        super();
        if (en == null)
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    private static function get_instance() : Site
    {
        if (_instance == null)
        {
            _instance = new Site(new SiteSingletonEnforcer());
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
    
    ///- Site Loading
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
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.SITE_DATA_URL) + "?d=" + Date.now().getTime());
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        _isLoading = true;
    }
    
    private function siteLoadComplete(e : Event) : Void
    {
        Logger.info(this, "Data Loaded");
        removeLoaderListeners();
        
        // Parse Response
        var siteDataString : String = e.target.data;
        try
        {
            data = haxe.Json.parse(siteDataString);
        }
        catch (err : Error)
        {
            Logger.error(this, "Parse Failure: " + Logger.exception_error(err));
            Logger.error(this, "Wrote invalid response data to log folder. [logs/site.txt]");
            AirContext.writeTextFile(AirContext.getAppFile("logs/site.txt"), siteDataString);
            
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
            return;
        }  // Has Response  
        
        
        
        _gvars.TOTAL_GENRES = data.game_total_genres;
        _gvars.MAX_CREDITS = data.game_max_credits;
        _gvars.SCORE_PER_CREDIT = data.game_score_per_credit;
        _gvars.MAX_DIFFICULTY = data.game_max_difficulty;
        _gvars.DIFFICULTY_RANGES = data.game_difficulty_range;
        _gvars.NONPUBLIC_GENRES = data.game_nonpublic_genres;
        
        // MP Divisions
        _gvars.divisionLevels = data.division_levels;
        _gvars.divisionTitles = data.division_titles;
        _gvars.divisionColors = data.division_colors;
        
        // Tokens
        _gvars.TOKENS = { };
        var tokens : Dynamic = { };
        for (tok/* AS3HX WARNING could not determine type for var: tok exp: EField(EIdent(data),game_tokens) type: null */ in data.game_tokens)
        {
            if (Reflect.field(tokens, Std.string(tok.type)) == null)
            {
                Reflect.setField(tokens, Std.string(tok.type), []);
            }
            
            if (tok.picture != null)
            {
                tok.picture = URLs.resolve(tok.picture);
            }
            
            Reflect.setField(Reflect.field(tokens, Std.string(tok.type)), Std.string(tok.id), tok);
            
            if (tok.level)
            {
                _gvars.TOKENS[tok.level] = tok;
            }
        }
        _gvars.TOKENS_TYPE = tokens;
        
        _isLoaded = true;
        _loadError = false;
        Logger.info(this, "Parse Complete");
        this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
    }
    
    private function siteLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Load Failure: " + Logger.event_error(err));
        _loadError = true;
        removeLoaderListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, siteLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _isLoading = false;
        _loader.removeEventListener(Event.COMPLETE, siteLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
    }
}


class SiteSingletonEnforcer
{

    public function new()
    {
    }
}
