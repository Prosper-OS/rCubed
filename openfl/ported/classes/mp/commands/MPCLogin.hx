package classes.mp.commands;

import classes.User;

class MPCLogin implements IMPCommand
{
    public var user                             : Dynamic;
    public var version                             : Dynamic;
    public var game_hash                             : Dynamic;
    public var game_version                             : Dynamic;
    
    public function new(version                             : Dynamic, user                             : Dynamic, game_hash                             : Dynamic, game_version                             : Dynamic)
    {
        this.version = version;
        this.user = user;
        this.game_hash = game_hash;
        this.game_version = game_version;
    }
    
    public function toJSON() : String
    {
        var data                             : Dynamic= {
            sid : user.siteId,
            token : user.hash,
            version : version,
            game_hash : game_hash,
            game_version : game_version
        };
        
        return haxe.Json.stringify({
                    t : "sys",
                    a : "login",
                    d : data
                });
    }
}

