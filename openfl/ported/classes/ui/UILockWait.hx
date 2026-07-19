package classes.ui;

import classes.Language;
import classes.ui.Throbber;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class UILockWait extends Sprite
{
    private var icon : Throbber;
    private var timer : Timer;
    private var callback : Dynamic;
    private var closeBtn : BoxButton;
    
    public function new(parent : DisplayObjectContainer, useTimer : Bool = false, closeFunction : Dynamic = null)
    {
        super();
        this.graphics.beginFill(0x000000, 0.5);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        
        this.graphics.lineStyle(3, 0xFFFFFF, 1);
        this.graphics.beginFill(0x000000, 1);
        this.graphics.drawRoundRect(Main.GAME_WIDTH / 2 - 48, Main.GAME_HEIGHT / 2 - 48, 96, 96, 12, 12);
        this.graphics.endFill();
        
        icon = new Throbber(64, 64, 3);
        icon.x = Main.GAME_WIDTH / 2 - 32;
        icon.y = Main.GAME_HEIGHT / 2 - 32;
        addChild(icon);
        
        icon.start();
        
        parent.addChild(this);
        
        if (useTimer)
        {
            timer = new Timer(10000, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, e_timerComplete);
            timer.start();
            
            closeBtn = new BoxButton(this, Main.GAME_WIDTH / 2 - 75, Main.GAME_HEIGHT - 50, 150, 30, Language.instance.string("menu_close"), 12, e_closeButton);
            closeBtn.visible = false;
        }
    }
    
    private function e_timerComplete(e : TimerEvent) : Void
    {
        closeBtn.visible = true;
    }
    
    private function e_closeButton(e : Event) : Void
    {
        remove();
        
        if (callback != null)
        {
            callback();
        }
    }
    
    public function remove() : Void
    {
        icon.stop();
        
        if (parent != null && parent.contains(this))
        {
            parent.removeChild(this);
        }
    }
}

