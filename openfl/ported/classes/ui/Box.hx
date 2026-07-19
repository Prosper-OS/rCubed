package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class Box extends Sprite
{
    public var highlight(get, never) : Bool;
    public var active(get, set) : Bool;
    public var color(get, set) : Int;
    public var borderColor(get, set) : Int;
    public var normalAlpha(get, set) : Float;
    public var activeAlpha(get, set) : Float;
    public var borderAlpha(get, set) : Float;
    public var borderActiveAlpha(get, set) : Float;

    // Display
    private var _width : Float = -1;
    private var _height : Float = -1;
    private var _highlight : Bool = false;
    private var _active : Bool = false;
    
    // Variables
    private var _useHover : Bool = true;
    private var _useGradient : Bool = true;
    
    // Colors & Gradient
    private var GRADIENT_COLOR : Array<Dynamic> = [0xFFFFFF, 0xFFFFFF];
    private var GRADIENT_ALPHA_HIGHLIGHT : Array<Dynamic> = [0.35, 0.1225];
    private var GRADIENT_ALPHA : Array<Dynamic> = [0.2, 0.04];
    private var GRADIENT_RATIO : Array<Dynamic> = [0, 255];
    
    private var BOX_COLOR : Int = 0xFFFFFF;
    private var BOX_ALPHA : Float = 0.07;
    private var BOX_ALPHA_ACTIVE : Float = 0.1225;
    
    private var BORDER_COLOR : Int = 0xFFFFFF;
    private var BORDER_ALPHA : Float = 0.35;
    private var BORDER_ALPHA_ACTIVE : Float = 0.55;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, useHover : Bool = true, useGradient : Bool = true)
    {
        super();
        this._useHover = useHover;
        this._useGradient = useGradient;
        
        this.x = xpos;
        this.y = ypos;
        
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        //- Add Hover Listeners
        setHoverStatus(_useHover);
    }
    
    public function setSize(w : Float, h : Float) : Void
    {
        if ((w == _width && h == _height) || (w < 0) || (h < 0) || Math.isNaN(w) || Math.isNaN(h))
        {
            return;
        }
        
        this._width = w;
        this._height = h;
        
        draw();
    }
    
    public function draw() : Void
    {
        var gradient_alphas : Array<Dynamic> = ((highlight) ? GRADIENT_ALPHA_HIGHLIGHT : GRADIENT_ALPHA);
        var draw_fill_alpha : Float = ((highlight) ? BOX_ALPHA_ACTIVE : BOX_ALPHA);
        var draw_border_alpha : Float = ((highlight) ? BORDER_ALPHA_ACTIVE : BORDER_ALPHA);
        
        this.graphics.clear();
        
        this.graphics.lineStyle(1, BORDER_COLOR, draw_border_alpha, true);
        if (_useGradient)
        {
            this.graphics.beginGradientFill(GradientType.LINEAR, GRADIENT_COLOR, gradient_alphas, GRADIENT_RATIO, Constant.GRADIENT_MATRIX);
        }
        else
        {
            this.graphics.beginFill(BOX_COLOR, draw_fill_alpha);
        }
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
    }
    
    public function dispose() : Void
    {
        this.removeEventListener(MouseEvent.ROLL_OVER, e_onHover);
        this.removeEventListener(MouseEvent.ROLL_OUT, e_onHoverOut);
    }
    
    public function setHoverStatus(enabled : Bool) : Void
    {
        if (enabled)
        {
            this.addEventListener(MouseEvent.ROLL_OVER, e_onHover, false, 0, true);
        }
        else
        {
            this.removeEventListener(MouseEvent.ROLL_OVER, e_onHover);
            this.removeEventListener(MouseEvent.ROLL_OUT, e_onHoverOut);
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Events
    private function e_onHover(e : MouseEvent) : Void
    {
        _highlight = true;
        draw();
        this.addEventListener(MouseEvent.ROLL_OUT, e_onHoverOut, false, 0, true);
    }
    
    private function e_onHoverOut(e : MouseEvent) : Void
    {
        _highlight = false;
        draw();
        this.removeEventListener(MouseEvent.ROLL_OUT, e_onHoverOut);
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_width(val : Float) : Float
    {
        this.setSize(val, _height);
        return val;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override private function set_height(val : Float) : Float
    {
        this.setSize(_width, val);
        return val;
    }
    
    private function get_highlight() : Bool
    {
        return _highlight || _active;
    }
    
    private function set_active(val : Bool) : Bool
    {
        _active = val;
        draw();
        return val;
    }
    
    private function get_active() : Bool
    {
        return _active;
    }
    
    private function set_color(val : Int) : Int
    {
        GRADIENT_COLOR = [val, val];
        BOX_COLOR = val;
        draw();
        return val;
    }
    
    private function get_color() : Int
    {
        return BOX_COLOR;
    }
    
    private function set_borderColor(val : Int) : Int
    {
        BORDER_COLOR = val;
        draw();
        return val;
    }
    
    private function get_borderColor() : Int
    {
        return BORDER_COLOR;
    }
    
    private function set_normalAlpha(val : Float) : Float
    {
        BOX_ALPHA = val;
        draw();
        return val;
    }
    
    private function get_normalAlpha() : Float
    {
        return BOX_ALPHA;
    }
    
    private function set_activeAlpha(val : Float) : Float
    {
        BOX_ALPHA_ACTIVE = val;
        draw();
        return val;
    }
    
    private function get_activeAlpha() : Float
    {
        return BOX_ALPHA_ACTIVE;
    }
    
    private function set_borderAlpha(val : Float) : Float
    {
        BORDER_ALPHA = val;
        BORDER_ALPHA_ACTIVE = Math.min(1, BORDER_ALPHA + 0.25);
        draw();
        return val;
    }
    
    private function get_borderAlpha() : Float
    {
        return BORDER_ALPHA;
    }
    
    private function set_borderActiveAlpha(val : Float) : Float
    {
        BORDER_ALPHA_ACTIVE = val;
        draw();
        return val;
    }
    
    private function get_borderActiveAlpha() : Float
    {
        return BORDER_ALPHA_ACTIVE;
    }
}

