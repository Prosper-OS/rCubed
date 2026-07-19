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
    public var lockUI(never, set) : Bool;

    private static var INITIAL_LOAD : Bool = false;
    public static var REPLAYS : Array<Replay> = [];
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    private var _avars : ArcGlobals = ArcGlobals.instance;
    
    private var btn_refresh : BoxButton;
    
    private var uiLock : Sprite;
    private var uiLockBG : Bitmap;
    private var loadingIndex : Text;
    private var loadingProgress : ProgressBar;
    private var loadingCancelButton : BoxButton;
    private var cancelRequested : Bool = false;
    
    public function new(replayWindow : ReplayHistoryWindow)
    {
        super(replayWindow);
        
        // UI Lock
        uiLock = new Sprite();
        var lockUIText : Text = new Text(uiLock, 0, 200, _lang.string("replay_loading_external"), 24);
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
        
        if (btn_refresh == null)
        {
            btn_refresh = new BoxButton(null, 5, 410, 162, 29, _lang.string("menu_refresh"), 12, refreshReplays);
        }
        parent.addChild(btn_refresh);
        
        // Initial Load
        if (!INITIAL_LOAD)
        {
            if (!_gvars.file_replay_cache.cacheFound)
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
        var render_list : Array<Dynamic> = [];
        for (r in REPLAYS)
        {
            if (r.song == null)
            {
                continue;
            }
            
            if (parent.searchText.length >= 1 && r.song.name.toLowerCase().indexOf(parent.searchText) == -1)
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
        
        var idx : Int = 0;
        var cache : Dynamic = _gvars.file_replay_cache.cache;
        var TIME : Float = Date.now().getTime();
        
        var r : Replay;
        var cacheObj : Dynamic;
        
        for (key in Reflect.fields(cache))
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
            if (Reflect.field(cacheObj, "engine") != null)
            {
                var engine : Dynamic = _avars.legacyEngine(Reflect.field(cacheObj, "engine"));
                if (engine == null)
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
    
    private function refreshReplays(e : MouseEvent = null) : Void
    {
        Logger.info(this, "Reloading External Replays");
        lockUI = true;
        
        _gvars.file_replay_cache.clear();
        REPLAYS = [];
        
        var loadTimer : Timer;
        var TIME : Float = Date.now().getTime();
        
        // File Searching
        var dirQueue : Array<FileDirectoryQueue> = [new FileDirectoryQueue(AirContext.getAppFile("replays"), 0)];
        var fileQueue : Array<File> = [];
        var activeDirQueue : FileDirectoryQueue;
        var maxDepth : Int = 2;
        
        e_startFileSearch();
        
        var e_startFileSearch : Void->Void = function() : Void
        {
            loadingIndex.text = "";
            loadingProgress.update(0);
            
            loadTimer = new Timer(20, 1);
            loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_searchTimer);
            loadTimer.start();
        }
        
        function e_searchTimer(e : TimerEvent) : Void
        {
            var startTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
            var isDelay : Bool = false;
            
            // File Loop
            var found : Array<Dynamic>;
            var len : Int;
            var file : File;
            var i : Int;
            
            while (dirQueue.length > 0)
            {
                activeDirQueue = dirQueue.pop();
                
                found = activeDirQueue.dir.getDirectoryListing();
                len = found.length;
                
                for (i in 0...len)
                {
                    file = found[i];
                    
                    if (file.isHidden || !file.exists)
                    {
                        continue;
                    }
                    else if (file.isDirectory)
                    {
                        if (activeDirQueue.level < maxDepth)
                        {
                            dirQueue.push(new FileDirectoryQueue(file, activeDirQueue.level + 1));
                        }
                    }
                    else if (file.extension != null && file.extension.toLowerCase() == "txt")
                    {
                        fileQueue.push(file);
                    }
                }
                
                var endTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
                if (endTimer - startTimer > 250)
                {
                    isDelay = true;
                    break;
                }
            }
            
            if (cancelRequested)
            {
                as3hx.Compat.setArrayLength(dirQueue, 0);
                as3hx.Compat.setArrayLength(fileQueue, 0);
            }
            
            loadingIndex.text = "#" + fileQueue.length;
            
            // Loaded All Files
            if (dirQueue.length == 0)
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_searchTimer);
                e_startFileQueue();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (isDelay && dirQueue.length > 0)
            {
                loadTimer.start();
            }
        }  // File Loading  ;
        
        
        
        var pathIndex : Int;
        var pathTotal : Int;
        
        var e_startFileQueue : Void->Void = function() : Void
        {
            if (fileQueue.length <= 0)
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
        
        var e_parseTimer : TimerEvent->Void = function(e : TimerEvent) : Void
        {
            var r : Replay;
            var chartFile : File;
            var stringPath : String;
            var startTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
            var isDelay : Bool = false;
            var cacheObj : Dynamic;
            
            while (pathIndex < pathTotal)
            {
                chartFile = fileQueue[pathIndex];
                stringPath = chartFile.nativePath;
                
                loadingIndex.text = pathIndex + " / " + pathTotal;
                
                r = new Replay(TIME + pathIndex);
                
                // Read File
                var txt : String = Std.string(AirContext.readFile(chartFile));
                r.parseEncode(txt, false);
                r.fileReplay = true;
                if (r.isValid())
                {
                    r.loadSongInfo();
                    
                    if (r.song != null)
                    {
                        REPLAYS[REPLAYS.length] = r;
                        
                        cacheObj = {
                                    name : r.song.name,
                                    rate : r.settings.songRate,
                                    score : r.score,
                                    judge : [r.perfect, r.good, r.average, r.miss, r.boo, r.maxcombo]
                                };
                        
                        if (r.settings.arc_engine != null)
                        {
                            Reflect.setField(cacheObj, "engine", r.song.engine.id);
                        }
                        
                        _gvars.file_replay_cache.setValue(chartFile.parent.name + "/" + chartFile.name, cacheObj);
                    }
                }
                
                pathIndex++;
                
                if (cancelRequested)
                {
                    pathIndex = 0;
                    pathTotal = 0;
                    as3hx.Compat.setArrayLength(fileQueue, 0);
                    as3hx.Compat.setArrayLength(REPLAYS, 0);
                }
                
                var endTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
                if (endTimer - startTimer > 250)
                {
                    loadingProgress.update(pathIndex / pathTotal);
                    isDelay = true;
                    break;
                }
            }
            
            // Loaded All Files
            if (pathIndex >= pathTotal)
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_parseTimer);
                _gvars.file_replay_cache.save();
                lockUI = false;
                
                setValues();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (isDelay && pathIndex < pathTotal)
            {
                loadTimer.start();
            }
        }
    }
    
    private function clickHandler(e : MouseEvent) : Void
    {
        if (e.target == loadingCancelButton)
        {
            cancelRequested = true;
        }
    }
    
    private function set_lockUI(val : Bool) : Bool
    {
        cancelRequested = false;
        if (val)
        {
            uiLockBG = SpriteUtil.getBitmapSprite(_gvars.gameMain.stage, 0.3);
            uiLock.addChildAt(uiLockBG, 0);
            parent.addChild(uiLock);
        }
        else if (parent.contains(uiLock))
        {
            uiLock.removeChildAt(0);
            uiLockBG = null;
            parent.removeChild(uiLock);
        }
        return val;
    }
    
    override public function prepareReplay(r : Replay) : Replay
    // Incomplete
    {
        
        try
        {
            if (r.filePath != null)
            {
                Logger.debug(this, "Loading Local replay: " + "replays/" + r.filePath);
                var txt : String = Std.string(AirContext.readFile(AirContext.getAppFile("replays/" + r.filePath)));
                
                if (txt != null && txt.length > 0)
                {
                    r.parseEncode(txt, false);
                    r.fileReplay = true;
                    if (r.isValid())
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
    public var dir : File;
    public var level : Int;
    
    @:allow(popups.replays)
    private function new(dir : File, level : Int)
    {
        this.dir = dir;
        this.level = level;
    }
}
