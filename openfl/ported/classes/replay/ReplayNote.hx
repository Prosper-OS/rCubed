package classes.replay;


class ReplayNote
{
    public var direction : String;
    public var frame : Float;
    public var time : Float;
    public var score : Float;
    
    public function new(direction : String, frame : Float = -1, time : Float = -1, score : Float = 0)
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
    public static function sortFunction(a : ReplayNote, b : ReplayNote) : Float
    {
        return a.frame - b.frame;
    }
}


