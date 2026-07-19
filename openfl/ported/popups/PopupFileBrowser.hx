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
    private static var e_bannerLoaded                  : Dynamic;
    private static var e_timerComplete                    : Dynamic;
    public var lockUI(never, set)                       : Dynamic;

    private static var _gvars                       : Dynamic= GlobalVariables.instance;
    private static var _lang                       : Dynamic= Language.instance;
    private static var _mp                       : Dynamic= Multiplayer.instance;
    
    public var lc                       : Dynamic= new LoaderContext();
    
    public static var rootFolder                       : Dynamic;
    public static var lastSelectedIndex                       : Dynamic= 0;
    public static var listFilter                       : Dynamic= new FileBrowserFilter();
    
    public static var pathList                       : Dynamic= [];
    
    //- Background
    private var box                       : Dynamic;
    private var bmd                       : Dynamic;
    private var bmp                       : Dynamic;
    private var dividers                       : Dynamic;
    
    private var refreshAllFolder                       : Dynamic;
    private var displayFolderPath                       : Dynamic;
    private var selectFolder                       : Dynamic;
    private var closeWindow                       : Dynamic;
    
    private var searchInput                       : Dynamic;
    private var searchPlaceholder                       : Dynamic;
    private var searchTypeBox                       : Dynamic;
    
    private var lastSelectedItem                       : Dynamic;
    private var songBrowser                       : Dynamic;
    private var songDetails                       : Dynamic;
    private var songDetailsWidth                       : Dynamic= 0;
    private var songDifficulties                       : Dynamic= [];
    
    private var _isLocked                       : Dynamic= false;
    private var uiLock                       : Dynamic;
    private var loadingPathIndex                       : Dynamic;
    private var loadingPathFolder                       : Dynamic;
    private var loadingPathSong                       : Dynamic;
    private var loadingCancelButton                       : Dynamic;
    private var cancelRequested                       : Dynamic= false;
    
    public function new(myParent                       : Dynamic)
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
        
        var bgbox                       : Dynamic= new Box(this, -1, -1, false, false);
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
        var searchTypeBoxItems                       : Dynamic= [{
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
        
        var lockUIText                       : Dynamic= new Text(uiLock, 0, 200, _lang.string("file_loader_loading_files"), 24);
        lockUIText.setAreaParams(780, 30, "center");
        
        loadingPathIndex = new Text(uiLock, 0, 340, "", 20);
        loadingPathIndex.setAreaParams(780, 30, "center");
        loadingPathFolder = new Text(uiLock, 0, 371, "", 22);
        loadingPathFolder.setAreaParams(780, 30, "center");
        loadingPathSong = new Text(uiLock, 0, 400, "", 18);
        loadingPathSong.setAreaParams(780, 30, "center");
        
        loadingCancelButton = new BoxButton(uiLock, 390 - 40, 440, 80, 30, _lang.string("menu_cancel"), 12, clickHandler);
        
        if (as3hx.Compat.truthy(rootFolder != null && pathList == null))
        {
            refreshFolder();
        }
        else if (as3hx.Compat.truthy(rootFolder != null && pathList != null))
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
        var renderList                       : Dynamic= [];
        var cacheValue                       : Dynamic= null;
        
        // List Building
        var path                       : Dynamic= null;
        var endOfFolder                       : Dynamic= null;
        var arLen                       : Dynamic= pathList.length;
        for (i in 0...arLen)
        {
            cacheValue = FileLoader.cache.getValue(pathList[i]);
            path = pathList[i];
            endOfFolder = path.lastIndexOf(File.separator) + 1;
            renderList[i] = new FileFolder(path.substr(0, endOfFolder), path.substr(endOfFolder), Reflect.field(cacheValue, "ext"), new FileFolderItem(pathList[i], cacheValue));
        }
        
        // Folder Merging
        var elm1                       : Dynamic= null;
        var elm2                       : Dynamic= null;
        var n                       : Dynamic= null;
        as3hx.Compat.sortOn(renderList, ["folder", "ext"], [as3hx.Compat.ARRAY_CASEINSENSITIVE, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
        for (i in 0...as3hx.Compat.parseInt(arLen - 1))
        {
            elm1 = renderList[i];
            n = as3hx.Compat.parseInt(i + 1);
            while (as3hx.Compat.truthy(n < arLen))
            {
                elm2 = renderList[n];
                if (as3hx.Compat.truthy(elm1.folder == elm2.folder && elm1.ext == elm2.ext))
                {
                    while (as3hx.Compat.truthy(elm2.data.length > 0))
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
                n++;
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
        as3hx.Compat.sortOn(renderList, ["name", "author"], [as3hx.Compat.ARRAY_CASEINSENSITIVE, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
        // Display
        songBrowser.setRenderList(renderList);
        
        // Set Active Item
        if (as3hx.Compat.truthy(renderList.length > 0))
        {
            selectedItem(songBrowser.findSongButtonByIndex(lastSelectedIndex));
        }
    }
    
    private function dirSelected(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(stage))
        {
            stage.focus = null;
        }
        
        rootFolder = try cast(e.target, File) catch(e:Dynamic) null;
        refreshFolder();
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(stage))
        {
            stage.focus = null;
        }
        
        if (as3hx.Compat.truthy(e.target == refreshAllFolder))
        {
            refreshCache();
        }
        else if (as3hx.Compat.truthy(e.target == selectFolder || e.target == displayFolderPath))
        {
            var tempFolder                       : Dynamic= new File();
            tempFolder.addEventListener(Event.SELECT, dirSelected);
            tempFolder.browseForDirectory(_lang.stringSimple("file_loader_select_a_directory"));
        }
        else if (as3hx.Compat.truthy(e.target == loadingCancelButton))
        {
            cancelRequested = true;
        }
        else if (as3hx.Compat.truthy(e.target == closeWindow))
        {
            removePopup();
        }
    }
    
    private function searchTypeSelect(e                       : Dynamic) : Void
    {
        listFilter.type = Reflect.field(e.target.selectedItem, "data");
    }
    
    
    private function refreshCache() : Void
    {
        lockUI = true;
        
        var paths                       : Dynamic= FileLoader.cache.keys;
        var fileQueue                       : Dynamic= [];
        var file                       : Dynamic= null;
        
        as3hx.Compat.setArrayLength(pathList, 0);
        
        for (path in as3hx.Compat.iter(paths))
        {
            file = new File(path);
            
            if (as3hx.Compat.truthy(file.isHidden || !file.exists))
            {
                FileLoader.cache.deleteKey(path);
            }
            
            fileQueue.push(file);
        }
        
        _parseFileQueue(fileQueue);
    }
    
    private function refreshFolder() : Void
    {
        if (as3hx.Compat.truthy(rootFolder == null))
        {
            return;
        }
        
        lastSelectedIndex = 0;
        lastSelectedItem = null;
        
        as3hx.Compat.setArrayLength(pathList, 0);
        
        displayFolderPath.text = rootFolder.nativePath;
        
        lockUI = true;
        
        var loadTimer                       : Dynamic= null;
        
        // File Searching
        var dirQueue                       : Dynamic= [new FileDirectoryQueue(rootFolder, 0)];
        var fileQueue                       : Dynamic= [];
        var activeDirQueue                       : Dynamic= null;
        var maxDepth                       : Dynamic= 2;
        var validExt                       : Dynamic= ExternalChartBase.VALID_CHART_EXTENSIONS;
        
        loadingPathIndex.text = _lang.string("file_loader_scanning");
        loadingPathFolder.text = "";
        loadingPathSong.text = "";
        
        loadTimer = new Timer(20, 1);
        loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
        loadTimer.start();
        
        e_timerComplete = function(e                       : Dynamic) : Void
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
                    else if (as3hx.Compat.truthy(file.extension != null && Lambda.indexOf(validExt, file.extension.toLowerCase()) != -1))
                    {
                        fileQueue.push(file);
                    }
                }
                
                var endTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
                if (as3hx.Compat.truthy(endTimer - startTimer > 200))
                {
                    isDelay = true;
                    break;
                }
            }
            
            if (as3hx.Compat.truthy(cancelRequested))
            {
                as3hx.Compat.setArrayLength(dirQueue, 0);
                as3hx.Compat.setArrayLength(fileQueue, 0);
                as3hx.Compat.setArrayLength(pathList, 0);
            }
            
            loadingPathIndex.text = sprintf(_lang.string("file_loader_found_files"), {
                                files : fileQueue.length
                            });
            
            // Loaded All Files
            if (as3hx.Compat.truthy(dirQueue.length == 0))
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
                _parseFileQueue(fileQueue);
                return;
            }
            
            // Not Finished, Continue next frame.
            if (as3hx.Compat.truthy(isDelay && dirQueue.length > 0))
            {
                loadTimer.start();
            }
        }
    }
    
    private function _parseFileQueue(fileQueue                       : Dynamic) : Void
    {
        var loadTimer                       : Dynamic= null;
        
        // File Loading
        var rootFolderPath                       : Dynamic= (rootFolder != null) ? rootFolder.nativePath : "";
        var pathIndex                       : Dynamic= null;
        var pathTotal                       : Dynamic= null;
        
        if (as3hx.Compat.truthy(fileQueue.length <= 0))
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
        
        e_timerComplete = function(e                       : Dynamic) : Void
        {
            var chartFile                       : Dynamic= null;
            var stringPath                       : Dynamic= null;
            var startTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
            var isDelay                       : Dynamic= false;
            var cacheObj                       : Dynamic= null;
            
            while (as3hx.Compat.truthy(pathIndex < pathTotal))
            {
                chartFile = fileQueue[pathIndex];
                stringPath = chartFile.nativePath;
                
                cacheObj = FileLoader.cache.getValue(stringPath);
                var needUpdate                       : Dynamic= cacheObj == null || chartFile.modificationDate.getTime() != Reflect.field(cacheObj, "date");
                
                if (as3hx.Compat.truthy(!needUpdate))
                {
                    if (as3hx.Compat.truthy(cacheObj.valid == 1))
                    {
                        pathList.push(stringPath);
                    }
                }
                else
                {
                    loadingPathIndex.text = pathIndex + " / " + pathTotal;
                    
                    if (as3hx.Compat.truthy(chartFile.parent.parent.nativePath == rootFolderPath))
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
                    
                    if (as3hx.Compat.truthy(cacheObj.valid == 1))
                    {
                        pathList.push(stringPath);
                    }
                }
                pathIndex++;
                
                if (as3hx.Compat.truthy(cancelRequested))
                {
                    pathIndex = 0;
                    pathTotal = 0;
                    as3hx.Compat.setArrayLength(fileQueue, 0);
                    as3hx.Compat.setArrayLength(pathList, 0);
                }
                
                var endTimer                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
                if (as3hx.Compat.truthy(endTimer - startTimer > 200))
                {
                    isDelay = true;
                    break;
                }
            }
            
            // Loaded All Files
            if (as3hx.Compat.truthy(pathIndex >= pathTotal))
            {
                loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
                FileLoader.cache.save();
                lockUI = false;
                
                buildFileList();
                return;
            }
            
            // Not Finished, Continue next frame.
            if (as3hx.Compat.truthy(isDelay && pathIndex < pathTotal))
            {
                loadTimer.start();
            }
        }
    }
    
    private function selectedItem(item                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(item == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(lastSelectedItem != null))
        {
            lastSelectedItem.highlight = false;
        }
        
        item.highlight = true;
        setInfoBox(item.songData);
        lastSelectedIndex = item.index;
        lastSelectedItem = item;
        songBrowser.activeIndex = item.index;
    }
    
    private function e_searchChange(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_isLocked))
        {
            return;
        }
        
        listFilter.term = searchInput.text;
        searchPlaceholder.visible = searchInput.text.length == 0;
        songBrowser.updateList();
        selectedItem(songBrowser.findSongButtonByIndex(lastSelectedIndex));
    }
    
    private function e_songListClick(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, FileBrowserItem)))
        {
            selectedItem(try cast(e.target, FileBrowserItem) catch(e:Dynamic) null);
        }
    }
    
    public function setInfoBox(info                       : Dynamic) : Void
    {
        songDetails.removeChildren();
        as3hx.Compat.setArrayLength(songDifficulties, 0);
        
        var infoTitle                       : Dynamic= null;
        var infoDetails                       : Dynamic= null;
        var tY                       : Dynamic= 83;
        
        // Create Holder Sprite
        var sr                       : Dynamic= drawInfoBannerSprite(0, 0.3);
        sr.x = 10;
        sr.y = 10;
        songDetails.addChild(sr);
        
        // Mask
        var srm                       : Dynamic= drawInfoBannerSprite(0, 1);
        sr.addChild(srm);
        sr.mask = srm;
        
        // Border
        var srb                       : Dynamic= drawInfoBannerSprite(0.35, 0);
        srb.x = 10;
        srb.y = 10;
        songDetails.addChild(srb);
        
        // Banner
        if (as3hx.Compat.truthy(info.banner != "")) {
var bannerExt                       : Dynamic= info.banner.substr(info.banner.lastIndexOf(".") + 1).toLowerCase();
            if (as3hx.Compat.truthy(bannerExt == "jpg" || bannerExt == "png" || bannerExt == "gif" || bannerExt == "jpeg"))
            {
                var path                       : Dynamic= "file:///" + info.folder + info.banner;
                var imageLoader         : Dynamic= new Loader();
                var e_bannerLoaded         : Dynamic= null;
                var e_bannerLoaded          : Dynamic= null;
                var e_bannerLoaded           : Dynamic= null;
                var e_bannerLoaded            : Dynamic= null;
                var e_bannerLoaded             : Dynamic= null;
                var e_bannerLoaded              : Dynamic= null;
                var e_bannerLoaded               : Dynamic= null;
                var e_bannerLoaded                : Dynamic= null;
                var e_bannerLoaded                 : Dynamic= null;
                var e_bannerLoaded                  : Dynamic= null;
                var e_bannerLoaded                   : Dynamic= null;
                var e_bannerLoaded                    : Dynamic= null;
                var e_bannerLoaded                     : Dynamic= null;
                imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_bannerLoaded);
                imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bannerLoaded);
                imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bannerLoaded);
                imageLoader.load(new URLRequest(path), lc);
                
                e_bannerLoaded = function(e                       : Dynamic) : Void
                // Position Loaded Banner Image
                {
                    
                    if (as3hx.Compat.truthy(e.type == Event.COMPLETE && e.target != null && ((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content) != null))
                    {
                        var bmp                       : Dynamic= try cast(((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content), Bitmap) catch(e:Dynamic) null;
                        bmp.smoothing = true;
                        bmp.pixelSnapping = "always";
                        sr.addChildAt(bmp, 1);
                        
                        var imageScale                       : Dynamic= 214 / bmp.width;
                        
                        bmp.scaleX = bmp.scaleY = imageScale;
                        
                        if (as3hx.Compat.truthy(bmp.height < 70))
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
        var reloadCache                       : Dynamic= new BoxButton(songDetails, 209, 3, 22, 22, "R", 12, e_reloadCache);
        
        // Print Song Info
        var infoData                     : Dynamic= as3hx.Compat.field(info, "data");
        var infoZero                     : Dynamic= as3hx.Compat.field(infoData, 0);
        var infoInfo                     : Dynamic= as3hx.Compat.field(infoZero, "info");
        var infoDisplay                     : Dynamic= [[as3hx.Compat.field(infoInfo, "name"), 14], [as3hx.Compat.field(infoInfo, "author"), 12]];
        for (item in as3hx.Compat.iter(Reflect.fields(infoDisplay))) {
infoDetails = new Text(songDetails, 5, tY, as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 0), as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 1));
            infoDetails.setAreaParams(songDetailsWidth - 10, 23, "center");
            tY += 23;
        }
        
        // Build UI
        var sources                       : Dynamic= info.data;
        for (s in 0...sources.length)
        {
            var charts                       : Dynamic= sources[s].info.chart;
            for (i in 0...charts.length)
            {
                var chartSelectButton                       : Dynamic= new FileBrowserDifficultyItem(i, sources[s]);
                chartSelectButton.addEventListener(MouseEvent.CLICK, e_difficultySelect, false, 0, true);
                songDetails.addChild(chartSelectButton);
                songDifficulties.push(chartSelectButton);
            }
        }
        
        as3hx.Compat.sortOn(songDifficulties, "sorting_key", as3hx.Compat.ARRAY_NUMERIC);
        // Place UI
        tY = 0;
        var i                      : Dynamic= songDifficulties.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            songDifficulties[i].x = 9;
            songDifficulties[i].y = 405 - tY;
            tY += 30;
            i--;
        }
    }
    
    public function drawInfoBannerSprite(border                       : Dynamic, bg                       : Dynamic) : Sprite
    {
        var srm                       : Dynamic= new Sprite();
        srm.graphics.lineStyle(2, 0xffffff, border, true);
        srm.graphics.beginFill(0, bg);
        srm.graphics.drawRoundRect(0, 0, 215, 70, 25, 25);
        srm.graphics.endFill();
        return srm;
    }
    
    private function e_difficultySelect(e                       : Dynamic) : Void
    {
        var tar                       : Dynamic= try cast(e.target, FileBrowserDifficultyItem) catch(e:Dynamic) null;
        var info                       : Dynamic= tar.cache_info;
        var id                       : Dynamic= tar.chart_id;
        
        removePopup();
        
        if (as3hx.Compat.truthy(_mp.inGameRoom))
        {
            _mp.ffrSelectSong(FileLoader.buildSongInfo(info.loc, id, true));
            
            if (as3hx.Compat.truthy(Std.is(_gvars.gameMain.activePanel, MainMenu)))
            {
                _gvars.gameMain.activePanel.switchTo(MainMenu.MENU_MULTIPLAYER);
            }
        }
        else
        {
            Reflect.setField(Flags.VALUES, Flags.FILE_LOADER_OPEN, true);
            FileLoader.loadLocalFile(info.loc, id);
        }
    }
    
    private function e_reloadCache(e                       : Dynamic) : Void
    {
        var chartFile                       : Dynamic= null;
        var emb                       : Dynamic= null;
        var cacheObj                       : Dynamic= null;
        
        var file                       : Dynamic= lastSelectedItem.songData;
        var fileList                       : Dynamic= file.data;
        for (chartItem in as3hx.Compat.iter(fileList))
        {
            chartFile = new File(chartItem.loc);
            cacheObj = FileLoader.buildCacheObject(chartFile);
            FileLoader.cache.setValue(chartItem.loc, cacheObj);
        }
        FileLoader.cache.save();
        Alert.add(_lang.string("file_loader_reloaded_file"));
        buildFileList();
    }
    
    private function set_lockUI(val                       : Dynamic) : Bool
    {
        _isLocked = val;
        cancelRequested = false;
        if (as3hx.Compat.truthy(val))
        {
            this.addChild(uiLock);
        }
        else if (as3hx.Compat.truthy(this.contains(uiLock)))
        {
            this.removeChild(uiLock);
        }
        return val;
    }
}



class FileDirectoryQueue
{
    private static var e_bannerLoaded                  : Dynamic;
    private static var e_timerComplete                    : Dynamic;
    public var dir                       : Dynamic;
    public var level                       : Dynamic;
    
    @:allow(popups)
    private function new(dir                       : Dynamic, level                       : Dynamic)
    {
        this.dir = dir;
        this.level = level;
    }
}
