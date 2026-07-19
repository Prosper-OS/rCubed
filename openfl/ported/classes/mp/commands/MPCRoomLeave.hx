package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomLeave implements IMPCommand
{
    public var room : MPRoom;
    
    public function new(room : MPRoom)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "leave",
                    d : {
                        uid : room.uid
                    }
                });
    }
}

