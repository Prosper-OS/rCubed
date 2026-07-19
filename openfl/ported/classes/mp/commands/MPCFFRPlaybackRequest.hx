
package classes.mp.commands;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPCFFRPlaybackRequest implements IMPCommand
{
    public var room                             : Dynamic;
    public var user                             : Dynamic;
    public var index                             : Dynamic;
    
    public function new(room                             : Dynamic, user                             : Dynamic, index                             : Dynamic)
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

