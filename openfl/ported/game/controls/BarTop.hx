package game.controls;

import assets.gameplay.BarTopNormal;
import assets.gameplay.BarTopSideways;
import classes.ui.BoxCheck;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import game.GameOptions;

class BarTop extends GameControl
{
    public var type(never, set) : Float;

    private var options : GameOptions;
    
    public var lastType : Int = 0;
    
    public var type0 : BarTopNormal;
    public var type1 : BarTopSideways;
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        type0 = new BarTopNormal();
        type1 = new BarTopSideways();
    }
    
    private function set_type(val : Float) : Float
    {
        this.removeChildren();
        
        if (val == 1)
        {
            addChild(type1);
            lastType = 1;
        }
        else
        {
            addChild(type0);
            lastType = 0;
        }
        return val;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_BAR_TOP;
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self : BarTop = this;
        
        var out : GameControlEditor = super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alt_layout"));
        var checkLayout : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLayout.checked = (lastType == 1);
        
        out.cy += 42;
        
        var e_changeHandler : Event->Void = function(e : Event) : Void
        {
            if (e.target == checkLayout)
            {
                checkLayout.checked = !checkLayout.checked;
                Reflect.setField(editorLayout, "type", (checkLayout.checked) ? 1 : 0);
                self.type = Reflect.field(editorLayout, "type");
            }
        }
        
        return out;
    }
}

