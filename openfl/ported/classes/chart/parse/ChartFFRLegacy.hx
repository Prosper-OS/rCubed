package classes.chart.parse;

import openfl.errors.Error;
import arc.ArcGlobals;
import by.blooddy.crypto.MD5;
import classes.Alert;
import classes.Site;
import classes.SongInfo;
import classes.chart.Note;
import classes.chart.NoteChart;
import com.flashfla.media.Beatbox;
import com.flashfla.utils.StringUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class ChartFFRLegacy extends NoteChart
{
    private var songInfo                             : Dynamic;
    
    public function new(songInfo                             : Dynamic, inData                             : Dynamic, framerate                             : Dynamic= 30)
    {
        type = NoteChart.FFR_LEGACY;
        
        super(null, framerate);
        
        this.songInfo = songInfo;
        
        parseChart(cast((inData), ByteArray));
    }
    
    public static function songUrl(songInfo                             : Dynamic, engine                             : Dynamic= null) : String
    {
        if (as3hx.Compat.truthy(engine == null))
        {
            engine = songInfo.engine;
        }
        if (as3hx.Compat.truthy(engine.songURLMode != null && engine.songURLMode == "replace"))
        {
            var song_variables                             : Dynamic= {
                level : songInfo.level_id,
                playhash : songInfo.play_hash
            };
            
            return sprintf(engine.songURL, song_variables);
        }
        return engine.songURL + "level_" + songInfo.level_id + ".swf";
    }
    
    public static function validURL(url                             : Dynamic) : Bool
    {
        var pieces                             : Dynamic= StringUtil.getURLPieces(url);
        var urls                         : Dynamic= Reflect.field(Site.instance.data, "alt_engine_list");
        
        if (as3hx.Compat.truthy(Lambda.indexOf(urls, "c1de69f4b4e024a4a943348b8e5e56d6") != -1))
        {
            return false;
        }
        
        for (item in as3hx.Compat.iter(pieces))
        {
            if (as3hx.Compat.truthy(Lambda.indexOf(urls, MD5.hash(item.toLowerCase())) != -1))
            {
                return false;
            }
        }
        return true;
    }
    
    public static function parseEngine(url                             : Dynamic, handler                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!validURL(url)))
        {
            Alert.add("Incorrect legacy URL");
            return;
        }
        
        var time                             : Dynamic= Date.now().getTime();
        var loader                             : Dynamic= new URLLoader();
        
        loader.addEventListener(Event.COMPLETE, function(event                             : Dynamic) : Void
                {
                    try
                    {
                        var xml                             : Dynamic= new FastXML(event.target.data);
                        if (as3hx.Compat.truthy(xml.node.localName.innerData() != "arc_engines"))
                        {
                            Alert.add("Incorrect legacy URL");
                            return;
                        }
                        for (node/* AS3HX WARNING could not determine type for var: node exp: ECall(EField(EIdent(xml),children),[]) type: null */ in as3hx.Compat.iter(xml.nodes.children()))
                        {
                            if (as3hx.Compat.truthy(node.id == null))
                            {
                                continue;
                            }
                            var engine                             : Dynamic= { };
                            engine.level_ranks = { };
                            engine.config_url = url;
                            engine.id = Std.string(node.id);
                            engine.name = Std.string(node.name);
                            engine.domain = Std.string(node.domain);
                            engine.songURL = Std.string(node.songURL);
                            engine.playlistURL = Std.string(node.playlistURL);
                            engine.ignoreCache = cast(Std.string(node.att.ignoreCache), Bool);
                            engine.legacySync = cast(Std.string(node.att.legacySync), Bool);
                            if (as3hx.Compat.truthy(node.songURLMode != null))
                            {
                                engine.songURLMode = Std.string(node.songURLMode);
                            }
                            if (as3hx.Compat.truthy(engine.legacySync))
                            {
                                engine.legacySyncLevel = as3hx.Compat.parseInt(Std.string(node.att.legacySyncLevel));
                                engine.legacySyncLow = as3hx.Compat.parseInt(Std.string(node.att.legacySyncLow));
                                engine.legacySyncHigh = as3hx.Compat.parseInt(Std.string(node.att.legacySyncHigh));
                                setEngineSync(engine);
                            }
                            if (as3hx.Compat.truthy(false || node.att.nocrossdomain != "true"))
                            {
                                handler(engine);
                            }
                        }
                    }
                    catch (e : Error)
                    {
                        parseEngineError();
                    }
                });
        loader.addEventListener(IOErrorEvent.IO_ERROR, parseEngineError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, parseEngineError);
        loader.load(new URLRequest(url + (url.indexOf("?") == -(1) ? "?d=" + time : "&d=" + time)));
    }
    
    public static function setEngineSync(engine                             : Dynamic) : Void
    {
        engine.sync = engineLegacySync(engine.legacySyncLevel, engine.legacySyncLow, engine.legacySyncHigh);
    }
    
    public static function engineLegacySync(level                             : Dynamic, low                             : Dynamic, high                             : Dynamic) : Dynamic
    {
        return function(songInfo                             : Dynamic) : Int
        {
            return ((songInfo.level > level) ? high : low);
        };
    }
    
    private static function parseEngineError(event                             : Dynamic= null) : Void
    {
        Alert.add("Error loading legacy engine");
    }
    
    public static function parsePlaylist(data                             : Dynamic, engine                             : Dynamic= null) : Array<Dynamic>
    {
        if (as3hx.Compat.truthy(engine == null))
        {
            engine = ArcGlobals.instance.configLegacy;
        }
        
        var xml                             : Dynamic= new FastXML(data);
        var nodes                             : Dynamic= xml.node.children.innerData();
        var count                             : Dynamic= nodes.length();
        var songs                             : Dynamic= [];
        
        for (i in 0...count)
        {
            var node                             : Dynamic= nodes.get(i);
            var songInfo                             : Dynamic= new SongInfo();
            
            songInfo.genre = as3hx.Compat.parseInt(Std.string(node.att.genre));
            songInfo.name = Std.string(node.node.songname.innerData);
            songInfo.difficulty = as3hx.Compat.parseInt(Std.string(node.node.songdifficulty.innerData));
            songInfo.style = Std.string(node.node.songstyle.innerData);
            songInfo.time = Std.string(node.node.songlength.innerData);
            songInfo.level_id = Std.string(node.node.level.innerData);
            songInfo.level = i + 1;
            songInfo.order = as3hx.Compat.parseInt(Std.string(node.node.order.innerData));
            songInfo.note_count = as3hx.Compat.parseInt(Std.string(node.node.arrows.innerData));
            songInfo.author = Std.string(node.node.songauthor.innerData);
            songInfo.author_url = Std.string(node.node.songauthorURL.innerData);
            songInfo.stepauthor = Std.string(node.node.songstepauthor.innerData);
            songInfo.play_hash = Std.string(node.node.playhash.innerData);
            songInfo.swf_hash = Std.string(node.node.swfhash.innerData);
            songInfo.min_nps = as3hx.Compat.parseInt(Std.string(node.node.min_nps.innerData));
            songInfo.max_nps = as3hx.Compat.parseInt(Std.string(node.node.max_nps.innerData));
            songInfo.credits = as3hx.Compat.parseInt(Std.string(node.node.secretcredits.innerData));
            songInfo.price = as3hx.Compat.parseInt(Std.string(node.node.price.innerData));
            songInfo.background = Std.string(node.node.background.innerData);
            songInfo.engine = engine;
            
            if (as3hx.Compat.truthy(cast(Std.string(node.node.arc_sync.innerData), Bool)))
            {
                songInfo.sync = as3hx.Compat.parseInt(Std.string(node.node.arc_sync.innerData));
            }
            else if (as3hx.Compat.truthy(engine.sync))
            {
                songInfo.sync = engine.sync(songInfo);
            }
            
            songs.push(songInfo);
        }
        return songs;
    }
    
    public function parseChart(data                             : Dynamic) : Void
    {
        var validDirections                             : Dynamic= ["L", "D", "U", "R"];
        
        var beatbox                             : Dynamic= Beatbox.parseBeatbox(data);
        if (as3hx.Compat.truthy(beatbox != null && beatbox.length > 0))
        {
            for (beat in as3hx.Compat.iter(beatbox))
            {
                if (as3hx.Compat.truthy(Lambda.indexOf(validDirections, as3hx.Compat.field(beat, 1)) >= 0))
                {
                    var beatPos                             : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.field(beat, 0) + (as3hx.Compat.orValue(songInfo.sync, 0)));
                    var beatPosMS                             : Dynamic= beatPos / framerate;
                    
                    // has ms timing data
                    if (as3hx.Compat.truthy(beat.length >= 4))
                    {
                        beatPosMS = (as3hx.Compat.field(beat, 3) / 1000);
                    }
                    
                    Notes.push(new Note(as3hx.Compat.field(beat, 1), beatPosMS, as3hx.Compat.orValue(as3hx.Compat.field(beat, 2), "blue"), beatPos));
                }
            }
        }
    }
}

