package menu;

import by.blooddy.crypto.MD5;
import classes.SongInfo;
import classes.chart.Note;
import classes.chart.NoteChart;
import classes.chart.Song;
import classes.chart.parse.ExternalChartBase;
import r3.air.filesystem.File;
import game.GameOptions;

class FileLoader
{
    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    
    public static var cache : FileCache = new FileCache("chart_cache.json", 2);
    
    public static var ENGINE_INFO : Dynamic = {
            name : "File Loader",
            id : "fileloader",
            config_url : "",
            ignoreCache : true,
            legacySync : false,
            playlistURL : "",
            songURL : ""
        };
    
    public static function buildSongInfo(loc : String, id : Int, isUnique : Bool = false) : SongInfo
    {
        if (loc == null || loc.length == 0)
        {
            return null;
        }
        
        // Parse Chart
        var emb : ExternalChartBase = new ExternalChartBase();
        if (emb.load(new File(loc)))
        {
            var chartinfo : Dynamic = emb.getInfo();
            var chartData : Dynamic = emb.getValidChartData(id);
            
            // Build Song Info
            var songInfo : SongInfo = new SongInfo();
            songInfo.access = GlobalVariables.SONG_ACCESS_PLAYABLE;
            songInfo.genre = 14;
            songInfo.author = songInfo.author_html = chartinfo.author;
            songInfo.stepauthor = songInfo.stepauthor_html = chartinfo.stepauthor;
            songInfo.name = chartinfo.display;
            songInfo.level = 1;
            songInfo.level_id = MD5.hash(id + emb.ID);
            songInfo.note_count = chartinfo.arrows;
            songInfo.time = chartinfo.time;
            songInfo.time_secs = chartinfo.time_secs;
            songInfo.time_end = 0;
            songInfo.background = (chartinfo.background != "") ? chartinfo.folder + chartinfo.background : null;
            
            if (isUnique)
            {
                songInfo.engine = {
                            id : "fileloader",
                            cache_id : emb.ID,
                            chart_id : id
                        };
            }
            else
            {
                ENGINE_INFO.cache_id = emb.ID;
                ENGINE_INFO.chart_id = id;
                songInfo.engine = ENGINE_INFO;
            }
            
            // File Loader Assistance
            songInfo.is_local = true;
            songInfo.chart_parser = emb;
            
            return songInfo;
        }
        
        return null;
    }
    
    public static function buildSong(info : SongInfo) : Void
    {
        if (!info.is_local)
        {
            return;
        }
        
        var emb : ExternalChartBase = info.chart_parser;
        var id : Int = info.engine.chart_id;
        
        emb.parseData();
        
        var chartData : Dynamic = emb.getValidChartData(id);
        
        ENGINE_INFO.cache_id = emb.ID;
        ENGINE_INFO.chart_id = id;
        
        // Build Chart
        var noteChart : NoteChart = new NoteChart();
        noteChart.type = "EXTERNAL";
        for (note/* AS3HX WARNING could not determine type for var: note exp: EField(EIdent(chartData),notes) type: null */ in chartData.notes)
        {
            noteChart.Notes.push(new Note(note[1], note[0], note[2], Math.floor(note[0] * 30)));
        }
        
        // Build Song
        var song : Song = new Song(info, false);
        song.chart = noteChart;
        song.loadSoundBytes(emb.getAudioData());
        song.isChartLoaded = song.isMusicLoaded = song.isLoaded = true;
        
        // Setup Loading
        _gvars.externalSongInfo = info;
        _gvars.externalSong = song;
    }
    
    public static function setupLocalFile(loc : String, id : Int) : Bool
    {
        var info : SongInfo = buildSongInfo(loc, id);
        if (info != null)
        {
            buildSong(info);
            return true;
        }
        return false;
    }
    
    public static function loadLocalFile(loc : String, id : Int) : Void
    {
        if (setupLocalFile(loc, id))
        {
            _gvars.songQueue = [_gvars.externalSongInfo];
            
            _gvars.options = new GameOptions();
            _gvars.options.fill();
            _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
        }
    }
    
    public static function buildCacheObject(chartFile : File) : Dynamic
    {
        var cacheObj : Dynamic = {
            valid : 0,
            date : chartFile.modificationDate.getTime()
        };
        var emb : ExternalChartBase = new ExternalChartBase();
        if (emb.load(chartFile, true))
        {
            var chartData : Dynamic = emb.getInfo();
            var chartCharts : Array<Dynamic> = emb.getAllCharts();
            
            cacheObj = {
                        valid : 1,
                        name : Reflect.field(chartData, "name"),
                        author : Reflect.field(chartData, "author"),
                        stepauthor : Reflect.field(chartData, "stepauthor"),
                        difficulty : Reflect.field(chartData, "difficulty"),
                        music : Reflect.field(chartData, "music"),
                        banner : Reflect.field(chartData, "banner"),
                        background : Reflect.field(chartData, "background"),
                        ext : Reflect.field(chartData, "ext"),
                        chart : [],
                        id : emb.ID,
                        date : emb.DATE
                    };
            
            for (i in 0...chartCharts.length)
            {
                var difficultyData : Dynamic = chartCharts[i];
                Reflect.setField(Reflect.field(cacheObj, "chart"), Std.string(i), {
                    "class" : Reflect.field(difficultyData, "class"),
                    class_color : Reflect.field(difficultyData, "class_color"),
                    desc : Reflect.field(difficultyData, "desc"),
                    difficulty : Reflect.field(difficultyData, "difficulty"),
                    type : Reflect.field(difficultyData, "type"),
                    time_sec : as3hx.Compat.parseFloat(Reflect.field(difficultyData, "time_sec").toFixed(2)),
                    nps : as3hx.Compat.parseFloat(Reflect.field(difficultyData, "nps").toFixed(2)),
                    arrows : Reflect.field(difficultyData, "arrows"),
                    holds : Reflect.field(difficultyData, "holds"),
                    mines : Reflect.field(difficultyData, "mines")
                });
            }
        }
        
        return cacheObj;
    }

    public function new()
    {
    }
}

