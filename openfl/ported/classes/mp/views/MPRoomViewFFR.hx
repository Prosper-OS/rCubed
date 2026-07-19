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
    private static var _noteskins : Noteskins = Noteskins.instance;
    
    public var room : MPRoomFFR;
    
    private var _width : Float = 409;
    private var _height : Float = 388;
    
    private var chat : MPViewChatLogRoom;
    private var userlist : MPViewUserListRoom;
    
    private var autoSpectateButton : UIIconHover;
    private var inviteButton : UIIconHover;
    
    private var ownerPanel : OwnerPanel;
    private var ownerEditPanel : OwnerEditPanel;
    private var ownerModsPanel : OwnerModsPanel;
    private var userPanel : UserPanel;
    
    private var _userProfilePrompt : MPUserProfilePrompt;
    private var _userInvitePrompt : MPRoomUserInvitePrompt;
    
    private var loadProgressTimer : Timer = new Timer(500);
    private var autoSpectate : Bool = false;
    private var autoSpectatePlayer : MPUser;
    
    public function new(room : MPRoomFFR, parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0)
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
        
        if (_mp.currentUser == room.owner)
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
    
    override public function onKeyInput(e : KeyboardEvent) : Void
    {
        if (_userInvitePrompt != null)
        {
            _userInvitePrompt.onKeyInput(e);
            return;
        }
        
        if (_userProfilePrompt != null)
        {
            _userProfilePrompt.onKeyInput(e);
            return;
        }
        
        chat.onKeyInput(e);
    }
    
    public function onChatMessage(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            chat.onChatMessage(e);
        }
    }
    
    override private function updateRoomButton() : Void
    {
        if (room.spectatorCount > 0)
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
    
    override private function set_width(value : Float) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value : Float) : Float
    {
        _height = height;
        redraw();
        return value;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override private function e_roomUpdate(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override private function e_roomEdit(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override private function e_roomMessage(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            onChatMessage(e);
        }
    }
    
    override private function e_teamUpdate(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    private function e_gameState(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.updateGameStates();
        }
    }
    
    private function e_gameMods(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.updateGameStates();
            updatePanelDisplay();
        }
    }
    
    private function e_playableState(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            ownerPanel.update();
            userPanel.update();
        }
    }
    
    private function e_songRate(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.updateGameStates();
        }
    }
    
    override private function e_userJoin(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.USER_JOIN + "\">" + sprintf(_lang.string("mp_room_chat_user_join"), {
                                user : e.user.name
                            }) + "</font>"));
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
        }
    }
    
    override private function e_userLeave(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.USER_LEAVE + "\">" + sprintf(_lang.string("mp_room_chat_user_left"), {
                                user : e.user.name
                            }) + "</font>"));
            userlist.update();
            updateRoomButton();
            updatePanelDisplay();
            
            if (autoSpectatePlayer == e.user && autoSpectate)
            {
                e_autoSpectateClick(null);
            }
        }
    }
    
    private function e_songUpdate(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            updatePanelDisplay();
        }
    }
    
    private function e_songRequest(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            var info : MPSong = new MPSong();
            info.update(e.command.data);
            info.selected = false;
            
            chat.addItem(new MPChatLogEntrySong(e.room, e.user, info));
            userlist.update();
            updateRoomButton();
        }
    }
    
    private function e_readyState(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            ownerPanel.update();
        }
    }
    
    private function e_loadingStart(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            _startSongLoading();
        }
    }
    
    private function e_loadingProgress(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.updateGameStates();
        }
    }
    
    private function e_loadingAbort(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            _abortSongLoading();
        }
    }
    
    private function e_matchStart(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + _lang.string("mp_room_ffr_match_start") + "</font>"));
            _gameMatchStart();
        }
    }
    
    private function e_songStart(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.updateGameStates();
        }
    }
    
    private function e_autoSpectate(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            if (autoSpectate)
            {
                if (room.isPlayer(_mp.currentUser))
                {
                    return;
                }
                
                // Set Player
                if (autoSpectatePlayer != null)
                {
                    _spectatePlayer(autoSpectatePlayer);
                    return;
                }
                
                // Random Player
                var gameUsers : Array<MPUser> = room.users.filter(function(user : MPUser, index : Int, array : Array<MPUser>) : Bool
                        {
                            return room.isPlayer(user) && room.getPlayerState(user) == "game";
                        });
                
                if (gameUsers.length > 0)
                {
                    _spectatePlayer(gameUsers[Math.floor(Math.random() * gameUsers.length)]);
                }
            }
        }
    }
    
    private function e_matchEnd(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            userlist.update();
            userlist.updateGameStates();
            updateRoomButton();
            updatePanelDisplay();
            
            chat.addItem(new MPChatLogEntryMatchResults(room, room.lastMatch));
        }
    }
    
    private function e_countdown(e : MPRoomEvent) : Void
    {
        if (e.room == this.room)
        {
            if (e.command.data.value > 5)
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
    
    private function e_autoSpectateClick(e : MouseEvent) : Void
    {
        autoSpectate = !autoSpectate;
        autoSpectateButton.setColor((autoSpectate) ? "#bdeda8" : "#eda8a8");
        
        if (autoSpectatePlayer != null)
        {
            Alert.add(_lang.string("mp_room_spectate_user_clear"), 120, 0x005e5e);
            autoSpectatePlayer = null;
        }
    }
    
    private function e_inviteClick(e : MouseEvent) : Void
    {
        _userInvitePrompt = new MPRoomUserInvitePrompt(this.room, this);
        _userInvitePrompt.addEventListener(Event.CLOSE, e_onInviteClose);
    }
    
    private function e_onInviteClose(e : Event) : Void
    {
        _userInvitePrompt.removeEventListener(Event.CLOSE, e_onInviteClose);
        _userInvitePrompt = null;
    }
    
    private function e_onUserSelect(e : MPUserEvent) : Void
    {
        _userProfilePrompt = new MPUserProfilePrompt(e.user, this.room, this);
        _userProfilePrompt.addEventListener(Event.CLOSE, e_onProfileClose);
        _userProfilePrompt.addEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectate);
    }
    
    private function e_onUserSpectateUserlist(e : MPUserEvent) : Void
    {
        if (autoSpectate)
        {
            autoSpectatePlayer = e.user;
            Alert.add(sprintf(_lang.string("mp_room_spectate_user_select"), {
                                name : e.user.name
                            }), 120, 0x005e5e);
        }
        
        _spectatePlayer(e.user);
    }
    
    private function e_onUserSpectate(e : MPUserEvent) : Void
    {
        _spectatePlayer(e.user);
    }
    
    private function e_onProfileClose(e : Event) : Void
    {
        _userProfilePrompt.removeEventListener(MPEvent.ROOM_USERLIST_SPECTATE, e_onUserSpectate);
        _userProfilePrompt.removeEventListener(Event.CLOSE, e_onProfileClose);
        _userProfilePrompt = null;
    }
    
    public function closePrompts() : Void
    {
        if (_userProfilePrompt != null)
        {
            _userProfilePrompt.close();
            e_onProfileClose(null);
        }
        
        if (_userInvitePrompt != null)
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
        if (this.room.owner == _mp.currentUser && userPanel.visible)
        {
            setPanelOwner();
        }
        
        // Update Owner -> User Switch
        if (this.room.owner != _mp.currentUser && (ownerPanel.visible || ownerEditPanel.visible || ownerModsPanel.visible))
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
        if (room.songInfo == null)
        {
            if (room.isPlayer(_mp.currentUser))
            {
                _mp.sendCommand(new MPCFFRSongLoadError(room));
            }
            return;
        }
        
        // Setup Local File
        if (room.songInfo.is_local)
        {
            FileLoader.buildSong(room.songInfo);
        }
        
        room.song = _gvars.getSongFile(room.songInfo);
        
        if (room.isSongLoaded())
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
    
    private function e_songFileComplete(e : Event) : Void
    {
        room.song.removeEventListener(Event.COMPLETE, e_songFileComplete);
        
        if (room.isSongLoaded())
        {
            _endSongLoading();
        }
    }
    
    private function e_loadProgressUpdaterTimer(e : TimerEvent) : Void
    {
        if (!room.song || room.isSongLoaded())
        {
            loadProgressTimer.stop();
        }
        else
        {
            if (room.song.loadFail)
            {
                _gvars.removeSongFile(room.song);
                room.song.removeEventListener(Event.COMPLETE, e_songFileComplete);
                room.song = null;
                
                if (room.isPlayer(_mp.currentUser))
                {
                    _mp.sendCommand(new MPCFFRSongLoadError(room));
                }
                
                Alert.add(sprintf(_lang.string("mp_room_ffr_song_load_error"), {
                                    song : room.songData.name
                                }));
                loadProgressTimer.stop();
                return;
            }
            
            if (room.isPlayer(_mp.currentUser))
            {
                _mp.sendCommand(new MPCFFRSongLoadProgress(room, room.song.progress, false));
            }
        }
    }
    
    private function _abortSongLoading() : Void
    {
        if (loadProgressTimer.running)
        {
            loadProgressTimer.removeEventListener(TimerEvent.TIMER, e_loadProgressUpdaterTimer);
            loadProgressTimer.stop();
        }
        
        chat.addItem(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + _lang.string("mp_room_chat_loading_abort") + "</font>"));
    }
    
    private function _endSongLoading() : Void
    {
        if (loadProgressTimer.running)
        {
            loadProgressTimer.removeEventListener(TimerEvent.TIMER, e_loadProgressUpdaterTimer);
            loadProgressTimer.stop();
        }
        
        if (room.isPlayer(_mp.currentUser))
        {
            var state : MPCFFRSongLoadProgress = new MPCFFRSongLoadProgress(room, 100, true);
            _mp.sendCommand(state);
        }
    }
    
    private function _gameMatchStart() : Void
    {
        if (room.isPlayer(_mp.currentUser))
        {
            closePrompts();
            
            if (!room.song)
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
    
    private function _spectatePlayer(user : MPUser) : Void
    {
        if (room.isPlayer(user) && room.getPlayerState(user) == "game")
        {
            closePrompts();
            
            Alert.add(sprintf(_lang.string("mp_room_spectate_user_start"), {
                                name : user.name
                            }), 120, 0x005e5e);
            
            if (!room.song)
            {
                room.song = _gvars.getSongFile(room.songInfo);
            }
            
            if (!room.song)
            {
                chat.addItem(new MPChatLogEntryText(_lang.string("mp_room_chat_spectate_error")));
                return;
            }
            
            var vars : MPFFRState = room.getPlayerVariables(user);
            
            room.song.isDirty = true;
            _gvars.options = new GameOptions();
            _gvars.options.settingsDecode(vars.settings);
            _gvars.options.song = room.song;
            _gvars.options.isMultiplayer = true;
            _gvars.options.isSpectator = true;
            _gvars.options.spectatorUser = user;
            
            // User Custom Noteskin.
            if (vars.noteskin == null && _gvars.options.noteskin == 0)
            {
                _gvars.options.noteskin = 1;
            }
            
            if (_gvars.options.noteskin == 0 && vars.noteskin != null)
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
    
    private function e_onNoteskinComplete(e : Event) : Void
    {
        _noteskins.removeEventListener(Noteskins.JSON_LOAD, e_onNoteskinComplete);
        _noteskins.removeEventListener(Noteskins.JSON_ERROR, e_onNoteskinCancel);
        _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
    }
    
    private function e_onNoteskinCancel(e : Event) : Void
    {
        _noteskins.removeEventListener(Noteskins.JSON_LOAD, e_onNoteskinComplete);
        _noteskins.removeEventListener(Noteskins.JSON_ERROR, e_onNoteskinCancel);
        _gvars.options.noteskin = 1;
        _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
    }
}



class UserPanel extends Sprite
{
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var view : MPRoomViewFFR;
    private var room : MPRoomFFR;
    
    private var panelName : Text;
    private var iconLeaveBtn : UIIconHover;
    
    private var songName : Text;
    private var songAuthor : Text;
    private var songLength : Text;
    private var songDifficulty : Text;
    
    private var ready : BoxButton;
    private var selectSong : BoxButton;
    
    @:allow(classes.mp.views)
    private function new(view : MPRoomViewFFR, room : MPRoomFFR)
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
        
        if (room.songData.selected)
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
        
        if (ready.enabled && !room.canUserPlaySong(_mp.currentUser))
        {
            ready.enabled = false;
        }
        
        ready.text = _lang.string((room.isPlayerReady(_mp.currentUser)) ? "mp_room_ffr_owner_unready" : "mp_room_ffr_owner_ready");
    }
    
    private function e_leaveClick(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCRoomLeave(room));
    }
    
    private function e_readyClick(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCFFRReady(room));
    }
    
    private function e_songsClick(e : MouseEvent) : Void
    {
        (try cast(this.view.parent, MenuMultiplayer) catch(e:Dynamic) null).switchTo(MainMenu.MENU_SONGSELECTION);
    }
}

class OwnerPanel extends Sprite
{
    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var view : MPRoomViewFFR;
    private var room : MPRoomFFR;
    
    private var panelName : Text;
    private var iconModsBtn : UIIconHover;
    private var iconEditBtn : UIIconHover;
    private var iconLeaveBtn : UIIconHover;
    
    private var songName : Text;
    private var songAuthor : Text;
    private var songLength : Text;
    private var songDifficulty : Text;
    
    private var ready : BoxButton;
    private var forceStart : BoxIcon;
    private var selectSong : BoxButton;
    private var selectMods : BoxButton;
    
    @:allow(classes.mp.views)
    private function new(view : MPRoomViewFFR, room : MPRoomFFR)
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
        
        if (room.songData.selected)
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
        
        if (ready.enabled && !room.canUserPlaySong(_mp.currentUser))
        {
            ready.enabled = false;
        }
        
        ready.text = _lang.string((room.isPlayerReady(_mp.currentUser)) ? "mp_room_ffr_owner_unready" : "mp_room_ffr_owner_ready");
    }
    
    private function e_modsClick(e : MouseEvent) : Void
    {
        view.setPanelMods();
    }
    
    private function e_editClick(e : MouseEvent) : Void
    {
        view.setPanelEdit();
    }
    
    private function e_leaveClick(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCRoomLeave(room));
    }
    
    private function e_readyClick(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCFFRReady(room));
    }
    
    private function e_forceStartClick(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCFFRReadyForce(room));
    }
    
    private function e_songsClick(e : MouseEvent) : Void
    {
        (try cast(this.view.parent, MenuMultiplayer) catch(e:Dynamic) null).switchTo(MainMenu.MENU_SONGSELECTION);
    }
}

