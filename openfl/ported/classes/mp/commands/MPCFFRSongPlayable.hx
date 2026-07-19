package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongPlayable implements IMPCommand
{
    public var room : MPRoomFFR;
    public var canPlay : Bool;
    
    public var id : Int;
    public var level_id : String;
    public var engine : Dynamic;
    
    public function new(room : MPRoomFFR)
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

