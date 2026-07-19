package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCFFRScoreUpdate implements IMPCommand
{
    public var room                             : Dynamic;
    
    public var raw_score                             : Dynamic;
    public var amazing                             : Dynamic;
    public var perfect                             : Dynamic;
    public var good                             : Dynamic;
    public var average                             : Dynamic;
    public var miss                             : Dynamic;
    public var boo                             : Dynamic;
    public var combo                             : Dynamic;
    public var max_combo                             : Dynamic;
    
    public function new(room                             : Dynamic, raw_score                             : Dynamic, amazing                             : Dynamic, perfect                             : Dynamic, good                             : Dynamic, average                             : Dynamic, miss                             : Dynamic, boo                             : Dynamic, combo                             : Dynamic, max_combo                             : Dynamic)
    {
        this.room = room;
        
        this.raw_score = raw_score;
        this.amazing = amazing;
        this.perfect = perfect;
        this.good = good;
        this.average = average;
        this.miss = miss;
        this.boo = boo;
        this.combo = combo;
        this.max_combo = max_combo;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "mode",
                    a : "score_update",
                    d : {
                        uid : room.uid,
                        raw_score : raw_score,
                        amazing : amazing,
                        perfect : perfect,
                        good : good,
                        average : average,
                        miss : miss,
                        boo : boo,
                        combo : combo,
                        max_combo : max_combo
                    }
                });
    }
}

