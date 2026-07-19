package classes.mp.commands;

import classes.mp.MPUser;

class MPCModBanUser implements IMPCommand
{
    public var user                             : Dynamic;
    public var duration                             : Dynamic;
    
    public function new(user                             : Dynamic, duration                             : Dynamic)
    {
        this.user = user;
        this.duration = duration;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "user",
                    a : "mod_ban",
                    d : {
                        uid : user.uid,
                        sid : user.sid,
                        duration : duration
                    }
                });
    }
}

