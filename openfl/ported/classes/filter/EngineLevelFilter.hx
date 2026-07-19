package classes.filter;

import classes.Language;
import classes.SongInfo;
import classes.User;
import classes.user.UserSongData;
import classes.user.UserSongNotes;

class EngineLevelFilter
{
    public var type(get, set) : String;

    /// Filter Types
    public static inline var FILTER_AND : String = "and";
    public static inline var FILTER_OR : String = "or";
    public static inline var FILTER_STYLE : String = "style";
    public static inline var FILTER_NAME : String = "name";
    public static inline var FILTER_ARTIST : String = "artist";
    public static inline var FILTER_STEPARTIST : String = "stepartist";
    public static inline var FILTER_BPM : String = "bpm";
    public static inline var FILTER_DIFFICULTY : String = "difficulty";
    public static inline var FILTER_AAA_EQUIV : String = "aaa_eq";
    public static inline var FILTER_ARROWCOUNT : String = "arrows";
    public static inline var FILTER_ID : String = "id";
    public static inline var FILTER_MIN_NPS : String = "min_nps";
    public static inline var FILTER_MAX_NPS : String = "max_nps";
    public static inline var FILTER_RANK : String = "rank";
    public static inline var FILTER_SCORE : String = "score";
    public static inline var FILTER_COMBO_SCORE : String = "combo_score";
    public static inline var FILTER_STATS : String = "stats";
    public static inline var FILTER_TIME : String = "time";
    public static inline var FILTER_SONG_RATING : String = "song_rating";
    public static inline var FILTER_PERSONAL_SONG_RATING : String = "personal_rating";
    public static inline var FILTER_SONG_FLAGS : String = "song_flags";
    public static inline var FILTER_SONG_ACCESS : String = "song_access";
    public static inline var FILTER_SONG_TYPE : String = "song_type";
    public static inline var FILTER_SONG_GENRE : String = "song_genre";
    public static inline var FILTER_FAVORITE : String = "song_favorite";
    
    
    public static var FILTERS : Array<Dynamic> = [FILTER_AND, FILTER_OR, FILTER_ARTIST, FILTER_STEPARTIST, 
        FILTER_STYLE, FILTER_TIME, FILTER_DIFFICULTY, FILTER_AAA_EQUIV, FILTER_ARROWCOUNT, FILTER_MIN_NPS, FILTER_MAX_NPS, 
        FILTER_RANK, FILTER_SCORE, FILTER_STATS, FILTER_SONG_FLAGS, FILTER_SONG_ACCESS, FILTER_SONG_TYPE, 
        FILTER_SONG_RATING, FILTER_PERSONAL_SONG_RATING, FILTER_SONG_GENRE, FILTER_FAVORITE
    ];
    public static var FILTERS_STAT : Array<Dynamic> = ["perfect", "good", "average", "miss", "boo", "combo"];
    public static var FILTERS_NUMBER : Array<Dynamic> = ["=", "!=", "<=", ">=", "<", ">"];
    public static var FILTERS_STRING : Array<Dynamic> = ["equal", "start_with", "end_with", "contains"];
    public static var FILTERS_FLAGS : Array<Dynamic> = ["equal", "not_equal", "contains", "not_contains"];
    
    public static var FILTERS_BOOLEAN : Array<Dynamic> = ["is", "isnt"];
    public static var FILTERS_SONG_TYPES : Array<Dynamic> = ["public", "token", "purchased", "secret"];
    
    public static var FILTER_FLAGS_MAP : Array<Dynamic> = [GlobalVariables.SONG_ICON_NO_SCORE, 
        GlobalVariables.SONG_ICON_UNFINISHED, 
        GlobalVariables.SONG_ICON_PASSED, 
        GlobalVariables.SONG_ICON_FC_STAR, 
        GlobalVariables.SONG_ICON_FC, 
        GlobalVariables.SONG_ICON_SDG, 
        GlobalVariables.SONG_ICON_BLACKFLAG, 
        GlobalVariables.SONG_ICON_BOOFLAG, 
        GlobalVariables.SONG_ICON_AAA, 
        GlobalVariables.SONG_ICON_MISSFLAG, 
        GlobalVariables.SONG_ICON_AVFLAG, 
        GlobalVariables.SONG_ICON_OMNIFLAG
    ];
    
    public var name : String;
    private var _type : String;
    public var comparison : String;
    public var inverse : Bool = false;
    public var is_default : Bool = false;
    
