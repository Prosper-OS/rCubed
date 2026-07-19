package game.controls;

import assets.gameplay.BarBottomNormal;
import assets.gameplay.BarBottomSideways;
import classes.ui.BoxCheck;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import game.GameOptions;

class BarBottom extends GameControl
{
    private static var e_changeHandler                    : Dynamic;
    public var type(never, set)                       : Dynamic;

    private var options                       : Dynamic;
    
    public var lastType                       : Dynamic= 0;
    
    public var type0                       : Dynamic;
    public var type1                       : Dynamic;
    
    public function new(options                       : Dynamic, parent                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        type0 = new BarBottomNormal();
        type1 = new BarBottomSideways();
    }
    
    private function set_type(val                       : Dynamic) : Float
    {
        this.removeChildren();
        
        if (as3hx.Compat.truthy(val == 1))
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
        return GameLayoutManager.LAYOUT_BAR_BOTTOM;
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self                       : Dynamic= this;
        
        var out                       : Dynamic= super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alt_layout"));
        var checkLayout                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLayout.checked = (lastType == 1);
        
        out.cy += 42;
        
        e_changeHandler = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(e.target == checkLayout))
            {
                checkLayout.checked = !checkLayout.checked;
                Reflect.setField(editorLayout, "type", (checkLayout.checked) ? 1 : 0);
                self.type = Reflect.field(editorLayout, "type");
            }
        }
        
        return out;
    }
}

