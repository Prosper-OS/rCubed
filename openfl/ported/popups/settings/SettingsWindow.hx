package popups.settings;

import openfl.errors.Error;
import assets.GameBackgroundColor;
import classes.Language;
import classes.SongInfo;
import classes.User;
import classes.chart.Song;
import classes.ui.BoxButton;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;
import com.flashfla.utils.SpriteUtil;
import com.greensock.TweenLite;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.media.SoundMixer;
import openfl.media.SoundTransform;
import game.GameOptions;
import menu.MainMenu;
import menu.MenuPanel;
import menu.MenuSongSelection;
import arc.ArcGlobals;

import assets.menu.icons.fa.IconRight;
import classes.Alert;



import classes.ui.BoxCheck;
import classes.ui.Prompt;



import com.flashfla.utils.SystemUtil;




import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import popups.settings.SettingsWindow;

class SettingsWindow extends MenuPanel
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var box                       : Dynamic;
    private var bmp                       : Dynamic;
    
    public var scrollbar                       : Dynamic;
    public var pane                       : Dynamic;
    
    private var TABS                       : Dynamic;
    
    private var CURRENT_TAB                       : Dynamic;
    private var CURRENT_INDEX                       : Dynamic= -1;
    private static var LAST_INDEX                       : Dynamic= 0;
    
    private var TAB_BUTTONS                       : Dynamic;
    
    private var txt_settings                       : Dynamic;
    private var txt_mod_warning                       : Dynamic;
    
    // buttons
    private var btn_close                       : Dynamic;
    private var btn_manage                       : Dynamic;
    private var btn_reset                       : Dynamic;
    
    private var btn_editor_gameplay                       : Dynamic;
    private var btn_editor_multiplayer                       : Dynamic;
    
    private var game_options_test                       : Dynamic= new GameOptions();
    
    private var win_manage                       : Dynamic;
    private var win_reset                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    
    {
TABS = [new SettingsTabGeneral(this), 
                        new SettingsTabInput(this), 
                        new SettingsTabNoteskin(this), 
                        new SettingsTabModifiers(this), 
                        new SettingsTabVisuals(this), 
                        new SettingsTabColors(this), 
                        new SettingsTabMisc(this)
            ];
        
        TAB_BUTTONS = [];
        
        super(myParent);
    }
    
    override public function stageAdd() : Void
    {
        stage.focus = this.stage;
        
        bmp = SpriteUtil.getBitmapSprite(stage);
        this.addChild(bmp);
        
        // background
        box = new Sprite();
        box.graphics.lineStyle(0, 0, 0);
        
        box.graphics.beginFill(0, 0.2);
        box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        box.graphics.endFill();
        
        box.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.6);
        box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        box.graphics.endFill();
        
        box.graphics.beginFill(0xFFFFFF, 0.07);
        box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        box.graphics.endFill();
        
        box.graphics.beginFill(0x000000, 0.1);
        box.graphics.drawRect(0, 61, 173, Main.GAME_HEIGHT - 60);
        box.graphics.endFill();
        
        // dividers
        box.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        box.graphics.moveTo(0, 60);
        box.graphics.lineTo(Main.GAME_WIDTH, 60);
        box.graphics.moveTo(174, 61);
        box.graphics.lineTo(174, Main.GAME_HEIGHT);
        box.graphics.moveTo(Main.GAME_WIDTH - 16, 61);
        box.graphics.lineTo(Main.GAME_WIDTH - 16, Main.GAME_HEIGHT);
        
        this.addChild(box);
        
        // scroll pane
        pane = new ScrollPane(this, 175, 61, 589, Main.GAME_HEIGHT - 61, mouseWheelMoved);
        scrollbar = new ScrollBar(this, Main.GAME_WIDTH - 16, 61, 16, Main.GAME_HEIGHT - 61, null, new Sprite());
        scrollbar.addEventListener(Event.CHANGE, scrollBarMoved, false, 0, false);
        
        // ui
        buildTabs();
        
        txt_settings = new Text(box, 15, 5, _lang.string("settings_title"), 32);
        
        txt_mod_warning = new Text(box, 215, 18, _lang.string("options_warning_save"), 14, "#f06868");
        txt_mod_warning.setAreaParams(265, 24, "right");
        
        btn_reset = new BoxButton(box, 495, 15, 80, 29, _lang.string("menu_reset"), 12, clickHandler);
        btn_reset.color = 0xff0000;
        
        btn_manage = new BoxButton(box, 590, 15, 80, 29, _lang.string("menu_manage"), 12, clickHandler);
        
        btn_close = new BoxButton(box, 685, 15, 80, 29, _lang.string("menu_close"), 12, clickHandler);
        //btn_close.contextMenu = _contextImportExport;
        
        changeTab(LAST_INDEX);
    }
    
    override public function stageRemove() : Void
    {
        CURRENT_TAB.closeTab();
        scrollbar.removeEventListener(Event.CHANGE, scrollBarMoved, false);
        pane.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false);
    }
    
    public function buildTabs() : Void
    {
        var tabBox                       : Dynamic= null;
        
        for (idx in 0...TABS.length)
        {
            TABS[idx].container = pane.content;
            
            tabBox = new TabButton(box, -1, 60 + 33 * idx, idx, _lang.string("settings_tab_" + TABS[idx].name));
            tabBox.tabIndex = idx;
            tabBox.addEventListener(MouseEvent.CLICK, tabHandler);
            
            TAB_BUTTONS.push(tabBox);
        }
        
        // editor buttons
        btn_editor_gameplay = new TabButton(box, -1, 397, -1, _lang.string("settings_tab_editor_gameplay"), true);
        btn_editor_gameplay.addEventListener(MouseEvent.CLICK, clickHandler);
        btn_editor_multiplayer = new TabButton(box, -1, 430, -1, _lang.string("settings_tab_editor_multiplayer"));
        btn_editor_multiplayer.addEventListener(MouseEvent.CLICK, clickHandler);
    }
    
    public function changeTab(idx                       : Dynamic, force                       : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(CURRENT_INDEX == idx && !force))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(CURRENT_TAB != null))
        {
            CURRENT_TAB.closeTab();
            pane.clear();
            pane.content.graphics.clear();
        }
        
        CURRENT_INDEX = idx;
        CURRENT_TAB = TABS[idx];
        CURRENT_TAB.openTab();
        CURRENT_TAB.setValues();
        LAST_INDEX = idx;
        
        pane.update();
        
        pane.scrollTo(0);
        scrollbar.scrollTo(0);
        
        scrollbar.visible = (pane.content.height > 425);
        
        // update buttons
        for (tabButton in as3hx.Compat.iter(TAB_BUTTONS))
        {
            tabButton.setActive(tabButton.index == idx);
        }
        
        checkValidMods();
    }
    
    public function refreshTab() : Void
    {
        changeTab(CURRENT_INDEX, true);
    }
    
    private function tabHandler(e                       : Dynamic) : Void
    {
        changeTab((try cast(e.currentTarget, TabButton) catch(e:Dynamic) null).index);
    }
    
    public function checkValidMods() : Void
    {
        game_options_test.fill();
        txt_mod_warning.visible = !game_options_test.isScoreValid();
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.currentTarget == btn_editor_gameplay || e.currentTarget == btn_editor_multiplayer))
        {
            setGameColors();
            
            _gvars.options = new GameOptions();
            _gvars.options.isEditor = true;
            _gvars.options.isMultiplayer = (e.currentTarget == btn_editor_multiplayer);
            
            var tempSongInfo                       : Dynamic= new SongInfo();
            tempSongInfo.level = 1337;
            tempSongInfo.chart_type = "EDITOR";
            _gvars.options.song = new Song(tempSongInfo);
            
            _gvars.options.fill();
            removePopup();
            _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
            return;
        }
        else if (as3hx.Compat.truthy(e.target == btn_manage))
        {
            win_manage = new ManageWindow(this);
        }
        else if (as3hx.Compat.truthy(e.target == btn_reset))
        {
            win_reset = new ConfirmResetWindow(this);
        }
        else if (as3hx.Compat.truthy(e.target == btn_close))
        {
            if (as3hx.Compat.truthy(_gvars.activeUser == _gvars.playerUser))
            {
                _gvars.activeUser.saveLocal();
                _gvars.activeUser.save();
                LocalOptions.flush();
                
                setGameColors();
                
                if (as3hx.Compat.truthy(Std.is(_gvars.gameMain.activePanel, MainMenu) && (Std.is((try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null).panel, MenuSongSelection))))
                {
                    var panel                       : Dynamic= (try cast((try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null).panel, MenuSongSelection) catch(e:Dynamic) null);
                    panel.buildGenreList();
                    panel.drawPages();
                }
            }
            SoundMixer.soundTransform = new SoundTransform(_gvars.activeUser.gameVolume);
            LocalOptions.setVariable("menu_music_volume", _gvars.menuMusicSoundVolume);
            removePopup();
            return;
        }
    }
    
    private function mouseWheelMoved(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        var dist                       : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function scrollBarMoved(e                       : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
    
    private function setGameColors() : Void
    {
        GameBackgroundColor.BG_LIGHT = _gvars.activeUser.gameColors[0];
        GameBackgroundColor.BG_DARK = _gvars.activeUser.gameColors[1];
        GameBackgroundColor.BG_STATIC = _gvars.activeUser.gameColors[2];
        GameBackgroundColor.BG_POPUP = _gvars.activeUser.gameColors[3];
        GameBackgroundColor.BG_STAGE = _gvars.activeUser.gameColors[4];
        (try cast(_gvars.gameMain.getChildAt(0), GameBackgroundColor) catch(e:Dynamic) null).redraw();
    }
}



class TabButton extends Sprite
{
    public var index                       : Dynamic;
    
    private var text                       : Dynamic;
    private var button                       : Dynamic;
    private var chevron                       : Dynamic;
    
    private var active                       : Dynamic= false;
    
    private var hasTopBorder                       : Dynamic= false;
    
    @:allow(popups.settings)
    private function new(parent                       : Dynamic, xpos                       : Dynamic, ypos                       : Dynamic, index                       : Dynamic, btnText                       : Dynamic, hasTopBorder                       : Dynamic= false)
    {
        super();
        this.index = index;
        this.hasTopBorder = hasTopBorder;
        
        this.text = new Text(this, 15, 5, btnText);
        this.text.setAreaParams(146, 22);
        
        this.button = new SimpleBoxButton(175, 32);
        this.addChild(button);
        
        this.x = xpos;
        this.y = ypos;
        parent.addChild(this);
        
        this.chevron = new IconRight();
        this.chevron.x = 16;
        this.chevron.y = 16.5;
        this.chevron.scaleX = this.chevron.scaleY = 0.2;
        this.chevron.visible = false;
        this.addChild(chevron);
        
        draw();
    }
    
    public function draw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0xFFFFFF, (active) ? 0.2 : 0.08);
        this.graphics.drawRect(0, 0, 175, 32);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, 32);
        this.graphics.lineTo(175, 32);
        
        if (as3hx.Compat.truthy(hasTopBorder))
        {
            this.graphics.moveTo(0, 0);
            this.graphics.lineTo(175, 0);
        }
    }
    
    public function setActive(newState                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(this.active != newState))
        {
            TweenLite.to(this.text, 0.25, {
                        x : ((newState) ? 25 : 15)
                    });
            this.active = newState;
            this.button.visible = !newState;
            this.chevron.visible = newState;
            draw();
        }
    }
}

