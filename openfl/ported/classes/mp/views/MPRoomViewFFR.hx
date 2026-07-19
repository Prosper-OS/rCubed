package classes.mp.views;

import assets.menu.icons.fa.IconEye;
import assets.menu.icons.fa.IconUserAdd;
import classes.Alert;
import classes.Noteskins;
import classes.mp.MPColors;
import classes.mp.MPSong;
import classes.mp.MPUser;
import classes.mp.commands.MPCFFRReadyForce;
import classes.mp.commands.MPCFFRSongLoadError;
import classes.mp.commands.MPCFFRSongLoadProgress;
import classes.mp.commands.MPCRoomEdit;
import classes.mp.components.MPViewChatLogRoom;
import classes.mp.components.MPViewUserListRoom;
import classes.mp.components.chatlog.MPChatLogEntryMatchResults;
import classes.mp.components.chatlog.MPChatLogEntrySong;
import classes.mp.components.chatlog.MPChatLogEntryText;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.mode.ffr.MPFFRState;
import classes.mp.prompts.MPRoomUserInvitePrompt;
import classes.mp.prompts.MPUserProfilePrompt;
import classes.mp.room.MPRoomFFR;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.Text;
import classes.ui.UIIcon;
import classes.ui.UIIconHover;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import game.GameOptions;
import menu.FileLoader;
import assets.menu.icons.fa.IconAccept;
import assets.menu.icons.fa.IconCancel;

import assets.menu.icons.fa.IconGear;
import assets.menu.icons.fa.IconLeave;
import assets.menu.icons.fa.IconLock;
import assets.menu.icons.fa.IconPlay;
import assets.menu.icons.fa.IconWrench;

import classes.Language;
import classes.mp.MPModes;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCFFRGameModifiers;
import classes.mp.commands.MPCFFRReady;


import classes.mp.commands.MPCRoomLeave;



import classes.mp.views.MPRoomViewFFR;

import classes.ui.BoxCheck;

import classes.ui.BoxText;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;



import classes.ui.ValidatedText;
import com.bit101.components.ComboBox;
import com.flashfla.utils.SystemUtil;




import menu.MainMenu;
import menu.MenuMultiplayer;

class MPRoomViewFFR extends MPRoomView
{
    private static var _noteskins                             : Dynamic= Noteskins.instance;
    
    public var room                             : Dynamic;
    
    private var _width                             : Dynamic= 409;
    private var _height                             : Dynamic= 388;
    
    private var chat                             : Dynamic;
    private var userlist                             : Dynamic;
    
    private var autoSpectateButton                             : Dynamic;
    private var inviteButton                             : Dynamic;
    
    private var ownerPanel                             : Dynamic;
    private var ownerEditPanel                             : Dynamic;
    private var ownerModsPanel                             : Dynamic;
    private var userPanel                             : Dynamic;
    
    private var _userProfilePrompt                             : Dynamic;
    private var _userInvitePrompt                             : Dynamic;
    
    private var loadProgressTimer                             : Dynamic= new Timer(500);
    private var autoSpectate                             : Dynamic= false;
    private var autoSpectatePlayer                             : Dynamic;
    
    public function new(room                             : Dynamic, parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0)
    {
        this.room = room;
        
        super(parent, xpos, ypos);
    }
    
    override public function addRoomEvents() : Void
    {
        super.addRoomEvents();
        
        _mp.addEventListener(MPEvent.FFR_GAME_STATE, e_gameState);
        _mp.addEventListener(MPEvent.FFR_GAME_MODS, e_gameMods);
        _mp.addEventListener(MPEvent.FFR_PLAYABLE_STATE, e_playableState);
        
        _mp.addEventListener(MPEvent.FFR_SONG_RATE, e_songRate);
        _mp.addEventListener(MPEvent.FFR_SONG_CHANGE, e_songUpdate);
        _mp.addEventListener(MPEvent.FFR_SONG_REQUEST, e_songRequest);
        _mp.addEventListener(MPEvent.FFR_READY_STATE, e_readyState);
        _mp.addEventListener(MPEvent.FFR_FORCE_START, e_readyState);
        
        _mp.addEventListener(MPEvent.FFR_LOADING_START, e_loadingStart);
        _mp.addEventListener(MPEvent.FFR_LOADING, e_loadingProgress);
        _mp.addEventListener(MPEvent.FFR_LOADING_ABORT, e_loadingAbort);
        
        _mp.addEventListener(MPEvent.FFR_COUNTDOWN, e_countdown);
        _mp.addEventListener(MPEvent.FFR_MATCH_START, e_matchStart);
        _mp.addEventListener(MPEvent.FFR_SONG_START, e_songStart);
        _mp.addEventListener(MPEvent.FFR_AUTO_SPECTATE, e_autoSpectate);
        _mp.addEventListener(MPEvent.FFR_MATCH_END, e_matchEnd);
    }
    
    override public function dispose() : Void
    {
        _mp.removeEventListener(MPEvent.FFR_GAME_STATE, e_gameState);
        _mp.removeEventListener(MPEvent.FFR_GAME_MODS, e_gameMods);
        _mp.removeEventListener(MPEvent.FFR_PLAYABLE_STATE, e_playableState);
        
        _mp.removeEventListener(MPEvent.FFR_SONG_RATE, e_songRate);
        _mp.removeEventListener(MPEvent.FFR_SONG_CHANGE, e_songUpdate);
        _mp.removeEventListener(MPEvent.FFR_SONG_REQUEST, e_songRequest);
        _mp.removeEventListener(MPEvent.FFR_READY_STATE, e_readyState);
        _mp.removeEventListener(MPEvent.FFR_FORCE_START, e_readyState);
        
        _mp.removeEventListener(MPEvent.FFR_LOADING_START, e_loadingStart);
        _mp.removeEventListener(MPEvent.FFR_LOADING, e_loadingProgress);
        _mp.removeEventListener(MPEvent.FFR_LOADING_ABORT, e_loadingAbort);
        
        _mp.removeEventListener(MPEvent.FFR_COUNTDOWN, e_countdown);
        _mp.removeEventListener(MPEvent.FFR_MATCH_START, e_matchStart);
        _mp.removeEventListener(MPEvent.FFR_SONG_START, e_songStart);
        _mp.removeEventListener(MPEvent.FFR_AUTO_SPECTATE, e_autoSpectate);
        _mp.removeEventListener(MPEvent.FFR_MATCH_END, e_matchEnd);
        
        userlist.removeEventListener(MPEvent.ROOM_USERLIST_SELECT, e_onUserSelect);
        userlist.removeEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectateUserlist);
        inviteButton.removeEventListener(MouseEvent.CLICK, e_inviteClick);
        
