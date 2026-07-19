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
    public var name(get, never) : String;

    private static var DEFAULT_OPTIONS : GameOptions = new GameOptions();
    
    private var parent : SettingsWindow;
    public var container : ScrollPaneContent;
    private var hover_message : MouseTooltip;
    
    private var judgeTitles : Array<Dynamic> = ["amazing", "perfect", "good", "average", "miss", "boo"];
    private var receptorRotations : Array<Dynamic> = [1, 0, 2, -1];
    
    public function new(settingWindow : SettingsWindow)
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
        
        var index : Int = as3hx.Compat.parseInt(container.numChildren - 1);
        while (index >= 0)
        {
            var olditem : DisplayObject = container.getChildAt(index);
            olditem.removeEventListener(MouseEvent.CLICK, clickHandler);
            olditem.removeEventListener(Event.CHANGE, changeHandler);
            index--;
        }
    }
    
    public function setValues() : Void
    {
    }
    
    public function clickHandler(e : MouseEvent) : Void
    {
    }
    
    public function changeHandler(e : Event) : Void
    {
    }
    
    public function drawSeperator(container : ScrollPaneContent, x : Int, w : Int, y : Int, a : Int = 0, b : Int = 0) : Int
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(x, y + 10 + a);
        container.graphics.lineTo(x + w, y + 10 + a);
        return as3hx.Compat.parseInt(20 + a + b);
    }
    
    private function setTextMaxWidth(maxWidth : Float) : Void
    {
        for (i in 0...container.numChildren)
        {
            var chd : Dynamic = container.getChildAt(i);
            if (Std.is(chd, Text))
            {
                chd.width = maxWidth;
            }
        }
    }
    
    public function displayToolTip(tx : Float, ty : Float, text : String, align : String = "left") : Void
    {
        if (hover_message == null)
        {
            hover_message = new MouseTooltip();
        }
        hover_message.message = text;
        
        var messagePoint : Point = parent.globalToLocal(parent.pane.content.localToGlobal(new Point(tx, ty)));
        
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
        if (hover_message != null && parent.contains(hover_message))
        {
            parent.removeChild(hover_message);
        }
    }
}

