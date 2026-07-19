package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class StarSelector extends Sprite
{
    public var value(get, set)                            : Dynamic;
    public var outline(never, set)                            : Dynamic;

    private var outlineSprite                            : Dynamic;
    private var fillSprite                            : Dynamic;
    private var fillMask                            : Dynamic;
    private var _value                            : Dynamic= 1;
    private var _hovervalue                            : Dynamic= 0;
    public var MIN_VALUE                            : Dynamic= 0;
    public var MAX_VALUE                            : Dynamic= 5;
    
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0, isActive                            : Dynamic= true)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        init(isActive);
    }
    
    private function init(isActive                            : Dynamic) : Void
    {
        this.mouseChildren = false;
        if (as3hx.Compat.truthy(isActive))
        {
            this.buttonMode = true;
            this.useHandCursor = true;
            this.addEventListener(MouseEvent.CLICK, e_mouseClick);
            this.addEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
        }
        // Draw Star Mask
        fillMask = new Sprite();
        for (i in 0...5)
        {
            drawStar(fillMask.graphics, 28, i * 32, 0, false, 0, 2, true);
        }
        addChild(fillMask);
        
        // Draw Star Fills
        fillSprite = new Sprite();
        drawFill();
        fillSprite.mask = fillMask;
        addChild(fillSprite);
        
        // Draw Star Outlines
        outlineSprite = new Sprite();
        for (i in 0...5)
        {
            drawStar(outlineSprite.graphics, 28, i * 32, 0);
        }
        
        // Draw Mouse Background
        this.graphics.beginFill(0xff0000, 0);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
        
        addChild(outlineSprite);
    }
    
    private function e_mouseClick(e                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_hovervalue != value))
        {
            value = _hovervalue;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    private function e_mouseOver(e                            : Dynamic) : Void
    {
        this.addEventListener(MouseEvent.MOUSE_MOVE, e_mouseMove);
        this.addEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
    }
    
    private function e_mouseOut(e                            : Dynamic) : Void
    {
        this.removeEventListener(MouseEvent.MOUSE_MOVE, e_mouseMove);
        this.removeEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
        _hovervalue = 0;
        drawFill();
    }
    
    private function e_mouseMove(e                            : Dynamic) : Void
    {
        var posX                            : Dynamic= ((e.localX + 8) / outlineSprite.width);
        var val                            : Dynamic= Math.round((((MAX_VALUE - MIN_VALUE) * posX) + MIN_VALUE) * 2) / 2;
        if (as3hx.Compat.truthy(val != _hovervalue && val >= 0.5))
        {
            _hovervalue = val;
            drawFill();
        }
    }
    
    private function drawFill() : Void
    {
        fillSprite.graphics.clear();
        fillSprite.graphics.lineStyle(1, 0, 0);
        fillSprite.graphics.beginFill(0xF2D60D, 1);
        fillSprite.graphics.drawRect(0, 0, value * 32 - 2, 32);
        fillSprite.graphics.endFill();
        
        if (as3hx.Compat.truthy(_hovervalue > 0))
        {
            fillSprite.graphics.beginFill(0x4EBFE5, 1);
            fillSprite.graphics.drawRect(0, 0, _hovervalue * 32 - 2, 32);
            fillSprite.graphics.endFill();
        }
    }
    
    public function addBackgroundStars() : Void
    {
        var bgStars                            : Dynamic= new Sprite();
        for (i in 0...5)
        {
            drawStar(bgStars.graphics, 28, i * 32, 0, true, 0xFFFFFF, 0, false);
        }
        bgStars.alpha = 0.2;
        addChildAt(bgStars, 0);
    }
    
    private function get_value() : Float
    {
        return _value;
    }
    
    private function set_value(val                            : Dynamic) : Float
    {
        _value = val;
        drawFill();
        return val;
    }
    
    private function set_outline(val                            : Dynamic) : Bool
    {
        outlineSprite.visible = val;
        return val;
    }
    
    public static function drawStar(grph                            : Dynamic, size                            : Dynamic, _x                            : Dynamic= 0, _y                            : Dynamic= 0, _fill                            : Dynamic= false, _fillColor                            : Dynamic= 0xffffff, _borderThickness                            : Dynamic= 2, _isMask                            : Dynamic= false) : Void
    {
        var STAR_WIDTH                            : Dynamic= size;
        var STAR_HEIGHT                            : Dynamic= size;
        
        if (as3hx.Compat.truthy(!_isMask))
        {
            grph.lineStyle(1, 0, 0);
            grph.beginFill(0, 0);
            grph.drawRect(0, 0, size, size);
            grph.endFill();
        }
        
        grph.beginFill(_fillColor, (_fill) ? 1 : 0);
        grph.lineStyle(_borderThickness, 0xffffff, 1, true);
        grph.moveTo(_x + (0.5 * STAR_WIDTH), _y + (0 * STAR_HEIGHT));
        grph.lineTo(_x + (0.667 * STAR_WIDTH), _y + (0.296 * STAR_HEIGHT));
        grph.lineTo(_x + (1 * STAR_WIDTH), _y + (0.37 * STAR_HEIGHT));
        grph.lineTo(_x + (0.778 * STAR_WIDTH), _y + (0.611 * STAR_HEIGHT));
        grph.lineTo(_x + (0.815 * STAR_WIDTH), _y + (0.944 * STAR_HEIGHT));
        grph.lineTo(_x + (0.5 * STAR_WIDTH), _y + (0.815 * STAR_HEIGHT));
        grph.lineTo(_x + (0.185 * STAR_WIDTH), _y + (0.944 * STAR_HEIGHT));
        grph.lineTo(_x + (0.241 * STAR_WIDTH), _y + (0.611 * STAR_HEIGHT));
        grph.lineTo(_x + (0 * STAR_WIDTH), _y + (0.37 * STAR_HEIGHT));
        grph.lineTo(_x + (0.333 * STAR_WIDTH), _y + (0.296 * STAR_HEIGHT));
        grph.lineTo(_x + (0.5 * STAR_WIDTH), _y + (0 * STAR_HEIGHT));
        grph.endFill();
    }
}

