package classes.replay;


class ReplayBinFrame
{
    public var time : Float;
    public var direction : String;
    public var index : Int;
    
    public function new(time : Float, dir : String = "", index : Int = 0)
    {
        this.time = time;
        this.direction = dir;
        this.index = index;
    }
}


