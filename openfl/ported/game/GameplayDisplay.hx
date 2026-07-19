package game;

import openfl.errors.Error;
import arc.ArcGlobals;
import assets.GameBackgroundColor;
import classes.Alert;
import classes.GameNote;
import classes.Language;
import classes.Noteskins;
import classes.chart.Note;
import classes.chart.Song;
import classes.mp.MPSocketDataRaw;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCFFRPlaybackRequest;
import classes.mp.commands.MPCFFRSongStart;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPRoomRawEvent;
import classes.mp.mode.ffr.MPFFRState;
import classes.mp.mode.ffr.MPMatchFFR;
import classes.mp.mode.ffr.MPMatchFFRTeam;
import classes.mp.mode.ffr.MPMatchFFRUser;
import classes.mp.room.MPRoomFFR;
import classes.replay.ReplayBinFrame;
import classes.replay.ReplayNote;
import classes.ui.BoxButton;
import classes.ui.Text;
import classes.user.UserSongData;
import classes.user.UserSongNotes;
import com.flashfla.utils.Average;
import com.flashfla.utils.RollingAverage;
import com.flashfla.utils.StringUtil;
import com.flashfla.utils.TimeUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;
import openfl.utils.ByteArray;
import openfl.utils.Timer;
import game.controls.AccuracyBar;
import game.controls.BarBottom;
import game.controls.BarTop;
import game.controls.Combo;
import game.controls.ComboHypeOverlay;
import game.controls.ComboTotal;
import game.controls.GameControl;
import game.controls.GameControlEditor;
import game.controls.GameLayoutManager;
import game.controls.Judge;
import game.controls.LifeBar;
import game.controls.MPFFRScoreCompare;
import game.controls.NoteBox;
import game.controls.PAWindow;
import game.controls.ProgressBarGame;
import game.controls.RawGoods;
import game.controls.Score;
import game.controls.ScreenCut;
import game.controls.TextStatic;
import game.events.GamePlaybackEvent;
import game.events.GamePlaybackFocusChange;
import game.events.GamePlaybackReader;
import game.events.GamePlaybackScoreState;
import game.events.GamePlaybackSpectatorEnd;
import game.events.GamePlaybackSpectatorHit;
import menu.MenuPanel;
import menu.MenuSongSelection;


import assets.menu.icons.fa.IconClose;



import classes.ui.PromptInput;

import classes.ui.UIIcon;
import com.flashfla.utils.SystemUtil;


import game.GameplayDisplay;


class GameplayDisplay extends MenuPanel
{
    private static var dragEnd                  : Dynamic;
    private static var dragStart                  : Dynamic;
    public static inline var GAME_WAIT                       : Dynamic= 0;
    public static inline var GAME_PLAY                       : Dynamic= 1;
    public static inline var GAME_END                       : Dynamic= 2;
    public static inline var GAME_RESTART                       : Dynamic= 3;
    public static inline var GAME_PAUSE                       : Dynamic= 4;
    public static inline var GAME_DISPOSE                       : Dynamic= 5;
    
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _mp                       : Dynamic= Multiplayer.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var _noteskins                       : Dynamic= Noteskins.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var _loader                       : Dynamic;
    public var _keyDown                       : Dynamic;
    
    public var song                       : Dynamic;
    public var options                       : Dynamic;
    public var layoutManager                       : Dynamic;
    
    public var reverseMod                       : Dynamic;
    
    public var editorMenu                       : Dynamic;
    public var editorSpriteMenus                       : Dynamic;
    
    public var bgTopBar                       : Dynamic;
    public var bgBottomBar                       : Dynamic;
    
    public var uiNoteField                       : Dynamic;
    public var uiProgressDisplay                       : Dynamic;
    public var uiProgressDisplayText                       : Dynamic;
    public var uiScore                       : Dynamic;
    public var uiAccuracyBar                       : Dynamic;
    public var uiPAWindow                       : Dynamic;
    public var uiCombo                       : Dynamic;
    public var uiComboHype                       : Dynamic;
    public var uiComboStatic                       : Dynamic;
    public var uiLifebar                       : Dynamic;
    public var uiJudge                       : Dynamic;
    public var uiRawGoods                       : Dynamic;
    public var uiRawGoodsStatic                       : Dynamic;
    public var uiNoteCount                       : Dynamic;
    public var uiNoteCountStatic                       : Dynamic;
    public var uiScreenCut                       : Dynamic;
    public var uiSongBackground                       : Dynamic;
    
    public var accuracy                       : Dynamic;
    public var songOffset                       : Dynamic;
    public var frameRate                       : Dynamic;
    
    public var absoluteStart                       : Dynamic= 0;
    public var absolutePosition                       : Dynamic= 0;
    public var songPausePosition                       : Dynamic= 0;
    public var songDelay                       : Dynamic= 0;
    public var songDelayStarted                       : Dynamic= false;
    public var judgeSettings                       : Dynamic;
    
    public var GAME_FRAME                       : Dynamic= 0;
    public var GAME_TIME                       : Dynamic= 0;
    
    public var GLOBAL_OFFSET_MS                       : Dynamic= 0;
    public var GLOBAL_OFFSET_FRAMES                       : Dynamic= 0;
    public var JUDGE_OFFSET_MS                       : Dynamic= 0;
    public var JUDGE_OFFSET_FRAMES                       : Dynamic;
    
    public var quitDoubleTap                       : Dynamic= -1;
    
    public var gameLastNoteFrame                       : Dynamic;
    public var gameFirstNoteFrame                       : Dynamic;
    
    public var gameLife                       : Dynamic;
    public var gameScore                       : Dynamic;
    public var gameRawGoods                       : Dynamic;
    public var gameReplay                       : Dynamic;
    public var autoplayCount                       : Dynamic;
    
    /** Contains a list of scores or other flags used in replay_hit.
     * The value is either:
     * [100]  Amazing
     * [50]   Perfect
     * [25]   Good
     * [5]    Average
     * [0]    Miss & Boo
     * [-5]   Missed Note After End Game
     * [-10]  End of Replay Hit Tag
     */
    public var gameReplayHit                       : Dynamic;
    
    public var binReplayNotes                       : Dynamic;
    public var binReplayBoos                       : Dynamic;
    
    public var gameHistory                       : Dynamic;
    
    public var replayPressCount                       : Dynamic= 0;
    
    public var hitAmazing                       : Dynamic;
    public var hitPerfect                       : Dynamic;
    public var hitGood                       : Dynamic;
    public var hitAverage                       : Dynamic;
    public var hitMiss                       : Dynamic;
    public var hitBoo                       : Dynamic;
    public var hitCombo                       : Dynamic;
    public var hitMaxCombo                       : Dynamic;
    
    public var noteBoxOffset                       : Dynamic= new Point();
    public var noteBoxPositionDefault                       : Dynamic;
    private var _laneGuideRect                       : Dynamic= new Rectangle();
    private var _laneGuideEdges                       : Dynamic= new Array<Float>();
    private var _laneGuideValid                       : Dynamic= false;
    private var _laneGuideLastDisplayState                       : Dynamic= "";
    private var _laneGuideLastStageWidth                       : Dynamic= -1;
    private var _laneGuideLastStageHeight                       : Dynamic= -1;
    private var _laneGuideLastFieldX                       : Dynamic= 0;
    private var _laneGuideLastFieldY                       : Dynamic= 0;
    private var _laneGuideLastFieldScaleX                       : Dynamic= 0;
    private var _laneGuideLastFieldScaleY                       : Dynamic= 0;
    private var _laneGuideLastFieldRotation                       : Dynamic= 0;
    private var _laneGuideLastReceptorMinX                       : Dynamic= 0;
    private var _laneGuideLastReceptorMaxX                       : Dynamic= 0;
    private var _laneGuideLastReceptorMinY                       : Dynamic= 0;
    private var _laneGuideLastReceptorMaxY                       : Dynamic= 0;
    private var _chordImpactFrame                       : Dynamic= -2147483648;
    private var _chordImpactCount                       : Dynamic= 1;
    private var _lastVisualImpactFrame                       : Dynamic= -2147483648;
    private var _accuracyGuideBaseX                       : Dynamic= 0;
    private var _accuracyGuideBaseY                       : Dynamic= 0;
    
    public var GAME_STATE                       : Dynamic= GAME_WAIT;
    
    public var SOCKET_SONG_MESSAGE                       : Dynamic= { };
    public var SOCKET_SCORE_MESSAGE                       : Dynamic= { };
    
    // Anti-GPU Rampdown Hack
    public var GPU_PIXEL_BMD                       : Dynamic;
    public var GPU_PIXEL_BITMAP                       : Dynamic;
    
    // Multiplayer
    public var isMultiplayer                       : Dynamic= false;
    public var isMultiplayerSpectator                       : Dynamic= false;
    public var scoreHistory                       : Dynamic;
    public var scoreHistoryLastCount                       : Dynamic;
    public var scoreHistoryBuffer                       : Dynamic;
    public var spectatorHistory                       : Dynamic;
    public var spectatorHistoryLastCount                       : Dynamic;
    public var spectatorPlayerVars                       : Dynamic;
    public var mpUpdateTimer                       : Dynamic;
    public var mpSpectatorTimer                       : Dynamic;
    public var mpRawBuffer                       : Dynamic;
    public var mpFFRRoom                       : Dynamic;
    public var mpuiFFRScores                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        options = _gvars.options;
        song = options.song;
        song.handleDirty(options);
        
        if (as3hx.Compat.truthy(!options.isEditor && song.chart.Notes.length == 0))
        {
            Alert.add(_lang.string("error_chart_has_no_notes"), 120, Alert.RED);
            switchTo(Main.GAME_MENU_PANEL);
            return false;
        }
        
        layoutManager = new GameLayoutManager(this, options);
        
        if (as3hx.Compat.truthy(options.isEditor && options.isMultiplayer))
        {
            mpFFRRoom = new MPRoomFFR();
            
            var fakeMatch                       : Dynamic= new MPMatchFFR(mpFFRRoom);
            mpFFRRoom.activeMatch = fakeMatch;
            
            var fakeTeam                       : Dynamic= new MPMatchFFRTeam();
            fakeMatch.teams.push(fakeTeam);
            
            var fakeNames                       : Dynamic= ["Velocity", "Synthlight", "xXOpkillerXx", "goldstinger"];
            
            for (i in 1...fakeNames.length + 1)
            {
                var fakeMPPlayer                       : Dynamic= new MPUser();
                fakeMPPlayer.update({
                            name : fakeNames[i - 1]
                        });
                
                var fakePlayer                       : Dynamic= new MPMatchFFRUser(mpFFRRoom, fakeMPPlayer);
                fakePlayer.playing = (i != fakeNames.length - 1);
                fakePlayer.alive = (i != fakeNames.length);
                fakePlayer.raw_score = Math.floor(50000 / i);
                fakePlayer.good = Math.floor(86 / i);
                fakePlayer.average = Math.floor(69 / i);
                fakePlayer.miss = Math.floor(76 / i);
                fakePlayer.boo = Math.floor(79 / i);
                fakePlayer.position = i;
                fakeMatch.users.push(fakePlayer);
                fakeTeam.users.push(fakePlayer);
            }
        }
        
        // --- Per Song Options
        var perSongOptions                       : Dynamic= UserSongNotes.getSongUserInfo(song.songInfo);
        if (as3hx.Compat.truthy(perSongOptions != null && !options.isEditor && !options.replay))
        {
            options.fill();  // Reset  
            
            // Custom Offsets
            if (as3hx.Compat.truthy(perSongOptions.set_custom_offsets))
            {
                options.offsetJudge = perSongOptions.offset_judge;
                options.offsetGlobal = perSongOptions.offset_music;
            }
            
            // Invert Mirror Mod
            if (as3hx.Compat.truthy(perSongOptions.set_mirror_invert))
            {
                if (as3hx.Compat.truthy(options.modEnabled("mirror")))
                {
                    options.mods.removeAt(options.mods.indexOf("mirror"));
                }
                else
                {
                    options.mods.push("mirror");
                    Reflect.setField(options.modCache, "mirror", true);
                }
            }
        }
        // --- End Per Song Settings
        
