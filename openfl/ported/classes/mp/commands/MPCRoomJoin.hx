package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCRoomJoin implements IMPCommand
{
    public var room : MPRoom;
    public var password : String;
    
    public function new(room : MPRoom, password : String = null)
    {
        this.room = room;
        this.password = password;
    }
    
    public function toJSON() : String
    {
        var data : Dynamic = {
            uid : room.uid
        };
        
        if (password != null && password.length > 0)
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

