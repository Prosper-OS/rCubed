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
    public var winnerText(get, never) : String;
    public var wasTie(get, never) : Bool;

    private static var _lang : Language = Language.instance;
    
    public var room : MPRoomFFR;
    
    public var index : Int;
    public var teamMode : Bool = false;
    public var songData : MPSong = new MPSong();
    public var songInfo : SongInfo = new SongInfo();
    public var teams : Array<MPMatchResultsTeam> = [];
    public var users : Array<MPMatchResultsUser> = [];
    
    private var _winnerText : String;
    private var _wasTie : Bool = false;
    
    public function new(room : MPRoomFFR, index : Int)
    {
        this.room = room;
        this.index = index;
    }
    
    public function update(info : Dynamic) : Void
    {
        if (info.song != null)
        {
            songData.update(info.song);
            updateSongInfo();
        }
        
        if (info.teamMode != null)
        {
            teamMode = info.teamMode;
        }
        
        if (info.teams != null)
        {
            as3hx.Compat.setArrayLength(teams, 0);
            as3hx.Compat.setArrayLength(users, 0);
            
            for (mp_team/* AS3HX WARNING could not determine type for var: mp_team exp: EField(EIdent(info),teams) type: null */ in info.teams)
            {
                var team : MPMatchResultsTeam = new MPMatchResultsTeam();
                team.update(mp_team);
                teams.push(team);
                
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(mp_team),users) type: null */ in mp_team.users)
                {
                    var mpuser : MPMatchResultsUser = new MPMatchResultsUser();
                    mpuser.update(user);
                    mpuser.team = team;
                    mpuser.index = users.length;
                    
                    mpuser.score.songInfo = songInfo;
                    
                    // User Personal Result instead of server score.
                    if (room.lastMatchScorePersonal && room.lastMatchScorePersonal.compare(mpuser.score))
                    {
                        mpuser.score = room.lastMatchScorePersonal;
                    }
                    
                    team.users.push(mpuser);
                    users.push(mpuser);
                }
            }
            
            _winnerText = _generateWinnerText();
        }
        
        if (info.timestamp != null)
        {
            for (score_user in users)
            {
                score_user.score.end_time = TimeUtil.getFormattedDate(new Date(info.timestamp));
            }
        }
    }
    
    private function updateSongInfo() : Void
    {
        songInfo = null;
        
        if (songData == null)
        {
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
                var ffrSongsMatch : Array<SongInfo> = Playlist.instanceCanon.indexList.filter(function(item : SongInfo, index : Int, vec : Array<SongInfo>) : Bool
                        {
                            return item.level == songData.id;
                        });
                
                if (ffrSongsMatch.length == 1)
                {
                    songInfo = ffrSongsMatch[0];
                }
            }
        }
        
        // Still no SongInfo, using songData backup.
        if (songInfo == null)
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
        if ((teamMode && teams.length == 0) || (!teamMode && users.length == 0))
        {
            return "Missingno????";
        }
        
        // Teams
        if (teamMode)
        {
            var teamList : Array<MPMatchResultsTeam> = teams.filter(function(item : MPMatchResultsTeam, index : Int, vec : Array<MPMatchResultsTeam>) : Bool
                    {
                        return item.position == 1;
                    });
            
            if (teamList.length == teams.length && teams.length > 1)
            {
                _wasTie = true;
                return _lang.string("mp_match_result_tie_team");
            }
            
            return teamList.join(", ");
        }
        
        // Users
        var userList : Array<MPMatchResultsUser> = users.filter(function(item : MPMatchResultsUser, index : Int, vec : Array<MPMatchResultsUser>) : Bool
                {
                    return item.position == 1;
                });
        
        if (userList.length == users.length && users.length > 1)
        {
            _wasTie = true;
            return _lang.string("mp_match_result_tie_user");
        }
        
        return userList.join(", ");
    }
}

