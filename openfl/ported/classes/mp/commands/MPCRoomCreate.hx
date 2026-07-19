package classes.mp.commands;


class MPCRoomCreate implements IMPCommand
{
    public var name                             : Dynamic;
    public var password                             : Dynamic;
    public var type                             : Dynamic;
    
    public var max_players                             : Dynamic;
    public var team_count                             : Dynamic;
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            type : type,
            name : name,
            password : password,
            team_count : team_count,
            max_players : max_players
        };
        
        return haxe.Json.stringify({
                    t : "room",
                    a : "create",
                    d : data
                });
    }

    public function new()
    {
    }
}