        // --- Update RG values for Personal Best or AAA Equiv autofail/tracking if active
        if (as3hx.Compat.truthy(options.isScoreUpdated() && (options.personalBestMode || options.personalBestTracker || options.autofail[7] != 0)))
        {
            var infoRanks                       : Dynamic= _gvars.playerUser.getLevelRank(song.songInfo);
            var rawScoreMax                       : Dynamic= song.songInfo.score_raw;
            
            if (as3hx.Compat.truthy(rawScoreMax == 0))
            {
                rawScoreMax = song.chart.Notes.length * 50;
            }  // Alt engine hack as they often don't have a note count or raw max saved...  
            
            if (as3hx.Compat.truthy(infoRanks != null)) {
{
                    var rawDifference                       : Dynamic= rawScoreMax - infoRanks.rawscore;
                    
                    if (as3hx.Compat.truthy(options.personalBestMode))
                    {
                        options.autofail[6] = rawDifference / 25;
                    }
                    
                    if (as3hx.Compat.truthy(options.personalBestTracker))
                    {
                        options.rawGoodTracker = rawDifference / 25;
                    }
                }
            }
            
            if (as3hx.Compat.truthy(options.autofail[7] != 0 && song.songInfo.engine == null)) {
{
                    // first check if the song can even meet that equiv, if not then set the autofail at non-AAA
                    if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(song.songInfo.difficulty) <= as3hx.Compat.parseFloat(options.autofail[7])))
                    {
                        options.autofail[6] = 0.2;
                    }
                    // need to convert the AAA equiv to a raw good max on this particular song to use for autofail
                    else
                    {
                        
                        var calculatedRawGoods                       : Dynamic= SkillRating.getRawGoodsFromEquiv(song.songInfo, options.autofail[7]);
                        
                        // now set the autofail to that value
                        options.autofail[6] = calculatedRawGoods;
                    }
                }
            }
        }
        // --- End Personal Best tracking
        
        // --- Multiplayer
        if (as3hx.Compat.truthy(!options.isEditor && !options.replay && options.isMultiplayer))
        {
            _mp.addEventListener(MPEvent.SOCKET_DISCONNECT, e_destroyMultiplayer);
            _mp.addEventListener(MPEvent.SOCKET_ERROR, e_destroyMultiplayer);
            _mp.addEventListener(MPEvent.ROOM_LEAVE_OK, e_destroyMultiplayer);
            _mp.addEventListener(MPEvent.ROOM_DELETE_OK, e_destroyMultiplayer);
            
            if (as3hx.Compat.truthy(Std.is(_mp.GAME_ROOM, MPRoomFFR)))
            {
                mpFFRRoom = try cast(_mp.GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null;
                mpFFRRoom.lastMatchIndex = -1;
                _mp.addEventListener(MPEvent.FFR_SCORE_UPDATE, e_mpFFRScoreUpdate);
                
                if (as3hx.Compat.truthy(options.isSpectator && options.spectatorUser != null))
                {
                    isMultiplayerSpectator = true;
                    spectatorPlayerVars = mpFFRRoom.getPlayerVariables(options.spectatorUser);
                    _mp.addEventListener(MPEvent.FFR_GET_PLAYBACK, e_mpFFRPlaybackUpdate);
                }
                else if (as3hx.Compat.truthy(mpFFRRoom.getPlayerState(_mp.currentUser) == "loading"))
                {
                    isMultiplayer = true;
                    
                    mpFFRRoom.mods.apply(options, song);
                    
                    var noteskinData                       : Dynamic= (options.noteskin == 0) ? _noteskins.lastCustomNoteskin : null;
                    _mp.sendCommand(new MPCFFRSongStart(mpFFRRoom, options.settingsEncode(), options.layout, noteskinData));
                }
            }
        }
        
        return true;
    }
    
    override public function stageAdd() : Void
    {
        if (as3hx.Compat.truthy(_gvars.menuMusic))
        {
            _gvars.menuMusic.stop();
        }
        
        if (as3hx.Compat.truthy(MenuSongSelection.previewMusic))
        {
            MenuSongSelection.previewMusic.stop();
        }
        
        // Init Core
        initGameVars();
        initCore();
        initMultiplayer();
        
        // Preload next Song
        if (as3hx.Compat.truthy(_gvars.songQueue.length > 0))
        {
            _gvars.getSongFile(_gvars.songQueue[0]);
        }
        
        // Stage Properties
        _gvars.gameMain.disablePopups = true;
        
        stage.focus = this.stage;
        stage.frameRate = options.frameRate;
        
        if (as3hx.Compat.truthy(!options.isEditor && !options.replay && !isMultiplayerSpectator))
        {
            Mouse.hide();
        }
        
        if (as3hx.Compat.truthy(song.songInfo && song.songInfo.name))
        {
            Main.window.title = Constant.AIR_WINDOW_TITLE + " - " + StringUtil.stripHtml(song.songInfo.name);
        }
        
        // Prebuild Websocket Message, this is updated instead of creating a new object every message.
        SOCKET_SONG_MESSAGE = {
                    player : {
                        settings : options.settingsEncode(),
                        name : _gvars.activeUser.name,
                        userid : _gvars.activeUser.siteId,
                        avatar : URLs.resolve(URLs.USER_AVATAR_URL) + "?uid=" + _gvars.activeUser.siteId,
                        skill_rating : _gvars.activeUser.skillRating,
                        skill_level : _gvars.activeUser.skillLevel,
                        game_rank : _gvars.activeUser.gameRank,
                        game_played : _gvars.activeUser.gamesPlayed,
                        game_grand_total : _gvars.activeUser.grandTotal
                    },
                    engine : ((song.songInfo.engine == null) ? null : {
                        id : song.songInfo.engine.id,
                        name : song.songInfo.engine.name,
                        config : song.songInfo.engine.config_url,
                        domain : song.songInfo.engine.domain
                    }),
                    song : {
                        name : song.songInfo.name,
                        level : song.songInfo.level,
                        difficulty : song.songInfo.difficulty,
                        style : song.songInfo.style,
                        author : song.songInfo.author,
                        author_url : song.songInfo.author_url,
                        stepauthor : song.songInfo.stepauthor,
                        credits : song.songInfo.credits,
                        genre : song.songInfo.genre,
                        nps_min : song.songInfo.min_nps,
                        nps_max : song.songInfo.max_nps,
                        time : song.chartTimeFormatted,
                        time_seconds : song.chartTime,
                        note_count : song.totalNotes,
                        nps_avg : (song.totalNotes / song.chartTime)
                    },
                    best_score : _gvars.activeUser.getLevelRank(song.songInfo)
                };
        
        SOCKET_SCORE_MESSAGE = {
                    amazing : 0,
                    perfect : 0,
                    good : 0,
                    average : 0,
                    miss : 0,
                    boo : 0,
                    score : 0,
                    combo : 0,
                    maxcombo : 0,
                    restarts : 0,
                    last_hit : null
                };
        
        // Set Defaults for Editor Mode
        if (as3hx.Compat.truthy(options.isEditor))
        {
            Reflect.setField(Reflect.field(SOCKET_SONG_MESSAGE, "song"), "name", "Editor Mode");
            Reflect.setField(Reflect.field(SOCKET_SONG_MESSAGE, "song"), "author", "rCubed Engine");
            Reflect.setField(Reflect.field(SOCKET_SONG_MESSAGE, "song"), "difficulty", 0);
            Reflect.setField(Reflect.field(SOCKET_SONG_MESSAGE, "song"), "time", "10:00");
            Reflect.setField(Reflect.field(SOCKET_SONG_MESSAGE, "song"), "time_seconds", 600);
        }
        
        // Init Game
        interfaceBuild();
        interfaceSetup();
        initPlayerVars();
        
        // Add onEnterFrame Listeners
        if (as3hx.Compat.truthy(options.isEditor))
        {
            options.isAutoplay = true;
            interfaceSetupEditor();
            editorMenu = new EditorMenu(this);
            editorSpriteMenus = [];
            stage.addEventListener(Event.ENTER_FRAME, e_onFrameEditor, false, as3hx.Compat.INT_MAX - 10, true);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDownEditor, true, as3hx.Compat.INT_MAX - 10, true);
        }
        else
        {
            stage.addEventListener(Event.ENTER_FRAME, e_onFrame, false, as3hx.Compat.INT_MAX - 10, true);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDown, true, as3hx.Compat.INT_MAX - 10, true);
            stage.addEventListener(KeyboardEvent.KEY_UP, e_onKeyUp, true, as3hx.Compat.INT_MAX - 10, true);
        }
        
        if (as3hx.Compat.truthy(!isMultiplayerSpectator))
        {
            GAME_STATE = GAME_PLAY;
            initSongStart();
        }
    }
    
    override public function stageRemove() : Void
    // Reset Window Title
    {
        
        Main.window.title = Constant.AIR_WINDOW_TITLE;
        
        stage.frameRate = 60;
        
        if (as3hx.Compat.truthy(options.isEditor))
        {
            _gvars.activeUser.screencutPosition = options.screencutPosition;
            stage.removeEventListener(Event.ENTER_FRAME, e_onFrameEditor);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDownEditor, true);
        }
        else
        {
            stage.removeEventListener(Event.ENTER_FRAME, e_onFrame);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_onKeyDown, true);
            stage.removeEventListener(KeyboardEvent.KEY_UP, e_onKeyUp, true);
        }
        
        destroyMultiplayer();
        
        _gvars.gameMain.disablePopups = false;
        
        // Disable Editor mode when leaving editor.
        options.isEditor = false;
        
        Mouse.show();
    }
    
    public function e_destroyMultiplayer(e                       : Dynamic= null) : Void
    {
        var wasSpectator                       : Dynamic= isMultiplayerSpectator;
        
        destroyMultiplayer();
        
        if (as3hx.Compat.truthy(wasSpectator && (GAME_STATE == GAME_WAIT || GAME_STATE == GAME_PLAY)))
        {
            GAME_STATE = GAME_END;
        }
    }
    
    public function destroyMultiplayer() : Void
    {
        if (as3hx.Compat.truthy(options.isEditor))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(isMultiplayer || isMultiplayerSpectator))
        {
            _mp.removeEventListener(MPEvent.SOCKET_DISCONNECT, e_destroyMultiplayer);
            _mp.removeEventListener(MPEvent.SOCKET_ERROR, e_destroyMultiplayer);
            _mp.removeEventListener(MPEvent.ROOM_LEAVE_OK, e_destroyMultiplayer);
            _mp.removeEventListener(MPEvent.ROOM_DELETE_OK, e_destroyMultiplayer);
            Reflect.setField(Flags.VALUES, Flags.MP_MENU_RETURN, true);
        }
        
        if (as3hx.Compat.truthy(scoreHistory != null))
        {
            scoreHistory = null;
            scoreHistoryLastCount = 0;
        }
        
        if (as3hx.Compat.truthy(spectatorHistory != null))
        {
            spectatorHistory = null;
            spectatorHistoryLastCount = 0;
        }
        
        if (as3hx.Compat.truthy(mpRawBuffer != null))
        {
            mpRawBuffer = null;
        }
        
        if (as3hx.Compat.truthy(mpUpdateTimer != null))
        {
            mpUpdateTimer.stop();
            mpUpdateTimer.removeEventListener(TimerEvent.TIMER, e_onMPTimerTick);
            mpUpdateTimer = null;
        }
        
        if (as3hx.Compat.truthy(mpSpectatorTimer != null))
        {
            mpSpectatorTimer.stop();
            mpSpectatorTimer.removeEventListener(TimerEvent.TIMER, e_onSpectatorTimerTick);
            mpSpectatorTimer = null;
        }
        
        if (as3hx.Compat.truthy(mpFFRRoom != null))
        {
            _mp.removeEventListener(MPEvent.FFR_SCORE_UPDATE, e_mpFFRScoreUpdate);
            _mp.removeEventListener(MPEvent.FFR_GET_PLAYBACK, e_mpFFRPlaybackUpdate);
            mpFFRRoom = null;
        }
        
        isMultiplayer = false;
        isMultiplayerSpectator = false;
    }
    
    /*#########################################################################################*\
     *       _____       _ _   _       _ _
     *       \_   \_ __ (_) |_(_) __ _| (_)_______
     *	     / /\/ '_ \| | __| |/ _` | | |_  / _ \
     *	  /\/ /_ | | | | | |_| | (_| | | |/ /  __/
     *	  \____/ |_| |_|_|\__|_|\__,_|_|_/___\___|
     *
       \*#########################################################################################*/
    
    public function initCore() : Void
    // Bound Isolation Note Mod
    {
        
        if (as3hx.Compat.truthy(options.isolationOffset >= song.chart.Notes.length))
        {
            options.isolationOffset = song.chart.Notes.length - 1;
        }
        
        // Song
        song.updateMusicOffset();
        if (as3hx.Compat.truthy(song.background && !options.modEnabled("nobackground")))
        {
            uiSongBackground = try cast(song.background, MovieClip) catch(e:Dynamic) null;
            uiSongBackground.x = 115;
            uiSongBackground.y = 42.5;
            addChild(uiSongBackground);
        }
        
        songDelay = as3hx.Compat.parseInt(song.mp3Frame / options.songRate * 1000 / 30 - GLOBAL_OFFSET_MS);
    }
    
    public function initGameVars() : Void
    // Force no Judge on SongPreviews
    {
        
        if (as3hx.Compat.truthy(options.replay && options.replay.isPreview))
        {
            options.offsetJudge = 0;
            options.offsetGlobal = 0;
            options.visualDelay = 0;
            options.isAutoplay = true;
        }
        
        reverseMod = options.modEnabled("reverse");
        
        JUDGE_OFFSET_FRAMES = Math.round(options.offsetJudge);
        GLOBAL_OFFSET_FRAMES = Math.round(options.chartOffset);
        
        GLOBAL_OFFSET_MS = as3hx.Compat.parseInt((options.chartOffset - GLOBAL_OFFSET_FRAMES) * 1000 / 30);
        JUDGE_OFFSET_MS = as3hx.Compat.parseInt(options.offsetJudge * 1000 / 30);
        
        judgeSettings = buildJudgeNodes((options.judgeWindow) ? options.judgeWindow : Constant.JUDGE_WINDOW);
        
        songOffset = new RollingAverage(1, _avars.configMusicOffset);
    }
    
    public function initSongStart(postStart                       : Dynamic= true) : Void
    // Post Start Time
    {
        
        if (as3hx.Compat.truthy(postStart && !_gvars.activeUser.isGuest && !options.replay && !options.isEditor && !options.isSpectator && song.songInfo.engine == null))
        {
            Logger.debug(this, "Posting Start of level " + song.id);
            _loader = new URLLoader();
            addLoaderListeners();
            
            var req                       : Dynamic= new URLRequest(URLs.resolve(URLs.SONG_START_URL));
            var requestVars                       : Dynamic= new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;
            requestVars.id = song.id;
            requestVars.restarts = _gvars.songRestarts;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            _loader.load(req);
        }
        
        absoluteStart = Math.round(haxe.Timer.stamp() * 1000);
        
        // Handle Early Charts - Pad Charts till atleast 2 seconds before first note.
        if (as3hx.Compat.truthy(song != null && song.totalNotes > 0 && options.isolationOffset == 0))
        {
            var firstNote                       : Dynamic= song.getNote(0);
            if (as3hx.Compat.truthy(firstNote.time < 2))
            {
                absoluteStart += as3hx.Compat.parseInt((2 - firstNote.time) * 1000);
            }
        }
        
        // Websocket
        if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
        {
            Reflect.setField(SOCKET_SCORE_MESSAGE, "amazing", hitAmazing);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "perfect", hitPerfect);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "good", hitGood);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "average", hitAverage);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "boo", hitBoo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "miss", hitMiss);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "combo", hitCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "maxcombo", hitMaxCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "score", gameScore);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "last_hit", null);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "restarts", _gvars.songRestarts);
            _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
            _gvars.websocketSend("SONG_START", SOCKET_SONG_MESSAGE);
        }
    }
    
    public function initPlayerVars() : Void
    // Game Vars
    {
        
        _keyDown = { };
        gameLife = 50;
        gameScore = 0;
        gameRawGoods = 0;
        gameReplay = [];
        gameReplayHit = [];
        autoplayCount = 0;
        
        hitAmazing = 0;
        hitPerfect = 0;
        hitGood = 0;
        hitAverage = 0;
        hitMiss = 0;
        hitBoo = 0;
        hitCombo = 0;
        hitMaxCombo = 0;
        _chordImpactFrame = -2147483648;
        _chordImpactCount = 1;
        _lastVisualImpactFrame = -2147483648;
        
        // Replay
        replayPressCount = 0;
        
        binReplayNotes = new Array<ReplayBinFrame>();
        binReplayBoos = [];
        gameHistory = [];
        
        // Prefill Replay
        var i                       : Dynamic= as3hx.Compat.parseInt(song.totalNotes - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            binReplayNotes[i] = new ReplayBinFrame(Math.NaN, song.getNote(i).direction, i);
            i--;
        }
        
        if (as3hx.Compat.truthy(song != null && song.totalNotes > 0))
        {
            gameLastNoteFrame = song.getNote(song.totalNotes - 1).frame + Math.ceil(song.songInfo.time_end * 30);
            gameFirstNoteFrame = song.getNote(0).frame;
        }
        
        absoluteStart = Math.round(haxe.Timer.stamp() * 1000);
        absolutePosition = 0;
        GAME_TIME = 0;
        GAME_FRAME = 0;
        
        songOffset = new RollingAverage(options.frameRate * 4, _avars.configMusicOffset);
        frameRate = new RollingAverage(options.frameRate * 4, options.frameRate);
        accuracy = new Average();
        
        songDelayStarted = false;
        
        if (as3hx.Compat.truthy(options.isAutoplay))
        {
            autoplayCount++;
        }
        
        // Update UI
        updateFieldVars();
        
        if (as3hx.Compat.truthy(uiNoteCount.visible))
        {
            uiNoteCount.update(song.totalNotes);
        }
        
        if (as3hx.Compat.truthy(uiLifebar.visible))
        {
            uiLifebar.health = gameLife;
        }
        
        if (as3hx.Compat.truthy(uiProgressDisplayText.visible))
        {
            uiProgressDisplayText.update(TimeUtil.convertToHMSS(Math.ceil(gameLastNoteFrame / 30)));
        }
    }
    
    public function initMultiplayer() : Void
    {
        if (as3hx.Compat.truthy(options.isEditor))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(isMultiplayer || isMultiplayerSpectator))
        {
            spectatorHistory = [];
            spectatorHistoryLastCount = 0;
            scoreHistory = [];
            scoreHistoryLastCount = 0;
            mpRawBuffer = new ByteArray();
        }
        
        if (as3hx.Compat.truthy(isMultiplayer))
        {
            mpUpdateTimer = new Timer(200);
            mpUpdateTimer.addEventListener(TimerEvent.TIMER, e_onMPTimerTick);
            mpUpdateTimer.start();
        }
        
        if (as3hx.Compat.truthy(isMultiplayerSpectator))
        {
            mpSpectatorTimer = new Timer(1000);
            mpSpectatorTimer.addEventListener(TimerEvent.TIMER, e_onSpectatorTimerTick);
            mpSpectatorTimer.start();
        }
    }
    
    public function siteLoadComplete(e                       : Dynamic) : Void
    {
        removeLoaderListeners();
        var data                       : Dynamic= e.target.data;
        Logger.success(this, "Post Start Load Success = " + data.result);
        if (as3hx.Compat.truthy(data.result == "success"))
        {
            _gvars.songStartTime = data.current_date;
            _gvars.songStartHash = data.current_time;
        }
    }
    
    public function siteLoadError(err                       : Dynamic= null) : Void
    {
        Logger.error(this, "Post Start Load Failure: " + Logger.event_error(err));
        removeLoaderListeners();
    }
    
    /*#########################################################################################*\
     *        __                 _
     *       /__\_   _____ _ __ | |_ ___
     *      /_\ \ \ / / _ \ '_ \| __/ __|
     *     //__  \ V /  __/ | | | |_\__ \
     *     \__/   \_/ \___|_| |_|\__|___/
     *
       \*#########################################################################################*/
    
    public function e_onWindowFocus(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.type == Event.ACTIVATE))
        {
            gameHistory.push(new GamePlaybackFocusChange(gameHistory.length, GAME_TIME, true));
        }
        else
        {
            gameHistory.push(new GamePlaybackFocusChange(gameHistory.length, GAME_TIME, false));
        }
    }
    
    public function e_onFrame(e                       : Dynamic) : Void
    // UI Updates
    {
        
        uiJudge.updateJudge(e);
        var didUpdatePlay                       : Dynamic= false;
        
        // Gameplay Logic
        switch (GAME_STATE)
        {
            case GAME_PLAY:
                var lastAbsolutePosition                       : Dynamic= absolutePosition;
                absolutePosition = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - absoluteStart);
                
                if (as3hx.Compat.truthy(!songDelayStarted))
                {
                    if (as3hx.Compat.truthy(absolutePosition >= songDelay))
                    {
                        songDelayStarted = true;
                        song.start();
                    }
                }
                
                var songPosition                       : Dynamic= as3hx.Compat.parseInt(song.getPosition() + songDelay);
                if (as3hx.Compat.truthy(song.musicIsPlaying && songPosition > 100))
                {
                    songOffset.addValue(songPosition - absolutePosition);
                }
                
                frameRate.addValue(1000 / (absolutePosition - lastAbsolutePosition));
                
                GAME_TIME = Math.round(absolutePosition + songOffset.value);
                
                var targetProgress                       : Dynamic= Math.round(GAME_TIME * 30 / 1000 - 0.5);
                var threshold                       : Dynamic= Math.round(1 / (frameRate.value / 60));
                if (as3hx.Compat.truthy(threshold < 1))
                {
                    threshold = 1;
                }
                if (as3hx.Compat.truthy(options.replay))
                {
                    threshold = 0x7fffffff;
                }
                
                //Logger.debug("GP", "lAP: " + lastAbsolutePosition + " | aP: " + absolutePosition + " | sDS: " + songDelayStarted + " | sD: " + songDelay + " | sOv: " + songOffset.value + " | sGP: " + song.getPosition() + " | sP: " + songPosition + " | gP: " + GAME_TIME + " | tP: " + targetProgress + " | t: " + threshold);
                
                while (as3hx.Compat.truthy(GAME_FRAME < targetProgress && threshold-- > 0))
                {
                    logicTick();
                }
                
                if (as3hx.Compat.truthy(reverseMod))
                {
                    stopClips(uiSongBackground, 2 + song.musicStartFrames - GLOBAL_OFFSET_FRAMES + GAME_FRAME * options.songRate);
                }
                else
                {
                    stopClips(uiSongBackground, 2 + song.musicStartFrames - GLOBAL_OFFSET_FRAMES + GAME_FRAME * options.songRate);
                }
                
                updateTapPulseOffset();
                applyFieldVisualOffset(0, 0);
                
                uiNoteField.update(GAME_TIME);
                updateLaneGuideEffects();
                if (as3hx.Compat.truthy(uiAccuracyBar != null))
                {
                    uiAccuracyBar.tick();
                }
                
                if (as3hx.Compat.truthy(uiProgressDisplay.visible))
                {
                    uiProgressDisplay.update(GAME_FRAME / gameLastNoteFrame, false);
                }
                
                didUpdatePlay = true;
            
            case GAME_END:
                endGame();
            
            case GAME_RESTART:
                restartGame();
        }
        
        if (as3hx.Compat.truthy(uiComboHype != null))
        {
            uiComboHype.setJudgeBounds((uiJudge != null) ? uiJudge.getTextBounds(this) : null);
            uiComboHype.tick(GAME_FRAME);
            if (as3hx.Compat.truthy(didUpdatePlay))
            {
                applyFieldVisualOffset(uiComboHype.shakeX, uiComboHype.shakeY);
            }
        }
        
        e.stopImmediatePropagation();
    }
    
    public function e_onKeyUp(e                       : Dynamic) : Void
    {
        var keyCode                       : Dynamic= e.keyCode;
        var pressTime                       : Dynamic= as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - absoluteStart + songOffset.value);
        
        //gameHistory.push(new GameKeyUpEvent(gameHistory.length, pressTime, keyCode));
        
        // Set Key as used.
        Reflect.setField(_keyDown, Std.string(keyCode), false);
        
        e.stopImmediatePropagation();
    }
    
    public function e_onKeyDown(e                       : Dynamic) : Void
    {
        var keyCode                       : Dynamic= e.keyCode;
        var pressTime                       : Dynamic= as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - absoluteStart + songOffset.value);
        
        //gameHistory.push(new GameKeyDownEvent(gameHistory.length, pressTime, keyCode));
        
        // Don't allow key presses unless the key is up.
        if (as3hx.Compat.truthy(as3hx.Compat.field(_keyDown, keyCode) != null))
        {
            return;
        }
        
        // Set Key as used.
        Reflect.setField(_keyDown, Std.string(keyCode), true);
        
        // Handle judgement of key presses.
        if (as3hx.Compat.truthy(gameLife > 0))
        {
            if (as3hx.Compat.truthy(!options.replay))
            {
                var dir                       : Dynamic= null;
                if (keyCode == _gvars.activeUser.keyLeft) { dir = "L"; }
                else if (keyCode == _gvars.activeUser.keyRight) { dir = "R"; }
                else if (keyCode == _gvars.activeUser.keyUp) { dir = "U"; }
                else if (keyCode == _gvars.activeUser.keyDown) { dir = "D"; }
                
                if (as3hx.Compat.truthy(dir != null))
                {
                    judgeScorePosition(dir, pressTime);
                    
                    if (as3hx.Compat.truthy(isMultiplayer))
                    {
                        spectatorHistory.push(new GamePlaybackSpectatorHit(spectatorHistory.length, pressTime, dir));
                    }
                }
            }
        }
        
        // Game Restart
        if (as3hx.Compat.truthy(keyCode == _gvars.playerUser.keyRestart && !options.isMultiplayer))
        {
            GAME_STATE = GAME_RESTART;
        }
        // Quit
        else if (as3hx.Compat.truthy(keyCode == _gvars.playerUser.keyQuit))
        {
            if (as3hx.Compat.truthy(_gvars.songQueue.length > 0))
            {
                if (as3hx.Compat.truthy(quitDoubleTap > 0))
                {
                    _gvars.songQueue.length = 0;
                    GAME_STATE = GAME_END;
                }
                else
                {
                    quitDoubleTap = as3hx.Compat.parseInt(options.frameRate / 4);
                }
            }
            else
            {
                GAME_STATE = GAME_END;
            }
        }
        // Pause
        else if (as3hx.Compat.truthy(keyCode == 19 && (false || _gvars.playerUser.isAdmin || _gvars.playerUser.isDeveloper || options.replay)))
        {
            togglePause();
        }
        // Auto-Play
        else if (as3hx.Compat.truthy(keyCode == Keyboard.F8))
        {
            options.isAutoplay = !options.isAutoplay;
            autoplayCount++;
            Alert.add("Bot Play: " + options.isAutoplay, 120, Alert.RED);
        }
        
        e.stopImmediatePropagation();
    }
    
    public function e_progressMouseClick(e                       : Dynamic) : Void
    {
        var seek                       : Dynamic= as3hx.Compat.parseInt((e.localX / uiProgressDisplay.barWidth) * gameLastNoteFrame);
        if (as3hx.Compat.truthy(seek < GAME_FRAME))
        {
            restartGame();
        }
        
        absoluteStart = Math.round(haxe.Timer.stamp() * 1000);
        songOffset.reset(seek * 1000 / 30);
        song.start(seek * 1000 / 30);
        
        while (as3hx.Compat.truthy(GAME_FRAME < seek))
        {
            logicTick();
        }
        
        songDelayStarted = true;
    }
    
    public function e_onFrameEditor(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!(Std.is(stage.focus, TextField))))
        {
            stage.focus = null;
        }
        
        // State 0 = Gameplay
        if (as3hx.Compat.truthy(GAME_STATE == GAME_PLAY))
        {
            GAME_TIME = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - absoluteStart);
            var targetProgress                       : Dynamic= Math.round(GAME_TIME * 30 / 1000);
            
            // Update Notes
            while (as3hx.Compat.truthy(GAME_FRAME < targetProgress))
            {
                logicTick();
            }
            
            uiNoteField.update(GAME_TIME);
        }
        // State 1 = End Game
        else if (as3hx.Compat.truthy(GAME_STATE == GAME_END))
        {
            endGame();
            return;
        }
    }
    
    public function e_onKeyDownEditor(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(uiNoteField == null))
        {
            return;
        }
        
        var keyCode                       : Dynamic= e.keyCode;
        var dir                       : Dynamic= "";
        
        if (as3hx.Compat.truthy(keyCode == Keyboard.ESCAPE))
        {
            if (as3hx.Compat.truthy(contains(editorMenu)))
            {
                removeChild(editorMenu);
            }
            else
            {
                addChild(editorMenu);
            }
            
            return;
        }
        
        if (keyCode == _gvars.playerUser.keyLeft) { dir = "L"; }
        else if (keyCode == _gvars.playerUser.keyRight) { dir = "R"; }
        else if (keyCode == _gvars.playerUser.keyUp) { dir = "U"; }
        else if (keyCode == _gvars.playerUser.keyDown) { dir = "D"; }
        
        if (as3hx.Compat.truthy(dir != ""))
        {
            var frameahead                       : Dynamic= as3hx.Compat.parseInt((uiNoteField.readahead / (1000 / 30)) + 1);
            uiNoteField.spawnArrow(new Note(dir, (GAME_FRAME + frameahead) / 30, "red", GAME_FRAME + frameahead), (GAME_FRAME + JUDGE_OFFSET_FRAMES + 5) / 30 * 1000);
        }
    }
    
    /*#########################################################################################*\
     *	   ___                         ___                 _   _
     *	  / _ \__ _ _ __ ___   ___    / __\   _ _ __   ___| |_(_) ___  _ __  ___
     *	 / /_\/ _` | '_ ` _ \ / _ \  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
     *	/ /_\\ (_| | | | | | |  __/ / /  | |_| | | | | (__| |_| | (_) | | | \__ \
     *	\____/\__,_|_| |_| |_|\___| \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
     *
       \*#########################################################################################*/
    public function e_onMPTimerTick(e                       : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(mpFFRRoom == null))
        {
            return;
        }
        
        //_mp.sendCommand(new MPCFFRSongProgress(mpFFRRoom, GAME_TIME));
        
        var i                       : Dynamic= null;
        
        // Score Updates
        if (as3hx.Compat.truthy(scoreHistoryLastCount != scoreHistory.length)) {
mpRawBuffer.length = 0;
            mpRawBuffer.writeByte(MPEvent.RAW_TYPE_MODE);
            mpRawBuffer.writeByte(MPEvent.FFR_RAW_SCORE_HISTORY_APPEND);
            mpRawBuffer.writeUnsignedInt(mpFFRRoom.uid);
            
            for (i in scoreHistoryLastCount...scoreHistory.length)
            {
                scoreHistory[i].writeData(mpRawBuffer);
            }
            
            _mp.sendBytes(mpRawBuffer);
            scoreHistoryLastCount = scoreHistory.length;
        }
        
        // Spectator Playback
        if (as3hx.Compat.truthy(spectatorHistoryLastCount != spectatorHistory.length))
        {
            mpRawBuffer.length = 0;
            mpRawBuffer.writeByte(MPEvent.RAW_TYPE_MODE);
            mpRawBuffer.writeByte(MPEvent.FFR_RAW_PLAYBACK_APPEND);
            mpRawBuffer.writeUnsignedInt(mpFFRRoom.uid);
            
            for (i in spectatorHistoryLastCount...spectatorHistory.length)
            {
                spectatorHistory[i].writeData(mpRawBuffer);
            }
            
            _mp.sendBytes(mpRawBuffer);
            spectatorHistoryLastCount = spectatorHistory.length;
        }
    }
    
    public function e_onSpectatorTimerTick(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(mpFFRRoom == null))
        {
            return;
        }
        
        _mp.sendCommand(new MPCFFRPlaybackRequest(mpFFRRoom, options.spectatorUser, spectatorHistoryLastCount));
    }
    
    public function e_mpFFRScoreUpdate(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(mpFFRRoom != e.room))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(mpuiFFRScores != null))
        {
            mpuiFFRScores.update();
        }
    }
    
    public function e_mpFFRPlaybackUpdate(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(mpFFRRoom != e.room || options.spectatorUser != e.user))
        {
            return;
        }
        
        var cmd                       : Dynamic= e.command;
        
        GamePlaybackReader.parse(cmd.data, 18, spectatorHistory);  // Header is 1 + 1 + 4 + 4 + 4 + 4 Bytes  
        
        cmd.data.position = 10;
        var start_index                       : Dynamic= cmd.data.readUnsignedInt();
        var end_index                       : Dynamic= cmd.data.readUnsignedInt();
        
        spectatorHistoryLastCount = end_index;
        
        if (as3hx.Compat.truthy(GAME_STATE == GAME_WAIT && spectatorHistory.length > 0))
        {
            GAME_STATE = GAME_PLAY;
            
            //  Skip Ahead
            var lastTimestamp                       : Dynamic= 0;  //Math.max(0, spectatorHistory[spectatorHistory.length - 1].timestamp - 5000);  
            var lastFrame                       : Dynamic= as3hx.Compat.parseInt(lastTimestamp / 1000 * 30);
            
            absoluteStart = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - lastTimestamp);
            song.start(lastTimestamp);
            
            while (as3hx.Compat.truthy(GAME_FRAME < lastFrame))
            {
                logicTick();
            }
            
            songDelayStarted = true;
        }
    }
    
    public function logicTick() : Void
    {
        GAME_FRAME++;
        
        // Anti-GPU Rampdown Trick
        if (as3hx.Compat.truthy(GAME_FRAME % 15 == 0))
        {
            if (as3hx.Compat.truthy((GAME_FRAME & 1) == 0))
            {
                GPU_PIXEL_BMD.setPixel(0, 0, 0x010101);
            }
            else
            {
                GPU_PIXEL_BMD.setPixel(0, 0, 0x020202);
            }
        }
        
        if (as3hx.Compat.truthy(quitDoubleTap > 0))
        {
            quitDoubleTap--;
        }
        
        if (as3hx.Compat.truthy(GAME_FRAME >= gameLastNoteFrame + 20 || quitDoubleTap == 0))
        {
            GAME_STATE = GAME_END;
            return;
        }
        
        // Timer Text
        if (as3hx.Compat.truthy(GAME_FRAME % 30 == 0 && uiProgressDisplayText.visible))
        {
            uiProgressDisplayText.update(TimeUtil.convertToHMSS(Math.ceil((gameLastNoteFrame - GAME_FRAME) / 30)));
        }
        
        // Note Spawning
        var nextNote                       : Dynamic= uiNoteField.nextNote;
        while (as3hx.Compat.truthy(nextNote && nextNote.frame <= GAME_FRAME + JUDGE_OFFSET_FRAMES + 5))
        {
            uiNoteField.spawnArrow(nextNote, (GAME_FRAME + JUDGE_OFFSET_FRAMES + 5) / 30 * 1000);
            nextNote = uiNoteField.nextNote;
        }
        
        // Missed Notes
        var notes                       : Dynamic= uiNoteField.notes;
        var n                     : Dynamic= 0;
        while (as3hx.Compat.truthy(n < notes.length))
        {
            var curNote                       : Dynamic= notes[n];
            
            if (as3hx.Compat.truthy(GAME_FRAME - curNote.FRAME + JUDGE_OFFSET_FRAMES >= 6))
            {
                commitJudge(curNote.DIR, GAME_FRAME, -10, curNote.POSITION + 200, curNote.FRAME);
                uiNoteField.removeNote(curNote.ID);
                n--;
            }
            else
            {
                break;
            }
            n++;
        }
        
        // Auto Play
        if (as3hx.Compat.truthy(options.isAutoplay))
        {
            tickAutoplay();
        }
        // Replays
        else if (as3hx.Compat.truthy(options.replay && !options.replay.isPreview))
        {
            tickReplays();
        }
        // Multiplayer Spectator
        else if (as3hx.Compat.truthy(isMultiplayerSpectator))
        {
            tickSpectator();
        }
    }
    
    public function tickAutoplay() : Void
    {
        var notes                       : Dynamic= uiNoteField.notes;
        var n                     : Dynamic= 0;
        while (as3hx.Compat.truthy(n < notes.length))
        {
            var curNote                       : Dynamic= notes[n];
            
            if (as3hx.Compat.truthy(GAME_FRAME - curNote.FRAME + JUDGE_OFFSET_FRAMES >= 0))
            {
                var isDec                       : Dynamic= (Math.floor(curNote.ID / 32) & 1) == 1;
                var offset                       : Dynamic= as3hx.Compat.parseInt(((isDec) ? 32 - (curNote.ID % 32) : (curNote.ID % 32)) - 16);
                
                if (as3hx.Compat.truthy(options.isEditor))
                {
                    commitJudge(curNote.DIR, curNote.FRAME + JUDGE_OFFSET_FRAMES, 50, curNote.POSITION, curNote.FRAME);
                    uiNoteField.removeNote(curNote.ID);
                }
                else
                {
                    judgeScorePosition(curNote.DIR, curNote.POSITION - JUDGE_OFFSET_MS + offset);
                }
                
                if (as3hx.Compat.truthy(isMultiplayer))
                {
                    spectatorHistory.push(new GamePlaybackSpectatorHit(spectatorHistory.length, curNote.POSITION - JUDGE_OFFSET_MS + offset, curNote.DIR));
                }
                n--;
            }
        }
    }
    
    public function tickReplays() : Void
    {
        var notes                       : Dynamic= uiNoteField.notes;
        var newPress                       : Dynamic= options.replay.getPress(replayPressCount);
        
        if (as3hx.Compat.truthy(options.replay.needsBeatboxGeneration))
        {
            var oldPosition                       : Dynamic= GAME_TIME;
            GAME_TIME = as3hx.Compat.parseInt((GAME_FRAME + 0.5) * 1000 / 30);
            var cutOffReplayNote                       : Dynamic= options.replay.generationReplayNotes.length;
            var readAheadTime                       : Dynamic= (1 / frameRate.value) * 1000;
            
            // Note Hits
            var n                     : Dynamic= 0;
            while (as3hx.Compat.truthy(n < notes.length))
            {
                var curNote                       : Dynamic= notes[n];
                
                // Missed Note
                if (as3hx.Compat.truthy(curNote.ID >= cutOffReplayNote || (options.replay.generationReplayNotes[curNote.ID] == null || Math.isNaN(options.replay.generationReplayNotes[curNote.ID].time))))
                {
                    continue;
                }
                
                var diffValue                       : Dynamic= as3hx.Compat.parseInt(options.replay.generationReplayNotes[curNote.ID].time + curNote.POSITION);
                if (as3hx.Compat.truthy((GAME_TIME + readAheadTime >= diffValue) || GAME_TIME >= diffValue))
                {
                    judgeScorePosition(curNote.DIR, diffValue);
                    n--;
                }
            }
            
            // Boo Handling
            while (as3hx.Compat.truthy(newPress != null && GAME_TIME >= newPress.time))
            {
                if (as3hx.Compat.truthy(newPress.frame == -2))
                {
                    commitJudge(newPress.direction, GAME_FRAME, -5, newPress.time);
                    binReplayBoos[binReplayBoos.length] = new ReplayBinFrame(newPress.time, newPress.direction, binReplayBoos.length);
                }
                replayPressCount++;
                newPress = options.replay.getPress(replayPressCount);
            }
            
            GAME_TIME = oldPosition;
        }
        else
        {
            while (as3hx.Compat.truthy(newPress != null && newPress.frame == GAME_FRAME))
            {
                judgeScore(newPress.direction, newPress.frame);
                
                replayPressCount++;
                newPress = options.replay.getPress(replayPressCount);
            }
        }
    }
    
    public function tickSpectator() : Void
    {
        if (as3hx.Compat.truthy(spectatorHistory.length <= 0 || replayPressCount >= spectatorHistory.length))
        {
            return;
        }
        
        var oldPosition                       : Dynamic= GAME_TIME;
        
        GAME_TIME = as3hx.Compat.parseInt((GAME_FRAME + 0.5) * 1000 / 30);
        
        var hit                       : Dynamic= as3hx.Compat.field(spectatorHistory, replayPressCount);
        
        while (as3hx.Compat.truthy(replayPressCount < spectatorHistory.length))
        {
            hit = as3hx.Compat.field(spectatorHistory, replayPressCount);
            
            if (as3hx.Compat.truthy(hit.timestamp > GAME_TIME))
            {
                break;
            }
            
            // Skip Non-hits
            if (as3hx.Compat.truthy(hit.id == GamePlaybackSpectatorHit.ID))
            {
                judgeScorePosition((try cast(hit, GamePlaybackSpectatorHit) catch(e:Dynamic) null).direction, hit.timestamp);
                replayPressCount++;
            }
            else if (as3hx.Compat.truthy(hit.id == GamePlaybackSpectatorEnd.ID))
            {
                GAME_STATE = GAME_END;
                break;
            }
            else
            {
                replayPressCount++;
            }
        }
        
        GAME_TIME = oldPosition;
    }
    
    public function togglePause() : Void
    {
        if (as3hx.Compat.truthy(GAME_STATE == GAME_PLAY))
        {
            GAME_STATE = GAME_PAUSE;
            songPausePosition = Math.round(haxe.Timer.stamp() * 1000);
            song.pause();
            
            if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
            {
                _gvars.websocketSend("SONG_PAUSE", SOCKET_SONG_MESSAGE);
            }
        }
        else if (as3hx.Compat.truthy(GAME_STATE == GAME_PAUSE))
        {
            GAME_STATE = GAME_PLAY;
            absoluteStart += as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - songPausePosition);
            song.resume();
            
            if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
            {
                _gvars.websocketSend("SONG_RESUME", SOCKET_SONG_MESSAGE);
            }
        }
    }
    
    public function endGame() : Void
    {
        if (as3hx.Compat.truthy(GAME_STATE == GAME_DISPOSE || song == null))
        {
            return;
        }
        
        // Save Editor
        if (as3hx.Compat.truthy(options.isEditor))
        {
            layoutManager.save();
            _gvars.activeUser.saveLocal();
            _gvars.activeUser.save();
        }
        
        // Stop Music Play
        song.stop();
        
        // Play through to the end of a replay
        if (as3hx.Compat.truthy(options.replay))
        {
            GAME_STATE = GAME_PLAY;
            while (as3hx.Compat.truthy(gameLife > 0 && GAME_STATE == GAME_PLAY))
            {
                logicTick();
            }
            GAME_STATE = GAME_END;
        }
        
        // Multiplayer
        var wasMultiplayer                       : Dynamic= isMultiplayer;
        if (as3hx.Compat.truthy(isMultiplayer))
        {
            spectatorHistory.push(new GamePlaybackSpectatorEnd(spectatorHistory.length, Math.round(haxe.Timer.stamp() * 1000) - absoluteStart + songOffset.value));
            e_onMPTimerTick();
        }
        else if (as3hx.Compat.truthy(isMultiplayer || isMultiplayerSpectator))
        {
            e_destroyMultiplayer();
        }
        
        // Save results for display
        if (as3hx.Compat.truthy(!options.isEditor && !options.isSpectator))
        {
            if (as3hx.Compat.truthy(autoplayCount > 0))
            {
                options.isAutoplay = true;
            }
            
            // Fill missing notes from replay.
            if (as3hx.Compat.truthy(gameReplayHit.length > 0))
            {
                while (as3hx.Compat.truthy(gameReplayHit.length < song.totalNotes))
                {
                    gameReplayHit.push(-5);
                }
            }
            gameReplayHit.push(-10);
            gameReplay.sort(ReplayNote.sortFunction);
            
            var noteCount                       : Dynamic= as3hx.Compat.parseInt(hitAmazing + hitPerfect + hitGood + hitAverage + hitMiss);
            
            var newGameResults                       : Dynamic= new GameScoreResult();
            newGameResults.game_index = _gvars.gameIndex++;
            newGameResults.level = song.id;
            newGameResults.song = song;
            newGameResults.songInfo = song.songInfo;
            newGameResults.note_count = song.totalNotes;
            newGameResults.amazing = hitAmazing;
            newGameResults.perfect = hitPerfect;
            newGameResults.good = hitGood;
            newGameResults.average = hitAverage;
            newGameResults.boo = hitBoo;
            newGameResults.miss = hitMiss;
            newGameResults.combo = hitCombo;
            newGameResults.max_combo = hitMaxCombo;
            newGameResults.score = gameScore;
            newGameResults.last_note = (noteCount < song.totalNotes) ? noteCount : 0;
            newGameResults.accuracy = accuracy.value;
            newGameResults.accuracy_deviation = accuracy.deviation;
            newGameResults.options = this.options;
            newGameResults.restart_stats = _gvars.songStats.data;
            newGameResults.replayData = gameReplay.copy();
            newGameResults.replay_hit = gameReplayHit.copy();
            newGameResults.replay_bin_notes = binReplayNotes;
            newGameResults.replay_bin_boos = binReplayBoos;
            newGameResults.user = (options.replay) ? options.replay.user : _gvars.activeUser;
            newGameResults.restarts = (options.replay) ? 0 : _gvars.songRestarts;
            newGameResults.start_time = _gvars.songStartTime;
            newGameResults.start_hash = _gvars.songStartHash;
            newGameResults.end_time = (options.replay) ? TimeUtil.getFormattedDate(Date.fromTime(as3hx.Compat.parseFloat(options.replay.timestamp) * 1000)) : TimeUtil.getCurrentDate();
            newGameResults.song_progress = (GAME_FRAME / gameLastNoteFrame);
            
            // Set Note Counts for Preview Songs
            if (as3hx.Compat.truthy(options.replay && options.replay.isPreview))
            {
                newGameResults.is_preview = true;
                newGameResults.score = song.totalNotes * 50;
                newGameResults.amazing = song.totalNotes;
                newGameResults.max_combo = song.totalNotes;
            }
            
            newGameResults.update(_gvars);
            _gvars.songResults.push(newGameResults);
        }
        
        if (as3hx.Compat.truthy(!options.replay && !options.isEditor && !options.isSpectator))
        {
            _gvars.sessionStats.addFromStats(_gvars.songStats);
            _gvars.songStats.reset();
            
            _avars.configMusicOffset = (_avars.configMusicOffset * 0.85) + songOffset.value * 0.15;
            
            // Cap between 5 seconds for sanity.
            if (as3hx.Compat.truthy(Math.abs(_avars.configMusicOffset) >= 5000))
            {
                _avars.configMusicOffset = Math.max(-5000, Math.min(5000, _avars.configMusicOffset));
            }
            
            _avars.musicOffsetSave();
        }
        
        // Websocket
        if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
        {
            Reflect.setField(SOCKET_SCORE_MESSAGE, "amazing", hitAmazing);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "perfect", hitPerfect);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "good", hitGood);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "average", hitAverage);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "boo", hitBoo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "miss", hitMiss);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "combo", hitCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "maxcombo", hitMaxCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "score", gameScore);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "last_hit", null);
            _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
            _gvars.websocketSend("SONG_END", SOCKET_SONG_MESSAGE);
        }
        
        // Cleanup
        initPlayerVars();
        
        if (as3hx.Compat.truthy(song != null))
        {
            song.stop();
            song = null;
        }
        
        interfaceDestroy();
        
        GAME_STATE = GAME_DISPOSE;
        
        // Go to results
        if (as3hx.Compat.truthy(options.isEditor || options.isSpectator))
        {
            switchTo(Main.GAME_MENU_PANEL);
        }
        else if (as3hx.Compat.truthy(wasMultiplayer))
        {
            switchTo(GameMenu.GAME_MP_WAIT);
        }
        else
        {
            switchTo(GameMenu.GAME_RESULTS);
        }
    }
    
    public function restartGame() : Void
    // Remove Notes
    {
        
        uiNoteField.reset();
        uiPAWindow.reset();
        uiAccuracyBar.onResetSignal();
        uiJudge.hideJudge();
        
        noteBoxOffset.x = 0;
        noteBoxOffset.y = 0;
        
        // Track
        var tempGT                       : Dynamic= ((hitAmazing + hitPerfect) * 500) + (hitGood * 250) + (hitAverage * 50) + (hitCombo * 1000) - (hitMiss * 300) - (hitBoo * 15) + gameScore;
        _gvars.songStats.amazing += hitAmazing;
        _gvars.songStats.perfect += hitPerfect;
        _gvars.songStats.good += hitGood;
        _gvars.songStats.average += hitAverage;
        _gvars.songStats.miss += hitMiss;
        _gvars.songStats.boo += hitBoo;
        _gvars.songStats.raw_score += gameScore;
        _gvars.songStats.amazing += hitAmazing;
        _gvars.songStats.grandtotal += tempGT;
        _gvars.songStats.credits += Math.round(tempGT / _gvars.SCORE_PER_CREDIT);
        _gvars.songStats.restarts++;
        
        // Restart
        song.stop();
        GAME_STATE = GAME_PLAY;
        initGameVars();
        initPlayerVars();
        initSongStart();
        
        _gvars.songRestarts++;
        
        // Websocket
        if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
        {
            Reflect.setField(SOCKET_SCORE_MESSAGE, "restarts", _gvars.songRestarts);
            _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
            _gvars.websocketSend("SONG_RESTART", SOCKET_SONG_MESSAGE);
        }
    }
    
    public function stopClips(clip                       : Dynamic, frame                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(clip == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(frame < 2))
        {
            frame = 2;
        }
        
        var _sw0_ = (clip.currentFrame - frame + 1);        

        switch (_sw0_)
        {
            case 0, 1:

                switch (_sw0_)
                {case 0:
                        clip.nextFrame();
                }
            default:
                clip.gotoAndStop(frame);
        }
        
        for (i in 0...clip.numChildren)
        {
            stopClips(try cast(clip.getChildAt(i), MovieClip) catch(e:Dynamic) null, frame);
        }
    }
    
    /*#########################################################################################*\
     *			_____     ___               _   _
     *	 /\ /\  \_   \   / __\ __ ___  __ _| |_(_) ___  _ __
     *	/ / \ \  / /\/  / / | '__/ _ \/ _` | __| |/ _ \| '_ \
     *	\ \_/ /\/ /_   / /__| | |  __/ (_| | |_| | (_) | | | |
     *	 \___/\____/   \____/_|  \___|\__,_|\__|_|\___/|_| |_|
     *
       \*#########################################################################################*/
    
    public function interfaceBuild() : Void
    {
        stage.color = GameBackgroundColor.BG_STAGE;
        
        // Anti-GPU Rampdown Hack
        GPU_PIXEL_BMD = new BitmapData(1, 1, false, 0x010101);
        GPU_PIXEL_BITMAP = new Bitmap(GPU_PIXEL_BMD);
        addChild(GPU_PIXEL_BITMAP);
        
        uiAccuracyBar = new AccuracyBar(options, this);
        uiAccuracyBar.visible = options.displayAccuracyBar;
        
        uiNoteField = new NoteBox(song, options, this);
        uiNoteField.position();
        
        uiScreenCut = new ScreenCut(options, this);
        uiScreenCut.visible = options.displayScreencut;
        
        bgTopBar = new BarTop(options, this);
        bgTopBar.visible = options.displayGameTopBar;
        
        bgBottomBar = new BarBottom(options, this);
        bgBottomBar.visible = options.displayGameBottomBar;
        
        uiPAWindow = new PAWindow(options, this);
        uiPAWindow.visible = options.displayPA;
        
        uiScore = new Score(options, this);
        uiScore.visible = options.displayScore;
        
        uiCombo = new Combo(options, this);
        uiCombo.visible = options.displayCombo;
        uiComboStatic = new TextStatic(_lang.string("game_combo"), this);
        uiComboStatic.visible = options.displayCombo;
        
        uiRawGoods = new RawGoods(options, this);
        uiRawGoods.visible = options.displayRawGoods;
        uiRawGoodsStatic = new TextStatic(_lang.string("game_raw_goods"), this, options.rawGoodsColor, 12);
        uiRawGoodsStatic.visible = options.displayRawGoods;
        
        uiNoteCount = new ComboTotal(options, this);
        uiNoteCount.visible = options.displayComboTotal;
        uiNoteCountStatic = new TextStatic(_lang.string("game_combo_total"), this);
        uiNoteCountStatic.visible = options.displayComboTotal;
        
        uiComboHype = new ComboHypeOverlay(this, options.visualHypeMode);
        setChildIndex(uiComboHype, getChildIndex(uiNoteField));
        
        uiProgressDisplay = new ProgressBarGame(this, 161, 9, 458, 20, 4, 0x545454, 0.1);
        uiProgressDisplay.visible = as3hx.Compat.orValue(options.displaySongProgress, options.replay);
        if (as3hx.Compat.truthy(options.replay))
        {
            uiProgressDisplay.addEventListener(MouseEvent.CLICK, e_progressMouseClick);
        }
        
        uiProgressDisplayText = new TextStatic("0:00", this);
        uiProgressDisplayText.visible = options.displaySongProgressText;
        
        uiJudge = new Judge(options, this);
        if (as3hx.Compat.truthy(options.isEditor))
        {
            uiJudge.showJudge(100, true);
        }
        
        uiLifebar = new LifeBar(this);
        uiLifebar.visible = options.displayHealth;
        
        if (as3hx.Compat.truthy(isMultiplayer || isMultiplayerSpectator || (options.isEditor && options.isMultiplayer)))
        {
            mpuiFFRScores = new MPFFRScoreCompare(options, this, mpFFRRoom);
            mpuiFFRScores.visible = options.displayMultiplayerScores;
        }
    }
    
    public function interfaceDestroy() : Void
    {
        if (as3hx.Compat.truthy(uiSongBackground != null))
        {
            this.removeChild(uiSongBackground);
            uiSongBackground = null;
        }
        
        if (as3hx.Compat.truthy(GPU_PIXEL_BITMAP != null))
        {
            this.removeChild(GPU_PIXEL_BITMAP);
            GPU_PIXEL_BITMAP = null;
            GPU_PIXEL_BMD = null;
        }
        if (as3hx.Compat.truthy(uiProgressDisplay != null))
        {
            this.removeChild(uiProgressDisplay);
            uiProgressDisplay = null;
        }
        if (as3hx.Compat.truthy(uiLifebar != null))
        {
            this.removeChild(uiLifebar);
            uiLifebar = null;
        }
        if (as3hx.Compat.truthy(uiJudge != null))
        {
            this.removeChild(uiJudge);
            uiJudge = null;
        }
        if (as3hx.Compat.truthy(uiComboHype != null))
        {
            this.removeChild(uiComboHype);
            uiComboHype = null;
        }
        if (as3hx.Compat.truthy(bgTopBar != null))
        {
            this.removeChild(bgTopBar);
            bgTopBar = null;
        }
        if (as3hx.Compat.truthy(bgBottomBar != null))
        {
            this.removeChild(bgBottomBar);
            bgBottomBar = null;
        }
        if (as3hx.Compat.truthy(uiNoteField != null))
        {
            uiNoteField.reset();
            this.removeChild(uiNoteField);
            uiNoteField = null;
        }
        if (as3hx.Compat.truthy(uiAccuracyBar != null))
        {
            this.removeChild(uiAccuracyBar);
            uiAccuracyBar = null;
        }
        if (as3hx.Compat.truthy(uiScreenCut != null))
        {
            this.removeChild(uiScreenCut);
            uiScreenCut = null;
        }
    }
    
    public function interfaceSetup() : Void
    {
        noteBoxPositionDefault = layoutManager.interfaceLayout(GameLayoutManager.LAYOUT_RECEPTORS);
        
        // Position
        layoutManager.interfacePosition(bgTopBar, GameLayoutManager.LAYOUT_BAR_TOP);
        layoutManager.interfacePosition(bgBottomBar, GameLayoutManager.LAYOUT_BAR_BOTTOM);
        layoutManager.interfacePosition(uiProgressDisplay, GameLayoutManager.LAYOUT_PROGRESS_BAR);
        layoutManager.interfacePosition(uiProgressDisplayText, GameLayoutManager.LAYOUT_PROGRESS_TEXT);
        layoutManager.interfacePosition(uiNoteField, GameLayoutManager.LAYOUT_RECEPTORS);
        layoutManager.interfacePosition(uiAccuracyBar, GameLayoutManager.LAYOUT_ACCURACY_BAR);
        layoutManager.interfacePosition(uiLifebar, GameLayoutManager.LAYOUT_HEALTH);
        layoutManager.interfacePosition(uiScore, GameLayoutManager.LAYOUT_SCORE);
        layoutManager.interfacePosition(uiNoteCount, GameLayoutManager.LAYOUT_TOTAL);
        layoutManager.interfacePosition(uiComboStatic, GameLayoutManager.LAYOUT_COMBO_STATIC);
        layoutManager.interfacePosition(uiNoteCountStatic, GameLayoutManager.LAYOUT_TOTAL_STATIC);
        layoutManager.interfacePosition(uiRawGoodsStatic, GameLayoutManager.LAYOUT_RAWGOODS_STATIC);
        
        layoutManager.interfacePosition(uiPAWindow, GameLayoutManager.LAYOUT_PA);
        layoutManager.interfacePosition(uiCombo, GameLayoutManager.LAYOUT_COMBO);
        layoutManager.interfacePosition(uiRawGoods, GameLayoutManager.LAYOUT_RAWGOODS);
        layoutManager.interfacePosition(uiJudge, GameLayoutManager.LAYOUT_JUDGE);
        
        layoutManager.interfacePosition(mpuiFFRScores, GameLayoutManager.LAYOUT_MP_FFR_SCORE);
        
        _laneGuideValid = false;
        updateLaneGuideEffects(true);
    }
    
    private function updateLaneGuideEffects(force                       : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(uiNoteField == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(!force && !needsLaneGuideUpdate()))
        {
            return;
        }
        
        var rect                       : Dynamic= uiNoteField.getLaneGuideRect(this, _laneGuideRect);
        if (as3hx.Compat.truthy(uiAccuracyBar != null))
        {
            if (as3hx.Compat.truthy(Math.abs(uiAccuracyBar.width - rect.width) > 0.5))
            {
                uiAccuracyBar.width = rect.width;
            }
            
            if (as3hx.Compat.truthy(Math.abs(uiAccuracyBar.height - rect.height) > 0.5))
            {
                uiAccuracyBar.height = rect.height;
            }
            
            _accuracyGuideBaseX = rect.x + rect.width / 2;
            _accuracyGuideBaseY = rect.y + rect.height / 2;
            uiAccuracyBar.x = _accuracyGuideBaseX;
            uiAccuracyBar.y = _accuracyGuideBaseY;
            uiAccuracyBar.rotation = 0;
        }
        
        if (as3hx.Compat.truthy(uiComboHype != null))
        {
            uiNoteField.getLaneGuideEdges(this, _laneGuideEdges);
            uiComboHype.setLaneBounds(rect.x, rect.y, rect.width, rect.height);
            uiComboHype.setLaneEdges(_laneGuideEdges);
        }
        
        rememberLaneGuideState();
        _laneGuideValid = true;
    }
    
    private function needsLaneGuideUpdate() : Bool
    {
        if (as3hx.Compat.truthy(!_laneGuideValid))
        {
            return true;
        }
        
        if (as3hx.Compat.truthy(options != null && (options.modEnabled("wave") || options.modEnabled("tap_pulse") || options.modEnabled("drunk") || options.modEnabled("dizzy"))))
        {
            return true;
        }
        
        if (as3hx.Compat.truthy(stage))
        {
            if (as3hx.Compat.truthy(stage.displayState != _laneGuideLastDisplayState || stage.stageWidth != _laneGuideLastStageWidth || stage.stageHeight != _laneGuideLastStageHeight))
            {
                return true;
            }
        }
        
        var receptorMinX                       : Dynamic= Math.min(Math.min(Math.min(uiNoteField.leftReceptor.x, uiNoteField.downReceptor.x), uiNoteField.upReceptor.x), uiNoteField.rightReceptor.x);
        var receptorMaxX                       : Dynamic= Math.max(Math.max(Math.max(uiNoteField.leftReceptor.x, uiNoteField.downReceptor.x), uiNoteField.upReceptor.x), uiNoteField.rightReceptor.x);
        var receptorMinY                       : Dynamic= Math.min(Math.min(Math.min(uiNoteField.leftReceptor.y, uiNoteField.downReceptor.y), uiNoteField.upReceptor.y), uiNoteField.rightReceptor.y);
        var receptorMaxY                       : Dynamic= Math.max(Math.max(Math.max(uiNoteField.leftReceptor.y, uiNoteField.downReceptor.y), uiNoteField.upReceptor.y), uiNoteField.rightReceptor.y);
        if (Math.abs(receptorMinX - _laneGuideLastReceptorMinX) > 0.25 ||
            Math.abs(receptorMaxX - _laneGuideLastReceptorMaxX) > 0.25 ||
            Math.abs(receptorMinY - _laneGuideLastReceptorMinY) > 0.25 ||
            Math.abs(receptorMaxY - _laneGuideLastReceptorMaxY) > 0.25)
        {
            return true;
        }
        
        return Math.abs(uiNoteField.x - _laneGuideLastFieldX) > 0.25 ||
        Math.abs(uiNoteField.y - _laneGuideLastFieldY) > 0.25 ||
        Math.abs(uiNoteField.scaleX - _laneGuideLastFieldScaleX) > 0.001 ||
        Math.abs(uiNoteField.scaleY - _laneGuideLastFieldScaleY) > 0.001 ||
        Math.abs(uiNoteField.rotation - _laneGuideLastFieldRotation) > 0.001;
    }
    
    private function rememberLaneGuideState() : Void
    {
        _laneGuideLastDisplayState = (stage != null) ? stage.displayState : "";
        _laneGuideLastStageWidth = (stage != null) ? stage.stageWidth : 0;
        _laneGuideLastStageHeight = (stage != null) ? stage.stageHeight : 0;
        _laneGuideLastFieldX = uiNoteField.x;
        _laneGuideLastFieldY = uiNoteField.y;
        _laneGuideLastFieldScaleX = uiNoteField.scaleX;
        _laneGuideLastFieldScaleY = uiNoteField.scaleY;
        _laneGuideLastFieldRotation = uiNoteField.rotation;
        _laneGuideLastReceptorMinX = Math.min(Math.min(Math.min(uiNoteField.leftReceptor.x, uiNoteField.downReceptor.x), uiNoteField.upReceptor.x), uiNoteField.rightReceptor.x);
        _laneGuideLastReceptorMaxX = Math.max(Math.max(Math.max(uiNoteField.leftReceptor.x, uiNoteField.downReceptor.x), uiNoteField.upReceptor.x), uiNoteField.rightReceptor.x);
        _laneGuideLastReceptorMinY = Math.min(Math.min(Math.min(uiNoteField.leftReceptor.y, uiNoteField.downReceptor.y), uiNoteField.upReceptor.y), uiNoteField.rightReceptor.y);
        _laneGuideLastReceptorMaxY = Math.max(Math.max(Math.max(uiNoteField.leftReceptor.y, uiNoteField.downReceptor.y), uiNoteField.upReceptor.y), uiNoteField.rightReceptor.y);
    }
    
    private function updateTapPulseOffset() : Void
    {
        if (as3hx.Compat.truthy(uiNoteField == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("tap_pulse")))
        {
            noteBoxOffset.x = Math.max(Math.min((Math.abs(noteBoxOffset.x) < 0.5) ? 0 : (noteBoxOffset.x * 0.992), uiNoteField.positionOffsetMax.max_x), uiNoteField.positionOffsetMax.min_x);
            noteBoxOffset.y = Math.max(Math.min((Math.abs(noteBoxOffset.y) < 0.5) ? 0 : (noteBoxOffset.y * 0.992), uiNoteField.positionOffsetMax.max_y), uiNoteField.positionOffsetMax.min_y);
        }
        else
        {
            noteBoxOffset.x = 0;
            noteBoxOffset.y = 0;
        }
    }
    
    private function applyFieldVisualOffset(shakeX                       : Dynamic, shakeY                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(uiNoteField != null && noteBoxPositionDefault != null))
        {
            uiNoteField.x = noteBoxPositionDefault.x + noteBoxOffset.x + shakeX;
            uiNoteField.y = noteBoxPositionDefault.y + noteBoxOffset.y + shakeY;
        }
        
        if (as3hx.Compat.truthy(uiAccuracyBar != null))
        {
            uiAccuracyBar.x = _accuracyGuideBaseX + shakeX;
            uiAccuracyBar.y = _accuracyGuideBaseY + shakeY;
        }
        
        if (as3hx.Compat.truthy(uiComboHype != null))
        {
            uiComboHype.x = shakeX;
            uiComboHype.y = shakeY;
        }
    }
    
    public function interfaceSetupEditor() : Void
    {
        interfaceEditor(bgTopBar, GameLayoutManager.LAYOUT_BAR_TOP);
        interfaceEditor(bgBottomBar, GameLayoutManager.LAYOUT_BAR_BOTTOM);
        interfaceEditor(uiProgressDisplay, GameLayoutManager.LAYOUT_PROGRESS_BAR);
        interfaceEditor(uiProgressDisplayText, GameLayoutManager.LAYOUT_PROGRESS_TEXT);
        interfaceEditor(uiNoteField, GameLayoutManager.LAYOUT_RECEPTORS);
        interfaceEditor(uiAccuracyBar, GameLayoutManager.LAYOUT_ACCURACY_BAR);
        interfaceEditor(uiLifebar, GameLayoutManager.LAYOUT_HEALTH);
        interfaceEditor(uiScore, GameLayoutManager.LAYOUT_SCORE);
        interfaceEditor(uiNoteCount, GameLayoutManager.LAYOUT_TOTAL);
        interfaceEditor(uiComboStatic, GameLayoutManager.LAYOUT_COMBO_STATIC);
        interfaceEditor(uiNoteCountStatic, GameLayoutManager.LAYOUT_TOTAL_STATIC);
        interfaceEditor(uiRawGoodsStatic, GameLayoutManager.LAYOUT_RAWGOODS_STATIC);
        
        interfaceEditor(uiPAWindow, GameLayoutManager.LAYOUT_PA);
        interfaceEditor(uiCombo, GameLayoutManager.LAYOUT_COMBO);
        interfaceEditor(uiRawGoods, GameLayoutManager.LAYOUT_RAWGOODS);
        interfaceEditor(uiJudge, GameLayoutManager.LAYOUT_JUDGE);
        
        interfaceEditor(mpuiFFRScores, GameLayoutManager.LAYOUT_MP_FFR_SCORE);
        
        var helpFormat                       : Dynamic= new TextFormat(Fonts.BASE_FONT_CJK);
        helpFormat.align = "center";
        
        var editorShortcut                       : Dynamic= new TextField();
        editorShortcut.x = 10;
        editorShortcut.width = Main.GAME_WIDTH - 20;
        editorShortcut.selectable = false;
        editorShortcut.embedFonts = true;
        editorShortcut.antiAliasType = AntiAliasType.ADVANCED;
        editorShortcut.defaultTextFormat = Constant.TEXT_FORMAT_CENTER_12;
        editorShortcut.htmlText = _lang.string("editor_menu_shortcut");
        editorShortcut.y = (Main.GAME_HEIGHT / 2);
        editorShortcut.alpha = 0.5;
        this.addChildAt(editorShortcut, 0);
        
        hitAmazing = 4321;
        hitPerfect = 1234;
        hitGood = 876;
        hitAverage = 543;
        hitMiss = 321;
        hitBoo = 111;
        hitCombo = 8000;
        gameRawGoods = 184.2;
        gameScore = 55555;
        uiNoteCount.update(9999);
        updateFieldVars();
    }
    
    public function interfaceEditor(sprite                       : Dynamic, key                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(sprite == null))
        {
            return;
        }
        
        sprite.mouseChildren = false;
        sprite.buttonMode = true;
        sprite.useHandCursor = true;
        
        var layout                       : Dynamic= layoutManager.interfaceLayout(key, false);
        
        // Advanced Editor (for Supporting)
        if (as3hx.Compat.truthy(Std.is(sprite, GameControl)))
        {
            var __DOLLAR__cast                       : Dynamic= try cast(sprite, GameControl) catch(e:Dynamic) null;
            __DOLLAR__cast.editorLayout = layout;
            //cast.drawDebugBounds();
            
            sprite.addEventListener(MouseEvent.CLICK, function(e                       : Dynamic) : Void
                    {
                        if (as3hx.Compat.truthy(e.ctrlKey))
                        {
                            var editMenu                       : Dynamic= null;
                            for (spriteMenu in as3hx.Compat.iter(editorSpriteMenus))
                            {
                                if (as3hx.Compat.truthy(as3hx.Compat.field(spriteMenu, 0) == sprite))
                                {
                                    editMenu = as3hx.Compat.field(spriteMenu, 1);
                                    break;
                                }
                            }
                            
                            // Reuse Menu
                            if (as3hx.Compat.truthy(editMenu != null))
                            {
                                editMenu.position();
                            }
                            // Create New Editor
                            else
                            {
                                
                                {
                                    editMenu = __DOLLAR__cast.getEditorInterface();
                                    editMenu.finalize();
                                    editorSpriteMenus.push([__DOLLAR__cast, editMenu]);
                                    editMenu.addEventListener(Event.CLOSE, function(e                       : Dynamic) : Void
                                            {
                                                for (i in 0...editorSpriteMenus.length)
                                                {
                                                    if (as3hx.Compat.truthy(editorSpriteMenus[i][0] == sprite))
                                                    {
                                                        editorSpriteMenus.splice(i, 1);
                                                        break;
                                                    }
                                                }
                                            });
                                    
                                    addChild(editMenu);
                                }
                            }
                        }
                    });
        }
        
        // UI Dragging
        dragStart = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(!e.ctrlKey))
            {
                stage.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
                sprite.startDrag(false);
            }
        };
        
        dragEnd = function(e                       : Dynamic) : Void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, dragEnd);
            sprite.stopDrag();
            sprite.dispatchEvent(new Event(Event.CHANGE));
            
            Reflect.setField(layout, "x", sprite.x);
            Reflect.setField(layout, "y", sprite.y);
        }
        
        sprite.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
    }
    
    /*#########################################################################################*\
     *	   ___                           _
     *	  / _ \__ _ _ __ ___   ___ _ __ | | __ _ _   _
     *	 / /_\/ _` | '_ ` _ \ / _ \ '_ \| |/ _` | | | |
     *	/ /_\\ (_| | | | | | |  __/ |_) | | (_| | |_| |
     *	\____/\__,_|_| |_| |_|\___| .__/|_|\__,_|\__, |
     *							  |_|            |___/
       \*#########################################################################################*/
    
    public function buildJudgeNodes(src                       : Dynamic) : Array<JudgeNode>
    {
        var out                       : Dynamic= new Array<JudgeNode>();
        for (i in 0...src.length)
        {
            out[i] = new JudgeNode(src[i].t, src[i].s, src[i].f);
        }
        return out;
    }
    
    /**
     * Judge a note score based on the current song position in ms.
     * @param dir Note Direction
     * @param position Time in MS.
     * @return
     */
    public function judgeScorePosition(dir                       : Dynamic, position                       : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(position < 0))
        {
            position = 0;
        }
        
        var positionJudged                       : Dynamic= as3hx.Compat.parseInt(position + JUDGE_OFFSET_MS);
        
        var score                     : Dynamic= 0;
        var frame                     : Dynamic= 0;
        var booConflict                     : Dynamic= false;
        var note                     : Dynamic= null;
        var rawAccuracy                     : Dynamic= 0;
        var judgeAccuracy                     : Dynamic= 0;
        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))
        {
            note = noteCandidate;
            if (as3hx.Compat.truthy(note.DIR != dir))
            {
                continue;
            }
            
            rawAccuracy = note.POSITION - position;
            judgeAccuracy = positionJudged - note.POSITION;
            var lastJudge                       : Dynamic= null;
            for (j in as3hx.Compat.iter(judgeSettings))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(judgeAccuracy) > as3hx.Compat.parseFloat(j.time)))
                {
                    lastJudge = j;
                }
            }
            score = (lastJudge != null) ? lastJudge.score : 0;
            
            if (as3hx.Compat.truthy(score != 0))
            {
                frame = lastJudge.frame;
            }
            
            if (as3hx.Compat.truthy(!_avars.configJudge && score == 0))
            {
                var pdiff                       : Dynamic= as3hx.Compat.parseInt(GAME_FRAME - note.FRAME + JUDGE_OFFSET_FRAMES);
                if (as3hx.Compat.truthy(pdiff >= -3 && pdiff <= 3))
                {
                    booConflict = true;
                }
            }
            
            if (as3hx.Compat.truthy(score > 0))
            {
                break;
            }
            else if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(judgeAccuracy) <= as3hx.Compat.parseFloat(judgeSettings[0].time)))
            {
                break;
            }
        }
        
        if (as3hx.Compat.truthy(score != 0))
        {
            commitJudge(dir, frame + note.FRAME - JUDGE_OFFSET_FRAMES, score, position, note.FRAME);
            uiNoteField.removeNote(note.ID);
            accuracy.addValue(rawAccuracy);
            binReplayNotes[note.ID].time = judgeAccuracy;
            
            if (as3hx.Compat.truthy(uiAccuracyBar.visible))
            {
                uiAccuracyBar.onScoreSignal(score, judgeAccuracy);
            }
        }
        else
        {
            var booFrame                       : Dynamic= GAME_FRAME;
            if (as3hx.Compat.truthy(booConflict))
            {
                var noteIndex                       : Dynamic= 0;
                note = ((as3hx.Compat.parseInt(noteIndex) < as3hx.Compat.parseInt(uiNoteField.notes.length - 1)) ? uiNoteField.notes[as3hx.Compat.parseInt(noteIndex++)] : uiNoteField.spawnNextNote());
                while (as3hx.Compat.truthy(note))
                {
                    if (as3hx.Compat.truthy(booFrame + JUDGE_OFFSET_FRAMES < note.FRAME - 3))
                    {
                        break;
                    }
                    if (as3hx.Compat.truthy(note.DIR == dir))
                    {
                        booFrame = as3hx.Compat.parseInt(note.FRAME + 4 - JUDGE_OFFSET_FRAMES);
                    }
                    
                    note = ((as3hx.Compat.parseInt(noteIndex) < as3hx.Compat.parseInt(uiNoteField.notes.length - 1)) ? uiNoteField.notes[as3hx.Compat.parseInt(noteIndex++)] : uiNoteField.spawnNextNote());
                }
            }
            
            if (as3hx.Compat.truthy(booFrame >= gameFirstNoteFrame))
            {
                binReplayBoos[binReplayBoos.length] = new ReplayBinFrame(position, dir, binReplayBoos.length);
            }
            
            commitJudge(dir, booFrame, -5, position);
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("tap_pulse")))
        {
            if (as3hx.Compat.truthy(dir == "L"))
            {
                noteBoxOffset.x -= Math.abs(options.receptorSpacing * 0.20);
            }
            if (as3hx.Compat.truthy(dir == "R"))
            {
                noteBoxOffset.x += Math.abs(options.receptorSpacing * 0.20);
            }
            if (as3hx.Compat.truthy(dir == "U"))
            {
                noteBoxOffset.y -= Math.abs(options.receptorSpacing * 0.15);
            }
            if (as3hx.Compat.truthy(dir == "D"))
            {
                noteBoxOffset.y += Math.abs(options.receptorSpacing * 0.15);
            }
        }
        
        return score > 0;
    }
    
    public function judgeScore(dir                       : Dynamic, frame                       : Dynamic) : Bool
    {
        var score                     : Dynamic= 0;
        var note                     : Dynamic= null;
        var diff                     : Dynamic= 0;
        for (noteCandidate in as3hx.Compat.iter(uiNoteField.notes))
        {
            note = noteCandidate;
            if (as3hx.Compat.truthy(note.DIR != dir))
            {
                continue;
            }
            
            diff = as3hx.Compat.parseInt(frame + JUDGE_OFFSET_FRAMES - note.FRAME);
            switch (diff)
            {
                case -3:
                    score = 5;
                case -2:
                    score = 25;
                case -1:
                    score = 50;
                case 0:
                    score = 100;
                case 1:
                    score = 50;
                case 2, 3:
                    score = 25;
                default:
                    score = 0;
            }
            
            if (as3hx.Compat.truthy(score > 0))
            {
                break;
            }
            else if (as3hx.Compat.truthy(diff < -3))
            {
                break;
            }
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("tap_pulse")))
        {
            if (as3hx.Compat.truthy(dir == "L"))
            {
                noteBoxOffset.x -= Math.abs(options.receptorSpacing * 0.20);
            }
            if (as3hx.Compat.truthy(dir == "R"))
            {
                noteBoxOffset.x += Math.abs(options.receptorSpacing * 0.20);
            }
            if (as3hx.Compat.truthy(dir == "U"))
            {
                noteBoxOffset.y -= Math.abs(options.receptorSpacing * 0.15);
            }
            if (as3hx.Compat.truthy(dir == "D"))
            {
                noteBoxOffset.y += Math.abs(options.receptorSpacing * 0.15);
            }
        }
        
        if (as3hx.Compat.truthy(score != 0))
        {
            commitJudge(dir, frame, score, note.POSITION, note.FRAME);
            uiNoteField.removeNote(note.ID);
            accuracy.addValue((note.FRAME - frame) * 1000 / 30);
            
            if (as3hx.Compat.truthy(uiAccuracyBar.visible))
            {
                uiAccuracyBar.onScoreSignal(score, diff * 33.3333 - 1);
            }
        }
        else
        {
            commitJudge(dir, frame, -5, note.POSITION);
        }
        
        return cast(score, Bool);
    }
    
    private function getChordImpactCount(noteFrame                       : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(noteFrame < 0 || uiNoteField == null || !uiNoteField.notes))
        {
            return 1;
        }
        
        if (as3hx.Compat.truthy(_chordImpactFrame == noteFrame))
        {
            return _chordImpactCount;
        }
        
        var count                       : Dynamic= 0;
        var notes                       : Dynamic= uiNoteField.notes;
        for (note in as3hx.Compat.iter(notes))
        {
            if (as3hx.Compat.truthy(note.FRAME == noteFrame))
            {
                count++;
                if (as3hx.Compat.truthy(count >= 4))
                {
                    break;
                }
            }
            else if (as3hx.Compat.truthy(count > 0 && as3hx.Compat.parseFloat(note.FRAME) > as3hx.Compat.parseFloat(noteFrame)))
            {
                break;
            }
        }
        
        _chordImpactFrame = noteFrame;
        if (as3hx.Compat.truthy(count <= 1))
        {
            _chordImpactCount = 1;
        }
        else if (as3hx.Compat.truthy(count >= 4))
        {
            _chordImpactCount = 4;
        }
        else
        {
            _chordImpactCount = count;
        }
        
        return _chordImpactCount;
    }
    
    private function getVisualImpactCount(noteFrame                       : Dynamic, score                       : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(score <= 0))
        {
            return 1;
        }
        
        var impactCount                       : Dynamic= getChordImpactCount(noteFrame);
        if (as3hx.Compat.truthy(impactCount <= 1))
        {
            return 1;
        }
        
        if (as3hx.Compat.truthy(_lastVisualImpactFrame == noteFrame))
        {
            return 1;
        }
        
        _lastVisualImpactFrame = noteFrame;
        return impactCount;
    }
    
    public function commitJudge(dir                       : Dynamic, frame                       : Dynamic, score                       : Dynamic, position                       : Dynamic, noteFrame                       : Dynamic= -1) : Void
    {
        var health                       : Dynamic= 0;
        var jscore                       : Dynamic= score;
        var visualImpactCount                       : Dynamic= getVisualImpactCount(noteFrame, score);
        uiNoteField.receptorFeedback(dir, score);
        switch (score)
        {
            case 100:
                hitAmazing++;
                hitCombo++;
                gameScore += 50;
                health = 1;
                if (as3hx.Compat.truthy(options.displayAmazing))
                {
                    checkAutofail(options.autofail[0], hitAmazing);
                }
                else
                {
                    jscore = 50;
                    checkAutofail(options.autofail[0] + options.autofail[1], hitAmazing + hitPerfect);
                }
                checkAutofail(options.autofail[6], gameRawGoods);
            case 50:
                hitPerfect++;
                hitCombo++;
                gameScore += 50;
                health = 1;
                checkAutofail(options.autofail[1], hitPerfect);
                checkAutofail(options.autofail[6], gameRawGoods);
            case 25:
                hitGood++;
                hitCombo++;
                gameScore += 25;
                gameRawGoods += 1;
                health = 1;
                checkAutofail(options.autofail[2], hitGood);
                checkAutofail(options.autofail[6], gameRawGoods);
            case 5:
                hitAverage++;
                hitCombo++;
                gameScore += 5;
                gameRawGoods += 1.8;
                health = 1;
                checkAutofail(options.autofail[3], hitAverage);
                checkAutofail(options.autofail[6], gameRawGoods);
            case -5:
                if (as3hx.Compat.truthy(frame < gameFirstNoteFrame))
                {
                    return;
                }
                hitBoo++;
                gameScore -= 5;
                gameRawGoods += 0.2;
                health = -1;
                checkAutofail(options.autofail[5], hitBoo);
                checkAutofail(options.autofail[6], gameRawGoods);
            case -10:
                hitMiss++;
                hitCombo = 0;
                gameScore -= 10;
                gameRawGoods += 2.4;
                health = -1;
                checkAutofail(options.autofail[4], hitMiss);
                checkAutofail(options.autofail[6], gameRawGoods);
        }
        
        if (as3hx.Compat.truthy(options.isAutoplay && !options.isEditor))
        {
            gameScore = 0;
            hitAmazing = 0;
            hitPerfect = 0;
            hitGood = 0;
            hitAverage = 0;
        }
        
        if (as3hx.Compat.truthy(options.displayJudge && !options.isEditor))
        {
            uiJudge.showJudge(jscore);
        }
        
        updateHealth((health > 0) ? _gvars.HEALTH_JUDGE_ADD : _gvars.HEALTH_JUDGE_REMOVE);
        
        if (as3hx.Compat.truthy(hitCombo > hitMaxCombo))
        {
            hitMaxCombo = hitCombo;
        }
        
        if (as3hx.Compat.truthy(uiComboHype != null))
        {
            uiComboHype.onJudge(hitCombo, score, dir, visualImpactCount);
        }
        
        if (as3hx.Compat.truthy(score == -10))
        {
            gameReplayHit.push(0);
        }
        else if (as3hx.Compat.truthy(score == -5))
        {
            score = 0;
        }
        
        if (as3hx.Compat.truthy(score > 0))
        {
            gameReplayHit.push(score);
        }
        
        if (as3hx.Compat.truthy(score >= 0))
        {
            gameReplay.push(new ReplayNote(dir, frame, Math.round(Math.round(haxe.Timer.stamp() * 1000) - absoluteStart + songOffset.value), score));
        }
        
        updateFieldVars();
        
        // Multiplayer
        if (as3hx.Compat.truthy(isMultiplayer))
        {
            var scoreEvent                       : Dynamic= new GamePlaybackScoreState(scoreHistory.length, position);
            scoreEvent.raw_score = gameScore;
            scoreEvent.amazing = hitAmazing;
            scoreEvent.perfect = hitPerfect;
            scoreEvent.good = hitGood;
            scoreEvent.average = hitAverage;
            scoreEvent.miss = hitMiss;
            scoreEvent.boo = hitBoo;
            scoreEvent.combo = hitCombo;
            scoreEvent.max_combo = hitMaxCombo;
            scoreHistory.push(scoreEvent);
        }
        
        // Websocket
        if (as3hx.Compat.truthy(_gvars.air_useWebsockets))
        {
            Reflect.setField(SOCKET_SCORE_MESSAGE, "amazing", hitAmazing);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "perfect", hitPerfect);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "good", hitGood);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "average", hitAverage);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "boo", hitBoo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "miss", hitMiss);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "combo", hitCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "maxcombo", hitMaxCombo);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "score", gameScore);
            Reflect.setField(SOCKET_SCORE_MESSAGE, "last_hit", score);
            _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
        }
    }
    
    public function checkAutofail(autofail                       : Dynamic, hit                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(autofail > 0 && hit >= autofail))
        {
            if (as3hx.Compat.truthy(options.autofail_restart))
            {
                GAME_STATE = GAME_RESTART;
            }
            else
            {
                GAME_STATE = GAME_END;
            }
        }
    }
    
    /*#########################################################################################*\
     *		   _                 _                   _       _
     *	/\   /(_)___ _   _  __ _| |  /\ /\ _ __   __| | __ _| |_ ___  ___
     *	\ \ / / / __| | | |/ _` | | / / \ \ '_ \ / _` |/ _` | __/ _ \/ __|
     *	 \ V /| \__ \ |_| | (_| | | \ \_/ / |_) | (_| | (_| | ||  __/\__ \
     *	  \_/ |_|___/\__,_|\__,_|_|  \___/| .__/ \__,_|\__,_|\__\___||___/
     *									  |_|
       \*#########################################################################################*/
    
    public function updateHealth(val                       : Dynamic) : Void
    {
        gameLife += val;
        
        if (as3hx.Compat.truthy(gameLife <= 0))
        {
            GAME_STATE = GAME_END;
        }
        else if (as3hx.Compat.truthy(gameLife > 100))
        {
            gameLife = 100;
        }
        
        if (as3hx.Compat.truthy(uiLifebar.visible))
        {
            uiLifebar.health = gameLife;
        }
    }
    
    public function updateFieldVars() : Void
    {
        if (as3hx.Compat.truthy(uiPAWindow.visible))
        {
            uiPAWindow.update(hitAmazing, hitPerfect, hitGood, hitAverage, hitMiss, hitBoo);
        }
        
        if (as3hx.Compat.truthy(uiScore.visible))
        {
            uiScore.update(gameScore);
        }
        
        if (as3hx.Compat.truthy(uiCombo.visible))
        {
            uiCombo.update(hitCombo, hitAmazing, hitPerfect, hitGood, hitAverage, hitMiss, hitBoo, gameRawGoods);
        }
        
        if (as3hx.Compat.truthy(uiRawGoods.visible))
        {
            uiRawGoods.update(gameRawGoods);
        }
    }
    
    public function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, siteLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
    }
    
    public function removeLoaderListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, siteLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
    }
}



