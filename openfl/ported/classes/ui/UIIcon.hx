package classes.ui;

import com.flashfla.utils.ColorUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;

/**
 * Wrapper for icon shapes into UIComponent compatible shapes.
 */
class UIIcon extends Sprite
{
    public var icon                            : Dynamic;
    private var _sprWidth                            : Dynamic= 1;
    private var _sprHeight                            : Dynamic= 1;
    private var _width                            : Dynamic= 0;
    private var _height                            : Dynamic= 0;
    
    public function new(parent                            : Dynamic= null, sprite                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0)
    {
        super();
        mouseChildren = false;
        
        if (as3hx.Compat.truthy(sprite != null))
        {
            icon = sprite;
            _sprWidth = sprite.width;
            _sprHeight = sprite.height;
            addChild(icon);
        }
        
        this.x = xpos;
        this.y = ypos;
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
    }
    
    public function setSize(w                            : Dynamic, h                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(icon != null))
        {
            _width = w;
            _height = h;
            
            icon.scaleX = icon.scaleY = Math.min(w / _sprWidth, h / _sprHeight);
            
            this.graphics.clear();
            this.graphics.lineStyle(1, 0, 0);
            this.graphics.beginFill(0, 0);
            this.graphics.drawRect(-(icon.width / 2), -(icon.height / 2), w, h);
            this.graphics.endFill();
        }
    }
    
    public function setColor(color                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(icon != null))
        {
            var newColorJ                            : Dynamic= as3hx.Compat.parseInt("0x" + StringTools.replace(color, "#", ""));
            if (as3hx.Compat.truthy(Math.isNaN(newColorJ) || newColorJ < 0))
            {
                newColorJ = 0;
            }
            var rgb                            : Dynamic= ColorUtil.hexToRgb(newColorJ);
            
            icon.transform.colorTransform = new ColorTransform((rgb.r / 255), (rgb.g / 255), (rgb.b / 255));
        }
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

