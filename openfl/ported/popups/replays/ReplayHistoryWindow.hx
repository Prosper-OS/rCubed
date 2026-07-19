package popups.replays;

import assets.GameBackgroundColor;
import assets.menu.icons.fa.IconClose;
import assets.menu.icons.fa.IconSearch;
import classes.Alert;
import classes.Language;
import classes.replay.Replay;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.BoxIcon;
import classes.ui.BoxText;
import classes.ui.Prompt;
import classes.ui.ScrollBar;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;
import com.flashfla.utils.SpriteUtil;
import com.flashfla.utils.SystemUtil;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import game.GameOptions;
import menu.FileLoader;
import menu.MenuPanel;
import assets.menu.icons.fa.IconRight;


import com.greensock.TweenLite;


class ReplayHistoryWindow extends MenuPanel
{
    private static var e_changeHandler                    : Dynamic;
    private static var closePrompt                    : Dynamic;
    public var searchText(get, never)                       : Dynamic;

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
    
    private var txt_title                       : Dynamic;
    
    private var search_field                       : Dynamic;
    private var search_field_placeholder                       : Dynamic;
    private var _search_text                       : Dynamic= "";
    
    // settings
    private var useReplayLayout                       : Dynamic= true;
    
    // buttons
    private var btn_close                       : Dynamic;
    private var btn_options                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    
    {
TABS = [new ReplayHistoryTabSession(this), 
                        new ReplayHistoryTabLocal(this)
            ];
        
        if (as3hx.Compat.truthy(!_gvars.activeUser.isGuest))
        {
            TABS.push(new ReplayHistoryTabOnline(this));
        }
        
        TAB_BUTTONS = [];
        
        // Replay Options
        useReplayLayout = LocalOptions.getVariable("replay_layout", true);
        
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
        box.graphics.moveTo(670, 0);
        box.graphics.lineTo(670, 60);
        box.graphics.moveTo(0, 60);
        box.graphics.lineTo(Main.GAME_WIDTH, 60);
        box.graphics.moveTo(174, 61);
        box.graphics.lineTo(174, Main.GAME_HEIGHT);
        box.graphics.moveTo(Main.GAME_WIDTH - 16, 61);
        box.graphics.lineTo(Main.GAME_WIDTH - 16, Main.GAME_HEIGHT);
        
        this.addChild(box);
        
        // scroll pane
        pane = new ReplayHistoryScrollpane(this, 180, 61, 584, Main.GAME_HEIGHT - 61);
        pane.addEventListener(MouseEvent.MOUSE_WHEEL, e_mouseWheelMoved, false, 0, false);
        pane.addEventListener(MouseEvent.CLICK, e_replayEntryClick);
        scrollbar = new ScrollBar(this, Main.GAME_WIDTH - 16, 61, 16, Main.GAME_HEIGHT - 61, null, new Sprite());
        scrollbar.addEventListener(Event.CHANGE, e_scrollBarMoved, false, 0, false);
        
        // ui
        buildTabs();
        
        txt_title = new Text(box, 15, 5, _lang.string("replay_history_title"), 32);
        
        // Search
        search_field_placeholder = new Text(box, 405, 17, _lang.string("replay_search"));
        search_field_placeholder.setAreaParams(210, 27, "left");
        search_field_placeholder.alpha = 0.6;
        
        search_field = new BoxText(box, 400, 15, 220, 29);
        search_field.addEventListener(Event.CHANGE, e_searchChange, false, 0, true);
        
        var searchSprite                       : Dynamic= new IconSearch();
        searchSprite.x = 644;
        searchSprite.y = 31;
        searchSprite.scaleX = searchSprite.scaleY = 0.25;
        searchSprite.alpha = 0.8;
        box.addChild(searchSprite);
        
        btn_close = new BoxButton(box, 685, 15, 80, 29, _lang.string("menu_close"), 12, e_clickHandler);
        btn_options = new BoxButton(box, 5, 445, 162, 29, _lang.string("menu_options"), 12, e_replayOptions);
        
        changeTab(LAST_INDEX);
    }
    
    override public function stageRemove() : Void
    {
        CURRENT_TAB.closeTab();
        scrollbar.removeEventListener(Event.CHANGE, e_scrollBarMoved, false);
        pane.removeEventListener(MouseEvent.MOUSE_WHEEL, e_mouseWheelMoved, false);
    }
    
    public function buildTabs() : Void
    {
        var tabBox                       : Dynamic= null;
        
        for (idx in 0...TABS.length)
        {
            tabBox = new TabButton(box, -1, 60 + 33 * idx, idx, _lang.string("replay_tab_" + TABS[idx].name));
            tabBox.tabIndex = idx;
            tabBox.addEventListener(MouseEvent.CLICK, e_tabHandler);
            
            TAB_BUTTONS.push(tabBox);
        }
    }
    
