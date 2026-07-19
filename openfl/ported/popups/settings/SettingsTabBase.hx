package popups.settings;

import classes.ui.MouseTooltip;
import classes.ui.ScrollPaneContent;
import classes.ui.Text;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import game.GameOptions;

class SettingsTabBase
{
    public var name(get, never)                       : Dynamic;

    public static var DEFAULT_OPTIONS                       : Dynamic= new GameOptions();
    
    public var parent                       : Dynamic;
    public var container                       : Dynamic;
    private var hover_message                       : Dynamic;
    
    public var judgeTitles                       : Dynamic= ["amazing", "perfect", "good", "average", "miss", "boo"];
    public var receptorRotations                       : Dynamic= [1, 0, 2, -1];
    
    public function new(settingWindow                       : Dynamic)
    {
        this.parent = settingWindow;
    }
    
    private function get_name() : String
    {
        return null;
    }
    
    public function openTab() : Void
    {
    }
    
    public function closeTab() : Void
    {
        hideTooltip();
        
        var index                       : Dynamic= as3hx.Compat.parseInt(container.numChildren - 1);
        while (as3hx.Compat.truthy(index >= 0))
        {
            var olditem                       : Dynamic= container.getChildAt(index);
            olditem.removeEventListener(MouseEvent.CLICK, clickHandler);
            olditem.removeEventListener(Event.CHANGE, changeHandler);
            index--;
        }
    }
    
    public function setValues() : Void
    {
    }
    
    public function clickHandler(e                       : Dynamic) : Void
    {
    }
    
    public function changeHandler(e                       : Dynamic) : Void
    {
    }
    
    public function drawSeperator(container                       : Dynamic, x                       : Dynamic, w                       : Dynamic, y                       : Dynamic, a                       : Dynamic= 0, b                       : Dynamic= 0) : Int
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(x, y + 10 + a);
        container.graphics.lineTo(x + w, y + 10 + a);
        return as3hx.Compat.parseInt(20 + a + b);
    }
    
    public function setTextMaxWidth(maxWidth                       : Dynamic) : Void
    {
        for (i in 0...container.numChildren)
        {
            var chd                       : Dynamic= container.getChildAt(i);
            if (as3hx.Compat.truthy(Std.is(chd, Text)))
            {
                chd.width = maxWidth;
            }
        }
    }
    
    public function displayToolTip(tx                       : Dynamic, ty                       : Dynamic, text                       : Dynamic, align                       : Dynamic= "left") : Void
    {
        if (as3hx.Compat.truthy(hover_message == null))
        {
            hover_message = new MouseTooltip();
        }
        hover_message.message = text;
        
        var messagePoint                       : Dynamic= parent.globalToLocal(parent.pane.content.localToGlobal(new Point(tx, ty)));
        
        switch (align)
        {
            /* covers case "left": */
            default:
                hover_message.x = messagePoint.x;
                hover_message.y = messagePoint.y;
            case "right":
                hover_message.x = messagePoint.x - hover_message.width;
                hover_message.y = messagePoint.y;
        }
        
        parent.addChild(hover_message);
    }
    
    public function hideTooltip() : Void
    {
        if (as3hx.Compat.truthy(hover_message != null && parent.contains(hover_message)))
        {
            parent.removeChild(hover_message);
        }
    }
}

