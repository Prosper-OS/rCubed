package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomDelete implements IMPCommand
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
                    a : "delete",
                    d : {
                        uid : room.uid
                    }
                });
    }
}

