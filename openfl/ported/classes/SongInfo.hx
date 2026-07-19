package classes;

import classes.chart.parse.ExternalChartBase;

class SongInfo
{
    public static inline var SONG_TYPE_PUBLIC                              : Dynamic= 0;
    public static inline var SONG_TYPE_TOKEN                              : Dynamic= 1;
    public static inline var SONG_TYPE_PURCHASED                              : Dynamic= 2;
    public static inline var SONG_TYPE_SECRET                              : Dynamic= 3;
    
    // Engine Variables
    public var access                              : Dynamic= 0;
    public var chart_type                              : Dynamic;
    public var song_type                              : Dynamic;
    public var index                              : Dynamic;
    
    public var score_raw                              : Dynamic;
    public var score_total                              : Dynamic;
    
    // Song Variables
    public var genre                              : Dynamic;
    public var level                              : Dynamic;
    public var name                              : Dynamic;
    public var name_original                              : Dynamic;
    public var name_explicit                              : Dynamic;
    public var subtitle                              : Dynamic;
    public var difficulty                              : Dynamic;
    public var note_count                              : Dynamic;
    public var order                              : Dynamic;
    public var style                              : Dynamic;
    public var tags                              : Dynamic;
    
    public var author                              : Dynamic;
    public var author_original                              : Dynamic;
    public var author_url                              : Dynamic;
    public var author_html                              : Dynamic;
    
    public var stepauthor                              : Dynamic;
    public var stepauthor_html                              : Dynamic;
    
    public var play_hash                              : Dynamic;
    public var swf_hash                              : Dynamic;
    
    public var prerelease                              : Dynamic;
    public var release_date                              : Dynamic;
    
    public var min_nps                              : Dynamic;
    public var max_nps                              : Dynamic;
    
    public var time                              : Dynamic;
    public var time_secs                              : Dynamic;
    public var time_end                              : Dynamic= 0;
    
    public var is_unranked                              : Dynamic= false;
    public var is_explicit                              : Dynamic= false;
    public var is_legacy                              : Dynamic= false;
    public var is_disabled                              : Dynamic= false;
    
    // Song - Optional
    public var price                              : Dynamic;
    public var credits                              : Dynamic;
    public var song_rating                              : Dynamic;
    
    // Alt Engines Variables
    public var engine                              : Dynamic;
    public var level_id                              : Dynamic;
    public var sync                              : Dynamic;
    public var background                              : Dynamic;
    
    // Local Files
    public var is_local                              : Dynamic= false;
    public var chart_parser                              : Dynamic;
    
    public function new()
    {
    }
    
    public function compareTo(s2                              : Dynamic) : Bool
    {
        return compare(this, s2);
    }
    
    public static function compare(s1                              : Dynamic, s2                              : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(s1 == null || s2 == null))
        {
            return false;
        }
        
        if (as3hx.Compat.truthy(s1.engine && s2.engine && s1.engine.id != s2.engine.id))
        {
            return false;
        }
        
        if (as3hx.Compat.truthy(s1.level > 0 && s2.level > 0 && s1.level != s2.level))
        {
            return false;
        }
        
        if (as3hx.Compat.truthy(s1.level_id && s2.level_id && s1.level_id != s2.level_id))
        {
            return false;
        }
        
        return true;
    }
}

