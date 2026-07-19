package classes.ui;

import assets.GameBackgroundColor;
import classes.ui.UILockWait;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;

class Prompt extends Sprite
{
    public var uiLock(never, set) : Bool;
    public var content(get, never) : Sprite;

    private var _width : Float;
    private var _height : Float;
    private var _content : Sprite;
    private var _dropshadow : Sprite;
    private var _lock : UILockWait;
    
    public function new(parent : DisplayObjectContainer, width : Float = 200, height : Float = 200)
    {
        super();
        _width = width;
        _height = height;
        
        parent.addChild(this);
        
        // Background
        var bmp : Bitmap = SpriteUtil.getBitmapSprite(parent.stage);
        this.graphics.beginBitmapFill(bmp.bitmapData);
        this.graphics.drawRect((Main.GAME_WIDTH - _width) / 2, (Main.GAME_HEIGHT - _height) / 2, _width, _height);
        this.graphics.endFill();
        
        this.graphics.beginFill(0x000000, 0.5);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        
        // Box
        _content = new Sprite();
        _content.graphics.lineStyle(1, 0x000000, 0, true);
        _content.graphics.beginFill(0xFFFFFF, 0.15);
        _content.graphics.drawRect(0, 0, _width, _height);
        _content.graphics.endFill();
        _content.graphics.lineStyle(3, 0xFFFFFF, 0.35);
        _content.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.6);
        _content.graphics.drawRect(0, 0, _width, _height);
        _content.graphics.endFill();
        _content.x = (Main.GAME_WIDTH - _width) / 2;
        _content.y = (Main.GAME_HEIGHT - _height) / 2;
        super.addChild(_content);
        
        _content.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        
        // Shadow
        _dropshadow = new Sprite();
        _dropshadow.graphics.beginFill(0x000000, 1);
        _dropshadow.graphics.drawRect(0, 0, _width, _height);
        _dropshadow.graphics.endFill();
        _dropshadow.x = _content.x;
        _dropshadow.y = _content.y;
        _dropshadow.filters = [new DropShadowFilter(0, 45, GameBackgroundColor.BG_DARK, 1, 128, 128, 1, 1, false, true, true)];
        super.addChildAt(_dropshadow, 0);
    }
    
    private function set_uiLock(val : Bool) : Bool
    {
        if (val && _lock == null)
        {
            _lock = new UILockWait(stage);
        }
        else if (!val && _lock != null)
        {
            _lock.remove();
            _lock = null;
        }
        return val;
    }
    
    override public function addChild(child : DisplayObject) : DisplayObject
    {
        return _content.addChild(child);
    }
    
    override public function removeChild(child : DisplayObject) : DisplayObject
    {
        return _content.removeChild(child);
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    private function get_content() : Sprite
    {
        return _content;
    }
    
    public function close() : Void
    {
        if (parent != null && parent.contains(this))
        {
            parent.removeChild(this);
            
            if (_lock != null)
            {
                _lock.remove();
                _lock = null;
            }
        }
    }
}

