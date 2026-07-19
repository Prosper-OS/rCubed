package classes.mp.commands;

import classes.mp.MPTeam;
import classes.mp.room.MPRoom;

class MPCRoomTeamChange implements IMPCommand
{
    public var room                             : Dynamic;
    public var team                             : Dynamic;
    
    public function new(room                             : Dynamic, team                             : Dynamic)
    {
        this.room = room;
        this.team = team;
    }
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            uid : room.uid,
            team : team.uid
        };
        
        return haxe.Json.stringify({
                    t : "room",
                    a : "team",
                    d : data
                });
    }
}

