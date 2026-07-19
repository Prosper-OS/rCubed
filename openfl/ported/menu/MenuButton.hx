package menu;

import classes.ui.BoxButton;
import openfl.display.DisplayObjectContainer;

class MenuButton extends BoxButton
{
    public var panel                       : Dynamic;
    public var index                       : Dynamic;
    
    public function new(parent                       : Dynamic= null, xpos                       : Dynamic= 0, wid                       : Dynamic= 0, message                       : Dynamic= "", isActive                       : Dynamic= false, listener                       : Dynamic= null)
    {
        super(parent, xpos, 0, wid, 28, message, 12, listener);
        super.active = isActive;
    }
}

