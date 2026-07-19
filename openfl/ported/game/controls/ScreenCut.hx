package game.controls;

import assets.GameBackgroundColor;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import game.GameOptions;

class ScreenCut extends Sprite
{
    private var options : GameOptions;
    
    private var self : ScreenCut;
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        this.self = this;
        this.graphics.lineStyle(3, GameBackgroundColor.BG_STATIC, 1);
        this.graphics.beginFill(0x000000);
        
        var _sw1_ = (options.scrollDirection);        

        switch (_sw1_)
        {
            case "down":
                this.x = 0;
                this.y = options.screencutPosition * Main.GAME_HEIGHT;
                this.graphics.drawRect(-Main.GAME_WIDTH, -(Main.GAME_HEIGHT * 3), Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);
                
                if (options.isEditor)
                {
                    this.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : Void
                            {
                                self.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                            });
                    this.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : Void
                            {
                                self.stopDrag();
                                options.screencutPosition = (self.y / Main.GAME_HEIGHT);
                            });
                }
            case "right":
                this.x = options.screencutPosition * Main.GAME_WIDTH;
                this.y = 0;
                this.graphics.drawRect(-Main.GAME_WIDTH * 3, -Main.GAME_HEIGHT, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);
                
                if (options.isEditor)
                {
                    this.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : Void
                            {
                                self.startDrag(false, new Rectangle(0, 0, Main.GAME_WIDTH - 7, 0));
                            });
                    this.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : Void
                            {
                                self.stopDrag();
                                options.screencutPosition = (self.x / Main.GAME_WIDTH);
                            });
                }
            case "left":
                this.x = Main.GAME_WIDTH - (options.screencutPosition * Main.GAME_WIDTH);
                this.y = 0;
                this.graphics.drawRect(0, -Main.GAME_HEIGHT, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);
                
                if (options.isEditor)
                {
                    this.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : Void
                            {
                                self.startDrag(false, new Rectangle(0, 0, Main.GAME_WIDTH - 7, 0));
                            });
                    this.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : Void
                            {
                                self.stopDrag();
                                options.screencutPosition = 1 - (self.x / Main.GAME_WIDTH);
                            });
                }
            default:
                this.x = 0;
                this.y = Main.GAME_HEIGHT - (options.screencutPosition * Main.GAME_HEIGHT);
                this.graphics.drawRect(-Main.GAME_WIDTH, 0, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);
                
                if (options.isEditor)
                {
                    this.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : Void
                            {
                                self.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                            });
                    this.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : Void
                            {
                                self.stopDrag();
                                options.screencutPosition = 1 - (self.y / Main.GAME_HEIGHT);
                            });
                }
        }
        this.graphics.endFill();
        if (options.isEditor)
        {
            this.buttonMode = true;
            this.useHandCursor = true;
        }
    }
}

