package classes.replay;

import openfl.errors.Error;
import arc.ArcGlobals;
import by.blooddy.crypto.Base64;
import by.blooddy.crypto.MD5;
import classes.Alert;
import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.User;
import classes.replay.ReplayPack;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.utils.ByteArray;
import menu.FileLoader;

class Replay
{
    public var songname(get, never)                             : Dynamic;

    private var _gvars                             : Dynamic= GlobalVariables.instance;
    private var _loader                             : Dynamic;
    
    public var fileReplay                             : Dynamic= false;
    public var filePath                             : Dynamic;
    
    public var chartPath                             : Dynamic;
    public var cacheID                             : Dynamic;
    
    public var replayBin                             : Dynamic;
    
    public var isLoaded                             : Dynamic= false;
    public var isEdited                             : Dynamic= false;
    public var isPreview                             : Dynamic= false;
    public var isFileLoader                             : Dynamic= false;
    
    public var needsBeatboxGeneration                             : Dynamic= false;
    public var generationReplayBoos                             : Dynamic;
    public var generationReplayNotes                             : Dynamic;
    
    public var id                             : Dynamic;
    public var user                             : Dynamic;
    public var level                             : Dynamic;
    public var settings                             : Dynamic;
    public var score                             : Dynamic;
    public var perfect                             : Dynamic;
    public var good                             : Dynamic;
    public var average                             : Dynamic;
    public var miss                             : Dynamic;
    public var boo                             : Dynamic;
    public var maxcombo                             : Dynamic;
    public var replayData                             : Dynamic;
    public var timestamp                             : Dynamic;
    
    public var song                             : Dynamic;
    
    public function new(id                             : Dynamic, doLoad                             : Dynamic= false)
    {
        this.id = id;
        
        if (as3hx.Compat.truthy(doLoad))
        {
            load();
        }
    }
    
    private function load() : Void
    {
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                             : Dynamic= new URLRequest(URLs.resolve(URLs.USER_LOAD_REPLAY_URL));
        var urlVars                             : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(urlVars);
        
        // Post Game Data
        urlVars.id = id;
        
        // Set Request
        req.data = urlVars;
        req.method = URLRequestMethod.POST;
        
        // Load
        _loader.load(req);
    }
    
    private function replayLoadComplete(e                             : Dynamic) : Void
    {
        removeLoaderListeners();
        var site_data                             : Dynamic= haxe.Json.parse(e.target.data);
        if (as3hx.Compat.truthy(site_data.result != 1))
        {
            parseReplay(site_data);
        }
        else
        {
            isLoaded = true;
        }
    }
    
    private function replayLoadError(e                             : Dynamic) : Void
    {
        removeLoaderListeners();
    }
    
