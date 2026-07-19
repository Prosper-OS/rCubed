package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRSongStart implements IMPCommand
{
    public var room : MPRoomFFR;
    public var settings : Dynamic;
    public var layout : Dynamic;
    public var noteskin : String;
    
    public function new(room : MPRoomFFR, settings : Dynamic, layout : Dynamic, noteskin : String)
    {
        this.room = room;
        this.settings = settings;
        this.layout = layout;
        this.noteskin = noteskin;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "song_start",
                    d : {
                        uid : room.uid,
                        settings : settings,
                        layout : layout,
                        noteskin : noteskin
                    }
                });
    }
}

