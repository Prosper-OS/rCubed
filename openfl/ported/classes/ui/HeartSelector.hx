package classes.ui;

import assets.menu.icons.fa.IconHeartEmpty;
import assets.menu.icons.fa.IconHeartFull;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class HeartSelector extends Sprite
{
    public var checked(get, set)                             : Dynamic;

    private var outlineSprite                             : Dynamic;
    private var fillSprite                             : Dynamic;
    private var _checked                             : Dynamic= false;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, isActive                             : Dynamic= true)
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
    
    private function init(isActive                             : Dynamic) : Void
    {
        this.mouseChildren = false;
        if (as3hx.Compat.truthy(isActive))
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
    
    private function e_mouseClick(e                             : Dynamic) : Void
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
    
    private function set_checked(val                             : Dynamic) : Bool
    {
        _checked = val;
        updateSprites();
        return val;
    }
}

