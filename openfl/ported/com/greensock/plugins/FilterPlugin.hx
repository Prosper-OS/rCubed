  /**
 * VERSION: 12.0.1
 * DATE: 2013-05-21
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/  
package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

/**
 * @private
 * Base class for all filter plugins (like blurFilter, colorMatrixFilter, glowFilter, etc.). Handles common routines. 
 * There is no reason to use this class directly.<br /><br />
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class FilterPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _target : Dynamic;
    /** @private **/
    private var _type : Class<Dynamic>;
    /** @private **/
    private var _filter : BitmapFilter;
    /** @private **/
    private var _index : Int;
    /** @private **/
    private var _remove : Bool;
    /** @private **/
    private var _tween : TweenLite;
    
    /** @private **/
    public function new(props : String = "", priority : Float = 0)
    {
        super(props, priority);
    }
    
    /** @private **/
    private function _initFilter(target : Dynamic, props : Dynamic, tween : TweenLite, type : Class<Dynamic>, defaultFilter : BitmapFilter, propNames : Array<Dynamic>) : Bool
    {
        _target = target;
        _tween = tween;
        _type = type;
        var filters : Array<Dynamic> = _target.filters;
        var p : String;
        var i : Int;
        var colorTween : HexColorsPlugin;
        var extras : Dynamic = ((Std.is(props, BitmapFilter))) ? { } : props;
        if (extras.index != null)
        {
            _index = extras.index;
        }
        else
        {
            _index = filters.length;
            if (extras.addFilter != true)
            {
                while (--_index > -1 && !(Std.is(filters[_index], _type)))
                {
                }
            }
        }
        if (_index < 0 || !(Std.is(filters[_index], _type)))
        {
            if (_index < 0)
            {
                _index = filters.length;
            }
            if (_index > filters.length) {
i = as3hx.Compat.parseInt(filters.length - 1);
                while (++i < _index)
                {
                    filters[i] = new BlurFilter(0, 0, 1);
                }
            }
            filters[_index] = defaultFilter;
            _target.filters = filters;
        }
        _filter = filters[_index];
        _remove = (extras.remove == true);
        i = propNames.length;
        while (--i > -1)
        {
            p = propNames[i];
            if (Lambda.has(props, p) && Reflect.field(_filter, p) != Reflect.field(props, p))
            {
                if (p == "color" || p == "highlightColor" || p == "shadowColor")
                {
                    colorTween = new HexColorsPlugin();
                    colorTween._initColor(_filter, p, Reflect.field(props, p));
                    _addTween(colorTween, "setRatio", 0, 1, _propName);
                }
                else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject")
                {
                    Reflect.setField(_filter, p, Reflect.field(props, p));
                }
                else
                {
                    _addTween(_filter, p, Reflect.field(_filter, p), Reflect.field(props, p), _propName);
                }
            }
        }
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        var filters : Array<Dynamic> = _target.filters;
        if (!(Std.is(filters[_index], _type))) {
_index = filters.length;  //default (in case it was removed)  
            while (--_index > -1 && !(Std.is(filters[_index], _type)))
            {
            }
            if (_index == -1)
            {
                _index = filters.length;
            }
        }
        if (v == 1 && _remove && _tween._time == _tween._duration && _tween.data != "isFromStart")
        {
            if (_index < filters.length)
            {
                filters.splice(_index, 1);
            }
        }
        else
        {
            filters[_index] = _filter;
        }
        _target.filters = filters;
    }
}
