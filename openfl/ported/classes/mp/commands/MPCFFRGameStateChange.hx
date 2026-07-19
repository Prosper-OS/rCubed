package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRGameStateChange implements IMPCommand
{
    public var room : MPRoomFFR;
    public var state : String;
    
    public function new(room : MPRoomFFR, state : String)
    {
        this.room = room;
        this.state = state;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "game_state",
                    d : {
                        uid : room.uid,
                        state : state
                    }
                });
    }
}

