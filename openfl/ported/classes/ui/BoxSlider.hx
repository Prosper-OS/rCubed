package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class BoxSlider extends Sprite
{
    public var slideValue(get, set)                             : Dynamic;
    public var valueRange(get, never)                             : Dynamic;
    public var minValue(get, set)                             : Dynamic;
    public var maxValue(get, set)                             : Dynamic;

    private var _width                             : Dynamic;
    private var _height                             : Dynamic;
    private var _slider                             : Dynamic;
    private var _slideValue                             : Dynamic= 0;
    private var _minValue                             : Dynamic= 0;
    private var _maxValue                             : Dynamic= 1;
    
    private var _listener                             : Dynamic= null;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, width                             : Dynamic= 0, height                             : Dynamic= 0, listener                             : Dynamic= null)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        this._width = width;
        this._height = height;
        
        init();
        
        if (as3hx.Compat.truthy(listener != null))
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    public function init() : Void
    {
        this.graphics.lineStyle(1, 0xFFFFFF, 0.2);
        this.graphics.moveTo(0, _height / 2);
        this.graphics.lineTo(_width, _height / 2);
        
        _slider = new Sprite();
        _slider.graphics.lineStyle(1, 0xFFFFFF, 0.55);
        _slider.graphics.beginFill(0xFFFFFF, 0.2);
        _slider.graphics.drawRect(0, 0, 10, _height);
        _slider.graphics.endFill();
        _slider.buttonMode = true;
        _slider.useHandCursor = true;
        _slider.mouseChildren = false;
        _slider.addEventListener(MouseEvent.MOUSE_DOWN, e_startDrag);
        addChild(_slider);
    }
    
    private function e_startDrag(e                             : Dynamic) : Void
    {
        _slider.startDrag(false, new Rectangle(0, 0, _width - _slider.width, 0));
        stage.addEventListener(MouseEvent.MOUSE_MOVE, e_dragMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, e_stopDrag);
    }
    
    private function e_dragMove(e                             : Dynamic) : Void
    {
        _slideValue = (_slider.x / (_width - _slider.width)) * valueRange + _minValue;
        
        this.dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function e_stopDrag(e                             : Dynamic) : Void
    {
        _slider.stopDrag();
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, e_dragMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, e_stopDrag);
        _slideValue = (_slider.x / (_width - _slider.width)) * valueRange + _minValue;
    }
    
    /**
     * Returns the slider value and capped between the min and max values.
     */
    private function get_slideValue() : Float
    {
        return Math.max(Math.min(_slideValue, _maxValue), _minValue);
    }
    
    private function set_slideValue(value                             : Dynamic) : Float
    {
        _slideValue = value;
        var moveVal                             : Dynamic= (slideValue - minValue) / valueRange;
        _slider.x = (_width - _slider.width) * moveVal;
        return value;
    }
    
    private function get_valueRange() : Float
    {
        return _maxValue - _minValue;
    }
    
    private function get_minValue() : Float
    {
        return _minValue;
    }
    
    private function set_minValue(val                             : Dynamic) : Float
    {
        _minValue = val;
        return val;
    }
    
    private function get_maxValue() : Float
    {
        return _maxValue;
    }
    
    private function set_maxValue(val                             : Dynamic) : Float
    {
        _maxValue = val;
        return val;
    }
}


