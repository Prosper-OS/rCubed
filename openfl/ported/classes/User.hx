package classes;

import openfl.errors.Error;
import arc.ArcGlobals;
import assets.GameBackgroundColor;
import classes.filter.EngineLevelFilter;
import classes.user.UserSongData;
import classes.user.UserSongNotes;
import com.flashfla.utils.VectorUtil;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.media.SoundMixer;
import openfl.media.SoundTransform;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.ui.Keyboard;
import game.SkillRating;

class User extends EventDispatcher
{
    public var settings(get, set) : Dynamic;

    //- Constants
    public static inline var ADMIN_ID : Int = 6;
    public static inline var DEVELOPER_ID : Int = 83;
    public static inline var BANNED_ID : Int = 8;
    public static inline var CHAT_MOD_ID : Int = 24;
    public static inline var FORUM_MOD_ID : Int = 5;
    public static inline var MULTI_MOD_ID : Int = 44;
    public static inline var MUSIC_PRODUCER_ID : Int = 46;
    public static inline var PROFILE_MOD_ID : Int = 56;
    public static inline var SIM_AUTHOR_ID : Int = 47;
    public static inline var VETERAN_ID : Int = 49;
    
    ///- Private Locals
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _playlist : Playlist = Playlist.instance;
    private var _loader : URLLoader;
    private var _isLoaded : Bool = false;
    private var _isLoading : Bool = false;
    private var _loadError : Bool = false;
    
    //- User Vars
    public var name : String;
    public var siteId : Int;
    public var hash : String;
    public var groups : Array<Float>;
    public var language : String = "us";
    public var playerIdx : Int;
    
    public var userLevel : Int;
    public var userClass : Int;
    public var userColor : Int;
    public var userStatus : Int;
    
    public var joinDate : String;
    public var skillLevel : Float;
    public var skillRating : Float;
    public var gameRank : Float;
    public var gamesPlayed : Float;
    public var grandTotal : Float;
    public var credits : Float;
    public var purchased : Array<Bool>;
    public var averageRank : Float;
    public var level_ranks : Dynamic = { };
    public var skill_rating_top_count : Int = 50;
    public var skill_rating_levelranks : Array<Dynamic> = [];
    public var avatar : DisplayObject;
    public var loggedIn : Bool;
    
    public var songQueues : Array<Dynamic> = [];
    public var filters : Array<EngineLevelFilter> = [];
    public var songRatings : Dynamic = { };
    
    public var DISPLAY_LEGACY_SONGS : Bool = false;
    public var DISPLAY_UNRANKED_SONGS : Bool = true;
    public var DISPLAY_EXPLICIT_SONGS : Bool = true;
    public var DISPLAY_GENRE_FLAG : Bool = true;
    public var DISPLAY_SONG_FLAG : Bool = true;
    public var DISPLAY_SONG_NOTE : Bool = true;
    
    //- Game Data
    public var GLOBAL_OFFSET : Float = 0;
    public var VISUAL_DELAY : Float = 0;
    public var JUDGE_OFFSET : Float = 0;
    public var AUTO_JUDGE_OFFSET : Bool = false;
    public var DISPLAY_JUDGE : Bool = true;
    public var DISPLAY_JUDGE_ANIMATIONS : Bool = true;
    public var DISPLAY_RECEPTOR_ANIMATIONS : Bool = true;
    public var DISPLAY_HEALTH : Bool = true;
    public var DISPLAY_GAME_TOP_BAR : Bool = true;
    public var DISPLAY_GAME_BOTTOM_BAR : Bool = true;
    public var DISPLAY_SCORE : Bool = true;
    public var DISPLAY_COMBO : Bool = true;
    public var DISPLAY_PACOUNT : Bool = true;
    public var DISPLAY_ACCURACY_BAR : Bool = true;
    public var DISPLAY_AMAZING : Bool = true;
    public var DISPLAY_PERFECT : Bool = true;
    public var DISPLAY_TOTAL : Bool = true;
    public var DISPLAY_SCREENCUT : Bool = false;
    public var DISPLAY_SONGPROGRESS : Bool = true;
    public var DISPLAY_SONGPROGRESS_TEXT : Bool = false;
    public var DISPLAY_MULTIPLAYER_SCORES : Bool = true;
    public var DISPLAY_RAWGOODS : Bool = false;
    
    public var DISPLAY_MP_TIMESTAMP : Bool = false;
    public var judgeColors : Array<Dynamic> = [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100];
    public var comboColors : Array<Dynamic> = [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2];  // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood  
    public var enableComboColors : Array<Bool> = [true, true, true, false, false, false, false, false, false];
    public var receptorColors : Array<Dynamic> = [0xFFFFFF, 0xFFFFFF, 0x64FF64, 0xFFFF00, 0xBB8500, 0xA80000];
    public var enableReceptorColors : Array<Bool> = [true, true, true, true, true, false];
    public var gameColors : Array<Dynamic> = [0x1495BD, 0x033242, 0x0C6A88, 0x074B62, 0x000000];
    public var noteColors : Array<Dynamic> = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
    public var rawGoodTracker : Float = 0;
    public var rawGoodsColor : Float = 0xDC00C2;
    
