import openfl.errors.Error;
import be.aboutme.airserver.AIRServer;
import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
import be.aboutme.airserver.messages.Message;
import classes.Playlist;
import classes.SongInfo;
import classes.SongPlayerBytes;
import classes.StatTracker;
import classes.User;
import classes.chart.Song;
import classes.filter.EngineLevelFilter;
import classes.mp.Multiplayer;
import classes.user.UserSongNotes;
import com.flashfla.loader.DataEvent;
import com.flashfla.net.DynamicURLLoader;
import com.flashfla.utils.Crypt;
import com.flashfla.utils.Screenshots;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import r3.air.filesystem.File;
import openfl.media.SoundTransform;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.system.Capabilities;
import openfl.utils.ByteArray;
import game.GameMenu;
import game.GameOptions;
import game.GameScoreResult;

class GlobalVariables extends EventDispatcher
{
    public static var instance(get, never) : GlobalVariables;

    ///- Singleton Instance
    private static var _instance : GlobalVariables = null;
    private var _loader : DynamicURLLoader;
    
    ///- Constants
    public static inline var LOAD_COMPLETE : String = "LoadComplete";
    public static inline var LOAD_ERROR : String = "LoadError";
    public static inline var HIGHSCORES_LOAD_COMPLETE : String = "HighscoresLoadComplete";
    public static inline var HIGHSCORES_LOAD_ERROR : String = "HighscoresLoadError";
    
    public var gameMain : Main;
    
    public var options : GameOptions;
    
    ///- Game Data
    public var TOTAL_GENRES : Int = 13;
    public var TOTAL_SONGS : Int = 0;
    public var TOTAL_PUBLIC_SONGS : Int = 0;
    public var HEALTH_JUDGE_ADD : Int = 5;
    public var HEALTH_JUDGE_REMOVE : Int = -5;
    public var TOTAL_STEPS : Int = 31;
    public var BEAT_DELAY : Int = -31;
    public var MAX_CREDITS : Int = 120;
    public var SCORE_PER_CREDIT : Int = 50000;
    public var MAX_DIFFICULTY : Int = 120;
    public var DIFFICULTY_RANGES : Array<Dynamic> = [[1, 120]];
    public var NONPUBLIC_GENRES : Array<Dynamic> = [];
    public var TOKENS : Dynamic = { };
    public var TOKENS_TYPE : Dynamic = { };
    public var SCROLL_DIRECTIONS : Array<Dynamic> = ["up", "down", "left", "right", "split", "split_down", "plus"];
    public var GAME_MODS : Array<Dynamic> = ["hidden", "sudden", "blink", "----", "rotating", "rotate_cw", "rotate_ccw", "wave", "drunk", "tornado", "mini_resize", "tap_pulse", "----", "random", "scramble", "shuffle", "reverse"];
    public var VISUAL_MODS : Array<Dynamic> = ["mirror", "dark", "hide", "mini", "columncolour", "halftime", "----", "nobackground"];
    public var songStartTime : String = "0";
    public var songStartHash : String = "0";
    public var songCache : Array<Song> = [];
    public var songHighscores : Dynamic = { };
    
    public var divisionColors : Array<Dynamic> = ["#C27BA0", "#8E7CC3", "#6D9EEB", "#93C47D", "#CEA023", "#E06666", "#919C86", "#D2C7AC", "#7B738A", "#BF0000"];
    public var divisionTitles : Array<Dynamic> = ["Novice", "Intermediate", "Advanced", "Expert", "Master", "Guru", "Legendary", "Godly", "Mythical", "Developer"];
    public var divisionLevels : Array<Dynamic> = [0, 24, 42, 58, 72, 84, 94, 102, 108, 120];
    
    ///- User Vars
    public var userSession : String = "0";
    public var activeUser : User;
    public var playerUser : User;
    
    ///- GamePlay
    public var songQueue : Array<Dynamic> = [];
    public var totalSongQueue : Array<Dynamic> = [];
    public var gameIndex : Int = 0;
    public var replayHistory : Array<Dynamic> = [];
    public var songResults : Array<GameScoreResult> = [];
    public var songResultRanks : Array<Dynamic> = [];
    public var songRestarts : Int;
    public var activeFilter : EngineLevelFilter;
    
    ///- Session Stats
    public var sessionStats : StatTracker = new StatTracker();
    public var songStats : StatTracker = new StatTracker();
    
