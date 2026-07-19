package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class ScrollPane extends Sprite implements IScrollPane
{
    public var scrollFactorVertical(get, never)                             : Dynamic;

    private var _width                             : Dynamic;
    private var _height                             : Dynamic;
    
    public var content                             : Dynamic;
    
    private var _listener                             : Dynamic= null;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, width                             : Dynamic= 0, height                             : Dynamic= 0, listener                             : Dynamic= null)
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
        this.scrollRect = new Rectangle(0, 0, _width, _height);
        
        //- Draw Filler
        this.graphics.beginFill(0xFF0000, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        //- Build Content Pane
        content = new ScrollPaneContent();
        
        //- Add Content Pane
        this.addChild(content);
        
        //- Set click event listener
        if (as3hx.Compat.truthy(listener != null))
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.MOUSE_WHEEL, listener);
        }
    }
    
    public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_listener != null))
        {
            this.removeEventListener(MouseEvent.MOUSE_WHEEL, _listener);
        }
        
        if (as3hx.Compat.truthy(content != null))
        {
            content.removeChildren();
            this.removeChild(content);
            content = null;
        }
    }
    
    public function clear() : Void
    {
        content.clear();
    }
    
    public function update() : Void
    {
        content.update(content.y * -1, _height);
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
        
        content.y = -((content.height - _height) * val);
        update();
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    /**
     * Gets the current vertical scroll factor.
     * Scroll factor is the percent of the height the scrollpane is compared to the overall content height.
     */
    private function get_scrollFactorVertical() : Float
    {
        return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(height / content.height, 1), 0), 0));
    }
}

