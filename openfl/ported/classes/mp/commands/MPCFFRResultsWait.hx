package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRResultsWait implements IMPCommand
{
    public var room                             : Dynamic;
    
    public function new(room                             : Dynamic)
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

