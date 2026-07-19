package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class ScrollBar extends Sprite
{
    public var draggerVisibility(get, set)                             : Dynamic;

    private var _width                             : Dynamic;
    private var _height                             : Dynamic;
    private var _dragger                             : Dynamic;
    private var _background                             : Dynamic;
    private var _bottom                             : Dynamic;
    private var _bounds                             : Dynamic;
    
    public var scroll                             : Dynamic= 0;
    
    private var _listener                             : Dynamic= null;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, width                             : Dynamic= 0, height                             : Dynamic= 0, dragger                             : Dynamic= null, background                             : Dynamic= null, listener                             : Dynamic= null)
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
        this._dragger = dragger;
        this._background = background;
        
        //- Draw Background if one isn't provided
        if (as3hx.Compat.truthy(_background == null))
        {
            _background = new Sprite();
            _background.graphics.beginFill(0xFFFFFF, 0.12);
            _background.graphics.drawRect(0, 0, _width, _height);
            _background.graphics.endFill();
        }
        this.addChild(_background);
        
        //- Draw Dragger if one isn't provided
        if (as3hx.Compat.truthy(_dragger == null))
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
        if (as3hx.Compat.truthy(listener != null))
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
    
    public function scrollTo(val                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(val < 0))
        {
            val = 0;
        }
        if (as3hx.Compat.truthy(val > 1))
        {
            val = 1;
        }
        scroll = val;
        _dragger.y = (_bottom * val);
    }
    
    private function set_draggerVisibility(visible                             : Dynamic) : Bool
    {
        _dragger.visible = visible;
        return visible;
    }
    
    private function get_draggerVisibility() : Bool
    {
        return _dragger.visible;
    }
    
    ///- Dragger Events
    private function draggerDown(e                             : Dynamic) : Void
    {
        _bounds = new Rectangle(0, 0, 0, _bottom);
        _dragger.startDrag(false, _bounds);
        e.target.stage.addEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.addEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerUp(e                             : Dynamic) : Void
    {
        e.stopImmediatePropagation();
        _dragger.stopDrag();
        e.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.removeEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerUpOutside(e                             : Dynamic) : Void
    {
        _dragger.stopDrag();
        e.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggerMove);
        e.target.stage.removeEventListener(MouseEvent.MOUSE_UP, draggerUpOutside);
    }
    
    private function draggerMove(e                             : Dynamic) : Void
    {
        scroll = (_dragger.y / _bottom);
        this.dispatchEvent(new Event(Event.CHANGE));
    }
}

