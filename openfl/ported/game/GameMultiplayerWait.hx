package game;

import assets.results.MPWaitBackground;
import classes.Language;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCFFRResultsWait;
import classes.mp.commands.MPCFFRScoreUpdate;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.mode.ffr.MPMatchFFRUser;
import classes.mp.room.MPRoomFFR;
import classes.score.ScoreHandler;
import classes.ui.BoxButton;
import classes.ui.Text;
import classes.ui.Throbber;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import game.results.GameResultBackground;
import menu.MenuPanel;
import classes.ImageCache;




import classes.ui.ScrollBar;
import classes.ui.ScrollPane;

import com.flashfla.utils.TimeUtil;
import openfl.display.Sprite;
import openfl.events.Event;

import game.GameMultiplayerWait;

class GameMultiplayerWait extends MenuPanel
{
    private static var _gvars                         : Dynamic= GlobalVariables.instance;
    private static var _lang                         : Dynamic= Language.instance;
    private static var _mp                         : Dynamic= Multiplayer.instance;
    private static var _score                         : Dynamic= ScoreHandler.instance;
    
    public var userResult                         : Dynamic;
    public var textWaiting                         : Dynamic;
    
    public var startTime                         : Dynamic= 0;
    public var chartLength                         : Dynamic= 0;
    public var updateTimer                         : Dynamic;
    
    public var background                         : Dynamic;
    public var resultsDisplay                         : Dynamic;
    public var throbber                         : Dynamic;
    
    public var gotoResults                         : Dynamic;
    public var userDisplay                         : Dynamic;
    
