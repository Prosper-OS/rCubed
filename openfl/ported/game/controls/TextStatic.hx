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
    public var alignment(never, set) : String;

    public var field : TextField;
    public var lastText : String;
    
    public function new(text : String, parent : DisplayObjectContainer, color : Float = 0x0098CB, size : Int = 17)
    {
        super();
        if (parent != null)
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
    
    public function update(str : String) : Void
    {
        field.htmlText = str;
        lastText = field.htmlText;
    }
    
    private function set_alignment(value : String) : String
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
        var self : TextStatic = this;
        
        var out : GameControlEditor = super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alignment"));
        out.cy += 24;
        
        var checkAlignLeft : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignLeft.checked = (field.autoSize == "left");
        new Text(out, 30, out.cy, _lang.string("editor_component_left"));
        out.cy += 22;
        
        var checkAlignCenter : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignCenter.checked = (field.autoSize == "center");
        new Text(out, 30, out.cy, _lang.string("editor_component_center"));
        out.cy += 22;
        
        var checkAlignRight : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 3, e_changeHandler);
        checkAlignRight.checked = (field.autoSize == "right");
        new Text(out, 30, out.cy, _lang.string("editor_component_right"));
        out.cy += 22;
        
        var e_changeHandler : Event->Void = function(e : Event) : Void
        {
            if (e.target == checkAlignLeft)
            {
                checkAlignLeft.checked = true;
                checkAlignCenter.checked = checkAlignRight.checked = false;
                Reflect.setField(editorLayout, "alignment", "left");
                self.alignment = Reflect.field(editorLayout, "alignment");
            }
            if (e.target == checkAlignCenter)
            {
                checkAlignCenter.checked = true;
                checkAlignLeft.checked = checkAlignRight.checked = false;
                Reflect.setField(editorLayout, "alignment", "center");
                self.alignment = Reflect.field(editorLayout, "alignment");
            }
            if (e.target == checkAlignRight)
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

