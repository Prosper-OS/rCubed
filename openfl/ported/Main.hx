/**
 * @author Jonathan (Velocity)
 */

import assets.GameBackgroundColor;
import by.blooddy.crypto.MD5;
import classes.Alert;
import classes.Language;
import classes.Noteskins;
import classes.Playlist;
import classes.RenderQuality;
import classes.Site;
import classes.User;
import classes.ui.BoxButton;
import classes.ui.ProgressBar;
import classes.ui.Text;
import com.flashdynamix.utils.SWFProfiler;
import com.flashfla.utils.ObjectUtil;
import com.flashfla.utils.SystemUtil;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.SineInOut;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;
import r3.air.desktop.NativeApplication;
import r3.air.desktop.NativeProcess;
import r3.air.desktop.NativeProcessStartupInfo;
import openfl.display.NativeWindow;
import openfl.events.ContextMenuEvent;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.NativeWindowBoundsEvent;
import openfl.events.UncaughtErrorEvent;
import r3.air.filesystem.File;
import openfl.system.Capabilities;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.ui.ContextMenu;
import openfl.ui.ContextMenuItem;
import openfl.ui.Keyboard;
import game.GameMenu;
import menu.MainMenu;
import menu.MenuPanel;
import popups.PopupContextMenu;
import popups.PopupHelp;
import popups.replays.ReplayHistoryWindow;
import popups.settings.SettingsWindow;

class Main extends MenuPanel
{
    public static inline var GAME_WIDTH                              : Dynamic= 780;
    public static inline var GAME_HEIGHT                              : Dynamic= 480;
    public static var VSYNC_SUPPORT                              : Dynamic= false;
    public static var window                              : Dynamic;
    
    public static inline var GAME_LOGIN_PANEL                              : Dynamic= "GameLoginPanel";
    public static inline var GAME_MENU_PANEL                              : Dynamic= "GameMenuPanel";
    public static inline var GAME_PLAY_PANEL                              : Dynamic= "GamePlayPanel";
    public static inline var POPUP_OPTIONS                              : Dynamic= "PopupOptions";
    public static inline var POPUP_HELP                              : Dynamic= "PopupHelp";
    public static inline var POPUP_REPLAY_HISTORY                              : Dynamic= "PopupReplayHistory";
    public static inline var EVENT_PANEL_SWITCHED                              : Dynamic= "MainEventSwitched";
    
    public static var WINDOW_WIDTH_EXTRA                              : Dynamic= 0;
    public static var WINDOW_HEIGHT_EXTRA                              : Dynamic= 0;
    
    public var _lang                              : Dynamic= Language.instance;
    public var _gvars                              : Dynamic= GlobalVariables.instance;
    public var _site                              : Dynamic= Site.instance;
    public var _playlist                              : Dynamic= Playlist.instance;
    public var _noteskins                              : Dynamic= Noteskins.instance;
    
    public var loadTimer                              : Dynamic= 0;
    public var preloader                              : Dynamic;
    public var loadScripts                              : Dynamic= 0;
    public var loadTotal                              : Dynamic;
    public var isLoginLoad                              : Dynamic= false;
    public var loadComplete                              : Dynamic= false;
    public var retryLoadButton                              : Dynamic;
    public var disablePopups                              : Dynamic= false;
    public var ignoreWindowChanges                              : Dynamic= false;
    
    private var popupQueue                              : Dynamic= [];
    private var lastPanel                              : Dynamic;
    public var activePanel                              : Dynamic;
    
    public var activePanelName                              : Dynamic;
    
    public var loadStatus                              : Dynamic;
    public var epilepsyWarning                              : Dynamic;
    
    public var ver                              : Dynamic;
    public var bg                              : Dynamic;
    
    // Application Info
    public static var SWF_FILE                              : Dynamic;
    public static var SWF_PATH                              : Dynamic;
    public static var SWF_VERSION                              : Dynamic;
    public static var EXE_PATH                              : Dynamic;
    
