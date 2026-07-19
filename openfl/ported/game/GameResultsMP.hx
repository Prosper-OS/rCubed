package game;

import assets.menu.icons.fa.IconPhoto;
import assets.menu.icons.fa.IconVideo;
import classes.Language;
import classes.SongInfo;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCFFRGameStateChange;
import classes.mp.mode.ffr.MPMatchResultsFFR;
import classes.mp.room.MPRoomFFR;
import classes.score.ScoreHandler;
import classes.score.ScoreHandlerEvent;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.ui.Keyboard;
import openfl.utils.Timer;
import game.results.GameResultBackground;
import game.results.GameResultFFRView;
import game.results.GameResultSingleView;
import menu.MenuPanel;
import popups.PopupHighscores;

class GameResultsMP extends MenuPanel
{
    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    private static var _lang : Language = Language.instance;
    private static var _score : ScoreHandler = ScoreHandler.instance;
    private static var _mp : Multiplayer = Multiplayer.instance;
    
    // Multiplayer
    private var room : MPRoomFFR;
    
    // Results
    private var resultIndex : Int = 0;
    private var result : GameScoreResult;
    
    private var songInfo : SongInfo;
    private var matchResults : MPMatchResultsFFR;
    
    private var background : GameResultBackground;
    private var singleResult : GameResultSingleView;
    private var overviewResult : GameResultFFRView;
    
    // Title Bar
    private var navSaveReplay : BoxIcon;
    private var navScreenShot : BoxIcon;
    
    // Game Result
    private var navBack : BoxButton;
    
    // Menu Bar
    private var navOptions : BoxButton;
    private var navHighscores : BoxButton;
    private var navMenu : BoxButton;
    private var navEnableTimer : Timer;
    
    public function new(myParent : MenuPanel)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    // Get MP Results
    {
        
        room = try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
        if (room.lastMatchIndex == -1)
        {
            matchResults = room.lastMatch;
        }
        else if (room.lastMatchIndex >= 0 && room.lastMatchIndex < room.lastMatchHistory.length)
        {
            matchResults = room.lastMatchHistory[room.lastMatchIndex];
        }
        
        return true;
    }
    
    //******************************************************************************************//
    // Panel Stage Functions
    //******************************************************************************************//
    
    override public function stageAdd() : Void
    // Score Update Handlers
    {
        
        _score.addEventListener(ScoreHandlerEvent.SUCCESS, e_onScoreResult);
        _score.addEventListener(ScoreHandlerEvent.FAILURE, e_onScoreResult);
        
        // Background
        background = new GameResultBackground();
        addChild(background);
        
        // Background Noise
        var noiseSource : BitmapData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x00000000);
        noiseSource.perlinNoise(Main.GAME_WIDTH, Main.GAME_HEIGHT, 12, Math.round(haxe.Timer.stamp() * 1000), true, false, 7, true);
        var noiseImage : Bitmap = new Bitmap(noiseSource);
        noiseImage.alpha = 0.15;
        background.addChild(noiseImage);
        
        if (matchResults != null)
        {
            overviewResult = new GameResultFFRView(room, matchResults, e_onScoreClick);
            addChild(overviewResult);
            
            songInfo = matchResults.songInfo;
        }
        else
        {
            songInfo = room.lastMatchScorePersonal.songInfo;
        }
        
        singleResult = new GameResultSingleView();
        addChild(singleResult);
        
        // Main Navigation Buttons
        var buttonMenu : Sprite = new Sprite();
        var buttonMenuItems : Array<Dynamic> = [];
        buttonMenu.x = 22;
        buttonMenu.y = 428;
        this.addChild(buttonMenu);
        
        navOptions = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_options"), 17, eventHandler);
        buttonMenuItems.push(navOptions);
        
        navHighscores = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_highscores"), 17, eventHandler);
        buttonMenuItems.push(navHighscores);
        
        navMenu = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_exit_menu"), 17, eventHandler);
        buttonMenuItems.push(navMenu);
        
        var BUTTON_GAP : Int = 11;
        var BUTTON_WIDTH : Int = as3hx.Compat.parseInt((735 - (Math.max(0, buttonMenuItems.length - 1) * BUTTON_GAP)) / buttonMenuItems.length);
        for (bx in 0...buttonMenuItems.length)
        {
            buttonMenuItems[bx].width = BUTTON_WIDTH;
            buttonMenuItems[bx].x = BUTTON_WIDTH * bx + BUTTON_GAP * bx;
        }
        
        // Song Results Buttons
        navScreenShot = new BoxIcon(this, 522, 6, 32, 32, new IconPhoto(), eventHandler);
        navScreenShot.setIconColor("#E2FEFF");
        navScreenShot.setHoverText(_lang.string("game_results_queue_save_screenshot_clipboard_hint"), "bottom");
        
        navSaveReplay = new BoxIcon(this, 485, 6, 32, 32, new IconVideo(), eventHandler);
        navSaveReplay.setIconColor("#E2FEFF");
        navSaveReplay.setHoverText(_lang.string("game_results_queue_save_replay"), "bottom");
        
        // Song Results
        navBack = new BoxButton(this, 18, 62, 90, 32, _lang.string("game_results_mp_back"), 12, eventHandler);
        
