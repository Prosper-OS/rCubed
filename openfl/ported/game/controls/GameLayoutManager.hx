package game.controls;

import openfl.errors.Error;
import openfl.display.Sprite;
import game.GameOptions;
import game.GameplayDisplay;

class GameLayoutManager extends Sprite
{
    public static inline var LAYOUT_BAR_TOP : String = "bartop";
    public static inline var LAYOUT_BAR_BOTTOM : String = "barbottom";
    public static inline var LAYOUT_PROGRESS_BAR : String = "progressbar";
    public static inline var LAYOUT_PROGRESS_TEXT : String = "progresstext";
    public static inline var LAYOUT_RECEPTORS : String = "receptors";
    public static inline var LAYOUT_JUDGE : String = "judge";
    public static inline var LAYOUT_HEALTH : String = "health";
    public static inline var LAYOUT_SCORE : String = "score";
    public static inline var LAYOUT_COMBO : String = "combo";
    public static inline var LAYOUT_TOTAL : String = "combototal";
    public static inline var LAYOUT_COMBO_STATIC : String = "combostatic";
    public static inline var LAYOUT_TOTAL_STATIC : String = "combototalstatic";
    public static inline var LAYOUT_ACCURACY_BAR : String = "accuracybar";
    public static inline var LAYOUT_PA : String = "pa";
    public static inline var LAYOUT_RAWGOODS : String = "rawgoods";
    public static inline var LAYOUT_RAWGOODS_STATIC : String = "rawgoodsstatic";
    public static inline var LAYOUT_MP_FFR_SCORE : String = "mpffrscore";
    
    public var gameplay : GameplayDisplay;
    public var options : GameOptions;
    public var defaultLayout : Dynamic;
    
    public function new(gameplay : GameplayDisplay, options : GameOptions)
    {
        super();
        buildDefaultLayout();
        
        this.gameplay = gameplay;
        this.options = options;
    }
    
    public function save() : Void
    {
        cleanLayout(options.layout);
    }
    
    public function interfaceLayout(key : String, defaults : Bool = true) : Dynamic
    {
        if (defaults)
        {
            var ret : Dynamic = { };
            var def : Dynamic = Reflect.field(defaultLayout, key);
            
            for (i in Reflect.fields(def))
            {
                Reflect.setField(ret, i, Reflect.field(def, i));
            }
            
            var layout : Dynamic = options.layout[key];
            for (i in Reflect.fields(layout))
            {
                Reflect.setField(ret, Std.string(i), Reflect.field(layout, Std.string(i)));
            }
            
            return ret;
        }
        else if (options.layout[key] == null)
        {
            options.layout[key] = { };
        }
        
        return options.layout[key];
    }
    
    public function interfacePosition(sprite : Sprite, key : String) : Void
    {
        if (sprite == null)
        {
            return;
        }
        
        try
        {
            var layout : Dynamic = interfaceLayout(key);
            for (p in Reflect.fields(layout))
            {
                if (Lambda.has(sprite, p))
                {
                    Reflect.setField(sprite, p, Reflect.field(layout, p));
                }
            }
        }
        catch (e : Error)
        {
        }
    }
    
    private function buildDefaultLayout() : Void
    {
        defaultLayout = { };
        Reflect.setField(defaultLayout, LAYOUT_BAR_TOP, {
            x : 0,
            y : 0,
            scale : 1,
            alpha : 1,
            rotation : 0,
            type : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_BAR_BOTTOM, {
            x : 0,
            y : Main.GAME_HEIGHT,
            scale : 1,
            alpha : 1,
            rotation : 0,
            type : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_PROGRESS_BAR, {
            x : 161,
            y : 9,
            scale : 1,
            alpha : 1,
            rotation : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_PROGRESS_TEXT, {
            x : 768,
            y : 5,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "right"
        });
        Reflect.setField(defaultLayout, LAYOUT_JUDGE, {
            x : (Main.GAME_WIDTH / 2),
            y : 225,
            scale : 1,
            alpha : 1,
            rotation : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_ACCURACY_BAR, {
            x : (Main.GAME_WIDTH / 2),
            y : 328,
            alpha : 1,
            rotation : 0,
            width : 200,
            height : 16
        });
        Reflect.setField(defaultLayout, LAYOUT_HEALTH, {
            x : Main.GAME_WIDTH - 37,
            y : 70,
            scale : 1,
            alpha : 1,
            rotation : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_RECEPTORS, {
            x : Main.GAME_WIDTH / 2,
            y : Main.GAME_HEIGHT / 2,
            z : 0,
            scale : 1,
            rotation : 0,
            rotationX : 0
        });
        
        Reflect.setField(defaultLayout, LAYOUT_PA, {
            x : 18,
            y : 80,
            scale : 1,
            alpha : 1,
            rotation : 0,
            type : 0,
            show_labels : true
        });
        Reflect.setField(defaultLayout, LAYOUT_SCORE, {
            x : (Main.GAME_WIDTH / 2),
            y : 436,
            scale : 1,
            alpha : 1,
            rotation : 0
        });
        Reflect.setField(defaultLayout, LAYOUT_COMBO, {
            x : 222,
            y : 396,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "right"
        });
        Reflect.setField(defaultLayout, LAYOUT_COMBO_STATIC, {
            x : 220,
            y : 434,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "left"
        });
        Reflect.setField(defaultLayout, LAYOUT_TOTAL, {
            x : 554,
            y : 402,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "left"
        });
        Reflect.setField(defaultLayout, LAYOUT_TOTAL_STATIC, {
            x : 552,
            y : 434,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "right"
        });
        Reflect.setField(defaultLayout, LAYOUT_RAWGOODS, {
            x : 73,
            y : 350,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "left"
        });
        Reflect.setField(defaultLayout, LAYOUT_RAWGOODS_STATIC, {
            x : 71,
            y : 371,
            scale : 1,
            alpha : 1,
            rotation : 0,
            alignment : "right"
        });
        
        Reflect.setField(defaultLayout, LAYOUT_MP_FFR_SCORE, {
            x : Main.GAME_WIDTH - 150,
            y : 0,
            scale : 1,
            alpha : 1,
            rotation : 0
        });
    }
    
    /**
     * Removes all non-existent components or properties that match the defaults.
     * @param layout
     */
    public function cleanLayout(layout : Dynamic) : Void
    {
        var key : String;
        var prop : String;
        
        // Remove non-existent Components
        for (key in Reflect.fields(layout))
        {
            if (!(Lambda.has(defaultLayout, key)))
            {
                Reflect.deleteField(layout, key);
            }
        }
        
        // Remove default values.
        for (key in Reflect.fields(defaultLayout)) {
if (!(Lambda.has(layout, key)))
            {
                continue;
            }
            
            var dprop : Dynamic = Reflect.field(defaultLayout, key);
            var sprop : Dynamic = Reflect.field(layout, key);
            
            for (prop in Reflect.fields(dprop)) {
if (!(Lambda.has(sprop, prop)))
                {
                    continue;
                }
                
                // Value matches default, remove.
                if (Reflect.field(sprop, prop) == Reflect.field(dprop, prop))
                {
                    Reflect.deleteField(sprop, prop);
                }
            }
        }
        
        // Remove empty components.
        for (key in Reflect.fields(layout))
        {
            var cprop : Dynamic = Reflect.field(layout, key);
            var ccount : Float = 0;
            
            for (prop in Reflect.fields(cprop))
            {
                ccount++;
            }
            
            if (ccount == 0)
            {
                Reflect.deleteField(layout, key);
            }
        }
    }
}

