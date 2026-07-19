package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class ScrollBar extends Sprite
{
    public var draggerVisibility(get, set) : Bool;

    private var _width : Int;
    private var _height : Int;
    private var _dragger : Sprite;
    private var _background : Sprite;
    private var _bottom : Float;
    private var _bounds : Rectangle;
    
    public var scroll : Float = 0;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Int = 0, height : Int = 0, dragger : Sprite = null, background : Sprite = null, listener : Dynamic = null)
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
        this._dragger = dragger;
        this._background = background;
        
        //- Draw Background if one isn't provided
        if (_background == null)
        {
            _background = new Sprite();
            _background.graphics.beginFill(0xFFFFFF, 0.12);
            _background.graphics.drawRect(0, 0, _width, _height);
            _background.graphics.endFill();
        }
        this.addChild(_background);
        
        //- Draw Dragger if one isn't provided
        if (_dragger == null)
        {
            _dragger = new Sprite();
            _dragger.graphics.beginFill(0xFFFFFF, 0.5);
            _dragger.graphics.drawRect(0, 0, _width, (_height < 30) ? _height : 30);
            _dragger.graphics.endFill();
        }
        
        //- Set Button Mode
        _dragger.mouseChildren = false;
        _dragger.useHandCursor = true;
        _dragger.buttonMode = true;
        
        //- Add Listeners
        _dragger.addEventListener(MouseEvent.MOUSE_DOWN, draggerDown);
        _dragger.addEventListener(MouseEvent.MOUSE_UP, draggerUp);
        
        this.addChild(_dragger);
        
        //- Set Bottom Bound
        _bottom = Math.floor(_height - _dragger.height);
        
        //- Set click event listener
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    public function reset() : Void
    {
        _dragger.y = 0;
        scroll = 0;
    }
    
    public function scrollTo(val : Float) : Void
    {
        if (val < 0)
        {
            val = 0;
        }
        if (val > 1)
        {
            val = 1;
        }
        scroll = val;
        _dragger.y = (_bottom * val);
    }
    
    private function set_draggerVisibility(visible : Bool) : Bool
    {
        _dragger.visible = visible;
        return visible;
    }
    
    private function get_draggerVisibility() : Bool
    {
        return _dragger.visible;
    }
    
    ///- Dragger Events
    private function draggerDown(e : MouseEvent) : Void
    {
        _bounds = new Rectangle(0, 0, 0, _bottom);
        _dragger.startDrag(false, _bounds);
        e.target.stage.addEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.addEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerUp(e : MouseEvent) : Void
    {
        e.stopImmediatePropagation();
        _dragger.stopDrag();
        e.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.removeEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerUpOutside(e : MouseEvent) : Void
    {
        _dragger.stopDrag();
        e.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.removeEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerMove(e : MouseEvent) : Void
    {
        scroll = (_dragger.y / _bottom);
        this.dispatchEvent(new Event(Event.CHANGE));
    }
}

