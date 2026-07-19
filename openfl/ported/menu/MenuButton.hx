package menu;

import classes.ui.BoxButton;
import openfl.display.DisplayObjectContainer;

class MenuButton extends BoxButton
{
    public var panel : String;
    public var index : String;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, wid : Float = 0, message : String = "", isActive : Bool = false, listener : Dynamic = null)
    {
        super(parent, xpos, 0, wid, 28, message, 12, listener);
        super.active = isActive;
    }
}