class OwnerEditPanel extends Sprite
{
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var view : MPRoomViewFFR;
    private var room : MPRoomFFR;
    
    private var panelName : BoxText;
    private var iconCancelBtn : UIIcon;
    private var iconSaveBtn : UIIcon;
    
    private var roomPassword : BoxText;
    private var showPassword : BoxIcon;
    private var joinCode : Text;
    
    private var teamModes : ComboBox;
    
    private var maxPlayersText : Text;
    private var maxPlayers : ComboBox;
    
    private var maxTeamsText : Text;
    private var maxTeams : ComboBox;
    private var maxPlayersPerTeamText : Text;
    private var maxPlayersPerTeam : ComboBox;
    
    @:allow(classes.mp.views)
    private function new(view : MPRoomViewFFR, room : MPRoomFFR)
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
        
        if ((room.teamCount - 1) > 1)
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
    
    private function e_cancelClick(e : MouseEvent) : Void
    {
        view.setPanelOwner();
    }
    
    private function e_onJoinClick(e : MouseEvent) : Void
    {
        var success : Bool = SystemUtil.setClipboard(room.joinCode);
        
        if (success)
        {
            Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
        }
        else
        {
            Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }
    }
    
    private function e_saveClick(e : MouseEvent) : Void
    {
        _mp.addEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.addEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
        
        var cmd : MPCRoomEdit = new MPCRoomEdit(room);
        cmd.name = panelName.text;
        cmd.password = roomPassword.text;
        
        // FFA
        if (teamModes.selectedItem.data == "ffa")
        {
            cmd.team_count = 1;
            cmd.max_players = as3hx.Compat.parseFloat(maxPlayers.selectedItem);
        }
        else if (teamModes.selectedItem.data == "team")
        {
            cmd.team_count = as3hx.Compat.parseFloat(maxTeams.selectedItem);
            cmd.max_players = as3hx.Compat.parseFloat(maxPlayersPerTeam.selectedItem);
        }
        
        _mp.sendCommand(cmd);
    }
    