        closePrompts();
        
        super.dispose();
    }
    
    override public function build() : Void
    {
        super.build();
        
        chat = new MPViewChatLogRoom(this, 0, 192, _width, _height - 192);
        chat.setRoom(room);
        chat.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        chat.graphics.moveTo(1, 0);
        chat.graphics.lineTo(_width, 0);
        
        // Userlist
        userlist = new MPViewUserListRoom(this, 410, 0);
        userlist.setRoom(room);
        userlist.addEventListener(MPEvent.ROOM_USERLIST_SELECT, e_onUserSelect);
        userlist.addEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectateUserlist);
        
        autoSpectateButton = new UIIconHover(this, new IconEye(), 566, 16);
        autoSpectateButton.setSize(15, 15);
        autoSpectateButton.buttonMode = true;
        autoSpectateButton.setHoverText(_lang.string("mp_room_auto_spectate"));
        autoSpectateButton.setColor("#eda8a8");
        autoSpectateButton.addEventListener(MouseEvent.CLICK, e_autoSpectateClick);
        
        inviteButton = new UIIconHover(this, new IconUserAdd(), 596, 16);
        inviteButton.setSize(15, 15);
        inviteButton.buttonMode = true;
        inviteButton.setHoverText(_lang.string("mp_room_invite_players"));
        inviteButton.addEventListener(MouseEvent.CLICK, e_inviteClick);
        
        // Name
        new Text(this, 5, 0, "#", 14, "#c0c0c0").setAreaParams(15, 30);
        
        // Owner Panel
        ownerPanel = new OwnerPanel(this, room);
        addChild(ownerPanel);
        
        ownerEditPanel = new OwnerEditPanel(this, room);
        addChild(ownerEditPanel);
        
        ownerModsPanel = new OwnerModsPanel(this, room);
        addChild(ownerModsPanel);
        
        userPanel = new UserPanel(this, room);
        addChild(userPanel);
        
        if (as3hx.Compat.truthy(_mp.currentUser == room.owner))
        {
            setPanelOwner();
        }
        else
        {
            setPanelUser();
        }
        
        // Graphics
        redraw();
    }
    
    public function redraw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        
        // Title BG
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, 30);
        this.graphics.endFill();
        
        // BG
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        // Title
        this.graphics.moveTo(1, 30);
        this.graphics.lineTo(_width, 30);
    }
    
    override public function onKeyInput(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_userInvitePrompt != null))
        {
            _userInvitePrompt.onKeyInput(e);
            return;
        }
        
        if (as3hx.Compat.truthy(_userProfilePrompt != null))
        {
            _userProfilePrompt.onKeyInput(e);
            return;
        }
        
        chat.onKeyInput(e);
    }
    
    public function onChatMessage(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            chat.onChatMessage(e);
        }
    }
    
    override public function updateRoomButton() : Void
    {
        if (as3hx.Compat.truthy(room.spectatorCount > 0))
        {
            this.roomButton.updateText(room.name, sprintf(_lang.string("mp_btn_player_count_spectator"), {
                                current : room.playerCount,
                                max : room.playerCountMax,
                                spectator : room.spectatorCount
                            }));
        }
        else
        {
            this.roomButton.updateText(room.name, sprintf(_lang.string("mp_btn_player_count"), {
                                current : room.playerCount,
                                max : room.playerCountMax
                            }));
        }
    }
    
    override private function set_width(value                             : Dynamic) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value                             : Dynamic) : Float
    {
        _height = height;
        redraw();
        return value;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override public function e_roomUpdate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override public function e_roomEdit(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override public function e_roomMessage(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            onChatMessage(e);
        }
    }
    
    override public function e_teamUpdate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    public function e_gameState(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.updateGameStates();
        }
    }
    
    public function e_gameMods(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.updateGameStates();
            updatePanelDisplay();
        }
    }
    
    public function e_playableState(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            ownerPanel.update();
            userPanel.update();
        }
    }
    
    public function e_songRate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.updateGameStates();
        }
    }
    
    override public function e_userJoin(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.USER_JOIN + "\">" + sprintf(_lang.string("mp_room_chat_user_join"), {
                                user : e.user.name
                            }) + "</font>"));
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override public function e_userLeave(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.USER_LEAVE + "\">" + sprintf(_lang.string("mp_room_chat_user_left"), {
                                user : e.user.name
                            }) + "</font>"));
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
            
            if (as3hx.Compat.truthy(autoSpectatePlayer == e.user && autoSpectate))
            {
                e_autoSpectateClick(null);
            }
        }
    }
    
    public function e_songUpdate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            updatePanelDisplay();
        }
    }
    
    public function e_songRequest(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            var info                             : Dynamic= new MPSong();
            info.update(e.command.data);
            info.selected = false;
            
            chat.addItem(new MPChatLogEntrySong(e.room, e.user, info));
            userlist.update();
            updateRoomButton();
        }
    }
    
    public function e_readyState(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            ownerPanel.update();
        }
    }
    
    public function e_loadingStart(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            _startSongLoading();
        }
    }
    
    public function e_loadingProgress(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.updateGameStates();
        }
    }
    
    public function e_loadingAbort(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            _abortSongLoading();
        }
    }
    
    public function e_matchStart(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + _lang.string("mp_room_ffr_match_start") + "</font>"));
            _gameMatchStart();
        }
    }
    
    public function e_songStart(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.updateGameStates();
        }
    }
    
    public function e_autoSpectate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            if (as3hx.Compat.truthy(autoSpectate))
            {
                if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
                {
                    return;
                }
                
                // Set Player
                if (as3hx.Compat.truthy(autoSpectatePlayer != null))
                {
                    _spectatePlayer(autoSpectatePlayer);
                    return;
                }
                
                // Random Player
                var gameUsers                             : Dynamic= room.users.filter(function(user                             : Dynamic, index                             : Dynamic, array                             : Dynamic) : Bool
                        {
                            return room.isPlayer(user) && room.getPlayerState(user) == "game";
                        });
                
                if (as3hx.Compat.truthy(gameUsers.length > 0))
                {
                    _spectatePlayer(gameUsers[Math.floor(Math.random() * gameUsers.length)]);
                }
            }
        }
    }
    
    public function e_matchEnd(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            userlist.updateGameStates();
            updateRoomButton();
            updatePanelDisplay();
            
            chat.addItem(new MPChatLogEntryMatchResults(room, room.lastMatch));
        }
    }
    
    public function e_countdown(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            if (as3hx.Compat.truthy(e.command.data.value > 5))
            {
                chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + sprintf(_lang.string("mp_room_countdown_general"), {
                                    seconds : e.command.data.value
                                }) + "</font>"));
            }
            else
            {
                chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + _lang.string("mp_room_countdown_" + e.command.data.value) + "</font>"));
            }
        }
    }
    
    private function e_autoSpectateClick(e                             : Dynamic) : Void
    {
        autoSpectate = !autoSpectate;
        autoSpectateButton.setColor((autoSpectate) ? "#bdeda8" : "#eda8a8");
        
        if (as3hx.Compat.truthy(autoSpectatePlayer != null))
        {
            Alert.add(_lang.string("mp_room_spectate_user_clear"), 120, 0x005e5e);
            autoSpectatePlayer = null;
        }
    }
    
    private function e_inviteClick(e                             : Dynamic) : Void
    {
        _userInvitePrompt = new MPRoomUserInvitePrompt(this.room, this);
        _userInvitePrompt.addEventListener(Event.CLOSE, e_onInviteClose);
    }
    
    private function e_onInviteClose(e                             : Dynamic) : Void
    {
        _userInvitePrompt.removeEventListener(Event.CLOSE, e_onInviteClose);
        _userInvitePrompt = null;
    }
    
    private function e_onUserSelect(e                             : Dynamic) : Void
    {
        _userProfilePrompt = new MPUserProfilePrompt(e.user, this.room, this);
        _userProfilePrompt.addEventListener(Event.CLOSE, e_onProfileClose);
        _userProfilePrompt.addEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectate);
    }
    
    private function e_onUserSpectateUserlist(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(autoSpectate))
        {
            autoSpectatePlayer = e.user;
            Alert.add(sprintf(_lang.string("mp_room_spectate_user_select"), {
                                name : e.user.name
                            }), 120, 0x005e5e);
        }
        
        _spectatePlayer(e.user);
    }
    
    private function e_onUserSpectate(e                             : Dynamic) : Void
    {
        _spectatePlayer(e.user);
    }
    
    private function e_onProfileClose(e                             : Dynamic) : Void
    {
        _userProfilePrompt.removeEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectate);
        _userProfilePrompt.removeEventListener(Event.CLOSE, e_onProfileClose);
        _userProfilePrompt = null;
    }
    
    public function closePrompts() : Void
    {
        if (as3hx.Compat.truthy(_userProfilePrompt != null))
        {
            _userProfilePrompt.close();
            e_onProfileClose(null);
        }
        
        if (as3hx.Compat.truthy(_userInvitePrompt != null))
        {
            _userInvitePrompt.close();
            e_onInviteClose(null);
        }
    }
    
    public function updatePanelDisplay() : Void
    {
        ownerPanel.update();
        ownerEditPanel.update();
        ownerModsPanel.update();
        userPanel.update();
        
        // Update User -> Owner Switch
        if (as3hx.Compat.truthy(this.room.owner == _mp.currentUser && userPanel.visible))
        {
            setPanelOwner();
        }
        
        // Update Owner -> User Switch
        if (as3hx.Compat.truthy(this.room.owner != _mp.currentUser && (ownerPanel.visible || ownerEditPanel.visible || ownerModsPanel.visible)))
        {
            setPanelUser();
        }
    }
    
    public function setPanelOwner() : Void
    {
        ownerPanel.visible = true;
        ownerEditPanel.visible = false;
        ownerModsPanel.visible = false;
        userPanel.visible = false;
        chat.visible = true;
    }
    
    public function setPanelEdit() : Void
    {
        ownerPanel.visible = false;
        ownerEditPanel.visible = true;
        ownerModsPanel.visible = false;
        userPanel.visible = false;
        chat.visible = true;
    }
    
    public function setPanelMods() : Void
    {
        ownerPanel.visible = false;
        ownerEditPanel.visible = false;
        ownerModsPanel.visible = true;
        userPanel.visible = false;
        chat.visible = false;
    }
    
    public function setPanelUser() : Void
    {
        ownerPanel.visible = false;
        ownerEditPanel.visible = false;
        ownerModsPanel.visible = false;
        userPanel.visible = true;
        chat.visible = true;
    }
    
    private function _startSongLoading() : Void
    {
        if (as3hx.Compat.truthy(room.songInfo == null))
        {
            if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
            {
                _mp.sendCommand(new MPCFFRSongLoadError(room));
            }
            return;
        }
        
        // Setup Local File
        if (as3hx.Compat.truthy(room.songInfo.is_local))
        {
            FileLoader.buildSong(room.songInfo);
        }
        
        room.song = _gvars.getSongFile(room.songInfo);
        
        if (as3hx.Compat.truthy(room.isSongLoaded()))
        {
            _endSongLoading();
        }
        else
        {
            room.song.addEventListener(Event.COMPLETE, e_songFileComplete);
            loadProgressTimer.addEventListener(TimerEvent.TIMER, e_loadProgressUpdaterTimer);
            loadProgressTimer.start();
        }
    }
    
    private function e_songFileComplete(e                             : Dynamic) : Void
    {
        room.song.removeEventListener(Event.COMPLETE, e_songFileComplete);
        
        if (as3hx.Compat.truthy(room.isSongLoaded()))
        {
            _endSongLoading();
        }
    }
    
    private function e_loadProgressUpdaterTimer(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!room.song || room.isSongLoaded()))
        {
            loadProgressTimer.stop();
        }
        else
        {
            if (as3hx.Compat.truthy(room.song.loadFail))
            {
                _gvars.removeSongFile(room.song);
                room.song.removeEventListener(Event.COMPLETE, e_songFileComplete);
                room.song = null;
                
                if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
                {
                    _mp.sendCommand(new MPCFFRSongLoadError(room));
                }
                
                Alert.add(sprintf(_lang.string("mp_room_ffr_song_load_error"), {
                                    song : room.songData.name
                                }));
                loadProgressTimer.stop();
                return;
            }
            
            if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
            {
                _mp.sendCommand(new MPCFFRSongLoadProgress(room, room.song.progress, false));
            }
        }
    }
    
    private function _abortSongLoading() : Void
    {
        if (as3hx.Compat.truthy(loadProgressTimer.running))
        {
            loadProgressTimer.removeEventListener(TimerEvent.TIMER, e_loadProgressUpdaterTimer);
            loadProgressTimer.stop();
        }
        
        chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + _lang.string("mp_room_chat_loading_abort") + "</font>"));
    }
    
    private function _endSongLoading() : Void
    {
        if (as3hx.Compat.truthy(loadProgressTimer.running))
        {
            loadProgressTimer.removeEventListener(TimerEvent.TIMER, e_loadProgressUpdaterTimer);
            loadProgressTimer.stop();
        }
        
        if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
        {
            var state                             : Dynamic= new MPCFFRSongLoadProgress(room, 100, true);
            _mp.sendCommand(state);
        }
    }
    
    private function _gameMatchStart() : Void
    {
        if (as3hx.Compat.truthy(room.isPlayer(_mp.currentUser)))
        {
            closePrompts();
            
            if (as3hx.Compat.truthy(!room.song))
            {
                room.song = _gvars.getSongFile(room.songInfo);
            }
            
            _gvars.options = new GameOptions();
            _gvars.options.isMultiplayer = true;
            _gvars.options.fill();
            _gvars.options.song = room.song;
            _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
        }
    }
    
    private function _spectatePlayer(user                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(room.isPlayer(user) && room.getPlayerState(user) == "game"))
        {
            closePrompts();
            
            Alert.add(sprintf(_lang.string("mp_room_spectate_user_start"), {
                                name : user.name
                            }), 120, 0x005e5e);
            
            if (as3hx.Compat.truthy(!room.song))
            {
                room.song = _gvars.getSongFile(room.songInfo);
            }
            
            if (as3hx.Compat.truthy(!room.song))
            {
                chat.addItem(new MPChatLogEntryText(_lang.string("mp_room_chat_spectate_error")));
                return;
            }
            
            var vars                             : Dynamic= room.getPlayerVariables(user);
            
            room.song.isDirty = true;
            _gvars.options = new GameOptions();
            _gvars.options.settingsDecode(vars.settings);
            _gvars.options.song = room.song;
            _gvars.options.isMultiplayer = true;
            _gvars.options.isSpectator = true;
            _gvars.options.spectatorUser = user;
            
            // User Custom Noteskin.
            if (as3hx.Compat.truthy(vars.noteskin == null && _gvars.options.noteskin == 0))
            {
                _gvars.options.noteskin = 1;
            }
            
            if (as3hx.Compat.truthy(_gvars.options.noteskin == 0 && vars.noteskin != null))
            {
                _gvars.options.noteskin = 9999999;
                _noteskins.addEventListener(Noteskins.JSON_LOAD, e_onNoteskinComplete);
                _noteskins.addEventListener(Noteskins.JSON_ERROR, e_onNoteskinCancel);
                _noteskins.loadCustomNoteskinJSON(vars.noteskin, "9999999");
            }
            else
            {
                _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
            }
        }
    }
    
    private function e_onNoteskinComplete(e                             : Dynamic) : Void
    {
        _noteskins.removeEventListener(Noteskins.JSON_LOAD, e_onNoteskinComplete);
        _noteskins.removeEventListener(Noteskins.JSON_ERROR, e_onNoteskinCancel);
        _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
    }
    
    private function e_onNoteskinCancel(e                             : Dynamic) : Void
    {
        _noteskins.removeEventListener(Noteskins.JSON_LOAD, e_onNoteskinComplete);
        _noteskins.removeEventListener(Noteskins.JSON_ERROR, e_onNoteskinCancel);
        _gvars.options.noteskin = 1;
        _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
    }
}



