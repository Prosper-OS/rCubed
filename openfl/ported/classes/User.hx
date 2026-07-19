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
    private static var avatarLoadComplete                     : Dynamic;
    private static var mergeIntoArray                     : Dynamic;
    public var settings(get, set)                             : Dynamic;

    //- Constants
    public static inline var ADMIN_ID                             : Dynamic= 6;
    public static inline var DEVELOPER_ID                             : Dynamic= 83;
    public static inline var BANNED_ID                             : Dynamic= 8;
    public static inline var CHAT_MOD_ID                             : Dynamic= 24;
    public static inline var FORUM_MOD_ID                             : Dynamic= 5;
    public static inline var MULTI_MOD_ID                             : Dynamic= 44;
    public static inline var MUSIC_PRODUCER_ID                             : Dynamic= 46;
    public static inline var PROFILE_MOD_ID                             : Dynamic= 56;
    public static inline var SIM_AUTHOR_ID                             : Dynamic= 47;
    public static inline var VETERAN_ID                             : Dynamic= 49;
    
    ///- Private Locals
    private var _gvars                             : Dynamic= GlobalVariables.instance;
    private var _playlist                             : Dynamic= Playlist.instance;
    private var _loader                             : Dynamic;
    private var _isLoaded                             : Dynamic= false;
    private var _isLoading                             : Dynamic= false;
    private var _loadError                             : Dynamic= false;
    
    //- User Vars
    public var name                             : Dynamic;
    public var siteId                             : Dynamic;
    public var hash                             : Dynamic;
    public var groups                             : Dynamic;
    public var language                             : Dynamic= "us";
    public var playerIdx                             : Dynamic;
    
    public var userLevel                             : Dynamic;
    public var userClass                             : Dynamic;
    public var userColor                             : Dynamic;
    public var userStatus                             : Dynamic;
    
    public var joinDate                             : Dynamic;
    public var skillLevel                             : Dynamic;
    public var skillRating                             : Dynamic;
    public var gameRank                             : Dynamic;
    public var gamesPlayed                             : Dynamic;
    public var grandTotal                             : Dynamic;
    public var credits                             : Dynamic;
    public var purchased                             : Dynamic;
    public var averageRank                             : Dynamic;
    public var level_ranks                             : Dynamic= { };
    public var skill_rating_top_count                             : Dynamic= 50;
    public var skill_rating_levelranks                             : Dynamic= [];
    public var avatar                             : Dynamic;
    public var loggedIn                             : Dynamic;
    
    public var songQueues                             : Dynamic= [];
    public var filters                             : Dynamic= [];
    public var songRatings                             : Dynamic= { };
    
    public var DISPLAY_LEGACY_SONGS                             : Dynamic= false;
    public var DISPLAY_UNRANKED_SONGS                             : Dynamic= true;
    public var DISPLAY_EXPLICIT_SONGS                             : Dynamic= true;
    public var DISPLAY_GENRE_FLAG                             : Dynamic= true;
    public var DISPLAY_SONG_FLAG                             : Dynamic= true;
    public var DISPLAY_SONG_NOTE                             : Dynamic= true;
    
    //- Game Data
    public var GLOBAL_OFFSET                             : Dynamic= 0;
    public var VISUAL_DELAY                             : Dynamic= 0;
    public var JUDGE_OFFSET                             : Dynamic= 0;
    public var AUTO_JUDGE_OFFSET                             : Dynamic= false;
    public var DISPLAY_JUDGE                             : Dynamic= true;
    public var DISPLAY_JUDGE_ANIMATIONS                             : Dynamic= true;
    public var DISPLAY_RECEPTOR_ANIMATIONS                             : Dynamic= true;
    public var DISPLAY_HEALTH                             : Dynamic= true;
    public var DISPLAY_GAME_TOP_BAR                             : Dynamic= true;
    public var DISPLAY_GAME_BOTTOM_BAR                             : Dynamic= true;
    public var DISPLAY_SCORE                             : Dynamic= true;
    public var DISPLAY_COMBO                             : Dynamic= true;
    public var DISPLAY_PACOUNT                             : Dynamic= true;
    public var DISPLAY_ACCURACY_BAR                             : Dynamic= true;
    public var DISPLAY_AMAZING                             : Dynamic= true;
    public var DISPLAY_PERFECT                             : Dynamic= true;
    public var DISPLAY_TOTAL                             : Dynamic= true;
    public var DISPLAY_SCREENCUT                             : Dynamic= false;
    public var DISPLAY_SONGPROGRESS                             : Dynamic= true;
    public var DISPLAY_SONGPROGRESS_TEXT                             : Dynamic= false;
    public var DISPLAY_MULTIPLAYER_SCORES                             : Dynamic= true;
    public var DISPLAY_RAWGOODS                             : Dynamic= false;
    
    public var DISPLAY_MP_TIMESTAMP                             : Dynamic= false;
    public var judgeColors                             : Dynamic= [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100];
    public var comboColors                             : Dynamic= [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2];  // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood  
    public var enableComboColors                             : Dynamic= [true, true, true, false, false, false, false, false, false];
    public var receptorColors                             : Dynamic= [0xFFFFFF, 0xFFFFFF, 0x64FF64, 0xFFFF00, 0xBB8500, 0xA80000];
    public var enableReceptorColors                             : Dynamic= [true, true, true, true, true, false];
    public var gameColors                             : Dynamic= [0x1495BD, 0x033242, 0x0C6A88, 0x074B62, 0x000000];
    public var noteColors                             : Dynamic= ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
    public var rawGoodTracker                             : Dynamic= 0;
    public var rawGoodsColor                             : Dynamic= 0xDC00C2;
    
    public var autofailAmazing                             : Dynamic= 0;
    public var autofailPerfect                             : Dynamic= 0;
    public var autofailGood                             : Dynamic= 0;
    public var autofailAverage                             : Dynamic= 0;
    public var autofailMiss                             : Dynamic= 0;
    public var autofailBoo                             : Dynamic= 0;
    public var autofailRawGoods                             : Dynamic= 0;
    public var autofailAaaEquiv                             : Dynamic= 0;
    public var autofailRestart                             : Dynamic= false;
    public var personalBestMode                             : Dynamic= false;
    public var personalBestTracker                             : Dynamic= false;
    
    public var keyLeft                             : Dynamic= Keyboard.LEFT;
    public var keyDown                             : Dynamic= Keyboard.DOWN;
    public var keyUp                             : Dynamic= Keyboard.UP;
    public var keyRight                             : Dynamic= Keyboard.RIGHT;
    public var keyRestart                             : Dynamic= Keyboard.SLASH;
    public var keyQuit                             : Dynamic= Keyboard.CONTROL;
    public var keyOptions                             : Dynamic= 145;  // Scrolllock  
    
    public var activeNoteskin                             : Dynamic= 1;
    public var activeMods                             : Dynamic= [];
    public var activeVisualMods                             : Dynamic= [];
    public var slideDirection                             : Dynamic= "up";
    public var judgeSpeed                             : Dynamic= 1;
    public var gameSpeed                             : Dynamic= 1.5;
    public var receptorGap                             : Dynamic= 80;
    public var receptorSpeed                             : Dynamic= 1;
    public var judgeScale                             : Dynamic= 1;
    public var noteScale                             : Dynamic= 1;
    public var gameVolume                             : Dynamic= 1;
    public var screencutPosition                             : Dynamic= 0.5;
    public var frameRate                             : Dynamic= 60;
    public var songRate                             : Dynamic= 1;
    public var gameLayout                             : Dynamic= { };
    public var accuracyBarFadeFactor                             : Dynamic= 0.95;
    public var visualHypeMode                             : Dynamic= "full";
    
    //- Permissions
    public var isActiveUser                             : Dynamic;
    public var isGuest                             : Dynamic;
    public var isPlayer                             : Dynamic;
    public var isVeteran                             : Dynamic;
    public var isAdmin                             : Dynamic;
    public var isDeveloper                             : Dynamic;
    public var isForumBanned                             : Dynamic;
    public var isGameBanned                             : Dynamic;
    public var isProfileBanned                             : Dynamic;
    public var isModerator                             : Dynamic;
    public var isForumModerator                             : Dynamic;
    public var isProfileModerator                             : Dynamic;
    public var isChatModerator                             : Dynamic;
    public var isMultiModerator                             : Dynamic;
    public var isMusician                             : Dynamic;
    public var isSimArtist                             : Dynamic;
    
    ///- Constructor
    /**
     * Defines the creation of a new User object.
     *
     * @param	loadData Loads the user data on creation.
     * @param	isActiveUser Sets the active user flag.
     * @tiptext
     */
    public function new(loadData                             : Dynamic= false, isActiveUser                             : Dynamic= false, siteId                             : Dynamic= -1)
    {
        super();
        this.siteId = siteId;
        this.isActiveUser = isActiveUser;
        
        if (as3hx.Compat.truthy(loadData))
        {
            if (as3hx.Compat.truthy(siteId > -1))
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
        var rankTotal                             : Dynamic= 0;
        for (levelRank/* AS3HX WARNING could not determine type for var: levelRank exp: EField(EIdent(this),level_ranks) type: null */ in as3hx.Compat.iter(this.level_ranks))
        {
            var genre                             : Dynamic= levelRank.genre;
            if (as3hx.Compat.truthy(genre != 10 && genre != 12 && genre != 23))
            {
                rankTotal += levelRank.rank;
            }
        }
        this.averageRank = (rankTotal / _gvars.TOTAL_PUBLIC_SONGS);
    }
    
    ///- Determine what songs make up the user's Skill Rating
    public function getUserSkillRatingData() : Void
    {
        for (key in as3hx.Compat.iter(Reflect.fields(this.level_ranks)))
        {
            var levelRank                             : Dynamic= this.level_ranks[key];
            
            //Calculate the AAA Equiv for the scores on the song if greater than 0
            if (as3hx.Compat.truthy(levelRank.score > 0)) {
var songInfo                             : Dynamic= _playlist.getSongInfo(as3hx.Compat.parseInt(key));
                
                if (as3hx.Compat.truthy(songInfo == null || songInfo.is_unranked))
                {
                    continue;
                }
                
                //Calculate the song's equiv
                levelRank.equiv = SkillRating.calcSongWeightFromScore(levelRank.rawscore, songInfo);
                
                //Add it to the Skill Rating list if it's not 0
                if (as3hx.Compat.truthy(levelRank.equiv > 0))
                {
                    skill_rating_levelranks.push(levelRank);
                }
            }
        }
        
        //Sort based on equiv
        skill_rating_levelranks.sort(equivSort);
        
        //Dump all but the top X
        if (as3hx.Compat.truthy(skill_rating_levelranks.length > skill_rating_top_count))
        {
            as3hx.Compat.setArrayLength(skill_rating_levelranks, skill_rating_top_count);
        }
    }
    
    public function equivSort(a                             : Dynamic, b                             : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(a.equiv < b.equiv))
        {
            return 1;
        }
        else if (as3hx.Compat.truthy(a.equiv > b.equiv))
        {
            return -1;
        }
        else
        {
            return 0;
        }
    }
    
    public function updateSRList(newLevelRanks                             : Dynamic) : Void
    {
        var worseLevelRank                             : Dynamic= skill_rating_levelranks[as3hx.Compat.parseInt(skill_rating_top_count - 1)];
        if (as3hx.Compat.truthy(worseLevelRank == null || newLevelRanks.equiv > worseLevelRank.equiv)) {
if (as3hx.Compat.truthy(worseLevelRank != null))
            {
                var i                             : Dynamic= as3hx.Compat.parseInt(skill_rating_levelranks.length - 1);
                while (as3hx.Compat.truthy(i >= 0))
                {
                    if (as3hx.Compat.truthy(skill_rating_levelranks[i].id == newLevelRanks.id)) {
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
            if (as3hx.Compat.truthy(skill_rating_levelranks.length > skill_rating_top_count))
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
        
        if (as3hx.Compat.truthy(_loader != null && _isLoading))
        {
            removeLoaderListeners();
            _loader.close();
        }
        
        Logger.info(this, "Main User Load Requested");
        _isLoaded = false;
        _loadError = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                             : Dynamic= new URLRequest(URLs.resolve(URLs.USER_INFO_URL) + "?d=" + Date.now().getTime());
        var requestVars                             : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        _isLoading = true;
    }
    
    public function loadUser(userid                             : Dynamic) : Void
    {
        Logger.info(this, "Secondary User Load Requested");
        _isLoaded = false;
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                             : Dynamic= new URLRequest(URLs.resolve(URLs.USER_INFO_LITE_URL) + "?d=" + Date.now().getTime());
        var requestVars                             : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.userid = userid;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        _isLoading = true;
    }
    
    private function profileLoadComplete(e                             : Dynamic) : Void
    {
        Logger.success(this, "Profile Load Success");
        removeLoaderListeners();
        
        // Parse Response
        var _data                             : Dynamic= null;
        var siteDataString                             : Dynamic= e.target.data;
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
        
        if (as3hx.Compat.truthy(isActiveUser))
        {
            loadLevelRanks();
        }
        else
        {
            _isLoaded = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
    }
    
    public function loadUserData(_data                             : Dynamic) : Void
    // Private
    {
        
        if (as3hx.Compat.truthy(isActiveUser))
        {
            this.hash = _data.hash;
            this.credits = _data.credits;
            setPurchasedString(Reflect.field(_data, "purchased"));
            if (as3hx.Compat.truthy(Reflect.field(_data, "song_ratings") != null))
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
        if (as3hx.Compat.truthy(Reflect.field(_data, "settings") != null && !this.isGuest))
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
    
    public function setPurchasedString(str                             : Dynamic) : Void
    {
        this.purchased = [];
        for (x in 1...str.length)
        {
            this.purchased.push(str.charAt(x) == "1");
        }
    }
    
    private function profileLoadError(err                             : Dynamic= null) : Void
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
        var _loader                             : Dynamic= new Loader();
        
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, avatarLoadComplete);
        _loader.load(new URLRequest(URLs.resolve(URLs.USER_AVATAR_URL) + "?uid=" + this.siteId + "&cHeight=99&cWidth=99"));
        
        avatarLoadComplete = function(e                             : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(isActiveUser && !isGuest))
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
        
        var req                             : Dynamic= new URLRequest(URLs.resolve(URLs.USER_RANKS_URL));
        var requestVars                             : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
    }
    
    private function ranksLoadComplete(e                             : Dynamic) : Void
    {
        Logger.success(this, "Ranks Load Success");
        removeLoaderRanksListeners();
        level_ranks = {};
        
        // Check Level ranks for Non-empty
        if (as3hx.Compat.truthy(e.target.data != ""))
        {
            var ranksTemp                             : Dynamic= e.target.data.split(",");
            var rankLength                             : Dynamic= ranksTemp.length;
            for (x in 0...rankLength) {
var rankSplit                             : Dynamic= as3hx.Compat.field(ranksTemp, x).split(":");
                
                // [0]'perfect' - [1]'good' - [2]'average' - [3]'miss' - [4]'boo' - [5]'maxcombo'
                var scoreResults                             : Dynamic= rankSplit[4].split("-");
                for (s in as3hx.Compat.iter(Reflect.fields(scoreResults)))
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
    
    private function ranksLoadError(err                             : Dynamic= null) : Void
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
    
    private function set_settings(_settings                             : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(_settings == null))
        {
            return _settings;
        }
        
        if (as3hx.Compat.truthy(_settings.language != null))
        {
            this.language = _settings.language;
        }
        
        if (as3hx.Compat.truthy(_settings.viewOffset != null))
        {
            this.GLOBAL_OFFSET = _settings.viewOffset;
        }
        
        if (as3hx.Compat.truthy(_settings.visualDelay != null))
        {
            this.VISUAL_DELAY = _settings.visualDelay;
        }
        
        if (as3hx.Compat.truthy(_settings.judgeOffset != null))
        {
            this.JUDGE_OFFSET = _settings.judgeOffset;
        }
        
        if (as3hx.Compat.truthy(_settings.autoJudgeOffset != null))
        {
            this.AUTO_JUDGE_OFFSET = _settings.autoJudgeOffset;
        }
        
        if (as3hx.Compat.truthy(_settings.viewSongFlag != null))
        {
            this.DISPLAY_SONG_FLAG = _settings.viewSongFlag;
        }
        
        if (as3hx.Compat.truthy(_settings.viewGenreFlag != null))
        {
            this.DISPLAY_GENRE_FLAG = _settings.viewGenreFlag;
        }
        
        if (as3hx.Compat.truthy(_settings.viewSongNote != null))
        {
            this.DISPLAY_SONG_NOTE = _settings.viewSongNote;
        }
        
        if (as3hx.Compat.truthy(_settings.viewJudge != null))
        {
            this.DISPLAY_JUDGE = _settings.viewJudge;
        }
        
        if (as3hx.Compat.truthy(_settings.viewJudgeAnimations != null))
        {
            this.DISPLAY_JUDGE_ANIMATIONS = _settings.viewJudgeAnimations;
        }
        
        if (as3hx.Compat.truthy(_settings.viewReceptorAnimations != null))
        {
            this.DISPLAY_RECEPTOR_ANIMATIONS = _settings.viewReceptorAnimations;
        }
        
        if (as3hx.Compat.truthy(_settings.viewHealth != null))
        {
            this.DISPLAY_HEALTH = _settings.viewHealth;
        }
        
        if (as3hx.Compat.truthy(_settings.viewGameTopBar != null))
        {
            this.DISPLAY_GAME_TOP_BAR = _settings.viewGameTopBar;
        }
        
        if (as3hx.Compat.truthy(_settings.viewGameBottomBar != null))
        {
            this.DISPLAY_GAME_BOTTOM_BAR = _settings.viewGameBottomBar;
        }
        
        if (as3hx.Compat.truthy(_settings.viewScore != null))
        {
            this.DISPLAY_SCORE = _settings.viewScore;
        }
        
        if (as3hx.Compat.truthy(_settings.viewCombo != null))
        {
            this.DISPLAY_COMBO = _settings.viewCombo;
        }
        
        if (as3hx.Compat.truthy(_settings.viewRawGoods != null))
        {
            this.DISPLAY_RAWGOODS = _settings.viewRawGoods;
        }
        
        if (as3hx.Compat.truthy(_settings.viewPACount != null))
        {
            this.DISPLAY_PACOUNT = _settings.viewPACount;
        }
        
        if (as3hx.Compat.truthy(_settings.viewAccBar != null))
        {
            this.DISPLAY_ACCURACY_BAR = _settings.viewAccBar;
        }
        
        if (as3hx.Compat.truthy(_settings.viewAmazing != null))
        {
            this.DISPLAY_AMAZING = _settings.viewAmazing;
        }
        
        if (as3hx.Compat.truthy(_settings.viewPerfect != null))
        {
            this.DISPLAY_PERFECT = _settings.viewPerfect;
        }
        
        if (as3hx.Compat.truthy(_settings.viewTotal != null))
        {
            this.DISPLAY_TOTAL = _settings.viewTotal;
        }
        
        if (as3hx.Compat.truthy(_settings.viewScreencut != null))
        {
            this.DISPLAY_SCREENCUT = _settings.viewScreencut;
        }
        
        if (as3hx.Compat.truthy(_settings.viewSongProgress != null))
        {
            this.DISPLAY_SONGPROGRESS = _settings.viewSongProgress;
        }
        
        if (as3hx.Compat.truthy(_settings.viewSongProgressText != null))
        {
            this.DISPLAY_SONGPROGRESS_TEXT = _settings.viewSongProgressText;
        }
        
        if (as3hx.Compat.truthy(_settings.viewMultiplayerScores != null))
        {
            this.DISPLAY_MULTIPLAYER_SCORES = _settings.viewMultiplayerScores;
        }
        
        if (as3hx.Compat.truthy(_settings.viewMPTimestamp != null))
        {
            this.DISPLAY_MP_TIMESTAMP = _settings.viewMPTimestamp;
        }
        
        if (as3hx.Compat.truthy(_settings.viewLegacySongs != null))
        {
            this.DISPLAY_LEGACY_SONGS = _settings.viewLegacySongs;
        }
        
        if (as3hx.Compat.truthy(_settings.viewExplicitSongs != null))
        {
            this.DISPLAY_EXPLICIT_SONGS = _settings.viewExplicitSongs;
        }
        
        if (as3hx.Compat.truthy(_settings.viewUnrankedSongs != null))
        {
            this.DISPLAY_UNRANKED_SONGS = _settings.viewUnrankedSongs;
        }
        
        if (as3hx.Compat.truthy(_settings.keys[0] != null))
        {
            this.keyLeft = _settings.keys[0];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[1] != null))
        {
            this.keyDown = _settings.keys[1];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[2] != null))
        {
            this.keyUp = _settings.keys[2];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[3] != null))
        {
            this.keyRight = _settings.keys[3];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[4] != null))
        {
            this.keyRestart = _settings.keys[4];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[5] != null))
        {
            this.keyQuit = _settings.keys[5];
        }
        
        if (as3hx.Compat.truthy(_settings.keys[6] != null))
        {
            this.keyOptions = _settings.keys[6];
        }
        
        if (as3hx.Compat.truthy(_settings.noteskin != null))
        {
            this.activeNoteskin = _settings.noteskin;
        }
        
        if (as3hx.Compat.truthy(_settings.direction != null))
        {
            this.slideDirection = _settings.direction;
        }
        
        if (as3hx.Compat.truthy(_settings.speed != null))
        {
            this.gameSpeed = _settings.speed;
        }
        
        if (as3hx.Compat.truthy(_settings.judgeSpeed != null))
        {
            this.judgeSpeed = _settings.judgeSpeed;
        }
        
        if (as3hx.Compat.truthy(_settings.receptorSpeed != null))
        {
            this.receptorSpeed = _settings.receptorSpeed;
        }
        
        if (as3hx.Compat.truthy(_settings.judgeScale != null))
        {
            this.judgeScale = _settings.judgeScale;
        }
        
        if (as3hx.Compat.truthy(_settings.gap != null))
        {
            this.receptorGap = _settings.gap;
        }
        
        if (as3hx.Compat.truthy(_settings.noteScale != null))
        {
            this.noteScale = _settings.noteScale;
        }
        
        if (as3hx.Compat.truthy(_settings.accuracyBarFadeFactor != null))
        {
            this.accuracyBarFadeFactor = _settings.accuracyBarFadeFactor;
        }
        
        if (as3hx.Compat.truthy(_settings.visualHypeMode != null))
        {
            this.visualHypeMode = _settings.visualHypeMode;
        }
        
        if (as3hx.Compat.truthy(_settings.screencutPosition != null))
        {
            this.screencutPosition = _settings.screencutPosition;
        }
        
        if (as3hx.Compat.truthy(_settings.frameRate != null))
        {
            this.frameRate = _settings.frameRate;
        }
        
        if (as3hx.Compat.truthy(_settings.songRate != null))
        {
            this.songRate = _settings.songRate;
        }
        
        if (as3hx.Compat.truthy(_settings.autofailRestart != null))
        {
            this.autofailRestart = _settings.autofailRestart;
        }
        
        if (as3hx.Compat.truthy(_settings.personalBestMode != null))
        {
            this.personalBestMode = _settings.personalBestMode;
        }
        
        if (as3hx.Compat.truthy(_settings.personalBestTracker != null))
        {
            this.personalBestTracker = _settings.personalBestTracker;
        }
        
        if (as3hx.Compat.truthy(_settings.visual != null))
        {
            this.activeVisualMods = _settings.visual;
        }
        
        if (as3hx.Compat.truthy(_settings.judgeColours != null))
        {
            mergeIntoArray(this.judgeColors, _settings.judgeColours);
        }
        
        if (as3hx.Compat.truthy(_settings.comboColours != null))
        {
            mergeIntoArray(this.comboColors, _settings.comboColours);
        }
        
        if (as3hx.Compat.truthy(_settings.rawGoodsColor != null))
        {
            this.rawGoodsColor = _settings.rawGoodsColor;
        }
        
        if (as3hx.Compat.truthy(_settings.enableComboColors != null))
        {
            mergeIntoArray(this.enableComboColors, _settings.enableComboColors);
        }
        
        if (as3hx.Compat.truthy(_settings.receptorColours != null))
        {
            mergeIntoArray(this.receptorColors, _settings.receptorColours);
        }
        
        if (as3hx.Compat.truthy(_settings.enableReceptorColors != null))
        {
            mergeIntoArray(this.enableReceptorColors, _settings.enableReceptorColors);
        }
        
        if (as3hx.Compat.truthy(_settings.gameColours != null))
        {
            mergeIntoArray(this.gameColors, _settings.gameColours);
        }
        
        if (as3hx.Compat.truthy(_settings.noteColours != null))
        {
            mergeIntoArray(this.noteColors, _settings.noteColours);
        }
        
        if (as3hx.Compat.truthy(_settings.rawGoodTracker != null))
        {
            this.rawGoodTracker = _settings.rawGoodTracker;
        }
        
        if (as3hx.Compat.truthy(_settings.gameVolume != null))
        {
            this.gameVolume = _settings.gameVolume;
        }
        
        if (as3hx.Compat.truthy(_settings.layout != null))
        {
            this.gameLayout = doLayoutImport(_settings.layout);
        }
        
        if (as3hx.Compat.truthy(_settings.filters != null))
        {
            this.filters = doImportFilters(_settings.filters);
        }
        
        if (as3hx.Compat.truthy(_settings.songQueues != null))
        {
            this.songQueues = [];
            for (queueItem/* AS3HX WARNING could not determine type for var: queueItem exp: EField(EIdent(_settings),songQueues) type: null */ in as3hx.Compat.iter(_settings.songQueues))
            {
                this.songQueues.push(new SongQueueItem(queueItem.name, queueItem.items));
            }
        }
        
        if (as3hx.Compat.truthy(isActiveUser))
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
        
        mergeIntoArray = function(arr1                             : Dynamic, arr2                             : Dynamic) : Void
        {
            var minArrLen                             : Dynamic= Math.min(arr1.length, arr2.length);
            for (i in 0...minArrLen)
            {
                Reflect.setField(arr1, Std.string(i), as3hx.Compat.field(arr2, i));
            }
        }
        return _settings;
    }
    
    public function save(returnObject                             : Dynamic= false) : Dynamic
    {
        if (as3hx.Compat.truthy(isGuest && !returnObject))
        {
            return { };
        }
        
        var gameSave                             : Dynamic= { };
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
        
        if (as3hx.Compat.truthy(returnObject))
        {
            return gameSave;
        }
        
        //- Save to server
        _loader = new URLLoader();
        addLoaderSaveListeners();
        
        var req                             : Dynamic= new URLRequest(URLs.resolve(URLs.USER_SAVE_SETTINGS_URL));
        var requestVars                             : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        requestVars.settings = haxe.Json.stringify(gameSave);
        requestVars.action = "save";
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        
        return { };
    }
    
    private function settingSaveComplete(e                             : Dynamic) : Void
    {
        Logger.success(this, "Settings Save Success");
        removeLoaderSaveListeners();
        this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
    }
    
    private function settingLoadError(err                             : Dynamic= null) : Void
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
        var encodedSettings                             : Dynamic= LocalStore.getVariable("sEncode", null);
        if (as3hx.Compat.truthy(encodedSettings != null))
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
    
    public function getLevelRank(songInfo                             : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(songInfo.engine))
        {
            return ArcGlobals.instance.legacyLevelRanksGet(songInfo);
        }
        
        if (as3hx.Compat.truthy(as3hx.Compat.field(level_ranks, songInfo.level) == null))
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
        
        return as3hx.Compat.field(level_ranks, songInfo.level);
    }
    
    public function getSongRating(songInfo                             : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(songInfo.engine != null))
        {
            var sDetails                             : Dynamic= UserSongNotes.getSongDetails(songInfo.engine.id, songInfo.level_id);
            if (as3hx.Compat.truthy(sDetails != null))
            {
                return sDetails.song_rating;
            }
            
            return 0;
        }
        return (as3hx.Compat.field(songRatings, songInfo.level) != null) ? as3hx.Compat.field(songRatings, songInfo.level) : 0;
    }
    
    /**
     * Imports user filters from a save object.
     * @param	filtersIn Array of Filter objects.
     * @return Array of EngineLevelFilters.
     */
    private function doImportFilters(filtersIn                             : Dynamic) : Array<EngineLevelFilter>
    {
        if (as3hx.Compat.truthy(isActiveUser))
        {
            _gvars.activeFilter = null;
        }
        
        var newFilters                             : Dynamic= [];
        var filter                             : Dynamic= null;
        for (item in as3hx.Compat.iter(filtersIn))
        {
            filter = new EngineLevelFilter();
            filter.setup(item);
            newFilters.push(filter);
            
            if (as3hx.Compat.truthy(filter.is_default))
            {
                if (as3hx.Compat.truthy(_gvars.activeFilter == null && isActiveUser))
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
    private function doExportFilters(filtersOut                             : Dynamic) : Array<Dynamic>
    {
        var filters                             : Dynamic= [];
        for (item in as3hx.Compat.iter(filtersOut))
        {
            var exportFilter                             : Dynamic= item.export();
            if (as3hx.Compat.truthy(Reflect.field(exportFilter, "filters") != null && Reflect.field(exportFilter, "filters").length > 0)) {
filters.push(exportFilter);
            }
        }
        return filters;
    }
    
    private function doLayoutImport(data                             : Dynamic) : Dynamic
    {
        var out                             : Dynamic= { };
        var keys                             : Dynamic= ["sp", "mp"];
        
        for (key in as3hx.Compat.iter(keys))
        {
            if (as3hx.Compat.truthy(as3hx.Compat.field(data, key) == null))
            {
                continue;
            }
            
            if (as3hx.Compat.truthy(Std.string(as3hx.Compat.field(data, key).constructor).indexOf("Object") != -1))
            {
                Reflect.setField(out, Std.string(key), as3hx.Compat.field(data, key));
            }
        }
        
        return out;
    }
}

