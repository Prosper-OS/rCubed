package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class BoxSlider extends Sprite
{
    public var slideValue(get, set) : Float;
    public var valueRange(get, never) : Float;
    public var minValue(get, set) : Float;
    public var maxValue(get, set) : Float;

    private var _width : Float;
    private var _height : Float;
    private var _slider : Sprite;
    private var _slideValue : Float = 0;
    private var _minValue : Float = 0;
    private var _maxValue : Float = 1;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Int = 0, height : Int = 0, listener : Dynamic = null)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        this._width = width;
        this._height = height;
        
        init();
        
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    private function init() : Void
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
    
    private function e_startDrag(e : MouseEvent) : Void
    {
        _slider.startDrag(false, new Rectangle(0, 0, _width - _slider.width, 0));
        stage.addEventListener(MouseEvent.MOUSE_MOVE, e_dragMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, e_stopDrag);
    }
    
    private function e_dragMove(e : MouseEvent) : Void
    {
        _slideValue = (_slider.x / (_width - _slider.width)) * valueRange + _minValue;
        
        this.dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function e_stopDrag(e : MouseEvent) : Void
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
    
    private function set_slideValue(value : Float) : Float
    {
        _slideValue = value;
        var moveVal : Float = (slideValue - minValue) / valueRange;
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
    
    private function set_minValue(val : Float) : Float
    {
        _minValue = val;
        return val;
    }
    
    private function get_maxValue() : Float
    {
        return _maxValue;
    }
    
    private function set_maxValue(val : Float) : Float
    {
        _maxValue = val;
        return val;
    }
}


