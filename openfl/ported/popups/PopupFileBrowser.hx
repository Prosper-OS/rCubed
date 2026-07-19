package popups;

import assets.menu.icons.fa.IconClose;
import assets.menu.icons.fa.IconFolder;
import assets.menu.icons.fa.IconRefresh;
import classes.Alert;
import classes.Language;
import classes.chart.parse.ExternalChartBase;
import classes.mp.Multiplayer;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.BoxText;
import classes.ui.Text;
import com.bit101.components.ComboBox;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import r3.air.filesystem.File;
import openfl.filters.BlurFilter;
import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.text.TextFormat;
import openfl.utils.Timer;
import menu.FileLoader;
import menu.MainMenu;
import menu.MenuPanel;
import popups.filebrowser.FileBrowserDifficultyItem;
import popups.filebrowser.FileBrowserFilter;
import popups.filebrowser.FileBrowserItem;
import popups.filebrowser.FileBrowserList;
import popups.filebrowser.FileFolder;
import popups.filebrowser.FileFolderItem;


class PopupFileBrowser extends MenuPanel
{
    public var lockUI(never, set) : Bool;

    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    private static var _lang : Language = Language.instance;
    private static var _mp : Multiplayer = Multiplayer.instance;
    
    public var lc : LoaderContext = new LoaderContext();
    
    public static var rootFolder : File;
    public static var lastSelectedIndex : Int = 0;
    public static var listFilter : FileBrowserFilter = new FileBrowserFilter();
    
    public static var pathList : Array<String> = [];
    
    //- Background
    private var box : Box;
    private var bmd : BitmapData;
    private var bmp : Bitmap;
    private var dividers : Sprite;
    
    private var refreshAllFolder : BoxIcon;
    private var displayFolderPath : Text;
    private var selectFolder : BoxIcon;
    private var closeWindow : BoxIcon;
    
    private var searchInput : BoxText;
    private var searchPlaceholder : Text;
    private var searchTypeBox : ComboBox;
    
    private var lastSelectedItem : FileBrowserItem;
    private var songBrowser : FileBrowserList;
    private var songDetails : Sprite;
    private var songDetailsWidth : Float = 0;
    private var songDifficulties : Array<Dynamic> = [];
    
    private var _isLocked : Bool = false;
    private var uiLock : Sprite;
    private var loadingPathIndex : Text;
    private var loadingPathFolder : Text;
    private var loadingPathSong : Text;
    private var loadingCancelButton : BoxButton;
    private var cancelRequested : Bool = false;
    
    public function new(myParent : MenuPanel)
    {
        super(myParent);
    }
    
    override public function stageAdd() : Void
    {
        bmd = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
        bmd.draw(stage);
        bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
        bmp = new Bitmap(bmd);
        
        this.addChild(bmp);
        
        var bgbox : Box = new Box(this, -1, -1, false, false);
        bgbox.setSize(Main.GAME_WIDTH + 2, Main.GAME_HEIGHT + 2);
        bgbox.color = 0x000000;
        bgbox.normalAlpha = 0.7;
        bgbox.activeAlpha = 1;
        
        box = new Box(this, -1, -1, false, false);
        box.setSize(Main.GAME_WIDTH + 2, Main.GAME_HEIGHT + 2);
        box.activeAlpha = 0.5;
        
        dividers = new Sprite();
        dividers.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        box.addChild(dividers);
        
        // Top Bar Item
        closeWindow = new BoxIcon(box, box.width - 34, 6, 27, 27, new IconClose(), clickHandler);
        selectFolder = new BoxIcon(box, closeWindow.x - 32, 6, 27, 27, new IconFolder(), clickHandler);
        
        displayFolderPath = new Text(box, 40, 6, _lang.string("file_loader_no_folder_selected"));
        displayFolderPath.setAreaParams(selectFolder.x - displayFolderPath.x - 5, 27);
        displayFolderPath.mouseEnabled = true;
        displayFolderPath.useHandCursor = true;
        displayFolderPath.buttonMode = true;
        displayFolderPath.addEventListener(MouseEvent.CLICK, clickHandler);
        
        dividers.graphics.beginFill(0x000000, 0.2);
        dividers.graphics.drawRect(displayFolderPath.x - 2, displayFolderPath.y, displayFolderPath.width + 2, displayFolderPath.height);
        dividers.graphics.endFill();
        
        refreshAllFolder = new BoxIcon(box, 6, 6, 27, 27, new IconRefresh(), clickHandler);
        refreshAllFolder.setHoverText(_lang.string("file_loader_refresh_cache"), "bottom");
        
        // Song List
        songBrowser = new FileBrowserList(box, 6, 39, listFilter);
        songBrowser.addEventListener(MouseEvent.CLICK, e_songListClick);
        songBrowser.activeIndex = lastSelectedIndex;
        
        songDetails = new Sprite();
        songDetails.x = 541;
        songDetails.y = 39;
        songDetailsWidth = box.width - 7 - songDetails.x;
        box.addChild(songDetails);
        
        // Search
        searchPlaceholder = new Text(box, 13, box.height - 29, _lang.string("file_loader_search"));
        searchPlaceholder.alpha = 0.4;
        searchPlaceholder.visible = listFilter.term.length == 0;
        searchInput = new BoxText(box, 11, box.height - 32, 370, 25, new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 12, 0xFFFFFF));
        searchInput.text = listFilter.term;
        searchInput.addEventListener(Event.CHANGE, e_searchChange);
        