    public function new(myParent                         : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    // Get Local Results
    {
        
        if (as3hx.Compat.truthy(_gvars.songResults.length > 0))
        {
            userResult = _gvars.songResults[as3hx.Compat.parseInt(_gvars.songResults.length - 1)];
            
            // Update Judge Offset
            updateJudgeOffset(userResult);
            
            // Send User Score
            _score.sendScore(userResult);
            _score.saveLocalReplay(userResult);
            
            // Clear Scores
            _gvars.songResults.length = 0;
        }
        
        return true;
    }
    
    override public function stageAdd() : Void
    {
        _mp.addEventListener(MPEvent.SOCKET_DISCONNECT, e_onMPDestroy);
        _mp.addEventListener(MPEvent.SOCKET_ERROR, e_onMPDestroy);
        _mp.addEventListener(MPEvent.ROOM_LEAVE_OK, e_onMPDestroy);
        _mp.addEventListener(MPEvent.ROOM_DELETE_OK, e_onMPDestroy);
        
        // Background
        background = new GameResultBackground();
        addChild(background);
        
        resultsDisplay = new MPWaitBackground();
        addChild(resultsDisplay);
        
        textWaiting = new Text(this, 20, 10, _lang.string("mp_room_ffr_match_wait"), 16, "#E2FEFF");
        textWaiting.setAreaParams(Main.GAME_WIDTH - 10, 26, "center");
        
        if (as3hx.Compat.truthy(Std.is(_mp.GAME_ROOM, MPRoomFFR)))
        {
            var ffrRoom                         : Dynamic= try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
            
            ffrRoom.lastMatchScorePersonal = userResult;
            
            _mp.addEventListener(MPEvent.FFR_MATCH_END, e_onFFRResults);
            
            // Final Score
            _mp.sendCommand(new MPCFFRScoreUpdate(ffrRoom, userResult.score, userResult.amazing, userResult.perfect, userResult.good, userResult.average, userResult.miss, userResult.boo, userResult.combo, userResult.max_combo));
            
            // Set to Waiting
            _mp.sendCommand(new MPCFFRResultsWait(ffrRoom));
            
            gotoResults = new BoxButton(this, 22, 428, 732, 40, _lang.string("mp_room_ffr_match_wait_skip"), 12, e_skipToResults);  // TODO Language  
            
            // Figure out waiting time.
            var lowestRate                         : Dynamic= Math.POSITIVE_INFINITY;
            for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EField(EIdent(ffrRoom),activeMatch),users) type: null */ in as3hx.Compat.iter(ffrRoom.activeMatch.users))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(user.rate) < as3hx.Compat.parseFloat(lowestRate)))
                {
                    lowestRate = user.rate;
                }
            }
            
            chartLength = as3hx.Compat.parseInt(Math.ceil(userResult.song.chart.Notes[as3hx.Compat.parseInt(userResult.song.chart.Notes.length - 1)].time)) * 1000;
            startTime = ffrRoom.activeMatch.startTime + 1500;
            
            var eclipsedTime                         : Dynamic= Math.round(haxe.Timer.stamp() * 1000) - startTime;
            var remainingTime                         : Dynamic= Math.ceil(chartLength / lowestRate) - eclipsedTime;
            
            if (as3hx.Compat.truthy(usersStillPlaying() > 0 && remainingTime >= 3))
            {
                userDisplay = new UserDisplayGroup(this, ffrRoom);
                userDisplay.x = 34;
                userDisplay.y = 60;
                addChild(userDisplay);
                
                _mp.addEventListener(MPEvent.FFR_GAME_STATE, e_gameState);
                
                updateTimer = new Timer(1000);
                updateTimer.addEventListener(TimerEvent.TIMER, e_timerCountdown);
                updateTimer.start();
            }
            else
            {
                throbber = new Throbber(64, 64);
                throbber.x = Main.GAME_WIDTH / 2 - 32;
                throbber.y = Main.GAME_HEIGHT / 2 - 32;
                throbber.start();
                addChild(throbber);
                gotoResults.enabled = false;
            }
        }
    }
    
    override public function stageRemove() : Void
    {
        _mp.removeEventListener(MPEvent.SOCKET_DISCONNECT, e_onMPDestroy);
        _mp.removeEventListener(MPEvent.SOCKET_ERROR, e_onMPDestroy);
        _mp.removeEventListener(MPEvent.ROOM_LEAVE_OK, e_onMPDestroy);
        _mp.removeEventListener(MPEvent.ROOM_DELETE_OK, e_onMPDestroy);
        
        if (as3hx.Compat.truthy(updateTimer != null))
        {
            updateTimer.stop();
        }
        
        if (as3hx.Compat.truthy(throbber != null))
        {
            throbber.stop();
        }
        
        if (as3hx.Compat.truthy(Std.is(_mp.GAME_ROOM, MPRoomFFR)))
        {
            _mp.removeEventListener(MPEvent.FFR_GAME_STATE, e_gameState);
            _mp.removeEventListener(MPEvent.FFR_MATCH_END, e_onFFRResults);
        }
    }
    
    private function usersStillPlaying() : Float
    {
        var ffrRoom                         : Dynamic= try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
        
        var count                         : Dynamic= 0;
        
        for (player/* AS3HX WARNING could not determine type for var: player exp: EField(EField(EIdent(ffrRoom),activeMatch),users) type: null */ in as3hx.Compat.iter(ffrRoom.activeMatch.users))
        {
            if (as3hx.Compat.truthy(player.user != _mp.currentUser && ffrRoom.getPlayerState(player.user) == "game"))
            {
                count++;
            }
        }
        
        return count;
    }
    
    private function e_timerCountdown(e                         : Dynamic) : Void
    {
        userDisplay.update();
    }
    
    private function e_skipToResults(e                         : Dynamic) : Void
    {
        var ffrRoom                         : Dynamic= try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
        ffrRoom.lastMatchIndex = -2;
        switchTo(GameMenu.GAME_MP_RESULTS);
    }
    
    private function e_gameState(e                         : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == _mp.GAME_ROOM))
        {
            userDisplay.update();
        }
    }
    
    private function e_onFFRResults(e                         : Dynamic) : Void
    {
        switchTo(GameMenu.GAME_MP_RESULTS);
    }
    
    private function e_onMPDestroy(e                         : Dynamic) : Void
    {
        switchTo(Main.GAME_MENU_PANEL);
    }
    
    //******************************************************************************************//
    // Helper Functions
    //******************************************************************************************//
    
    /**
     * Handles Auto Judge Offset options by changing the judge offset and saving
     * the user settings. This is called when scores are saved successfully.
     * @param result GameScoreResult
     */
    private function updateJudgeOffset(result                         : Dynamic) : Void
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
}




class UserDisplayGroup extends Sprite
{
    public var panel                         : Dynamic;
    public var room                         : Dynamic;
    public var displays                         : Dynamic= [];
    
    public var pane                         : Dynamic;
    private var scrollbar                         : Dynamic;
    
