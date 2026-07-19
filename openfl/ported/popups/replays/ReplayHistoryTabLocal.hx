package popups.replays;

import openfl.errors.Error;
import arc.ArcGlobals;
import classes.Language;
import classes.SongInfo;
import classes.replay.Replay;
import classes.ui.BoxButton;
import classes.ui.ProgressBar;
import classes.ui.Text;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import r3.air.filesystem.File;
import openfl.utils.Timer;


class ReplayHistoryTabLocal extends ReplayHistoryTabBase
{
    private static var e_searchTimer                  : Dynamic;
    private static var e_startFileSearch                    : Dynamic;
    private static var e_startFileQueue                    : Dynamic;
    private static var e_parseTimer                    : Dynamic;
    public var lockUI(never, set)                       : Dynamic;

    private static var INITIAL_LOAD                       : Dynamic= false;
    public static var REPLAYS                       : Dynamic= [];
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    
    private var btn_refresh                       : Dynamic;
    
    private var uiLock                       : Dynamic;
    private var uiLockBG                       : Dynamic;
    private var loadingIndex                       : Dynamic;
    private var loadingProgress                       : Dynamic;
    private var loadingCancelButton                       : Dynamic;
    private var cancelRequested                       : Dynamic= false;
    
    public function new(replayWindow                       : Dynamic)
    {
        super(replayWindow);
        
        // UI Lock
        uiLock = new Sprite();
        var lockUIText                       : Dynamic= new Text(uiLock, 0, 200, _lang.string("replay_loading_external"), 24);
        lockUIText.setAreaParams(780, 30, "center");
        
        loadingIndex = new Text(uiLock, 0, 340, "", 20);
        loadingIndex.setAreaParams(780, 30, "center");
        
        loadingProgress = new ProgressBar(uiLock, (Main.GAME_WIDTH - 450) / 2, 380, 450);
        
        loadingCancelButton = new BoxButton(uiLock, 390 - 40, 440, 80, 30, _lang.string("menu_cancel"), 12, clickHandler);
    }
    
    override private function get_name() : String
    {
        return "local";
    }
    
    override public function openTab() : Void
    // Add UI Elements
    {
        
        if (as3hx.Compat.truthy(btn_refresh == null))
        {
            btn_refresh = new BoxButton(null, 5, 410, 162, 29, _lang.string("menu_refresh"), 12, refreshReplays);
        }
        parent.addChild(btn_refresh);
        
        // Initial Load
        if (as3hx.Compat.truthy(!INITIAL_LOAD))
        {
            if (as3hx.Compat.truthy(!_gvars.file_replay_cache.cacheFound))
            {
                refreshReplays();
            }
            else
            {
                loadCachedReplays();
            }
            
            INITIAL_LOAD = true;
        }
    }
    
    override public function closeTab() : Void
    {
        parent.removeChild(btn_refresh);
    }
    
    override public function setValues() : Void
    {
        var render_list                       : Dynamic= [];
        for (r in as3hx.Compat.iter(REPLAYS))
        {
            if (as3hx.Compat.truthy(r.song == null))
            {
                continue;
            }
            
            if (as3hx.Compat.truthy(parent.searchText.length >= 1 && r.song.name.toLowerCase().indexOf(parent.searchText) == -1))
            {
                continue;
            }
            
            render_list[render_list.length] = r;
        }
        parent.pane.setRenderList(render_list);
        parent.updateScrollPane();
    }
    