class UserPanel extends Sprite
{
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var view                             : Dynamic;
    private var room                             : Dynamic;
    
    private var panelName                             : Dynamic;
    private var iconLeaveBtn                             : Dynamic;
    
    private var songName                             : Dynamic;
    private var songAuthor                             : Dynamic;
    private var songLength                             : Dynamic;
    private var songDifficulty                             : Dynamic;
    
    private var ready                             : Dynamic;
    private var selectSong                             : Dynamic;
    
    @:allow(classes.mp.views)
    private function new(view                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.view = view;
        this.room = room;
        
        panelName = new Text(this, 20, 0, room.name, 16);
        panelName.setAreaParams(view.width - 85, 30);
        
        iconLeaveBtn = new UIIconHover(this, new IconLeave(), view.width - 15, 16);
        iconLeaveBtn.setSize(15, 15);
        iconLeaveBtn.buttonMode = true;
        iconLeaveBtn.setHoverText(_lang.string("mp_room_leave"));
        iconLeaveBtn.addEventListener(MouseEvent.CLICK, e_leaveClick);
        
        new Text(this, 6, 35, _lang.string("mp_room_ffr_song_name"), 13, "#c3c3c3").setAreaParams(250, 20);
        songName = new Text(this, 6, 51, "", 11);
        songName.setAreaParams(250, 20);
        
        new Text(this, 6, 74, _lang.string("mp_room_ffr_song_author"), 13, "#c3c3c3").setAreaParams(250, 20);
        songAuthor = new Text(this, 6, 90, "", 11);
        songAuthor.setAreaParams(250, 20);
        
        new Text(this, 6, 113, _lang.string("mp_room_ffr_song_length"), 13, "#c3c3c3").setAreaParams(250, 20);
        songLength = new Text(this, 6, 129, "", 11);
        songLength.setAreaParams(250, 20);
        
        new Text(this, 6, 152, _lang.string("mp_room_ffr_song_difficulty"), 13, "#c3c3c3").setAreaParams(250, 20);
        songDifficulty = new Text(this, 6, 168, "", 11);
        songDifficulty.setAreaParams(250, 20);
        
        ready = new BoxButton(this, 275, 40, 125, 26, _lang.string("mp_room_ffr_player_ready"), 12, e_readyClick);
        selectSong = new BoxButton(this, 275, 75, 125, 26, _lang.string("mp_room_ffr_player_song_request"), 12, e_songsClick);
        
        update();
    }
    
