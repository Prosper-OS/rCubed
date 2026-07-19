package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomEdit implements IMPCommand
{
    public var room                             : Dynamic;
    
    public var name                             : Dynamic;
    public var password                             : Dynamic;
    
    public var team_count                             : Dynamic;
    public var max_players                             : Dynamic;
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            uid : room.uid,
            name : name,
            password : password,
            team_count : team_count,
            max_players : max_players
        };
        
        return haxe.Json.stringify({
                    t : "room",
                    a : "edit",
                    d : data
                });
    }
}