    public var autofailAmazing : Int = 0;
    public var autofailPerfect : Int = 0;
    public var autofailGood : Int = 0;
    public var autofailAverage : Int = 0;
    public var autofailMiss : Int = 0;
    public var autofailBoo : Int = 0;
    public var autofailRawGoods : Float = 0;
    public var autofailAaaEquiv : Float = 0;
    public var autofailRestart : Bool = false;
    public var personalBestMode : Bool = false;
    public var personalBestTracker : Bool = false;
    
    public var keyLeft : Int = Keyboard.LEFT;
    public var keyDown : Int = Keyboard.DOWN;
    public var keyUp : Int = Keyboard.UP;
    public var keyRight : Int = Keyboard.RIGHT;
    public var keyRestart : Int = Keyboard.SLASH;
    public var keyQuit : Int = Keyboard.CONTROL;
    public var keyOptions : Int = 145;  // Scrolllock  
    
    public var activeNoteskin : Int = 1;
    public var activeMods : Array<Dynamic> = [];
    public var activeVisualMods : Array<Dynamic> = [];
    public var slideDirection : String = "up";
    public var judgeSpeed : Float = 1;
    public var gameSpeed : Float = 1.5;
    public var receptorGap : Float = 80;
    public var receptorSpeed : Float = 1;
    public var judgeScale : Float = 1;
    public var noteScale : Float = 1;
    public var gameVolume : Float = 1;
    public var screencutPosition : Float = 0.5;
    public var frameRate : Int = 60;
    public var songRate : Float = 1;
    public var gameLayout : Dynamic = { };
    public var accuracyBarFadeFactor : Float = 0.95;
    public var visualHypeMode : String = "full";
    
    //- Permissions
    public var isActiveUser : Bool;
    public var isGuest : Bool;
    public var isPlayer : Bool;
    public var isVeteran : Bool;
    public var isAdmin : Bool;
    public var isDeveloper : Bool;
    public var isForumBanned : Bool;
    public var isGameBanned : Bool;
    public var isProfileBanned : Bool;
    public var isModerator : Bool;
    public var isForumModerator : Bool;
    public var isProfileModerator : Bool;
    public var isChatModerator : Bool;
    public var isMultiModerator : Bool;
    public var isMusician : Bool;
    public var isSimArtist : Bool;
    
    ///- Constructor
    /**
     * Defines the creation of a new User object.
     *
     * @param	loadData Loads the user data on creation.
     * @param	isActiveUser Sets the active user flag.
     * @tiptext
     */
    public function new(loadData : Bool = false, isActiveUser : Bool = false, siteId : Int = -1)
    {
        super();
        this.siteId = siteId;
        this.isActiveUser = isActiveUser;
        
        if (loadData)
        {
            if (siteId > -1)
            {
                loadUser(siteId);
            }
            else
            {
                load();
            }
        }
    }
    
    public function refreshUser() : Void
    {
        _gvars.userSession = "0";
        _gvars.playerUser = new User(true, true);
        _gvars.activeUser = _gvars.playerUser;
    }
    
    ///- Public
    public function calculateAverageRank() : Void
    {
        var rankTotal : Int = 0;
        for (levelRank/* AS3HX WARNING could not determine type for var: levelRank exp: EField(EIdent(this),level_ranks) type: null */ in this.level_ranks)
        {
            var genre : Int = levelRank.genre;
            if (genre != 10 && genre != 12 && genre != 23)
            {
                rankTotal += levelRank.rank;
            }
        }
        this.averageRank = (rankTotal / _gvars.TOTAL_PUBLIC_SONGS);
    }
    
    ///- Determine what songs make up the user's Skill Rating
    public function getUserSkillRatingData() : Void
    {
        for (key in Reflect.fields(this.level_ranks))
        {
            var levelRank : Dynamic = this.level_ranks[key];
            
            //Calculate the AAA Equiv for the scores on the song if greater than 0
            if (levelRank.score > 0) {
var songInfo : SongInfo = _playlist.getSongInfo(as3hx.Compat.parseInt(key));
                
                if (songInfo == null || songInfo.is_unranked)
                {
                    continue;
                }
                
                //Calculate the song's equiv
                levelRank.equiv = SkillRating.calcSongWeightFromScore(levelRank.rawscore, songInfo);
                
                //Add it to the Skill Rating list if it's not 0
                if (levelRank.equiv > 0)
                {
                    skill_rating_levelranks.push(levelRank);
                }
            }
        }
        
        //Sort based on equiv
        skill_rating_levelranks.sort(equivSort);
        
        //Dump all but the top X
        if (skill_rating_levelranks.length > skill_rating_top_count)
        {
            as3hx.Compat.setArrayLength(skill_rating_levelranks, skill_rating_top_count);
        }
    }
    
