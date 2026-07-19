package com.flashfla.utils;


class ColorUtil
{
    public static function brightenColor(hexColor                            : Dynamic, percent                            : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(Math.isNaN(percent)))
        {
            percent = 0;
        }
        if (as3hx.Compat.truthy(percent > 1))
        {
            percent = 1;
        }
        if (as3hx.Compat.truthy(percent < 0))
        {
            percent = 0;
        }
        
        var rgb                            : Dynamic= hexToRgb(hexColor);
        
        rgb.r += (255 - rgb.r) * percent;
        rgb.b += (255 - rgb.b) * percent;
        rgb.g += (255 - rgb.g) * percent;
        
        return rgbToHex(Math.round(rgb.r), Math.round(rgb.g), Math.round(rgb.b));
    }
    
    public static function darkenColor(hexColor                            : Dynamic, percent                            : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(Math.isNaN(percent)))
        {
            percent = 0;
        }
        if (as3hx.Compat.truthy(percent > 1))
        {
            percent = 1;
        }
        if (as3hx.Compat.truthy(percent < 0))
        {
            percent = 0;
        }
        
        var factor                            : Dynamic= 1 - percent;
        var rgb                            : Dynamic= hexToRgb(hexColor);
        
        rgb.r *= factor;
        rgb.b *= factor;
        rgb.g *= factor;
        
        return rgbToHex(Math.round(rgb.r), Math.round(rgb.g), Math.round(rgb.b));
    }
    
    public static function rgbToHex(r                            : Dynamic, g                            : Dynamic, b                            : Dynamic) : Float
    {
        return (r << 16 | g << 8 | b);
    }
    
    public static function hexToRgb(hex                            : Dynamic) : Dynamic
    {
        return {
            r : (as3hx.Compat.parseInt(hex) & 0xff0000) >> 16,
            g : (as3hx.Compat.parseInt(hex) & 0x00ff00) >> 8,
            b : as3hx.Compat.parseInt(hex) & 0x0000ff
        };
    }
    
    public static function brightness(hex                            : Dynamic) : Float
    {
        var max                            : Dynamic= 0;
        var rgb                            : Dynamic= hexToRgb(hex);
        if (as3hx.Compat.truthy(rgb.r > max))
        {
            max = rgb.r;
        }
        if (as3hx.Compat.truthy(rgb.g > max))
        {
            max = rgb.g;
        }
        if (as3hx.Compat.truthy(rgb.b > max))
        {
            max = rgb.b;
        }
        max /= 255;
        return max;
    }

    public function new()
    {
    }
}


