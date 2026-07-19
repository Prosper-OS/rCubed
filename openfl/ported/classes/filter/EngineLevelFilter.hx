package classes.filter;

import classes.Language;
import classes.SongInfo;
import classes.User;
import classes.user.UserSongData;
import classes.user.UserSongNotes;

class EngineLevelFilter
{
    public var type(get, set)                             : Dynamic;

    /// Filter Types
    public static inline var FILTER_AND                             : Dynamic= "and";
    public static inline var FILTER_OR                             : Dynamic= "or";
    public static inline var FILTER_STYLE                             : Dynamic= "style";
    public static inline var FILTER_NAME                             : Dynamic= "name";
    public static inline var FILTER_ARTIST                             : Dynamic= "artist";
    public static inline var FILTER_STEPARTIST                             : Dynamic= "stepartist";
    public static inline var FILTER_BPM                             : Dynamic= "bpm";
    public static inline var FILTER_DIFFICULTY                             : Dynamic= "difficulty";
    public static inline var FILTER_AAA_EQUIV                             : Dynamic= "aaa_eq";
    public static inline var FILTER_ARROWCOUNT                             : Dynamic= "arrows";
    public static inline var FILTER_ID                             : Dynamic= "id";
    public static inline var FILTER_MIN_NPS                             : Dynamic= "min_nps";
    public static inline var FILTER_MAX_NPS                             : Dynamic= "max_nps";
    public static inline var FILTER_RANK                             : Dynamic= "rank";
    public static inline var FILTER_SCORE                             : Dynamic= "score";
    public static inline var FILTER_COMBO_SCORE                             : Dynamic= "combo_score";
    public static inline var FILTER_STATS                             : Dynamic= "stats";
    public static inline var FILTER_TIME                             : Dynamic= "time";
    public static inline var FILTER_SONG_RATING                             : Dynamic= "song_rating";
    public static inline var FILTER_PERSONAL_SONG_RATING                             : Dynamic= "personal_rating";
    public static inline var FILTER_SONG_FLAGS                             : Dynamic= "song_flags";
    public static inline var FILTER_SONG_ACCESS                             : Dynamic= "song_access";
    public static inline var FILTER_SONG_TYPE                             : Dynamic= "song_type";
    public static inline var FILTER_SONG_GENRE                             : Dynamic= "song_genre";
    public static inline var FILTER_FAVORITE                             : Dynamic= "song_favorite";
    
    
    public static var FILTERS                             : Dynamic= [FILTER_AND, FILTER_OR, FILTER_ARTIST, FILTER_STEPARTIST, 
        FILTER_STYLE, FILTER_TIME, FILTER_DIFFICULTY, FILTER_AAA_EQUIV, FILTER_ARROWCOUNT, FILTER_MIN_NPS, FILTER_MAX_NPS, 
        FILTER_RANK, FILTER_SCORE, FILTER_STATS, FILTER_SONG_FLAGS, FILTER_SONG_ACCESS, FILTER_SONG_TYPE, 
        FILTER_SONG_RATING, FILTER_PERSONAL_SONG_RATING, FILTER_SONG_GENRE, FILTER_FAVORITE
    ];
    public static var FILTERS_STAT                             : Dynamic= ["perfect", "good", "average", "miss", "boo", "combo"];
    public static var FILTERS_NUMBER                             : Dynamic= ["=", "!=", "<=", ">=", "<", ">"];
    public static var FILTERS_STRING                             : Dynamic= ["equal", "start_with", "end_with", "contains"];
    public static var FILTERS_FLAGS                             : Dynamic= ["equal", "not_equal", "contains", "not_contains"];
    
    public static var FILTERS_BOOLEAN                             : Dynamic= ["is", "isnt"];
    public static var FILTERS_SONG_TYPES                             : Dynamic= ["public", "token", "purchased", "secret"];
    