    public var parent_filter : EngineLevelFilter;
    public var filters : Array<Dynamic> = [];
    public var input_number : Float = 0;
    public var input_string : String = "";
    public var input_stat : String = FILTERS_STAT[0];  // Display4  
    
    public function new(topLevelFilter : Bool = false)
    {
        if (topLevelFilter)
        {
            name = "Untitled Filter";
            type = "and";
            filters = [];
        }
    }
    
    private function get_type() : String
    {
        return _type;
    }
    
    private function set_type(value : String) : String
    {
        _type = value;
        setDefaultComparison();
        return value;
    }
    
    /**
     * Process the engine level to see if it has passed the requirements of the filters currently set.
     *
     * @param	songInfo	Engine Level to be processed.
     * @param	userData	User Data from comparisons.
     * @return	Song passed filter.
     */
    public function process(songInfo : SongInfo, userData : User) : Bool
    {
        switch (type)
        {
            case FILTER_AND:
                if (filters == null || filters.length == 0)
                {
                    return true;
                }
                
                // Check ALL Sub Filters Pass
                for (filter_and in filters)
                {
                    if (!filter_and.process(songInfo, userData))
                    {
                        return false;
                    }
                }
                return true;
            
            case FILTER_OR:
                if (filters == null || filters.length == 0)
                {
                    return true;
                }
                
                var out : Bool = false;
                // Check if any Sub Filters Pass
                for (filter_or in filters)
                {
                    if (filter_or.process(songInfo, userData))
                    {
                        out = true;
                    }
                }
                return out;
            
            case FILTER_ID:
                return compareNumber(songInfo.level, input_number);
            
            case FILTER_NAME:
                return compareString(songInfo.name, input_string);
            
            case FILTER_STYLE:
                return compareString(songInfo.style, input_string);
            
            case FILTER_ARTIST:
                return compareString(songInfo.author, input_string);
            
            case FILTER_STEPARTIST:
                return compareString(songInfo.stepauthor, input_string);
            
            case FILTER_BPM:
                return true;  // TODO: compareNumber(songData.bpm, input_number);  
            
            case FILTER_DIFFICULTY:
                return compareNumber(songInfo.difficulty, input_number);
            
            case FILTER_ARROWCOUNT:
                return compareNumber(songInfo.note_count, input_number);
            
            case FILTER_MIN_NPS:
                return compareNumber(songInfo.min_nps, input_number);
            
            case FILTER_MAX_NPS:
                return compareNumber(songInfo.max_nps, input_number);
            
            case FILTER_RANK:
                return compareNumber(userData.getLevelRank(songInfo).rank, input_number);
            
            case FILTER_SCORE:
                return compareNumber(userData.getLevelRank(songInfo).score, input_number);
            
            case FILTER_STATS:
                return compareNumber(userData.getLevelRank(songInfo)[input_stat], input_number);
            
            case FILTER_TIME:
                return compareNumber(songInfo.time_secs, input_number);
            
            case FILTER_SONG_RATING:
                return compareNumber(songInfo.song_rating, input_number);
            
            case FILTER_PERSONAL_SONG_RATING:
                return compareNumber(userData.getSongRating(songInfo), input_number);
            
            case FILTER_SONG_FLAGS:
                return compareSongFlag(songInfo, userData.getLevelRank(songInfo), input_number);
            
            case FILTER_AAA_EQUIV, FILTER_SONG_ACCESS:

                switch (type)
                {case FILTER_AAA_EQUIV:
                        if (!songInfo.engine)
                        {
                            return greaterThan(songInfo.difficulty, userData.skill_rating_levelranks[userData.skill_rating_levelranks.length - 1].equiv) && userData.getLevelRank(songInfo).rawscore < songInfo.score_raw;
                        }
                }
                return compareNumberEqual(songInfo.access, input_number);
            
            case FILTER_SONG_TYPE:
                return compareSongType(songInfo, input_number);
            
            case FILTER_SONG_GENRE:
                return compareNumberEqual(songInfo.genre, input_number + 1);
            
            case FILTER_FAVORITE:
                var details : UserSongData = UserSongNotes.getSongUserInfo(songInfo);
                if (details != null)
                {
                    return compareNumberEqual((details.song_favorite) ? 0 : 1, input_number);
                }
                return compareNumberEqual(1, input_number);
        }
        return true;
    }
    
    private function compareSongType(songInfo : SongInfo, value : Float) : Bool
    {
        var out : Bool = songInfo.song_type == value;
        return (inverse) ? !out : out;
    }
    
