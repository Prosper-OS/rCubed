package game;

import assets.menu.icons.fa.IconPhoto;
import assets.menu.icons.fa.IconRandom;
import assets.menu.icons.fa.IconVideo;
import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.score.ScoreHandler;
import classes.score.ScoreHandlerEvent;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.StarSelector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import game.results.GameResultBackground;
import game.results.GameResultSingleView;
import menu.MenuPanel;
import popups.PopupHighscores;
import popups.PopupSongNotes;

class GameResults extends MenuPanel
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _playlist                       : Dynamic= Playlist.instance;
    private var _score                       : Dynamic= ScoreHandler.instance;
    
    // Results
    private var resultIndex                       : Dynamic= 0;
    private var songResults                       : Dynamic;
    private var result                       : Dynamic;
    
    private var queueTotalResult                       : Dynamic;
    
    private var background                       : Dynamic;
    private var resultsDisplay                       : Dynamic;
    
    // Title Bar
    private var navSaveReplay                       : Dynamic;
    private var navScreenShot                       : Dynamic;
    private var navRandomSong                       : Dynamic;
    
    // Game Result
    private var navRating                       : Dynamic;
    private var navPrev                       : Dynamic;
    private var navNext                       : Dynamic;
    
    // Menu Bar
    private var navReplay                       : Dynamic;
    private var navOptions                       : Dynamic;
    private var navHighscores                       : Dynamic;
    private var navMenu                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        songResults = _gvars.songResults.concat();
        
        // Send last score
        if (as3hx.Compat.truthy(!_gvars.options.replay))
        {
            var lastResult                       : Dynamic= songResults[as3hx.Compat.parseInt(songResults.length - 1)];
            
            // Update Judge Offset
            updateJudgeOffset(lastResult);
            
            if (as3hx.Compat.truthy(_gvars.songQueue.length == 0))
            {
                _score.addEventListener(ScoreHandlerEvent.SUCCESS, e_onScoreResult);
                _score.addEventListener(ScoreHandlerEvent.FAILURE, e_onScoreResult);
            }
            _score.sendScore(lastResult);
            _score.saveLocalReplay(lastResult);
        }
        
        // More songs to play, jump to gameplay or loading.
        if (as3hx.Compat.truthy(_gvars.songQueue.length > 0))
        {
            _gvars.options.song = null;
            switchTo(GameMenu.GAME_LOADING);
            return false;
        }
        else
        {
            _gvars.songResults.length = 0;
        }
        return true;
    }
    
    //******************************************************************************************//
    // Panel Stage Functions
    //******************************************************************************************//
    
    override public function stageAdd() : Void
    // Background
    {
        
        background = new GameResultBackground();
        addChild(background);
        
        // Background Noise
        var noiseSource                       : Dynamic= new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x00000000);
        noiseSource.perlinNoise(Main.GAME_WIDTH, Main.GAME_HEIGHT, 12, Math.round(haxe.Timer.stamp() * 1000), true, false, 7, true);
        var noiseImage                       : Dynamic= new Bitmap(noiseSource);
        noiseImage.alpha = 0.15;
        background.addChild(noiseImage);
        
        resultsDisplay = new GameResultSingleView();
        addChild(resultsDisplay);
        
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
        
        navReplay = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_replay_song"), 17, eventHandler);
        buttonMenuItems.push(navReplay);
        
        navMenu = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_exit_menu"), 17, eventHandler);
        buttonMenuItems.push(navMenu);
        
        var BUTTON_GAP                       : Dynamic= 11;
        var BUTTON_WIDTH                       : Dynamic= as3hx.Compat.parseInt((735 - (Math.max(0, buttonMenuItems.length - 1) * BUTTON_GAP)) / buttonMenuItems.length);
        for (bx in 0...buttonMenuItems.length)
        {
            buttonMenuItems[bx].width = BUTTON_WIDTH;
            buttonMenuItems[bx].x = BUTTON_WIDTH * bx + BUTTON_GAP * bx;
        }
        
        // Song Notes / Star Rating Button
        navRating = new Sprite();
        navRating.buttonMode = true;
        navRating.mouseChildren = false;
        navRating.addEventListener(MouseEvent.CLICK, eventHandler);
        StarSelector.drawStar(navRating.graphics, 18, 0, 0, true, 0xF2D60D, 1);
        resultsDisplay.addChild(navRating);
        
        // Song Results Buttons
        navScreenShot = new BoxIcon(this, 522, 6, 32, 32, new IconPhoto(), eventHandler);
        navScreenShot.setIconColor("#E2FEFF");
        navScreenShot.setHoverText(_lang.string("game_results_queue_save_screenshot_clipboard_hint"), "bottom");
        
        navSaveReplay = new BoxIcon(this, 485, 6, 32, 32, new IconVideo(), eventHandler);
        navSaveReplay.setIconColor("#E2FEFF");
        navSaveReplay.setHoverText(_lang.string("game_results_queue_save_replay"), "bottom");
        
        navRandomSong = new BoxIcon(this, 448, 6, 32, 32, new IconRandom(), eventHandler);
        navRandomSong.setIconColor("#E2FEFF");
        navRandomSong.setHoverText(_lang.string("game_results_play_random_song"), "bottom");
        
        // Song Results - Song Queue
        navPrev = new BoxButton(this, 18, 62, 90, 32, _lang.string("game_results_queue_previous"), 12, eventHandler);
        navNext = new BoxButton(this, 672, 62, 90, 32, _lang.string("game_results_queue_next"), 12, eventHandler);
        
        // Build Queue Total
        buildQueueTotal();
        
        // Display Game Result
        displayGameResult((songResults.length > 1) ? -1 : 0);
        
        _gvars.gameMain.displayPopupQueue();
        
        // Add keyboard navigation
        stage.addEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
        
        // Add Mouse Move for graphs
        stage.addEventListener(MouseEvent.MOUSE_MOVE, resultsDisplay.e_graphHover);
    }
    
    override public function stageRemove() : Void
    // Remove Score Events
    {
        
        _score.removeEventListener(ScoreHandlerEvent.SUCCESS, e_onScoreResult);
        _score.removeEventListener(ScoreHandlerEvent.FAILURE, e_onScoreResult);
        
        // Remove keyboard navigation
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
        
        // Remove Mouse Move for graphs
        if (as3hx.Compat.truthy(resultsDisplay != null))
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, resultsDisplay.e_graphHover);
        }
        
        super.stageRemove();
    }
    
    private function e_onScoreResult(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(resultsDisplay != null))
        {
            resultsDisplay.onScoreResult(e);
            
            // Display Popup Queue
            _gvars.gameMain.displayPopupQueue();
        }
    }
    
    //******************************************************************************************//
    // Results Display Logic
    //******************************************************************************************//
    public function buildQueueTotal() : Void
    {
        if (as3hx.Compat.truthy(songResults.length <= 1))
        {
            return;
        }
        
        var songSubTitle                       : Dynamic= "";
        
        queueTotalResult = new GameScoreResult();
        queueTotalResult.game_index = -1;
        queueTotalResult.user = songResults[0].user;
        queueTotalResult.options = songResults[0].options;
        queueTotalResult.replay_hit = [];
        queueTotalResult.score_total = 0;
        
        queueTotalResult.songInfo = new SongInfo();
        queueTotalResult.songInfo.order = songResults.length;
        
        for (x in 0...songResults.length)
        {
            var tempResult                       : Dynamic= songResults[x];
            
            songSubTitle += tempResult.songInfo.name + ", ";
            
            queueTotalResult.note_count += tempResult.note_count;
            queueTotalResult.amazing += tempResult.amazing;
            queueTotalResult.perfect += tempResult.perfect;
            queueTotalResult.good += tempResult.good;
            queueTotalResult.average += tempResult.average;
            queueTotalResult.miss += tempResult.miss;
            queueTotalResult.boo += tempResult.boo;
            queueTotalResult.score += tempResult.score;
            queueTotalResult.credits += tempResult.credits;
            queueTotalResult.restarts += tempResult.restarts;
            
            // Replay Graph
            for (y in 0...tempResult.replay_hit.length)
            {
                queueTotalResult.replay_hit.push(tempResult.replay_hit[y]);
            }
            
            // Score Total
            queueTotalResult.score_total += tempResult.score_total;
        }
        queueTotalResult.update(_gvars);
        
        queueTotalResult.max_combo = getMaxCombo(queueTotalResult);
        
        queueTotalResult.songInfo.name = songSubTitle.substr(0, songSubTitle.length - 2);
    }
    
    public function displayGameResult(gameIndex                       : Dynamic) : Void
    // Set Index
    {
        
        resultIndex = gameIndex;
        
        // Buttons
        navScreenShot.enabled = false;
        navSaveReplay.enabled = false;
        navPrev.visible = false;
        navNext.visible = false;
        
        if (as3hx.Compat.truthy(songResults.length > 1))
        {
            if (as3hx.Compat.truthy(gameIndex > -1))
            {
                navPrev.visible = true;
                navPrev.text = ((gameIndex == 0) ? _lang.string("game_results_queue_total") : _lang.string("game_results_queue_previous"));
            }
            if (as3hx.Compat.truthy(gameIndex < songResults.length - 1))
            {
                navNext.visible = true;
            }
        }
        
        // Song Results
        // Song Queue (Multiple Songs)
        if (as3hx.Compat.truthy(gameIndex == -1))
        {
            navHighscores.enabled = false;
            result = queueTotalResult;
        }
        // Single Song
        else
        {
            
            {
                navHighscores.enabled = true;
                result = songResults[resultIndex];
                
                // Song Notes / Star
                navRating.visible = (result.songInfo != null);
                
                // Highscores
                if (as3hx.Compat.truthy(result.songInfo && result.songInfo.engine))
                {
                    navHighscores.enabled = false;
                }
                
                // Save Replay Button
                navSaveReplay.enabled = true;
                if (as3hx.Compat.truthy(!_score.canSendScore(result, true, false, true, true) || result.is_preview))
                {
                    navSaveReplay.enabled = false;
                }
            }
        }
        
        // Save Screenshot
        if (as3hx.Compat.truthy(!result.is_preview))
        {
            navScreenShot.enabled = true;
        }
        
        // Random Song Button
        if (as3hx.Compat.truthy(result.options.replay || result.is_preview))
        {
            navRandomSong.enabled = false;
        }
        
        // Update
        resultsDisplay.update(result);
        
        // Align Rating Star to Song Title
        navRating.x = resultsDisplay.songName.x + resultsDisplay.songName.textfield.x - 22;
        navRating.y = resultsDisplay.songName.y + 5;
    }
    
    //******************************************************************************************//
    // Helper Functions
    //******************************************************************************************//
    
    /**
     * Handles Auto Judge Offset options by changing the judge offset and saving
     * the user settings. This is called when scores are saved successfully.
     * @param result GameScoreResult
     */
    private function updateJudgeOffset(result                       : Dynamic) : Void
    {
        if (_gvars.activeUser.AUTO_JUDGE_OFFSET &&  // Auto Judge Offset enabled  
            (result.amazing + result.perfect + result.good + result.average >= 50) &&  // Accuracy data is reliable  
            result.accuracy != 0)
        {
            _gvars.activeUser.JUDGE_OFFSET = as3hx.Compat.parseFloat(result.accuracy_frames.toFixed(3));
            // Save settings
            _gvars.activeUser.saveLocal();
            _gvars.activeUser.save();
        }
    }
    
    /**
     * Calculates the max combo in a game score result based on the replay.
     * This is used for queue results to display the max combo across
     * multiple songs for the UI.
     * @param gameResult
     * @return int
     */
    private function getMaxCombo(gameResult                       : Dynamic) : Int
    {
        var maxCombo                       : Dynamic= 0;
        var curCombo                       : Dynamic= 0;
        for (x in 0...gameResult.replay_hit.length)
        {
            var curNote                       : Dynamic= gameResult.replay_hit[x];
            if (as3hx.Compat.truthy(curNote > 0))
            {
                curCombo += 1;
            }
            else if (as3hx.Compat.truthy(curNote <= 0))
            {
                curCombo = 0;
            }
            if (as3hx.Compat.truthy(curCombo > maxCombo))
            {
                maxCombo = curCombo;
            }
        }
        return maxCombo;
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
            if (as3hx.Compat.truthy((keyCode == _gvars.playerUser.keyLeft || keyCode == Keyboard.LEFT) && navPrev.visible))
            {
                target = navPrev;
            }
            else if (as3hx.Compat.truthy((keyCode == _gvars.playerUser.keyRight || keyCode == Keyboard.RIGHT) && navNext.visible))
            {
                target = navNext;
            }
            else if (as3hx.Compat.truthy(keyCode == _gvars.playerUser.keyRestart))
            {
                target = navReplay;
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
            _score.saveServerReplay(result);
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
        else if (as3hx.Compat.truthy(target == navPrev))
        {
            displayGameResult(resultIndex - 1);
        }
        else if (as3hx.Compat.truthy(target == navNext))
        {
            displayGameResult(resultIndex + 1);
        }
        else if (as3hx.Compat.truthy(target == navReplay))
        {
            var skipload                       : Dynamic= (songResults.length == 1 && songResults[0].song && songResults[0].song.isLoaded);
            
            if (as3hx.Compat.truthy(!_gvars.options.replay))
            {
                _gvars.options.fill();
            }
            
            if (as3hx.Compat.truthy(skipload))
            {
                _gvars.songRestarts++;
                switchTo(GameMenu.GAME_PLAY);
            }
            else
            {
                _gvars.songQueue = _gvars.totalSongQueue.concat();
                switchTo(GameMenu.GAME_LOADING);
            }
        }
        else if (as3hx.Compat.truthy(target == navRandomSong))
        {
            var songList                       : Dynamic= _playlist.playList;
            var selectedSong                       : Dynamic= null;
            
            //Check for filters and filter the songs list
            if (as3hx.Compat.truthy(_gvars.activeFilter != null))
            {
                var filteredSongInfos                       : Dynamic= null;
                filteredSongInfos = _playlist.indexList.filter(function(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
                                {
                                    return _gvars.activeFilter.process(item, _gvars.activeUser);
                                });
                
                songList = [];
                for (songInfo in as3hx.Compat.iter(filteredSongInfos))
                {
                    songList.push(songInfo);
                }
            }
            
            // Filter to only Playable Songs
            songList = songList.filter(function(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
                            {
                                return _gvars.checkSongAccess(item) == GlobalVariables.SONG_ACCESS_PLAYABLE;
                            });
            
            // Check for at least 1 possible playable song.
            if (as3hx.Compat.truthy(songList.length > 0))
            {
                selectedSong = songList[Math.floor(Math.random() * (songList.length - 1))];
                _gvars.songQueue.push(selectedSong);
                _gvars.options = new GameOptions();
                _gvars.options.fill();
                switchTo(Main.GAME_PLAY_PANEL);
            }
        }
        else if (as3hx.Compat.truthy(target == navOptions))
        {
            addPopup(Main.POPUP_OPTIONS);
        }
        else if (as3hx.Compat.truthy(target == navHighscores))
        {
            if (as3hx.Compat.truthy(resultIndex >= 0))
            {
                addPopup(new PopupHighscores(this, result.songInfo));
            }
        }
        else if (as3hx.Compat.truthy(target == navMenu))
        {
            switchTo(Main.GAME_MENU_PANEL);
        }
        else if (as3hx.Compat.truthy(target == navRating))
        {
            if (as3hx.Compat.truthy(resultIndex >= 0))
            {
                _gvars.gameMain.addPopup(new PopupSongNotes(this, result.songInfo));
            }
        }
    }
}

