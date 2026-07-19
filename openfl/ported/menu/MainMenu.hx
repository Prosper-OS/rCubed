package menu;

import arc.ArcGlobals;
import assets.GameBackgroundColor;
import assets.menu.Logo;
import assets.menu.MainMenuBackground;
import assets.menu.icons.fa.IconDelete;
import assets.menu.icons.fa.IconPause;
import assets.menu.icons.fa.IconPlay;
import assets.menu.icons.fa.IconStop;
import classes.Alert;
import classes.Language;
import classes.ui.Box;
import classes.ui.BoxIcon;
import classes.ui.IconUtil;
import classes.ui.MouseTooltip;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;
import classes.ui.Throbber;
import com.flashfla.net.WebRequest;
import com.flashfla.utils.NumberUtil;
import com.flashfla.utils.SystemUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.ui.ContextMenu;
import openfl.ui.ContextMenuItem;
import popups.PopupFileBrowser;
import popups.PopupFilterManager;
import popups.PopupSkillRankUpdate;
import popups.replays.ReplayHistoryWindow;

class MainMenu extends MenuPanel
{
    public static inline var MENU_SONGSELECTION : String = "MenuSongSelection";
    public static inline var MENU_MULTIPLAYER : String = "MenuMultiplayer";
    public static inline var MENU_TOKENS : String = "MenuTokens";
    public static inline var MENU_FILTERS : String = "MenuFilter";
    public static inline var MENU_REPLAYS : String = "MenuReplays";
    public static inline var MENU_LOCAL : String = "MenuLocal";
    public static inline var MENU_OPTIONS : String = "MenuOptions";
    
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    public var _MenuSingleplayer : MenuPanel;
    private static var _MenuMultiplayer : MenuPanel;
    private var _MenuTokens : MenuPanel;
    
    private var hover_message : MouseTooltip;
    private var user_text : Text;
    private var menuItemBox : Sprite;
    private var logo : Logo;
    
    public var menuMusicControls : Box;
    private var mmc_icons(default, never) : Array<Dynamic> = [new IconPlay(), new IconPause(), new IconStop(), new IconDelete()];
    private var mmc_functions(default, never) : Array<Dynamic> = [playMusic, pauseMusic, stopMusic, deleteMusic];
    private var mmc_buttons : Array<Dynamic> = [];
    private var mmc_strings(default, never) : Array<Dynamic> = ["play", "pause", "stop", "remove"];
    
    private var statUpdaterBtn : SimpleBoxButton;
    private var rankUpdateThrobber : Throbber;
    
    public var menuItems : Array<Dynamic> = [["menu_play", MENU_SONGSELECTION, false, "iconPlay"], 
        ["menu_multiplayer", MENU_MULTIPLAYER, false, "iconUsers"], 
        ["menu_tokens", MENU_TOKENS, false, "iconMedal"], 
        ["menu_filters", MENU_FILTERS, true, "iconFilter"], 
        ["menu_replays", MENU_REPLAYS, true, "iconVideo"], 
        ["menu_local", MENU_LOCAL, true, "iconFolder"], 
        ["menu_options", MENU_OPTIONS, false, "iconGear"]
    ];
    
    public var panel : MenuPanel;
    public var activePanelID : Int = -1;
    
    ///- Constructor
    public function new(myParent : MenuPanel)
    {
        super(myParent);
        
        ArcGlobals.instance.resetConfig();
    }
    
    override public function init() : Bool
    //- Add Logo
    {
        
        logo = new Logo();
        logo.x = 18 + logo.width * 0.5;
        logo.y = 8 + logo.height * 0.5;
        logo.visible = LocalOptions.getVariable("menu_show_logo", true);
        this.addChild(logo);
        
        //- Add Menu Background
        var menu_bg : MainMenuBackground = new MainMenuBackground();
        menu_bg.x = 145;
        menu_bg.visible = LocalOptions.getVariable("menu_show_menu_background", true);
        this.addChild(menu_bg);
        
        //- Add Menu to Stage
        buildMenuItems();
        
        for (i in 0...mmc_strings.length)
        {
            var menu_music_button : BoxIcon = new BoxIcon(null, 5 + 30 * i, 5, 25, 25, mmc_icons[i], mmc_functions[i]);
            mmc_buttons[i] = menu_music_button;
        }
        
        //- Add Menu Music to Stage
        if (_gvars.menuMusic)
        {
            drawMenuMusicControls();
            if (!_gvars.menuMusic.isPlaying && !_gvars.menuMusic.userStopped)
            {
                _gvars.menuMusic.start();
            }
        }
        
        //- Add Main Panel to Stage
        if (Flags.VALUES[Flags.MP_MENU_RETURN] != null)
        {
            switchTo(MENU_MULTIPLAYER);
            Flags.VALUES[Flags.MP_MENU_RETURN] = false;
        }
        else
        {
            switchTo(MENU_SONGSELECTION);
        }
        return false;
    }
    
