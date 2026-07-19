package arc;

import openfl.errors.Error;
import classes.Playlist;
import classes.SongInfo;
import classes.chart.parse.ChartFFRLegacy;
import openfl.events.EventDispatcher;
import openfl.net.SharedObject;

class ArcGlobals extends EventDispatcher
{
    public static var instance(get, never) : ArcGlobals;

    private static var _instance : ArcGlobals = null;
    
    public var legacyLevelRanks : Dynamic = null;
    public static inline var legacyLevelRanksName : String = "90579262-509d-4370-9c2e-835a38cf0387";
    
    public var configMusicOffset : Int = 0;
    public var configLegacy : Dynamic = null;
    public var legacyEngines : Array<Dynamic> = [];
    public var legacyDefaultEngine : Dynamic = null;
    
    public var configIsolation : Bool = false;
    public var configIsolationStart : Int = 0;
    public var configIsolationLength : Int = 0;
    
    public var configJudge : Array<Dynamic>;
    
    public function new(en : ArcGlobalsSingletonEnforcer)
    {
        super();
        if (en == null)
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
        
        load();
    }
    
    public function legacyEngine(id : String) : Dynamic
    {
        for (engine in legacyEngines)
        {
            if (engine.id == id)
            {
                return engine;
            }
        }
        return null;
    }
    
    public function legacyLoad() : Void
    {
        var legacyEngineArray : Dynamic = LocalOptions.getVariable("legacy_engines", null);
        for (engine/* AS3HX WARNING could not determine type for var: engine exp: EIdent(legacyEngineArray) type: Dynamic */ in legacyEngineArray)
        {
            ChartFFRLegacy.setEngineSync(engine);
            if (engine.level_ranks)
            {
                for (levelid in Reflect.fields(engine.level_ranks))
                {
                    var songInfo : SongInfo = new SongInfo();
                    songInfo.engine = engine;
                    songInfo.level_id = levelid;
                    legacyLevelRanksSet(songInfo, engine.level_ranks[levelid]);
                }
                Reflect.deleteField(engine, "level_ranks");
            }
            legacyEngines.push(engine);
        }
    }
    
    public function legacySave() : Void
    {
        LocalOptions.setVariable("legacy_engines", legacyEngines);
    }
    
    public function legacyDefaultSave() : Void
    {
        LocalOptions.setVariable("legacy_default_engine", legacyDefaultEngine);
    }
    
    /**
     * Creates a new `engine` object from the song's fields
     */
    public function legacyEncode(song : SongInfo) : Dynamic
    {
        if (song == null || !song.engine)
        {
            return null;
        }
        
        if (song.engine.id == "fileloader")
        {
            return {
                engineID : "fileloader",
                cacheID : song.engine.cache_id,
                chartID : song.engine.chart_id
            };
        }
        
        var engine : Dynamic = {
            engineID : song.engine.id,
            songLevel : song.level,
            songID : song.level_id,
            songName : song.name,
            songAuthor : song.author,
            stepAuthor : song.stepauthor,
            ffrlURL : song.engine.songURL,
            type : song.chart_type
        };
        
        if (song.sync)
        {
            Reflect.setField(engine, "sync", song.sync);
        }
        
        return engine;
    }
    
    public function legacyDecode(data : Dynamic) : SongInfo
    {
        var playlist : Playlist = Playlist.instance;
        if (playlist.engine && playlist.engine.id == Reflect.field(data, "engineID"))
        {
            return playlist.playList[Reflect.field(data, "songLevel")];
        }
        
        var engine : Dynamic = legacyEngine(data.engineID);
        if (engine == null)
        {
            engine = {
                        id : data.engineID,
                        songURL : data.ffrlURL
                    };
        }
        
        var songInfo : SongInfo = new SongInfo();
        songInfo.engine = engine;
        songInfo.level = Reflect.field(data, "songLevel");
        songInfo.name = Reflect.field(data, "songName");
        songInfo.author = Reflect.field(data, "songAuthor");
        songInfo.author_html = Reflect.field(data, "songAuthor");
        songInfo.stepauthor = Reflect.field(data, "stepAuthor");
        songInfo.stepauthor_html = Reflect.field(data, "stepAuthor");
        songInfo.level_id = Reflect.field(data, "songID");
        songInfo.chart_type = Reflect.field(data, "type");
        songInfo.sync = Reflect.field(data, "sync");
        songInfo.note_count = 0;
        
        return songInfo;
    }
    
    public function musicOffsetSave() : Void
    {
        LocalOptions.setVariable("rolling_music_offset", configMusicOffset);
    }
    
    public function legacyLevelRanksGet(songInfo : SongInfo) : Dynamic
    {
        if (legacyLevelRanks == null)
        {
            return null;
        }
        var ranks : Dynamic = Reflect.field(legacyLevelRanks, Std.string(songInfo.engine.id));
        if (ranks == null)
        {
            return null;
        }
        return Reflect.field(ranks, Std.string(songInfo.level_id || songInfo.level));
    }
    
    public function legacyLevelRanksSet(songInfo : SongInfo, value : Dynamic) : Void
    {
        if (legacyLevelRanks == null)
        {
            legacyLevelRanks = { };
        }
        var ranks : Dynamic = Reflect.field(legacyLevelRanks, Std.string(songInfo.engine.id));
        if (ranks == null)
        {
            Reflect.setField(legacyLevelRanks, Std.string(songInfo.engine.id), ranks = { });
        }
        Reflect.setField(ranks, Std.string(songInfo.level_id || songInfo.level), songInfo.level);
    }
    
    public function legacyLevelRanksLoad() : Void
    {
        var save : SharedObject = SharedObject.getLocal(legacyLevelRanksName);
        legacyLevelRanks = save.data.legacyLevelRanks;
    }
    
    public function legacyLevelRanksSave() : Void
    {
        var save : SharedObject = SharedObject.getLocal(legacyLevelRanksName);
        save.data.legacyLevelRanks = legacyLevelRanks;
        try
        {
            save.flush();
        }
        catch (e : Error)
        {
        }
    }
    
    public function load() : Void
    {
        legacyLevelRanksLoad();
        legacyLoad();
        
        legacyDefaultEngine = LocalOptions.getVariable("legacy_default_engine", null);
        configMusicOffset = LocalOptions.getVariable("rolling_music_offset", 0);
    }
    
    public function resetSettings() : Void
    {
        LocalOptions.deleteVariable("rolling_music_offset");
        
        resetConfig();
        configJudge = null;
        
        load();
    }
    
    public function resetConfig() : Void
    {
        configIsolation = false;
        configIsolationStart = 0;
        configIsolationLength = 0;
    }
    
    private static function get_instance() : ArcGlobals
    {
        if (_instance == null)
        {
            _instance = new ArcGlobals(new ArcGlobalsSingletonEnforcer());
        }
        return _instance;
    }
}


class ArcGlobalsSingletonEnforcer
{

    public function new()
    {
    }
}
