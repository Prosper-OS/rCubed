package classes.mp.commands;

import classes.mp.MPUser;
import classes.mp.room.MPRoom;

class MPCRoomUserOwner implements IMPCommand
{
    public var room : MPRoom;
    public var user : MPUser;
    
    public function new(room : MPRoom, user : MPUser)
    {
        this.room = room;
        this.user = user;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "user_owner",
                    d : {
                        uid : room.uid,
                        userUID : user.uid
                    }
                });
    }
}