    public function update() : Void
    {
        panelName.text = (room.name) ? room.name : "";
        
        if (as3hx.Compat.truthy(room.songData.selected))
        {
            ready.enabled = true;
            songName.text = room.songData.name;
            songAuthor.text = room.songData.author;
            songLength.text = sprintf(_lang.string("mp_room_ffr_song_length_value"), {
                                time : room.songData.time,
                                note_count : room.songData.note_count
                            });
            songDifficulty.text = Std.string(room.songData.difficulty);
        }
        else
        {
            ready.enabled = true;
            songName.text = _lang.string("mp_room_ffr_song_unselected");
            songAuthor.text = "---";
            songLength.text = "---";
            songDifficulty.text = "---";
        }
        
        if (as3hx.Compat.truthy(ready.enabled && !room.canUserPlaySong(_mp.currentUser)))
        {
            ready.enabled = false;
        }
        
        ready.text = _lang.string((room.isPlayerReady(_mp.currentUser)) ? "mp_room_ffr_owner_unready" : "mp_room_ffr_owner_ready");
    }
    
    private function e_leaveClick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomLeave(room));
    }
    
    private function e_readyClick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCFFRReady(room));
    }
    
    private function e_songsClick(e                             : Dynamic) : Void
    {
        (try cast(this.view.parent, MenuMultiplayer) catch(e:Dynamic) null).switchTo(MainMenu.MENU_SONGSELECTION);
    }
}

