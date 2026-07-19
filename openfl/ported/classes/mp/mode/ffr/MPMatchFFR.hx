package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;
import openfl.utils.Dictionary;

class MPMatchFFR
{
    public var room                             : Dynamic;
    
    public var teams                             : Dynamic= [];
    public var teams_map                             : Dynamic= new Dictionary<Dynamic, Dynamic>(true);
    
    public var users                             : Dynamic= [];
    public var users_map                             : Dynamic= new Dictionary<Dynamic, Dynamic>(true);
    
    public var startTime                             : Dynamic;
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function build(data                             : Dynamic) : Void
    {
        var s_users                             : Dynamic= data.users;
        var s_teams                             : Dynamic= data.teams;
        
        for (t in 0...s_teams.length)
        {
            var teamData                             : Dynamic= s_teams[t];
            
            var matchTeam                             : Dynamic= new MPMatchFFRTeam();
            matchTeam.update(teamData);
            teams.push(matchTeam);
            teams_map[matchTeam.id] = matchTeam;
            
            var scores                             : Dynamic= teamData.scores;
            for (s in 0...scores.length)
            {
                var scoreData                             : Dynamic= scores[s];
                var scoreUser                             : Dynamic= room.getUser(scoreData.uid);
                
                if (as3hx.Compat.truthy(scoreUser == null))
                {
                    scoreUser = new MPUser();
                    if (as3hx.Compat.truthy(as3hx.Compat.field(s_users, scoreUser.uid) != null))
                    {
                        scoreUser.update(as3hx.Compat.field(s_users, scoreUser.uid));
                    }
                    else
                    {
                        scoreUser.update({
                                    uid : scoreData.uid,
                                    name : "UID " + scoreData.uid
                                });
                    }
                }
                
                var matchUser                             : Dynamic= new MPMatchFFRUser(room, scoreUser);
                matchUser.update(scoreData);
                matchUser.rate = room.getPlayerSongRate(scoreUser);
                
                users.push(matchUser);
                users_map[scoreUser.uid] = matchUser;
                
                matchTeam.users.push(matchUser);
            }
        }
        
        startTime = Math.round(haxe.Timer.stamp() * 1000);
    }
    
    public function update(data                             : Dynamic) : Void
    // Not Built
    {
        
        if (as3hx.Compat.truthy(teams.length == 0))
        {
            return;
        }
        
        var s_teams                             : Dynamic= data.teams;
        
        for (t in 0...s_teams.length)
        {
            var teamData                             : Dynamic= s_teams[t];
            var matchTeam                             : Dynamic= teams_map[teamData.id];
            matchTeam.update(teamData);
            
            var scores                             : Dynamic= teamData.scores;
            for (s in 0...scores.length)
            {
                var scoreData                             : Dynamic= scores[s];
                var matchUser                             : Dynamic= users_map[scoreData.uid];
                matchUser.update(scoreData);
            }
        }
    }
}