        // Search Type
        var searchTypeBoxItems : Array<Dynamic> = [{
            label : _lang.stringSimple("song_selection_search_any"),
            data : "any"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_song_name"),
            data : "name"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_author"),
            data : "author"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_stepauthor"),
            data : "stepauthor"
        }
    ];
        
        searchTypeBox = new ComboBox(null, searchInput.x + searchInput.width + 5, box.height - 32, "", searchTypeBoxItems);
        searchTypeBox.setSize(144, 27);
        searchTypeBox.fontSize = 11;
        searchTypeBox.selectedItemByData = listFilter.type;
        searchTypeBox.openPosition = ComboBox.TOP;
        searchTypeBox.addEventListener(Event.SELECT, searchTypeSelect);
        box.addChild(searchTypeBox);
        
        dividers.graphics.beginFill(0x000000, 0.2);
        dividers.graphics.drawRect(6, box.height - 37, 529, 45);
        dividers.graphics.endFill();
        
        // Song Info
        dividers.graphics.beginFill(0x000000, 0.2);
        dividers.graphics.drawRect(songDetails.x, songDetails.y, songDetailsWidth, box.height - 44);
        dividers.graphics.endFill();
        
        // Scroll Bar
        dividers.graphics.beginFill(0x000000, 0.2);
        dividers.graphics.drawRect(songBrowser.x + songBrowser.width - 24, songBrowser.y, 22, songBrowser.height);
        dividers.graphics.endFill();
        
        // UI Lock
        uiLock = new Sprite();
        uiLock.graphics.lineStyle(0, 0, 0);
        uiLock.graphics.beginFill(0x000000, 0.7);
        uiLock.graphics.drawRect(0, 0, 780, 480);
        uiLock.graphics.endFill();
        
        var lockUIText : Text = new Text(uiLock, 0, 200, _lang.string("file_loader_loading_files"), 24);
        lockUIText.setAreaParams(780, 30, "center");
        
        loadingPathIndex = new Text(uiLock, 0, 340, "", 20);
        loadingPathIndex.setAreaParams(780, 30, "center");
        loadingPathFolder = new Text(uiLock, 0, 371, "", 22);
        loadingPathFolder.setAreaParams(780, 30, "center");
        loadingPathSong = new Text(uiLock, 0, 400, "", 18);
        loadingPathSong.setAreaParams(780, 30, "center");
        
        loadingCancelButton = new BoxButton(uiLock, 390 - 40, 440, 80, 30, _lang.string("menu_cancel"), 12, clickHandler);
        
