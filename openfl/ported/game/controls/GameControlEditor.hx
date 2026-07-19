package game.controls;

import assets.GameBackgroundColor;
import assets.menu.icons.fa.IconClose;
import assets.menu.icons.fa.IconMove;
import classes.ui.Text;
import classes.ui.UIIcon;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class GameControlEditor extends Sprite
{
    private var _width : Float;
    private var _height : Float;
    
    private var bounds : Rectangle;
    
    public var title : Text;
    
    public var dragButton : UIIcon;
    public var closeButton : UIIcon;
    
    public var cy : Float = 37;
    
    public function new(paneWidth : Float)
    {
        super();
        _width = paneWidth;
        
        title = new Text(this, 10, 8);
        title.setAreaParams(_width - 66, 16);
        
        dragButton = new UIIcon(this, new IconMove(), _width - 40, 16);
        dragButton.setSize(14, 14);
        dragButton.buttonMode = true;
        dragButton.addEventListener(MouseEvent.MOUSE_DOWN, e_onDragStart);
        
        closeButton = new UIIcon(this, new IconClose(), _width - 16, 16);
        closeButton.setSize(12, 12);
        closeButton.setColor("#eda8a8");
        closeButton.buttonMode = true;
    }
    
    public function finalize() : Void
    {
        _height = cy + 10;
        
        bounds = new Rectangle(2, 2, Main.GAME_WIDTH - _width - 5, Main.GAME_HEIGHT - _height - 5);
        
        this.graphics.lineStyle(1, 0x000000, 0, true);
        this.graphics.beginFill(0x000000, 0.9);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0x000000, 0, true);
        this.graphics.beginFill(0xFFFFFF, 0.15);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(3, 0xFFFFFF, 0.35);
        this.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.3);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        graphics.moveTo(10, 31);
        graphics.lineTo(_width - 9, 31);
        
        position();
    }
    
    public function position() : Void
    {
        this.x = (Main.GAME_WIDTH - _width) / 2;
        this.y = (Main.GAME_HEIGHT - _height) / 2;
    }
    
    private function e_onDragStart(e : MouseEvent) : Void
    {
        stage.addEventListener(MouseEvent.MOUSE_UP, e_onDragEnd);
        startDrag(false, bounds);
    }
    
    private function e_onDragEnd(e : MouseEvent) : Void
    {
        if (stage)
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, e_onDragEnd);
        }
        
        stopDrag();
    }
}

