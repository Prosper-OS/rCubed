  /**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/  
package com.greensock.plugins;

import com.greensock.TweenLite;

//due to a bug in Flex Builder, this must be included in order to correctly compile a swc
/**
 * [AS3 only] Tweens numbers in a Vector.&lt;Number&gt;. Remember, Vectors require that you publish to <strong>Flash Player 10</strong> or later.
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.EndVectorPlugin; 
TweenPlugin.activate([EndVectorPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

var v:Vector.&lt;Number&gt; = new Vector.&lt;Number&gt;();
	v[0] = 0;
	v[1] = 1;
	v[2] = 2;
var end:Vector.&lt;Number&gt; = new Vector.&lt;Number&gt;();
	end[0] = 100;
	end[1] = 250;
	end[2] = 500;
TweenLite.to(v, 3, {endVector:end, onUpdate:report}); 
function report():void {
	trace(v);
}
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class EndVectorPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _v : Array<Float>;
    /** @private **/
    private var _info : Array<VectorInfo> = new Array<VectorInfo>();
    /** @private If the values should be rounded to the nearest integer, <code>_round</code> will be set to <code>true</code>. **/
    public var _round : Bool;
    
    /** @private **/
    public function new()
    {
        super("endVector");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, Array/*Vector.<T> call?*/)) || !(Std.is(value, Array/*Vector.<T> call?*/)))
        {
            return false;
        }
        _init(try cast(target, Array/*Vector.<T> call?*/) catch(e:Dynamic) null, try cast(value, Array/*Vector.<T> call?*/) catch(e:Dynamic) null);
        return true;
    }
    
    /** @private **/
    public function _init(start : Array<Float>, end : Array<Float>) : Void
    {
        _v = start;
        var i : Int = end.length;
        var cnt : Int = 0;
        while (--i > -1)
        {
            if (_v[i] != end[i])
            {
                _info[cnt++] = new VectorInfo(i, _v[i], end[i] - _v[i]);
            }
        }
    }
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        if (Lambda.has(lookup, "endVector"))
        {
            _round = value;
        }
    }
    
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        var i : Int = _info.length;
        var vi : VectorInfo;
        var val : Float;
        if (_round)
        {
            while (--i > -1)
            {
                vi = _info[i];
                _v[vi.i] = (((val = vi.c * v + vi.s) > 0)) ? (val + 0.5) >> 0 : (val - 0.5) >> 0;
            }
        }
        else
        {
            while (--i > -1)
            {
                vi = _info[i];
                _v[vi.i] = vi.c * v + vi.s;
            }
        }
    }
}


class VectorInfo
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