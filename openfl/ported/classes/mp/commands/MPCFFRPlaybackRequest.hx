
package classes.mp.commands;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPCFFRPlaybackRequest implements IMPCommand
{
    public var room : MPRoomFFR;
    public var user : MPUser;
    public var index : Int;
    
    public function new(room : MPRoomFFR, user : MPUser, index : Int)
    {
        this.room = room;
        this.user = user;
        this.index = index;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "playback_request",
                    d : {
                        uid : room.uid,
                        userUID : user.uid,
                        index : index
                    }
                });
    }
}

