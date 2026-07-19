package classes.mp.mode.ffr;

import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.mp.MPSong;
import classes.mp.room.MPRoomFFR;
import com.flashfla.utils.TimeUtil;
import menu.FileLoader;

class MPMatchResultsFFR
{
    public var winnerText(get, never)                             : Dynamic;
    public var wasTie(get, never)                             : Dynamic;

    private static var _lang                             : Dynamic= Language.instance;
    
    public var room                             : Dynamic;
    
    public var index                             : Dynamic;
    public var teamMode                             : Dynamic= false;
    public var songData                             : Dynamic= new MPSong();
    public var songInfo                             : Dynamic= new SongInfo();
    public var teams                             : Dynamic= [];
    public var users                             : Dynamic= [];
    
    private var _winnerText                             : Dynamic;
    private var _wasTie                             : Dynamic= false;
    
    public function new(room                             : Dynamic, index                             : Dynamic)
    {
        this.room = room;
        this.index = index;
    }
    
    public function update(info                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(info.song != null))
        {
            songData.update(info.song);
            updateSongInfo();
        }
        
        if (as3hx.Compat.truthy(info.teamMode != null))
        {
            teamMode = info.teamMode;
        }
        
        if (as3hx.Compat.truthy(info.teams != null))
        {
            as3hx.Compat.setArrayLength(teams, 0);
            as3hx.Compat.setArrayLength(users, 0);
            
            for (mp_team/* AS3HX WARNING could not determine type for var: mp_team exp: EField(EIdent(info),teams) type: null */ in as3hx.Compat.iter(info.teams))
            {
                var team                             : Dynamic= new MPMatchResultsTeam();
                team.update(mp_team);
                teams.push(team);
                
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(mp_team),users) type: null */ in as3hx.Compat.iter(mp_team.users))
                {
                    var mpuser                             : Dynamic= new MPMatchResultsUser();
                    mpuser.update(user);
                    mpuser.team = team;
                    mpuser.index = users.length;
                    
                    mpuser.score.songInfo = songInfo;
                    
                    // User Personal Result instead of server score.
                    if (as3hx.Compat.truthy(room.lastMatchScorePersonal && room.lastMatchScorePersonal.compare(mpuser.score)))
                    {
                        mpuser.score = room.lastMatchScorePersonal;
                    }
                    
                    team.users.push(mpuser);
                    users.push(mpuser);
                }
            }
            
            _winnerText = _generateWinnerText();
        }
        
        if (as3hx.Compat.truthy(info.timestamp != null))
        {
            for (score_user in as3hx.Compat.iter(users))
            {
                score_user.score.end_time = TimeUtil.getFormattedDate(Date.fromTime(as3hx.Compat.parseFloat(info.timestamp)));
            }
        }
    }
    
    private function updateSongInfo() : Void
    {
        songInfo = null;
        
        if (as3hx.Compat.truthy(songData == null))
        {
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
                    return;
                }
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
                
                songInfo.time_end = 0;
                songInfo.time_secs = (as3hx.Compat.parseFloat(songInfo.time.split(":")[0]) * 60) + as3hx.Compat.parseFloat(songInfo.time.split(":")[1]);
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
            }
        }
        
        // Still no SongInfo, using songData backup.
        if (as3hx.Compat.truthy(songInfo == null))
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
            
            songInfo.time_end = 0;
            songInfo.time_secs = (as3hx.Compat.parseFloat(songInfo.time.split(":")[0]) * 60) + as3hx.Compat.parseFloat(songInfo.time.split(":")[1]);
        }
    }
    
    private function get_winnerText() : String
    {
        return _winnerText;
    }
    
    private function get_wasTie() : Bool
    {
        return _wasTie;
    }
    
    private function _generateWinnerText() : String
    {
        if (as3hx.Compat.truthy((teamMode && teams.length == 0) || (!teamMode && users.length == 0)))
        {
            return "Missingno????";
        }
        
        // Teams
        if (as3hx.Compat.truthy(teamMode))
        {
            var teamList                             : Dynamic= teams.filter(function(item                             : Dynamic, index                             : Dynamic, vec                             : Dynamic) : Bool
                    {
                        return item.position == 1;
                    });
            
            if (as3hx.Compat.truthy(teamList.length == teams.length && teams.length > 1))
            {
                _wasTie = true;
                return _lang.string("mp_match_result_tie_team");
            }
            
            return teamList.join(", ");
        }
        
        // Users
        var userList                             : Dynamic= users.filter(function(item                             : Dynamic, index                             : Dynamic, vec                             : Dynamic) : Bool
                {
                    return item.position == 1;
                });
        
        if (as3hx.Compat.truthy(userList.length == users.length && users.length > 1))
        {
            _wasTie = true;
            return _lang.string("mp_match_result_tie_user");
        }
        
        return userList.join(", ");
    }
}

