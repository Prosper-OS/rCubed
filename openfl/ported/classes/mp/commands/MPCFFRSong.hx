package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSong implements IMPCommand
{
    public var room                             : Dynamic;
    
    public var type                             : Dynamic;
    public var id                             : Dynamic;
    public var level_id                             : Dynamic;
    
    public var name                             : Dynamic;
    public var author                             : Dynamic;
    public var time                             : Dynamic;
    public var note_count                             : Dynamic;
    public var difficulty                             : Dynamic;
    
    public var engine                             : Dynamic;
    
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            uid : room.uid,
            type : type,
            id : id,
            level_id : level_id,
            name : name,
            author : author,
            time : time,
            note_count : note_count,
            difficulty : difficulty,
            engine : engine
        };
        
        return haxe.Json.stringify({
                    t : "mode",
                    a : "song",
                    d : data
                });
    }
}

