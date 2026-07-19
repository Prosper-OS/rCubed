package classes.mp.mode.ffr;


class MPMatchResultsTeam
{
    public var uid : Int;
    public var name : String;
    public var raw_score : Float;
    public var position : Int;
    public var users : Array<MPMatchResultsUser> = [];
    
    public function update(data : Dynamic) : Void
    {
        if (data.id != null)
        {
            this.uid = data.id;
        }
        
        if (data.name != null)
        {
            this.name = data.name;
        }
        
        if (data.raw_score != null)
        {
            this.raw_score = data.raw_score;
        }
        
        if (data.position != null)
        {
            this.position = data.position;
        }
    }
    
    public function toString() : String
    {
        return name;
    }

    public function new()
    {
    }
}

