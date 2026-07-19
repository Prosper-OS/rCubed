package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomEdit implements IMPCommand
{
    public var room : MPRoom;
    
    public var name : String;
    public var password : String;
    
    public var team_count : Float;
    public var max_players : Float;
    
    public function new(room : MPRoom)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        var data : Dynamic = {
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

