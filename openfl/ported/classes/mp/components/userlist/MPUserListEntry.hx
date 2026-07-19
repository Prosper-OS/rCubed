package classes.mp.components.userlist;

import classes.Language;
import classes.mp.MPUser;
import classes.ui.Text;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class MPUserListEntry extends Sprite
{
    private static var _lang : Language = Language.instance;
    
    public static inline var ENTRY_WIDTH : Int = 219;
    public static inline var ENTRY_HEIGHT : Int = 27;
    
    public var user : MPUser;
    
    private var title : Text;
    
    public var index : Int = 0;
    public var isStale : Bool = false;
    
    public function new()
    {
        super();
        // Text
        title = new Text(this, 5, 0, "???", 11, "#FFFFFF");
        title.setAreaParams(ENTRY_WIDTH, ENTRY_HEIGHT);
        title.cacheAsBitmap = true;
        
        this.mouseChildren = false;
        this.buttonMode = true;
        
        this.addEventListener(MouseEvent.MOUSE_OVER, e_onOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, e_onOut);
        
        draw(false);
    }
    
    public function draw(hover : Bool) : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, ENTRY_HEIGHT);
        this.graphics.lineTo(ENTRY_WIDTH, ENTRY_HEIGHT);
        
        this.graphics.lineStyle(0, 0x000000, 0);
        this.graphics.beginFill(0xFFFFFF, (hover) ? 0.1 : 0);
        this.graphics.drawRect(0, 0, ENTRY_WIDTH, ENTRY_HEIGHT);
        this.graphics.endFill();
    }
    
    public function setData(item : MPUser) : Void
    {
        user = item;
        title.text = user.userLabelHTML;
    }
    
    public function clear() : Void
    {
        user = null;
    }
    
    private function e_onOver(event : MouseEvent) : Void
    {
        draw(true);
    }
    
    private function e_onOut(event : MouseEvent) : Void
    {
        draw(false);
    }
}

