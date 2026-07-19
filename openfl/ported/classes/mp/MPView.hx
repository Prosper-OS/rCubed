package classes.mp;

import classes.Language;
import classes.ui.UILockWait;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;

class MPView extends Sprite
{
    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var _lock : UILockWait;
    
    public function new(parent : DisplayObjectContainer, xpos : Float = 0, ypos : Float = 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        parent.addChild(this);
    }
    
    public function build() : Void
    {
    }
    
    public function dispose() : Void
    {
    }
    
    public function onKeyInput(e : KeyboardEvent) : Void
    {
    }
    
    public function onSelect() : Void
    {
    }
    
    public function onExit() : Void
    {
    }
    
    public function setBlocker(enabled : Bool) : Void
    {
        if (enabled && _lock == null)
        {
            _lock = new UILockWait(parent.stage, true);
        }
        else if (!enabled && _lock != null)
        {
            _lock.remove();
            _lock = null;
        }
    }
}

