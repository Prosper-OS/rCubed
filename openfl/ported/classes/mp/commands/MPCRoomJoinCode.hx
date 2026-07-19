package classes.mp.commands;


class MPCRoomJoinCode implements IMPCommand
{
    public var code : String;
    
    public function new(code : String)
    {
        this.code = code;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "room",
                    a : "join_code",
                    d : code
                });
    }
}

