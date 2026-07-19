package classes.mp.commands;

import classes.mp.MPUser;

class MPCUserBlock implements IMPCommand
{
    public var user : MPUser;
    public var message : String;
    public var type : Float;
    
    public function new(user : MPUser)
    {
        this.user = user;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "user",
                    a : "block",
                    d : {
                        uid : user.uid,
                        sid : user.sid
                    }
                });
    }
}

