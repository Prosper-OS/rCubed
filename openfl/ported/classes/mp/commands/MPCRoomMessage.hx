package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomMessage implements IMPCommand
{
    public var room                             : Dynamic;
    public var message                             : Dynamic;
    public var type                             : Dynamic;
    
    public function new(room                             : Dynamic, message                             : Dynamic, type                             : Dynamic= 0)
    {
        this.room = room;
        this.message = message;
        this.type = type;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "message",
                    d : {
                        uid : room.uid,
                        message : message,
                        type : type
                    }
                });
    }
}

