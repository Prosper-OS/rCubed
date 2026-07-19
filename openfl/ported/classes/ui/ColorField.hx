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
    public var color(get, set)                             : Dynamic;

    
    public var key_name                             : Dynamic;
    
    private var _color                             : Dynamic= 0x000000;
    private var _width                             : Dynamic;
    private var _height                             : Dynamic;
    
    private var _picker                             : Dynamic;
    private var _bmp                             : Dynamic;
    private var _pickerColor                             : Dynamic= 0x000000;
    private var _pickerColorExample                             : Dynamic;
    
    private var _listener                             : Dynamic= null;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, defaultColor                             : Dynamic= 0x000000, dWidth                             : Dynamic= 75, dHeight                             : Dynamic= 20, listener                             : Dynamic= null)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
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
        
        if (as3hx.Compat.truthy(listener != null))
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    private function e_onClick(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(this.parent == null || !this.parent.contains(this)))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(_picker == null))
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
        
        if (as3hx.Compat.truthy(this.parent.contains(_picker)))
        {
            removePicker();
        }
        else
        {
            _picker.addEventListener(MouseEvent.MOUSE_MOVE, e_pickerMove);
            _picker.addEventListener(MouseEvent.MOUSE_OUT, e_pickerOut);
            stage.addEventListener(MouseEvent.CLICK, e_pickerClick, true, 100);
            var stagePoint                             : Dynamic= this.localToGlobal(new Point(this.width + 5, 0));
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
    
    private function set_color(newColor                             : Dynamic) : Int
    {
        this._color = this._pickerColor = newColor;
        draw();
        return newColor;
    }
    
    private function removePicker() : Void
    {
        if (as3hx.Compat.truthy(stage == null || !stage.contains(_picker)))
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
        if (as3hx.Compat.truthy(_pickerColorExample == null || _bmp == null))
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
    
    private function e_pickerOut(e                             : Dynamic) : Void
    {
        _pickerColor = color;
        updateExampleColor();
    }
    
    private function e_pickerMove(e                             : Dynamic) : Void
    {
        var newColor                             : Dynamic= _bmp.bitmapData.getPixel(_bmp.mouseX, _bmp.mouseY);
        var newColorS                             : Dynamic= Std.string(newColor);
        _pickerColor = newColor;
        updateExampleColor();
    }
    
    private function e_pickerClick(e                             : Dynamic) : Void
    {
        e.preventDefault();
        removePicker();
        if (as3hx.Compat.truthy(e.target == _picker))
        {
            this.color = this._pickerColor;
            this.dispatchEvent(new Event(Event.CHANGE));
        }
    }
}


