package classes;

import game.GameOptions;

class NoteskinsStruct
{
    public static function getDefaultStruct() : Dynamic
    {
        var DEFAULT_OPTIONS                              : Dynamic= new GameOptions();
        DEFAULT_OPTIONS.noteColors.push("receptor");
        
        var output                              : Dynamic= {
            options : {
                grid_dim : "5,2",
                rotate : "90"
            }
        };
        for (c in 0...DEFAULT_OPTIONS.noteColors.length)
        {
            var color_obj                              : Dynamic= { };
            for (d in 0...DEFAULT_OPTIONS.noteDirections.length)
            {
                var dir_obj                              : Dynamic= {
                    r : "",
                    c : ""
                };
                Reflect.setField(color_obj, Std.string(DEFAULT_OPTIONS.noteDirections[d]), dir_obj);
            }
            Reflect.setField(output, Std.string(DEFAULT_OPTIONS.noteColors[c]), color_obj);
        }
        return output;
    }
    
    public static function getDirectionValue(struct                              : Dynamic, color                              : Dynamic, dir                              : Dynamic, key                              : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(struct != null && Reflect.field(struct, color) != null && Reflect.field(Reflect.field(struct, color), dir) != null && Reflect.field(Reflect.field(Reflect.field(struct, color), dir), key) != null))
        {
            return Reflect.field(Reflect.field(Reflect.field(struct, color), dir), key);
        }
        return "";
    }
    
    public static function setDirectionValue(struct                              : Dynamic, color                              : Dynamic, dir                              : Dynamic, key                              : Dynamic, val                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(struct != null))
        {
            if (as3hx.Compat.truthy(Reflect.field(struct, color) == null))
            {
                Reflect.setField(struct, color, { });
            }
            if (as3hx.Compat.truthy(Reflect.field(Reflect.field(struct, color), dir) == null))
            {
                Reflect.setField(Reflect.field(struct, color), dir, { });
            }
            Reflect.setField(Reflect.field(Reflect.field(struct, color), dir), key, val);
        }
    }
    
    public static function parseCellInput(text                              : Dynamic, min_x                              : Dynamic= 0, min_y                              : Dynamic= 0, max_x                              : Dynamic= 20, max_y                              : Dynamic= 20) : Array<Dynamic>
    {
        var out                              : Dynamic= [1, 1];
        var cell_values                              : Dynamic= text.split(",");
        if (as3hx.Compat.truthy(cell_values.length >= 2))
        {
            out[0] = as3hx.Compat.parseInt(cell_values[0]);
            out[1] = as3hx.Compat.parseInt(cell_values[1]);
        }
        else if (as3hx.Compat.truthy(cell_values.length == 1))
        {
            out[0] = out[1] = as3hx.Compat.parseInt(cell_values[0]);
        }
        
        if (as3hx.Compat.truthy(Math.isNaN(out[0]) || !Math.isFinite(out[0])))
        {
            out[0] = 1;
        }
        if (as3hx.Compat.truthy(Math.isNaN(out[1]) || !Math.isFinite(out[1])))
        {
            out[1] = 1;
        }
        
        out[0] = Math.min(Math.max(out[0], min_x), max_x);
        out[1] = Math.min(Math.max(out[1], min_y), max_y);
        
        return out;
    }
    
    public static function textToRotation(t                              : Dynamic, def                              : Dynamic) : Float
    {
        var n                              : Dynamic= as3hx.Compat.parseFloat(t);
        if (as3hx.Compat.truthy(Math.isNaN(n) || !Math.isFinite(n)))
        {
            n = def;
        }
        
        return n % 360;
    }

    public function new()
    {
    }
}


