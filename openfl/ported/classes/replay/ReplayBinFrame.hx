package classes.replay;


class ReplayBinFrame
{
    public var time                             : Dynamic;
    public var direction                             : Dynamic;
    public var index                             : Dynamic;
    
    public function new(time                             : Dynamic, dir                             : Dynamic= "", index                             : Dynamic= 0)
    {
        this.time = time;
        this.direction = dir;
        this.index = index;
    }
}