class OwnerPanel extends Sprite
{
    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var view                             : Dynamic;
    private var room                             : Dynamic;
    
    private var panelName                             : Dynamic;
    private var iconModsBtn                             : Dynamic;
    private var iconEditBtn                             : Dynamic;
    private var iconLeaveBtn                             : Dynamic;
    
    private var songName                             : Dynamic;
    private var songAuthor                             : Dynamic;
    private var songLength                             : Dynamic;
    private var songDifficulty                             : Dynamic;
    
    private var ready                             : Dynamic;
    private var forceStart                             : Dynamic;
    private var selectSong                             : Dynamic;
    private var selectMods                             : Dynamic;
    
    @:allow(classes.mp.views)
    private function new(view                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.view = view;
        this.room = room;
        
        panelName = new Text(this, 20, 0, "", 16);
        panelName.setAreaParams(view.width - 115, 30);
        
        iconModsBtn = new UIIconHover(this, new IconWrench(), view.width - 75, 16);
        iconModsBtn.setSize(15, 15);
        iconModsBtn.buttonMode = true;
        iconModsBtn.setHoverText(_lang.string("mp_room_options_mods"));
        iconModsBtn.addEventListener(MouseEvent.CLICK, e_modsClick);
        
        iconEditBtn = new UIIconHover(this, new IconGear(), view.width - 45, 16);
        iconEditBtn.setSize(15, 15);
        iconEditBtn.buttonMode = true;
        iconEditBtn.setHoverText(_lang.string("mp_room_options"));
        iconEditBtn.addEventListener(MouseEvent.CLICK, e_editClick);
        
        iconLeaveBtn = new UIIconHover(this, new IconLeave(), view.width - 15, 16);
        iconLeaveBtn.setSize(15, 15);
        iconLeaveBtn.buttonMode = true;
        iconLeaveBtn.setHoverText(_lang.string("mp_room_leave"));
        iconLeaveBtn.addEventListener(MouseEvent.CLICK, e_leaveClick);
        
        new Text(this, 6, 35, _lang.string("mp_room_ffr_song_name"), 13, "#c3c3c3").setAreaParams(250, 20);
        songName = new Text(this, 6, 51, "", 11);
        songName.setAreaParams(250, 20);
        
        new Text(this, 6, 74, _lang.string("mp_room_ffr_song_author"), 13, "#c3c3c3").setAreaParams(250, 20);
        songAuthor = new Text(this, 6, 90, "", 11);
        songAuthor.setAreaParams(250, 20);
        
        new Text(this, 6, 113, _lang.string("mp_room_ffr_song_length"), 13, "#c3c3c3").setAreaParams(250, 20);
        songLength = new Text(this, 6, 129, "", 11);
        songLength.setAreaParams(250, 20);
        
        new Text(this, 6, 152, _lang.string("mp_room_ffr_song_difficulty"), 13, "#c3c3c3").setAreaParams(250, 20);
        songDifficulty = new Text(this, 6, 168, "", 11);
        songDifficulty.setAreaParams(250, 20);
        
        ready = new BoxButton(this, 275, 40, 94, 26, _lang.string("mp_room_ffr_owner_ready"), 12, e_readyClick);
        
        forceStart = new BoxIcon(this, 374, 40, 26, 26, new IconPlay(), e_forceStartClick);
        forceStart.padding = 16;
        forceStart.setHoverText(_lang.string("mp_room_ffr_owner_force_start"));
        
        selectSong = new BoxButton(this, 275, 75, 125, 26, _lang.string("mp_room_ffr_owner_song_select"), 12, e_songsClick);
        
        selectMods = new BoxButton(this, 275, 110, 125, 26, _lang.string("mp_room_ffr_owner_mod_select"), 12, e_modsClick);
        selectMods.visible = false;
        
        update();
    }
    
    public function update() : Void
    {
        panelName.text = (room.name) ? room.name : "";
        
        if (as3hx.Compat.truthy(room.songData.selected))
        {
            ready.enabled = forceStart.enabled = true;
            songName.text = room.songData.name;
            songAuthor.text = room.songData.author;
            songLength.text = sprintf(_lang.string("mp_room_ffr_song_length_value"), {
                                time : room.songData.time,
                                note_count : room.songData.note_count
                            });
            songDifficulty.text = Std.string(room.songData.difficulty);
        }
        else
        {
            ready.enabled = forceStart.enabled = false;
            songName.text = _lang.string("mp_room_ffr_song_unselected");
            songAuthor.text = "---";
            songLength.text = "---";
            songDifficulty.text = "---";
        }
        
        if (as3hx.Compat.truthy(ready.enabled && !room.canUserPlaySong(_mp.currentUser)))
        {
            ready.enabled = false;
        }
        
        ready.text = _lang.string((room.isPlayerReady(_mp.currentUser)) ? "mp_room_ffr_owner_unready" : "mp_room_ffr_owner_ready");
    }
    
    private function e_modsClick(e                             : Dynamic) : Void
    {
        view.setPanelMods();
    }
    
    private function e_editClick(e                             : Dynamic) : Void
    {
        view.setPanelEdit();
    }
    
    private function e_leaveClick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomLeave(room));
    }
    
    private function e_readyClick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCFFRReady(room));
    }
    
    private function e_forceStartClick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCFFRReadyForce(room));
    }
    
    private function e_songsClick(e                             : Dynamic) : Void
    {
        (try cast(this.view.parent, MenuMultiplayer) catch(e:Dynamic) null).switchTo(MainMenu.MENU_SONGSELECTION);
    }
}