class ManageWindow extends Prompt
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var win                       : Dynamic;
    
    private var boxMid                       : Dynamic= 290;
    
    private var saveJSON                       : Dynamic;
    
    private var btn_close                       : Dynamic;
    private var txt_export                       : Dynamic;
    private var btn_export                       : Dynamic;
    private var txt_import                       : Dynamic;
    private var btn_import                       : Dynamic;
    
    private var check_settings                       : Dynamic;
    private var check_layout                       : Dynamic;
    private var check_filters                       : Dynamic;
    private var check_songQueues                       : Dynamic;
    
    @:allow(popups.settings)
    private function new(win                       : Dynamic)
    {
        this.win = win;
        super(win, 580, 320);
        
        var xOff                       : Dynamic= 10;
        var yOff                       : Dynamic= 0;
        
        // Close
        btn_close = new BoxButton(this, width - 110, height - 39, 100, 29, _lang.string("menu_close"), 12, clickHandler);
        
        // Export
        new Text(this, xOff, yOff + 12, _lang.string("settings_manage_export"), 16).setAreaParams(160, 30);
        btn_export = new BoxButton(this, xOff + 169, yOff + 10, 100, 26, _lang.string("menu_copy"), 12, clickHandler);
        
        txt_export = makeTextfield(160);
        txt_export.x = xOff + 5;
        txt_export.y = yOff + 50;
        txt_export.type = TextFieldType.DYNAMIC;
        
        _content.graphics.beginFill(0, 0.4);
        _content.graphics.drawRect(txt_export.x - 4, txt_export.y - 4, txt_export.width + 8, txt_export.height + 8);
        _content.graphics.endFill();
        
        // Filters
        yOff = txt_export.y + txt_export.height + 13;
        
        new Text(this, xOff + 21, yOff, _lang.string("settings_manage_filter_settings")).setAreaParams(250, 22);
        check_settings = new BoxCheck(this, xOff + 1, yOff + 3, clickHandler);
        check_settings.checked = true;
        yOff += 22;
        
        new Text(this, xOff + 21, yOff, _lang.string("settings_manage_filter_layout")).setAreaParams(250, 22);
        check_layout = new BoxCheck(this, xOff + 1, yOff + 3, clickHandler);
        yOff += 22;
        
        new Text(this, xOff + 21, yOff, _lang.string("settings_manage_filter_filters")).setAreaParams(250, 22);
        check_filters = new BoxCheck(this, xOff + 1, yOff + 3, clickHandler);
        yOff += 22;
        
        new Text(this, xOff + 21, yOff, _lang.string("settings_manage_filter_song_queues")).setAreaParams(250, 22);
        check_songQueues = new BoxCheck(this, xOff + 1, yOff + 3, clickHandler);
        yOff += 22;
        
        yOff = 0;
        xOff = boxMid + 10;
        
        // Import
        new Text(this, xOff + 0, yOff + 12, _lang.string("settings_manage_import"), 16).setAreaParams(160, 30);
        btn_import = new BoxButton(this, xOff + 169, yOff + 10, 100, 26, _lang.string("menu_save"), 12, clickHandler);
        
        txt_import = makeTextfield(215);
        txt_import.x = xOff + 5;
        txt_import.y = yOff + 50;
        txt_import.type = TextFieldType.INPUT;
        
        _content.graphics.beginFill(0, 0.4);
        _content.graphics.drawRect(txt_import.x - 4, txt_import.y - 4, txt_import.width + 8, txt_import.height + 8);
        _content.graphics.endFill();
        
        // Update
        updateJSON();
    }
    
    private function makeTextfield(_h                       : Dynamic) : TextField
    {
        var _tf                       : Dynamic= new TextField();
        _tf.width = boxMid - 30;
        _tf.height = _h;
        _tf.multiline = true;
        _tf.defaultTextFormat = new TextFormat(Fonts.BASE_FONT, 10, 0xFFFFFF, true);
        _tf.type = TextFieldType.DYNAMIC;
        _tf.embedFonts = true;
        _tf.antiAliasType = AntiAliasType.ADVANCED;
        _tf.gridFitType = GridFitType.SUBPIXEL;
        _tf.wordWrap = true;
        addChild(_tf);
        return _tf;
    }
    
    private function updateJSON() : Void
    // Filter Settings
    {
        
        var saveObject                       : Dynamic= _gvars.activeUser.save(true);
        Reflect.deleteField(saveObject, "language");
        
        if (as3hx.Compat.truthy(!check_settings.checked))
        {
            saveObject = {
                        layout : saveObject.layout,
                        filters : saveObject.filters,
                        songQueues : saveObject.songQueues
                    };
        }
        
        if (as3hx.Compat.truthy(!check_layout.checked))
        {
            Reflect.deleteField(saveObject, "layout");
        }
        
        if (as3hx.Compat.truthy(!check_filters.checked))
        {
            Reflect.deleteField(saveObject, "filters");
        }
        
        if (as3hx.Compat.truthy(!check_songQueues.checked))
        {
            Reflect.deleteField(saveObject, "songQueues");
        }
        
        saveJSON = haxe.Json.stringify(saveObject);
        txt_export.text = saveJSON;
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == btn_export))
        {
            var success                       : Dynamic= SystemUtil.setClipboard(saveJSON);
            
            if (as3hx.Compat.truthy(success))
            {
                Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
            }
            else
            {
                Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
            }
        }
        else if (as3hx.Compat.truthy(e.target == btn_import))
        {
            try
            {
                var optionsJSON                       : Dynamic= txt_import.text;
                if (as3hx.Compat.truthy(optionsJSON.length >= 2 && optionsJSON.charAt(0) == "{"))
                {
                    var item                       : Dynamic= haxe.Json.parse(optionsJSON);
                    _gvars.activeUser.settings = item;
                    Alert.add(_lang.string("settings_manage_import_success"), 120, Alert.GREEN);
                }
                else
                {
                    Alert.add(_lang.string("settings_manage_import_blank"), 120, Alert.RED);
                }
            }
            catch (e : Error)
            {
                Alert.add(_lang.string("settings_manage_import_fail"), 120, Alert.RED);
            }
        }
        else if (as3hx.Compat.truthy(e.target == check_settings || e.target == check_layout || e.target == check_filters || e.target == check_songQueues))
        {
            e.target.checked = !e.target.checked;
            updateJSON();
        }
        else if (as3hx.Compat.truthy(e.target == btn_close))
        {
            win.removeChild(this);
        }
    }
}

