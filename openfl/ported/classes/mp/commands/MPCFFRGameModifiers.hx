package classes.mp.commands;

import classes.mp.room.MPRoomFFR;

class MPCFFRGameModifiers implements IMPCommand
{
    public var room : MPRoomFFR;
    public var mods : Dynamic;
    
    public function new(room : MPRoomFFR, mods : Dynamic)
    {
        this.room = room;
        this.mods = mods;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "game_mods",
                    d : {
                        uid : room.uid,
                        mods : mods
                    }
                });
    }
}