class JudgeNode
{
    private static var dragEnd                  : Dynamic;
    private static var dragStart                  : Dynamic;
    public var time                       : Dynamic;
    public var frame                       : Dynamic;
    public var score                       : Dynamic;
    
    @:allow(game)
    private function new(time                       : Dynamic, score                       : Dynamic, frame                       : Dynamic= -1)
    {
        this.time = time;
        this.score = score;
        this.frame = frame;
    }
}

class EditorMenu extends Sprite
{
    private static var dragEnd                  : Dynamic;
    private static var dragStart                  : Dynamic;
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var _width                       : Dynamic= 230;
    private var _height                       : Dynamic= 0;
    
    public var gameplay                       : Dynamic;
    
    public var title                       : Dynamic;
    
    public var closeButton                       : Dynamic;
    
    public var btnExitEditor                       : Dynamic;
    public var btnResetEditor                       : Dynamic;
    
    public var btnLayoutImport                       : Dynamic;
    public var btnLayoutExport                       : Dynamic;
    
    public var btnLayoutSingle                       : Dynamic;
    public var btnLayoutMultiplayer                       : Dynamic;
    public var btnLayoutSideScroll                       : Dynamic;
    
    @:allow(game)
    private function new(gameplay                       : Dynamic)
    {
        super();
        this.gameplay = gameplay;
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        
        var gamemode                       : Dynamic= (gameplay.options.isMultiplayer) ? "mp" : "sp";
        
        title = new Text(this, 10, 8, _lang.string("editor_menu_" + gamemode));
        title.setAreaParams(_width - 32, 16);
        graphics.moveTo(10, 31);
        graphics.lineTo(_width - 9, 31);
        
        closeButton = new UIIcon(this, new IconClose(), _width - 16, 16);
        closeButton.setSize(12, 12);
        closeButton.setColor("#eda8a8");
        closeButton.buttonMode = true;
        closeButton.addEventListener(MouseEvent.CLICK, e_editorClose);
        
        var cy                       : Dynamic= 0;
        
        btnExitEditor = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_exit_editor"), 12, e_exitEditorMode);
        btnResetEditor = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_reset_layout"), 12, e_resetLayout);
        btnResetEditor.color = 0xff0000;
        
        cy += 20;
        
        btnLayoutImport = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_import_layout"), 12, e_layoutImport);
        btnLayoutExport = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_export_layout"), 12, e_layoutExport);
        
        cy += 20;
        
        btnLayoutSingle = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_use_layout_singleplayer"), 12, e_setLayoutSingle);
        btnLayoutMultiplayer = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_use_layout_multiplayer"), 12, e_setLayoutMulti);
        
        cy += 20;
        
        btnLayoutSideScroll = new BoxButton(this, 15, cy += 40, _width - 30, 30, _lang.string("editor_use_layout_sidescroll"), 12, e_setLayoutSidescroll);
        
        // Background
        _height = cy + 45;
        
        this.graphics.lineStyle(1, 0x000000, 0, true);
        this.graphics.beginFill(0x000000, 0.9);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0x000000, 0, true);
        this.graphics.beginFill(0xFFFFFF, 0.15);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(3, 0xFFFFFF, 0.35);
        this.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.3);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.x = (Main.GAME_WIDTH - _width) / 2;
        this.y = (Main.GAME_HEIGHT - _height) / 2;
    }
    
    private function e_editorClose(e                       : Dynamic) : Void
    {
        gameplay.removeChild(this);
    }
    
    private function e_exitEditorMode(e                       : Dynamic) : Void
    {
        gameplay.removeChild(this);
        
        gameplay.GAME_STATE = GameplayDisplay.GAME_END;
    }
    
    private function e_resetLayout(e                       : Dynamic) : Void
    {
        var layout                       : Dynamic= gameplay.options.layout;
        
        clearLayout(layout);
        
        gameplay.interfaceSetup();
    }
    
    private function e_layoutImport(e                       : Dynamic) : Void
    {
        new PromptInput(gameplay, _lang.string("editor_layout_import_title"), _lang.string("editor_layout_import_save"), e_importFilter);
    }
    
    private function e_importFilter(json                       : Dynamic) : Void
    {
        try
        {
            var item                       : Dynamic= haxe.Json.parse(json);
            var layout                       : Dynamic= gameplay.options.layout;
            
            clearLayout(layout);
            copyTo(layout, item);
            
            gameplay.interfaceSetup();
        }
        catch (e : Error)
        {
        }
    }
    
    private function e_layoutExport(code                       : Dynamic) : Void
    // Clone Layout
    {
        
        var exportLayout                       : Dynamic= { };
        copyTo(exportLayout, gameplay.options.layout);
        gameplay.layoutManager.cleanLayout(exportLayout);
        
        var layoutString                       : Dynamic= haxe.Json.stringify(exportLayout);
        var success                       : Dynamic= SystemUtil.setClipboard(layoutString);
        if (as3hx.Compat.truthy(success))
        {
            Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
        }
        else
        {
            Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }
    }
    
    private function e_setLayoutSidescroll(e                       : Dynamic) : Void
    {
        var layout                       : Dynamic= gameplay.options.layout;
        
        clearLayout(layout);
        
        // Set Sidescroll
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_BAR_TOP), {
            type : 1
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_BAR_BOTTOM), {
            type : 1
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_HEALTH), {
            y : 55
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_PA), {
            x : 16,
            y : 418,
            type : 1
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_SCORE), {
            x : 392,
            y : 24
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_COMBO), {
            x : 508,
            y : 390,
            alignment : "left"
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_TOTAL), {
            x : 770,
            y : 410,
            alignment : "right"
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_COMBO_STATIC), {
            x : 512,
            y : 450
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_TOTAL_STATIC), {
            x : 769,
            y : 405
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_RAWGOODS), {
            x : 90,
            y : 35
        });
        Reflect.setField(layout, Std.string(GameLayoutManager.LAYOUT_RAWGOODS_STATIC), {
            x : 16,
            y : 53,
            alignment : "left"
        });
        
        gameplay.interfaceSetup();
    }
    
    private function e_setLayoutSingle(e                       : Dynamic) : Void
    {
        var layout                       : Dynamic= gameplay.options.layout;
        
        clearLayout(layout);
        copyTo(layout, Reflect.field(_gvars.playerUser.gameLayout, "sp"));
        
        gameplay.interfaceSetup();
    }
    
    private function e_setLayoutMulti(e                       : Dynamic) : Void
    {
        var layout                       : Dynamic= gameplay.options.layout;
        
        clearLayout(layout);
        copyTo(layout, Reflect.field(_gvars.playerUser.gameLayout, "mp"));
        
        gameplay.interfaceSetup();
    }
    
    private function copyTo(layout                       : Dynamic, source_layout                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(source_layout == null))
        {
            return;
        }
        
        for (comp in as3hx.Compat.iter(Reflect.fields(source_layout)))
        {
            if (as3hx.Compat.truthy(Reflect.field(layout, comp) == null))
            {
                Reflect.setField(layout, comp, { });
            }
            
            var values                       : Dynamic= Reflect.field(source_layout, comp);
            for (value in as3hx.Compat.iter(Reflect.fields(values)))
            {
                Reflect.setField(Reflect.field(layout, comp), value, Reflect.field(values, value));
            }
        }
    }
    
    private function clearLayout(layout                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(layout == null))
        {
            return;
        }
        
        for (key in as3hx.Compat.iter(Reflect.fields(layout)))
        {
            var comp                       : Dynamic= Reflect.field(layout, key);
            
            for (param in as3hx.Compat.iter(Reflect.fields(comp)))
            {
                Reflect.deleteField(comp, param);
            }
        }
    }
}
