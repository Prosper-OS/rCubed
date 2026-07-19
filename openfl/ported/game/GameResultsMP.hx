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
    private static var _gvars                       : Dynamic= GlobalVariables.instance;
    private static var _lang                       : Dynamic= Language.instance;
    private static var _score                       : Dynamic= ScoreHandler.instance;
    private static var _mp                       : Dynamic= Multiplayer.instance;
    
    // Multiplayer
    private var room                       : Dynamic;
    
    // Results
    private var resultIndex                       : Dynamic= 0;
    private var result                       : Dynamic;
    
    private var songInfo                       : Dynamic;
    private var matchResults                       : Dynamic;
    
    private var background                       : Dynamic;
    private var singleResult                       : Dynamic;
    private var overviewResult                       : Dynamic;
    
    // Title Bar
    private var navSaveReplay                       : Dynamic;
    private var navScreenShot                       : Dynamic;
    
    // Game Result
    private var navBack                       : Dynamic;
    
    // Menu Bar
    private var navOptions                       : Dynamic;
    private var navHighscores                       : Dynamic;
    private var navMenu                       : Dynamic;
    private var navEnableTimer                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    // Get MP Results
    {
        
        room = try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
        if (as3hx.Compat.truthy(room.lastMatchIndex == -1))
        {
            matchResults = room.lastMatch;
        }
        else if (as3hx.Compat.truthy(room.lastMatchIndex >= 0 && room.lastMatchIndex < room.lastMatchHistory.length))
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
        var noiseSource                       : Dynamic= new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x00000000);
        noiseSource.perlinNoise(Main.GAME_WIDTH, Main.GAME_HEIGHT, 12, Math.round(haxe.Timer.stamp() * 1000), true, false, 7, true);
        var noiseImage                       : Dynamic= new Bitmap(noiseSource);
        noiseImage.alpha = 0.15;
        background.addChild(noiseImage);
        
        if (as3hx.Compat.truthy(matchResults != null))
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
        var buttonMenu                       : Dynamic= new Sprite();
        var buttonMenuItems                       : Dynamic= [];
        buttonMenu.x = 22;
        buttonMenu.y = 428;
        this.addChild(buttonMenu);
        
        navOptions = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_options"), 17, eventHandler);
        buttonMenuItems.push(navOptions);
        
        navHighscores = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_highscores"), 17, eventHandler);
        buttonMenuItems.push(navHighscores);
        
        navMenu = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_exit_menu"), 17, eventHandler);
        buttonMenuItems.push(navMenu);
        
        var BUTTON_GAP                       : Dynamic= 11;
        var BUTTON_WIDTH                       : Dynamic= as3hx.Compat.parseInt((735 - (Math.max(0, buttonMenuItems.length - 1) * BUTTON_GAP)) / buttonMenuItems.length);
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
        Reflect.setField(Flags.VALUES, Flags.MP_MENU_RETURN, true);
        
        // Enable Menu after 1 second.
        if (as3hx.Compat.truthy(room.lastMatchIndex == -1))
        {
            navOptions.enabled = navMenu.enabled = navHighscores.enabled = false;
            navEnableTimer = new Timer(1000);
            navEnableTimer.addEventListener(TimerEvent.TIMER, e_navEnable);
            navEnableTimer.start();
        }
    }
    
    override public function stageRemove() : Void
    {
        if (as3hx.Compat.truthy(room.lastMatchIndex < 0))
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
    
    private function e_mouseMove(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(singleResult != null && singleResult.visible))
        {
            singleResult.e_graphHover(e);
        }
    }
    
    private function e_onScoreClick(index                       : Dynamic) : Void
    {
        displayGameResult(index);
    }
    
    private function e_onScoreResult(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(singleResult != null && singleResult.visible))
        {
            singleResult.onScoreResult(e);
        }
        
        // Display Popup Queue
        _gvars.gameMain.displayPopupQueue();
    }
    
    private function e_navEnable(e                       : Dynamic) : Void
    {
        navOptions.enabled = navMenu.enabled = true;
        navHighscores.enabled = songInfo && !songInfo.engine;
    }
    
    //******************************************************************************************//
    // Results Display Logic
    //******************************************************************************************//
    
    public function displayGameResult(gameIndex                       : Dynamic) : Void
    // Set Index
    {
        
        resultIndex = gameIndex;
        
        // Single Score - Skipped
        if (as3hx.Compat.truthy(gameIndex == -2))
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
        else if (as3hx.Compat.truthy(gameIndex == -1))
        {
            navSaveReplay.enabled = false;
            overviewResult.visible = true;
            singleResult.visible = false;
            navBack.visible = false;
        }
        // Single Score
        else if (as3hx.Compat.truthy(resultIndex >= 0 && resultIndex < matchResults.users.length))
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
    private function eventHandler(e                       : Dynamic= null) : Void
    {
        var target                       : Dynamic= e.target;
        
        // Don't do anything with popups open.
        if (as3hx.Compat.truthy(_gvars.gameMain.current_popup != null))
        {
            return;
        }
        
        // Handle Key events and click in the same function
        if (as3hx.Compat.truthy(e.type == "keyDown"))
        {
            target = null;
            var keyCode                       : Dynamic= e.keyCode;
            if (as3hx.Compat.truthy((keyCode == _gvars.playerUser.keyLeft || keyCode == Keyboard.LEFT) && navBack.visible))
            {
                target = navBack;
            }
            else if (as3hx.Compat.truthy(keyCode == _gvars.playerUser.keyQuit))
            {
                target = navMenu;
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
            }
        }
        
        if (as3hx.Compat.truthy(target == null))
        {
            return;
        }
        
        // Based on target
        if (as3hx.Compat.truthy(target == navSaveReplay))
        {
            if (as3hx.Compat.truthy(result.user.siteId == _gvars.activeUser.siteId))
            {
                _score.saveServerReplay(result);
            }
        }
        else if (as3hx.Compat.truthy(target == navScreenShot))
        {
            navScreenShot.purgeHoverSprite();
            if (as3hx.Compat.truthy(e.ctrlKey))
            {
                _gvars.saveScreenshotToClipboard();
            }
            else
            {
                var ext                       : Dynamic= "";
                if (as3hx.Compat.truthy(resultIndex >= 0))
                {
                    ext = result.screenshot_path;
                }
                _gvars.takeScreenShot(ext);
            }
        }
        else if (as3hx.Compat.truthy(target == navBack))
        {
            displayGameResult(-1);
        }
        else if (as3hx.Compat.truthy(target == navOptions))
        {
            addPopup(Main.POPUP_OPTIONS);
        }
        else if (as3hx.Compat.truthy(target == navHighscores))
        {
            addPopup(new PopupHighscores(this, songInfo));
        }
        else if (as3hx.Compat.truthy(target == navMenu))
        {
            switchTo(Main.GAME_MENU_PANEL);
        }
    }
}

