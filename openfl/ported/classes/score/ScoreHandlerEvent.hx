package classes.score;

import openfl.events.Event;
import game.GameScoreResult;

class ScoreHandlerEvent extends Event
{
    public static inline var SUCCESS : String = "success";
    public static inline var FAILURE : String = "failure";
    
    public var result : GameScoreResult;
    public var rank : String;
    public var last_best : String;
    public var hash : String;
    
    public function new(type : String, result : GameScoreResult, rank : String, best : String, hash : String = "")
    {
        super(type, false, false);
        this.result = result;
        this.rank = rank;
        this.last_best = best;
        this.hash = hash;
    }
}

