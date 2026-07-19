package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomJoin implements IMPCommand
{
    public var room                             : Dynamic;
    public var password                             : Dynamic;
    
    public function new(room                             : Dynamic, password                             : Dynamic= null)
    {
        this.room = room;
        this.password = password;
    }
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            uid : room.uid
        };
        
        if (as3hx.Compat.truthy(password != null && password.length > 0))
        {
            Reflect.setField(data, "password", password);
        }
        
        return haxe.Json.stringify({
                    t : "room",
                    a : "join",
                    d : data
                });
    }
}

