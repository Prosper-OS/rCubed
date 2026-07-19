package classes.mp.mode.ffr;


class MPMatchFFRTeam
{
    public var users                             : Dynamic= [];
    
    public var id                             : Dynamic= 0;
    public var position                             : Dynamic= 1;
    public var raw_score                             : Dynamic= 0;
    
    public function update(data                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(data.id != null))
        {
            id = data.id;
        }
        
        if (as3hx.Compat.truthy(data.position != null))
        {
            position = data.position;
        }
        
        if (as3hx.Compat.truthy(data.raw_score != null))
        {
            raw_score = data.raw_score;
        }
    }

    public function new()
    {
    }
}