    override public function stageRemove() : Void
    {
        if (_MenuSingleplayer != null)
        {
            _MenuSingleplayer.stageRemove();
        }
        
        if (_MenuTokens != null)
        {
            _MenuTokens.stageRemove();
        }
        
        if (_MenuMultiplayer != null)
        {
            _MenuMultiplayer.stageRemove();
        }
        
        super.stageRemove();
    }
    
    override public function dispose() : Void
    {
        if (_MenuSingleplayer != null)
        {
            _MenuSingleplayer.dispose();
            if (this.contains(_MenuSingleplayer))
            {
                this.removeChild(_MenuSingleplayer);
            }
            _MenuSingleplayer = null;
        }
        if (_MenuTokens != null)
        {
            _MenuTokens.dispose();
            if (this.contains(_MenuTokens))
            {
                this.removeChild(_MenuTokens);
            }
            _MenuTokens = null;
        }
        if (_MenuMultiplayer != null)
        {
            if (this.contains(_MenuMultiplayer))
            {
                this.removeChild(_MenuMultiplayer);
            }
        }
        super.dispose();
    }
    
    override public function draw() : Void
    {
        buildMenuItems();
        panel.draw();
    }
    
    public function buildMenuItems() : Void
    {
        if (menuItemBox != null)
        {
            this.removeChild(menuItemBox);
            menuItemBox = null;
            
            this.removeChild(user_text);
            user_text = null;
        }
        
        //- User Info Display
        _gvars.activeUser.calculateAverageRank();
        user_text = new Text(this, 153, 452, sprintf(_lang.string("main_menu_userbar"), {
                            player_name : _gvars.activeUser.name,
                            games_played : NumberUtil.numberFormat(_gvars.activeUser.gamesPlayed),
                            grand_total : NumberUtil.numberFormat(_gvars.activeUser.grandTotal),
                            rank : NumberUtil.numberFormat(_gvars.activeUser.gameRank),
                            skill_level : _gvars.activeUser.skillLevel,
                            skill_rating : NumberUtil.numberFormat(_gvars.activeUser.skillRating, 2),
                            avg_rank : NumberUtil.numberFormat(_gvars.activeUser.averageRank, 3, true)
                        }));
        user_text.width = 594;
        user_text.height = 28;
        user_text.align = Text.CENTER;
        
        if (!_gvars.activeUser.isGuest)
        {
            statUpdaterBtn = new SimpleBoxButton(609, 28);
            statUpdaterBtn.x = 147;
            statUpdaterBtn.y = Main.GAME_HEIGHT - 28;
            statUpdaterBtn.addEventListener(MouseEvent.MOUSE_OVER, e_statUpdaterMouseOver);
            statUpdaterBtn.addEventListener(MouseEvent.CLICK, e_statUpdaterClick);
            this.addChild(statUpdaterBtn);
        }
        
        menuItemBox = new Sprite();
        menuItemBox.x = 145;
        menuItemBox.y = 8;
        
        //- Add Menu Buttons
        var i : Int;
        var btnLarge : Int = menuItems.length;
        
        for (i in 0...menuItems.length)
        {
            if (menuItems[i][2] != null)
            {
                btnLarge--;
            }
        }
        
        var btnWidth : Int = as3hx.Compat.parseInt((604 - ((menuItems.length - btnLarge) * 28) - (6 * (menuItems.length - 1))) / btnLarge);
        var btnPosition : Int = 0;
        
        for (i in 0...menuItems.length)
        {
            if (menuItems[i][2] != null)
            {
                var menuItemSmall : BoxIcon = new BoxIcon(menuItemBox, btnPosition, 0, 28, 28, IconUtil.getIcon(menuItems[i][3]), menuItemClick);
                menuItemSmall.panel = menuItems[i][1];
                menuItemSmall.setIconColor("#DDDDDD");
                menuItemSmall.setHoverText(_lang.string(menuItems[i][0]), "bottom");
                menuItemSmall.active = (i == activePanelID);
                btnPosition += as3hx.Compat.parseInt(28 + 6);
                
                // Filter - Set to Green if enabled.
                if (menuItems[i][1] == MENU_FILTERS && _gvars.activeFilter != null)
                {
                    menuItemSmall.setIconColor("#61ED42");
                    menuItemSmall.color = 0x61ED42;
                    menuItemSmall.borderColor = 0x61ED42;
                }
            }
            else
            {
                var menuItem : MenuButton = new MenuButton(menuItemBox, btnPosition, btnWidth, _lang.string(menuItems[i][0]), i == activePanelID, menuItemClick);
                menuItem.panel = menuItems[i][1];
                btnPosition += as3hx.Compat.parseInt(btnWidth + 6);
            }
        }
        
        this.addChild(menuItemBox);
    }
    
