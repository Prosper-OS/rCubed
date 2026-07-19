package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPMatchFFRUser
{
    public var user                             : Dynamic;
    public var room                             : Dynamic;
    
    public var alive                             : Dynamic= true;
    public var playing                             : Dynamic= false;
    public var rate                             : Dynamic= 1;
    
    public var raw_score                             : Dynamic= 0;
    public var position                             : Dynamic= 1;
    
    public var amazing                             : Dynamic= 0;
    public var perfect                             : Dynamic= 0;
    public var good                             : Dynamic= 0;
    public var average                             : Dynamic= 0;
    public var miss                             : Dynamic= 0;
    public var boo                             : Dynamic= 0;
    public var max_combo                             : Dynamic= 0;
    
    public function new(room                             : Dynamic, user                             : Dynamic)
    {
        this.room = room;
        this.user = user;
    }
    
    public function update(data                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(data.raw_score != null))
        {
            this.raw_score = data.raw_score;
        }
        
        if (as3hx.Compat.truthy(data.position != null))
        {
            this.position = data.position;
        }
        
        if (as3hx.Compat.truthy(data.alive != null))
        {
            this.alive = data.alive;
        }
        
        if (as3hx.Compat.truthy(data.playing != null))
        {
            this.playing = data.playing;
        }
        
        if (as3hx.Compat.truthy(data.amazing != null))
        {
            this.amazing = data.amazing;
        }
        
        if (as3hx.Compat.truthy(data.perfect != null))
        {
            this.perfect = data.perfect;
        }
        
        if (as3hx.Compat.truthy(data.good != null))
        {
            this.good = data.good;
        }
        
        if (as3hx.Compat.truthy(data.average != null))
        {
            this.average = data.average;
        }
        
        if (as3hx.Compat.truthy(data.miss != null))
        {
            this.miss = data.miss;
        }
        
        if (as3hx.Compat.truthy(data.boo != null))
        {
            this.boo = data.boo;
        }
        
        if (as3hx.Compat.truthy(data.max_combo != null))
        {
            this.max_combo = data.max_combo;
        }
    }
}