        if (rootFolder != null && pathList == null)
        {
            refreshFolder();
        }
        else if (rootFolder != null && pathList != null)
        {
            displayFolderPath.text = rootFolder.nativePath;
            buildFileList();
        }
    }
    
    override public function stageRemove() : Void
    {
        closeWindow.dispose();
        box.dispose();
        this.removeChild(box);
        this.removeChild(bmp);
        bmd = null;
        bmp = null;
        box = null;
    }
    
    public function buildFileList() : Void
    {
        var renderList : Array<Dynamic> = [];
        var cacheValue : Dynamic;
        
        // List Building
        var path : String;
        var endOfFolder : Float;
        var arLen : Float = pathList.length;
        for (i in 0...arLen)
        {
            cacheValue = FileLoader.cache.getValue(pathList[i]);
            path = pathList[i];
            endOfFolder = path.lastIndexOf(File.separator) + 1;
            renderList[i] = new FileFolder(path.substr(0, endOfFolder), path.substr(endOfFolder), Reflect.field(cacheValue, "ext"), new FileFolderItem(pathList[i], cacheValue));
        }
        
        // Folder Merging
        var elm1 : FileFolder;
        var elm2 : FileFolder;
        var n : Int;
        renderList.sortOn(["folder", "ext"], [Array.CASEINSENSITIVE, Array.CASEINSENSITIVE]);
        for (i in 0...arLen - 1)
        {
            elm1 = renderList[i];
            for (n in i + 1...arLen)
            {
                elm2 = renderList[n];
                if (elm1.folder == elm2.folder && elm1.ext == elm2.ext)
                {
                    while (elm2.data.length > 0)
                    {
                        elm1.data.push(elm2.data.pop());
                    }
                    
                    renderList.splice(n, 1)[0];
                    n--;
                    arLen--;
                }
                else
                {
                    break;
                }
            }
        }
        
        // Sorting
        for (i in 0...arLen)
        {
            elm1 = renderList[i];
            elm1.author = elm1.data[0].info.author;
            elm1.name = elm1.data[0].info.name;
            elm1.stepauthor = elm1.data[0].info.stepauthor;
            elm1.banner = elm1.data[0].info.banner;
        }
        renderList.sortOn(["name", "author"], [Array.CASEINSENSITIVE, Array.CASEINSENSITIVE]);
        
        // Display
        songBrowser.setRenderList(renderList);
        
        // Set Active Item
        if (renderList.length > 0)
        {
            selectedItem(songBrowser.findSongButtonByIndex(lastSelectedIndex));
        }
    }
    
    private function dirSelected(e : Event) : Void
    {
        if (stage)
        {
            stage.focus = null;
        }
        
        rootFolder = try cast(e.target, File) catch(e:Dynamic) null;
        refreshFolder();
    }
    
    private function clickHandler(e : MouseEvent) : Void
    {
        if (stage)
        {
            stage.focus = null;
        }
        
        if (e.target == refreshAllFolder)
        {
            refreshCache();
        }
        else if (e.target == selectFolder || e.target == displayFolderPath)
        {
            var tempFolder : File = new File();
            tempFolder.addEventListener(Event.SELECT, dirSelected);
            tempFolder.browseForDirectory(_lang.stringSimple("file_loader_select_a_directory"));
        }
        else if (e.target == loadingCancelButton)
        {
            cancelRequested = true;
        }
        else if (e.target == closeWindow)
        {
            removePopup();
        }
    }
    
    private function searchTypeSelect(e : Event) : Void
    {
        listFilter.type = e.target.selectedItem["data"];
    }
    
    
    private function refreshCache() : Void
    {
        lockUI = true;
        
        var paths : Array<String> = FileLoader.cache.keys;
        var fileQueue : Array<File> = [];
        var file : File;
        
        as3hx.Compat.setArrayLength(pathList, 0);
        
        for (path in paths)
        {
            file = new File(path);
            
            if (file.isHidden || !file.exists)
            {
                FileLoader.cache.deleteKey(path);
            }
            
            fileQueue.push(file);
        }
        
        _parseFileQueue(fileQueue);
    }
    
    private function refreshFolder() : Void
    {
        if (rootFolder == null)
        {
            return;
        }
        
        lastSelectedIndex = 0;
        lastSelectedItem = null;
        
        as3hx.Compat.setArrayLength(pathList, 0);
        
        displayFolderPath.text = rootFolder.nativePath;
        
        lockUI = true;
        
        var loadTimer : Timer;
        
        // File Searching
        var dirQueue : Array<FileDirectoryQueue> = [new FileDirectoryQueue(rootFolder, 0)];
        var fileQueue : Array<File> = [];
        var activeDirQueue : FileDirectoryQueue;
        var maxDepth : Int = 2;
        var validExt : Array<Dynamic> = ExternalChartBase.VALID_CHART_EXTENSIONS;
        
        loadingPathIndex.text = _lang.string("file_loader_scanning");
        loadingPathFolder.text = "";
        loadingPathSong.text = "";
        
        loadTimer = new Timer(20, 1);
        loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
        loadTimer.start();
        
        var e_timerComplete : TimerEvent->Void = function(e : TimerEvent) : Void
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
                    else if (file.extension != null && Lambda.indexOf(validExt, file.extension.toLowerCase()) != -1)
                    {
                        fileQueue.push(file);
                    }
                }
                
                var endTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
                if (endTimer - startTimer > 200)
                {
                    isDelay = true;
                    break;
                }
            }
            
            if (cancelRequested)
            {
                as3hx.Compat.setArrayLength(dirQueue, 0);
                as3hx.Compat.setArrayLength(fileQueue, 0);
                as3hx.Compat.setArrayLength(pathList, 0);
            }
            
            loadingPathIndex.text = sprintf(_lang.string("file_loader_found_files"), {
                                files : fileQueue.length
                            });
            
            // Loaded All Files
            if (dirQueue.length == 0)
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
                _parseFileQueue(fileQueue);
                return;
            }
            
            // Not Finished, Continue next frame.
            if (isDelay && dirQueue.length > 0)
            {
                loadTimer.start();
            }
        }
    }
    
    private function _parseFileQueue(fileQueue : Array<File>) : Void
    {
        var loadTimer : Timer;
        
        // File Loading
        var rootFolderPath : String = (rootFolder != null) ? rootFolder.nativePath : "";
        var pathIndex : Int;
        var pathTotal : Int;
        
        if (fileQueue.length <= 0)
        {
            lockUI = false;
            buildFileList();
            return;
        }
        
        pathIndex = 0;
        pathTotal = fileQueue.length;
        
        loadingPathIndex.text = pathIndex + " / " + pathTotal;
        loadingPathFolder.text = "";
        loadingPathSong.text = "";
        
        loadTimer = new Timer(20, 1);
        loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
        loadTimer.start();
        
        var e_timerComplete : TimerEvent->Void = function(e : TimerEvent) : Void
        {
            var chartFile : File;
            var stringPath : String;
            var startTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
            var isDelay : Bool = false;
            var cacheObj : Dynamic;
            
            while (pathIndex < pathTotal)
            {
                chartFile = fileQueue[pathIndex];
                stringPath = chartFile.nativePath;
                
                cacheObj = FileLoader.cache.getValue(stringPath);
                var needUpdate : Bool = cacheObj == null || chartFile.modificationDate.getTime() != Reflect.field(cacheObj, "date");
                
                if (!needUpdate)
                {
                    if (cacheObj.valid == 1)
                    {
                        pathList.push(stringPath);
                    }
                }
                else
                {
                    loadingPathIndex.text = pathIndex + " / " + pathTotal;
                    
                    if (chartFile.parent.parent.nativePath == rootFolderPath)
                    {
                        loadingPathFolder.text = chartFile.parent.name;
                        loadingPathSong.text = "";
                    }
                    else
                    {
                        loadingPathFolder.text = chartFile.parent.parent.name;
                        loadingPathSong.text = chartFile.parent.name;
                    }
                    
                    cacheObj = FileLoader.buildCacheObject(chartFile);
                    
                    FileLoader.cache.setValue(stringPath, cacheObj);
                    
                    if (cacheObj.valid == 1)
                    {
                        pathList.push(stringPath);
                    }
                }
                pathIndex++;
                
                if (cancelRequested)
                {
                    pathIndex = 0;
                    pathTotal = 0;
                    as3hx.Compat.setArrayLength(fileQueue, 0);
                    as3hx.Compat.setArrayLength(pathList, 0);
                }
                
                var endTimer : Float = Math.round(haxe.Timer.stamp() * 1000);
                if (endTimer - startTimer > 200)
                {
                    isDelay = true;
                    break;
                }
            }
            
            // Loaded All Files
            if (pathIndex >= pathTotal)
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
                FileLoader.cache.save();
                lockUI = false;
                
                buildFileList();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (isDelay && pathIndex < pathTotal)
            {
                loadTimer.start();
            }
        }
    }
    
    private function selectedItem(item : FileBrowserItem) : Void
    {
        if (item == null)
        {
            return;
        }
        
        if (lastSelectedItem != null)
        {
            lastSelectedItem.highlight = false;
        }
        
        item.highlight = true;
        setInfoBox(item.songData);
        lastSelectedIndex = item.index;
        lastSelectedItem = item;
        songBrowser.activeIndex = item.index;
    }
    
    private function e_searchChange(e : Event) : Void
    {
        if (_isLocked)
        {
            return;
        }
        
        listFilter.term = searchInput.text;
        searchPlaceholder.visible = searchInput.text.length == 0;
        songBrowser.updateList();
        selectedItem(songBrowser.findSongButtonByIndex(lastSelectedIndex));
    }
    
    private function e_songListClick(e : MouseEvent) : Void
    {
        if (Std.is(e.target, FileBrowserItem))
        {
            selectedItem(try cast(e.target, FileBrowserItem) catch(e:Dynamic) null);
        }
    }
    
    public function setInfoBox(info : FileFolder) : Void
    {
        songDetails.removeChildren();
        as3hx.Compat.setArrayLength(songDifficulties, 0);
        
        var infoTitle : Text;
        var infoDetails : Text;
        var tY : Int = 83;
        
        // Create Holder Sprite
        var sr : Sprite = drawInfoBannerSprite(0, 0.3);
        sr.x = 10;
        sr.y = 10;
        songDetails.addChild(sr);
        
        // Mask
        var srm : Sprite = drawInfoBannerSprite(0, 1);
        sr.addChild(srm);
        sr.mask = srm;
        
        // Border
        var srb : Sprite = drawInfoBannerSprite(0.35, 0);
        srb.x = 10;
        srb.y = 10;
        songDetails.addChild(srb);
        
        // Banner
        if (info.banner != "") {
var bannerExt : String = info.banner.substr(info.banner.lastIndexOf(".") + 1).toLowerCase();
            if (bannerExt == "jpg" || bannerExt == "png" || bannerExt == "gif" || bannerExt == "jpeg")
            {
                var path : String = "file:///" + info.folder + info.banner;
                var imageLoader : Loader = new Loader();
                imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_bannerLoaded);
                imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bannerLoaded);
                imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bannerLoaded);
                imageLoader.load(new URLRequest(path), lc);
                
                function e_bannerLoaded(e : Event) : Void
                // Position Loaded Banner Image
                {
                    
                    if (e.type == Event.COMPLETE && e.target != null && ((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content) != null)
                    {
                        var bmp : Bitmap = try cast(((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content), Bitmap) catch(e:Dynamic) null;
                        bmp.smoothing = true;
                        bmp.pixelSnapping = "always";
                        sr.addChildAt(bmp, 1);
                        
                        var imageScale : Float = 214 / bmp.width;
                        
                        bmp.scaleX = bmp.scaleY = imageScale;
                        
                        if (bmp.height < 70)
                        {
                            bmp.scaleX = bmp.scaleY = 1;
                            imageScale = 70 / bmp.height;
                            bmp.scaleX = bmp.scaleY = imageScale;
                            bmp.x = -((bmp.width - 214) / 2);
                        }
                        else
                        {
                            bmp.y = -((bmp.height - 70) / 2);
                        }
                    }
                };
            }
        }
        
        // Reload File
        var reloadCache : BoxButton = new BoxButton(songDetails, 209, 3, 22, 22, "R", 12, e_reloadCache);
        
        // Print Song Info
        var infoDisplay : Array<Dynamic> = [[Reflect.field(info, "data")[0]["info"]["name"], 14], [Reflect.field(info, "data")[0]["info"]["author"], 12]];
        for (item in Reflect.fields(infoDisplay)) {
infoDetails = new Text(songDetails, 5, tY, Reflect.field(infoDisplay, item)[0], Reflect.field(infoDisplay, item)[1]);
            infoDetails.setAreaParams(songDetailsWidth - 10, 23, "center");
            tY += 23;
        }
        
        // Build UI
        var sources : Array<FileFolderItem> = info.data;
        for (s in 0...sources.length)
        {
            var charts : Array<Dynamic> = sources[s].info.chart;
            for (i in 0...charts.length)
            {
                var chartSelectButton : FileBrowserDifficultyItem = new FileBrowserDifficultyItem(i, sources[s]);
                chartSelectButton.addEventListener(MouseEvent.CLICK, e_difficultySelect, false, 0, true);
                songDetails.addChild(chartSelectButton);
                songDifficulties.push(chartSelectButton);
            }
        }
        
        songDifficulties.sortOn("sorting_key", Array.NUMERIC);
        
        // Place UI
        tY = 0;
        i = songDifficulties.length - 1;
        while (i >= 0)
        {
            songDifficulties[i].x = 9;
            songDifficulties[i].y = 405 - tY;
            tY += 30;
            i--;
        }
    }
    
    public function drawInfoBannerSprite(border : Float, bg : Float) : Sprite
    {
        var srm : Sprite = new Sprite();
        srm.graphics.lineStyle(2, 0xffffff, border, true);
        srm.graphics.beginFill(0, bg);
        srm.graphics.drawRoundRect(0, 0, 215, 70, 25, 25);
        srm.graphics.endFill();
        return srm;
    }
    
    private function e_difficultySelect(e : MouseEvent) : Void
    {
        var tar : FileBrowserDifficultyItem = try cast(e.target, FileBrowserDifficultyItem) catch(e:Dynamic) null;
        var info : FileFolderItem = tar.cache_info;
        var id : Int = tar.chart_id;
        
        removePopup();
        
        if (_mp.inGameRoom)
        {
            _mp.ffrSelectSong(FileLoader.buildSongInfo(info.loc, id, true));
            
            if (Std.is(_gvars.gameMain.activePanel, MainMenu))
            {
                _gvars.gameMain.activePanel.switchTo(MainMenu.MENU_MULTIPLAYER);
            }
        }
        else
        {
            Flags.VALUES[Flags.FILE_LOADER_OPEN] = true;
            FileLoader.loadLocalFile(info.loc, id);
        }
    }
    
    private function e_reloadCache(e : Event) : Void
    {
        var chartFile : File;
        var emb : ExternalChartBase;
        var cacheObj : Dynamic;
        
        var file : FileFolder = lastSelectedItem.songData;
        var fileList : Array<FileFolderItem> = file.data;
        for (chartItem in fileList)
        {
            chartFile = new File(chartItem.loc);
            cacheObj = FileLoader.buildCacheObject(chartFile);
            FileLoader.cache.setValue(chartItem.loc, cacheObj);
        }
        FileLoader.cache.save();
        Alert.add(_lang.string("file_loader_reloaded_file"));
        buildFileList();
    }
    
    private function set_lockUI(val : Bool) : Bool
    {
        _isLocked = val;
        cancelRequested = false;
        if (val)
        {
            this.addChild(uiLock);
        }
        else if (this.contains(uiLock))
        {
            this.removeChild(uiLock);
        }
        return val;
    }
}



class FileDirectoryQueue
{
    public var dir : File;
    public var level : Int;
    
    @:allow(popups)
    private function new(dir : File, level : Int)
    {
        this.dir = dir;
        this.level = level;
    }
}
