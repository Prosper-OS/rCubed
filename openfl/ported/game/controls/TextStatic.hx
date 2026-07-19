package game.controls;

import classes.RenderQuality;
import classes.ui.BoxCheck;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

class TextStatic extends GameControl
{
    private static var e_changeHandler                    : Dynamic;
    public var alignment(never, set)                       : Dynamic;

    public var field                       : Dynamic;
    public var lastText                       : Dynamic;
    
    public function new(text                       : Dynamic, parent                       : Dynamic, color                       : Dynamic= 0x0098CB, size                       : Dynamic= 17)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        field = new TextField();
        field.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, size, color, true);
        field.antiAliasType = AntiAliasType.ADVANCED;
        field.embedFonts = true;
        field.selectable = false;
        field.autoSize = TextFieldAutoSize.LEFT;
        field.x = field.y = 0;  // Fixes Bug  
        field.htmlText = text;
        addChild(field);
        RenderQuality.cacheDisplayObject(field);
        
        lastText = field.text;
    }
    
    public function update(str                       : Dynamic) : Void
    {
        field.htmlText = str;
        lastText = field.htmlText;
    }
    
    private function set_alignment(value                       : Dynamic) : String
    {
        field.htmlText = "";
        field.autoSize = TextFieldAutoSize.NONE;
        field.x = field.y = field.width = 0;
        
        field.autoSize = value;
        field.htmlText = lastText;
        return value;
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self                       : Dynamic= this;
        
        var out                       : Dynamic= super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alignment"));
        out.cy += 24;
        
        var checkAlignLeft                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignLeft.checked = (field.autoSize == "left");
        new Text(out, 30, out.cy, _lang.string("editor_component_left"));
        out.cy += 22;
        
        var checkAlignCenter                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignCenter.checked = (field.autoSize == "center");
        new Text(out, 30, out.cy, _lang.string("editor_component_center"));
        out.cy += 22;
        
        var checkAlignRight                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignRight.checked = (field.autoSize == "right");
        new Text(out, 30, out.cy, _lang.string("editor_component_right"));
        out.cy += 22;
        
        e_changeHandler = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(e.target == checkAlignLeft))
            {
                checkAlignLeft.checked = true;
                checkAlignCenter.checked = checkAlignRight.checked = false;
                Reflect.setField(editorLayout, "alignment", "left");
                self.alignment = Reflect.field(editorLayout, "alignment");
            }
            if (as3hx.Compat.truthy(e.target == checkAlignCenter))
            {
                checkAlignCenter.checked = true;
                checkAlignLeft.checked = checkAlignRight.checked = false;
                Reflect.setField(editorLayout, "alignment", "center");
                self.alignment = Reflect.field(editorLayout, "alignment");
            }
            if (as3hx.Compat.truthy(e.target == checkAlignRight))
            {
                checkAlignRight.checked = true;
                checkAlignLeft.checked = checkAlignCenter.checked = false;
                Reflect.setField(editorLayout, "alignment", "right");
                self.alignment = Reflect.field(editorLayout, "alignment");
            }
        }
        
        return out;
    }
    
    override private function get_id() : String
    {
        return "text_static";
    }
}

