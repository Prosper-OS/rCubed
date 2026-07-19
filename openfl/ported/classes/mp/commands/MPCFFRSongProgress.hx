package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongProgress implements IMPCommand
{
    public var room                             : Dynamic;
    public var progress                             : Dynamic;
    
    public function new(room                             : Dynamic, progress                             : Dynamic)
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