    /**
     * Compares a Bitmask from Song Flags with a Bit Flag
     * @param	flag_bits
     * @param	bitmask
     */
    private function compareSongFlag(songInfo : SongInfo, levelRank : Dynamic, value : Float) : Bool
    {
        var flag_int : Int = GlobalVariables.getSongIconIndex(songInfo, levelRank);
        var flag_bits : Int = GlobalVariables.getSongIconIndexBitmask(songInfo, levelRank);
        var bitmask : Int = 1 << as3hx.Compat.parseInt(value);
        
        if (Math.isNaN(flag_int) || Math.isNaN(flag_bits) || Math.isNaN(bitmask))
        {
            return true;
        }
        
        switch (comparison)
        {
            case "equal":
                return flag_int == value;
            
            case "not_equal":
                return flag_int != value;
            
            case "contains":
                return (flag_bits & bitmask) != 0;
            
            case "not_contains":
                return (flag_bits & bitmask) == 0;
        }
        return false;
    }
    
    /**
     * Compares 2 Number values with the selected comparision.
     * @param	value1	Input Value
     * @param	value2	Value to compare to.
     * @param	comparison	Method of comparision.
     * @return	If comparision was successful.
     */
    private function compareNumber(value1 : Float, value2 : Float) : Bool
    {
        if (Math.isNaN(value1) || Math.isNaN(value2))
        {
            return true;
        }
        switch (comparison)
        {
            case "=":
                return value1 == value2;
            
            case "!=":
                return value1 != value2;
            
            case "<=":
                return value1 <= value2;
            
            case ">=":
                return value1 >= value2;
            
            case "<":
                return value1 < value2;
            
            case ">":
                return value1 > value2;
        }
        return false;
    }
    
    /**
     * Compares 2 Number values with a greater than comparison, unless inverted.
     * @param	value1	Input Value
     * @param	value2	Value to compare to.
     * @param	inverse	Use inverse comparisons.
     * @return	If comparision was successful.
     */
    private function greaterThan(value1 : Float, value2 : Float) : Bool
    {
        if (Math.isNaN(value1) || Math.isNaN(value2))
        {
            return true;
        }
        
        var out : Bool = value1 > value2;
        return (inverse) ? !out : out;
    }
    
    private function compareNumberEqual(value1 : Float, value2 : Float) : Bool
    {
        var out : Bool = value1 == value2;
        return (inverse) ? !out : out;
    }
    
    /**
     * Compares 2 String values with the selected comparision.
     * @param	value1	Input Value
     * @param	value2	Value to compare to.
     * @param	comparison	Method of comparision.
     * @param	inverse	Use inverse comparisions.
     * @return	If comparision was successful.
     */
    private function compareString(value1 : String, value2 : String) : Bool
    {
        if (value1 == null || value2 == null)
        {
            return true;
        }
        
        var out : Bool = false;
        value1 = value1.toLowerCase();
        value2 = value2.toLowerCase();
        
        switch (comparison)
        {
            case "equal":
                out = (value1 == value2);
            
            case "start_with":
                out = (value2 == value1.substring(0, value2.length));
            
            case "end_with":
                out = (value2 == value1.substring(value1.length - value2.length));
            
            case "contains":
                out = (value1.indexOf(value2) >= 0);
        }
        return (inverse) ? !out : out;
    }
    
    public function setup(obj : Dynamic) : Void
    {
        if (obj.exists("type"))
        {
            type = Reflect.field(obj, "type");
        }
        
        if (obj.exists("is_default"))
        {
            is_default = Reflect.field(obj, "is_default");
        }
        
        if (obj.exists("filters"))
        {
            var in_filter : EngineLevelFilter;
            var in_filters : Array<Dynamic> = Reflect.field(obj, "filters");
            for (i in 0...in_filters.length)
            {
                in_filter = new EngineLevelFilter();
                in_filter.setup(in_filters[i]);
                in_filter.parent_filter = this;
                filters.push(in_filter);
            }
            if (obj.exists("name"))
            {
                name = Reflect.field(obj, "name");
            }
        }
        else
        {
            if (obj.exists("comparison"))
            {
                comparison = Reflect.field(obj, "comparison");
            }
            
            if (obj.exists("input_number"))
            {
                input_number = Reflect.field(obj, "input_number");
            }
            
            if (obj.exists("input_string"))
            {
                input_string = Reflect.field(obj, "input_string");
            }
            
            if (obj.exists("input_stat"))
            {
                input_stat = Reflect.field(obj, "input_stat");
            }
            
            if (obj.exists("inverse"))
            {
                inverse = Reflect.field(obj, "inverse");
            }
            
            if (type == FILTER_SONG_FLAGS)
            {
                input_number = Reflect.field(FILTER_FLAGS_MAP, Std.string(input_number));
            }
        }
    }
    
