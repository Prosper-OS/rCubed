package arc;

import openfl.errors.Error;
import classes.Playlist;
import classes.SongInfo;
import classes.chart.parse.ChartFFRLegacy;
import openfl.events.EventDispatcher;
import openfl.net.SharedObject;

class ArcGlobals extends EventDispatcher
{
    public static var instance(get, never)                              : Dynamic;

    private static var _instance                              : Dynamic= null;
    
    public var legacyLevelRanks                              : Dynamic= null;
    public static inline var legacyLevelRanksName                              : Dynamic= "90579262-509d-4370-9c2e-835a38cf0387";
    
    public var configMusicOffset                              : Dynamic= 0;
    public var configLegacy                              : Dynamic= null;
    public var legacyEngines                              : Dynamic= [];
    public var legacyDefaultEngine                              : Dynamic= null;
    
    public var configIsolation                              : Dynamic= false;
    public var configIsolationStart                              : Dynamic= 0;
    public var configIsolationLength                              : Dynamic= 0;
    
    public var configJudge                              : Dynamic;
    
    public function new(en                              : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(en == null))
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
        
        load();
    }
    
    public function legacyEngine(id                              : Dynamic) : Dynamic
    {
        for (engine in as3hx.Compat.iter(legacyEngines))
        {
            if (as3hx.Compat.truthy(engine.id == id))
            {
                return engine;
            }
        }
        return null;
    }
    
    public function legacyLoad() : Void
    {
        var legacyEngineArray                              : Dynamic= LocalOptions.getVariable("legacy_engines", null);
        for (engine/* AS3HX WARNING could not determine type for var: engine exp: EIdent(legacyEngineArray) type: Dynamic */ in as3hx.Compat.iter(legacyEngineArray))
        {
            ChartFFRLegacy.setEngineSync(engine);
            if (as3hx.Compat.truthy(engine.level_ranks))
            {
                for (levelid in as3hx.Compat.iter(Reflect.fields(engine.level_ranks)))
                {
                    var songInfo                              : Dynamic= new SongInfo();
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
    public function legacyEncode(song                              : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(song == null || !song.engine))
        {
            return null;
        }
        
        if (as3hx.Compat.truthy(song.engine.id == "fileloader"))
        {
            return {
                engineID : "fileloader",
                cacheID : song.engine.cache_id,
                chartID : song.engine.chart_id
            };
        }
        
        var engine                              : Dynamic= {
            engineID : song.engine.id,
            songLevel : song.level,
            songID : song.level_id,
            songName : song.name,
            songAuthor : song.author,
            stepAuthor : song.stepauthor,
            ffrlURL : song.engine.songURL,
            type : song.chart_type
        };
        
        if (as3hx.Compat.truthy(song.sync))
        {
            Reflect.setField(engine, "sync", song.sync);
        }
        
        return engine;
    }
    
    public function legacyDecode(data                              : Dynamic) : SongInfo
    {
        var playlist                              : Dynamic= Playlist.instance;
        if (as3hx.Compat.truthy(playlist.engine && playlist.engine.id == Reflect.field(data, "engineID")))
        {
            return playlist.playList[Reflect.field(data, "songLevel")];
        }
        
        var engine                              : Dynamic= legacyEngine(data.engineID);
        if (as3hx.Compat.truthy(engine == null))
        {
            engine = {
                        id : data.engineID,
                        songURL : data.ffrlURL
                    };
        }
        
        var songInfo                              : Dynamic= new SongInfo();
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
    
    public function legacyLevelRanksGet(songInfo                              : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(legacyLevelRanks == null))
        {
            return null;
        }
        var ranks                              : Dynamic= as3hx.Compat.field(legacyLevelRanks, songInfo.engine.id);
        if (as3hx.Compat.truthy(ranks == null))
        {
            return null;
        }
        return as3hx.Compat.field(ranks, songInfo.level_id || songInfo.level);
    }
    
    public function legacyLevelRanksSet(songInfo                              : Dynamic, value                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(legacyLevelRanks == null))
        {
            legacyLevelRanks = { };
        }
        var ranks                              : Dynamic= as3hx.Compat.field(legacyLevelRanks, songInfo.engine.id);
        if (as3hx.Compat.truthy(ranks == null))
        {
            Reflect.setField(legacyLevelRanks, Std.string(songInfo.engine.id), ranks = { });
        }
        Reflect.setField(ranks, Std.string(songInfo.level_id || songInfo.level), songInfo.level);
    }
    
    public function legacyLevelRanksLoad() : Void
    {
        var save                              : Dynamic= SharedObject.getLocal(legacyLevelRanksName);
        legacyLevelRanks = save.data.legacyLevelRanks;
    }
    
    public function legacyLevelRanksSave() : Void
    {
        var save                              : Dynamic= SharedObject.getLocal(legacyLevelRanksName);
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
        if (as3hx.Compat.truthy(_instance == null))
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
