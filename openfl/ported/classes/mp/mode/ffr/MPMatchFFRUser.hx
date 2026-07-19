package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPMatchFFRUser
{
    public var user : MPUser;
    public var room : MPRoomFFR;
    
    public var alive : Bool = true;
    public var playing : Bool = false;
    public var rate : Float = 1;
    
    public var raw_score : Float = 0;
    public var position : Float = 1;
    
    public var amazing : Float = 0;
    public var perfect : Float = 0;
    public var good : Float = 0;
    public var average : Float = 0;
    public var miss : Float = 0;
    public var boo : Float = 0;
    public var max_combo : Float = 0;
    
    public function new(room : MPRoomFFR, user : MPUser)
    {
        this.room = room;
        this.user = user;
    }
    
    public function update(data : Dynamic) : Void
    {
        if (data.raw_score != null)
        {
            this.raw_score = data.raw_score;
        }
        
        if (data.position != null)
        {
            this.position = data.position;
        }
        
        if (data.alive != null)
        {
            this.alive = data.alive;
        }
        
        if (data.playing != null)
        {
            this.playing = data.playing;
        }
        
        if (data.amazing != null)
        {
            this.amazing = data.amazing;
        }
        
        if (data.perfect != null)
        {
            this.perfect = data.perfect;
        }
        
        if (data.good != null)
        {
            this.good = data.good;
        }
        
        if (data.average != null)
        {
            this.average = data.average;
        }
        
        if (data.miss != null)
        {
            this.miss = data.miss;
        }
        
        if (data.boo != null)
        {
            this.boo = data.boo;
        }
        
        if (data.max_combo != null)
        {
            this.max_combo = data.max_combo;
        }
    }
}

