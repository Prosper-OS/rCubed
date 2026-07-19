package classes.ui;

import classes.RenderQuality;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Text extends Sprite
{
    public var useArea(get, set)                            : Dynamic;
    public var align(never, set)                            : Dynamic;
    public var textfield(get, never)                            : Dynamic;
    public var text(get, set)                            : Dynamic;
    public var fontColor(get, set)                            : Dynamic;
    public var fontSize(get, set)                            : Dynamic;

    public static inline var LEFT                            : Dynamic= "left";
    public static inline var CENTER                            : Dynamic= "center";
    public static inline var RIGHT                            : Dynamic= "right";
    
    private var _textTF                            : Dynamic;
    private var _textTFormat                            : Dynamic;
    private var _message                            : Dynamic;
    private var _width                            : Dynamic= -1;
    private var _height                            : Dynamic= 22.6;
    private var _fontSize                            : Dynamic;
    private var _fontColor                            : Dynamic;
    private var _useArea                            : Dynamic= false;
    private var _align                            : Dynamic= LEFT;
    private var _isUnicode                            : Dynamic= false;
    
    ///- Constructor
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0, message                            : Dynamic= "", fontSize                            : Dynamic= 12, fontColor                            : Dynamic= "#FFFFFF")
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
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
    
    public function setAreaParams(width                            : Dynamic, height                            : Dynamic, align                            : Dynamic= LEFT) : Void
    {
        _width = width;
        _height = height;
        _align = align;
        _useArea = true;
        draw();
    }
    
    override private function set_width(nW                            : Dynamic) : Float
    {
        _width = nW;
        _useArea = true;
        draw();
        return nW;
    }
    
    override private function set_height(nH                            : Dynamic) : Float
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
    
    private function set_useArea(inBool                            : Dynamic) : Bool
    {
        _useArea = inBool;
        draw();
        return inBool;
    }
    
    private function set_align(inString                            : Dynamic) : String
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
    
    private function set_text(value                            : Dynamic) : String
    {
        if (as3hx.Compat.truthy(_message != value))
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
    
    private function set_fontColor(value                            : Dynamic) : String
    {
        _fontColor = value;
        draw();
        return value;
    }
    
    private function get_fontSize() : Int
    {
        return as3hx.Compat.parseInt(_fontSize);
    }
    
    private function set_fontSize(value                            : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(_fontSize != value))
        {
            _fontSize = value;
            draw();
        }
        return value;
    }
    
    private function html() : String
    {
        var fnt                            : Dynamic= (isUnicode(_message)) ? Fonts.BASE_FONT_CJK : Fonts.BASE_FONT;
        return "<font face=\"" + fnt + "\" color=\"" + _fontColor + "\" size=\"" + _fontSize + "\"><b>" + _message + "</b></font>";
    }
    
    private function draw() : Void
    {
        _textTF.htmlText = html();
        
        if (as3hx.Compat.truthy(_useArea)) {
this.graphics.clear();
            //this.graphics.lineStyle(1, Math.random() * 0xFFFFFF, 1);
            this.graphics.beginFill(0, 0);
            this.graphics.drawRect(0, 0, _width, _height);
            this.graphics.endFill();
            
            //- Auto Center Y axis.
            if (as3hx.Compat.truthy(_width > 0)) {
_textTF.scaleX = _textTF.scaleY = 1;
                if (as3hx.Compat.truthy(_textTF.width > _width))
                {
                    _textTF.scaleX = _textTF.scaleY = _width / _textTF.width;
                }
            }
            _textTF.y = ((_height - _textTF.height) / 2);
            
            //- Text Alignment to Area
            if (as3hx.Compat.truthy(_align == LEFT))
            {
                _textTF.x = 0;
            }
            else if (as3hx.Compat.truthy(_align == CENTER))
            {
                _textTF.x = ((_width - _textTF.width) / 2);
            }
            else if (as3hx.Compat.truthy(_align == RIGHT))
            {
                _textTF.x = (_width - _textTF.width);
            }
        }
    }
    
    public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_textTF != null))
        {
            this.removeChild(_textTF);
            _textTF = null;
        }
        _textTF = null;
    }
    
    public static function isUnicode(str                            : Dynamic) : Bool
    {
        return !((new as3hx.Compat.Regex('^[\\x20-\\x7E]*$', "")).test(str));
    }
}

