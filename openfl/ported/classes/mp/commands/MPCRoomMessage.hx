package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomMessage implements IMPCommand
{
    public var room : MPRoom;
    public var message : String;
    public var type : Float;
    
    public function new(room : MPRoom, message : String, type : Float = 0)
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

