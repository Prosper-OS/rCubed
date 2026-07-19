package classes.ui;

import assets.GameBackgroundColor;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class BoxCheck extends Sprite
{
    public var highlight(get, never)                             : Dynamic;
    public var checked(get, set)                             : Dynamic;

    // Display
    private var _width                             : Dynamic= 14;
    private var _height                             : Dynamic= 14;
    private var _highlight                             : Dynamic= false;
    private var _active                             : Dynamic= false;
    
    private var _listener                             : Dynamic= null;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, listener                             : Dynamic= null)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        //- Set Button Mode
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        //- Set position
        this.x = xpos;
        this.y = ypos;
        
        //- Set click event listener
        if (as3hx.Compat.truthy(listener != null))
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.CLICK, listener);
        }
        
        draw();
    }
    
    public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_listener != null))
        {
            this.removeEventListener(MouseEvent.CLICK, _listener);
        }
    }
    
    public function draw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.75, true);
        this.graphics.beginFill((highlight) ? GameBackgroundColor.BG_LIGHT : 0xFFFFFF, (highlight) ? 1 : 0.25);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
        
        // X
        if (as3hx.Compat.truthy(checked))
        {
            this.graphics.lineStyle(0, 0, 0);
            this.graphics.beginFill(0xFFFFFF, 0.75);
            this.graphics.drawRect(5, 5, width - 9, height - 9);
            this.graphics.endFill();
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    private function get_highlight() : Bool
    {
        return _highlight || _active;
    }
    
    private function set_checked(val                             : Dynamic) : Bool
    {
        _active = val;
        draw();
        return val;
    }
    
    private function get_checked() : Bool
    {
        return _active;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
}

