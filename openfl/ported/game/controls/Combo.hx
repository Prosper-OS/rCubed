package game.controls;

import classes.RenderQuality;
import classes.ui.BoxCheck;
import classes.ui.Text;
import com.flashfla.utils.ColorUtil;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import game.GameOptions;

class Combo extends GameControl
{
    public var alignment(never, set) : String;

    private var options : GameOptions;
    
    private var colors : Array<Float>;
    private var colors_dark : Array<Float>;
    private var colors_enabled : Array<Bool>;
    
    private var field : TextField;
    private var fieldShadow : TextField;
    
    private var lastText : String;
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        // Copy Combo Colors
        colors = new Array<Float>();
        colors_dark = new Array<Float>();
        for (i in 0...options.comboColors.length)
        {
            colors[i] = options.comboColors[i];
            colors_dark[i] = ColorUtil.darkenColor(options.comboColors[i], 0.5);
        }
        
        // Copy Enabled Colors
        colors_enabled = new Array<Bool>();
        for (i in 0...options.enableComboColors.length)
        {
            colors_enabled[i] = options.enableComboColors[i];
        }
        
        fieldShadow = new TextField();
        fieldShadow.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 50, colors_dark[2], true);
        fieldShadow.antiAliasType = AntiAliasType.ADVANCED;
        fieldShadow.embedFonts = true;
        fieldShadow.selectable = false;
        fieldShadow.autoSize = TextFieldAutoSize.LEFT;
        fieldShadow.x = 2;
        fieldShadow.y = 2;
        fieldShadow.text = "0";
        addChild(fieldShadow);
        RenderQuality.cacheDisplayObject(fieldShadow);
        
        field = new TextField();
        field.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 50, colors[2], true);
        field.antiAliasType = AntiAliasType.ADVANCED;
        field.embedFonts = true;
        field.selectable = false;
        field.autoSize = TextFieldAutoSize.LEFT;
        field.x = 0;
        field.y = 0;
        field.text = "0";
        addChild(field);
        RenderQuality.cacheDisplayObject(field);
        
        lastText = field.text;
        
        if (options != null && options.isAutoplay && !options.isEditor)
        {
            field.textColor = 0xD00000;
            fieldShadow.textColor = 0x5B0000;
        }
    }
    
    public function update(combo : Int, amazing : Int = 0, perfect : Int = 0, good : Int = 0, average : Int = 0, miss : Int = 0, boo : Int = 0, raw_goods : Float = 0) : Void
    {
        field.text = Std.string(combo);
        fieldShadow.text = Std.string(combo);
        
        lastText = field.text;
        
        /* colors[i]:
           [0] = Normal,
           [1] = FC,
           [2] = AAA,
           [3] = SDG,
           [4] = Black Flag,
           [5] = Average Flag,
           [6] = Boo Flag,
           [7] = Miss Flag,
           [8] = Raw Goods
         */
        
        if (options != null && (!options.isAutoplay || options.isEditor))
        {
            if (colors_enabled[2] != null && good + average + boo + miss == 0) {
{
                    field.textColor = colors[2];
                    fieldShadow.textColor = colors_dark[2];
                }
            }
            else if (colors_enabled[6] != null && boo == 1 && good + average + miss == 0) {
{
                    field.textColor = colors[6];
                    fieldShadow.textColor = colors_dark[6];
                }
            }
            else if (colors_enabled[4] != null && good == 1 && average + boo + miss == 0) {
{
                    field.textColor = colors[4];
                    fieldShadow.textColor = colors_dark[4];
                }
            }
            else if (colors_enabled[5] != null && average == 1 && good + boo + miss == 0) {
{
                    field.textColor = colors[5];
                    fieldShadow.textColor = colors_dark[5];
                }
            }
            else if (colors_enabled[7] != null && miss == 1 && good + average + boo == 0) {
{
                    field.textColor = colors[7];
                    fieldShadow.textColor = colors_dark[7];
                }
            }
            else if (colors_enabled[8] != null && raw_goods >= options.rawGoodTracker) {
{
                    field.textColor = colors[8];
                    fieldShadow.textColor = colors_dark[8];
                }
            }
            else if (colors_enabled[3] != null && raw_goods < 10) {
{
                    field.textColor = colors[3];
                    fieldShadow.textColor = colors_dark[3];
                }
            }
            else if (colors_enabled[1] != null && miss == 0) {
{
                    field.textColor = colors[1];
                    fieldShadow.textColor = colors_dark[1];
                }
            }
            // Display blue combo text
            else
            {
                
                {
                    field.textColor = colors[0];
                    fieldShadow.textColor = colors_dark[0];
                }
            }
        }
    }
    
    private function set_alignment(value : String) : String
    {
        field.htmlText = "";
        field.autoSize = TextFieldAutoSize.NONE;
        field.x = field.y = field.width = 0;
        
        field.autoSize = value;
        field.htmlText = lastText;
        
        fieldShadow.htmlText = "";
        fieldShadow.autoSize = TextFieldAutoSize.NONE;
        fieldShadow.x = fieldShadow.y = fieldShadow.width = 0;
        
        fieldShadow.autoSize = value;
        fieldShadow.htmlText = lastText;
        return value;
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self : Combo = this;
        
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
        return GameLayoutManager.LAYOUT_COMBO;
    }
}

