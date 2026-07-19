package classes.ui;

import assets.GameBackgroundColor;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class BoxCheck extends Sprite
{
    public var highlight(get, never) : Bool;
    public var checked(get, set) : Bool;

    // Display
    private var _width : Float = 14;
    private var _height : Float = 14;
    private var _highlight : Bool = false;
    private var _active : Bool = false;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, listener : Dynamic = null)
    {
        super();
        if (parent != null)
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
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.CLICK, listener);
        }
        
        draw();
    }
    
    public function dispose() : Void
    {
        if (_listener != null)
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
        if (checked)
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
    
    private function set_checked(val : Bool) : Bool
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

