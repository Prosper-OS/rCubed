package classes;

import openfl.errors.Error;
import arc.ArcGlobals;
import classes.chart.parse.ChartFFRLegacy;
import com.flashfla.utils.ArrayUtil;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import menu.MainMenu;
import menu.MenuSongSelection;

class Playlist extends EventDispatcher
{
    public static var instanceCanon(get, never) : Playlist;
    public static var instance(get, never) : Playlist;

    ///- Singleton Instance
    private static var _instance : Playlist = null;
    private static var _instanceCanon : Playlist = null;
    
    ///- Private Locals
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    private var _loader : URLLoader;
    private var _isLoaded : Bool = false;
    private var _isLoading : Bool = false;
    private var _loadError : Bool = false;
    
    ///- Public Locals
    public var generatedQueues : Array<Dynamic>;
    public var genreList : Array<Dynamic>;
    public var playList : Array<Dynamic>;
    public var indexList : Array<SongInfo>;
    public var engine : Dynamic;
    
    ///- Constructor
    public function new()
    {
        super();
    }
    
    public static function clearCanon() : Void
    {
        _instanceCanon = null;
    }
    
    private static function get_instanceCanon() : Playlist
    {
        return _instanceCanon;
    }
    
    private static function get_instance() : Playlist
    {
        if (_instance == null)
        {
            _instance = new Playlist();
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
    
    ///- Playlist Loading
    public function load() : Void
    // Kill old Loading Stream
    {
        
        if (_loader != null && _isLoading)
        {
            removeLoaderListeners();
            _loader.close();
        }
        
        // Load New
        var time : Float = Date.now().getTime();
        _isLoaded = false;
        _loadError = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        if (ArcGlobals.instance.configLegacy)
        {
            var url : String = ArcGlobals.instance.configLegacy.playlistURL;
            engine = ArcGlobals.instance.configLegacy;
            _loader.load(new URLRequest(url + (url.indexOf("?") == -(1) ? "?d=" + time : "&d=" + time)));
            _isLoading = true;
        }
        else if (_instanceCanon != null)
        {
            engine = null;
            this._isLoaded = _instanceCanon._isLoaded;
            this._loadError = _instanceCanon._loadError;
            genreList = _instanceCanon.genreList;
            playList = _instanceCanon.playList;
            indexList = _instanceCanon.indexList;
            generatedQueues = _instanceCanon.generatedQueues;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
        else
        {
            engine = null;
            var req : URLRequest = new URLRequest(URLs.resolve(URLs.SITE_PLAYLIST_URL) + "?d=" + time);
            var requestVars : URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
            _isLoading = true;
        }
    }
    
    private function playlistLoadComplete(e : Event) : Void
    {
        removeLoaderListeners();
        var data : Dynamic;
        var legacy : Bool = ArcGlobals.instance.configLegacy;
        try
        {
            if (legacy)
            {
                data = ChartFFRLegacy.parsePlaylist(e.target.data);
            }
            else
            {
                data = haxe.Json.parse(e.target.data);
                _gvars.TOTAL_PUBLIC_SONGS = 0;
            }
        }
        catch (e : Error)
        {
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
            return;
        }
        generatedQueues = [];
        genreList = [];
        playList = [];
        indexList = [];
        
        if (_instanceCanon == null && !legacy)
        {
            _instanceCanon = new Playlist();
            _instanceCanon._isLoaded = true;
            _instanceCanon.genreList = genreList;
            _instanceCanon.playList = playList;
            _instanceCanon.indexList = indexList;
            _instanceCanon.generatedQueues = generatedQueues;
        }
        
        for (dynamicSongInfo/* AS3HX WARNING could not determine type for var: dynamicSongInfo exp: EIdent(data) type: Dynamic */ in data)
        {
            var songInfo : SongInfo;
            
            if (Std.is(dynamicSongInfo, SongInfo))
            {
                songInfo = try cast(dynamicSongInfo, SongInfo) catch(e:Dynamic) null;
                
                if (genreList[songInfo.genre] == null)
                {
                    genreList[songInfo.genre] = [];
                    generatedQueues[songInfo.genre] = [];
                }
            }
            else
            {
                var genre : Int = dynamicSongInfo.genre;
                if (genreList[genre] == null)
                {
                    genreList[genre] = [];
                    generatedQueues[genre] = [];
                }
                
                // Important to note that the dynamic fields aren't all exactly the same name
                var newSongInfo : SongInfo = new SongInfo();
                newSongInfo.level = dynamicSongInfo.level;
                newSongInfo.level_id = dynamicSongInfo.level;
                
                newSongInfo.name = dynamicSongInfo.name;
                newSongInfo.name_original = dynamicSongInfo.name_original;  // Optional  
                newSongInfo.name_explicit = dynamicSongInfo.name_explicit;  // Optional  
                newSongInfo.subtitle = dynamicSongInfo.subtitle;  // Optional  
                
                newSongInfo.author = dynamicSongInfo.author;
                newSongInfo.author_original = dynamicSongInfo.author_original;  // Optional  
                newSongInfo.author_url = dynamicSongInfo.authorURL;
                
                newSongInfo.stepauthor = dynamicSongInfo.stepauthor;
                
                newSongInfo.genre = dynamicSongInfo.genre;
                newSongInfo.difficulty = dynamicSongInfo.difficulty;
                newSongInfo.style = dynamicSongInfo.style;
                newSongInfo.tags = dynamicSongInfo.tags;  // Optional  
                newSongInfo.time = dynamicSongInfo.time;
                newSongInfo.note_count = dynamicSongInfo.arrows;
                newSongInfo.order = dynamicSongInfo.order;
                newSongInfo.release_date = dynamicSongInfo.date;
                newSongInfo.prerelease = dynamicSongInfo.prerelease;
                newSongInfo.play_hash = dynamicSongInfo.playhash;
                newSongInfo.time_end = dynamicSongInfo.end_delay;
                newSongInfo.song_rating = dynamicSongInfo.song_rating;
                
                newSongInfo.price = dynamicSongInfo.price;
                newSongInfo.credits = dynamicSongInfo.credits;
                
                newSongInfo.min_nps = dynamicSongInfo.min_nps;
                newSongInfo.max_nps = dynamicSongInfo.max_nps;
                
                newSongInfo.is_legacy = dynamicSongInfo.o_legacy == 1;
                newSongInfo.is_unranked = dynamicSongInfo.o_unranked == 1;
                newSongInfo.is_explicit = dynamicSongInfo.o_explicit == 1;
                newSongInfo.is_disabled = dynamicSongInfo.o_disabled == 1;
                
                newSongInfo.swf_hash = dynamicSongInfo.swfhash;
                newSongInfo.background = dynamicSongInfo.background;
                
                songInfo = newSongInfo;
            }
            
            // Song Time
            if (songInfo.time == null)
            {
                songInfo.time = "0:00";
            }
            
            // Note Count
            if (Math.isNaN(as3hx.Compat.parseFloat(songInfo.note_count)))
            {
                songInfo.note_count = 0;
            }
            
            // Time End
            if (Math.isNaN(as3hx.Compat.parseFloat(songInfo.time_end)))
            {
                songInfo.time_end = 0;
            }
            
            // Extra Info
            songInfo.index = genreList[songInfo.genre].length;
            songInfo.time_secs = (as3hx.Compat.parseFloat(songInfo.time.split(":")[0]) * 60) + as3hx.Compat.parseFloat(songInfo.time.split(":")[1]);
            
            // Author with URL
            if (songInfo.author_url != null && songInfo.author_url.length > 7)
            {
                songInfo.author_html = "<a href=\"" + songInfo.author_url + "\">" + songInfo.author + "</a>";
            }
            else
            {
                songInfo.author_html = songInfo.author;
            }
            
            // Multiple Step Authors
            if (songInfo.stepauthor != null && songInfo.stepauthor.indexOf(" & ") != false)
            {
                var stepAuthors : Array<Dynamic> = songInfo.stepauthor.split(" & ");
                songInfo.stepauthor_html = "<a href=\"" + URLs.BASE_PATH + "profile/" + escape(stepAuthors[0]) + "\">" + stepAuthors[0] + "</a>";
                
                for (i in 1...stepAuthors.length)
                {
                    songInfo.stepauthor_html += " & <a href=\"" + URLs.BASE_PATH + "profile/" + escape(stepAuthors[i]) + "\">" + stepAuthors[i] + "</a>";
                }
            }
            else
            {
                songInfo.stepauthor_html = "<a href=\"" + URLs.BASE_PATH + "profile/" + escape(songInfo.stepauthor) + "\">" + songInfo.stepauthor + "</a>";
            }
            
            // Song Price
            if (Math.isNaN(as3hx.Compat.parseFloat(songInfo.price)))
            {
                songInfo.price = -1;
            }
            
            // Secret Credits
            if (Math.isNaN(as3hx.Compat.parseFloat(songInfo.credits)))
            {
                songInfo.credits = -1;
            }
            
            // Max Score Totals
            songInfo.score_total = songInfo.note_count * 1550;
            songInfo.score_raw = songInfo.note_count * 50;
            
            // Legacy Sync
            if (!legacy && Math.isNaN(songInfo.sync))
            {
                songInfo.sync = oldOffsets(songInfo.level);
            }
            
            // Add to lists
            playList[songInfo.level] = songInfo;
            indexList.push(songInfo);
            genreList[songInfo.genre].push(songInfo);
            generatedQueues[songInfo.genre].push(songInfo.level);
        }
        indexList.sort(compareSongLevel);
        _isLoaded = true;
        _loadError = false;
        this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
    }
    
    private function compareSongLevel(songInfo1 : SongInfo, songInfo2 : SongInfo) : Float
    {
        if (songInfo1.level < songInfo2.level)
        {
            return -1;
        }
        else if (songInfo1.level > songInfo2.level)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    
    private function playlistLoadError(e : ErrorEvent = null) : Void
    {
        Logger.error(this, "Load Failure: " + Logger.event_error(e));
        removeLoaderListeners();
        _loadError = true;
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, playlistLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, playlistLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, playlistLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _isLoading = false;
        _loader.removeEventListener(Event.COMPLETE, playlistLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, playlistLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, playlistLoadError);
    }
    
    public function getSongInfo(genre : Int, index : Int = -1) : SongInfo
    // Returns the indexed song for the All genre
    {
        
        if (genre <= -1 && index >= 0 && index < indexList.length && indexList[index] != null)
        {
            return indexList[index];
        }
        // If a index is set, use the genre list to get the correct song.
        else if (index >= 0 && genreList[genre] != null && genreList[genre][index] != null)
        {
            return genreList[genre][index];
        }
        // Return the song from the playlist, using the levelid as the default.
        else if (playList[genre] != null)
        {
            return playList[genre];
        }
        
        return null;
    }
    
    public function updateSongAccess() : Void
    {
        var songType : Int = 0;
        for (i in 0...indexList.length)
        {
            songType = 0;
            
            if (indexList[i].engine == null && _gvars.TOKENS[indexList[i].level] != null)
            {
                songType = 1;
            }
            if (indexList[i].price > 0)
            {
                songType = 2;
            }
            if (indexList[i].credits > 0)
            {
                songType = 3;
            }
            
            indexList[i].access = _gvars.checkSongAccess(indexList[i]);
            indexList[i].song_type = songType;
        }
    }
    
    public function updatePublicSongsCount() : Void
    {
        var s : Site = Site.instance;
        _gvars.TOTAL_SONGS = indexList.length;
        _gvars.TOTAL_PUBLIC_SONGS = indexList.filter(function(item : SongInfo, index : Int, vec : Array<SongInfo>) : Bool
                        {
                            return !ArrayUtil.in_array([item.genre], _gvars.NONPUBLIC_GENRES);
                        }).length;
    }
    
    public function engineChangeHandler(e : Event) : Void
    {
        removeEventListener(GlobalVariables.LOAD_COMPLETE, engineChangeHandler);
        removeEventListener(GlobalVariables.LOAD_ERROR, engineChangeHandler);
        var _sw0_ = (e.type);        

        switch (_sw0_)
        {
            case GlobalVariables.LOAD_ERROR:
                ArcGlobals.instance.configLegacy = null;
                load();
                Alert.add(_lang.string("error_loading_playlist"));
            case GlobalVariables.LOAD_COMPLETE:
                if (Std.is(_gvars.gameMain.activePanel, MainMenu))
                {
                    var mainmenu : MainMenu = try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null;
                    if (mainmenu != null && mainmenu._MenuSingleplayer != null)
                    {
                        var reload : Bool = false;
                        if (mainmenu.panel == mainmenu._MenuSingleplayer)
                        {
                            reload = true;
                        }
                        mainmenu._MenuSingleplayer = null;
                        if (reload)
                        {
                            MenuSongSelection.options.pageNumber = 0;
                            MenuSongSelection.options.scroll_position = 0;
                            mainmenu.switchTo(MainMenu.MENU_SONGSELECTION);
                        }
                        _gvars.removeSongFiles();
                    }
                }
        }
    }
    
    private function oldOffsets(lvlid : Int) : Int
    {
        switch (lvlid)
        {
            case 87, 88:
                return -10;
            case 68, 28, 25, 24, 21, 20:
                return 0;
            case 37:
                return 6;
            case 23:
                return -2;
            case 22:
                return 3;
            case 19:
                return -4;
            case 17:
                return 1;
            case 1883:
                return -21;
            default:
                return (lvlid <= 29) ? -6 : 0;
        }
    }
}

