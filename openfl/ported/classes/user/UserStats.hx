package classes.user;

import openfl.errors.Error;
import com.flashfla.net.WebRequest;
import openfl.events.EventDispatcher;

class UserStats extends EventDispatcher
{
    private static var cache : Dynamic = { };
    
    public var userid : Float;
    public var aaa : Float;
    public var fc : Float;
    public var tier_points : Float;
    public var tier_bonus : Float;
    public var tier_total : Float;
    public var equiv_cutoff : Float;
    public var equiv_scores : Array<UserStatsScore>;
    
    public var tier_tiers : Array<Dynamic>;
    public var total_songs : Float;
    public var total_tier_points : Float;
    
    public function new(data : Dynamic)
    {
        super();
        if (data.userid != null)
        {
            this.userid = data.userid;
        }
        
        if (data.aaa != null)
        {
            this.aaa = data.aaa;
        }
        
        if (data.fc != null)
        {
            this.fc = data.fc;
        }
        
        if (data.tier_points != null)
        {
            this.tier_points = data.tier_points;
        }
        
        if (data.tier_bonus != null)
        {
            this.tier_bonus = data.tier_bonus;
        }
        
        if (data.tier_total != null)
        {
            this.tier_total = data.tier_total;
        }
        
        if (data.equiv_cutoff != null)
        {
            this.equiv_cutoff = data.equiv_cutoff;
        }
        
        if (data.equiv_scores != null)
        {
            this.equiv_scores = [];
            for (score/* AS3HX WARNING could not determine type for var: score exp: EField(EIdent(data),equiv_scores) type: null */ in data.equiv_scores)
            {
                this.equiv_scores.push(new UserStatsScore(score));
            }
        }
        
        if (data.tier_tiers != null)
        {
            this.tier_tiers = data.tier_tiers;
        }
        
        if (data.total_songs != null)
        {
            this.total_songs = data.total_songs;
        }
        
        if (data.total_tier_points != null)
        {
            this.total_tier_points = data.total_tier_points;
        }
    }
    
    public static function load(userid : Float, callback : Dynamic) : Void
    {
        if (Reflect.field(cache, Std.string(userid)) != null)
        {
            callback(Reflect.field(cache, Std.string(userid)));
            return;
        }
        
        var wr : WebRequest = new WebRequest(URLs.resolve(URLs.USER_STATS_URL), c_loadComplete, c_loadError);
        wr.load({
                    userid : userid
                });
        
        var c_loadComplete : Dynamic->Void = function(e : Dynamic = null) : Void
        {
            try
            {
                Reflect.setField(cache, Std.string(userid), new UserStats(haxe.Json.parse(e.target.data)));
                callback(Reflect.field(cache, Std.string(userid)));
            }
            catch (e : Error)
            {
                c_loadError();
            }
        }
        
        var c_loadError : Dynamic->Void = function(e : Dynamic = null) : Void
        {
            callback(null);
        }
    }
}

