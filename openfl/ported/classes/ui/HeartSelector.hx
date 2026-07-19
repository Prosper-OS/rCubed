package classes.ui;

import assets.menu.icons.fa.IconHeartEmpty;
import assets.menu.icons.fa.IconHeartFull;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class HeartSelector extends Sprite
{
    public var checked(get, set) : Bool;

    private var outlineSprite : UIIcon;
    private var fillSprite : UIIcon;
    private var _checked : Bool = false;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, isActive : Bool = true)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        init(isActive);
    }
    
    private function init(isActive : Bool) : Void
    {
        this.mouseChildren = false;
        if (isActive)
        {
            this.buttonMode = true;
            this.useHandCursor = true;
            this.addEventListener(MouseEvent.CLICK, e_mouseClick);
        }
        
        fillSprite = new UIIcon(this, new IconHeartFull(), 16, 16);
        fillSprite.setSize(32, 32);
        fillSprite.setColor("#f7b9e4");
        
        outlineSprite = new UIIcon(this, new IconHeartEmpty(), 16, 16);
        outlineSprite.setSize(32, 32);
        
        // Draw Mouse Background
        this.graphics.beginFill(0xff0000, 0);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
    }
    
    private function e_mouseClick(e : MouseEvent) : Void
    {
        _checked = !_checked;
        updateSprites();
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function updateSprites() : Void
    {
        fillSprite.visible = _checked;
    }
    
    private function get_checked() : Bool
    {
        return _checked;
    }
    
    private function set_checked(val : Bool) : Bool
    {
        _checked = val;
        updateSprites();
        return val;
    }
}