    private function loadCachedReplays() : Void
    {
        Logger.info(this, "Loading Cached Replays");
        REPLAYS = [];
        
        var idx                       : Dynamic= 0;
        var cache                       : Dynamic= _gvars.file_replay_cache.cache;
        var TIME                       : Dynamic= Date.now().getTime();
        
        var r                       : Dynamic= null;
        var cacheObj                       : Dynamic= null;
        
        for (key in as3hx.Compat.iter(Reflect.fields(cache)))
        {
            cacheObj = Reflect.field(cache, key);
            
            r = new Replay(TIME + idx);
            r.filePath = key;
            
            r.song = new SongInfo();
            r.song.name = Reflect.field(cacheObj, "name");
            
            r.score = Reflect.field(cacheObj, "score");
            r.perfect = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(0));
            r.good = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(1));
            r.average = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(2));
            r.miss = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(3));
            r.boo = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(4));
            r.maxcombo = Reflect.field(Reflect.field(cacheObj, "judge"), Std.string(5));
            
            r.settings = {
                        songRate : Reflect.field(cacheObj, "rate")
                    };
            if (as3hx.Compat.truthy(Reflect.field(cacheObj, "engine") != null))
            {
                var engine                       : Dynamic= _avars.legacyEngine(Reflect.field(cacheObj, "engine"));
                if (as3hx.Compat.truthy(engine == null))
                {
                    engine = {
                                id : Reflect.field(cacheObj, "engine")
                            };
                }
                
                r.settings.arc_engine = {
                            engineID : Reflect.field(cacheObj, "engine")
                        };
                
                r.song.engine = engine;
            }
            
            REPLAYS[REPLAYS.length] = r;
        }
        
        setValues();
    }
    
    private function refreshReplays(e                       : Dynamic= null) : Void
    {
        Logger.info(this, "Reloading External Replays");
        lockUI = true;
        
        _gvars.file_replay_cache.clear();
        REPLAYS = [];
        
        var loadTimer                       : Dynamic= null;
        var TIME                       : Dynamic= Date.now().getTime();
        
        // File Searching
        var dirQueue                       : Dynamic= [new FileDirectoryQueue(AirContext.getAppFile("replays"), 0)];
        var fileQueue                       : Dynamic= [];
        var activeDirQueue                       : Dynamic= null;
        var maxDepth                       : Dynamic= 2;
        
        e_startFileSearch();
        
        e_startFileSearch = function() : Void
        {
            loadingIndex.text = "";
            loadingProgress.update(0);
            
            loadTimer = new Timer(20, 1);
            loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_searchTimer);
            loadTimer.start();
        }
        
        e_searchTimer = function(e                       : Dynamic) : Void
        {
            var startTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
            var isDelay                       : Dynamic= false;
            
            // File Loop
            var found                       : Dynamic= null;
            var len                       : Dynamic= null;
            var file                       : Dynamic= null;
            var i                       : Dynamic= null;
            
            while (as3hx.Compat.truthy(dirQueue.length > 0))
            {
                activeDirQueue = dirQueue.pop();
                
                found = activeDirQueue.dir.getDirectoryListing();
                len = found.length;
                
                for (i in 0...len)
                {
                    file = found[i];
                    
                    if (as3hx.Compat.truthy(file.isHidden || !file.exists))
                    {
                        continue;
                    }
                    else if (as3hx.Compat.truthy(file.isDirectory))
                    {
                        if (as3hx.Compat.truthy(activeDirQueue.level < maxDepth))
                        {
                            dirQueue.push(new FileDirectoryQueue(file, activeDirQueue.level + 1));
                        }
                    }
                    else if (as3hx.Compat.truthy(file.extension != null && file.extension.toLowerCase() == "txt"))
                    {
                        fileQueue.push(file);
                    }
                }
                
                var endTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
                if (as3hx.Compat.truthy(endTimer - startTimer > 250))
                {
                    isDelay = true;
                    break;
                }
            }
            
            if (as3hx.Compat.truthy(cancelRequested))
            {
                as3hx.Compat.setArrayLength(dirQueue, 0);
                as3hx.Compat.setArrayLength(fileQueue, 0);
            }
            
            loadingIndex.text = "#" + fileQueue.length;
            
            // Loaded All Files
            if (as3hx.Compat.truthy(dirQueue.length == 0))
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_searchTimer);
                e_startFileQueue();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (as3hx.Compat.truthy(isDelay && dirQueue.length > 0))
            {
                loadTimer.start();
            }
        }  // File Loading  ;
        
        
        
        var pathIndex                       : Dynamic= null;
        var pathTotal                       : Dynamic= null;
        
        e_startFileQueue = function() : Void
        {
            if (as3hx.Compat.truthy(fileQueue.length <= 0))
            {
                lockUI = false;
                setValues();
                return;
            }
            
            pathIndex = 0;
            pathTotal = fileQueue.length;
            
            loadingIndex.text = pathIndex + " / " + pathTotal;
            loadingProgress.update(0);
            
            loadTimer = new Timer(20, 1);
            loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_parseTimer);
            loadTimer.start();
        }
        
        e_parseTimer = function(e                       : Dynamic) : Void
        {
            var r                       : Dynamic= null;
            var chartFile                       : Dynamic= null;
            var stringPath                       : Dynamic= null;
            var startTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
            var isDelay                       : Dynamic= false;
            var cacheObj                       : Dynamic= null;
            
            while (as3hx.Compat.truthy(pathIndex < pathTotal))
            {
                chartFile = fileQueue[pathIndex];
                stringPath = chartFile.nativePath;
                
                loadingIndex.text = pathIndex + " / " + pathTotal;
                
                r = new Replay(TIME + pathIndex);
                
                // Read File
                var txt                       : Dynamic= Std.string(AirContext.readFile(chartFile));
                r.parseEncode(txt, false);
                r.fileReplay = true;
                if (as3hx.Compat.truthy(r.isValid()))
                {
                    r.loadSongInfo();
                    
                    if (as3hx.Compat.truthy(r.song != null))
                    {
                        REPLAYS[REPLAYS.length] = r;
                        
                        cacheObj = {
                                    name : r.song.name,
                                    rate : r.settings.songRate,
                                    score : r.score,
                                    judge : [r.perfect, r.good, r.average, r.miss, r.boo, r.maxcombo]
                                };
                        
                        if (as3hx.Compat.truthy(r.settings.arc_engine != null))
                        {
                            Reflect.setField(cacheObj, "engine", r.song.engine.id);
                        }
                        
                        _gvars.file_replay_cache.setValue(chartFile.parent.name + "/" + chartFile.name, cacheObj);
                    }
                }
                
                pathIndex++;
                
                if (as3hx.Compat.truthy(cancelRequested))
                {
                    pathIndex = 0;
                    pathTotal = 0;
                    as3hx.Compat.setArrayLength(fileQueue, 0);
                    as3hx.Compat.setArrayLength(REPLAYS, 0);
                }
                
                var endTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
                if (as3hx.Compat.truthy(endTimer - startTimer > 250))
                {
                    loadingProgress.update(pathIndex / pathTotal);
                    isDelay = true;
                    break;
                }
            }
            
            // Loaded All Files
            if (as3hx.Compat.truthy(pathIndex >= pathTotal))
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_parseTimer);
                _gvars.file_replay_cache.save();
                lockUI = false;
                
                setValues();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (as3hx.Compat.truthy(isDelay && pathIndex < pathTotal))
            {
                loadTimer.start();
            }
        }
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == loadingCancelButton))
        {
            cancelRequested = true;
        }
    }
    
    private function set_lockUI(val                       : Dynamic) : Bool
    {
        cancelRequested = false;
        if (as3hx.Compat.truthy(val))
        {
            uiLockBG = SpriteUtil.getBitmapSprite(_gvars.gameMain.stage, 0.3);
            uiLock.addChildAt(uiLockBG, 0);
            parent.addChild(uiLock);
        }
        else if (as3hx.Compat.truthy(parent.contains(uiLock)))
        {
            uiLock.removeChildAt(0);
            uiLockBG = null;
            parent.removeChild(uiLock);
        }
        return val;
    }
    
    override public function prepareReplay(r                       : Dynamic) : Replay
    // Incomplete
    {
        
        try
        {
            if (as3hx.Compat.truthy(r.filePath != null))
            {
                Logger.debug(this, "Loading Local replay: " + "replays/" + r.filePath);
                var txt                       : Dynamic= Std.string(AirContext.readFile(AirContext.getAppFile("replays/" + r.filePath)));
                
                if (as3hx.Compat.truthy(txt != null && txt.length > 0))
                {
                    r.parseEncode(txt, false);
                    r.fileReplay = true;
                    if (as3hx.Compat.truthy(r.isValid()))
                    {
                        r.loadSongInfo();
                        return r;
                    }
                }
                
                return null;
            }
        }
        catch (e : Error)
        {
            Logger.error(this, "Loading replay txt file error:");
            Logger.exception_error(e);
            return null;
        }
        
        return r;
    }
}



class FileDirectoryQueue
{
    private static var e_searchTimer                  : Dynamic;
    private static var e_startFileSearch                    : Dynamic;
    private static var e_startFileQueue                    : Dynamic;
    private static var e_parseTimer                    : Dynamic;
    public var dir                       : Dynamic;
    public var level                       : Dynamic;
    
    @:allow(popups.replays)
    private function new(dir                       : Dynamic, level                       : Dynamic)
    {
        this.dir = dir;
        this.level = level;
    }
}