    private function e_onEditOK(e : MPRoomEvent) : Void
    {
        _mp.removeEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.removeEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
        
        view.setPanelOwner();
    }
    
    private function e_onEditFail(e : MPEvent) : Void
    {
        _mp.removeEventListener(MPEvent.ROOM_EDIT_OK, e_onEditOK);
        _mp.removeEventListener(MPEvent.ROOM_EDIT_FAIL, e_onEditFail);
    }
    
    private function e_onTeamModeChange(e : Event) : Void
    {
        updateTeamMode();
    }
    
    private function e_togglePassword(e : Event) : Void
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
    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var view : MPRoomViewFFR;
    private var room : MPRoomFFR;
    
    private var panelName : Text;
    private var iconCancelBtn : UIIcon;
    private var iconSaveBtn : UIIcon;
    
    private var pane : ScrollPane;
    private var scrollbarWidth(default, never) : Float = 15;
    private var scrollbar : ScrollBar;
    
    private var enabledRate : BoxCheck;
    private var optionRate : ValidatedText;
    
    private var enabledHidden : BoxCheck;
    private var optionHidden : BoxCheck;
    private var enabledSudden : BoxCheck;
    private var optionSudden : BoxCheck;
    private var enabledBlink : BoxCheck;
    private var optionBlink : BoxCheck;
    
