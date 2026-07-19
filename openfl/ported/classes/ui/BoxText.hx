package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFormat;

class BoxText extends Box
{
    public var text(get, set) : String;
    public var htmlText(get, set) : String;
    public var restrict(get, set) : String;
    public var autoSize(get, set) : String;
    public var selectable(get, set) : Bool;
    public var displayAsPassword(get, set) : Bool;
    public var textColor(get, set) : Int;
    public var focus(get, never) : Bool;
    public var field(get, never) : TextField;

    private var _textFormat : TextFormat = Constant.TEXT_FORMAT_UNICODE;
    private var _input : TextField;
    private var _isFocused : Bool = false;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Int = 100, height : Int = 20, textformat : TextFormat = null)
    {
        if (textformat != null)
        {
            _textFormat = textformat;
        }
        
        super(parent, xpos, ypos, false, false);
        setSize(width + 1, height + 1);
        
        init();
    }
    
    private function init() : Void
    {
        _input = new TextField();
        _input.width = width - 4;
        _input.type = "input";
        _input.embedFonts = true;
        _input.gridFitType = GridFitType.SUBPIXEL;
        _input.antiAliasType = AntiAliasType.ADVANCED;
        _input.defaultTextFormat = _textFormat;
        
        // Position Input within Box
        _input.text = "X";
        _input.height = Math.min(_input.textHeight + 4, height);
        _input.text = "";
        _input.x = 2;
        _input.y = Math.round(height / 2 - _input.height / 2) - 1;
        
        _input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
        _input.addEventListener(FocusEvent.FOCUS_OUT, onFocus);
        _input.addEventListener(Event.CHANGE, onChange);
        this.addChild(_input);
    }
    
    override public function dispose() : Void
    {
        super.dispose();
        _input.removeEventListener(FocusEvent.FOCUS_IN, onFocus);
        _input.removeEventListener(FocusEvent.FOCUS_OUT, onFocus);
        _input.removeEventListener(Event.CHANGE, onChange);
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Events
    private function onFocus(e : FocusEvent) : Void
    {
        _isFocused = (e.type == FocusEvent.FOCUS_IN);
        draw();
    }
    
    private function onChange(e : Event) : Void
    {
        this.dispatchEvent(e);
    }
    
    override private function get_highlight() : Bool
    {
        return _isFocused || super.highlight;
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    private function get_text() : String
    {
        return _input.text;
    }
    
    private function set_text(newString : String) : String
    {
        _input.text = newString;
        return newString;
    }
    
    private function get_htmlText() : String
    {
        return _input.htmlText;
    }
    
    private function set_htmlText(newString : String) : String
    {
        _input.htmlText = newString;
        return newString;
    }
    
    private function get_restrict() : String
    {
        return _input.restrict;
    }
    
    private function set_restrict(newString : String) : String
    {
        _input.restrict = newString;
        return newString;
    }
    
    private function get_autoSize() : String
    {
        return _input.autoSize;
    }
    
    private function set_autoSize(newString : String) : String
    {
        _input.x = (newString == "center") ? 4 : 0;
        _input.autoSize = newString;
        return newString;
    }
    
    private function get_selectable() : Bool
    {
        return _input.selectable;
    }
    
    private function set_selectable(newBool : Bool) : Bool
    {
        _input.type = (newBool) ? "input" : "dynamic";
        _input.selectable = newBool;
        return newBool;
    }
    
    private function get_displayAsPassword() : Bool
    {
        return _input.displayAsPassword;
    }
    
    private function set_displayAsPassword(newBool : Bool) : Bool
    {
        _input.displayAsPassword = newBool;
        return newBool;
    }
    
    private function get_textColor() : Int
    {
        return _input.textColor;
    }
    
    private function set_textColor(newint : Int) : Int
    {
        _input.textColor = newint;
        return newint;
    }
    
    private function get_focus() : Bool
    {
        return _isFocused;
    }
    
    private function get_field() : TextField
    {
        return _input;
    }
}

