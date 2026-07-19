package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongProgress implements IMPCommand
{
    public var room : MPRoomFFR;
    public var progress : Float;
    
    public function new(room : MPRoomFFR, progress : Float)
    {
        this.room = room;
        this.progress = progress;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "song_progress",
                    d : {
                        uid : room.uid,
                        progress : progress
                    }
                });
    }
}

