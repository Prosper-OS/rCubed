package classes.mp;

import classes.Language;
import classes.ui.UILockWait;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;

class MPView extends Sprite
{
    public var _gvars                             : Dynamic= GlobalVariables.instance;
    public var _mp                             : Dynamic= Multiplayer.instance;
    public var _lang                             : Dynamic= Language.instance;
    
    public var _lock                             : Dynamic;
    
    public function new(parent                             : Dynamic, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0)
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
    
    public function onKeyInput(e                             : Dynamic) : Void
    {
    }
    
    public function onSelect() : Void
    {
    }
    
    public function onExit() : Void
    {
    }
    
    public function setBlocker(enabled                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(enabled && _lock == null))
        {
            _lock = new UILockWait(parent.stage, true);
        }
        else if (as3hx.Compat.truthy(!enabled && _lock != null))
        {
            _lock.remove();
            _lock = null;
        }
    }
}