    public function drawMenuMusicControls() : Void
    {
        if (menuMusicControls == null)
        {
            menuMusicControls = new Box(null, 7, -1, false, false);
            menuMusicControls.setSize(125, 35);
            menuMusicControls.normalAlpha = 1;
            menuMusicControls.color = GameBackgroundColor.BG_STATIC;
            
            for (i in 0...mmc_strings.length)
            {
                menuMusicControls.addChildAt(mmc_buttons[i], i);
            }
            
            updateMenuMusicControls();
        }
        
        if (!contains(menuMusicControls))
        {
            addChild(menuMusicControls);
        }
    }
    
    public function updateMenuMusicControls() : Void
    {
        if (menuMusicControls != null)
        {
            for (i in 0...mmc_strings.length)
            {
                (try cast(menuMusicControls.getChildAt(i), BoxIcon) catch(e:Dynamic) null).setHoverText(_lang.string("main_menu_music_" + mmc_strings[i]), "bottom");
            }
            
            buildMenuMusicControlsContextMenu();
        }
    }
    
    private function buildMenuMusicControlsContextMenu() : Void
    // Context Menu Display song Playing
    {
        
        var musicContextMenu : ContextMenu = new ContextMenu();
        var musicContextMenuPlaying : ContextMenuItem = new ContextMenuItem(sprintf(_lang.stringSimple("main_menu_now_playing"), {
                    music_name : LocalStore.getVariable("menu_music", "Unknown")
                }), false, false);
        musicContextMenu.customItems.push(musicContextMenuPlaying);
        menuMusicControls.contextMenu = musicContextMenu;
    }
    
    private function playMusic(e : Event) : Void
    {
        if (_gvars.menuMusic && !_gvars.menuMusic.isPlaying)
        {
            _gvars.menuMusic.userStart();
        }
    }
    
    private function pauseMusic(e : Event) : Void
    {
        if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
        {
            _gvars.menuMusic.userPause();
        }
    }
    
    private function stopMusic(e : Event) : Void
    {
        if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
        {
            _gvars.menuMusic.userStop();
        }
    }
    
    private function deleteMusic(e : Event) : Void
    {
        if (_gvars.menuMusic)
        {
            _gvars.menuMusic.userStop();
            _gvars.menuMusic = null;
            menuMusicControls.parent.removeChild(menuMusicControls);
            
            AirContext.deleteFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
        }
    }
    
