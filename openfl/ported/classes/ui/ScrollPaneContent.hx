package classes.ui;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class ScrollPaneContent extends Sprite
{
    private var doUpdate : Bool = false;
    private var _width : Float = -1;
    private var _height : Float = -1;
    
    private var _idx : Int;
    private var _child : DisplayObject;
    
    public function update(maskY : Float, maskHeight : Float) : Void
    {
        _idx = as3hx.Compat.parseInt(this.numChildren - 1);
        while (_idx >= 0)
        {
            _child = this.getChildAt(_idx);
            _child.visible = ((_child.y >= maskY || _child.y + _child.height >= maskY) && _child.y < maskY + maskHeight);
            _idx--;
        }
        
        _child = null;
        updateSizes();
    }
    
    /**
     * Add a display object to the content field.
     * Requires calling "scrollTo" or "update" on the ScrollPane to make children visible.
     * @param	child
     * @return
     */
    override public function addChild(child : DisplayObject) : DisplayObject
    {
        child.visible = false;
        return super.addChild(child);
    }
    
    override public function removeChild(child : DisplayObject) : DisplayObject
    {
        return super.removeChild(child);
    }
    
    public function updateSizes() : Void
    // account for elements not placed at 0.
    {
        
        var currentBounds : Rectangle = getBounds(this);
        
        _width = currentBounds.x + currentBounds.width;  //super.width;  
        _height = (currentBounds.y * 2) + currentBounds.height;
    }
    
    public function clear() : Void
    {
        this.removeChildren();
        _width = -1;
        _height = -1;
    }
    
    override private function get_width() : Float
    {
        if (_width == -1)
        {
            updateSizes();
        }
        return _width;
    }
    
    override private function get_height() : Float
    {
        if (_height == -1)
        {
            updateSizes();
        }
        return _height;
    }

    public function new()
    {
        super();
    }
}