    public function changeTab(idx                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(CURRENT_INDEX == idx))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(CURRENT_TAB != null))
        {
            CURRENT_TAB.closeTab();
            pane.clear();
        }
        
        CURRENT_INDEX = idx;
        CURRENT_TAB = TABS[idx];
        CURRENT_TAB.openTab();
        CURRENT_TAB.setValues();
        LAST_INDEX = idx;
        
        // update buttons
        for (tabButton in as3hx.Compat.iter(TAB_BUTTONS))
        {
            tabButton.setActive(tabButton.index == idx);
        }
    }
    
    private function e_tabHandler(e                       : Dynamic) : Void
    {
        changeTab((try cast(e.currentTarget, TabButton) catch(e:Dynamic) null).index);
    }
    
    private function e_clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == btn_close))
        {
            removePopup();
            return;
        }
    }
    
    private function e_mouseWheelMoved(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        var dist                       : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function e_scrollBarMoved(e                       : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
    
    public function updateScrollPane() : Void
    {
        pane.scrollTo(0);
        scrollbar.scrollTo(0);
        
        scrollbar.visible = pane.doScroll;
    }
    
    public function e_replayEntryClick(e                       : Dynamic) : Void
    {
        var te                       : Dynamic= e.target;
        if (as3hx.Compat.truthy(Std.is(te, SimpleBoxButton)))
        {
            var target                       : Dynamic= try cast(te, SimpleBoxButton) catch(e:Dynamic) null;
            var entry                       : Dynamic= try cast(target.parent, ReplayHistoryEntry) catch(e:Dynamic) null;
            var replay                       : Dynamic= CURRENT_TAB.prepareReplay(entry.replay);
            
            if (as3hx.Compat.truthy(replay == null))
            {
                return;
            }
            
            if (as3hx.Compat.truthy(target == entry.btn_play))
            {
                if (as3hx.Compat.truthy(replay.song == null))
                {
                    Alert.add(_lang.string("popup_replay_missing_song_data"), 120, Alert.RED);
                    return;
                }
                
                if (as3hx.Compat.truthy(replay.isFileLoader))
                {
                    var chartLoaded                       : Dynamic= true;
                    if (as3hx.Compat.truthy(_gvars.externalSongInfo == null || _gvars.externalSongInfo.engine == null || _gvars.externalSongInfo.engine.cache_id != replay.cacheID))
                    {
                        chartLoaded = FileLoader.setupLocalFile(replay.chartPath, replay.settings.arc_engine.chartID);
                    }
                    
                    replay.song = _gvars.externalSongInfo;
                    
                    if (as3hx.Compat.truthy(!chartLoaded))
                    {
                        Alert.add(_lang.string("popup_replay_file_browser_replays"), 120, Alert.RED);
                        return;
                    }
                }
                
                if (as3hx.Compat.truthy(!replay.user.isLoaded()))
                {
                    replay.user.loadUser(replay.user.siteId);
                }
                
                _gvars.options = new GameOptions();
                _gvars.options.isolation = false;
                _gvars.options.replay = replay;
                _gvars.options.fillFromReplay();
                
                if (as3hx.Compat.truthy(!useReplayLayout || _gvars.options.layout == null))
                {
                    _gvars.options.layout = Reflect.field(_gvars.playerUser.gameLayout, "sp");
                }
                
                _gvars.songResults.length = 0;
                _gvars.songQueue = [replay.song];
                
                _gvars.gameMain.removePopup();
                
                _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
            }
            
            if (as3hx.Compat.truthy(target == entry.btn_copy))
            {
                var replayString                       : Dynamic= replay.getEncode();
                var success                       : Dynamic= SystemUtil.setClipboard(replayString);
                if (as3hx.Compat.truthy(success))
                {
                    Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
                }
                else
                {
                    Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
                }
            }
        }
    }
    
    private function e_searchChange(e                       : Dynamic) : Void
    {
        _search_text = search_field.text.toLowerCase();
        search_field_placeholder.visible = (_search_text.length <= 0);
        CURRENT_TAB.setValues();
    }
    
    private function get_searchText() : String
    {
        return _search_text;
    }
    
    private function e_replayOptions(e                       : Dynamic) : Void
    {
        var prompt                       : Dynamic= new Prompt(this, 300, 150);
        prompt.content.graphics.moveTo(10, 40);
        prompt.content.graphics.lineTo(prompt.width - 9, 40);
        
        //- Add Text
        var _text                       : Dynamic= new Text(prompt, 9, 10, _lang.string("popup_replay_settings_title"), 16);
        _text.setAreaParams(prompt.width - 45, 22);
        
        //- Add Close Button
        var _close_button                       : Dynamic= new BoxIcon(prompt, prompt.width - 32, 10, 22, 22, new IconClose(), closePrompt);
        
        var cy                       : Dynamic= 47;
        
        var checkUseReplayLayout                       : Dynamic= new BoxCheck(prompt, 10 + 3, cy + 3, e_changeHandler);
        checkUseReplayLayout.checked = useReplayLayout;
        new Text(prompt, 30, cy, _lang.string("popup_replay_settings_use_layout"));
        cy += 22;
        
        e_changeHandler = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(e.target == checkUseReplayLayout))
            {
                checkUseReplayLayout.checked = !checkUseReplayLayout.checked;
                useReplayLayout = checkUseReplayLayout.checked;
                LocalOptions.setVariable("replay_layout", useReplayLayout);
            }
        }
        
        closePrompt = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(prompt.parent))
            {
                prompt.parent.removeChild(prompt);
            }
        }
    }
}




class TabButton extends Sprite
{
    private static var e_changeHandler                    : Dynamic;
    private static var closePrompt                    : Dynamic;
    public var index                       : Dynamic;
    
    private var text                       : Dynamic;
    private var button                       : Dynamic;
    private var chevron                       : Dynamic;
    
    private var active                       : Dynamic= false;
    
    private var hasTopBorder                       : Dynamic= false;
    
    @:allow(popups.replays)
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
