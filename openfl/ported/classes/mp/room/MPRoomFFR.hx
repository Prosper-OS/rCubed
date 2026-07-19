package classes.mp.room;

import classes.Playlist;
import classes.SongInfo;
import classes.chart.Song;
import classes.mp.MPSocketDataRaw;
import classes.mp.MPSocketDataText;
import classes.mp.MPSong;
import classes.mp.MPTeam;
import classes.mp.MPUser;
import classes.mp.commands.MPCFFRSongPlayable;
import classes.mp.commands.MPCFFRSongRate;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPRoomRawEvent;
import classes.mp.mode.ffr.MPFFRState;
import classes.mp.mode.ffr.MPGameplayMods;
import classes.mp.mode.ffr.MPMatchFFR;
import classes.mp.mode.ffr.MPMatchFFRUser;
import classes.mp.mode.ffr.MPMatchResultsFFR;
import openfl.utils.Dictionary;
import game.GameScoreResult;
import menu.FileLoader;

class MPRoomFFR extends MPRoom
{
    public var isCurrentPlayer(get, never) : Bool;

    public var songData : MPSong = new MPSong();
    public var songInfo : SongInfo;
    public var song : Song;
    
    public var mods : MPGameplayMods = new MPGameplayMods();
    
    public var activeMatch : MPMatchFFR;
    
    public var lastMatch : MPMatchResultsFFR;
    public var lastMatchHistory : Array<MPMatchResultsFFR>;
    public var lastMatchIndex : Int = -1;
    public var lastMatchScorePersonal : GameScoreResult;
    
    public var player_states : Array<MPFFRState> = [];
    public var player_state_map : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
    
    public function new()
    {
        super();
    }
    
    override public function update(data : Dynamic) : Void
    {
        super.update(data);
        
        if (data.vars != null)
        {
            if (data.vars.mode != null)
            {
                updateVarsMode(data.vars.mode);
            }
            
            if (data.vars.user != null)
            {
                updateVarsUser(data.vars.user);
            }
        }
        
        if (data.match != null)
        {
            updateLastMatch(data.match);
        }
    }
    
    override public function clearExtra() : Void
    {
        super.clearExtra();
        
        activeMatch = null;
        lastMatchHistory = null;
    }
    
    public function updateVarsMode(modeData : Dynamic) : Void
    {
        if (modeData.song_details != null)
        {
            songData.update(modeData.song_details);
            updateSongInfo();
            updateAccessCheck();
        }
        
        if (modeData.mod_details != null)
        {
            mods.update(modeData.mod_details);
        }
    }
    
    public function updateVarsUser(userData : Array<Dynamic>) : Void
    {
        var i : Float = userData.length - 1;
        while (i >= 0)
        {
            var user : MPUser = getUser(Reflect.field(userData, Std.string(i)).uid);
            var userVars : MPFFRState = player_state_map[user.uid];
            
            if (userVars == null)
            {
                userVars = new MPFFRState(this, user);
                player_states.push(userVars);
                player_state_map[user.uid] = userVars;
            }
            userVars.update(Reflect.field(userData, Std.string(i)));
            i--;
        }
        
        _clearMissingPlayerData();
    }
    
    public function updateLastMatch(matchInfo : Dynamic) : Void
    {
        lastMatch = new MPMatchResultsFFR(this, lastMatchHistory.length);
        lastMatch.update(matchInfo);
        lastMatchHistory.push(lastMatch);
    }
    
    override public function onJoin() : Void
    {
        super.onJoin();
        
        activeMatch = new MPMatchFFR(this);
        lastMatchHistory = [];
    }
    
    override public function userJoinTeam(user : MPUser, teamUID : Int, vars : Dynamic = null) : Void
    {
        super.userJoinTeam(user, teamUID);
        
        var team : MPTeam = teams_map[teamUID];
        if (team != null && !team.spectator)
        {
            var needPlayerData : Bool = true;
            var i : Float = player_states.length - 1;
            while (i >= 0)
            {
                if (Reflect.field(player_states, Std.string(i)).user == user)
                {
                    needPlayerData = false;
                }
                i--;
            }
            
            if (needPlayerData)
            {
                var playerData : MPFFRState = new MPFFRState(this, user);
                playerData.update(vars);
                player_states.push(playerData);
                player_state_map[user.uid] = playerData;
            }
            
            if (_mp.currentUser == user)
            {
                updateAccessCheck();
            }
        }
    }
    
    override public function userLeaveTeam(user : MPUser, teamUID : Int) : Void
    {
        super.userLeaveTeam(user, teamUID);
        
        var team : MPTeam = teams_map[teamUID];
        if (team != null && !team.spectator)
        {
            var i : Float = player_states.length - 1;
            while (i >= 0)
            {
                if (Reflect.field(player_states, Std.string(i)).user == user)
                {
                    player_states.splice(i, 1);
                }
                i--;
            }
            Reflect.deleteField(player_state_map, Std.string(null));
        }
    }
    
