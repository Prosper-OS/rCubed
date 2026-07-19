package classes.ui;

import openfl.display.Sprite;
import openfl.events.MouseEvent;

class SimpleBoxButton extends Sprite
{
    private var _width                             : Dynamic;
    private var _height                             : Dynamic;
    
    public function new(width                             : Dynamic, height                             : Dynamic)
    {
        super();
        this._height = height;
        this._width = width;
        
        drawBox(false);
        
        this.mouseChildren = false;
        this.tabEnabled = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        addEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
    }
    
    private function e_mouseOver(e                             : Dynamic) : Void
    {
        addEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
        drawBox(true);
    }
    
    private function e_mouseOut(e                             : Dynamic) : Void
    {
        removeEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
        drawBox(false);
    }
    
    private function drawBox(doHover                             : Dynamic) : Void
    {
        graphics.clear();
        graphics.lineStyle(0, 0, 0);
        graphics.beginFill(0xffffff, (doHover) ? 0.2 : 0);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();
    }
}


