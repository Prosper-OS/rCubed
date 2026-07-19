/**
 * VERSION: 12.01
 * DATE: 2012-07-28
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.*;
import com.greensock.core.*;
import openfl.display.*;
import openfl.geom.ColorTransform;
import openfl.geom.Transform;

/**
 * [AS3/AS2 only] To change a DisplayObject's tint/color, set this to the hex value of the tint you'd like
 * to end up at (or begin at if you're using <code>TweenMax.from()</code>). An example hex value would be <code>0xFF0000</code>.
 * 
 * <p>To remove a tint completely, set the tint to <code>null</code></p>
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.TintPlugin; 
TweenPlugin.activate([TintPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(mc, 1, {tint:0xFF0000}); 
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class TintPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    /** @private **/
    private static var _props : Array<Dynamic> = ["redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset", "greenOffset", "blueOffset", "alphaOffset"];
    
    /** @private **/
    private var _transform : Transform;
    
    /** @private **/
    public function new()
    {
        super("tint,colorTransform,removeTint");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, DisplayObject)))
        {
            return false;
        }
        var end : ColorTransform = new ColorTransform();
        if (value != null && tween.vars.removeTint != true)
        {
            end.color = as3hx.Compat.parseInt(value);
        }
        _transform = cast((target), DisplayObject).transform;
        var ct : ColorTransform = _transform.colorTransform;
        end.alphaMultiplier = ct.alphaMultiplier;
        end.alphaOffset = ct.alphaOffset;
        _init(ct, end);
        return true;
    }
    
    /** @private **/
    public function _init(start : ColorTransform, end : ColorTransform) : Void
    {
        var i : Int = _props.length;
        var p : String;
        while (--i > -1)
        {
            p = _props[i];
            if (Reflect.field(start, p) != Reflect.field(end, p))
            {
                _addTween(start, p, Reflect.field(start, p), Reflect.field(end, p), "tint");
            }
        }
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        var ct : ColorTransform = _transform.colorTransform;
        var pt : PropTween = _firstPT;
        while (pt)
        {
            ct[pt.p] = pt.c * v + pt.s;
            pt = pt._next;
        }
        _transform.colorTransform = ct;
    }
}
