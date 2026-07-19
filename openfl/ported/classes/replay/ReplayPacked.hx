package classes.replay;

import openfl.utils.ByteArray;

class ReplayPacked
{
    public var VERSION(get, never) : Int;

    public var MAGIC : String;
    public var MAJOR_VER : Int;
    public var MINOR_VER : Int;
    public var user_id : Int;
    public var song_id : Int;
    public var song_rate : Float;
    public var timestamp : Int;
    public var judgements : Dynamic;
    public var raw_judgements : String;
    public var settings : Dynamic;
    public var raw_settings : String;
    public var rep_notes : Array<ReplayBinFrame>;
    public var rep_boos : Array<ReplayBinFrame>;
    public var checksum : Int;
    public var rechecksum : Int;
    public var replay_bin : ByteArray;
    
    public var error : String;
    
    private function get_VERSION() : Int
    {
        return as3hx.Compat.parseInt(MAJOR_VER * 1000 + MINOR_VER);
    }
    
    public function update() : Void
    {
        var i : Int;
        
        // 1.0 -> 1.1:
        // Judge ms Inversion
        if (MAJOR_VER == 1 && MINOR_VER == 0)
        {
            for (i in 0...rep_notes.length)
            {
                rep_notes[i].time = rep_notes[i].time * -1;
            }
            
            MAJOR_VER = 1;
            MINOR_VER = 1;
        }
    }

    public function new()
    {
    }
}