    public function equivSort(a : Dynamic, b : Dynamic) : Int
    {
        if (a.equiv < b.equiv)
        {
            return 1;
        }
        else if (a.equiv > b.equiv)
        {
            return -1;
        }
        else
        {
            return 0;
        }
    }
    
    public function updateSRList(newLevelRanks : Dynamic) : Void
    {
        var worseLevelRank : Dynamic = skill_rating_levelranks[skill_rating_top_count - 1];
        if (worseLevelRank == null || newLevelRanks.equiv > worseLevelRank.equiv) {
if (worseLevelRank != null)
            {
                var i : Int = as3hx.Compat.parseInt(skill_rating_levelranks.length - 1);
                while (i >= 0)
                {
                    if (skill_rating_levelranks[i].id == newLevelRanks.id) {
{
                            skill_rating_levelranks.splice(i, 1);
                            break;
                        }
                    }
                    i--;
                }
            }
            
            // Add this improved rating
            skill_rating_levelranks.push(newLevelRanks);
            
            // Sort it to the right spot
            skill_rating_levelranks.sort(equivSort);
            
            // Drop the bottom equiv if we have more than the top X count
            // [won't be necessary for newer players with less than X scores for equiv rating, or if we've improved a score that we already had equiv from]
            if (skill_rating_levelranks.length > skill_rating_top_count)
            {
                as3hx.Compat.setArrayLength(skill_rating_levelranks, skill_rating_top_count);
            }
        }
    }
    
    ///- Profile Loading
    public function isLoaded() : Bool
    {
        return _isLoaded && !_loadError;
    }
    
    public function isError() : Bool
    {
        return _loadError;
    }
    
