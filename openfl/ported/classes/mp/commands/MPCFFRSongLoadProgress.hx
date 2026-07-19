package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongLoadProgress implements IMPCommand
{
    public var room                             : Dynamic;
    public var progress                             : Dynamic;
    public var isLoaded                             : Dynamic;
    
    public function new(room                             : Dynamic, progress                             : Dynamic, isLoaded                             : Dynamic)
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

