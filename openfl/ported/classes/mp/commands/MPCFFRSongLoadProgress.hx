package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongLoadProgress implements IMPCommand
{
    public var room : MPRoomFFR;
    public var progress : Int;
    public var isLoaded : Bool;
    
    public function new(room : MPRoomFFR, progress : Int, isLoaded : Bool)
    {
        this.room = room;
        this.progress = progress;
        this.isLoaded = isLoaded;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "loading",
                    d : {
                        uid : room.uid,
                        progress : progress,
                        complete : isLoaded
                    }
                });
    }
}