class OwnerEditPanel extends Sprite
{
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var view                             : Dynamic;
    private var room                             : Dynamic;
    
    private var panelName                             : Dynamic;
    private var iconCancelBtn                             : Dynamic;
    private var iconSaveBtn                             : Dynamic;
    
    private var roomPassword                             : Dynamic;
    private var showPassword                             : Dynamic;
    private var joinCode                             : Dynamic;
    
    private var teamModes                             : Dynamic;
    
    private var maxPlayersText                             : Dynamic;
    private var maxPlayers                             : Dynamic;
    
    private var maxTeamsText                             : Dynamic;
    private var maxTeams                             : Dynamic;
    private var maxPlayersPerTeamText                             : Dynamic;
    private var maxPlayersPerTeam                             : Dynamic;
    
    @:allow(classes.mp.views)
    private function new(view                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.view = view;
        this.room = room;
        
        panelName = new BoxText(this, 20, 1, 280, 28);
        panelName.field.y += 1;
        panelName.borderAlpha = 0;
        panelName.borderActiveAlpha = 0;
        
        iconCancelBtn = new UIIcon(this, new IconCancel(), view.width - 45, 16);
        iconCancelBtn.setSize(15, 15);
        iconCancelBtn.setColor("#eda8a8");
        iconCancelBtn.buttonMode = true;
        iconCancelBtn.addEventListener(MouseEvent.CLICK, e_cancelClick);
        
        iconSaveBtn = new UIIcon(this, new IconAccept(), view.width - 15, 16);
        iconSaveBtn.setSize(15, 15);
        iconSaveBtn.setColor("#bdeda8");
        iconSaveBtn.buttonMode = true;
        iconSaveBtn.addEventListener(MouseEvent.CLICK, e_saveClick);
        
        new Text(this, 9, 35, _lang.string("mp_room_options_password"), 12, "#c3c3c3").setAreaParams(185, 22);
        
        roomPassword = new BoxText(this, 10, 58, 160, 21, Constant.TEXT_FORMAT_UNICODE_12);
        roomPassword.displayAsPassword = true;
        roomPassword.field.y += 1;
        
        showPassword = new BoxIcon(this, 175, 58, 21, 21, new IconEye(), e_togglePassword);
        
        new Text(this, 9, 85, _lang.string("mp_room_options_join_code"), 12, "#c3c3c3").setAreaParams(185, 22);
        
        joinCode = new Text(this, 9, 108);
        joinCode.mouseEnabled = true;
        joinCode.buttonMode = true;
        joinCode.addEventListener(MouseEvent.CLICK, e_onJoinClick);
        
        // Team Mode
        new Text(this, 214, 35, _lang.string("mp_room_options_team_mode")).setAreaParams(185, 22);
        
        teamModes = new ComboBox(this, 215, 58, "", MPModes.getTeamModes());
        teamModes.setSize(185, 24);
        teamModes.fontSize = 11;
        teamModes.selectedIndex = 0;
        
        // Max Players - FFA
        maxPlayersText = new Text(this, 214, 85, _lang.string("mp_room_options_max_player_count"), 12, "#c3c3c3");
        maxPlayersText.setAreaParams(185, 22);
        maxPlayersText.visible = false;
        
        maxPlayers = new ComboBox(this, 215, 108, "", MPModes.getMaxPlayers());
        maxPlayers.setSize(185, 24);
        maxPlayers.fontSize = 11;
        maxPlayers.selectedIndex = 1;
        maxPlayers.visible = false;
        
        // Max Teams - Team
        maxTeamsText = new Text(this, 215, 85, _lang.string("mp_room_options_max_team_count"), 12, "#c3c3c3");
        maxTeamsText.setAreaParams(185, 22);
        maxTeamsText.visible = false;
        
        maxTeams = new ComboBox(this, 215, 108, "", MPModes.getTeams());
        maxTeams.setSize(185, 24);
        maxTeams.fontSize = 11;
        maxTeams.selectedIndex = 0;
        maxTeams.visible = false;
        
        // Max Teams Players - Team
        maxPlayersPerTeamText = new Text(this, 215, 135, _lang.string("mp_room_options_max_team_players"), 12, "#c3c3c3");
        maxPlayersPerTeamText.setAreaParams(185, 22);
        maxPlayersPerTeamText.visible = false;
        
        maxPlayersPerTeam = new ComboBox(this, 215, 158, "", MPModes.getTeamMaxPlayers());
        maxPlayersPerTeam.setSize(185, 24);
        maxPlayersPerTeam.fontSize = 11;
        maxPlayersPerTeam.selectedIndex = 0;
        maxPlayersPerTeam.visible = false;
        
        // Events
        teamModes.addEventListener(Event.SELECT, e_onTeamModeChange);
        
        // Draw
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(panelName.x, 1);
        this.graphics.lineTo(panelName.x, panelName.height + 1);
        this.graphics.moveTo(panelName.x + panelName.width, 1);
        this.graphics.lineTo(panelName.x + panelName.width, panelName.height + 1);
        
        update();
    }
    
    public function update() : Void
    {
        panelName.text = (room.name) ? room.name : "";
        roomPassword.text = (room.password) ? room.password : "";
        joinCode.text = (room.joinCode) ? room.joinCode : "";
        
        if (as3hx.Compat.truthy((room.teamCount - 1) > 1))
        {
            teamModes.selectedItemByData = "team";
            maxTeams.selectedItemByData = (room.teamCount - 1);
            maxPlayersPerTeam.selectedItemByData = room.maxPlayers;
        }
        else
        {
            teamModes.selectedItemByData = "ffr";
            maxPlayers.selectedItemByData = room.maxPlayers;
        }
        
        updateTeamMode();
    }
    
    private function e_cancelClick(e                             : Dynamic) : Void
    {
        view.setPanelOwner();
    }
    
    private function e_onJoinClick(e                             : Dynamic) : Void
    {
        var success                             : Dynamic= SystemUtil.setClipboard(room.joinCode);
        
        if (as3hx.Compat.truthy(success))
        {
            Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
        }
        else
        {
            Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }
    }
    