    public function export() : Dynamic
    {
        var obj : Dynamic = {
            type : type
        };
        
        if (is_default)
        {
            Reflect.setField(obj, "is_default", is_default);
        }
        
        // Filter AND/OR
        if (type == FILTER_AND || type == FILTER_OR)
        {
            var ex_array : Array<Dynamic> = [];
            for (i in 0...filters.length)
            {
                ex_array.push(filters[i].export());
            }
            
            if (ex_array.length > 0) {
Reflect.setField(obj, "filters", ex_array);
            }
            
            if (name != null && name != "")
            {
                Reflect.setField(obj, "name", name);
            }
        }
        else
        {
            Reflect.setField(obj, "comparison", comparison);
            Reflect.setField(obj, "input_number", input_number);
            Reflect.setField(obj, "input_string", input_string);
            
            if (inverse)
            {
                Reflect.setField(obj, "inverse", inverse);
            }
            
            if (type == FILTER_STATS)
            {
                Reflect.setField(obj, "input_stat", input_stat);
            }
            
            if (type == FILTER_SONG_FLAGS)
            {
                Reflect.setField(obj, "input_number", Lambda.indexOf(FILTER_FLAGS_MAP, input_number));
            }
        }
        return obj;
    }
    
    public function setDefaultComparison() : Void
    {
        switch (type)
        {
            case FILTER_STATS:
                input_stat = FILTERS_STAT[0];
                comparison = FILTERS_NUMBER[0];
            
            case FILTER_SONG_FLAGS:
                input_number = 0;
                comparison = FILTERS_FLAGS[0];
            
            case FILTER_SONG_TYPE:
                input_number = 0;
                comparison = FILTERS_SONG_TYPES[0];
            case FILTER_ARROWCOUNT, FILTER_BPM, FILTER_DIFFICULTY, FILTER_MAX_NPS, FILTER_MIN_NPS, FILTER_RANK, FILTER_SCORE, FILTER_TIME, FILTER_SONG_RATING, FILTER_PERSONAL_SONG_RATING:
                comparison = FILTERS_NUMBER[0];
            case FILTER_ID, FILTER_NAME, FILTER_STYLE, FILTER_ARTIST, FILTER_STEPARTIST:
                comparison = FILTERS_STRING[0];
        }
    }
    
    public function toString() : String
    {
        return type + " [" + comparison + "]" + (!(Math.isNaN(input_number)) ? " input_number=" + input_number : "") + ((input_string != null) ? " input_string=" + input_string : "") + ((input_stat != null) ? " input_stat=" + input_stat : "");
    }
    
    public static function createSimpleOptions(filtersString : Array<Dynamic>) : Array<Dynamic>
    {
        var options : Array<Dynamic> = [];
        for (i in 0...filtersString.length)
        {
            options.push({
                        label : filtersString[i],
                        data : i
                    });
        }
        return options;
    }
    
    public static function createSimpleOptionsFromLanguage(endIndex : Int, prefix : String = "", suffix : String = "", startIndex : Int = 0) : Array<Dynamic>
    {
        var removeHtmlRegExp : as3hx.Compat.Regex = new as3hx.Compat.Regex("<[^<]+?>", "gi");
        var _lang : Language = Language.instance;
        var options : Array<Dynamic> = [];
        for (i in startIndex...endIndex)
        {
            options.push({
                        label : _lang.stringSimple(prefix + i + suffix).replace(removeHtmlRegExp, ""),
                        data : i
                    });
        }
        return options;
    }
    
    public static function createOptions(filtersString : Array<Dynamic>, type : String) : Array<Dynamic>
    {
        var _lang : Language = Language.instance;
        var options : Array<Dynamic> = [];
        for (i in 0...filtersString.length)
        {
            options.push({
                        label : _lang.stringSimple("filter_" + type + "_" + filtersString[i]),
                        data : filtersString[i]
                    });
        }
        
        return options;
    }
    
    public static function createIndexOptions(filtersString : Array<Dynamic>, type : String) : Array<Dynamic>
    {
        var _lang : Language = Language.instance;
        var options : Array<Dynamic> = [];
        for (i in 0...filtersString.length)
        {
            options.push({
                        label : _lang.stringSimple("filter_" + type + "_" + filtersString[i]),
                        data : i
                    });
        }
        
        return options;
    }
}

