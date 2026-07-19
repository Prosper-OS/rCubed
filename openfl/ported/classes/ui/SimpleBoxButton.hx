package classes.ui;

import openfl.display.Sprite;
import openfl.events.MouseEvent;

class SimpleBoxButton extends Sprite
{
    private var _width : Float;
    private var _height : Float;
    
    public function new(width : Float, height : Float)
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
    
    private function e_mouseOver(e : MouseEvent) : Void
    {
        addEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
        drawBox(true);
    }
    
    private function e_mouseOut(e : MouseEvent) : Void
    {
        removeEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
        drawBox(false);
    }
    
    private function drawBox(doHover : Bool) : Void
    {
        graphics.clear();
        graphics.lineStyle(0, 0, 0);
        graphics.beginFill(0xffffff, (doHover) ? 0.2 : 0);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();
    }
}