    private var enabledRotating : BoxCheck;
    private var optionRotating : BoxCheck;
    private var enabledRotateCW : BoxCheck;
    private var optionRotateCW : BoxCheck;
    private var enabledRotateCCW : BoxCheck;
    private var optionRotateCCW : BoxCheck;
    private var enabledWave : BoxCheck;
    private var optionWave : BoxCheck;
    private var enabledDrunk : BoxCheck;
    private var optionDrunk : BoxCheck;
    private var enabledTornado : BoxCheck;
    private var optionTornado : BoxCheck;
    private var enabledMiniResize : BoxCheck;
    private var optionMiniResize : BoxCheck;
    private var enabledTapPulse : BoxCheck;
    private var optionTapPulse : BoxCheck;
    
    private var enabledNoBackground : BoxCheck;
    private var optionNoBackground : BoxCheck;
    
    @:allow(classes.mp.views)
    private function new(view : MPRoomViewFFR, room : MPRoomFFR)
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
        var xOff : Float = 12;
        var yOff : Float = 39;
        
        var enabledHelp : UIIconHover = new UIIconHover(pane.content, new IconLock(), 20, 16);
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
    
    private function e_saveClick(e : MouseEvent) : Void
    {
        view.setPanelOwner();
        
        // Build command
        var mods : Dynamic = { };
        
        if (enabledRate.checked)
        {
            var newSongRate : Float = optionRate.validate(1, 0.1);
            newSongRate = Math.max(0.1, Math.min(200, Math.round(newSongRate * 1000) / 1000));
            if (Math.isNaN(newSongRate) || !Math.isFinite(newSongRate))
            {
                newSongRate = 1;
            }
            
            mods.rate = newSongRate;
        }
        
        if (enabledHidden.checked)
        {
            mods.hidden = optionHidden.checked;
        }
        if (enabledSudden.checked)
        {
            mods.sudden = optionSudden.checked;
        }
        if (enabledBlink.checked)
        {
            mods.blink = optionBlink.checked;
        }
        if (enabledRotating.checked)
        {
            mods.rotating = optionRotating.checked;
        }
        if (enabledRotateCW.checked)
        {
            mods.rotate_cw = optionRotateCW.checked;
        }
        if (enabledRotateCCW.checked)
        {
            mods.rotate_ccw = optionRotateCCW.checked;
        }
        if (enabledWave.checked)
        {
            mods.wave = optionWave.checked;
        }
        if (enabledDrunk.checked)
        {
            mods.drunk = optionDrunk.checked;
        }
        if (enabledTornado.checked)
        {
            mods.tornado = optionTornado.checked;
        }
        if (enabledMiniResize.checked)
        {
            mods.mini_resize = optionMiniResize.checked;
        }
        if (enabledTapPulse.checked)
        {
            mods.tap_pulse = optionTapPulse.checked;
        }
        if (enabledNoBackground.checked)
        {
            mods.nobackground = optionNoBackground.checked;
        }
        
        _mp.sendCommand(new MPCFFRGameModifiers(room, mods));
    }
    
    private function e_cancelClick(e : MouseEvent) : Void
    {
        view.setPanelOwner();
    }
    
    private function e_changeListener(e : Event) : Void
    {
        if (Std.is(e.target, BoxCheck))
        {
            (try cast(e.target, BoxCheck) catch(e:Dynamic) null).checked = !((try cast(e.target, BoxCheck) catch(e:Dynamic) null).checked);
        }
        else if (e.target == optionRate)
        {
            optionRate.validate(1, 0.1);
        }
    }
    
    /**
     * Mouse Wheel Handler for the Mods Pane.
     * Moves the scroll pane based on the scroll delta direction.
     * @param e
     */
    private function e_mouseWheelHandler(e : MouseEvent) : Void
    // Sanity
    {
        
        if (!scrollbar.draggerVisibility)
        {
            return;
        }
        
        // Scroll
        var newScrollPosition : Float = scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(newScrollPosition);
        scrollbar.scrollTo(newScrollPosition);
    }
    
    private function e_scrollbarUpdater(e : Event) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
}