    private function e_saveClick(e                             : Dynamic) : Void
    {
        _mp.addEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.addEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
        
        var cmd                             : Dynamic= new MPCRoomEdit(room);
        cmd.name = panelName.text;
        cmd.password = roomPassword.text;
        
        // FFA
        if (as3hx.Compat.truthy(teamModes.selectedItem.data == "ffa"))
        {
            cmd.team_count = 1;
            cmd.max_players = as3hx.Compat.parseFloat(maxPlayers.selectedItem);
        }
        else if (as3hx.Compat.truthy(teamModes.selectedItem.data == "team"))
        {
            cmd.team_count = as3hx.Compat.parseFloat(maxTeams.selectedItem);
            cmd.max_players = as3hx.Compat.parseFloat(maxPlayersPerTeam.selectedItem);
        }
        
        _mp.sendCommand(cmd);
    }
    
    private function e_onEditOK(e                             : Dynamic) : Void
    {
        _mp.removeEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.removeEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
        
        view.setPanelOwner();
    }
    
    private function e_onEditFail(e                             : Dynamic) : Void
    {
        _mp.removeEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.removeEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
    }
    
    private function e_onTeamModeChange(e                             : Dynamic) : Void
    {
        updateTeamMode();
    }
    
    private function e_togglePassword(e                             : Dynamic) : Void
    {
        roomPassword.displayAsPassword = !roomPassword.displayAsPassword;
    }
    
    private function updateTeamMode() : Void
    {
        var _sw0_ = (teamModes.selectedIndex);        

        switch (_sw0_)
        {
            case 0:
                maxPlayersText.visible = maxPlayers.visible = true;
                maxTeamsText.visible = maxTeams.visible = false;
                maxPlayersPerTeamText.visible = maxPlayersPerTeam.visible = false;
            
            case 1:
                maxPlayersText.visible = maxPlayers.visible = false;
                maxTeamsText.visible = maxTeams.visible = true;
                maxPlayersPerTeamText.visible = maxPlayersPerTeam.visible = true;
        }
    }
}

class OwnerModsPanel extends Sprite
{
    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var view                             : Dynamic;
    private var room                             : Dynamic;
    
    private var panelName                             : Dynamic;
    private var iconCancelBtn                             : Dynamic;
    private var iconSaveBtn                             : Dynamic;
    
    private var pane                             : Dynamic;
    private var scrollbarWidth(default, never)                             : Dynamic= 15;
    private var scrollbar                             : Dynamic;
    
    private var enabledRate                             : Dynamic;
    private var optionRate                             : Dynamic;
    
    private var enabledHidden                             : Dynamic;
    private var optionHidden                             : Dynamic;
    private var enabledSudden                             : Dynamic;
    private var optionSudden                             : Dynamic;
    private var enabledBlink                             : Dynamic;
    private var optionBlink                             : Dynamic;
    
    private var enabledRotating                             : Dynamic;
    private var optionRotating                             : Dynamic;
    private var enabledRotateCW                             : Dynamic;
    private var optionRotateCW                             : Dynamic;
    private var enabledRotateCCW                             : Dynamic;
    private var optionRotateCCW                             : Dynamic;
    private var enabledWave                             : Dynamic;
    private var optionWave                             : Dynamic;
    private var enabledDrunk                             : Dynamic;
    private var optionDrunk                             : Dynamic;
    private var enabledTornado                             : Dynamic;
    private var optionTornado                             : Dynamic;
    private var enabledMiniResize                             : Dynamic;
    private var optionMiniResize                             : Dynamic;
    private var enabledTapPulse                             : Dynamic;
    private var optionTapPulse                             : Dynamic;
    
    private var enabledNoBackground                             : Dynamic;
    private var optionNoBackground                             : Dynamic;
    
    @:allow(classes.mp.views)
    private function new(view                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.view = view;
        this.room = room;
        
        panelName = new Text(this, 20, 0, "", 16);
        panelName.setAreaParams(view.width - 115, 30);
        
        iconCancelBtn = new UIIcon(this, new IconCancel(), view.width - 45, 16);
        iconCancelBtn.setSize(15, 15);
        iconCancelBtn.setColor("#eda8a8");
        iconCancelBtn.buttonMode = true;
        iconCancelBtn.addEventListener(MouseEvent.CLICK, e_cancelClick);
        
        iconSaveBtn = new UIIcon(this, new IconAccept(), view.width - 15, 16);
        iconSaveBtn.setSize(15, 15);
        iconSaveBtn.setColor("#bdeda8");
        iconSaveBtn.buttonMode = true;
        iconSaveBtn.addEventListener(MouseEvent.CLICK, e_saveClick);
        
        // Settings Pane
        pane = new ScrollPane(this, 1, 31, view.width - scrollbarWidth - 1, view.height - 31, e_mouseWheelHandler);
        scrollbar = new ScrollBar(this, view.width - scrollbarWidth, 31, scrollbarWidth, view.height - 31, null, new Sprite(), e_scrollbarUpdater);
        
        // Scrollbar BG
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0xFFFFFF, 0.05);
        this.graphics.drawRect(view.width - scrollbarWidth, 31, scrollbarWidth, view.height - 31);
        this.graphics.endFill();
        
        // Scrollbar
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(view.width - scrollbarWidth - 1, 31);
        this.graphics.lineTo(view.width - scrollbarWidth - 1, view.height);
        
        // Mods
        var xOff                             : Dynamic= 12;
        var yOff                             : Dynamic= 39;
        
        var enabledHelp                             : Dynamic= new UIIconHover(pane.content, new IconLock(), 20, 16);
        enabledHelp.setSize(16, 16);
        enabledHelp.setHoverText("Force Modifiers");
        enabledHelp.setColor("#c7c7c7");
        
        new Text(pane.content, 40, 5, _lang.string("mp_room_options_mods"), 12, "#c7c7c7");
        
        enabledRate = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionRate = new ValidatedText(pane.content, xOff + 32, yOff, 80, 20, ValidatedText.R_FLOAT_P, e_changeListener);
        new Text(pane.content, xOff + 122, yOff, _lang.string("options_rate"));
        yOff += 35;
        
        enabledHidden = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionHidden = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_hidden"));
        yOff += 25;
        
        enabledSudden = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionSudden = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_sudden"));
        yOff += 25;
        
        enabledBlink = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionBlink = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_blink"));
        yOff += 35;
        
        enabledRotating = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionRotating = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_rotating"));
        yOff += 25;
        
        enabledRotateCW = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionRotateCW = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_rotate_cw"));
        yOff += 25;
        
        enabledRotateCCW = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionRotateCCW = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_rotate_ccw"));
        yOff += 25;
        