    public function load() : Void
    // Kill old Loading Stream
    {
        
        if (_loader != null && _isLoading)
        {
            removeLoaderListeners();
            _loader.close();
        }
        
        Logger.info(this, "Main User Load Requested");
        _isLoaded = false;
        _loadError = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.USER_INFO_URL) + "?d=" + Date.now().getTime());
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        _isLoading = true;
    }
    
    public function loadUser(userid : Int) : Void
    {
        Logger.info(this, "Secondary User Load Requested");
        _isLoaded = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.USER_INFO_LITE_URL) + "?d=" + Date.now().getTime());
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.userid = userid;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        _isLoading = true;
    }
    
    private function profileLoadComplete(e : Event) : Void
    {
        Logger.success(this, "Profile Load Success");
        removeLoaderListeners();
        
        // Parse Response
        var _data : Dynamic;
        var siteDataString : String = e.target.data;
        try
        {
            _data = haxe.Json.parse(siteDataString);
        }
        catch (err : Error)
        {
            Logger.error(this, "Profile Parse Failure: " + Logger.exception_error(err));
            Logger.error(this, "Wrote invalid response data to log folder. [logs/user_main.txt]");
            AirContext.writeTextFile(AirContext.getAppFile("logs/user_main.txt"), siteDataString);
            
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
            return;
        }  // Has Response  
        
        
        
        loadUserData(_data);
        
        if (isActiveUser)
        {
            loadLevelRanks();
        }
        else
        {
            _isLoaded = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
    }
    
    public function loadUserData(_data : Dynamic) : Void
    // Private
    {
        
        if (isActiveUser)
        {
            this.hash = _data.hash;
            this.credits = _data.credits;
            setPurchasedString(Reflect.field(_data, "purchased"));
            if (Reflect.field(_data, "song_ratings") != null)
            {
                this.songRatings = Reflect.field(_data, "song_ratings");
            }
        }
        
        // Public
        this.name = Reflect.field(_data, "name");
        this.siteId = Reflect.field(_data, "id");
        this.groups = VectorUtil.fromArr(Reflect.field(_data, "groups"));
        this.joinDate = Reflect.field(_data, "joinDate");
        this.gameRank = Reflect.field(_data, "gameRank");
        this.gamesPlayed = Reflect.field(_data, "gamesPlayed");
        this.grandTotal = Reflect.field(_data, "grandTotal");
        this.skillLevel = Reflect.field(_data, "skillLevel");
        this.skillRating = Reflect.field(_data, "skillRating");
        
        setupPermissions();
        
        // Load Avatar
        loadAvatar();
        
        // Setup Settings from server or local
        if (Reflect.field(_data, "settings") != null && !this.isGuest)
        {
            try
            {
                settings = haxe.Json.parse(_data.settings);
            }
            catch (err : Error)
            {
                Logger.error(this, "Settings Parse Failure: " + Logger.exception_error(err));
            }
        }
        else
        {
            loadLocal();
        }
    }
    
    public function setPurchasedString(str : String) : Void
    {
        this.purchased = [];
        for (x in 1...str.length)
        {
            this.purchased.push(str.charAt(x) == "1");
        }
    }
    
    private function profileLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Profile Load Failure: " + Logger.event_error(err));
        removeLoaderListeners();
        _loadError = true;
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, profileLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, profileLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, profileLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _isLoaded = false;
        _loader.removeEventListener(Event.COMPLETE, profileLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, profileLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, profileLoadError);
    }
    
    private function setupPermissions() : Void
    {
        this.isGuest = (this.siteId <= 2);
        this.isVeteran = VectorUtil.inVector(this.groups, [VETERAN_ID]);
        this.isAdmin = VectorUtil.inVector(this.groups, [ADMIN_ID]);
        this.isDeveloper = VectorUtil.inVector(this.groups, [DEVELOPER_ID]);
        this.isForumBanned = VectorUtil.inVector(this.groups, [BANNED_ID]);
        this.isModerator = VectorUtil.inVector(this.groups, [ADMIN_ID, FORUM_MOD_ID, CHAT_MOD_ID, PROFILE_MOD_ID, MULTI_MOD_ID]);
        this.isForumModerator = VectorUtil.inVector(this.groups, [FORUM_MOD_ID, ADMIN_ID]);
        this.isProfileModerator = VectorUtil.inVector(this.groups, [PROFILE_MOD_ID, ADMIN_ID]);
        this.isChatModerator = VectorUtil.inVector(this.groups, [CHAT_MOD_ID, ADMIN_ID]);
        this.isMultiModerator = VectorUtil.inVector(this.groups, [MULTI_MOD_ID, ADMIN_ID]);
        this.isMusician = VectorUtil.inVector(this.groups, [MUSIC_PRODUCER_ID]);
        this.isSimArtist = VectorUtil.inVector(this.groups, [SIM_AUTHOR_ID]);
    }
    
    public function loadAvatar() : Void
    {
        var _loader : Loader = new Loader();
        
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, avatarLoadComplete);
        _loader.load(new URLRequest(URLs.resolve(URLs.USER_AVATAR_URL) + "?uid=" + this.siteId + "&cHeight=99&cWidth=99"));
        
        var avatarLoadComplete : Event->Void = function(e : Event) : Void
        {
            if (isActiveUser && !isGuest)
            {
                LocalStore.setVariable("uAvatar", cast((e.target), LoaderInfo).bytes);
            }
            
            avatar = _loader.content;
            
            _loader.removeEventListener(Event.COMPLETE, avatarLoadComplete);
        }
    }
    
    ///- Level Ranks
    public function loadLevelRanks() : Void
    {
        _loader = new URLLoader();
        addLoaderRanksListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.USER_RANKS_URL));
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
    }
    
    private function ranksLoadComplete(e : Event) : Void
    {
        Logger.success(this, "Ranks Load Success");
        removeLoaderRanksListeners();
        level_ranks = {};
        
        // Check Level ranks for Non-empty
        if (e.target.data != "")
        {
            var ranksTemp : Array<Dynamic> = e.target.data.split(",");
            var rankLength : Int = ranksTemp.length;
            for (x in 0...rankLength) {
var rankSplit : Array<Dynamic> = Reflect.field(ranksTemp, Std.string(x)).split(":");
                
                // [0]'perfect' - [1]'good' - [2]'average' - [3]'miss' - [4]'boo' - [5]'maxcombo'
                var scoreResults : Array<Dynamic> = rankSplit[4].split("-");
                for (s in Reflect.fields(scoreResults))
                {
                    Reflect.setField(scoreResults, s, as3hx.Compat.parseFloat(Reflect.field(scoreResults, s)));
                }
                
                Reflect.setField(level_ranks, Std.string(as3hx.Compat.parseFloat(rankSplit[0])), {
                    id : as3hx.Compat.parseFloat(rankSplit[0]),
                    genre : as3hx.Compat.parseFloat(rankSplit[3]),
                    rank : as3hx.Compat.parseFloat(rankSplit[1]),
                    score : as3hx.Compat.parseFloat(rankSplit[2]),
                    results : rankSplit[4],
                    plays : as3hx.Compat.parseFloat(rankSplit[5]),
                    aaas : as3hx.Compat.parseFloat(rankSplit[6]),
                    fcs : as3hx.Compat.parseFloat(rankSplit[7]),
                    perfect : scoreResults[0],
                    good : scoreResults[1],
                    average : scoreResults[2],
                    miss : scoreResults[3],
                    boo : scoreResults[4],
                    maxcombo : scoreResults[5],
                    rawscore : ((scoreResults[0] * 50) + (scoreResults[1] * 25) + (scoreResults[2] * 5) - (scoreResults[3] * 10) - (scoreResults[4] * 5)),
                    equiv : 0
                });
            }
        }
        _isLoaded = true;
        this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
    }
    
    private function ranksLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Ranks Load Failure: " + Logger.event_error(err));
        removeLoaderRanksListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderRanksListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, ranksLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, ranksLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ranksLoadError);
    }
    
    private function removeLoaderRanksListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, ranksLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, ranksLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, ranksLoadError);
    }
    
    ///- Settings
    private function get_settings() : Dynamic
    {
        return save(true);
    }
    
    private function set_settings(_settings : Dynamic) : Dynamic
    {
        if (_settings == null)
        {
            return _settings;
        }
        
        if (_settings.language != null)
        {
            this.language = _settings.language;
        }
        
        if (_settings.viewOffset != null)
        {
            this.GLOBAL_OFFSET = _settings.viewOffset;
        }
        
        if (_settings.visualDelay != null)
        {
            this.VISUAL_DELAY = _settings.visualDelay;
        }
        
        if (_settings.judgeOffset != null)
        {
            this.JUDGE_OFFSET = _settings.judgeOffset;
        }
        
        if (_settings.autoJudgeOffset != null)
        {
            this.AUTO_JUDGE_OFFSET = _settings.autoJudgeOffset;
        }
        
        if (_settings.viewSongFlag != null)
        {
            this.DISPLAY_SONG_FLAG = _settings.viewSongFlag;
        }
        
        if (_settings.viewGenreFlag != null)
        {
            this.DISPLAY_GENRE_FLAG = _settings.viewGenreFlag;
        }
        
        if (_settings.viewSongNote != null)
        {
            this.DISPLAY_SONG_NOTE = _settings.viewSongNote;
        }
        
        if (_settings.viewJudge != null)
        {
            this.DISPLAY_JUDGE = _settings.viewJudge;
        }
        
        if (_settings.viewJudgeAnimations != null)
        {
            this.DISPLAY_JUDGE_ANIMATIONS = _settings.viewJudgeAnimations;
        }
        
        if (_settings.viewReceptorAnimations != null)
        {
            this.DISPLAY_RECEPTOR_ANIMATIONS = _settings.viewReceptorAnimations;
        }
        
        if (_settings.viewHealth != null)
        {
            this.DISPLAY_HEALTH = _settings.viewHealth;
        }
        
        if (_settings.viewGameTopBar != null)
        {
            this.DISPLAY_GAME_TOP_BAR = _settings.viewGameTopBar;
        }
        
        if (_settings.viewGameBottomBar != null)
        {
            this.DISPLAY_GAME_BOTTOM_BAR = _settings.viewGameBottomBar;
        }
        
        if (_settings.viewScore != null)
        {
            this.DISPLAY_SCORE = _settings.viewScore;
        }
        
        if (_settings.viewCombo != null)
        {
            this.DISPLAY_COMBO = _settings.viewCombo;
        }
        
        if (_settings.viewRawGoods != null)
        {
            this.DISPLAY_RAWGOODS = _settings.viewRawGoods;
        }
        
        if (_settings.viewPACount != null)
        {
            this.DISPLAY_PACOUNT = _settings.viewPACount;
        }
        
        if (_settings.viewAccBar != null)
        {
            this.DISPLAY_ACCURACY_BAR = _settings.viewAccBar;
        }
        
        if (_settings.viewAmazing != null)
        {
            this.DISPLAY_AMAZING = _settings.viewAmazing;
        }
        
        if (_settings.viewPerfect != null)
        {
            this.DISPLAY_PERFECT = _settings.viewPerfect;
        }
        
        if (_settings.viewTotal != null)
        {
            this.DISPLAY_TOTAL = _settings.viewTotal;
        }
        
        if (_settings.viewScreencut != null)
        {
            this.DISPLAY_SCREENCUT = _settings.viewScreencut;
        }
        
        if (_settings.viewSongProgress != null)
        {
            this.DISPLAY_SONGPROGRESS = _settings.viewSongProgress;
        }
        
        if (_settings.viewSongProgressText != null)
        {
            this.DISPLAY_SONGPROGRESS_TEXT = _settings.viewSongProgressText;
        }
        
        if (_settings.viewMultiplayerScores != null)
        {
            this.DISPLAY_MULTIPLAYER_SCORES = _settings.viewMultiplayerScores;
        }
        
        if (_settings.viewMPTimestamp != null)
        {
            this.DISPLAY_MP_TIMESTAMP = _settings.viewMPTimestamp;
        }
        
        if (_settings.viewLegacySongs != null)
        {
            this.DISPLAY_LEGACY_SONGS = _settings.viewLegacySongs;
        }
        
        if (_settings.viewExplicitSongs != null)
        {
            this.DISPLAY_EXPLICIT_SONGS = _settings.viewExplicitSongs;
        }
        
        if (_settings.viewUnrankedSongs != null)
        {
            this.DISPLAY_UNRANKED_SONGS = _settings.viewUnrankedSongs;
        }
        
        if (_settings.keys[0] != null)
        {
            this.keyLeft = _settings.keys[0];
        }
        
        if (_settings.keys[1] != null)
        {
            this.keyDown = _settings.keys[1];
        }
        
        if (_settings.keys[2] != null)
        {
            this.keyUp = _settings.keys[2];
        }
        
        if (_settings.keys[3] != null)
        {
            this.keyRight = _settings.keys[3];
        }
        
        if (_settings.keys[4] != null)
        {
            this.keyRestart = _settings.keys[4];
        }
        
        if (_settings.keys[5] != null)
        {
            this.keyQuit = _settings.keys[5];
        }
        
        if (_settings.keys[6] != null)
        {
            this.keyOptions = _settings.keys[6];
        }
        
        if (_settings.noteskin != null)
        {
            this.activeNoteskin = _settings.noteskin;
        }
        
        if (_settings.direction != null)
        {
            this.slideDirection = _settings.direction;
        }
        
        if (_settings.speed != null)
        {
            this.gameSpeed = _settings.speed;
        }
        
        if (_settings.judgeSpeed != null)
        {
            this.judgeSpeed = _settings.judgeSpeed;
        }
        
        if (_settings.receptorSpeed != null)
        {
            this.receptorSpeed = _settings.receptorSpeed;
        }
        
        if (_settings.judgeScale != null)
        {
            this.judgeScale = _settings.judgeScale;
        }
        
        if (_settings.gap != null)
        {
            this.receptorGap = _settings.gap;
        }
        
        if (_settings.noteScale != null)
        {
            this.noteScale = _settings.noteScale;
        }
        
        if (_settings.accuracyBarFadeFactor != null)
        {
            this.accuracyBarFadeFactor = _settings.accuracyBarFadeFactor;
        }
        
        if (_settings.visualHypeMode != null)
        {
            this.visualHypeMode = _settings.visualHypeMode;
        }
        
        if (_settings.screencutPosition != null)
        {
            this.screencutPosition = _settings.screencutPosition;
        }
        
        if (_settings.frameRate != null)
        {
            this.frameRate = _settings.frameRate;
        }
        
        if (_settings.songRate != null)
        {
            this.songRate = _settings.songRate;
        }
        
        if (_settings.autofailRestart != null)
        {
            this.autofailRestart = _settings.autofailRestart;
        }
        
        if (_settings.personalBestMode != null)
        {
            this.personalBestMode = _settings.personalBestMode;
        }
        
        if (_settings.personalBestTracker != null)
        {
            this.personalBestTracker = _settings.personalBestTracker;
        }
        
        if (_settings.visual != null)
        {
            this.activeVisualMods = _settings.visual;
        }
        
        if (_settings.judgeColours != null)
        {
            mergeIntoArray(this.judgeColors, _settings.judgeColours);
        }
        
        if (_settings.comboColours != null)
        {
            mergeIntoArray(this.comboColors, _settings.comboColours);
        }
        
        if (_settings.rawGoodsColor != null)
        {
            this.rawGoodsColor = _settings.rawGoodsColor;
        }
        
        if (_settings.enableComboColors != null)
        {
            mergeIntoArray(this.enableComboColors, _settings.enableComboColors);
        }
        
        if (_settings.receptorColours != null)
        {
            mergeIntoArray(this.receptorColors, _settings.receptorColours);
        }
        
        if (_settings.enableReceptorColors != null)
        {
            mergeIntoArray(this.enableReceptorColors, _settings.enableReceptorColors);
        }
        
        if (_settings.gameColours != null)
        {
            mergeIntoArray(this.gameColors, _settings.gameColours);
        }
        
        if (_settings.noteColours != null)
        {
            mergeIntoArray(this.noteColors, _settings.noteColours);
        }
        
        if (_settings.rawGoodTracker != null)
        {
            this.rawGoodTracker = _settings.rawGoodTracker;
        }
        
        if (_settings.gameVolume != null)
        {
            this.gameVolume = _settings.gameVolume;
        }
        
        if (_settings.layout != null)
        {
            this.gameLayout = doLayoutImport(_settings.layout);
        }
        
        if (_settings.filters != null)
        {
            this.filters = doImportFilters(_settings.filters);
        }
        
        if (_settings.songQueues != null)
        {
            this.songQueues = [];
            for (queueItem/* AS3HX WARNING could not determine type for var: queueItem exp: EField(EIdent(_settings),songQueues) type: null */ in _settings.songQueues)
            {
                this.songQueues.push(new SongQueueItem(queueItem.name, queueItem.items));
            }
        }
        
        if (isActiveUser)
        {
            SoundMixer.soundTransform = new SoundTransform(this.gameVolume);
            
            // Setup Background Colors
            GameBackgroundColor.BG_LIGHT = gameColors[0];
            GameBackgroundColor.BG_DARK = gameColors[1];
            GameBackgroundColor.BG_STATIC = gameColors[2];
            GameBackgroundColor.BG_POPUP = gameColors[3];
            GameBackgroundColor.BG_STAGE = gameColors[4];
            (try cast(_gvars.gameMain.getChildAt(0), GameBackgroundColor) catch(e:Dynamic) null).redraw();
        }
        
        var mergeIntoArray : Dynamic->Dynamic->Void = function(arr1 : Dynamic, arr2 : Dynamic) : Void
        {
            var minArrLen : Int = Math.min(arr1.length, arr2.length);
            for (i in 0...minArrLen)
            {
                Reflect.setField(arr1, Std.string(i), Reflect.field(arr2, Std.string(i)));
            }
        }
        return _settings;
    }
    
    public function save(returnObject : Bool = false) : Dynamic
    {
        if (isGuest && !returnObject)
        {
            return { };
        }
        
        var gameSave : Dynamic = { };
        gameSave.language = this.language;
        gameSave.viewOffset = this.GLOBAL_OFFSET;
        gameSave.visualDelay = this.VISUAL_DELAY;
        gameSave.judgeOffset = this.JUDGE_OFFSET;
        gameSave.autoJudgeOffset = this.AUTO_JUDGE_OFFSET;
        gameSave.viewGenreFlag = this.DISPLAY_GENRE_FLAG;
        gameSave.viewSongFlag = this.DISPLAY_SONG_FLAG;
        gameSave.viewSongNote = this.DISPLAY_SONG_NOTE;
        gameSave.viewJudge = this.DISPLAY_JUDGE;
        gameSave.viewHealth = this.DISPLAY_HEALTH;
        gameSave.viewJudgeAnimations = this.DISPLAY_JUDGE_ANIMATIONS;
        gameSave.viewReceptorAnimations = this.DISPLAY_RECEPTOR_ANIMATIONS;
        gameSave.viewGameTopBar = this.DISPLAY_GAME_TOP_BAR;
        gameSave.viewGameBottomBar = this.DISPLAY_GAME_BOTTOM_BAR;
        gameSave.viewScore = this.DISPLAY_SCORE;
        gameSave.viewCombo = this.DISPLAY_COMBO;
        gameSave.viewRawGoods = this.DISPLAY_RAWGOODS;
        gameSave.viewPACount = this.DISPLAY_PACOUNT;
        gameSave.viewAccBar = this.DISPLAY_ACCURACY_BAR;
        gameSave.viewAmazing = this.DISPLAY_AMAZING;
        gameSave.viewPerfect = this.DISPLAY_PERFECT;
        gameSave.viewTotal = this.DISPLAY_TOTAL;
        gameSave.viewScreencut = this.DISPLAY_SCREENCUT;
        gameSave.viewSongProgress = this.DISPLAY_SONGPROGRESS;
        gameSave.viewSongProgressText = this.DISPLAY_SONGPROGRESS_TEXT;
        gameSave.viewMultiplayerScores = this.DISPLAY_MULTIPLAYER_SCORES;
        gameSave.viewMPTimestamp = this.DISPLAY_MP_TIMESTAMP;
        gameSave.viewLegacySongs = this.DISPLAY_LEGACY_SONGS;
        gameSave.viewExplicitSongs = this.DISPLAY_EXPLICIT_SONGS;
        gameSave.viewUnrankedSongs = this.DISPLAY_UNRANKED_SONGS;
        
        gameSave.keys = [this.keyLeft, this.keyDown, this.keyUp, this.keyRight, this.keyRestart, this.keyQuit, this.keyOptions];
        
        gameSave.accuracyBarFadeFactor = this.accuracyBarFadeFactor;
        gameSave.visualHypeMode = this.visualHypeMode;
        gameSave.receptorSpeed = this.receptorSpeed;
        gameSave.judgeSpeed = this.judgeSpeed;
        gameSave.judgeScale = this.judgeScale;
        gameSave.speed = this.gameSpeed;
        gameSave.direction = this.slideDirection;
        gameSave.noteskin = this.activeNoteskin;
        gameSave.gap = this.receptorGap;
        gameSave.noteScale = this.noteScale;
        gameSave.screencutPosition = this.screencutPosition;
        gameSave.autofailRestart = this.autofailRestart;
        gameSave.personalBestMode = this.personalBestMode;
        gameSave.personalBestTracker = this.personalBestTracker;
        gameSave.frameRate = this.frameRate;
        gameSave.visual = this.activeVisualMods;
        gameSave.judgeColours = this.judgeColors;
        gameSave.comboColours = this.comboColors;
        gameSave.rawGoodsColor = this.rawGoodsColor;
        gameSave.enableComboColors = this.enableComboColors;
        gameSave.receptorColours = this.receptorColors;
        gameSave.enableReceptorColors = this.enableReceptorColors;
        gameSave.gameColours = this.gameColors;
        gameSave.noteColours = this.noteColors;
        gameSave.rawGoodTracker = this.rawGoodTracker;
        gameSave.songQueues = this.songQueues;
        gameSave.gameVolume = this.gameVolume;
        gameSave.layout = this.gameLayout;
        gameSave.filters = doExportFilters(this.filters);
        
        if (returnObject)
        {
            return gameSave;
        }
        
        //- Save to server
        _loader = new URLLoader();
        addLoaderSaveListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.USER_SAVE_SETTINGS_URL));
        var requestVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        requestVars.settings = haxe.Json.stringify(gameSave);
        requestVars.action = "save";
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        
        return { };
    }
    
    private function settingSaveComplete(e : Event) : Void
    {
        Logger.success(this, "Settings Save Success");
        removeLoaderSaveListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
    }
    
    private function settingLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Settings Save Failure: " + Logger.event_error(err));
        removeLoaderSaveListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
    }
    
    private function addLoaderSaveListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, settingSaveComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, settingLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, settingLoadError);
    }
    
    private function removeLoaderSaveListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, settingSaveComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, settingLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, settingLoadError);
    }
    
    public function saveLocal() : Void
    {
        LocalStore.setVariable("sEncode", haxe.Json.stringify(save(true)));
        LocalStore.flush();
    }
    
    public function loadLocal() : Void
    {
        var encodedSettings : String = LocalStore.getVariable("sEncode", null);
        if (encodedSettings != null)
        {
            try
            {
                settings = haxe.Json.parse(encodedSettings);
            }
            catch (e : Error)
            {
            }
        }
    }
    
    public function getLevelRank(songInfo : SongInfo) : Dynamic
    {
        if (songInfo.engine)
        {
            return ArcGlobals.instance.legacyLevelRanksGet(songInfo);
        }
        
        if (Reflect.field(level_ranks, Std.string(songInfo.level)) == null)
        {
            return {
                genre : 23,
                rank : 1,
                score : 0,
                results : "0-0-0-0-0-0",
                plays : 0,
                aaas : 0,
                fcs : 0,
                perfect : 0,
                good : 0,
                average : 0,
                miss : 0,
                boo : 0,
                maxcombo : 0,
                rawscore : 0
            };
        }
        
        return Reflect.field(level_ranks, Std.string(songInfo.level));
    }
    
    public function getSongRating(songInfo : SongInfo) : Float
    {
        if (songInfo.engine != null)
        {
            var sDetails : UserSongData = UserSongNotes.getSongDetails(songInfo.engine.id, songInfo.level_id);
            if (sDetails != null)
            {
                return sDetails.song_rating;
            }
            
            return 0;
        }
        return (Reflect.field(songRatings, Std.string(songInfo.level)) != null) ? Reflect.field(songRatings, Std.string(songInfo.level)) : 0;
    }
    
    /**
     * Imports user filters from a save object.
     * @param	filtersIn Array of Filter objects.
     * @return Array of EngineLevelFilters.
     */
    private function doImportFilters(filtersIn : Array<Dynamic>) : Array<EngineLevelFilter>
    {
        if (isActiveUser)
        {
            _gvars.activeFilter = null;
        }
        
        var newFilters : Array<EngineLevelFilter> = [];
        var filter : EngineLevelFilter;
        for (item in filtersIn)
        {
            filter = new EngineLevelFilter();
            filter.setup(item);
            newFilters.push(filter);
            
            if (filter.is_default)
            {
                if (_gvars.activeFilter == null && isActiveUser)
                {
                    _gvars.activeFilter = filter;
                }
                else
                {
                    filter.is_default = false;
                }
            }
        }
        return newFilters;
    }
    
    /**
     * Exports the user filters into an array of filter objects.
     * @param	filtersOut Array of EngineLevelFilter to export.
     * @return	Array of Filter Object.
     */
    private function doExportFilters(filtersOut : Array<EngineLevelFilter>) : Array<Dynamic>
    {
        var filters : Array<Dynamic> = [];
        for (item in filtersOut)
        {
            var exportFilter : Dynamic = item.export();
            if (Reflect.field(exportFilter, "filters") != null && Reflect.field(exportFilter, "filters").length > 0) {
filters.push(exportFilter);
            }
        }
        return filters;
    }
    
    private function doLayoutImport(data : Dynamic) : Dynamic
    {
        var out : Dynamic = { };
        var keys : Array<Dynamic> = ["sp", "mp"];
        
        for (key in keys)
        {
            if (Reflect.field(data, Std.string(key)) == null)
            {
                continue;
            }
            
            if (Std.string(Reflect.field(data, Std.string(key)).constructor).indexOf("Object") != -1)
            {
                Reflect.setField(out, Std.string(key), Reflect.field(data, Std.string(key)));
            }
        }
        
        return out;
    }
}

