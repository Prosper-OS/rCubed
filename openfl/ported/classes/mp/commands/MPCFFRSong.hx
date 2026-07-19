package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSong implements IMPCommand
{
    public var room : MPRoomFFR;
    
    public var type : String;
    public var id : Int;
    public var level_id : String;
    
    public var name : String;
    public var author : String;
    public var time : String;
    public var note_count : Float;
    public var difficulty : Float;
    
    public var engine : Dynamic;
    
    
    public function new(room : MPRoomFFR)
    {
        this.room = room;
    }
    
    public function toJSON() : String
    {
        var data : Dynamic = {
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