class ConfirmResetWindow extends Prompt
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var win                       : Dynamic;
    
    private var boxMid                       : Dynamic= Main.GAME_WIDTH / 2;
    
    private var btn_close                       : Dynamic;
    private var btn_confirm                       : Dynamic;
    
    @:allow(popups.settings)
    private function new(win                       : Dynamic)
    {
        super(win, 450, 200);
        this.win = win; // Title  ;
        new Text(this, 0, 22, _lang.string("option_reset_settings_confirm_text"), 26).setAreaParams(width, 35, "center");
        
        // Confirm
        btn_confirm = new BoxButton(this, 15, height - 50, 120, 35, _lang.string("menu_reset"), 12, clickHandler);
        btn_confirm.color = 0xAA0000;
        btn_confirm.textColor = "#AA0000";
        
        // Close
        btn_close = new BoxButton(this, width - 135, height - 50, 120, 35, _lang.string("menu_close"), 12, clickHandler);
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == btn_confirm))
        {
            win.removeChild(this);
            if (as3hx.Compat.truthy(_gvars.activeUser == _gvars.playerUser))
            {
                _gvars.activeUser.settings = new User().settings;
                _avars.resetSettings();
            }
            win.refreshTab();
        }
        else if (as3hx.Compat.truthy(e.target == btn_close))
        {
            win.removeChild(this);
        }
    }
}