    public static var FILTER_FLAGS_MAP                             : Dynamic= [GlobalVariables.SONG_ICON_NO_SCORE, 
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
    
    public var name                             : Dynamic;
    private var _type                             : Dynamic;
    public var comparison                             : Dynamic;
    public var inverse                             : Dynamic= false;
    public var is_default                             : Dynamic= false;
    
    public var parent_filter                             : Dynamic;
    public var filters                             : Dynamic= [];
    public var input_number                             : Dynamic= 0;
    public var input_string                             : Dynamic= "";
    public var input_stat                             : Dynamic= FILTERS_STAT[0];  // Display4  
    
    public function new(topLevelFilter                             : Dynamic= false)
    {
        if (as3hx.Compat.truthy(topLevelFilter))
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
    
    private function set_type(value                             : Dynamic) : String
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
    public function process(songInfo                             : Dynamic, userData                             : Dynamic) : Bool
    {
        switch (type)
        {
            case FILTER_AND:
                if (as3hx.Compat.truthy(filters == null || filters.length == 0))
                {
                    return true;
                }
                
                // Check ALL Sub Filters Pass
                for (filter_and in as3hx.Compat.iter(filters))
                {
                    if (as3hx.Compat.truthy(!filter_and.process(songInfo, userData)))
                    {
                        return false;
                    }
                }
                return true;
            
            case FILTER_OR:
                if (as3hx.Compat.truthy(filters == null || filters.length == 0))
                {
                    return true;
                }
                
                var out                             : Dynamic= false;
                // Check if any Sub Filters Pass
                for (filter_or in as3hx.Compat.iter(filters))
                {
                    if (as3hx.Compat.truthy(filter_or.process(songInfo, userData)))
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
                        if (as3hx.Compat.truthy(!songInfo.engine))
                        {
                            return greaterThan(songInfo.difficulty, userData.skill_rating_levelranks[as3hx.Compat.parseInt(userData.skill_rating_levelranks.length - 1)].equiv) && userData.getLevelRank(songInfo).rawscore < songInfo.score_raw;
                        }
                }
                return compareNumberEqual(songInfo.access, input_number);
            
            case FILTER_SONG_TYPE:
                return compareSongType(songInfo, input_number);
            
            case FILTER_SONG_GENRE:
                return compareNumberEqual(songInfo.genre, input_number + 1);
            
            case FILTER_FAVORITE:
                var details                             : Dynamic= UserSongNotes.getSongUserInfo(songInfo);
                if (as3hx.Compat.truthy(details != null))
                {
                    return compareNumberEqual((details.song_favorite) ? 0 : 1, input_number);
                }
                return compareNumberEqual(1, input_number);
        }
        return true;
    }
    
    private function compareSongType(songInfo                             : Dynamic, value                             : Dynamic) : Bool
    {
        var out                             : Dynamic= songInfo.song_type == value;
        return (inverse) ? !out : out;
    }
    
    /**
     * Compares a Bitmask from Song Flags with a Bit Flag
     * @param	flag_bits
     * @param	bitmask
     */
    private function compareSongFlag(songInfo                             : Dynamic, levelRank                             : Dynamic, value                             : Dynamic) : Bool
    {
        var flag_int                             : Dynamic= GlobalVariables.getSongIconIndex(songInfo, levelRank);
        var flag_bits                             : Dynamic= GlobalVariables.getSongIconIndexBitmask(songInfo, levelRank);
        var bitmask                             : Dynamic= 1 << as3hx.Compat.parseInt(value);
        
        if (as3hx.Compat.truthy(Math.isNaN(flag_int) || Math.isNaN(flag_bits) || Math.isNaN(bitmask)))
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
    private function compareNumber(value1                             : Dynamic, value2                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(Math.isNaN(value1) || Math.isNaN(value2)))
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
    private function greaterThan(value1                             : Dynamic, value2                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(Math.isNaN(value1) || Math.isNaN(value2)))
        {
            return true;
        }
        
        var out                             : Dynamic= value1 > value2;
        return (inverse) ? !out : out;
    }
    
    private function compareNumberEqual(value1                             : Dynamic, value2                             : Dynamic) : Bool
    {
        var out                             : Dynamic= value1 == value2;
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
    private function compareString(value1                             : Dynamic, value2                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(value1 == null || value2 == null))
        {
            return true;
        }
        
        var out                             : Dynamic= false;
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
    
    public function setup(obj                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(obj.exists("type")))
        {
            type = Reflect.field(obj, "type");
        }
        
        if (as3hx.Compat.truthy(obj.exists("is_default")))
        {
            is_default = Reflect.field(obj, "is_default");
        }
        
        if (as3hx.Compat.truthy(obj.exists("filters")))
        {
            var in_filter                             : Dynamic= null;
            var in_filters                             : Dynamic= Reflect.field(obj, "filters");
            for (i in 0...in_filters.length)
            {
                in_filter = new EngineLevelFilter();
                in_filter.setup(in_filters[i]);
                in_filter.parent_filter = this;
                filters.push(in_filter);
            }
            if (as3hx.Compat.truthy(obj.exists("name")))
            {
                name = Reflect.field(obj, "name");
            }
        }
        else
        {
            if (as3hx.Compat.truthy(obj.exists("comparison")))
            {
                comparison = Reflect.field(obj, "comparison");
            }
            
            if (as3hx.Compat.truthy(obj.exists("input_number")))
            {
                input_number = Reflect.field(obj, "input_number");
            }
            
            if (as3hx.Compat.truthy(obj.exists("input_string")))
            {
                input_string = Reflect.field(obj, "input_string");
            }
            
            if (as3hx.Compat.truthy(obj.exists("input_stat")))
            {
                input_stat = Reflect.field(obj, "input_stat");
            }
            
            if (as3hx.Compat.truthy(obj.exists("inverse")))
            {
                inverse = Reflect.field(obj, "inverse");
            }
            
            if (as3hx.Compat.truthy(type == FILTER_SONG_FLAGS))
            {
                input_number = as3hx.Compat.field(FILTER_FLAGS_MAP, input_number);
            }
        }
    }
    
    public function export() : Dynamic
    {
        var obj                             : Dynamic= {
            type : type
        };
        
        if (as3hx.Compat.truthy(is_default))
        {
            Reflect.setField(obj, "is_default", is_default);
        }
        
        // Filter AND/OR
        if (as3hx.Compat.truthy(type == FILTER_AND || type == FILTER_OR))
        {
            var ex_array                             : Dynamic= [];
            for (i in 0...filters.length)
            {
                ex_array.push(filters[i].export());
            }
            
            if (as3hx.Compat.truthy(ex_array.length > 0)) {
Reflect.setField(obj, "filters", ex_array);
            }
            
            if (as3hx.Compat.truthy(name != null && name != ""))
            {
                Reflect.setField(obj, "name", name);
            }
        }
        else
        {
            Reflect.setField(obj, "comparison", comparison);
            Reflect.setField(obj, "input_number", input_number);
            Reflect.setField(obj, "input_string", input_string);
            
            if (as3hx.Compat.truthy(inverse))
            {
                Reflect.setField(obj, "inverse", inverse);
            }
            
            if (as3hx.Compat.truthy(type == FILTER_STATS))
            {
                Reflect.setField(obj, "input_stat", input_stat);
            }
            
            if (as3hx.Compat.truthy(type == FILTER_SONG_FLAGS))
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
    
    public static function createSimpleOptions(filtersString                             : Dynamic) : Array<Dynamic>
    {
        var options                             : Dynamic= [];
        for (i in 0...filtersString.length)
        {
            options.push({
                        label : filtersString[i],
                        data : i
                    });
        }
        return options;
    }
    
    public static function createSimpleOptionsFromLanguage(endIndex                             : Dynamic, prefix                             : Dynamic= "", suffix                             : Dynamic= "", startIndex                             : Dynamic= 0) : Array<Dynamic>
    {
        var removeHtmlRegExp                             : Dynamic= new as3hx.Compat.Regex("<[^<]+?>", "gi");
        var _lang                             : Dynamic= Language.instance;
        var options                             : Dynamic= [];
        for (i in startIndex...endIndex)
        {
            options.push({
                        label : _lang.stringSimple(prefix + i + suffix).replace(removeHtmlRegExp, ""),
                        data : i
                    });
        }
        return options;
    }
    
    public static function createOptions(filtersString                             : Dynamic, type                             : Dynamic) : Array<Dynamic>
    {
        var _lang                             : Dynamic= Language.instance;
        var options                             : Dynamic= [];
        for (i in 0...filtersString.length)
        {
            options.push({
                        label : _lang.stringSimple("filter_" + type + "_" + filtersString[i]),
                        data : filtersString[i]
                    });
        }
        
        return options;
    }
    
    public static function createIndexOptions(filtersString                             : Dynamic, type                             : Dynamic) : Array<Dynamic>
    {
        var _lang                             : Dynamic= Language.instance;
        var options                             : Dynamic= [];
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

