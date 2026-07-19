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
    public var songname(get, never) : String;

    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _loader : URLLoader;
    
    public var fileReplay : Bool = false;
    public var filePath : String;
    
    public var chartPath : String;
    public var cacheID : String;
    
    public var replayBin : ByteArray;
    
    public var isLoaded : Bool = false;
    public var isEdited : Bool = false;
    public var isPreview : Bool = false;
    public var isFileLoader : Bool = false;
    
    public var needsBeatboxGeneration : Bool = false;
    public var generationReplayBoos : Array<ReplayBinFrame>;
    public var generationReplayNotes : Array<ReplayBinFrame>;
    
    public var id : Float;
    public var user : User;
    public var level : Int;
    public var settings : Dynamic;
    public var score : Float;
    public var perfect : Float;
    public var good : Float;
    public var average : Float;
    public var miss : Float;
    public var boo : Float;
    public var maxcombo : Float;
    public var replayData : Array<Dynamic>;
    public var timestamp : Float;
    
    public var song : SongInfo;
    
    public function new(id : Float, doLoad : Bool = false)
    {
        this.id = id;
        
        if (doLoad)
        {
            load();
        }
    }
    
    private function load() : Void
    {
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req : URLRequest = new URLRequest(URLs.resolve(URLs.USER_LOAD_REPLAY_URL));
        var urlVars : URLVariables = new URLVariables();
        Constant.addDefaultRequestVariables(urlVars);
        
        // Post Game Data
        urlVars.id = id;
        
        // Set Request
        req.data = urlVars;
        req.method = URLRequestMethod.POST;
        
        // Load
        _loader.load(req);
    }
    
    private function replayLoadComplete(e : Event) : Void
    {
        removeLoaderListeners();
        var site_data : Dynamic = haxe.Json.parse(e.target.data);
        if (site_data.result != 1)
        {
            parseReplay(site_data);
        }
        else
        {
            isLoaded = true;
        }
    }
    
    private function replayLoadError(e : Event) : Void
    {
        removeLoaderListeners();
    }
    
    public function parseReplay(data : Dynamic, loadUser : Bool = true) : Void
    {
        if (data == null)
        {
            return;
        }
        
        var jsonSettings : Dynamic;
        
        //- Level Details
        this.user = new User(loadUser, false, data.userid);
        this.user.addEventListener(GlobalVariables.LOAD_COMPLETE, userLoad);
        if (!loadUser)
        {
            this.user.siteId = data.userid;
        }
        this.level = data.replaylevelid;
        this.timestamp = data.timestamp;
        
        //- Score Data
        var tempScore : Array<Dynamic> = data.replayscore.split("|");
        this.score = tempScore[0];
        this.perfect = tempScore[1];
        this.good = tempScore[2];
        this.average = tempScore[3];
        this.miss = tempScore[4];
        this.boo = tempScore[5];
        this.maxcombo = tempScore[6];
        this.score = (perfect * 50) + (good * 25) + (average * 5) - (miss * 10) - (boo * 5);
        
        //- Settings
        var tempSettings : Dynamic = data.replaysettings;
        
        // Legacy / Velo
        var mirrorIndex : Int = -1;
        if (data.replayversion == "FFR")
        {
            tempSettings = tempSettings.split("|");
            jsonSettings = (_gvars.playerUser.isGuest) ? new User().settings : _gvars.playerUser.settings;
            jsonSettings.speed = as3hx.Compat.parseFloat(Reflect.field(tempSettings, Std.string(0)));
            jsonSettings.direction = cleanScrollDirection(Reflect.field(tempSettings, Std.string(2)));
            jsonSettings.songRate = 1;
            if (tempSettings.length >= 12)
            {
                if (Reflect.field(tempSettings, Std.string(11)) == "Mirror")
                {
                    jsonSettings.visual.push("mirror");
                }
                else if ((mirrorIndex = jsonSettings.visual.indexOf("mirror")) >= 0)
                {
                    jsonSettings.visual.splice(mirrorIndex, 1);
                }
            }
            jsonSettings.viewOffset = 0;
            jsonSettings.visualDelay = 0;
            jsonSettings.judgeOffset = 0;
            this.settings = jsonSettings;
        }
        else if (data.replayversion == "R^2")
        {
            tempSettings = tempSettings.split(",");
            for (ss in 0...tempSettings.length)
            {
                Reflect.setField(tempSettings, Std.string(ss), Reflect.field(tempSettings, Std.string(ss)).split("|"));
            }
            jsonSettings = (_gvars.playerUser.isGuest) ? new User().settings : _gvars.playerUser.settings;
            jsonSettings.speed = as3hx.Compat.parseFloat(Reflect.field(Reflect.field(tempSettings, Std.string(0)), Std.string(1)));
            jsonSettings.direction = cleanScrollDirection(Reflect.field(Reflect.field(tempSettings, Std.string(0)), Std.string(0)));
            jsonSettings.songRate = 1;
            if (Reflect.field(Reflect.field(tempSettings, Std.string(0)), Std.string(2)) == "true")
            {
                jsonSettings.visual.push("mirror");
            }
            else if ((mirrorIndex = jsonSettings.visual.indexOf("mirror")) >= 0)
            {
                jsonSettings.visual.splice(mirrorIndex, 1);
            }
            jsonSettings.gap = as3hx.Compat.parseFloat(Reflect.field(Reflect.field(tempSettings, Std.string(2)), Std.string(0)));
            jsonSettings.noteskin = as3hx.Compat.parseFloat(Reflect.field(Reflect.field(tempSettings, Std.string(2)), Std.string(3)));
            jsonSettings.viewOffset = 0;
            jsonSettings.visualDelay = 0;
            jsonSettings.judgeOffset = 0;
            this.settings = jsonSettings;
        }
        // R^3 Replay JSON
        else if (data.replayversion == "R^3")
        {
            this.settings = haxe.Json.parse(data.replaysettings);
        }
        
        //- Frames
        var tempReplay : String = data.replayframes;
        replayData = [];
        
        //- Clean up
        // Legacy Replay Format ((LDUR),(FRAME)|), Handled in the Velo Converter
        if (tempReplay.indexOf(",") > -1)
        {
            tempReplay = new as3hx.Compat.Regex(',', "g").replace(tempReplay, "");
        }
        
        //- Conversion
        // Velocity Replay Format ((LDUR)(FRAME)|)
        if (tempReplay.indexOf("|") > -1)
        {
            parseVelocityReplay(tempReplay);
        }
        // R^2/3 Replay Format ((WXYZ)(FRAME))
        else if (tempReplay.charCodeAt(0) >= 87 && tempReplay.charCodeAt(0) <= 90)
        {
            parserRCubedReplay(tempReplay, data.replayversion);
        }
    }
    
    private function parseReplayPack(data : ReplayPacked, loadUser : Bool = true) : Void
    {
        if (data == null)
        {
            return;
        }
        
        if (data.error != null)
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
        this.perfect = (data.judgements["perfect"] + data.judgements["amazing"]);
        this.good = data.judgements["good"];
        this.average = data.judgements["average"];
        this.miss = data.judgements["miss"];
        this.boo = data.judgements["boo"];
        this.maxcombo = data.judgements["maxcombo"];
        this.score = (perfect * 50) + (good * 25) + (average * 5) - (miss * 10) - (boo * 5);
        
        this.settings = data.settings;
        
        //- Replay
        this.replayData = [];
        for (item/* AS3HX WARNING could not determine type for var: item exp: EField(EIdent(data),rep_boos) type: null */ in data.rep_boos)
        {
            this.replayData[replayData.length] = new ReplayNote(item.direction, -2, item.time);
        }
        
        //- Edited Check
        if (data.checksum != data.rechecksum)
        {
            isEdited = true;
        }
        
        this.replayBin = data.replay_bin;
        this.generationReplayNotes = data.rep_notes;
        this.generationReplayBoos = data.rep_boos;
        this.needsBeatboxGeneration = true;
    }
    
    //// Parsers
    private function parseVelocityReplay(_input : String) : Void
    {
        var tempReplay : Array<Dynamic> = _input.split("|");
        for (x in 0...tempReplay.length)
        {
            var dir : String = tempReplay[x].charAt(0);
            var frame : Float = as3hx.Compat.parseInt("0x" + tempReplay[x].substr(1));
            this.replayData[replayData.length] = new ReplayNote(dir, frame - 30);
        }
    }
    
    private function parserRCubedReplay(_input : String, _version : String) : Void
    {
        var offsetf : Int = ((_version == "R^2") ? 30 : 0);
        var totalReplay : Int = 0;
        var lastFrame : Int = 0;
        var noteVal : String = "";
        var noteDir : String = "";
        var game_curChar : String;
        var game_nexChar : String;
        for (x in 0..._input.length)
        {
            game_curChar = _input.charAt(x);
            game_nexChar = _input.charAt(x + 1);
            if (game_nexChar == false || game_nexChar == "" || game_nexChar == "W" || game_nexChar == "X" || game_nexChar == "Y" || game_nexChar == "Z")
            {
                var dir : String = getDirCol(noteDir);
                var frame : Int = as3hx.Compat.parseInt(as3hx.Compat.parseInt("0x" + noteVal + game_curChar) + lastFrame);
                this.replayData[replayData.length] = new ReplayNote(dir, frame - offsetf);
                lastFrame = frame;
            }
            else if (game_curChar == "W" || game_curChar == "X" || game_curChar == "Y" || game_curChar == "Z")
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
        if (settings.arc_engine) {
if (settings.arc_engine.engineID == "fileloader")
            {
                cacheID = settings.arc_engine.cacheID;
                chartPath = FileLoader.cache.findKey(function(entry : Dynamic) : Dynamic
                                {
                                    return Reflect.field(entry, "id") == settings.arc_engine.cacheID;
                                });
                
                if (chartPath == null)
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
    
    private function getDirCol(noteDir : String) : String
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
    
    private function userLoad(e : Event) : Void
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
    public function getPress(index : Int) : ReplayNote
    {
        return replayData[index];
    }
    
    public function getEncode(onlyBinReplay : Bool = false) : String
    {
        if (replayBin != null)
        {
            return ReplayPack.MAGIC + "|" + Base64.encode(replayBin);
        }
        
        if (!onlyBinReplay)
        {
            var sT : Float = (perfect * 550) + (good * 275) + (average * 55) + (maxcombo * 1000) - (miss * 310) - (boo * 20);
            var o : Dynamic = { };
            o.userid = this.user.siteId;
            o.replaylevelid = this.level;
            o.replaysettings = haxe.Json.stringify(this.settings);
            o.replayscore = (sT + "|" + perfect + "|" + good + "|" + average + "|" + miss + "|" + boo + "|" + maxcombo);
            o.replayframes = getReplayString(replayData);
            o.replayversion = "R^3";
            o.timestamp = timestamp;
            
            var outJson : String = haxe.Json.stringify(o);
            return (outJson + "|" + MD5.hash(outJson + "|" + MD5.hash(outJson)));
        }
        
        return null;
    }
    
    public function parseEncode(str : String, loadUser : Bool = true) : Void
    {
        try
        {
            if (str.substr(0, 4) == ReplayPack.MAGIC)
            {
                parseReplayPack(ReplayPack.readReplay(Base64.decode(str.substr(5))), loadUser);
            }
            else
            {
                if (str.charAt(str.length - 33) == "|")
                {
                    var md5 : String = str.substr(str.length - 32);
                    str = str.substr(0, str.length - 33);
                    if (md5 != MD5.hash(str + "|" + MD5.hash(str)))
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
    
    public static function getReplayString(replay : Dynamic) : String
    // Build Replay String
    {
        
        var noteObj : ReplayNote;
        var lastDifference : Int = 0;
        var replayString : String = "";
        for (x in 0...replay.length)
        {
            noteObj = Reflect.field(replay, Std.string(x));
            replayString += getReplayChar(noteObj.direction) + Std.string(noteObj.frame - lastDifference).toUpperCase();
            lastDifference = noteObj.frame;
        }
        return replayString;
    }
    
    public static function getReplayChar(dir : String) : String
    {
        if (dir == "L")
        {
            return "W";
        }
        if (dir == "D")
        {
            return "X";
        }
        if (dir == "U")
        {
            return "Y";
        }
        if (dir == "R")
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
    public static function cleanScrollDirection(dir : String) : String
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

