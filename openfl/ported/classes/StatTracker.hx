package classes;


class StatTracker
{
    public var data(get, never) : Dynamic;

    public var raw_score : Float = 0;
    public var grandtotal : Float = 0;
    public var restarts : Float = 0;
    public var amazing : Float = 0;
    public var perfect : Float = 0;
    public var good : Float = 0;
    public var average : Float = 0;
    public var miss : Float = 0;
    public var boo : Float = 0;
    public var credits : Float = 0;
    
    private function get_data() : Dynamic
    {
        return {
            raw_score : raw_score,
            grandtotal : grandtotal,
            restarts : restarts,
            amazing : amazing,
            perfect : perfect,
            good : good,
            average : average,
            miss : miss,
            boo : boo,
            credits : credits
        };
    }
    
    public function reset() : Void
    {
        raw_score = 0;
        grandtotal = 0;
        restarts = 0;
        amazing = 0;
        perfect = 0;
        good = 0;
        average = 0;
        miss = 0;
        boo = 0;
        credits = 0;
    }
    
    public function addFromStats(stats : StatTracker) : Void
    {
        raw_score += stats.raw_score;
        grandtotal += stats.grandtotal;
        restarts += stats.restarts;
        amazing += stats.amazing;
        perfect += stats.perfect;
        good += stats.good;
        average += stats.average;
        miss += stats.miss;
        boo += stats.boo;
        credits += stats.credits;
    }

    public function new()
    {
    }
}


