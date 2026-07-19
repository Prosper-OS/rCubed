import openfl.geom.Matrix;
import openfl.net.URLVariables;
import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;


typedef JudgeWindowTypedef = {
    var t                              : Dynamic;
    var s                              : Dynamic;
    var f                              : Dynamic;
}
class Constant
{
    // Engine Brand Name
    public static inline var BRAND_NAME_LONG                              : Dynamic= "FlashFlashRevolution";
    public static inline var BRAND_NAME_SHORT                              : Dynamic= "FFR";
    public static var BRAND_NAME_LONG_UPPER                              : Dynamic= BRAND_NAME_LONG.toUpperCase();
    public static var BRAND_NAME_LONG_LOWER                              : Dynamic= BRAND_NAME_LONG.toLowerCase();
    public static var BRAND_NAME_SHORT_UPPER                              : Dynamic= BRAND_NAME_SHORT.toUpperCase();
    public static var BRAND_NAME_SHORT_LOWER                              : Dynamic= BRAND_NAME_SHORT.toLowerCase();
    
    public static inline var AIR_VERSION                              : Dynamic= "0.0.0";
    public static var AIR_WINDOW_TITLE                              : Dynamic= "FFR" + " R^3 [" + "" + AIR_VERSION + "D" + "]";
    public static inline var LOCAL_SO_NAME                              : Dynamic= "90579262-509d-4370-9c2e-564667e511d7";
    public static inline var ENGINE_VERSION                              : Dynamic= 3;
    
    // File Constants
    public static var MENU_MUSIC_PATH                              : Dynamic= "menu_music.swf";
    public static var MENU_MUSIC_MP3_PATH                              : Dynamic= "menu_music.mp3";
    public static var NOTESKIN_PATH                              : Dynamic= "noteskins/";
    public static var REPLAY_PATH                              : Dynamic= "replays/";
    public static var SONG_CACHE_PATH                              : Dynamic= "song_cache/";
    
    public static var TEXT_FORMAT                              : Dynamic= new TextFormat(Fonts.BASE_FONT, 14, 0xFFFFFF, true);
    public static var TEXT_FORMAT_12                              : Dynamic= new TextFormat(Fonts.BASE_FONT, 12, 0xFFFFFF, true);
    public static var TEXT_FORMAT_CENTER                              : Dynamic= new TextFormat(Fonts.BASE_FONT, 14, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
    public static var TEXT_FORMAT_CENTER_12                              : Dynamic= new TextFormat(Fonts.BASE_FONT, 12, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
    public static var TEXT_FORMAT_UNICODE                              : Dynamic= new TextFormat(Fonts.BASE_FONT_CJK, 14, 0xFFFFFF, true);
    public static var TEXT_FORMAT_UNICODE_12                              : Dynamic= new TextFormat(Fonts.BASE_FONT_CJK, 12, 0xFFFFFF, true);
    
    // Other
    public static inline var NOTESKIN_EDITOR_URL                              : Dynamic= "https://www.flashflashrevolution.com/~velocity/ffrjs/noteskin/";
    public static inline var WEBSOCKET_OVERLAY_URL                              : Dynamic= "https://github.com/flashflashrevolution/web-stream-overlay";
    public static inline var LEGACY_GENRE                              : Dynamic= 13;
    public static var JUDGE_WINDOW                              : Dynamic= [{
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
    public static var GRADIENT_MATRIX                              : Dynamic;
    public static var STYLESHEET                              : Dynamic;
    
    
    // Functions
    /**
     * Adds default URLVariables to the passed requestVars.
     * @param requestVars
     */
    public static function addDefaultRequestVariables(requestVars                              : Dynamic) : Void
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

