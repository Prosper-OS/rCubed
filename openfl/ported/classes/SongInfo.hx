package classes;

import classes.chart.parse.ExternalChartBase;

class SongInfo
{
    public static inline var SONG_TYPE_PUBLIC : Int = 0;
    public static inline var SONG_TYPE_TOKEN : Int = 1;
    public static inline var SONG_TYPE_PURCHASED : Int = 2;
    public static inline var SONG_TYPE_SECRET : Int = 3;
    
    // Engine Variables
    public var access : Int = 0;
    public var chart_type : String;
    public var song_type : Int;
    public var index : Int;
    
    public var score_raw : Int;
    public var score_total : Int;
    
    // Song Variables
    public var genre : Int;
    public var level : Int;
    public var name : String;
    public var name_original : String;
    public var name_explicit : String;
    public var subtitle : String;
    public var difficulty : Int;
    public var note_count : Int;
    public var order : Int;
    public var style : String;
    public var tags : String;
    
    public var author : String;
    public var author_original : String;
    public var author_url : String;
    public var author_html : String;
    
    public var stepauthor : String;
    public var stepauthor_html : String;
    
    public var play_hash : String;
    public var swf_hash : String;
    
    public var prerelease : Bool;
    public var release_date : Int;
    
    public var min_nps : Int;
    public var max_nps : Int;
    
    public var time : String;
    public var time_secs : Int;
    public var time_end : Float = 0;
    
    public var is_unranked : Bool = false;
    public var is_explicit : Bool = false;
    public var is_legacy : Bool = false;
    public var is_disabled : Bool = false;
    
    // Song - Optional
    public var price : Int;
    public var credits : Int;
    public var song_rating : Float;
    
    // Alt Engines Variables
    public var engine : Dynamic;
    public var level_id : String;
    public var sync : Int;
    public var background : String;
    
    // Local Files
    public var is_local : Bool = false;
    public var chart_parser : ExternalChartBase;
    
    public function new()
    {
    }
    
    public function compareTo(s2 : SongInfo) : Bool
    {
        return compare(this, s2);
    }
    
    public static function compare(s1 : SongInfo, s2 : SongInfo) : Bool
    {
        if (s1 == null || s2 == null)
        {
            return false;
        }
        
        if (s1.engine && s2.engine && s1.engine.id != s2.engine.id)
        {
            return false;
        }
        
        if (s1.level > 0 && s2.level > 0 && s1.level != s2.level)
        {
            return false;
        }
        
        if (s1.level_id && s2.level_id && s1.level_id != s2.level_id)
        {
            return false;
        }
        
        return true;
    }
}

