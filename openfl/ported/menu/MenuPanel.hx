package menu;

import openfl.display.Sprite;

class MenuPanel extends Sprite
{
    private var _listeners : Array<Dynamic> = [];
    public var my_Parent : MenuPanel;
    public var current_popup : MenuPanel;
    public var hasInit : Bool = false;
    
    public function new(myParent : MenuPanel)
    {
        this.my_Parent = myParent;
        super();
    }
    
    public function switchTo(_panel : String) : Bool
    {
        if (stage != null && this.stage != null)
        {
            stage.focus = this.stage;
        }
        
        return my_Parent.switchTo(_panel);
    }
    
    public function addPopup(_panel : Dynamic, newLayer : Bool = false) : Void
    {
        return my_Parent.addPopup(_panel, newLayer);
    }
    
    public function removePopup() : Void
    {
        return my_Parent.removePopup();
    }
    
    // Init status depended on use of switchTo in init function. If the function calls a switchTo, return false here.
    public function init() : Bool
    {
        return true;
    }
    
    public function dispose() : Void
    {
    }
    
    public function stageAdd() : Void
    {
    }
    
    public function stageRemove() : Void
    {
    }
    
    public function draw() : Void
    {
    }
    
    override public function addEventListener(type : String, listener : Dynamic, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        _listeners.push([type, listener, useCapture]);
        // trace("Added Listener:", this, _listeners.length - 1, type);
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    override public function removeEventListener(type : String, listener : Dynamic, useCapture : Bool = false) : Void
    {
        for (i in 0..._listeners.length)
        {
            if (_listeners[i][0] == type && _listeners[i][1] == listener && _listeners[i][2] == useCapture)
            {
                _listeners.splice(i, 1);
            }
        }
        super.removeEventListener(type, listener, useCapture);
    }
}

