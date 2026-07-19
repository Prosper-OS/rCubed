package classes.ui;

import assets.settings.ColorPickerBMP;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

class ColorField extends Sprite
{
    public var color(get, set) : Int;

    
    public var key_name : String;
    
    private var _color : Int = 0x000000;
    private var _width : Float;
    private var _height : Float;
    
    private var _picker : Sprite;
    private var _bmp : Bitmap;
    private var _pickerColor : Int = 0x000000;
    private var _pickerColorExample : Sprite;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, defaultColor : Int = 0x000000, dWidth : Float = 75, dHeight : Float = 20, listener : Dynamic = null)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        this._color = this._pickerColor = defaultColor;
        this._width = dWidth;
        this._height = dHeight;
        
        this.addEventListener(MouseEvent.CLICK, e_onClick);
        
        this.buttonMode = true;
        this.useHandCursor = true;
        
        draw();
        
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    private function e_onClick(e : MouseEvent) : Void
    {
        if (!this.parent || !this.parent.contains(this))
        {
            return;
        }
        
        if (_picker == null)
        {
            _picker = new Sprite();
            _bmp = new Bitmap(new ColorPickerBMP());
            _bmp.x = _bmp.y = 1;
            _picker.addChild(_bmp);
            
            _pickerColorExample = new Sprite();
            _pickerColorExample.x = 1;
            _pickerColorExample.y = _bmp.y + _bmp.height + 1;
            updateExampleColor();
            _picker.addChild(_pickerColorExample);
            
            _picker.graphics.lineStyle(1, 0xffffff, 1, false);
            _picker.graphics.beginFill(0xffffff, 1);
            _picker.graphics.drawRect(0, 0, _bmp.width + 1, _pickerColorExample.y + _pickerColorExample.height);
            _picker.graphics.endFill();
        }
        
        if (this.parent.contains(_picker))
        {
            removePicker();
        }
        else
        {
            _picker.addEventListener(MouseEvent.MOUSE_MOVE, e_pickerMove);
            _picker.addEventListener(MouseEvent.MOUSE_OUT, e_pickerOut);
            stage.addEventListener(MouseEvent.CLICK, e_pickerClick, true, 100);
            var stagePoint : Point = this.localToGlobal(new Point(this.width + 5, 0));
            stagePoint.x = Math.max(0, Math.min(stagePoint.x, Main.GAME_WIDTH - _picker.width - 5));
            stagePoint.y = Math.max(0, Math.min(stagePoint.y, Main.GAME_HEIGHT - _picker.height - 5));
            _picker.x = stagePoint.x;
            _picker.y = stagePoint.y;
            stage.addChild(_picker);
        }
    }
    
    private function draw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(_color);
        this.graphics.drawRect(1, 1, _width - 1, _height - 1);
        this.graphics.endFill();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.5);
        this.graphics.drawRect(0, 0, _width, _height);
    }
    
    private function get_color() : Int
    {
        return _color;
    }
    
    private function set_color(newColor : Int) : Int
    {
        this._color = this._pickerColor = newColor;
        draw();
        return newColor;
    }
    
    private function removePicker() : Void
    {
        if (!stage || !stage.contains(_picker))
        {
            return;
        }
        
        stage.removeChild(_picker);
        _picker.removeEventListener(MouseEvent.MOUSE_OUT, e_pickerOut);
        _picker.removeEventListener(MouseEvent.MOUSE_MOVE, e_pickerMove);
        stage.removeEventListener(MouseEvent.CLICK, e_pickerClick, true);
    }
    
    private function updateExampleColor() : Void
    {
        if (_pickerColorExample == null || _bmp == null)
        {
            return;
        }
        
        _pickerColorExample.graphics.clear();
        _pickerColorExample.graphics.lineStyle(0, 0, 0);
        _pickerColorExample.graphics.beginFill(_pickerColor);
        _pickerColorExample.graphics.drawRect(0, 0, _bmp.width / 2, 30);
        _pickerColorExample.graphics.endFill();
        _pickerColorExample.graphics.beginFill(_color);
        _pickerColorExample.graphics.drawRect(_bmp.width / 2, 0, _bmp.width / 2, 30);
        _pickerColorExample.graphics.endFill();
    }
    
    private function e_pickerOut(e : MouseEvent) : Void
    {
        _pickerColor = color;
        updateExampleColor();
    }
    
    private function e_pickerMove(e : MouseEvent) : Void
    {
        var newColor : Int = _bmp.bitmapData.getPixel(_bmp.mouseX, _bmp.mouseY);
        var newColorS : String = Std.string(newColor);
        _pickerColor = newColor;
        updateExampleColor();
    }
    
    private function e_pickerClick(e : MouseEvent) : Void
    {
        e.preventDefault();
        removePicker();
        if (e.target == _picker)
        {
            this.color = this._pickerColor;
            this.dispatchEvent(new Event(Event.CHANGE));
        }
    }
}


