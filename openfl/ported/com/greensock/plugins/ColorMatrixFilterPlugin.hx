/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.filters.ColorMatrixFilter;

/**
 * [AS3/AS2 only] ColorMatrixFilter tweening offers an easy way to tween a DisplayObject's saturation, hue, contrast,
 * brightness, and colorization. The following properties are available (you only need to define the ones you want to tween):
 * <ul>
 * 		<li><code> colorize : uint </code> (colorizing a DisplayObject makes it look as though you're seeing it through a colored piece of glass whereas tinting it makes every pixel exactly that color. You can control the amount of colorization using the "amount" value where 1 is full strength, 0.5 is half-strength, and 0 has no colorization effect.)</li>
 * 		<li><code> amount : Number [1] </code> (only used in conjunction with "colorize")</li>
 * 		<li><code> contrast : Number </code> (1 is normal contrast, 0 has no contrast, and 2 is double the normal contrast, etc.)</li>
 * 		<li><code> saturation : Number </code> (1 is normal saturation, 0 makes the DisplayObject look black and white, and 2 would be double the normal saturation)</li>
 * 		<li><code> hue : Number </code> (changes the hue of every pixel. Think of it as degrees, so 180 would be rotating the hue to be exactly opposite as normal, 360 would be the same as 0, etc.)</li>
 * 		<li><code> brightness : Number </code> (1 is normal brightness, 0 is much darker than normal, and 2 is twice the normal brightness, etc.)</li>
 * 		<li><code> threshold : Number </code> (number from 0 to 255 that controls the threshold of where the pixels turn white or black)</li>
 * 		<li><code> matrix : Array </code> (If you already have a matrix from a ColorMatrixFilter that you want to tween to, pass it in with the "matrix" property. This makes it possible to match effects created in the Flash IDE.)</li>
 * 		<li><code> index : Number </code> (only necessary if you already have a filter applied and you want to target it with the tween.)</li>
 * 		<li><code> addFilter : Boolean [false] </code></li>
 * 		<li><code> remove : Boolean [false] </code> (Set remove to true if you want the filter to be removed when the tween completes.)</li>
 * </ul>
 * <p>HINT: If you'd like to match the ColorMatrixFilter values you created in the Flash IDE on a particular object, you can get its matrix like this:</p>
 * <listing version="3.0">
import openfl.display.DisplayObject; 
import openfl.filters.ColorMatrixFilter;

function getColorMatrix(mc:DisplayObject):Array { 
   var f:Array = mc.filters, i:uint; 
	   for (i = 0; i &lt; f.length; i++) { 
	      if (f[i] is ColorMatrixFilter) { 
 return f[i].matrix; 
  } 
   }
   return null;
} 

var myOriginalMatrix:Array = getColorMatrix(my_mc); //store it so you can tween back to it anytime like TweenMax.to(my_mc, 1, {colorMatrixFilter:{matrix:myOriginalMatrix}});
</listing>
 * 
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.ColorMatrixFilterPlugin;
TweenPlugin.activate([ColorMatrixFilterPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(mc, 1, {colorMatrixFilter:{colorize:0xFF0000}});
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class ColorMatrixFilterPlugin extends FilterPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    /** @private **/
    private static var _propNames : Array<Dynamic> = [];
    
    /** @private **/
    private static var _idMatrix : Array<Dynamic> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    /** @private **/
    private static var _lumR : Float = 0.212671;  //Red constant - used for a few color matrix filter functions  
    /** @private **/
    private static var _lumG : Float = 0.715160;  //Green constant - used for a few color matrix filter functions  
    /** @private **/
    private static var _lumB : Float = 0.072169;  //Blue constant - used for a few color matrix filter functions  
    
    /** @private **/
    private var _matrix : Array<Dynamic>;
    /** @private **/
    private var _matrixTween : EndArrayPlugin;
    
    /** @private **/
    public function new()
    {
        super("colorMatrixFilter");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var cmf : Dynamic = value;
        _initFilter(target, {
                    remove : value.remove,
                    index : value.index,
                    addFilter : value.addFilter
                }, tween, ColorMatrixFilter, new ColorMatrixFilter(_idMatrix.copy()), _propNames);
        if (_filter == null)
        {
            trace("FILTER NULL! ");
            return true;
        }
        
        _matrix = cast((_filter), ColorMatrixFilter).matrix;
        var endMatrix : Array<Dynamic> = [];
        
        if (cmf.matrix != null && (Std.is(cmf.matrix, Array)))
        {
            endMatrix = cmf.matrix;
        }
        else
        {
            if (cmf.relative == true)
            {
                endMatrix = _matrix.copy();
            }
            else
            {
                endMatrix = _idMatrix.copy();
            }
            endMatrix = setBrightness(endMatrix, cmf.brightness);
            endMatrix = setContrast(endMatrix, cmf.contrast);
            endMatrix = setHue(endMatrix, cmf.hue);
            endMatrix = setSaturation(endMatrix, cmf.saturation);
            endMatrix = setThreshold(endMatrix, cmf.threshold);
            if (!Math.isNaN(cmf.colorize))
            {
                endMatrix = colorize(endMatrix, cmf.colorize, cmf.amount);
            }
        }
        _matrixTween = new EndArrayPlugin();
        _matrixTween._init(_matrix, endMatrix);
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        _matrixTween.setRatio(v);
        cast((_filter), ColorMatrixFilter).matrix = _matrix;
        super.setRatio(v);
    }
    
    
    //---- MATRIX OPERATIONS --------------------------------------------------------------------------------
    
    /** @private **/
    public static function colorize(m : Array<Dynamic>, color : Float, amount : Float = 1) : Array<Dynamic>
    {
        if (Math.isNaN(color))
        {
            return m;
        }
        else if (Math.isNaN(amount))
        {
            amount = 1;
        }
        var r : Float = (as3hx.Compat.parseInt(color >> 16) & 0xff) / 255;
        var g : Float = (as3hx.Compat.parseInt(color >> 8) & 0xff) / 255;
        var b : Float = (as3hx.Compat.parseInt(color) & 0xff) / 255;
        var inv : Float = 1 - amount;
        var temp : Array<Dynamic> = [inv + amount * r * _lumR, amount * r * _lumG, amount * r * _lumB, 0, 0, 
        amount * g * _lumR, inv + amount * g * _lumG, amount * g * _lumB, 0, 0, 
        amount * b * _lumR, amount * b * _lumG, inv + amount * b * _lumB, 0, 0, 
        0, 0, 0, 1, 0
    ];
        return applyMatrix(temp, m);
    }
    
    /** @private **/
    public static function setThreshold(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        var temp : Array<Dynamic> = [_lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, 
        _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, 
        _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, 
        0, 0, 0, 1, 0
    ];
        return applyMatrix(temp, m);
    }
    
    /** @private **/
    public static function setHue(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n *= Math.PI / 180;
        var c : Float = Math.cos(n);
        var s : Float = Math.sin(n);
        var temp : Array<Dynamic> = [(_lumR + (c * (1 - _lumR))) + (s * (-_lumR)), (_lumG + (c * (-_lumG))) + (s * (-_lumG)), (_lumB + (c * (-_lumB))) + (s * (1 - _lumB)), 0, 0, (_lumR + (c * (-_lumR))) + (s * 0.143), (_lumG + (c * (1 - _lumG))) + (s * 0.14), (_lumB + (c * (-_lumB))) + (s * -0.283), 0, 0, (_lumR + (c * (-_lumR))) + (s * (-(1 - _lumR))), (_lumG + (c * (-_lumG))) + (s * _lumG), (_lumB + (c * (1 - _lumB))) + (s * _lumB), 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
        return applyMatrix(temp, m);
    }
    
    /** @private **/
    public static function setBrightness(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n = (n * 100) - 100;
        return applyMatrix([1, 0, 0, 0, n, 
                0, 1, 0, 0, n, 
                0, 0, 1, 0, n, 
                0, 0, 0, 1, 0, 
                0, 0, 0, 0, 1
        ], m);
    }
    
    /** @private **/
    public static function setSaturation(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        var inv : Float = 1 - n;
        var r : Float = inv * _lumR;
        var g : Float = inv * _lumG;
        var b : Float = inv * _lumB;
        var temp : Array<Dynamic> = [r + n, g, b, 0, 0, 
        r, g + n, b, 0, 0, 
        r, g, b + n, 0, 0, 
        0, 0, 0, 1, 0
    ];
        return applyMatrix(temp, m);
    }
    
    /** @private **/
    public static function setContrast(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n += 0.01;
        var temp : Array<Dynamic> = [n, 0, 0, 0, 128 * (1 - n), 
        0, n, 0, 0, 128 * (1 - n), 
        0, 0, n, 0, 128 * (1 - n), 
        0, 0, 0, 1, 0
    ];
        return applyMatrix(temp, m);
    }
    
    /** @private **/
    public static function applyMatrix(m : Array<Dynamic>, m2 : Array<Dynamic>) : Array<Dynamic>
    {
        if (!(Std.is(m, Array)) || !(Std.is(m2, Array)))
        {
            return m2;
        }
        var temp : Array<Dynamic> = [];
        var i : Int = 0;
        var z : Int = 0;
        var y : Int;
        var x : Int;
        y = 0;
        while (y < 4)
        {
            x = 0;
            while (x < 5)
            {
                z = ((x == 4)) ? m[i + 4] : 0;
                temp[i + x] = m[i] * m2[x] +
                        m[i + 1] * m2[x + 5] +
                        m[i + 2] * m2[x + 10] +
                        m[i + 3] * m2[x + 15] +
                        z;
                x += 1;
            }
            i += 5;
            y += 1;
        }
        return temp;
    }
}
