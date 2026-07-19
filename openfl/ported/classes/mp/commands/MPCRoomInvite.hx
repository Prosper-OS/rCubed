package classes.mp.commands;

import classes.mp.MPUser;
import classes.mp.room.MPRoom;

class MPCRoomInvite implements IMPCommand
{
    public var user                             : Dynamic;
    public var room                             : Dynamic;
    
    public function new(user                             : Dynamic, room                             : Dynamic)
    {
        this.user = user;
        this.room = room;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "user",
                    a : "room_invite",
                    d : {
                        uid : user.uid,
                        sid : user.sid,
                        name : room.name,
                        code : room.joinCode
                    }
                });
    }
}

