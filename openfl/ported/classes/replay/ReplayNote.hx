package classes.replay;


class ReplayNote
{
    public var direction                             : Dynamic;
    public var frame                             : Dynamic;
    public var time                             : Dynamic;
    public var score                             : Dynamic;
    
    public function new(direction                             : Dynamic, frame                             : Dynamic= -1, time                             : Dynamic= -1, score                             : Dynamic= 0)
    {
        this.direction = direction;
        this.frame = frame;
        this.time = time;
        this.score = score;
    }
    
    /**
     * Used to sort vector replay notes by frame number in ASC order.
     * Called in GamePlay after a level end to finalize the replay data.
     * @param a ReplayNote A
     * @param b ReplayNote B
     * @return Number
     */
    public static function sortFunction(a                             : Dynamic, b                             : Dynamic) : Float
    {
        return a.frame - b.frame;
    }
}


