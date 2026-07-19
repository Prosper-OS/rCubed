package classes.mp.commands;

import classes.mp.MPUser;

class MPCUserMessage implements IMPCommand
{
    public var user                             : Dynamic;
    public var message                             : Dynamic;
    public var type                             : Dynamic;
    
    public function new(user                             : Dynamic, message                             : Dynamic, type                             : Dynamic= 0)
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

