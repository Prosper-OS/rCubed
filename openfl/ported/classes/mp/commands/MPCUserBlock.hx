package classes.mp.commands;

import classes.mp.MPUser;

class MPCUserBlock implements IMPCommand
{
    public var user                             : Dynamic;
    public var message                             : Dynamic;
    public var type                             : Dynamic;
    
    public function new(user                             : Dynamic)
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