    public function parseReplay(data                             : Dynamic, loadUser                             : Dynamic= true) : Void
    {
        if (as3hx.Compat.truthy(data == null))
        {
            return;
        }
        
        var jsonSettings                             : Dynamic= null;
        
        //- Level Details
        this.user = new User(loadUser, false, data.userid);
        this.user.addEventListener(GlobalVariables.LOAD_COMPLETE, userLoad);
        if (as3hx.Compat.truthy(!loadUser))
        {
            this.user.siteId = data.userid;
        }
        this.level = data.replaylevelid;
        this.timestamp = data.timestamp;
        
        //- Score Data
        var tempScore                             : Dynamic= data.replayscore.split("|");
        this.score = tempScore[0];
        this.perfect = tempScore[1];
        this.good = tempScore[2];
        this.average = tempScore[3];
        this.miss = tempScore[4];
        this.boo = tempScore[5];
        this.maxcombo = tempScore[6];
        this.score = (perfect * 50) + (good * 25) + (average * 5) - (miss * 10) - (boo * 5);
        
        //- Settings
        var tempSettings                             : Dynamic= data.replaysettings;
        
        // Legacy / Velo
        var mirrorIndex                             : Dynamic= -1;
        if (as3hx.Compat.truthy(data.replayversion == "FFR"))
        {
            tempSettings = tempSettings.split("|");
            jsonSettings = (_gvars.playerUser.isGuest) ? new User().settings : _gvars.playerUser.settings;
            jsonSettings.speed = as3hx.Compat.parseFloat(as3hx.Compat.field(tempSettings, 0));
            jsonSettings.direction = cleanScrollDirection(as3hx.Compat.field(tempSettings, 2));
            jsonSettings.songRate = 1;
            if (as3hx.Compat.truthy(tempSettings.length >= 12))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.field(tempSettings, 11) == "Mirror"))
                {
                    jsonSettings.visual.push("mirror");
                }
                else if (as3hx.Compat.truthy((mirrorIndex = jsonSettings.visual.indexOf("mirror")) >= 0))
                {
                    jsonSettings.visual.splice(mirrorIndex, 1);
                }
            }
            jsonSettings.viewOffset = 0;
            jsonSettings.visualDelay = 0;
            jsonSettings.judgeOffset = 0;
            this.settings = jsonSettings;
        }
        else if (as3hx.Compat.truthy(data.replayversion == "R^2"))
        {
            tempSettings = tempSettings.split(",");
            for (ss in 0...tempSettings.length)
            {
                Reflect.setField(tempSettings, Std.string(ss), as3hx.Compat.field(tempSettings, ss).split("|"));
            }
            jsonSettings = (_gvars.playerUser.isGuest) ? new User().settings : _gvars.playerUser.settings;
            jsonSettings.speed = as3hx.Compat.parseFloat(Reflect.field(as3hx.Compat.field(tempSettings, 0), Std.string(1)));
            jsonSettings.direction = cleanScrollDirection(Reflect.field(as3hx.Compat.field(tempSettings, 0), Std.string(0)));
            jsonSettings.songRate = 1;
            if (as3hx.Compat.truthy(Reflect.field(as3hx.Compat.field(tempSettings, 0), Std.string(2)) == "true"))
            {
                jsonSettings.visual.push("mirror");
            }
            else if (as3hx.Compat.truthy((mirrorIndex = jsonSettings.visual.indexOf("mirror")) >= 0))
            {
                jsonSettings.visual.splice(mirrorIndex, 1);
            }
            jsonSettings.gap = as3hx.Compat.parseFloat(Reflect.field(as3hx.Compat.field(tempSettings, 2), Std.string(0)));
            jsonSettings.noteskin = as3hx.Compat.parseFloat(Reflect.field(as3hx.Compat.field(tempSettings, 2), Std.string(3)));
            jsonSettings.viewOffset = 0;
            jsonSettings.visualDelay = 0;
            jsonSettings.judgeOffset = 0;
            this.settings = jsonSettings;
        }
        // R^3 Replay JSON
        else if (as3hx.Compat.truthy(data.replayversion == "R^3"))
        {
            this.settings = haxe.Json.parse(data.replaysettings);
        }
        
        //- Frames
        var tempReplay                             : Dynamic= data.replayframes;
        replayData = [];
        
        //- Clean up
        // Legacy Replay Format ((LDUR),(FRAME)|), Handled in the Velo Converter
        if (as3hx.Compat.truthy(tempReplay.indexOf(",") > -1))
        {
            tempReplay = new as3hx.Compat.Regex(',', "g").replace(tempReplay, "");
        }
        
        //- Conversion
        // Velocity Replay Format ((LDUR)(FRAME)|)
        if (as3hx.Compat.truthy(tempReplay.indexOf("|") > -1))
        {
            parseVelocityReplay(tempReplay);
        }
        // R^2/3 Replay Format ((WXYZ)(FRAME))
        else if (as3hx.Compat.truthy(tempReplay.charCodeAt(0) >= 87 && tempReplay.charCodeAt(0) <= 90))
        {
            parserRCubedReplay(tempReplay, data.replayversion);
        }
    }
    
    private function parseReplayPack(data                             : Dynamic, loadUser                             : Dynamic= true) : Void
    {
        if (as3hx.Compat.truthy(data == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(data.error != null))
        {
            Alert.add(data.error, 120, Alert.RED);
            return;
        }
        
        //- Level Details
        this.user = new User(loadUser, false);
        this.user.addEventListener(GlobalVariables.LOAD_COMPLETE, userLoad);
        this.user.siteId = data.user_id;
        this.level = data.song_id;
        this.timestamp = data.timestamp;
        
        //- Score Data
        this.perfect = (as3hx.Compat.field(data.judgements, "perfect") + as3hx.Compat.field(data.judgements, "amazing"));
        this.good = as3hx.Compat.field(data.judgements, "good");
        this.average = as3hx.Compat.field(data.judgements, "average");
        this.miss = as3hx.Compat.field(data.judgements, "miss");
        this.boo = as3hx.Compat.field(data.judgements, "boo");
        this.maxcombo = as3hx.Compat.field(data.judgements, "maxcombo");
        this.score = (perfect * 50) + (good * 25) + (average * 5) - (miss * 10) - (boo * 5);
        
        this.settings = data.settings;
        
        //- Replay
        this.replayData = [];
        for (item/* AS3HX WARNING could not determine type for var: item exp: EField(EIdent(data),rep_boos) type: null */ in as3hx.Compat.iter(data.rep_boos))
        {
            this.replayData[replayData.length] = new ReplayNote(item.direction, -2, item.time);
        }
        
        //- Edited Check
        if (as3hx.Compat.truthy(data.checksum != data.rechecksum))
        {
            isEdited = true;
        }
        
        this.replayBin = data.replay_bin;
        this.generationReplayNotes = data.rep_notes;
        this.generationReplayBoos = data.rep_boos;
        this.needsBeatboxGeneration = true;
    }
    
    //// Parsers
    private function parseVelocityReplay(_input                             : Dynamic) : Void
    {
        var tempReplay                             : Dynamic= _input.split("|");
        for (x in 0...tempReplay.length)
        {
            var dir                             : Dynamic= tempReplay[x].charAt(0);
            var frame                             : Dynamic= as3hx.Compat.parseInt("0x" + tempReplay[x].substr(1));
            this.replayData[replayData.length] = new ReplayNote(dir, frame - 30);
        }
    }
    
    private function parserRCubedReplay(_input                             : Dynamic, _version                             : Dynamic) : Void
    {
        var offsetf                             : Dynamic= ((_version == "R^2") ? 30 : 0);
        var totalReplay                             : Dynamic= 0;
        var lastFrame                             : Dynamic= 0;
        var noteVal                             : Dynamic= "";
        var noteDir                             : Dynamic= "";
        var game_curChar                             : Dynamic= null;
        var game_nexChar                             : Dynamic= null;
        for (x in 0..._input.length)
        {
            game_curChar = _input.charAt(x);
            game_nexChar = _input.charAt(x + 1);
            if (as3hx.Compat.truthy(game_nexChar == false || game_nexChar == "" || game_nexChar == "W" || game_nexChar == "X" || game_nexChar == "Y" || game_nexChar == "Z"))
            {
                var dir                             : Dynamic= getDirCol(noteDir);
                var frame                             : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt("0x" + noteVal + game_curChar) + lastFrame);
                this.replayData[replayData.length] = new ReplayNote(dir, frame - offsetf);
                lastFrame = frame;
            }
            else if (as3hx.Compat.truthy(game_curChar == "W" || game_curChar == "X" || game_curChar == "Y" || game_curChar == "Z"))
            {
                noteDir = game_curChar;
                noteVal = "";
            }
            else
            {
                noteVal += game_curChar;
            }
        }
    }
    
    /////
    private function get_songname() : String
    {
        return song.name;
    }
    
    public function loadSongInfo() : Void
    {
        if (as3hx.Compat.truthy(settings.arc_engine)) {
if (as3hx.Compat.truthy(settings.arc_engine.engineID == "fileloader"))
            {
                cacheID = settings.arc_engine.cacheID;
                chartPath = FileLoader.cache.findKey(function(entry                             : Dynamic) : Dynamic
                                {
                                    return Reflect.field(entry, "id") == settings.arc_engine.cacheID;
                                });
                
                if (as3hx.Compat.truthy(chartPath == null))
                {
                    return;
                }
                
                isFileLoader = true;
                return;
            }
            
            // Alt Engines
            song = ArcGlobals.instance.legacyDecode(settings.arc_engine);
            return;
        }
        song = Playlist.instanceCanon.getSongInfo(level);
    }
    
    private function getDirCol(noteDir                             : Dynamic) : String
    {
        switch (noteDir)
        {
            case "W":
                return "L";
            case "X":
                return "D";
            case "Y":
                return "U";
            case "Z":
                return "R";
            default:
                return noteDir;
        }
        return noteDir;
    }
    
    private function userLoad(e                             : Dynamic) : Void
    {
        this.user.removeEventListener(GlobalVariables.LOAD_COMPLETE, userLoad);
        this.user.settings = this.settings;
        isLoaded = true;
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, replayLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, replayLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, replayLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, replayLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, replayLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, replayLoadError);
    }
    
    /////
    public function getPress(index                             : Dynamic) : ReplayNote
    {
        return replayData[index];
    }
    
    public function getEncode(onlyBinReplay                             : Dynamic= false) : String
    {
        if (as3hx.Compat.truthy(replayBin != null))
        {
            return ReplayPack.MAGIC + "|" + Base64.encode(replayBin);
        }
        
        if (as3hx.Compat.truthy(!onlyBinReplay))
        {
            var sT                             : Dynamic= (perfect * 550) + (good * 275) + (average * 55) + (maxcombo * 1000) - (miss * 310) - (boo * 20);
            var o                             : Dynamic= { };
            o.userid = this.user.siteId;
            o.replaylevelid = this.level;
            o.replaysettings = haxe.Json.stringify(this.settings);
            o.replayscore = (sT + "|" + perfect + "|" + good + "|" + average + "|" + miss + "|" + boo + "|" + maxcombo);
            o.replayframes = getReplayString(replayData);
            o.replayversion = "R^3";
            o.timestamp = timestamp;
            
            var outJson                             : Dynamic= haxe.Json.stringify(o);
            return (outJson + "|" + MD5.hash(outJson + "|" + MD5.hash(outJson)));
        }
        
        return null;
    }
    
    public function parseEncode(str                             : Dynamic, loadUser                             : Dynamic= true) : Void
    {
        try
        {
            if (as3hx.Compat.truthy(str.substr(0, 4) == ReplayPack.MAGIC))
            {
                parseReplayPack(ReplayPack.readReplay(Base64.decode(str.substr(5))), loadUser);
            }
            else
            {
                if (as3hx.Compat.truthy(str.charAt(str.length - 33) == "|"))
                {
                    var md5                             : Dynamic= str.substr(str.length - 32);
                    str = str.substr(0, str.length - 33);
                    if (as3hx.Compat.truthy(md5 != MD5.hash(str + "|" + MD5.hash(str))))
                    {
                        isEdited = true;
                    }
                }
                else
                {
                    isEdited = true;
                }
                parseReplay(haxe.Json.parse(str), loadUser);
            }
        }
        catch (e : Error)
        {
            Alert.add(Language.instance.string("replay_parse_error"));
        }
    }
    
    public function isValid() : Bool
    {
        return replayData != null;
    }
    
    public static function getReplayString(replay                             : Dynamic) : String
    // Build Replay String
    {
        
        var noteObj                             : Dynamic= null;
        var lastDifference                             : Dynamic= 0;
        var replayString                             : Dynamic= "";
        for (x in 0...replay.length)
        {
            noteObj = as3hx.Compat.field(replay, x);
            replayString += getReplayChar(noteObj.direction) + Std.string(noteObj.frame - lastDifference).toUpperCase();
            lastDifference = noteObj.frame;
        }
        return replayString;
    }
    
    public static function getReplayChar(dir                             : Dynamic) : String
    {
        if (as3hx.Compat.truthy(dir == "L"))
        {
            return "W";
        }
        if (as3hx.Compat.truthy(dir == "D"))
        {
            return "X";
        }
        if (as3hx.Compat.truthy(dir == "U"))
        {
            return "Y";
        }
        if (as3hx.Compat.truthy(dir == "R"))
        {
            return "Z";
        }
        return dir;
    }
    
    /**
     * Cleans the scroll direction from older engine names to the current names.
     * Only used on loaded replays to understand older scroll direction values.
     * @param dir
     * @return
     */
    public static function cleanScrollDirection(dir                             : Dynamic) : String
    {
        dir = dir.toLowerCase();
        
        switch (dir)
        {
            case "slideright":
                return "right";  // Legacy/Velocity  
            case "slideleft":
                return "left";  // Legacy/Velocity  
            case "rising":
                return "up";  // Legacy/Velocity  
            case "falling":
                return "down";  // Legacy/Velocity  
            case "diagonalley":
                return "diagonalley";
        }
        return dir;
    }
}

