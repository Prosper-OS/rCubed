package popups.settings;

import arc.ArcGlobals;
import classes.Alert;
import classes.Language;
import classes.Playlist;
import classes.chart.parse.ChartFFRLegacy;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.PromptInput;
import classes.ui.Text;
import classes.ui.ValidatedText;
import com.bit101.components.ComboBox;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.NativeWindowBoundsEvent;
import openfl.net.URLRequest;
import openfl.system.Capabilities;
import menu.MainMenu;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;



import openfl.display.Sprite;

import openfl.events.TimerEvent;
import openfl.utils.Timer;
import popups.settings.SettingsTabMisc;

class SettingsTabMisc extends SettingsTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var _playlist                       : Dynamic= Playlist.instance;
    
    private var optionGameLanguages                       : Dynamic;
    private var languageCombo                       : Dynamic;
    private var languageComboIgnore                       : Dynamic;
    
    private var useCacheCheckbox                       : Dynamic;
    private var autoSaveLocalCheckbox                       : Dynamic;
    private var useVSyncCheckbox                       : Dynamic;
    private var useWebsocketCheckbox                       : Dynamic;
    private var openWebsocketOverlay                       : Dynamic;
    
    private var reloadEngineData                       : Dynamic;
    private var switchUserAccount                       : Dynamic;
    
    private var engineCombo                       : Dynamic;
    private var engineDefaultCombo                       : Dynamic;
    private var engineComboIgnore                       : Dynamic;
    private var optionFPS                       : Dynamic;
    
    private var windowWidthBox                       : Dynamic;
    private var windowHeightBox                       : Dynamic;
    private var windowSizeSet                       : Dynamic;
    private var windowSizeReset                       : Dynamic;
    private var windowSaveSizeCheck                       : Dynamic;
    private var windowXBox                       : Dynamic;
    private var windowYBox                       : Dynamic;
    private var windowPositionSet                       : Dynamic;
    private var windowPositionReset                       : Dynamic;
    private var windowSavePositionCheck                       : Dynamic;
    private var windowFullscreen                       : Dynamic;
    private var windowSaveFullscreen                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "misc";
    }
    
    override public function openTab() : Void
    {
        Main.window.addEventListener(NativeWindowBoundsEvent.MOVE, e_windowPropertyChange);
        Main.window.addEventListener(NativeWindowBoundsEvent.RESIZE, e_windowPropertyChange);
        
        container.stage.addEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDownMenu, true, as3hx.Compat.INT_MAX - 10, true);
        
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(295, 15);
        container.graphics.lineTo(295, 405);
        
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 15;
        
        /// Col 1
        //- Game Languages
        optionGameLanguages = [];
        var gameLanguageLabel                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_game_language"));
        yOff += 20;
        
        var selectedLanguage                       : Dynamic= "";
        for (id in as3hx.Compat.iter(Reflect.fields(_lang.indexed)))
        {
            var lang                       : Dynamic= _lang.indexed[id];
            var lang_name                       : Dynamic= _lang.string2Simple("_real_name", lang) + ((as3hx.Compat.field(as3hx.Compat.field(_lang.data, lang), "_en_name") != as3hx.Compat.field(as3hx.Compat.field(_lang.data, lang), "_real_name")) ? (" / " + _lang.string2Simple("_en_name", lang)) : "");
            optionGameLanguages.push({
                        label : lang_name,
                        data : lang
                    });
            if (as3hx.Compat.truthy(lang == _gvars.activeUser.language))
            {
                selectedLanguage = lang_name;
            }
        }
        
        languageCombo = new ComboBox(container, xOff, yOff, selectedLanguage, optionGameLanguages);
        languageCombo.x = xOff;
        languageCombo.y = yOff;
        languageCombo.setSize(245, 22);
        languageCombo.openPosition = ComboBox.BOTTOM;
        languageCombo.fontSize = 11;
        languageCombo.addEventListener(Event.SELECT, languageSelect);
        setLanguage();
        yOff += 30;
        
        yOff += drawSeperator(container, xOff, 266, yOff, 0, 0);
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_save_local_replays"));
        autoSaveLocalCheckbox = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 30;
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_use_cache"));
        useCacheCheckbox = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 30;
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_use_websockets"));
        useWebsocketCheckbox = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        useWebsocketCheckbox.addEventListener(MouseEvent.MOUSE_OVER, e_websocketMouseOver, false, 0, true);
        yOff += 30;
        
        // https://github.com/flashflashrevolution/web-stream-overlay
        openWebsocketOverlay = new BoxButton(container, xOff, yOff, 245, 27, _lang.string("options_overlay_instructions"), 12, clickHandler);
        yOff += 30;
        
        yOff += drawSeperator(container, xOff, 266, yOff, 0, 2);
        
        reloadEngineData = new BoxButton(container, xOff, yOff, 245, 27, _lang.string("popup_cm_reload_engine_user"), 12, clickHandler);
        yOff += 37;
        
        switchUserAccount = new BoxButton(container, xOff, yOff, 245, 27, _lang.string("popup_cm_switch_profile"), 12, clickHandler);
        yOff += 37;
        
        /// Col 2
        xOff = 310;
        yOff = 15;
        
        // Game Engine
        new Text(container, xOff, yOff, _lang.string("options_game_engine"));
        yOff += 20;
        
        engineCombo = new ComboBox(container, xOff, yOff);
        engineCombo.setSize(245, 22);
        engineCombo.openPosition = ComboBox.BOTTOM;
        engineCombo.fontSize = 11;
        engineCombo.addEventListener(Event.SELECT, engineSelect);
        yOff += 30;
        
        // Default Game Engine
        new Text(container, xOff, yOff, _lang.string("options_default_game_engine"));
        yOff += 20;
        
        engineDefaultCombo = new ComboBox(container, xOff, yOff);
        engineDefaultCombo.setSize(245, 22);
        engineDefaultCombo.openPosition = ComboBox.BOTTOM;
        engineDefaultCombo.fontSize = 11;
        engineDefaultCombo.addEventListener(Event.SELECT, engineDefaultSelect);
        container.addChild(engineDefaultCombo);
        engineRefresh();
        yOff += 30;
        
        yOff += drawSeperator(container, xOff, 266, yOff, 0, 0);
        
        // Engine Framerate
        new Text(container, xOff, yOff, _lang.string("options_framerate"));
        yOff += 20;
        
        optionFPS = new ValidatedText(container, xOff + 3, yOff + 3, 120, 20, ValidatedText.R_INT_P, changeHandler);
        
        new Text(container, xOff + 163, yOff + 4, _lang.string("air_options_use_vsync"));
        useVSyncCheckbox = new BoxCheck(container, xOff + 143, yOff + 7, clickHandler);
        if (as3hx.Compat.truthy(!Main.VSYNC_SUPPORT))
        {
            useVSyncCheckbox.alpha = 0.5;
            useVSyncCheckbox.addEventListener(MouseEvent.MOUSE_OVER, e_vsyncMouseOver, false, 0, true);
        }
        yOff += 30;
        
        yOff += drawSeperator(container, xOff, 266, yOff, 0, 0);
        
        // Window Size
        new Text(container, xOff, yOff, _lang.string("air_options_window_size"));
        yOff += 20;
        
        windowWidthBox = new ValidatedText(container, xOff + 3, yOff + 3, 60, 20, ValidatedText.R_INT);
        new Text(container, xOff + 73, yOff + 3, "X");
        windowHeightBox = new ValidatedText(container, xOff + 93, yOff + 3, 60, 20, ValidatedText.R_INT);
        windowSizeSet = new BoxButton(container, xOff + 163, yOff + 3, 51, 21, "Set", 12, clickHandler);
        windowSizeReset = new BoxButton(container, xOff + 223, yOff + 3, 21, 21, "R", 12, clickHandler);
        yOff += 30;
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_save_window_size"));
        windowSaveSizeCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 30;
        
        // Window Position
        new Text(container, xOff, yOff, _lang.string("air_options_window_position"));
        yOff += 20;
        
        windowXBox = new ValidatedText(container, xOff + 3, yOff + 3, 60, 20, ValidatedText.R_INT);
        new Text(container, xOff + 73, yOff + 3, "X");
        windowYBox = new ValidatedText(container, xOff + 93, yOff + 3, 60, 20, ValidatedText.R_INT);
        windowPositionSet = new BoxButton(container, xOff + 163, yOff + 3, 51, 21, "Set", 12, clickHandler);
        windowPositionReset = new BoxButton(container, xOff + 223, yOff + 3, 21, 21, "R", 12, clickHandler);
        yOff += 30;
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_save_window_position"));
        windowSavePositionCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 30;
        
        new Text(container, xOff + 23, yOff, _lang.string("air_options_fullscreen"));
        windowFullscreen = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        
        new Text(container, xOff + 133, yOff, _lang.string("air_options_launch_fullscreen"));
        windowSaveFullscreen = new BoxCheck(container, xOff + 113, yOff + 3, clickHandler);
        yOff += 30;
        
        setTextMaxWidth(245);
    }
    
    override public function closeTab() : Void
    {
        Main.window.removeEventListener(NativeWindowBoundsEvent.MOVE, e_windowPropertyChange);
        Main.window.removeEventListener(NativeWindowBoundsEvent.RESIZE, e_windowPropertyChange);
        container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDownMenu);
    }
    
    override public function setValues() : Void
    // Set Framerate
    {
        
        optionFPS.text = Std.string(_gvars.activeUser.frameRate);
        
        setLanguage();
        
        autoSaveLocalCheckbox.checked = _gvars.air_autoSaveLocalReplays;
        useCacheCheckbox.checked = _gvars.air_useLocalFileCache;
        useWebsocketCheckbox.checked = _gvars.air_useWebsockets;
        
        if (as3hx.Compat.truthy(Main.VSYNC_SUPPORT))
        {
            useVSyncCheckbox.checked = _gvars.air_useVSync;
        }
        else
        {
            useVSyncCheckbox.checked = true;
        }
        
        windowWidthBox.text = _gvars.air_windowProperties.width;
        windowHeightBox.text = _gvars.air_windowProperties.height;
        windowXBox.text = _gvars.air_windowProperties.x;
        windowYBox.text = _gvars.air_windowProperties.y;
        
        windowSavePositionCheck.checked = _gvars.air_saveWindowPosition;
        windowSaveSizeCheck.checked = _gvars.air_saveWindowSize;
        windowSaveFullscreen.checked = _gvars.air_useFullScreen;
        windowFullscreen.checked = _gvars.isFullScreen();
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    // Auto Save Local Replays
    {
        
        if (as3hx.Compat.truthy(e.target == autoSaveLocalCheckbox))
        {
            e.target.checked = !e.target.checked;
            _gvars.air_autoSaveLocalReplays = !_gvars.air_autoSaveLocalReplays;
            LocalOptions.setVariable("auto_save_local_replays", _gvars.air_autoSaveLocalReplays);
        }
        // SWF File Cache
        else if (as3hx.Compat.truthy(e.target == useCacheCheckbox))
        {
            e.target.checked = !e.target.checked;
            _gvars.air_useLocalFileCache = !_gvars.air_useLocalFileCache;
            LocalOptions.setVariable("use_local_file_cache", _gvars.air_useLocalFileCache);
        }
        // Vsync Toggle
        else if (as3hx.Compat.truthy(e.target == useVSyncCheckbox))
        {
            if (as3hx.Compat.truthy(Main.VSYNC_SUPPORT))
            {
                e.target.checked = !e.target.checked;
                _gvars.gameMain.stage.vsyncEnabled = _gvars.air_useVSync = !_gvars.air_useVSync;
                LocalOptions.setVariable("vsync", _gvars.air_useVSync);
            }
        }
        // Use HTTP Websockets
        else if (as3hx.Compat.truthy(e.target == useWebsocketCheckbox))
        {
            if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
            {
                _gvars.destroyWebsocketServer();
                _gvars.air_useWebsockets = false;
                useWebsocketCheckbox.checked = false;
                LocalOptions.setVariable("use_websockets", _gvars.air_useWebsockets);
            }
            else if (as3hx.Compat.truthy(_gvars.initWebsocketServer()))
            {
                _gvars.air_useWebsockets = true;
                useWebsocketCheckbox.checked = true;
                LocalOptions.setVariable("use_websockets", _gvars.air_useWebsockets);
                e_websocketMouseOver();
            }
            else
            {
                useWebsocketCheckbox.checked = false;
                Alert.add(_lang.string("air_options_unable_to_start_websockets"), 120, Alert.RED);
            }
        }
        // HTTP Websockets Instructions
        else if (as3hx.Compat.truthy(e.target == openWebsocketOverlay))
        {
            flash.Lib.getURL(new URLRequest(Constant.WEBSOCKET_OVERLAY_URL), "_blank");
        }
        //- Engine Reload
        else if (as3hx.Compat.truthy(e.target == reloadEngineData))
        {
            _gvars.reloadEngineData();
        }
        else if (as3hx.Compat.truthy(e.target == switchUserAccount))
        {
            _gvars.switchUserAccount();
        }
        // Window Position
        else if (as3hx.Compat.truthy(e.target == windowSavePositionCheck))
        {
            e.target.checked = !e.target.checked;
            _gvars.air_saveWindowPosition = !_gvars.air_saveWindowPosition;
            LocalOptions.setVariable("save_window_position", _gvars.air_saveWindowPosition);
        }
        else if (as3hx.Compat.truthy(e.target == windowPositionSet))
        {
            parent.addChild(new WindowSettingConfirm(this, _gvars.air_windowProperties));
            
            Reflect.setField(_gvars.air_windowProperties, "x", windowXBox.validate(Math.round((Capabilities.screenResolutionX - Main.window.width) * 0.5)));
            Reflect.setField(_gvars.air_windowProperties, "y", windowYBox.validate(Math.round((Capabilities.screenResolutionY - Main.window.height) * 0.5)));
            e_windowSetUpdate();
            windowFullscreen.checked = _gvars.isFullScreen();
        }
        else if (as3hx.Compat.truthy(e.target == windowPositionReset))
        {
            Reflect.setField(_gvars.air_windowProperties, "x", Math.round((Capabilities.screenResolutionX - Main.window.width) * 0.5));
            Reflect.setField(_gvars.air_windowProperties, "y", Math.round((Capabilities.screenResolutionY - Main.window.height) * 0.5));
            e_windowSetUpdate();
            windowFullscreen.checked = _gvars.isFullScreen();
        }
        // Window Size
        else if (as3hx.Compat.truthy(e.target == windowSaveSizeCheck))
        {
            e.target.checked = !e.target.checked;
            _gvars.air_saveWindowSize = !_gvars.air_saveWindowSize;
            LocalOptions.setVariable("save_window_size", _gvars.air_saveWindowSize);
        }
        else if (as3hx.Compat.truthy(e.target == windowSizeSet))
        {
            parent.addChild(new WindowSettingConfirm(this, _gvars.air_windowProperties));
            
            Reflect.setField(_gvars.air_windowProperties, "width", windowWidthBox.validate(Main.GAME_WIDTH));
            Reflect.setField(_gvars.air_windowProperties, "height", windowHeightBox.validate(Main.GAME_HEIGHT));
            e_windowSetUpdate();
            windowFullscreen.checked = _gvars.isFullScreen();
        }
        else if (as3hx.Compat.truthy(e.target == windowSizeReset))
        {
            Reflect.setField(_gvars.air_windowProperties, "width", Main.GAME_WIDTH);
            Reflect.setField(_gvars.air_windowProperties, "height", Main.GAME_HEIGHT);
            e_windowSetUpdate();
            windowFullscreen.checked = _gvars.isFullScreen();
        }
        else if (as3hx.Compat.truthy(e.target == windowSaveFullscreen))
        {
            e.target.checked = !e.target.checked;
            _gvars.air_useFullScreen = !_gvars.air_useFullScreen;
            LocalOptions.setVariable("save_usefullscreen", _gvars.air_useFullScreen);
        }
        else if (as3hx.Compat.truthy(e.target == windowFullscreen))
        {
            _gvars.toggleFullScreen();
            windowFullscreen.checked = _gvars.isFullScreen();
        }
    }
    
    override public function changeHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == optionFPS))
        {
            _gvars.activeUser.frameRate = optionFPS.validate(60);
            _gvars.activeUser.frameRate = Math.max(Math.min(_gvars.activeUser.frameRate, 1000), 10);
        }
    }
    
    public function e_onKeyDownMenu(e                       : Dynamic) : Void
    {
        var keyCode                       : Dynamic= e.keyCode;
        
        if (as3hx.Compat.truthy(keyCode == Keyboard.ESCAPE))
        {
            windowFullscreen.checked = false;  //ESC exits fullscreen  
            return;
        }
        
        if (as3hx.Compat.truthy(e.ctrlKey && keyCode == Keyboard.S))
        {
            windowFullscreen.checked = false;  //CTRL+S also exits fullscreen  
            return;
        }
    }
    
    private function e_windowPropertyChange(e                       : Dynamic) : Void
    {
        windowWidthBox.text = as3hx.Compat.field(_gvars.air_windowProperties, "width");
        windowHeightBox.text = as3hx.Compat.field(_gvars.air_windowProperties, "height");
        
        windowXBox.text = as3hx.Compat.field(_gvars.air_windowProperties, "x");
        windowYBox.text = as3hx.Compat.field(_gvars.air_windowProperties, "y");
    }
    
    public function e_windowSetUpdate() : Void
    {
        _gvars.gameMain.ignoreWindowChanges = true;
        Main.window.x = as3hx.Compat.field(_gvars.air_windowProperties, "x");
        Main.window.y = as3hx.Compat.field(_gvars.air_windowProperties, "y");
        Main.window.width = as3hx.Compat.field(_gvars.air_windowProperties, "width") + Main.WINDOW_WIDTH_EXTRA;
        Main.window.height = as3hx.Compat.field(_gvars.air_windowProperties, "height") + Main.WINDOW_HEIGHT_EXTRA;
        _gvars.gameMain.ignoreWindowChanges = false;
    }
    
    private function e_websocketMouseOver(e                       : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
        {
            var activePort                       : Dynamic= _gvars.websocketPortNumber("websocket");
            if (as3hx.Compat.truthy(activePort > 0))
            {
                useWebsocketCheckbox.addEventListener(MouseEvent.MOUSE_OUT, e_websocketMouseOut);
                displayToolTip(useWebsocketCheckbox.x, useWebsocketCheckbox.y + 22, sprintf(_lang.string("air_options_active_port"), {
                                    port : Std.string(_gvars.websocketPortNumber("websocket"))
                                }));
            }
        }
    }
    
    private function e_websocketMouseOut(e                       : Dynamic) : Void
    {
        useWebsocketCheckbox.removeEventListener(MouseEvent.MOUSE_OUT, e_websocketMouseOut);
        hideTooltip();
    }
    
    private function setLanguage() : Void
    {
        languageComboIgnore = true;
        languageCombo.selectedItemByData = _gvars.activeUser.language;
        languageComboIgnore = false;
    }
    
    private function languageSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!languageComboIgnore))
        {
            _gvars.activeUser.language = Std.string(e.target.selectedItem.data);
            
            _gvars.gameMain.activePanel.draw();
            _gvars.gameMain.buildContextMenu();
            
            if (as3hx.Compat.truthy(Std.is(_gvars.gameMain.activePanel, MainMenu)))
            {
                var mmpanel                       : Dynamic= (try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null);
                mmpanel.updateMenuMusicControls();
            }
            
            // refresh popup
            _gvars.gameMain.addPopup(Main.POPUP_OPTIONS);
        }
    }
    
    private function engineDefaultSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!engineComboIgnore))
        {
            _avars.legacyDefaultEngine = (try cast(e.target, ComboBox) catch(e:Dynamic) null).selectedItem.data;
            _avars.legacyDefaultSave();
        }
    }
    
    private function e_addEngine(url                       : Dynamic) : Void
    {
        ChartFFRLegacy.parseEngine(url, engineAdd);
    }
    
    private function engineSelect(e                       : Dynamic) : Void
    {
        var data                       : Dynamic= engineCombo.selectedItem.data;
        // Add Engine
        if (as3hx.Compat.truthy(data == this))
        {
            new PromptInput(parent, _lang.string("custom_engine_url"), _lang.string("custom_engine_add_engine"), e_addEngine);
        }
        // Clears Engines
        else if (as3hx.Compat.truthy(data == engineCombo))
        {
            _avars.legacyEngines = [];
            _avars.legacySave();
            engineRefresh();
        }
        // Change Engine
        else if (as3hx.Compat.truthy(!engineComboIgnore && data != _avars.configLegacy))
        {
            _avars.configLegacy = data;
            _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, _playlist.engineChangeHandler);
            _playlist.addEventListener(GlobalVariables.LOAD_ERROR, _playlist.engineChangeHandler);
            _playlist.load();
        }
    }
    
    private function engineAdd(engine                       : Dynamic) : Void
    {
        Alert.add(sprintf(_lang.string("custom_engine_loaded"), {
                            name : engine.name
                        }), 80);
        var i                      : Dynamic= 0;
        while (as3hx.Compat.truthy(i < _avars.legacyEngines.length))
        {
            if (as3hx.Compat.truthy(_avars.legacyEngines[i].id == engine.id))
            {
                engine.level_ranks = _avars.legacyEngines[i].level_ranks;
                _avars.legacyEngines[i] = engine;
                break;
            }
            i++;
        }
        if (as3hx.Compat.truthy(i == _avars.legacyEngines.length))
        {
            _avars.legacyEngines.push(engine);
        }
        _avars.legacySave();
        engineRefresh();
    }
    
    private function engineRefresh() : Void
    {
        engineComboIgnore = true;
        
        // engine Playlist Select
        engineCombo.removeAll();
        engineDefaultCombo.removeAll();
        engineCombo.addItem({
                    label : Constant.BRAND_NAME_LONG,
                    data : null
                });
        engineDefaultCombo.addItem({
                    label : Constant.BRAND_NAME_LONG,
                    data : null
                });
        engineCombo.selectedIndex = 0;
        engineDefaultCombo.selectedIndex = 0;
        for (engine/* AS3HX WARNING could not determine type for var: engine exp: EField(EIdent(_avars),legacyEngines) type: null */ in as3hx.Compat.iter(_avars.legacyEngines))
        {
            var item                       : Dynamic= {
                label : engine.name,
                data : engine
            };
            if (as3hx.Compat.truthy(!ChartFFRLegacy.validURL(Reflect.field(engine, "playlistURL"))))
            {
                continue;
            }
            if (as3hx.Compat.truthy(Reflect.field(engine, "config_url") == null))
            {
                Alert.add("Please re-add " + Reflect.field(engine, "name") + ", missing required information.", 240, Alert.RED);
                continue;
            }
            engineCombo.addItem(item);
            engineDefaultCombo.addItem(item);
            if (as3hx.Compat.truthy(engine == _avars.configLegacy || (_avars.configLegacy && Reflect.field(engine, "id") == as3hx.Compat.field(_avars.configLegacy, "id"))))
            {
                engineCombo.selectedItem = item;
            }
            if (as3hx.Compat.truthy(engine == _avars.legacyDefaultEngine || (_avars.legacyDefaultEngine && Reflect.field(engine, "id") == as3hx.Compat.field(_avars.legacyDefaultEngine, "id"))))
            {
                engineDefaultCombo.selectedItem = item;
            }
        }
        engineCombo.addItem({
                    label : _lang.stringSimple("custom_engine_add_engine"),
                    data : this
                });
        if (as3hx.Compat.truthy(_avars.legacyEngines.length > 0 && engineCombo.items.length > 2))
        {
            engineCombo.addItem({
                        label : _lang.stringSimple("custom_engine_clear_engines"),
                        data : engineCombo
                    });
        }
        engineComboIgnore = false;
    }
    
    private function e_vsyncMouseOver(e                       : Dynamic) : Void
    {
        useVSyncCheckbox.addEventListener(MouseEvent.MOUSE_OUT, e_vsyncMouseOut);
        displayToolTip(useVSyncCheckbox.x - 4, useVSyncCheckbox.y, _lang.string("air_options_use_vsync_unavailable"), "right");
    }
    
    private function e_vsyncMouseOut(e                       : Dynamic) : Void
    {
        useVSyncCheckbox.removeEventListener(MouseEvent.MOUSE_OUT, e_vsyncMouseOut);
        hideTooltip();
    }
}