    ///- Constructor
    public function new()
    {
        super(this);
        
        //- Set GlobalVariables Stage
        _gvars.gameMain = this;
        
        if (as3hx.Compat.truthy(stage))
        {
            gameInit();
        }
        else
        {
            this.addEventListener(Event.ADDED_TO_STAGE, gameInit);
        }
    }
    
    private function gameInit(e                              : Dynamic= null) : Void
    //- Remove Stage Listener
    {
        
        if (as3hx.Compat.truthy(e != null))
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, gameInit);
        }
        
        //- Application
        SWF_FILE = new File(new File(loaderInfo.loaderURL).nativePath);
        SWF_PATH = SWF_FILE.nativePath;
        SWF_VERSION = MD5.hashBytes(AirContext.readFile(SWF_FILE));
        VSYNC_SUPPORT = false;
        
        //- Static Class Init
        Logger.init();
        AirContext.initFolders();
        LocalOptions.init();
        Alert.init(stage);
        
        //- Setup Tween Override mode
        TweenPlugin.activate([TintPlugin, AutoAlphaPlugin]);
        TweenLite.defaultOverwrite = "all";
        stage.stageFocusRect = false;
        RenderQuality.configureStage(stage);
        
        //- Load Air Items
        _gvars.loadAirOptions();
        
        //- Window Options
        window = stage.nativeWindow;
        window.title = Constant.AIR_WINDOW_TITLE;
        window.addEventListener(Event.CLOSING, e_onNativeWindowClosing);
        window.addEventListener(NativeWindowBoundsEvent.MOVE, e_onNativeWindowPropertyChange, false, 1);
        window.addEventListener(NativeWindowBoundsEvent.RESIZE, e_onNativeWindowPropertyChange, false, 1);
        loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, e_uncaughtErrorHandler);
        NativeApplication.nativeApplication.addEventListener(NativeApplication.EXITING, e_onNativeShutdown);
        stage.addEventListener("vSyncStateChangeAvailability", e_onVsyncStateChangeAvailability);  // Lacking proper event class due to SDK limitations in Air 26.  
        
        WINDOW_WIDTH_EXTRA = window.width - GAME_WIDTH;
        WINDOW_HEIGHT_EXTRA = window.height - GAME_HEIGHT;
        
        ignoreWindowChanges = true;
        if (as3hx.Compat.truthy(_gvars.air_saveWindowPosition))
        {
            window.x = _gvars.air_windowProperties.x;
            window.y = _gvars.air_windowProperties.y;
        }
        if (as3hx.Compat.truthy(_gvars.air_saveWindowSize))
        {
            window.width = Math.max(100, _gvars.air_windowProperties.width + WINDOW_WIDTH_EXTRA);
            window.height = Math.max(100, _gvars.air_windowProperties.height + WINDOW_HEIGHT_EXTRA);
        }
        if (as3hx.Compat.truthy(_gvars.air_useFullScreen))
        {
            _gvars.toggleFullScreen();
        }
        ignoreWindowChanges = false;
        
        //- Load Menu Music
        _gvars.loadMenuMusic();
        
        //- Background
        this.stage.color = 0x000000;
        
        bg = new GameBackgroundColor();
        this.addChild(bg);
        
        //- Epilepsy Warning
        epilepsyWarning = new TextField();
        epilepsyWarning.x = 10;
        epilepsyWarning.y = stage.stageHeight * 0.15;
        epilepsyWarning.width = GAME_WIDTH - 20;
        epilepsyWarning.selectable = false;
        epilepsyWarning.embedFonts = true;
        epilepsyWarning.antiAliasType = AntiAliasType.ADVANCED;
        epilepsyWarning.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
        epilepsyWarning.textColor = 0xFFFFFF;
        epilepsyWarning.alpha = 0.2;
        epilepsyWarning.text = "WARNING: This game may potentially trigger seizures for people with photosensitive epilepsy.\nGamer discretion is advised.";
        this.addChild(epilepsyWarning);
        
        TweenMax.to(epilepsyWarning, 1, {
                    alpha : 0.6,
                    ease : SineInOut,
                    yoyo : true,
                    repeat : -1
                });
        
        //- Add Debug Tracking
        ver = new Text(this, stage.width - 5, 2, new as3hx.Compat.Regex(',', "g").replace(Capabilities.version, ".") + " - Build " + "9999-12-31" + " - " + Constant.AIR_VERSION);
        ver.alpha = 0.15;
        ver.align = Text.RIGHT;
        ver.mouseEnabled = false;
        ver.cacheAsBitmap = true;
        
        // Holidays!
        var d                              : Dynamic= Date.now();
        if (as3hx.Compat.truthy(d.getMonth() == 0 && d.getDate() == 1))
        {
            ver.text = "Happy New Year! - " + ver.text;
        }
        if (as3hx.Compat.truthy(d.getMonth() == 9 && d.getDate() == 31))
        {
            ver.text = "Happy Halloween! - " + ver.text;
        }
        if (as3hx.Compat.truthy(d.getMonth() == 11 && d.getDate() == 25))
        {
            ver.text = "Merry Christmas! - " + ver.text;
        }
        if (as3hx.Compat.truthy(d.getMonth() == 10 && d.getDate() == 6))
        {
            ver.text = "Happy Birthday Velocity! - " + ver.text;
        }
        
        //- Build global right-click context menu
        buildContextMenu();
        
        //- Build Preloader
        buildPreloader();
        
        //- Load Game Data
        loadSiteData();
        
        //- Key listener
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, false, 0, true);
        stage.focus = this.stage;
        
        //- No Reason
        false;{
            Alert.add("Development Build - " + "9999-12-31" + " - NOT FOR RELEASE", 120, Alert.RED);
        }
    }
    
    public function buildContextMenu() : Void
    //- Backup Menu incase
    {
        
        var cm                              : Dynamic= new ContextMenu();
        
        //- Toggle Fullscreen
        var fscmi                              : Dynamic= new ContextMenuItem(_lang.stringSimple("show_menu"));
        fscmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleContextPopup);
        cm.customItems.push(fscmi);
        
        //- Assign Menu Context
        Reflect.setField(this, "contextMenu", cm);
        
        //- Profiler
        SWFProfiler.init(stage, this);
        
        false;{
            cm.hideBuiltInItems();
        }
    }
    
    ///- Window Methods
    private function e_onNativeShutdown(e                              : Dynamic) : Void
    {
        Logger.destroy();
        LocalOptions.flush();
        _gvars.onNativeProcessClose(e);
    }
    
    private function e_onNativeWindowClosing(e                              : Dynamic) : Void
    {
        Reflect.setField(_gvars.air_windowProperties, "width", window.width - Main.WINDOW_WIDTH_EXTRA);
        Reflect.setField(_gvars.air_windowProperties, "height", window.height - Main.WINDOW_HEIGHT_EXTRA);
        Reflect.setField(_gvars.air_windowProperties, "x", window.x);
        Reflect.setField(_gvars.air_windowProperties, "y", window.y);
        LocalOptions.setVariable("window_properties", _gvars.air_windowProperties);
    }
    
    private function e_onNativeWindowPropertyChange(e                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(ignoreWindowChanges))
        {
            return;
        }
        
        Reflect.setField(_gvars.air_windowProperties, "width", e.afterBounds.width - Main.WINDOW_WIDTH_EXTRA);
        Reflect.setField(_gvars.air_windowProperties, "height", e.afterBounds.height - Main.WINDOW_HEIGHT_EXTRA);
        Reflect.setField(_gvars.air_windowProperties, "x", e.afterBounds.x);
        Reflect.setField(_gvars.air_windowProperties, "y", e.afterBounds.y);
    }
    
    private function e_uncaughtErrorHandler(e                              : Dynamic) : Void
    {
        Logger.enableLogger();
        Logger.error("UNCAUGHT_ERROR", e.error);
        Logger.info("INFO", "If possible, please submit this crash to the developers.");
        Alert.add("A fatal error has occured. You should restart the game.", 7200, Alert.RED);
        _gvars.logDebugError(Logger.generate_message(e.error));
    }
    
    /**
     * Called when the vsync state can be set.
     * This is even called in Air 26, when the actual event doesn't exist yet in the SDK
     * but is dispatched if you hardcode the event name.
     */
    public function e_onVsyncStateChangeAvailability(event                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(VSYNC_SUPPORT))
        {
            if (as3hx.Compat.truthy(event.available))
            {
                // vsyncEnabled is AIR-only; OpenFL uses the window FPS cap.
            }
            else
            {
                // vsyncEnabled is AIR-only; OpenFL uses the window FPS cap.
            }
        }
    }
    
    ///- Preloader
    public function buildPreloader() : Void
    //- Status Display
    {
        
        loadStatus = new TextField();
        loadStatus.x = 8;
        loadStatus.y = GAME_HEIGHT - (((isLoginLoad)) ? 118 : 155);
        loadStatus.width = GAME_WIDTH - 20;
        loadStatus.selectable = false;
        loadStatus.embedFonts = true;
        loadStatus.antiAliasType = AntiAliasType.ADVANCED;
        loadStatus.autoSize = "left";
        loadStatus.defaultTextFormat = Constant.TEXT_FORMAT;
        loadStatus.text = "\n\n\n\n\nConnecting...";
        this.addChild(loadStatus);
        
        //- Preloader Display
        preloader = new ProgressBar(this, 10, GAME_HEIGHT - 30, GAME_WIDTH - 20, 20);
        
        //- Frame Listener
        this.addEventListener(Event.ENTER_FRAME, updatePreloader);
    }
    
    ///- Game Data
    private static var LOAD_ATTEMPTS                              : Dynamic= 0;
    
    public function loadSiteData() : Void
    {
        if (as3hx.Compat.truthy(isLoginLoad))
        {
            loadGameData(false);
            return;
        }
        
        if (as3hx.Compat.truthy(LOAD_ATTEMPTS < 2))
        {
            _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameDataScriptLoad);
            _site.addEventListener(GlobalVariables.LOAD_ERROR, gameDataScriptLoadError);
            _site.load();
            LOAD_ATTEMPTS++;
        }
        else
        {
            loadStatus.text = "\n\n\n\n\nUnable to connect to the server, please check your internet connection.";
        }
    }
    
    private function gameDataScriptLoad(e                              : Dynamic= null) : Void
    {
        e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameDataScriptLoad);
        e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameDataScriptLoadError);
        loadScripts++;
        
        loadGameData();
    }
    
    private function gameDataScriptLoadError(e                              : Dynamic= null) : Void
    {
        e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameDataScriptLoad);
        e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameDataScriptLoadError);
        
        // Fallback to http
        if (as3hx.Compat.truthy(LOAD_ATTEMPTS == 1))
        {
            URLs.protocol = "http";
        }
        
        loadSiteData();
    }
    
    public function loadGameData(skipSite                              : Dynamic= true) : Void
    {
        loadTotal = ((!isLoginLoad)) ? 5 : 3;
        
        _gvars.playerUser = new User(true, true);
        _gvars.playerUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
        _gvars.playerUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
        _gvars.activeUser = _gvars.playerUser;
        
        _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
        _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
        _playlist.load();
        
        if (as3hx.Compat.truthy(!skipSite))
        {
            _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _site.load();
        }
        
        if (as3hx.Compat.truthy(!isLoginLoad))
        {
            _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _noteskins.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _noteskins.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _lang.load();
            _noteskins.load();
        }
    }
    
    private function gameScriptLoad(e                              : Dynamic= null) : Void
    {
        e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
        e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
        loadScripts++;
    }
    
    private function gameScriptLoadError(e                              : Dynamic= null) : Void
    {
        e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
        e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
    }
    
    private function updateLoaderText() : Void
    {
        if (as3hx.Compat.truthy(loadStatus != null && _gvars.playerUser != null))
        {
            loadStatus.htmlText = "Total: " + loadScripts + " / " + loadTotal + "\n" + "Playlist: " + getLoadText(_playlist.isLoaded(), _playlist.isError()) + "\n" + "User Data: " + getLoadText(_gvars.playerUser.isLoaded(), _gvars.playerUser.isError()) + "\n" + "Site Data: " + getLoadText(_site.isLoaded(), _site.isError()) + (((!isLoginLoad)) ? ("\n" + "Noteskin Data: " + getLoadText(_noteskins.isLoaded(), _noteskins.isError()) + "\n" + "Language Data: " + getLoadText(_lang.isLoaded(), _lang.isError())) : "");
        }
    }
    
    private function getLoadText(isLoaded                              : Dynamic, isError                              : Dynamic) : String
    {
        if (as3hx.Compat.truthy(isError))
        {
            return "<font color=\"#FFC4C4\">Error</font>";
        }
        if (as3hx.Compat.truthy(isLoaded))
        {
            return "<font color=\"#C4FFCD\">Complete</font>";
        }
        
        var cycle                              : Dynamic= 35;
        return "Loading." + (((loadTimer % cycle > cycle / 3)) ? "." : "") + (((loadTimer % cycle > cycle / 1.5)) ? "." : "");
    }
    
    ///- PreloaderHandlers
    private function updatePreloader(e                              : Dynamic) : Void
    // Update Text
    {
        
        updateLoaderText();
        
        loadTimer++;
        preloader.update(loadScripts / loadTotal);
        if (as3hx.Compat.truthy(loadTimer >= 300 && retryLoadButton == null))
        {
            retryLoadButton = new BoxButton(this, Main.GAME_WIDTH - 85, preloader.y - 35, 75, 25, "RELOAD", 12, e_retryClick);
        }
        
        if (as3hx.Compat.truthy(preloader.isComplete))
        {
            loadComplete = true;
            if (as3hx.Compat.truthy(retryLoadButton != null && this.contains(retryLoadButton)))
            {
                removeChild(retryLoadButton);
                retryLoadButton.dispose();
            }
            
            buildContextMenu();
            loadScripts = 0;
            preloader.remove();
            removeChild(loadStatus);
            this.removeEventListener(Event.ENTER_FRAME, updatePreloader);
            _playlist.updateSongAccess();
            _playlist.updatePublicSongsCount();
            _gvars.loadUserSongData();
            _gvars.playerUser.getUserSkillRatingData();
            Updater.handle(Reflect.field(_site.data, "update_version"), Reflect.field(_site.data, "update_url"));
            switchTo((_gvars.playerUser.isGuest) ? GAME_LOGIN_PANEL : GAME_MENU_PANEL);
        }
    }
    
    private function e_retryClick(e                              : Dynamic) : Void
    {
        Alert.add(_lang.string("reload_scripts"));
        
        if (as3hx.Compat.truthy(!_playlist.isLoaded()))
        {
            _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _playlist.load();
        }
        if (as3hx.Compat.truthy(!_site.isLoaded()))
        {
            _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _site.load();
        }
        if (as3hx.Compat.truthy(!_gvars.playerUser || !_gvars.playerUser.isLoaded()))
        {
            _gvars.playerUser = new User(true, true);
            _gvars.playerUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _gvars.playerUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _gvars.playerUser.load();
            _gvars.activeUser = _gvars.playerUser;
        }
        
        if (as3hx.Compat.truthy(!isLoginLoad))
        {
            if (as3hx.Compat.truthy(!_noteskins.isLoaded()))
            {
                _noteskins.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _noteskins.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _noteskins.load();
            }
            if (as3hx.Compat.truthy(!_lang.isLoaded()))
            {
                _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _lang.load();
            }
        }
        
        // Update Text
        updateLoaderText();
    }
    
    ///- Panels
    override public function switchTo(_panel                              : Dynamic) : Bool
    {
        var isFound                              : Dynamic= false;
        var nextPanel                             : Dynamic= null;
        
        if (as3hx.Compat.truthy(_panel == "none")) {
bg.updateDisplay();
            ver.visible = true;
            
            //- Remove last panel if exist
            if (as3hx.Compat.truthy(activePanel != null))
            {
                activePanel.stageRemove();
                TweenLite.to(activePanel, 0.5, {
                            alpha : 0,
                            onComplete : removeLastPanel,
                            onCompleteParams : [activePanel]
                        });
            }
            
            // Only load data that depend on the global session token after logging in
            this.isLoginLoad = true;
            
            //- Build Preloader
            buildPreloader();
            
            //- Load Game Data
            loadGameData(false);
            
            return true;
        }
        
        //- Add Requested Panel
        switch (_panel)
        {
            case GAME_LOGIN_PANEL:
                nextPanel = new LoginMenu(this);
                isFound = true;
            
            case GAME_MENU_PANEL:
                nextPanel = new MainMenu(this);
                isFound = true;
                
                if (as3hx.Compat.truthy(this.contains(epilepsyWarning)))
                {
                    removeChild(epilepsyWarning);
                }
            
            case GAME_PLAY_PANEL:
                nextPanel = new GameMenu(this);
                isFound = true;
        }
        
        // Show Background
        if (as3hx.Compat.truthy(_panel != GAME_PLAY_PANEL))
        {
            bg.visible = true;
            ver.visible = true;
        }
        
        if (as3hx.Compat.truthy(isFound)) {
if (as3hx.Compat.truthy(activePanel != null))
            {
                TweenLite.to(activePanel, 0.5, {
                            alpha : 0,
                            onComplete : removeLastPanel,
                            onCompleteParams : [activePanel]
                        });
                activePanel.mouseEnabled = false;
                activePanel.mouseChildren = false;
            }
            
            activePanel = nextPanel;
            activePanel.alpha = 0;
            
            this.addChildAt(activePanel, 2);
            if (as3hx.Compat.truthy(!activePanel.hasInit))
            {
                activePanel.init();
                activePanel.hasInit = true;
            }
            activePanel.stageAdd();
            TweenLite.to(activePanel, 0.5, {
                        alpha : 1
                    });
        }
        
        if (as3hx.Compat.truthy(isFound))
        {
            this.activePanelName = _panel;
            dispatchEvent(new Event(EVENT_PANEL_SWITCHED));
        }
        
        return isFound;
    }
    
    private function removeLastPanel(removePanel                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(removePanel != null))
        {
            if (as3hx.Compat.truthy(removePanel.stage != null))
            {
                removePanel.stageRemove();
                removePanel.parent.removeChild(removePanel);
            }
            removePanel.dispose();
            removePanel = null;
        }
        SystemUtil.gc();
    }
    
    ///- Popups
    override public function addPopup(_panel                              : Dynamic, newLayer                              : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(newLayer && Std.is(_panel, MenuPanel)))
        {
            removeChildClass(ObjectUtil.getClass(_panel));
            this.addChild(_panel);
            if (as3hx.Compat.truthy(!_panel.hasInit))
            {
                _panel.init();
                _panel.hasInit = true;
            }
            _panel.stageAdd();
        }
        else
        {
            if (as3hx.Compat.truthy(current_popup))
            {
                removePopup();
            }
            
            //- Add Requested Popop
            if (as3hx.Compat.truthy(Std.is(_panel, String)))
            {
                switch (_panel)
                {
                    case POPUP_OPTIONS:
                        current_popup = new SettingsWindow(this);
                    case POPUP_HELP:
                        current_popup = new PopupHelp(this);
                    case POPUP_REPLAY_HISTORY:
                        current_popup = new ReplayHistoryWindow(this);
                }
            }
            else if (as3hx.Compat.truthy(Std.is(_panel, MenuPanel)))
            {
                current_popup = _panel;
            }
            this.addChildAt(current_popup, 3);
            if (as3hx.Compat.truthy(!current_popup.hasInit))
            {
                current_popup.init();
                current_popup.hasInit = true;
            }
            current_popup.stageAdd();
        }
    }
    
    public function addPopupQueue(_panel                              : Dynamic, newLayer                              : Dynamic= false) : Void
    {
        popupQueue.push({
                    panel : _panel,
                    layer : newLayer
                });
    }
    
    public function displayPopupQueue() : Void
    {
        if (as3hx.Compat.truthy(current_popup != null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(popupQueue.length > 0))
        {
            var pop                              : Dynamic= popupQueue.shift();
            addPopup(Reflect.field(pop, "panel"), Reflect.field(pop, "layer"));
        }
    }
    
    override public function removePopup() : Void
    {
        if (as3hx.Compat.truthy(current_popup))
        {
            current_popup.stageRemove();
            if (as3hx.Compat.truthy(this.contains(current_popup)))
            {
                this.removeChild(current_popup);
            }
            current_popup = null;
        }
        stage.focus = this.stage;
        SystemUtil.gc();
        displayPopupQueue();
    }
    
    private function removeChildClass(clazz                              : Dynamic) : Void
    {
        for (i in 0...this.numChildren)
        {
            if (as3hx.Compat.truthy(Std.is(this.getChildAt(i), clazz)))
            {
                this.removeChildAt(i);
                break;
            }
        }
    }
    
    ///- Fullscreen Handling
    private function toggleContextPopup(e                              : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(Std.is(current_popup, PopupContextMenu)))
        {
            removePopup();
        }
        else if (as3hx.Compat.truthy(!disablePopups))
        {
            addPopup(new PopupContextMenu(this));
        }
    }
    
    ///- Key Handling
    private function keyboardKeyDown(e                              : Dynamic) : Void
    {
        var keyCode                              : Dynamic= e.keyCode;
        if (as3hx.Compat.truthy(as3hx.Compat.field(Flags.VALUES, Flags.ENABLE_GLOBAL_POPUPS) != null)) {
if (as3hx.Compat.truthy(keyCode == _gvars.playerUser.keyOptions && (stage.focus == null || !(Std.is(stage.focus, TextField)))))
            {
                if (as3hx.Compat.truthy(Std.is(current_popup, SettingsWindow)))
                {
                    removePopup();
                }
                else
                {
                    addPopup(Main.POPUP_OPTIONS);
                }
            }
            // Help Menu
            else if (as3hx.Compat.truthy(keyCode == Keyboard.F1))
            {
                if (as3hx.Compat.truthy(Std.is(current_popup, PopupHelp)))
                {
                    removePopup();
                }
                else
                {
                    addPopup(Main.POPUP_HELP);
                }
            }
            // Replay History
            else if (as3hx.Compat.truthy(keyCode == Keyboard.F2))
            {
                if (as3hx.Compat.truthy(Std.is(current_popup, ReplayHistoryWindow)))
                {
                    removePopup();
                }
                else
                {
                    addPopup(Main.POPUP_REPLAY_HISTORY);
                }
            }
        }
    }
    
    public function restartApplication() : Void
    {
        Logger.warning(this, "restartApplication is not implemented in the OpenFL port yet.");
    }
}

