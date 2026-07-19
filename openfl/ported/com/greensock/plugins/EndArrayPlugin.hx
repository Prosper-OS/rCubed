/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.TweenLite;

/**
 * [AS3/AS2 only] Tweens numbers in an Array.
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.EndArrayPlugin;
TweenPlugin.activate([EndArrayPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

var myArray:Array = [1,2,3,4];
TweenLite.to(myArray, 1.5, {endArray:[10,20,30,40]});
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class EndArrayPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _a : Array<Dynamic>;
    /** @private If the values should be rounded to the nearest integer, <code>_round</code> will be set to <code>true</code>. **/
    private var _round : Bool;
    /** @private **/
    private var _info : Array<Dynamic> = [];
    
    /** @private **/
    public function new()
    {
        super("endArray");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, Array)) || !(Std.is(value, Array)))
        {
            return false;
        }
        _init(try cast(target, Array<Dynamic>) catch(e:Dynamic) null, value);
        return true;
    }
    
    /** @private **/
    public function _init(start : Array<Dynamic>, end : Array<Dynamic>) : Void
    {
        _a = start;
        var i : Int = end.length;
        var cnt : Int = 0;
        while (--i > -1)
        {
            if (start[i] != end[i] && start[i] != null)
            {
                _info[cnt++] = new ArrayTweenInfo(i, _a[i], end[i] - _a[i]);
            }
        }
    }
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        if (Lambda.has(lookup, "endArray"))
        {
            _round = value;
        }
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        var i : Int = _info.length;
        var ti : ArrayTweenInfo;
        var val : Float;
        if (_round)
        {
            while (--i > -1)
            {
                ti = _info[i];
                _a[ti.i] = (((val = ti.c * v + ti.s) > 0)) ? (val + 0.5) >> 0 : (val - 0.5) >> 0;
            }
        }
        else
        {
            while (--i > -1)
            {
                ti = _info[i];
                _a[ti.i] = ti.c * v + ti.s;
            }
        }
    }
}


class ArrayTweenInfo
{
    public var i : Int;
    public var s : Float;
    public var c : Float;
    
    @:allow(com.greensock.plugins)
    private function new(index : Int, start : Float, change : Float)
    {
        this.i = index;
        this.s = start;
        this.c = change;
    }
}