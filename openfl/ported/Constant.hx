import openfl.geom.Matrix;
import openfl.net.URLVariables;
import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;


typedef JudgeWindowTypedef = {
    var t : Dynamic;
    var s : Int;
    var f : Dynamic;
}
class Constant
{
    // Engine Brand Name
    public static inline var BRAND_NAME_LONG : String = "FlashFlashRevolution";
    public static inline var BRAND_NAME_SHORT : String = "FFR";
    public static var BRAND_NAME_LONG_UPPER : String = BRAND_NAME_LONG.toLocaleUpperCase();
    public static var BRAND_NAME_LONG_LOWER : String = BRAND_NAME_LONG.toLocaleLowerCase();
    public static var BRAND_NAME_SHORT_UPPER : String = BRAND_NAME_SHORT.toLocaleUpperCase();
    public static var BRAND_NAME_SHORT_LOWER : String = BRAND_NAME_SHORT.toLocaleLowerCase();
    
    public static inline var AIR_VERSION : String = "0.0.0";
    public static var AIR_WINDOW_TITLE : String = "FFR" + " R^3 [" + "" + AIR_VERSION + "D" + "]";
    public static inline var LOCAL_SO_NAME : String = "90579262-509d-4370-9c2e-564667e511d7";
    public static inline var ENGINE_VERSION : Int = 3;
    
    // File Constants
    public static var MENU_MUSIC_PATH : String = "menu_music.swf";
    public static var MENU_MUSIC_MP3_PATH : String = "menu_music.mp3";
    public static var NOTESKIN_PATH : String = "noteskins/";
    public static var REPLAY_PATH : String = "replays/";
    public static var SONG_CACHE_PATH : String = "song_cache/";
    
    public static var TEXT_FORMAT : TextFormat = new TextFormat(Fonts.BASE_FONT, 14, 0xFFFFFF, true);
    public static var TEXT_FORMAT_12 : TextFormat = new TextFormat(Fonts.BASE_FONT, 12, 0xFFFFFF, true);
    public static var TEXT_FORMAT_CENTER : TextFormat = new TextFormat(Fonts.BASE_FONT, 14, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
    public static var TEXT_FORMAT_CENTER_12 : TextFormat = new TextFormat(Fonts.BASE_FONT, 12, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
    public static var TEXT_FORMAT_UNICODE : TextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 14, 0xFFFFFF, true);
    public static var TEXT_FORMAT_UNICODE_12 : TextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 12, 0xFFFFFF, true);
    
    // Other
    public static inline var NOTESKIN_EDITOR_URL : String = "https://www.flashflashrevolution.com/~velocity/ffrjs/noteskin/";
    public static inline var WEBSOCKET_OVERLAY_URL : String = "https://github.com/flashflashrevolution/web-stream-overlay";
    public static inline var LEGACY_GENRE : Int = 13;
    public static var JUDGE_WINDOW : Array<JudgeWindowTypedef> = [{
            t : -118,
            s : 5,
            f : -3
        }, 
        {
            t : -85,
            s : 25,
            f : -2
        }, 
        {
            t : -51,
            s : 50,
            f : -1
        }, 
        {
            t : -18,
            s : 100,
            f : 0
        }, 
        {
            t : 17,
            s : 50,
            f : 1
        }, 
        {
            t : 50,
            s : 25,
            f : 2
        }, 
        {
            t : 84,
            s : 25,
            f : 3
        }, 
        {
            t : 117,
            s : 0
        }
    ];
    
    // Static Initializer
    public static var GRADIENT_MATRIX : Matrix;
    public static var STYLESHEET : StyleSheet;
    
    
    // Functions
    /**
     * Adds default URLVariables to the passed requestVars.
     * @param requestVars
     */
    public static function addDefaultRequestVariables(requestVars : URLVariables) : Void
    {
        Reflect.setField(requestVars, "ver", Constant.ENGINE_VERSION);
        Reflect.setField(requestVars, "is_air", true);
        Reflect.setField(requestVars, "air_ver", Constant.AIR_VERSION);
        Reflect.setField(requestVars, "swf_ver", Main.SWF_VERSION);
    }

    public function new()
    {
    }
    private static var Constant_static_initializer = {
        {
            GRADIENT_MATRIX = new Matrix();
            GRADIENT_MATRIX.createGradientBox(100, 100, (Math.PI / 180) * 225);
            
            STYLESHEET = new StyleSheet();
            STYLESHEET.setStyle("A", {
                        textDecoration : "underline",
                        fontWeight : "bold"
                    });
        };
        true;
    }

}

