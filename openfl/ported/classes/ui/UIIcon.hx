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
    public var icon : DisplayObject;
    private var _sprWidth : Float = 1;
    private var _sprHeight : Float = 1;
    private var _width : Float = 0;
    private var _height : Float = 0;
    
    public function new(parent : DisplayObjectContainer = null, sprite : DisplayObject = null, xpos : Float = 0, ypos : Float = 0)
    {
        super();
        mouseChildren = false;
        
        if (sprite != null)
        {
            icon = sprite;
            _sprWidth = sprite.width;
            _sprHeight = sprite.height;
            addChild(icon);
        }
        
        this.x = xpos;
        this.y = ypos;
        if (parent != null)
        {
            parent.addChild(this);
        }
    }
    
    public function setSize(w : Float, h : Float) : Void
    {
        if (icon != null)
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
    
    public function setColor(color : String) : Void
    {
        if (icon != null)
        {
            var newColorJ : Float = as3hx.Compat.parseInt("0x" + StringTools.replace(color, "#", ""));
            if (Math.isNaN(newColorJ) || newColorJ < 0)
            {
                newColorJ = 0;
            }
            var rgb : Dynamic = ColorUtil.hexToRgb(newColorJ);
            
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

