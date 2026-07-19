package classes.mp.commands;

import classes.User;

class MPCLogin implements IMPCommand
{
    public var user : User;
    public var version : Int;
    public var game_hash : String;
    public var game_version : String;
    
    public function new(version : Int, user : User, game_hash : String, game_version : String)
    {
        this.version = version;
        this.user = user;
        this.game_hash = game_hash;
        this.game_version = game_version;
    }
    
    public function toJSON() : String
    {
        var data : Dynamic = {
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