    @:allow(game)
    private function new(panel                         : Dynamic, room                         : Dynamic)
    {
        super();
        this.panel = panel;
        this.room = room;
        
        // Chat Log
        pane = new ScrollPane(this, 0, 0, 710, 349, e_mouseWheelHandler);
        scrollbar = new ScrollBar(this, 719, 0, 15, 349, null, null, e_scrollbarUpdater);
        
        for (player/* AS3HX WARNING could not determine type for var: player exp: EField(EField(EIdent(room),activeMatch),users) type: null */ in as3hx.Compat.iter(room.activeMatch.users))
        {
            var display                         : Dynamic= new UserDisplay(panel, room, player);
            pane.content.addChild(display);
            displays.push(display);
        }
        
        scrollbar.draggerVisibility = displays.length > 12;
        
        position();
        update();
    }
    
    public function position() : Void
    {
        as3hx.Compat.sortOn(displays, ["weight", "name"], [as3hx.Compat.ARRAY_DESCENDING | as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
        var total                         : Dynamic= displays.length;
        var rowMax                         : Dynamic= 6;
        var rowIndex                         : Dynamic= 0;
        var startX                         : Dynamic= 0;
        var startY                         : Dynamic= ((total <= rowMax * 2)) ? (80 * (1 - Math.max(0, Math.floor(total / rowMax))) + 20) : 0;
        
        for (i in 0...total)
        {
            var display                         : Dynamic= displays[i];
            
            if (as3hx.Compat.truthy((i % rowMax) == 0))
            {
                startX = as3hx.Compat.parseInt((pane.width / 2) - (Math.min(rowMax, total - i) * 60));
                rowIndex = 0;
            }
            
            display.x = startX + (rowIndex * 120) + 4;
            display.y = Math.floor(i / rowMax) * 160 + startY;
            rowIndex++;
        }
        
        pane.update();
    }
    
    public function update() : Void
    {
        for (display in as3hx.Compat.iter(displays))
        {
            display.update();
        }
    }
    
    /**
     * Mouse Wheel Handler for the Chat Log Pane.
     * Moves the scroll pane based on the scroll delta direction.
     * @param e
     */
    private function e_mouseWheelHandler(e                         : Dynamic) : Void
    // Sanity
    {
        
        if (as3hx.Compat.truthy(!scrollbar.draggerVisibility))
        {
            return;
        }
        
        // Scroll
        var newScrollPosition                         : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(newScrollPosition);
        scrollbar.scrollTo(newScrollPosition);
    }
    
    private function e_scrollbarUpdater(e                         : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
}

class UserDisplay extends Sprite
{
    public var remainingTime(get, never)                         : Dynamic;
    public var weight(get, never)                         : Dynamic;

    private static var _lang                         : Dynamic= Language.instance;
    
    public var panel                         : Dynamic;
    public var room                         : Dynamic;
    public var player                         : Dynamic;
    
    public var textName                         : Dynamic;
    public var textState                         : Dynamic;
    public var avatar                         : Dynamic;
    
    @:allow(game)
    private function new(panel                         : Dynamic, room                         : Dynamic, player                         : Dynamic)
    {
        super();
        this.panel = panel;
        this.player = player;
        this.room = room;
        
        this.graphics.beginFill(0xffffff, 0.15);
        this.graphics.drawRect(0, 0, 110, 150);
        this.graphics.endFill();
        
        textName = new Text(this, 5, 110, player.user.userLabelHTML);
        textName.setAreaParams(100, 22, "center");
        
        textState = new Text(this, 5, 127, player.user.userLabelHTML, 11, "#CBCBCB");
        textState.setAreaParams(100, 22, "center");
        
        avatar = ImageCache.getImage(player.user.avatarURL, ImageCache.ALIGN_MIDDLE, 100, 100);
        avatar.x = 55;
        avatar.y = 55;
        addChild(avatar);
    }
    
    public function update() : Void
    {
        if (as3hx.Compat.truthy(room.getPlayerState(player.user) != "game"))
        {
            textState.text = _lang.string("mp_room_ffr_match_wait_finished");
        }
        else
        {
            textState.text = TimeUtil.convertToHMSS(remainingTime / 1000);
        }
        
        this.alpha = (player.alive) ? 1 : 0.5;
    }
    
    private function get_remainingTime() : Float
    {
        return Math.max(0, Math.ceil(panel.chartLength / player.rate) - (Math.round(haxe.Timer.stamp() * 1000) - panel.startTime));
    }
    
    override private function get_name() : String
    {
        return player.user.name;
    }
    
    private function get_weight() : Float
    {
        if (as3hx.Compat.truthy(room.getPlayerState(player.user) == "game"))
        {
            return remainingTime;
        }
        
        return 0;
    }
}