    public var menuMusic : SongPlayerBytes;
    public var menuMusicSoundVolume : Float = 1;
    public var menuMusicSoundTransform : SoundTransform = new SoundTransform();
    
    ///- Air Options
    public var air_useLocalFileCache : Bool = false;
    public var air_autoSaveLocalReplays : Bool = false;
    public var air_useVSync : Bool = true;
    public var air_useWebsockets : Bool = false;
    public var air_saveWindowPosition : Bool = false;
    public var air_saveWindowSize : Bool = false;
    public var air_useFullScreen : Bool = false;
    
    public var air_windowProperties : Dynamic;
    public var file_replay_cache : FileCache = new FileCache("replays/cache.json", 1);
    
    ///- Song Loader
    public var externalSongInfo : SongInfo;
    public var externalSong : Song;
    
    private var websocket_server : AIRServer;
    private static var websocket_message : Message = new Message();
    
    ///- Constructor
    public function new(en : GlobalVariablesSingletonEnforcer)
    {
        super();
        if (en == null)
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    public function loadAirOptions() : Void
    {
        var sessionToken : String = LocalStore.getVariable("uSessionToken", "");
        if (sessionToken != "")
        {
            userSession = Crypt.Decode(sessionToken);
        }
        
        air_useVSync = LocalOptions.getVariable("vsync", false);
        air_useLocalFileCache = LocalOptions.getVariable("use_local_file_cache", true);
        air_autoSaveLocalReplays = LocalOptions.getVariable("auto_save_local_replays", true);
        air_useWebsockets = LocalOptions.getVariable("use_websockets", false);
        air_saveWindowPosition = LocalOptions.getVariable("save_window_position", false);
        air_saveWindowSize = LocalOptions.getVariable("save_window_size", false);
        air_useFullScreen = LocalOptions.getVariable("save_usefullscreen", false);
        
        air_windowProperties = LocalOptions.getVariable("window_properties", {
                            x : 0,
                            y : 0,
                            width : 0,
                            height : 0
                        });
        
        if (air_useWebsockets)
        {
            initWebsocketServer();
        }
    }
    
    public function loadUserSongData() : Void
    // Export SQL to JSON
    {
        
        var db_name : String = "dbinfo/" + ((activeUser != null && activeUser.siteId > 0) ? activeUser.siteId : "0") + "_info.";
        var json_file : File = AirContext.getAppFile(db_name + "json");
        
        if (json_file.exists)
        {
            var json_str : String = AirContext.readTextFile(json_file);
            if (json_str != null)
            {
                try
                {
                    UserSongNotes.loadFromObject(haxe.Json.parse(json_str));
                }
                catch (e : Error)
                {
                }
            }
        }
    }
    
    public function writeUserSongData() : Void
    {
        var db_name : String = "dbinfo/" + ((activeUser != null && activeUser.siteId > 0) ? activeUser.siteId : "0") + "_info.";
        var json_file : File = AirContext.getAppFile(db_name + "json");
        UserSongNotes.writeFile(json_file);
    }
    
    public function websocketPortNumber(type : String) : Int
    {
        if (websocket_server != null)
        {
            return websocket_server.getPortNumber(type);
        }
        return 0;
    }
    
    public function initWebsocketServer() : Bool
    {
        if (websocket_server == null)
        {
            websocket_server = new AIRServer();
            websocket_server.addEndPoint(new SocketEndPoint(21235, new WebSocketClientHandlerFactory()));
            
            // didn't start, remove reference
            if (!websocket_server.start())
            {
                websocket_server.stop();
                websocket_server = null;
                return false;
            }
            return true;
        }
        return false;
    }
    
    public function destroyWebsocketServer() : Void
    {
        if (websocket_server != null)
        {
            websocket_server.stop();
            websocket_server = null;
        }
    }
    
    public function websocketSend(cmd : String, data : Dynamic) : Void
    {
        if (websocket_server != null)
        {
            websocket_message.command = cmd;
            websocket_message.data = data;
            websocket_server.sendMessageToAllClients(websocket_message);
        }
    }
    
    public function onNativeProcessClose(e : Event) : Void
    {
        if (websocket_server != null)
        {
            websocket_server.stop();
        }
    }
    
    public function loadMenuMusic() : Void
    {
        menuMusicSoundVolume = menuMusicSoundTransform.volume = LocalOptions.getVariable("menu_music_volume", 1);
        
        // Load Existing Menu Music SWF
        if (AirContext.doesFileExist(Constant.MENU_MUSIC_PATH))
        {
            var file_bytes : ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
            if (file_bytes != null && file_bytes.length > 0)
            {
                menuMusic = new SongPlayerBytes(file_bytes);
            }
        }
        // Convert MP3 if exist.
        else if (AirContext.doesFileExist(Constant.MENU_MUSIC_MP3_PATH))
        {
            var mp3Bytes : ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_MP3_PATH));
            if (mp3Bytes != null && mp3Bytes.length > 0)
            {
                menuMusic = new SongPlayerBytes(mp3Bytes, true);
                LocalStore.setVariable("menu_music", "External MP3");
            }
        }
    }
    
    ///- Public
    //- Player Divisions
    public function getDivisionColor(level : Int) : String
    {
        return divisionColors[getDivisionNumber(level)];
    }
    
    public function getDivisionTitle(level : Int) : String
    {
        return divisionTitles[getDivisionNumber(level)];
    }
    
    public function getDivisionNumber(level : Int) : Int
    {
        var div : Int;
        div = as3hx.Compat.parseInt(divisionLevels.length - 1);
        while (div >= 0)
        {
            if (level >= divisionLevels[div])
            {
                break;
            }
            --div;
        }
        return div;
    }
    
    //- Song Data
    public function getSongFile(songInfo : SongInfo) : Song
    {
        if (songInfo == externalSongInfo)
        {
            return externalSong;
        }
        
        if (songInfo.engine == Playlist.instance.engine && (!songInfo.engine || !songInfo.engine.ignoreCache))
        {
            for (s in 0...songCache.length)
            {
                var song : Song = songCache[s];
                if (song != null && song.songInfo.level == songInfo.level)
                {
                    return song;
                }
            }
        }
        
        return loadSongFile(songInfo);
    }
    
    private function loadSongFile(songInfo : SongInfo) : Song
    //- Only Cache 10 Songs
    {
        
        var engineCache : Bool = (songInfo.engine == Playlist.instance.engine) && (!songInfo.engine || !songInfo.engine.ignoreCache);
        if (songCache.length > 10 && engineCache)
        {
            songCache.pop();
        }
        
        //- Make new Song
        var song : Song = new Song(songInfo);
        
        //- Push to cache
        if (engineCache)
        {
            songCache.push(song);
        }
        
        return song;
    }
    
    public function removeSongFile(song : Song) : Void
    {
        for (s in 0...songCache.length)
        {
            if (songCache[s] == song)
            {
                song.unload();
                songCache.splice(s, 1)[0];
            }
        }
    }
    
    public function removeSongFiles() : Void
    {
        for (s in 0...songCache.length)
        {
            songCache[s].unload();
        }
        
        as3hx.Compat.setArrayLength(songCache, 0);
    }
    
    public function dirtySongFiles() : Void
    {
        if (externalSong != null)
        {
            externalSong.isDirty = true;
        }
        
        for (s in 0...songCache.length)
        {
            songCache[s].isDirty = true;
        }
    }
    
    public static inline var SONG_ACCESS_PLAYABLE : Int = 0;
    public static inline var SONG_ACCESS_CREDITS : Int = 1;
    public static inline var SONG_ACCESS_PURCHASED : Int = 2;
    public static inline var SONG_ACCESS_TOKEN : Int = 3;
    public static inline var SONG_ACCESS_VETERAN : Int = 4;
    public static inline var SONG_ACCESS_BANNED : Int = 5;
    
    public function checkSongAccess(songInfo : SongInfo) : Int
    {
        if (songInfo == null || Math.isNaN(songInfo.level))
        {
            return SONG_ACCESS_BANNED;
        }
        if (songInfo.credits > 0 && playerUser.credits < songInfo.credits)
        {
            return SONG_ACCESS_CREDITS;
        }
        if (songInfo.price > 0 && (songInfo.index >= playerUser.purchased.length || playerUser.purchased[songInfo.index] == null))
        {
            return SONG_ACCESS_PURCHASED;
        }
        if (songInfo.engine == null && Reflect.field(TOKENS, Std.string(songInfo.level)) != null && Reflect.field(TOKENS, Std.string(songInfo.level)).unlock == 0)
        {
            return SONG_ACCESS_TOKEN;
        }
        if (songInfo.prerelease && !playerUser.isVeteran)
        {
            return SONG_ACCESS_VETERAN;
        }
        return SONG_ACCESS_PLAYABLE;
    }
    
    public static inline var SONG_ICON_NO_SCORE : Int = 0;
    public static inline var SONG_ICON_UNFINISHED : Int = 1;
    public static inline var SONG_ICON_PASSED : Int = 2;
    public static inline var SONG_ICON_FC_STAR : Int = 3;
    public static inline var SONG_ICON_FC : Int = 4;
    public static inline var SONG_ICON_SDG : Int = 5;
    public static inline var SONG_ICON_OMNIFLAG : Int = 6;
    public static inline var SONG_ICON_MISSFLAG : Int = 7;
    public static inline var SONG_ICON_AVFLAG : Int = 8;
    public static inline var SONG_ICON_BLACKFLAG : Int = 9;
    public static inline var SONG_ICON_BOOFLAG : Int = 10;
    public static inline var SONG_ICON_AAA : Int = 11;
    
    public static function getSongIconIndex(_songInfo : SongInfo, _rank : Dynamic) : Int
    {
        var songIcon : Int = 0;
        if (_rank != null)
        {
            var noteCount : Int = _songInfo.note_count;
            var maxRawScore : Int = _songInfo.score_raw;
            
            // Alt engine hack
            if (_rank.arrows > 0)
            {
                noteCount = _rank.arrows;
                maxRawScore = as3hx.Compat.parseInt(noteCount * 50);
            }
            
            // No Score
            if (_rank.score == 0)
            {
                songIcon = SONG_ICON_NO_SCORE;
            }
            
            // Unfinished or Passed
            if (_rank.score > 0)
            {
                if (_rank.perfect + _rank.good + _rank.average + _rank.miss < noteCount)
                {
                    songIcon = SONG_ICON_UNFINISHED;
                }
                else
                {
                    songIcon = SONG_ICON_PASSED;
                }
            }
            
            // FC* - When current score isn't FC but a FC has been achieved before.
            if (_rank.fcs > 0)
            {
                songIcon = SONG_ICON_FC_STAR;
            }
            
            // FC
            if (_rank.perfect + _rank.good + _rank.average == noteCount && _rank.miss == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = SONG_ICON_FC;
            }
            
            // SDG
            if (maxRawScore - _rank.rawscore < 250)
            {
                songIcon = SONG_ICON_SDG;
            }
            
            // Omni Flag
            if (_rank.perfect == noteCount - 3 && _rank.good == 1 && _rank.average == 1 && _rank.miss == 1 && _rank.boo == 1)
            {
                songIcon = SONG_ICON_OMNIFLAG;
            }
            
            // Miss Flag
            if (_rank.perfect == noteCount - 1 && _rank.good == 0 && _rank.average == 0 && _rank.miss == 1 && _rank.boo == 0)
            {
                songIcon = SONG_ICON_MISSFLAG;
            }
            
            // Average Flag
            if (_rank.perfect == noteCount - 1 && _rank.good == 0 && _rank.average == 1 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = SONG_ICON_AVFLAG;
            }
            
            // BlackFlag
            if (_rank.perfect == noteCount - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = SONG_ICON_BLACKFLAG;
            }
            
            // BooFlag
            if (_rank.perfect == noteCount && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == noteCount)
            {
                songIcon = SONG_ICON_BOOFLAG;
            }
            
            // AAA
            if (_rank.rawscore == maxRawScore)
            {
                songIcon = SONG_ICON_AAA;
            }
        }
        return songIcon;
    }
    
    public static function getSongIconIndexBitmask(_songInfo : SongInfo, _rank : Dynamic) : Int
    {
        var songIcon : Int = SONG_ICON_NO_SCORE;
        if (_rank != null)
        {
            var noteCount : Int = _songInfo.note_count;
            var maxRawScore : Int = _songInfo.score_raw;
            
            // Alt engine hack
            if (_rank.arrows > 0)
            {
                noteCount = _rank.arrows;
                maxRawScore = as3hx.Compat.parseInt(noteCount * 50);
            }
            
            // Unfinished or Passed
            if (_rank.score > 0)
            {
                if (_rank.perfect + _rank.good + _rank.average + _rank.miss < noteCount)
                {
                    songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_UNFINISHED);
                }
                else
                {
                    songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_PASSED);
                }
            }
            
            // FC* - When current score isn't FC but a FC has been achieved before.
            if (_rank.fcs > 0)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_FC_STAR);
            }
            
            // FC
            if (_rank.perfect + _rank.good + _rank.average == noteCount && _rank.miss == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_FC);
            }
            
            // SDG
            if (maxRawScore - _rank.rawscore < 250)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_SDG);
            }
            
            // Omni Flag
            if (_rank.perfect == noteCount - 3 && _rank.good == 1 && _rank.average == 1 && _rank.miss == 1 && _rank.boo == 1)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_OMNIFLAG);
            }
            
            // Miss Flag
            if (_rank.perfect == noteCount - 1 && _rank.good == 0 && _rank.average == 0 && _rank.miss == 1 && _rank.boo == 0)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_MISSFLAG);
            }
            
            // Average Flag
            if (_rank.perfect == noteCount - 1 && _rank.good == 0 && _rank.average == 1 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_AVFLAG);
            }
            
            // BlackFlag
            if (_rank.perfect == noteCount - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == noteCount)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_BLACKFLAG);
            }
            
            // BooFlag
            if (_rank.perfect == noteCount && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == noteCount)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_BOOFLAG);
            }
            
            // AAA
            if (_rank.rawscore == maxRawScore)
            {
                songIcon = songIcon | as3hx.Compat.parseInt(1 << SONG_ICON_AAA);
            }
        }
        return songIcon;
    }
    
    public static var SONG_ICON_TEXT : Array<Dynamic> = ["<font color=\"#9C9C9C\">UNPLAYED</font>", 
        "", 
        "<font color=\"#9FC4B4\">PASS</font>", 
        "<font color=\"#00FF00\">FC*</font>", 
        "<font color=\"#00FF00\">FC</font>", 
        "<font color=\"#F2A254\">SDG</font>",   // < 10 raw  
        "<font color=\"#cc3333\">O</font><font color=\"#cca633\">M</font><font color=\"#7fcc33\">N</font><font color=\"#33cc59\">I</font><font color=\"#33cbcc\">F</font><font color=\"#6d91ff\">L</font><font color=\"#7f33cc\">A</font><font color=\"#cc33cc\">G</font>", 
        "<font color=\"#660A0A\">MISSFLAG</font>",   // 1 miss  
        "<font color=\"#FF9A00\">AVFLAG</font>",   // 1 average  
        "<font color=\"#2C2C2C\">BLACKFLAG</font>",   // 1 good  
        "<font color=\"#473218\">BOOFLAG</font>",   // 1 boo  
        "<font color=\"#FFFF38\">AAA</font>"
    ];  // :)  
    
    public static var SONG_ICON_COLOR : Array<Dynamic> = ["#9C9C9C", 
        "#FFFFFF", 
        "#9FC4B4", 
        "#00FF00", 
        "#00FF00", 
        "#F2A254", 
        "#cc33cc", 
        "#660A0A", 
        "#FF9A00", 
        "#2C2C2C", 
        "#473218", 
        "#FFFF38"
    ];
    
    public static var SONG_ICON_TEXT_FLAG : Array<Dynamic> = ["Unplayed", 
        "Unfinished", 
        "Passed", 
        "Full Combo*", 
        "Full Combo", 
        "Single Digit Good", 
        "Omniflag", 
        "Missflag", 
        "Averageflag", 
        "Blackflag", 
        "Booflag", 
        "AAA"
    ];
    
    public static function getSongIcon(_songInfo : SongInfo, _rank : Dynamic) : String
    {
        return SONG_ICON_TEXT[getSongIconIndex(_songInfo, _rank)];
    }
    
    //- Hiscores
    /**
     * Returns the loaded Highscore for the specified level id.
     * @param	lvlID
     * @return	Object containing the highscores list, or null if no highscore were loaded.
     */
    public function getHighscores(lvlID : Int) : Dynamic
    {
        if (Reflect.field(songHighscores, Std.string(lvlID)) != null)
        {
            return Reflect.field(songHighscores, Std.string(lvlID));
        }
        
        return null;
    }
    
    public function clearHighscores() : Void
    {
        songHighscores = { };
    }
    
    public function loadHighscores(lvlID : Int, startIndex : Int = 0) : Void
    {
        _loader = new DynamicURLLoader();
        addLoaderListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.SITE_HISCORES_URL) + "?d=" + Date.now().getTime());
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = this.userSession;
        requestVars.level = lvlID;
        requestVars.start = startIndex;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.level = lvlID;
        _loader.load(req);
    }
    
    private function highscoreLoadComplete(e : Event) : Void
    {
        removeLoaderListeners();
        var lvlID : Int = e.target.level;
        var data : Dynamic = haxe.Json.parse(e.target.data);
        var hiscores : Dynamic = Reflect.field(songHighscores, Std.string(lvlID));
        
        if (hiscores == null)
        {
            Reflect.setField(songHighscores, Std.string(lvlID), { });
        }
        
        if (data.error == null)
        {
            for (item/* AS3HX WARNING could not determine type for var: item exp: EIdent(data) type: Dynamic */ in data)
            {
                Reflect.setField(Reflect.field(songHighscores, Std.string(lvlID)), Std.string(item.id), item);
            }
        }
        this.dispatchEvent(new DataEvent(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, data));
    }
    
    private function highscoreLoadError(e : Event = null) : Void
    {
        removeLoaderListeners();
        this.dispatchEvent(new Event(GlobalVariables.HIGHSCORES_LOAD_ERROR));
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, highscoreLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, highscoreLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, highscoreLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, highscoreLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, highscoreLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, highscoreLoadError);
    }
    
    //- ScreenShot Handling
    /**
     * Takes a screenshot of the stage and saves it to disk.
     */
    public function takeScreenShot(filename : String = null) : Void
    {
        Screenshots.takeScreenshot(gameMain, filename);
    }
    
    /**
     * Takes a screenshot of the stage and saves it to clipboard.
     */
    public function saveScreenshotToClipboard() : Void
    {
        Screenshots.saveToClipboard(gameMain);
    }
    
    public function logDebugError(error_message : String) : Void
    {
        false;{
            var _debugLoader : URLLoader = new URLLoader();
            var req : URLRequest = new URLRequest(URLs.resolve(URLs.CRASH_LOG_URL));
            var requestVars : URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = userSession;
            requestVars.error = error_message;
            requestVars.settings = Capabilities.serverString;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _debugLoader.dataFormat = URLLoaderDataFormat.TEXT;
            _debugLoader.load(req);
        }
    }
    
    //- Full Screen
    public function toggleFullScreen(e : Event = null) : Void
    {
        if (gameMain.stage)
        {
            if (gameMain.stage.displayState == StageDisplayState.NORMAL)
            {
                gameMain.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            }
            else
            {
                gameMain.stage.displayState = StageDisplayState.NORMAL;
            }
        }
    }
    
    public function isFullScreen() : Bool
    {
        if (gameMain.stage)
        {
            return gameMain.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
        
        return false;
    }
    
    public function unlockTokenById(type : String, id : String) : Void
    {
        try
        {
            Reflect.setField(TOKENS, Std.string(Reflect.field(Reflect.field(TOKENS_TYPE, type), id).level), 1).unlock;
        }
        catch (err : Error)
        {
            Logger.error(this, "Attempted Unlock of Unknown Token: " + type + ", " + id);
        }
    }
    
    public function reloadEngineData() : Void
    {
        if (gameMain.loadComplete && !(Std.is(gameMain.activePanel, GameMenu)))
        {
            gameMain.removePopup();
            Flags.VALUES = { };
            Playlist.clearCanon();
            gameMain.loadComplete = false;
            gameMain.switchTo("none");
        }
    }
    
    public function switchUserAccount() : Void
    {
        if (gameMain.loadComplete && !(Std.is(gameMain.activePanel, GameMenu)))
        {
            gameMain.removePopup();
            Flags.VALUES = { };
            Multiplayer.instance.disconnect();
            playerUser.refreshUser();
            gameMain.switchTo(Main.GAME_LOGIN_PANEL);
        }
    }
    
    private static function get_instance() : GlobalVariables
    {
        if (_instance == null)
        {
            _instance = new GlobalVariables(new GlobalVariablesSingletonEnforcer());
        }
        
        return _instance;
    }
}


class GlobalVariablesSingletonEnforcer
{

    public function new()
    {
    }
}
