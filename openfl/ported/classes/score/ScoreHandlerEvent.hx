package classes.score;

import openfl.events.Event;
import game.GameScoreResult;

class ScoreHandlerEvent extends Event
{
    public static inline var SUCCESS                             : Dynamic= "success";
    public static inline var FAILURE                             : Dynamic= "failure";
    
    public var result                             : Dynamic;
    public var rank                             : Dynamic;
    public var last_best                             : Dynamic;
    public var hash                             : Dynamic;
    
    public function new(type                             : Dynamic, result                             : Dynamic, rank                             : Dynamic, best                             : Dynamic, hash                             : Dynamic= "")
    {
        super(type, false, false);
        this.result = result;
        this.rank = rank;
        this.last_best = best;
        this.hash = hash;
    }
}

