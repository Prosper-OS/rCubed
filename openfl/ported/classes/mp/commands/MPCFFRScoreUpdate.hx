package classes.mp.commands;

import classes.mp.room.MPRoom;

class MPCFFRScoreUpdate implements IMPCommand
{
    public var room : MPRoom;
    
    public var raw_score : Int;
    public var amazing : Int;
    public var perfect : Int;
    public var good : Int;
    public var average : Int;
    public var miss : Int;
    public var boo : Int;
    public var combo : Int;
    public var max_combo : Int;
    
    public function new(room : MPRoom, raw_score : Int, amazing : Int, perfect : Int, good : Int, average : Int, miss : Int, boo : Int, combo : Int, max_combo : Int)
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

