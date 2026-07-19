package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRGameStateChange implements IMPCommand
{
    public var room                             : Dynamic;
    public var state                             : Dynamic;
    
    public function new(room                             : Dynamic, state                             : Dynamic)
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

