
class Fonts
{
    public static inline var BASE_FONT : String = "Noto Sans";  //new NotoSans.Bold().fontName;  
    public static inline var BASE_FONT_CJK : String = "Noto Sans CJK JP Bold";  //new NotoSans.CJKBold().fontName;  
    public static inline var AACHEN_LIGHT : String = "Aachen-Light";  //new AachenLight().fontName;  
    public static inline var FONT_AWESOME : String = "FontAwesome";  //new FontAwesome.Solid().fontName;    // Embed Fonts  

    public function new()
    {
    }
    private static var Fonts_static_initializer = {
        AachenLight;
        NotoSans.CJKBold;
        NotoSans.Bold;
        NotoSans.BoldItalic;
        FontAwesome.Solid;
        true;
    }

}