        // Display Game Result
        displayGameResult(!(matchResults != null) ? -2 : -1);
        
        _gvars.gameMain.displayPopupQueue();
        
        // Add keyboard navigation
        stage.addEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
        
        // Add Mouse Move for graphs
        stage.addEventListener(MouseEvent.MOUSE_MOVE, e_mouseMove);
        
        // Return to Multiplayer Menu
        Flags.VALUES[Flags.MP_MENU_RETURN] = true;
        
        // Enable Menu after 1 second.
        if (room.lastMatchIndex == -1)
        {
            navOptions.enabled = navMenu.enabled = navHighscores.enabled = false;
            navEnableTimer = new Timer(1000);
            navEnableTimer.addEventListener(TimerEvent.TIMER, e_navEnable);
            navEnableTimer.start();
        }
    }
    
    override public function stageRemove() : Void
    {
        if (room.lastMatchIndex < 0)
        {
            _mp.sendCommand(new MPCFFRGameStateChange(room, "menu"));
        }
        
        // Remove Score Events
        _score.removeEventListener(ScoreHandlerEvent.SUCCESS, e_onScoreResult);
        _score.removeEventListener(ScoreHandlerEvent.FAILURE, e_onScoreResult);
        
        // Remove keyboard navigation
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
        
        // Remove Mouse Move for graphs
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, e_mouseMove);
        
        super.stageRemove();
    }
    
    private function e_mouseMove(e : MouseEvent) : Void
    {
        if (singleResult != null && singleResult.visible)
        {
            singleResult.e_graphHover(e);
        }
    }
    
    private function e_onScoreClick(index : Float) : Void
    {
        displayGameResult(index);
    }
    
    private function e_onScoreResult(e : ScoreHandlerEvent) : Void
    {
        if (singleResult != null && singleResult.visible)
        {
            singleResult.onScoreResult(e);
        }
        
        // Display Popup Queue
        _gvars.gameMain.displayPopupQueue();
    }
    
    private function e_navEnable(e : TimerEvent) : Void
    {
        navOptions.enabled = navMenu.enabled = true;
        navHighscores.enabled = songInfo && !songInfo.engine;
    }
    
    //******************************************************************************************//
    // Results Display Logic
    //******************************************************************************************//
    
    public function displayGameResult(gameIndex : Int) : Void
    // Set Index
    {
        
        resultIndex = gameIndex;
        
        // Single Score - Skipped
        if (gameIndex == -2)
        {
            singleResult.visible = true;
            navBack.visible = false;
            
            result = room.lastMatchScorePersonal;
            
            // Save Replay Button
            navSaveReplay.enabled = _score.canSendScore(result, true, false, true, true);
            
            // Update
            singleResult.update(result);
        }
        // Score Overview
        else if (gameIndex == -1)
        {
            navSaveReplay.enabled = false;
            overviewResult.visible = true;
            singleResult.visible = false;
            navBack.visible = false;
        }
        // Single Score
        else if (resultIndex >= 0 && resultIndex < matchResults.users.length)
        {
            overviewResult.visible = false;
            singleResult.visible = true;
            navBack.visible = true;
            
            result = matchResults.users[resultIndex].score;
            
            // Save Replay Button
            navSaveReplay.enabled = _score.canSendScore(result, true, false, true, true);
            
            // Update
            singleResult.update(result);
        }
        
        // Highscores
        navHighscores.enabled = songInfo && !songInfo.engine;
    }
    
    //******************************************************************************************//
    // Event Handlers
    //******************************************************************************************//
    
    /**
     * Handles all UI events, both mouse and keyboard.
     * @param e
     */
    private function eventHandler(e : Dynamic = null) : Void
    {
        var target : DisplayObject = e.target;
        
        // Don't do anything with popups open.
        if (_gvars.gameMain.current_popup != null)
        {
            return;
        }
        
        // Handle Key events and click in the same function
        if (e.type == "keyDown")
        {
            target = null;
            var keyCode : Int = e.keyCode;
            if ((keyCode == _gvars.playerUser.keyLeft || keyCode == Keyboard.LEFT) && navBack.visible)
            {
                target = navBack;
            }
            else if (keyCode == _gvars.playerUser.keyQuit)
            {
                target = navMenu;
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
            }
        }
        
        if (target == null)
        {
            return;
        }
        
        // Based on target
        if (target == navSaveReplay)
        {
            if (result.user.siteId == _gvars.activeUser.siteId)
            {
                _score.saveServerReplay(result);
            }
        }
        else if (target == navScreenShot)
        {
            navScreenShot.purgeHoverSprite();
            if (e.ctrlKey)
            {
                _gvars.saveScreenshotToClipboard();
            }
            else
            {
                var ext : String = "";
                if (resultIndex >= 0)
                {
                    ext = result.screenshot_path;
                }
                _gvars.takeScreenShot(ext);
            }
        }
        else if (target == navBack)
        {
            displayGameResult(-1);
        }
        else if (target == navOptions)
        {
            addPopup(Main.POPUP_OPTIONS);
        }
        else if (target == navHighscores)
        {
            addPopup(new PopupHighscores(this, songInfo));
        }
        else if (target == navMenu)
        {
            switchTo(Main.GAME_MENU_PANEL);
        }
    }
}

