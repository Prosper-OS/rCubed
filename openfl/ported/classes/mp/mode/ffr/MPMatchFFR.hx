package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;
import openfl.utils.Dictionary;

class MPMatchFFR
{
    public var room : MPRoomFFR;
    
    public var teams : Array<MPMatchFFRTeam> = [];
    public var teams_map : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
    
    public var users : Array<MPMatchFFRUser> = [];
    public var users_map : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
    
    public var startTime : Float;
    
    public function new(room : MPRoomFFR)
    {
        this.room = room;
    }
    
    public function build(data : Dynamic) : Void
    {
        var s_users : Dynamic = data.users;
        var s_teams : Array<Dynamic> = data.teams;
        
        for (t in 0...s_teams.length)
        {
            var teamData : Dynamic = s_teams[t];
            
            var matchTeam : MPMatchFFRTeam = new MPMatchFFRTeam();
            matchTeam.update(teamData);
            teams.push(matchTeam);
            teams_map[matchTeam.id] = matchTeam;
            
            var scores : Array<Dynamic> = teamData.scores;
            for (s in 0...scores.length)
            {
                var scoreData : Dynamic = scores[s];
                var scoreUser : MPUser = room.getUser(scoreData.uid);
                
                if (scoreUser == null)
                {
                    scoreUser = new MPUser();
                    if (Reflect.field(s_users, Std.string(scoreUser.uid)) != null)
                    {
                        scoreUser.update(Reflect.field(s_users, Std.string(scoreUser.uid)));
                    }
                    else
                    {
                        scoreUser.update({
                                    uid : scoreData.uid,
                                    name : "UID " + scoreData.uid
                                });
                    }
                }
                
                var matchUser : MPMatchFFRUser = new MPMatchFFRUser(room, scoreUser);
                matchUser.update(scoreData);
                matchUser.rate = room.getPlayerSongRate(scoreUser);
                
                users.push(matchUser);
                users_map[scoreUser.uid] = matchUser;
                
                matchTeam.users.push(matchUser);
            }
        }
        
        startTime = Math.round(haxe.Timer.stamp() * 1000);
    }
    
    public function update(data : Dynamic) : Void
    // Not Built
    {
        
        if (teams.length == 0)
        {
            return;
        }
        
        var s_teams : Array<Dynamic> = data.teams;
        
        for (t in 0...s_teams.length)
        {
            var teamData : Dynamic = s_teams[t];
            var matchTeam : MPMatchFFRTeam = teams_map[teamData.id];
            matchTeam.update(teamData);
            
            var scores : Array<Dynamic> = teamData.scores;
            for (s in 0...scores.length)
            {
                var scoreData : Dynamic = scores[s];
                var matchUser : MPMatchFFRUser = users_map[scoreData.uid];
                matchUser.update(scoreData);
            }
        }
    }
}

