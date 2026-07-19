package classes.mp.commands;


class MPCRoomJoinCode implements IMPCommand
{
    public var code                             : Dynamic;
    
    public function new(code                             : Dynamic)
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

