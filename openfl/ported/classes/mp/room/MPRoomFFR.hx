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
    public var isCurrentPlayer(get, never)                             : Dynamic;

    public var songData                             : Dynamic= new MPSong();
    public var songInfo                             : Dynamic;
    public var song                             : Dynamic;
    
    public var mods                             : Dynamic= new MPGameplayMods();
    
    public var activeMatch                             : Dynamic;
    
    public var lastMatch                             : Dynamic;
    public var lastMatchHistory                             : Dynamic;
    public var lastMatchIndex                             : Dynamic= -1;
    public var lastMatchScorePersonal                             : Dynamic;
    
    public var player_states                             : Dynamic= [];
    public var player_state_map                             : Dynamic= new Dictionary<Dynamic, Dynamic>(true);
    
    public function new()
    {
        super();
    }
    
    override public function update(data                             : Dynamic) : Void
    {
        super.update(data);
        
        if (as3hx.Compat.truthy(data.vars != null))
        {
            if (as3hx.Compat.truthy(data.vars.mode != null))
            {
                updateVarsMode(data.vars.mode);
            }
            
            if (as3hx.Compat.truthy(data.vars.user != null))
            {
                updateVarsUser(data.vars.user);
            }
        }
        
        if (as3hx.Compat.truthy(data.match != null))
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
    
    public function updateVarsMode(modeData                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(modeData.song_details != null))
        {
            songData.update(modeData.song_details);
            updateSongInfo();
            updateAccessCheck();
        }
        
        if (as3hx.Compat.truthy(modeData.mod_details != null))
        {
            mods.update(modeData.mod_details);
        }
    }
    
    public function updateVarsUser(userData                             : Dynamic) : Void
    {
        var i                             : Dynamic= userData.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var user                             : Dynamic= getUser(as3hx.Compat.field(userData, i).uid);
            var userVars                             : Dynamic= player_state_map[user.uid];
            
            if (as3hx.Compat.truthy(userVars == null))
            {
                userVars = new MPFFRState(this, user);
                player_states.push(userVars);
                player_state_map[user.uid] = userVars;
            }
            userVars.update(as3hx.Compat.field(userData, i));
            i--;
        }
        
        _clearMissingPlayerData();
    }
    
    public function updateLastMatch(matchInfo                             : Dynamic) : Void
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
    
    override public function userJoinTeam(user                             : Dynamic, teamUID                             : Dynamic, vars                             : Dynamic= null) : Void
    {
        super.userJoinTeam(user, teamUID);
        
        var team                             : Dynamic= teams_map[teamUID];
        if (as3hx.Compat.truthy(team != null && !team.spectator))
        {
            var needPlayerData                             : Dynamic= true;
            var i                             : Dynamic= player_states.length - 1;
            while (as3hx.Compat.truthy(i >= 0))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.field(player_states, i).user == user))
                {
                    needPlayerData = false;
                }
                i--;
            }
            
            if (as3hx.Compat.truthy(needPlayerData))
            {
                var playerData                             : Dynamic= new MPFFRState(this, user);
                playerData.update(vars);
                player_states.push(playerData);
                player_state_map[user.uid] = playerData;
            }
            
            if (as3hx.Compat.truthy(_mp.currentUser == user))
            {
                updateAccessCheck();
            }
        }
    }
    
    override public function userLeaveTeam(user                             : Dynamic, teamUID                             : Dynamic) : Void
    {
        super.userLeaveTeam(user, teamUID);
        
        var team                             : Dynamic= teams_map[teamUID];
        if (as3hx.Compat.truthy(team != null && !team.spectator))
        {
            var i                             : Dynamic= player_states.length - 1;
            while (as3hx.Compat.truthy(i >= 0))
            {
                if (as3hx.Compat.truthy(as3hx.Compat.field(player_states, i).user == user))
                {
                    player_states.splice(i, 1);
                }
                i--;
            }
            Reflect.deleteField(player_state_map, Std.string(null));
        }
    }
    
    override public function modeCommand(cmd                             : Dynamic, user                             : Dynamic) : Void
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
    
    override public function modeRawCommand(cmd                             : Dynamic, user                             : Dynamic) : Void
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
    
    private function modeSongChange(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        songData.update(cmd.data);
        updateSongInfo(user, cmd);
        updateAccessCheck();
    }
    
    private function modeGameMods(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        mods.update(cmd.data.value);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_GAME_MODS, cmd, this, user));
    }
    
    private function modeGameState(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.game_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_GAME_STATE, cmd, this, user));
    }
    
    private function modePlayableState(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.playable_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_PLAYABLE_STATE, cmd, this, user));
    }
    
    private function modeSongRate(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.song_rate = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_RATE, cmd, this, user));
    }
    
    private function modeLoadingProgress(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.loading_state = cmd.data.complete;
        playerVars.loading_percent = cmd.data.value;
        
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_LOADING, cmd, this, user));
    }
    
    private function modeReadyState(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.ready_state = cmd.data.value;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_READY_STATE, cmd, this, user));
    }
    
    private function modeMatchStart(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        activeMatch = new MPMatchFFR(this);
        activeMatch.build(cmd.data);
        
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_MATCH_START, cmd, this, user));
    }
    
    private function modeSongStart(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return;
        }
        
        playerVars.game_state = cmd.data.game_state;
        playerVars.settings = cmd.data.settings;
        playerVars.noteskin = cmd.data.noteskin;
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_START, cmd, this, user));
    }
    
    private function modeScoreUpdate(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        activeMatch.update(cmd.data);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SCORE_UPDATE, cmd, this, user));
    }
    
    private function modeScoreUpdateInProgress(user                             : Dynamic, cmd                             : Dynamic) : Void
    {
        activeMatch.build(cmd.data);
        _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SCORE_UPDATE, cmd, this, user));
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    private function updateSongInfo(user                             : Dynamic= null, cmd                             : Dynamic= null) : Void
    {
        songInfo = null;
        
        if (as3hx.Compat.truthy(songData == null || !songData.selected))
        {
            _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
            return;
        }
        
        var loadedPlaylist                             : Dynamic= Playlist.instance;
        var isAltLoaded                             : Dynamic= loadedPlaylist.engine != null;
        
        // Alt Engine
        if (as3hx.Compat.truthy(songData.engine))
        {
            if (as3hx.Compat.truthy(songData.engine.id == "fileloader"))
            {
                if (as3hx.Compat.truthy(songData.engine.cacheID != null))
                {
                    var chartPath                             : Dynamic= FileLoader.cache.findKey(function(entry                             : Dynamic) : Dynamic
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
                var ffrSongsMatch                             : Dynamic= Playlist.instanceCanon.indexList.filter(function(item                             : Dynamic, index                             : Dynamic, vec                             : Dynamic) : Bool
                        {
                            return item.level == songData.id;
                        });
                
                if (as3hx.Compat.truthy(ffrSongsMatch.length == 1))
                {
                    songInfo = ffrSongsMatch[0];
                }
                
                _mp.dispatchEvent(new MPRoomEvent(MPEvent.FFR_SONG_CHANGE, cmd, this, user));
            }
        }
    }
    
    public function updateAccessCheck() : Void
    {
        var cmd_play                             : Dynamic= new MPCFFRSongPlayable(this);
        if (as3hx.Compat.truthy(songInfo != null))
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
    
    public function getPlayerVariables(user                             : Dynamic) : MPFFRState
    {
        return player_state_map[user.uid];
    }
    
    public function getPlayerScore(user                             : Dynamic) : MPMatchFFRUser
    {
        return activeMatch.users_map[user.uid];
    }
    
    public function getPlayerState(user                             : Dynamic) : String
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return null;
        }
        
        return playerVars.game_state;
    }
    
    public function getPlayerSongRate(user                             : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(mods.rate.enabled))
        {
            return mods.rate.value;
        }
        
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return 1;
        }
        
        return playerVars.song_rate;
    }
    
    override public function isPlayerReady(user                             : Dynamic) : Bool
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return false;
        }
        
        return playerVars.ready_state;
    }
    
    public function canAllUsersPlay() : Bool
    {
        var canPlay                             : Dynamic= true;
        
        var i                             : Dynamic= player_states.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var vars                             : Dynamic= as3hx.Compat.field(player_states, i);
            
            if (as3hx.Compat.truthy(vars.playable_state != 1))
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
        var isReady                             : Dynamic= true;
        
        var i                             : Dynamic= player_states.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var vars                             : Dynamic= as3hx.Compat.field(player_states, i);
            
            if (as3hx.Compat.truthy(vars.user != owner && !vars.ready_state))
            {
                isReady = false;
                break;
            }
            i--;
        }
        
        return isReady;
    }
    
    override public function canUserPlaySong(user                             : Dynamic) : Bool
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return false;
        }
        
        return playerVars.playable_state == 1;
    }
    
    public function isSongLoaded() : Bool
    {
        return song != null && song.isLoaded;
    }
    
    public function isPlayerLoaded(user                             : Dynamic) : Bool
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return false;
        }
        
        return playerVars.loading_state;
    }
    
    public function getPlayerLoadingProgress(user                             : Dynamic) : Float
    {
        var playerVars                             : Dynamic= player_state_map[user.uid];
        if (as3hx.Compat.truthy(playerVars == null))
        {
            return 0;
        }
        
        return playerVars.loading_percent;
    }
    
    private function _clearMissingPlayerData() : Void
    {
        var i                             : Dynamic= player_states.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var playerData                             : Dynamic= as3hx.Compat.field(player_states, i);
            
            if (as3hx.Compat.truthy(!isPlayer(playerData.user)))
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

