package classes.mp.commands;

import classes.mp.MPUser;
import classes.mp.room.MPRoom;

class MPCRoomUserBlock implements IMPCommand
{
    public var room                             : Dynamic;
    public var user                             : Dynamic;
    public var duration                             : Dynamic;
    
    public function new(room                             : Dynamic, user                             : Dynamic, duration                             : Dynamic)
    {
        this.room = room;
        this.user = user;
        this.duration = duration;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "user_block",
                    d : {
                        uid : room.uid,
                        userUID : user.uid,
                        userSID : user.sid,
                        duration : duration
                    }
                });
    }
}

