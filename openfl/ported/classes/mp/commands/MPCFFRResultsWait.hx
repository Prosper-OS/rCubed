package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRResultsWait implements IMPCommand
{
    public var room : MPRoomFFR;
    
    public function new(room : MPRoomFFR)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "results_wait",
                    d : {
                        uid : room.uid
                    }
                });
    }
}

