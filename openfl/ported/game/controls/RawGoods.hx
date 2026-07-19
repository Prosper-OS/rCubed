package game.controls;

import classes.RenderQuality;
import classes.ui.BoxCheck;
import classes.ui.Text;
import com.flashfla.utils.NumberUtil;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import game.GameOptions;

class RawGoods extends GameControl
{
    public var alignment(never, set) : String;

    private var options : GameOptions;
    private var colors : Float;
    private var field : TextField;
    public var lastText : String;
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        // Copy Raw Goods Colors
        colors = options.rawGoodsColor;
        
        field = new TextField();
        field.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 30, colors, true);
        field.antiAliasType = AntiAliasType.ADVANCED;
        field.embedFonts = true;
        field.selectable = false;
        field.autoSize = TextFieldAutoSize.LEFT;
        field.x = 0;
        field.y = 0;
        field.text = "0.0";
        addChild(field);
        RenderQuality.cacheDisplayObject(field);
        
        lastText = field.text;
    }
    
    public function update(raw_goods : Float) : Void
    {
        field.text = Std.string(NumberUtil.numberFormat(raw_goods, 1, true));
        lastText = field.text;
    }
    
    public function updateFromPA(good : Int, average : Int, miss : Int, boo : Int) : Void
    {
        field.text = Std.string(NumberUtil.numberFormat(good + (average * 1.8) + (miss * 2.4) + (boo * 0.2), 1, true));
        lastText = field.text;
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
        var self : RawGoods = this;
        
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
        return GameLayoutManager.LAYOUT_RAWGOODS;
    }
}

