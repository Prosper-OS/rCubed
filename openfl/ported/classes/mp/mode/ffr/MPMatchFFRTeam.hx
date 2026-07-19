package classes.mp.mode.ffr;


class MPMatchFFRTeam
{
    public var users : Array<MPMatchFFRUser> = [];
    
    public var id : Int = 0;
    public var position : Int = 1;
    public var raw_score : Float = 0;
    
    public function update(data : Dynamic) : Void
    {
        if (data.id != null)
        {
            id = data.id;
        }
        
        if (data.position != null)
        {
            position = data.position;
        }
        
        if (data.raw_score != null)
        {
            raw_score = data.raw_score;
        }
    }

    public function new()
    {
    }
}

