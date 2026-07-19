package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongPlayable implements IMPCommand
{
    public var room                             : Dynamic;
    public var canPlay                             : Dynamic;
    
    public var id                             : Dynamic;
    public var level_id                             : Dynamic;
    public var engine                             : Dynamic;
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "song_playable",
                    d : {
                        uid : room.uid,
                        playable : canPlay,
                        id : id,
                        level_id : level_id,
                        engine : engine
                    }
                });
    }
}

