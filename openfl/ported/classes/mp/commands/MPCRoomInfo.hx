package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomInfo implements IMPCommand
{
    public var room                             : Dynamic;
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "info",
                    d : {
                        uid : room.uid
                    }
                });
    }
}

