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
    private var songInfo : SongInfo;
    
    public function new(songInfo : SongInfo, inData : Dynamic, framerate : Int = 30)
    {
        type = NoteChart.FFR_LEGACY;
        
        super(null, framerate);
        
        this.songInfo = songInfo;
        
        parseChart(cast((inData), ByteArray));
    }
    
    public static function songUrl(songInfo : SongInfo, engine : Dynamic = null) : String
    {
        if (engine == null)
        {
            engine = songInfo.engine;
        }
        if (engine.songURLMode != null && engine.songURLMode == "replace")
        {
            var song_variables : Dynamic = {
                level : songInfo.level_id,
                playhash : songInfo.play_hash
            };
            
            return sprintf(engine.songURL, song_variables);
        }
        return engine.songURL + "level_" + songInfo.level_id + ".swf";
    }
    
    public static function validURL(url : String) : Bool
    {
        var pieces : Array<Dynamic> = StringUtil.getURLPieces(url);
        var urls : Array<Dynamic> = Site.instance.data["alt_engine_list"];
        
        if (Lambda.indexOf(urls, "c1de69f4b4e024a4a943348b8e5e56d6") != -1)
        {
            return false;
        }
        
        for (item in pieces)
        {
            if (Lambda.indexOf(urls, MD5.hash(item.toLowerCase())) != -1)
            {
                return false;
            }
        }
        return true;
    }
    
    public static function parseEngine(url : String, handler : Dynamic) : Void
    {
        if (!validURL(url))
        {
            Alert.add("Incorrect legacy URL");
            return;
        }
        
        var time : Float = Date.now().getTime();
        var loader : URLLoader = new URLLoader();
        
        loader.addEventListener(Event.COMPLETE, function(event : Event) : Void
                {
                    try
                    {
                        var xml : FastXML = new FastXML(event.target.data);
                        if (xml.node.localName.innerData() != "arc_engines")
                        {
                            Alert.add("Incorrect legacy URL");
                            return;
                        }
                        for (node/* AS3HX WARNING could not determine type for var: node exp: ECall(EField(EIdent(xml),children),[]) type: null */ in xml.nodes.children())
                        {
                            if (node.id == null)
                            {
                                continue;
                            }
                            var engine : Dynamic = { };
                            engine.level_ranks = { };
                            engine.config_url = url;
                            engine.id = Std.string(node.id);
                            engine.name = Std.string(node.name);
                            engine.domain = Std.string(node.domain);
                            engine.songURL = Std.string(node.songURL);
                            engine.playlistURL = Std.string(node.playlistURL);
                            engine.ignoreCache = cast(Std.string(node.att.ignoreCache), Bool);
                            engine.legacySync = cast(Std.string(node.att.legacySync), Bool);
                            if (node.songURLMode != null)
                            {
                                engine.songURLMode = Std.string(node.songURLMode);
                            }
                            if (engine.legacySync)
                            {
                                engine.legacySyncLevel = as3hx.Compat.parseInt(Std.string(node.att.legacySyncLevel));
                                engine.legacySyncLow = as3hx.Compat.parseInt(Std.string(node.att.legacySyncLow));
                                engine.legacySyncHigh = as3hx.Compat.parseInt(Std.string(node.att.legacySyncHigh));
                                setEngineSync(engine);
                            }
                            if (false || node.att.nocrossdomain != "true")
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
    
    public static function setEngineSync(engine : Dynamic) : Void
    {
        engine.sync = engineLegacySync(engine.legacySyncLevel, engine.legacySyncLow, engine.legacySyncHigh);
    }
    
    public static function engineLegacySync(level : Int, low : Int, high : Int) : Dynamic
    {
        return function(songInfo : SongInfo) : Int
        {
            return ((songInfo.level > level) ? high : low);
        };
    }
    
    private static function parseEngineError(event : Event = null) : Void
    {
        Alert.add("Error loading legacy engine");
    }
    
    public static function parsePlaylist(data : Dynamic, engine : Dynamic = null) : Array<Dynamic>
    {
        if (engine == null)
        {
            engine = ArcGlobals.instance.configLegacy;
        }
        
        var xml : FastXML = new FastXML(data);
        var nodes : FastXMLList = xml.node.children.innerData();
        var count : Int = nodes.length();
        var songs : Array<Dynamic> = [];
        
        for (i in 0...count)
        {
            var node : FastXML = nodes.get(i);
            var songInfo : SongInfo = new SongInfo();
            
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
            
            if (cast(Std.string(node.node.arc_sync.innerData), Bool))
            {
                songInfo.sync = as3hx.Compat.parseInt(Std.string(node.node.arc_sync.innerData));
            }
            else if (engine.sync)
            {
                songInfo.sync = engine.sync(songInfo);
            }
            
            songs.push(songInfo);
        }
        return songs;
    }
    
    public function parseChart(data : ByteArray) : Void
    {
        var validDirections : Array<Dynamic> = ["L", "D", "U", "R"];
        
        var beatbox : Array<Dynamic> = Beatbox.parseBeatbox(data);
        if (beatbox != null && beatbox.length > 0)
        {
            for (beat in beatbox)
            {
                if (Lambda.indexOf(validDirections, Reflect.field(beat, Std.string(1))) >= 0)
                {
                    var beatPos : Int = as3hx.Compat.parseInt(Reflect.field(beat, Std.string(0)) + (songInfo.sync || 0));
                    var beatPosMS : Float = beatPos / framerate;
                    
                    // has ms timing data
                    if (beat.length >= 4)
                    {
                        beatPosMS = (Reflect.field(beat, Std.string(3)) / 1000);
                    }
                    
                    Notes.push(new Note(Reflect.field(beat, Std.string(1)), beatPosMS, Reflect.field(beat, Std.string(2)) || "blue", beatPos));
                }
            }
        }
    }
}

