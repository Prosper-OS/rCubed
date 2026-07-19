package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class ScrollPane extends Sprite implements IScrollPane
{
    public var scrollFactorVertical(get, never) : Float;

    private var _width : Float;
    private var _height : Float;
    
    public var content : ScrollPaneContent;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Int = 0, height : Int = 0, listener : Dynamic = null)
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
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.MOUSE_WHEEL, listener);
        }
    }
    
    public function dispose() : Void
    {
        if (_listener != null)
        {
            this.removeEventListener(MouseEvent.MOUSE_WHEEL, _listener);
        }
        
        if (content != null)
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
        return Math.max(Math.min(height / content.height, 1), 0) || 0;
    }
}

