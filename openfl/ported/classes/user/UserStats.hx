package classes.user;

import openfl.errors.Error;
import com.flashfla.net.WebRequest;
import openfl.events.EventDispatcher;

class UserStats extends EventDispatcher
{
    private static var c_loadComplete                     : Dynamic;
    private static var c_loadError                     : Dynamic;
    private static var cache                            : Dynamic= { };
    
    public var userid                            : Dynamic;
    public var aaa                            : Dynamic;
    public var fc                            : Dynamic;
    public var tier_points                            : Dynamic;
    public var tier_bonus                            : Dynamic;
    public var tier_total                            : Dynamic;
    public var equiv_cutoff                            : Dynamic;
    public var equiv_scores                            : Dynamic;
    
    public var tier_tiers                            : Dynamic;
    public var total_songs                            : Dynamic;
    public var total_tier_points                            : Dynamic;
    
    public function new(data                            : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(data.userid != null))
        {
            this.userid = data.userid;
        }
        
        if (as3hx.Compat.truthy(data.aaa != null))
        {
            this.aaa = data.aaa;
        }
        
        if (as3hx.Compat.truthy(data.fc != null))
        {
            this.fc = data.fc;
        }
        
        if (as3hx.Compat.truthy(data.tier_points != null))
        {
            this.tier_points = data.tier_points;
        }
        
        if (as3hx.Compat.truthy(data.tier_bonus != null))
        {
            this.tier_bonus = data.tier_bonus;
        }
        
        if (as3hx.Compat.truthy(data.tier_total != null))
        {
            this.tier_total = data.tier_total;
        }
        
        if (as3hx.Compat.truthy(data.equiv_cutoff != null))
        {
            this.equiv_cutoff = data.equiv_cutoff;
        }
        
        if (as3hx.Compat.truthy(data.equiv_scores != null))
        {
            this.equiv_scores = [];
            for (score/* AS3HX WARNING could not determine type for var: score exp: EField(EIdent(data),equiv_scores) type: null */ in as3hx.Compat.iter(data.equiv_scores))
            {
                this.equiv_scores.push(new UserStatsScore(score));
            }
        }
        
        if (as3hx.Compat.truthy(data.tier_tiers != null))
        {
            this.tier_tiers = data.tier_tiers;
        }
        
        if (as3hx.Compat.truthy(data.total_songs != null))
        {
            this.total_songs = data.total_songs;
        }
        
        if (as3hx.Compat.truthy(data.total_tier_points != null))
        {
            this.total_tier_points = data.total_tier_points;
        }
    }
    
    public static function load(userid                            : Dynamic, callback                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(as3hx.Compat.field(cache, userid) != null))
        {
            callback(as3hx.Compat.field(cache, userid));
            return;
        }
        
        var wr                            : Dynamic= new WebRequest(URLs.resolve(URLs.USER_STATS_URL), c_loadComplete, c_loadError);
        wr.load({
                    userid : userid
                });
        
        c_loadComplete = function(e                            : Dynamic= null) : Void
        {
            try
            {
                Reflect.setField(cache, Std.string(userid), new UserStats(haxe.Json.parse(e.target.data)));
                callback(as3hx.Compat.field(cache, userid));
            }
            catch (e : Error)
            {
                c_loadError();
            }
        }
        
        c_loadError = function(e                            : Dynamic= null) : Void
        {
            callback(null);
        }
    }
}

