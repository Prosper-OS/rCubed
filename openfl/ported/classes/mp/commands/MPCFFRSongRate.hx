package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongRate implements IMPCommand
{
    public var room                             : Dynamic;
    public var rate                             : Dynamic;
    
    public function new(room                             : Dynamic, rate                             : Dynamic)
    {
        this.room = room;
        this.rate = rate;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "song_rate",
                    d : {
                        uid : room.uid,
                        rate : rate
                    }
                });
    }
}

