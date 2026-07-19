package classes.mp.commands;


class MPCRoomCreate implements IMPCommand
{
    public var name : String;
    public var password : String;
    public var type : String;
    
    public var max_players : Float;
    public var team_count : Float;
    
    public function toJSON() : String
    {
        var data : Dynamic = {
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

