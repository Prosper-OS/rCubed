package classes.mp.commands;

import classes.mp.MPUser;

class MPCModMuteUser implements IMPCommand
{
    public var user : MPUser;
    public var duration : Float;
    
    public function new(user : MPUser, duration : Int)
    {
        this.user = user;
        this.duration = duration;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "user",
                    a : "mod_mute",
                    d : {
                        uid : user.uid,
                        sid : user.sid,
                        duration : duration
                    }
                });
    }
}

