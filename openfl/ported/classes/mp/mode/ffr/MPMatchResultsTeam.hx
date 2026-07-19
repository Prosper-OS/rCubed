package classes.mp.mode.ffr;


class MPMatchResultsTeam
{
    public var uid                             : Dynamic;
    public var name                             : Dynamic;
    public var raw_score                             : Dynamic;
    public var position                             : Dynamic;
    public var users                             : Dynamic= [];
    
    public function update(data                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(data.id != null))
        {
            this.uid = data.id;
        }
        
        if (as3hx.Compat.truthy(data.name != null))
        {
            this.name = data.name;
        }
        
        if (as3hx.Compat.truthy(data.raw_score != null))
        {
            this.raw_score = data.raw_score;
        }
        
        if (as3hx.Compat.truthy(data.position != null))
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

