package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRReady implements IMPCommand
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
                    a : "ready",
                    d : {
                        uid : room.uid
                    }
                });
    }
}

