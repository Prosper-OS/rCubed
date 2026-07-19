package classes.mp.commands;

import classes.mp.MPUser;

class MPCUserMessage implements IMPCommand
{
    public var user : MPUser;
    public var message : String;
    public var type : Float;
    
    public function new(user : MPUser, message : String, type : Float = 0)
    {
        this.user = user;
        this.message = message;
        this.type = type;
    }
    
    public function toJSON() : String
    {
        return haxe.Json.stringify({
                    t : "user",
                    a : "message",
                    d : {
                        uid : user.uid,
                        sid : user.sid,
                        message : message,
                        type : type
                    }
                });
    }
}