    override public function switchTo(_panel : String) : Bool
    //- Check Parent Function first.
    {
        
        if (super.switchTo(_panel))
        {
            if (panel != null)
            {
                panel.stageRemove();
                panel.parent.removeChild(panel);
                panel.dispose();
            }
            return true;
        }
        
        //- Do current panel.
        var isFound : Bool = false;
        var initValid : Bool = false;
        var doStageAddAnyway : Bool = false;
        
        if (_panel == MENU_OPTIONS)
        {
            addPopup(Main.POPUP_OPTIONS);
            return true;
        }
        else if (_panel == MENU_FILTERS)
        {
            addPopup(new PopupFilterManager(this));
            return true;
        }
        else if (_panel == MENU_REPLAYS)
        {
            addPopup(new ReplayHistoryWindow(this));
            return true;
        }
        else if (_panel == MENU_LOCAL)
        {
            addPopup(new PopupFileBrowser(this));
            return true;
        }
        
        // Remove Active Panel
        if (panel != null)
        {
            panel.stageRemove();
            panel.parent.removeChild(panel);
        }
        
        switch (_panel)
        {
            case MENU_SONGSELECTION:
                if (_MenuSingleplayer == null)
                {
                    _MenuSingleplayer = new MenuSongSelection(this);
                }
                panel = _MenuSingleplayer;
                activePanelID = 0;
                isFound = true;
            
            case MENU_MULTIPLAYER:
                if (_MenuMultiplayer == null)
                {
                    _MenuMultiplayer = new MenuMultiplayer(this);
                }
                else
                {
                    _MenuMultiplayer.my_Parent = this;
                }
                panel = _MenuMultiplayer;
                activePanelID = 1;
                isFound = true;
            
            case MENU_TOKENS:
                if (_MenuTokens == null)
                {
                    _MenuTokens = new MenuTokens(this);
                }
                panel = _MenuTokens;
                activePanelID = 2;
                isFound = true;
        }
        this.addChild(panel);
        
        if (panel.hasInit)
        {
            doStageAddAnyway = true;
        }
        
        if (!panel.hasInit)
        {
            initValid = panel.init();
            panel.hasInit = true;
        }
        
        if (initValid || doStageAddAnyway)
        {
            panel.stageAdd();
        }
        
        buildMenuItems();
        SystemUtil.gc();
        return isFound;
    }
    
    private function menuItemClick(e : MouseEvent = null) : Void
    {
        switchTo(e.target.panel);
    }
    
    private function e_statUpdaterMouseOver(e : Event) : Void
    {
        statUpdaterBtn.addEventListener(MouseEvent.MOUSE_OUT, e_statUpdaterMouseOut);
        displayToolTip(statUpdaterBtn.x + (statUpdaterBtn.width / 2), statUpdaterBtn.y - 25, _lang.string("menu_update_stat_over"));
    }
    
    private function e_statUpdaterMouseOut(e : Event) : Void
    {
        statUpdaterBtn.removeEventListener(MouseEvent.MOUSE_OUT, e_statUpdaterMouseOut);
        removeChild(hover_message);
    }
    
    private function displayToolTip(tx : Float, ty : Float, text : String, align : String = "center") : Void
    {
        if (hover_message == null)
        {
            hover_message = new MouseTooltip("", 500);
        }
        hover_message.message = text;
        
        switch (align)
        {
            /* covers case "left": */
            default:
                hover_message.x = tx;
                hover_message.y = ty;
            case "right":
                hover_message.x = tx - hover_message.width;
                hover_message.y = ty;
            case "center":
                hover_message.x = tx - (hover_message.width / 2);
                hover_message.y = ty;
        }
        
        addChild(hover_message);
    }
    
    private function e_statUpdaterClick(e : MouseEvent) : Void
    {
        if (rankUpdateThrobber == null)
        {
            rankUpdateThrobber = new Throbber(16, 16, 2);
            rankUpdateThrobber.x = Main.GAME_WIDTH - 48;
            rankUpdateThrobber.y = Main.GAME_HEIGHT - 22;
            rankUpdateThrobber.visible = false;
            this.addChild(rankUpdateThrobber);
        }
        if (rankUpdateThrobber.running)
        {
            return;
        }
        
        var wr : WebRequest = new WebRequest(URLs.resolve(URLs.USER_RANKS_UPDATE_URL), c_rankComplete, c_rankFail);
        wr.load({
                    session : _gvars.userSession
                });
        rankUpdateThrobber.visible = true;
        rankUpdateThrobber.start();
        
        var c_rankComplete : Dynamic->Void = function(e : Dynamic = null) : Void
        {
            var resp : Dynamic = haxe.Json.parse(e.target.data);
            if (Std.is(_gvars.gameMain.activePanel, MainMenu))
            {
                _gvars.gameMain.addPopup(new PopupSkillRankUpdate(_gvars.gameMain, resp), true);
                rankUpdateThrobber.stop();
                rankUpdateThrobber.visible = false;
            }
        }
        
        var c_rankFail : Dynamic->Void = function(e : Dynamic) : Void
        {
            Alert.add(_lang.string("skill_rank_update_fail"), 90, Alert.RED);
            if (Std.is(_gvars.gameMain.activePanel, MainMenu))
            {
                rankUpdateThrobber.stop();
                rankUpdateThrobber.visible = false;
            }
        }
    }
}

