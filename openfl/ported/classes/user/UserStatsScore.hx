package classes.user;


class UserStatsScore
{
    public var pa_string(get, never) : String;
    public var score(get, never) : Float;

    public var level_id : Float;
    
    public var perfect : Float;
    public var good : Float;
    public var average : Float;
    public var miss : Float;
    public var boo : Float;
    public var combo : Float;
    
    public var weight : Float;
    
    public function new(data : Dynamic)
    {
        level_id = data.song;
        
        perfect = data.pa[0];
        good = data.pa[1];
        average = data.pa[2];
        miss = data.pa[3];
        boo = data.pa[4];
        combo = data.pa[5];
        
        weight = data.weight;
    }
    
    /**
     * Gets the PA string displayed in several places.
     * Example: 1653-1-0-0-0
     */
    private function get_pa_string() : String
    {
        return perfect + "-" + good + "-" + average + "-" + miss + "-" + boo;
    }
    
    private function get_score() : Float
    {
        return (((perfect) * 50) + (good * 25) + (average * 5) - (miss * 10) - (boo * 5));
    }
}

