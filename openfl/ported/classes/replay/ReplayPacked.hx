package classes.replay;

import openfl.utils.ByteArray;

class ReplayPacked
{
    public var VERSION(get, never)                             : Dynamic;

    public var MAGIC                             : Dynamic;
    public var MAJOR_VER                             : Dynamic;
    public var MINOR_VER                             : Dynamic;
    public var user_id                             : Dynamic;
    public var song_id                             : Dynamic;
    public var song_rate                             : Dynamic;
    public var timestamp                             : Dynamic;
    public var judgements                             : Dynamic;
    public var raw_judgements                             : Dynamic;
    public var settings                             : Dynamic;
    public var raw_settings                             : Dynamic;
    public var rep_notes                             : Dynamic;
    public var rep_boos                             : Dynamic;
    public var checksum                             : Dynamic;
    public var rechecksum                             : Dynamic;
    public var replay_bin                             : Dynamic;
    
    public var error                             : Dynamic;
    
    private function get_VERSION() : Int
    {
        return as3hx.Compat.parseInt(MAJOR_VER * 1000 + MINOR_VER);
    }
    
    public function update() : Void
    {
        var i                             : Dynamic= null;
        
        // 1.0 -> 1.1:
        // Judge ms Inversion
        if (as3hx.Compat.truthy(MAJOR_VER == 1 && MINOR_VER == 0))
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

