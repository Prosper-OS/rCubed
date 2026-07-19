package classes.ui;

import classes.RenderQuality;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Text extends Sprite
{
    public var useArea(get, set) : Bool;
    public var align(never, set) : String;
    public var textfield(get, never) : TextField;
    public var text(get, set) : String;
    public var fontColor(get, set) : String;
    public var fontSize(get, set) : Int;

    public static inline var LEFT : String = "left";
    public static inline var CENTER : String = "center";
    public static inline var RIGHT : String = "right";
    
    private var _textTF : TextField;
    private var _textTFormat : TextFormat;
    private var _message : String;
    private var _width : Float = -1;
    private var _height : Float = 22.6;
    private var _fontSize : Float;
    private var _fontColor : String;
    private var _useArea : Bool = false;
    private var _align : String = LEFT;
    private var _isUnicode : Bool = false;
    
    ///- Constructor
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, message : Dynamic = "", fontSize : Int = 12, fontColor : String = "#FFFFFF")
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        this._message = Std.string(message);
        this._fontSize = fontSize;
        this._fontColor = fontColor;
        this.mouseChildren = false;
        this.mouseEnabled = false;
        
        // Build Text
        _textTF = new TextField();
        _textTF.selectable = false;
        _textTF.embedFonts = true;
        _textTF.antiAliasType = AntiAliasType.ADVANCED;
        _textTF.autoSize = "left";
        //_textTF.border = true;
        //_textTF.borderColor = 0xFF0000;
        this.addChild(_textTF);
        RenderQuality.cacheDisplayObject(_textTF);
        
        draw();
    }
    
    public function setAreaParams(width : Float, height : Float, align : String = LEFT) : Void
    {
        _width = width;
        _height = height;
        _align = align;
        _useArea = true;
        draw();
    }
    
    override private function set_width(nW : Float) : Float
    {
        _width = nW;
        _useArea = true;
        draw();
        return nW;
    }
    
    override private function set_height(nH : Float) : Float
    {
        _height = nH;
        _useArea = true;
        draw();
        return nH;
    }
    
    private function get_useArea() : Bool
    {
        return _useArea;
    }
    
    private function set_useArea(inBool : Bool) : Bool
    {
        _useArea = inBool;
        draw();
        return inBool;
    }
    
    private function set_align(inString : String) : String
    {
        _align = inString;
        _useArea = true;
        draw();
        return inString;
    }
    
    private function get_textfield() : TextField
    {
        return _textTF;
    }
    
    private function get_text() : String
    {
        return _message;
    }
    
    private function set_text(value : String) : String
    {
        if (_message != value)
        {
            _message = value;
            draw();
        }
        return value;
    }
    
    private function get_fontColor() : String
    {
        return _fontColor;
    }
    
    private function set_fontColor(value : String) : String
    {
        _fontColor = value;
        draw();
        return value;
    }
    
    private function get_fontSize() : Int
    {
        return as3hx.Compat.parseInt(_fontSize);
    }
    
    private function set_fontSize(value : Int) : Int
    {
        if (_fontSize != value)
        {
            _fontSize = value;
            draw();
        }
        return value;
    }
    
    private function html() : String
    {
        var fnt : String = (isUnicode(_message)) ? Fonts.BASE_FONT_CJK : Fonts.BASE_FONT;
        return "<font face=\"" + fnt + "\" color=\"" + _fontColor + "\" size=\"" + _fontSize + "\"><b>" + _message + "</b></font>";
    }
    
    private function draw() : Void
    {
        _textTF.htmlText = html();
        
        if (_useArea) {
this.graphics.clear();
            //this.graphics.lineStyle(1, Math.random() * 0xFFFFFF, 1);
            this.graphics.beginFill(0, 0);
            this.graphics.drawRect(0, 0, _width, _height);
            this.graphics.endFill();
            
            //- Auto Center Y axis.
            if (_width > 0) {
_textTF.scaleX = _textTF.scaleY = 1;
                if (_textTF.width > _width)
                {
                    _textTF.scaleX = _textTF.scaleY = _width / _textTF.width;
                }
            }
            _textTF.y = ((_height - _textTF.height) / 2);
            
            //- Text Alignment to Area
            if (_align == LEFT)
            {
                _textTF.x = 0;
            }
            else if (_align == CENTER)
            {
                _textTF.x = ((_width - _textTF.width) / 2);
            }
            else if (_align == RIGHT)
            {
                _textTF.x = (_width - _textTF.width);
            }
        }
    }
    
    public function dispose() : Void
    {
        if (_textTF != null)
        {
            this.removeChild(_textTF);
            _textTF = null;
        }
        _textTF = null;
    }
    
    public static function isUnicode(str : String) : Bool
    {
        return !((new as3hx.Compat.Regex('^[\\x20-\\x7E]*$', "")).test(str));
    }
}