class WindowSettingConfirm extends Sprite
{
    private var _lang                       : Dynamic= Language.instance;
    
    private var tab                       : Dynamic;
    private var properties                       : Dynamic;
    private var previousWidth                       : Dynamic;
    private var previousHeight                       : Dynamic;
    private var previousX                       : Dynamic;
    private var previousY                       : Dynamic;
    
    private var confirmTimer                       : Dynamic;
    
    private var window_text                       : Dynamic;
    private var window_timer_text                       : Dynamic;
    private var confirm_btn                       : Dynamic;
    
    @:allow(popups.settings)
    private function new(tab                       : Dynamic, properties                       : Dynamic)
    {
        super();
        this.tab = tab;
        this.properties = properties;
        
        this.previousX = Reflect.field(properties, "x");
        this.previousY = Reflect.field(properties, "y");
        this.previousWidth = Reflect.field(properties, "width");
        this.previousHeight = Reflect.field(properties, "height");
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0, 0.95);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        
        confirmTimer = new Timer(1000, 10);
        confirmTimer.addEventListener(TimerEvent.TIMER, e_timerTick);
        confirmTimer.start();
        
        window_text = new Text(this, 0, 200, _lang.string("option_window_settings_confirm_text"), 24);
        window_text.setAreaParams(Main.GAME_WIDTH, 30, "center");
        
        window_timer_text = new Text(this, 0, 250, "10", 38);
        window_timer_text.setAreaParams(Main.GAME_WIDTH, 30, "center");
        
        confirm_btn = new BoxButton(this, Main.GAME_WIDTH / 2 - 50, 400, 100, 30, _lang.string("menu_confirm"), 12, e_confirm);
    }
    
    private function e_timerTick(e                       : Dynamic) : Void
    {
        window_timer_text.text = Std.string(confirmTimer.repeatCount - confirmTimer.currentCount);
        
        if (as3hx.Compat.truthy(confirmTimer.currentCount >= confirmTimer.repeatCount))
        {
            e_cancel();
        }
    }
    
    private function e_confirm(e                       : Dynamic) : Void
    {
        confirmTimer.stop();
        this.parent.removeChild(this);
    }
    
    private function e_cancel() : Void
    {
        Reflect.setField(properties, "width", previousWidth);
        Reflect.setField(properties, "height", previousHeight);
        Reflect.setField(properties, "x", previousX);
        Reflect.setField(properties, "y", previousY);
        
        confirmTimer.stop();
        this.parent.removeChild(this);
        
        this.tab.e_windowSetUpdate();
    }
}