        enabledWave = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionWave = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_wave"));
        yOff += 25;
        
        enabledDrunk = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionDrunk = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_drunk"));
        yOff += 25;
        
        enabledTornado = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionTornado = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_tornado"));
        yOff += 25;
        
        enabledMiniResize = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionMiniResize = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_mini_resize"));
        yOff += 25;
        
        enabledTapPulse = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionTapPulse = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_tap_pulse"));
        yOff += 35;
        
        enabledNoBackground = new BoxCheck(pane.content, xOff, yOff + 2, e_changeListener);
        optionNoBackground = new BoxCheck(pane.content, xOff + 32, yOff + 2, e_changeListener);
        new Text(pane.content, xOff + 54, yOff, _lang.string("options_mod_nobackground"));
        yOff += 25;
        
        
        // Mod Borders
        pane.content.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        pane.content.graphics.moveTo(5, 30);
        pane.content.graphics.lineTo(view.width - scrollbarWidth - 7, 30);
        pane.content.graphics.moveTo(35, 5);
        pane.content.graphics.lineTo(35, Math.max(view.height - 36, yOff + 5));
        
        pane.update();
        scrollbar.draggerVisibility = (yOff > view.height - 30 && pane.content.height > pane.height - 5);
        
        update();
    }
    
    public function update() : Void
    {
        panelName.text = (room.name) ? room.name : "";
        
        enabledRate.checked = room.mods.rate.enabled;
        optionRate.text = Std.string(room.mods.rate.value);
        
        enabledHidden.checked = room.mods.hidden.enabled;
        optionHidden.checked = room.mods.hidden.value;
        
        enabledSudden.checked = room.mods.sudden.enabled;
        optionSudden.checked = room.mods.sudden.value;
        
        enabledBlink.checked = room.mods.blink.enabled;
        optionBlink.checked = room.mods.blink.value;
        
        enabledRotating.checked = room.mods.rotating.enabled;
        optionRotating.checked = room.mods.rotating.value;
        
        enabledRotateCW.checked = room.mods.rotate_cw.enabled;
        optionRotateCW.checked = room.mods.rotate_cw.value;
        
        enabledRotateCCW.checked = room.mods.rotate_ccw.enabled;
        optionRotateCCW.checked = room.mods.rotate_ccw.value;
        
        enabledWave.checked = room.mods.wave.enabled;
        optionWave.checked = room.mods.wave.value;
        
        enabledDrunk.checked = room.mods.drunk.enabled;
        optionDrunk.checked = room.mods.drunk.value;
        
        enabledTornado.checked = room.mods.tornado.enabled;
        optionTornado.checked = room.mods.tornado.value;
        
        enabledMiniResize.checked = room.mods.mini_resize.enabled;
        optionMiniResize.checked = room.mods.mini_resize.value;
        
        enabledTapPulse.checked = room.mods.tap_pulse.enabled;
        optionTapPulse.checked = room.mods.tap_pulse.value;
        
        enabledNoBackground.checked = room.mods.nobackground.enabled;
        optionNoBackground.checked = room.mods.nobackground.value;
    }
    
    private function e_saveClick(e                             : Dynamic) : Void
    {
        view.setPanelOwner();
        
        // Build command
        var mods                             : Dynamic= { };
        
        if (as3hx.Compat.truthy(enabledRate.checked))
        {
            var newSongRate                             : Dynamic= optionRate.validate(1, 0.1);
            newSongRate = Math.max(0.1, Math.min(200, Math.round(newSongRate * 1000) / 1000));
            if (as3hx.Compat.truthy(Math.isNaN(newSongRate) || !Math.isFinite(newSongRate)))
            {
                newSongRate = 1;
            }
            
            mods.rate = newSongRate;
        }
        
        if (as3hx.Compat.truthy(enabledHidden.checked))
        {
            mods.hidden = optionHidden.checked;
        }
        if (as3hx.Compat.truthy(enabledSudden.checked))
        {
            mods.sudden = optionSudden.checked;
        }
        if (as3hx.Compat.truthy(enabledBlink.checked))
        {
            mods.blink = optionBlink.checked;
        }
        if (as3hx.Compat.truthy(enabledRotating.checked))
        {
            mods.rotating = optionRotating.checked;
        }
        if (as3hx.Compat.truthy(enabledRotateCW.checked))
        {
            mods.rotate_cw = optionRotateCW.checked;
        }
        if (as3hx.Compat.truthy(enabledRotateCCW.checked))
        {
            mods.rotate_ccw = optionRotateCCW.checked;
        }
        if (as3hx.Compat.truthy(enabledWave.checked))
        {
            mods.wave = optionWave.checked;
        }
        if (as3hx.Compat.truthy(enabledDrunk.checked))
        {
            mods.drunk = optionDrunk.checked;
        }
        if (as3hx.Compat.truthy(enabledTornado.checked))
        {
            mods.tornado = optionTornado.checked;
        }
        if (as3hx.Compat.truthy(enabledMiniResize.checked))
        {
            mods.mini_resize = optionMiniResize.checked;
        }
        if (as3hx.Compat.truthy(enabledTapPulse.checked))
        {
            mods.tap_pulse = optionTapPulse.checked;
        }
        if (as3hx.Compat.truthy(enabledNoBackground.checked))
        {
            mods.nobackground = optionNoBackground.checked;
        }
        
        _mp.sendCommand(new MPCFFRGameModifiers(room, mods));
    }
    
    private function e_cancelClick(e                             : Dynamic) : Void
    {
        view.setPanelOwner();
    }
    
    private function e_changeListener(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, BoxCheck)))
        {
            (try cast(e.target, BoxCheck) catch(e:Dynamic) null).checked = !((try cast(e.target, BoxCheck) catch(e:Dynamic) null).checked);
        }
        else if (as3hx.Compat.truthy(e.target == optionRate))
        {
            optionRate.validate(1, 0.1);
        }
    }
    
    /**
     * Mouse Wheel Handler for the Mods Pane.
     * Moves the scroll pane based on the scroll delta direction.
     * @param e
     */
    private function e_mouseWheelHandler(e                             : Dynamic) : Void
    // Sanity
    {
        
        if (as3hx.Compat.truthy(!scrollbar.draggerVisibility))
        {
            return;
        }
        
        // Scroll
        var newScrollPosition                             : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(newScrollPosition);
        scrollbar.scrollTo(newScrollPosition);
    }
    
    private function e_scrollbarUpdater(e                             : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
}