    override public function modeCommand(cmd : MPSocketDataText, user : MPUser) : Void
    {
        var _sw0_ = (cmd.action);        

        switch (_sw0_)
        {
            case "game_state":
                modeGameState(user, cmd);
            
            case "game_mods":
                modeGameMods(user, cmd);
            
            case "playable_state":
                modePlayableState(user, cmd);
            
            case "song_rate":
                modeSongRate(user, cmd);
            
            case "song_change":
                modeSongChange(user, cmd);
            
            case "song_request":
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_REQUEST, cmd, this, user));
            
            case "ready_state":
                modeReadyState(user, cmd);
            
            case "force_start":
                update(cmd.data);
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_FORCE_START, cmd, this, user));
            
            case "loading_start":
                update(cmd.data);
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_LOADING_START, cmd, this, user));
            
            case "loading":
                modeLoadingProgress(user, cmd);
            
            case "loading_abort":
                update(cmd.data);
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_LOADING_ABORT, cmd, this, user));
            
            case "countdown":
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_COUNTDOWN, cmd, this, user));
            
            case "match_start":
                modeMatchStart(user, cmd);
            
            case "auto_spectate":
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_AUTO_SPECTATE, cmd, this, user));
            
            case "song_start":
                modeSongStart(user, cmd);
            
            case "score_update":
                modeScoreUpdate(user, cmd);
            
            case "score_update_users":
                modeScoreUpdateInProgress(user, cmd);
            
            case "match_end":
                update(cmd.data);
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_MATCH_END, cmd, this, user));
            default:
                trace("unknown mode command:");
                trace(user, cmd);
        }
    }
    
    override public function modeRawCommand(cmd : MPSocketDataRaw, user : MPUser) : Void
    {
        var _sw1_ = (cmd.action);        

        switch (_sw1_)
        {
            case MPEvent.FFR_RAW_PLAYBACK_REQUEST:
                _mp.dispatchEvent(new MPRoomRawEvent(MPEvent.FFR_GET_PLAYBACK, cmd, this, user));
            
            case MPEvent.FFR_RAW_SCORE_HISTORY_REQUEST:
                _mp.dispatchEvent(new MPRoomRawEvent(MPEvent.FFR_GET_SCORE_HISTORY, cmd, this, user));
        }
    }
    
    private function modeSongChange(user : MPUser, cmd : MPSocketDataText) : Void
    {
        songData.update(cmd.data);
        updateSongInfo(user, cmd);
        updateAccessCheck();
    }
    
    private function modeGameMods(user : MPUser, cmd : MPSocketDataText) : Void
    {
        mods.update(cmd.data.value);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_GAME_MODS, cmd, this, user));
    }
    
    private function modeGameState(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.game_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_GAME_STATE, cmd, this, user));
    }
    
    private function modePlayableState(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.playable_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_PLAYABLE_STATE, cmd, this, user));
    }
    
    private function modeSongRate(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.song_rate = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_RATE, cmd, this, user));
    }
    
    private function modeLoadingProgress(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.loading_state = cmd.data.complete;
        playerVars.loading_percent = cmd.data.value;
        
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_LOADING, cmd, this, user));
    }
    
    private function modeReadyState(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.ready_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_READY_STATE, cmd, this, user));
    }
    
    private function modeMatchStart(user : MPUser, cmd : MPSocketDataText) : Void
    {
        activeMatch = new MPMatchFFR(this);
        activeMatch.build(cmd.data);
        
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_MATCH_START, cmd, this, user));
    }
    
    private function modeSongStart(user : MPUser, cmd : MPSocketDataText) : Void
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return;
        }
        
        playerVars.game_state = cmd.data.game_state;
        playerVars.settings = cmd.data.settings;
        playerVars.noteskin = cmd.data.noteskin;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_START, cmd, this, user));
    }
    
    private function modeScoreUpdate(user : MPUser, cmd : MPSocketDataText) : Void
    {
        activeMatch.update(cmd.data);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SCORE_UPDATE, cmd, this, user));
    }
    
    private function modeScoreUpdateInProgress(user : MPUser, cmd : MPSocketDataText) : Void
    {
        activeMatch.build(cmd.data);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SCORE_UPDATE, cmd, this, user));
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    private function updateSongInfo(user : MPUser = null, cmd : MPSocketDataText = null) : Void
    {
        songInfo = null;
        
        if (songData == null || !songData.selected)
        {
            _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
            return;
        }
        
        var loadedPlaylist : Playlist = Playlist.instance;
        var isAltLoaded : Bool = loadedPlaylist.engine != null;
        
        // Alt Engine
        if (songData.engine)
        {
            if (songData.engine.id == "fileloader")
            {
                if (songData.engine.cacheID != null)
                {
                    var chartPath : String = FileLoader.cache.findKey(function(entry : Dynamic) : Dynamic
                            {
                                return Reflect.field(entry, "id") == songData.engine.cacheID;
                            });
                    
                    songInfo = FileLoader.buildSongInfo(chartPath, songData.engine.chartID, true);
                }
                
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
                return;
            }
            else
            {
                songInfo = new SongInfo();
                songInfo.engine = songData.engine;
                songInfo.level = songData.id;
                songInfo.level_id = songData.level_id;
                songInfo.name = songData.name;
                songInfo.author = songData.author;
                songInfo.time = songData.time;
                songInfo.note_count = songData.note_count;
                songInfo.difficulty = songData.difficulty;
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
                return;
            }
        }
        // Canon Engine
        else
        {
            
            {
                var ffrSongsMatch : Array<SongInfo> = Playlist.instanceCanon.indexList.filter(function(item : SongInfo, index : Int, vec : Array<SongInfo>) : Bool
                        {
                            return item.level == songData.id;
                        });
                
                if (ffrSongsMatch.length == 1)
                {
                    songInfo = ffrSongsMatch[0];
                }
                
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
            }
        }
    }
    
    public function updateAccessCheck() : Void
    {
        var cmd_play : MPCFFRSongPlayable = new MPCFFRSongPlayable(this);
        if (songInfo != null)
        {
            cmd_play.canPlay = songInfo.access == 0;
            cmd_play.id = songInfo.level;
            cmd_play.level_id = songInfo.level_id;
            cmd_play.engine = songInfo.engine;
        }
        else
        {
            cmd_play.canPlay = false;
        }
        _mp.sendCommand(cmd_play);
        
        _mp.sendCommand(new MPCFFRSongRate(this, GlobalVariables.instance.playerUser.songRate));
    }
    
    public function getPlayerVariables(user : MPUser) : MPFFRState
    {
        return player_state_map[user.uid];
    }
    
    public function getPlayerScore(user : MPUser) : MPMatchFFRUser
    {
        return activeMatch.users_map[user.uid];
    }
    
    public function getPlayerState(user : MPUser) : String
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return null;
        }
        
        return playerVars.game_state;
    }
    
    public function getPlayerSongRate(user : MPUser) : Float
    {
        if (mods.rate.enabled)
        {
            return mods.rate.value;
        }
        
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return 1;
        }
        
        return playerVars.song_rate;
    }
    
    override public function isPlayerReady(user : MPUser) : Bool
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return false;
        }
        
        return playerVars.ready_state;
    }
    
    public function canAllUsersPlay() : Bool
    {
        var canPlay : Bool = true;
        
        var i : Float = player_states.length - 1;
        while (i >= 0)
        {
            var vars : MPFFRState = Reflect.field(player_states, Std.string(i));
            
            if (vars.playable_state != 1)
            {
                canPlay = false;
                break;
            }
            i--;
        }
        
        return canPlay;
    }
    
    public function isAllPlayersReady() : Bool
    {
        var isReady : Bool = true;
        
        var i : Float = player_states.length - 1;
        while (i >= 0)
        {
            var vars : MPFFRState = Reflect.field(player_states, Std.string(i));
            
            if (vars.user != owner && !vars.ready_state)
            {
                isReady = false;
                break;
            }
            i--;
        }
        
        return isReady;
    }
    
    override public function canUserPlaySong(user : MPUser) : Bool
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return false;
        }
        
        return playerVars.playable_state == 1;
    }
    
    public function isSongLoaded() : Bool
    {
        return song != null && song.isLoaded;
    }
    
    public function isPlayerLoaded(user : MPUser) : Bool
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return false;
        }
        
        return playerVars.loading_state;
    }
    
    public function getPlayerLoadingProgress(user : MPUser) : Float
    {
        var playerVars : MPFFRState = player_state_map[user.uid];
        if (playerVars == null)
        {
            return 0;
        }
        
        return playerVars.loading_percent;
    }
    
    private function _clearMissingPlayerData() : Void
    {
        var i : Float = player_states.length - 1;
        while (i >= 0)
        {
            var playerData : MPFFRState = Reflect.field(player_states, Std.string(i));
            
            if (!isPlayer(playerData.user))
            {
                player_states.splice(i, 1);
                Reflect.deleteField(player_state_map, Std.string(null));
            }
            i--;
        }
    }
    
    private function get_isCurrentPlayer() : Bool
    {
        return !this.teamSpectator.contains(_mp.currentUser);
    }
    
    override public function toString() : String
    {
        return "[MPRoomFFR uid=" + uid + ", name=" + name + "]";
    }
}

