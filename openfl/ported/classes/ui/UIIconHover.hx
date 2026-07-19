package classes.ui;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Timer;

class UIIconHover extends UIIcon
{
    private var _hoverDisplayed                            : Dynamic= false;
    private var _hoverText                            : Dynamic;
    private var _hoverPosition                            : Dynamic= "top";
    private var _hoverSprite                            : Dynamic;
    private var _hoverTimer                            : Dynamic;
    private var _hoverPoint                            : Dynamic;
    
    public function new(parent                            : Dynamic= null, sprite                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0)
    {
        super(parent, sprite, xpos, ypos);
    }
    
    public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_hoverText != null))
        {
            _hoverTimer.stop();
            _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
            _hoverTimer = null;
            this.removeEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
            this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
            this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
            
            if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
            {
                _hoverSprite.parent.removeChild(_hoverSprite);
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Hover
    public function setHoverText(hover_text                            : Dynamic, position                            : Dynamic= "top") : Void
    {
        if (as3hx.Compat.truthy(hover_text != _hoverText)) {
if (as3hx.Compat.truthy(_hoverText == null))
            {
                this.addEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
                _hoverPoint = new Point();
            }
            // Previous Text, clean-up old.
            else
            {
                
                {
                    if (as3hx.Compat.truthy(_hoverSprite != null))
                    {
                        if (as3hx.Compat.truthy(_hoverSprite.parent))
                        {
                            _hoverSprite.parent.removeChild(_hoverSprite);
                        }
                        
                        _hoverSprite = null;
                    }
                    
                    this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
                    _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
                }
            }
            
            // New text is null, clear events.
            if (as3hx.Compat.truthy(hover_text == null))
            {
                this.removeEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
                this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
                this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
                _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
                _hoverTimer = null;
                _hoverPoint = null;
            }
            
            _hoverText = hover_text;
        }
        _hoverPosition = position;
        
        // Update Tooltip Instantly
        if (as3hx.Compat.truthy(_hoverDisplayed && _hoverText != null))
        {
            e_hoverTimerComplete();
        }
    }
    
    private function e_hoverRollOver(e                            : Dynamic= null) : Void
    {
        this.addEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        
        if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))
        {
            if (as3hx.Compat.truthy(_hoverTimer == null))
            {
                _hoverTimer = new Timer(500, 1);
            }
            
            _hoverTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
            _hoverTimer.start();
        }
    }
    
    private function e_hoverRollOut(e                            : Dynamic) : Void
    {
        _hoverDisplayed = false;
        _hoverTimer.stop();
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
        
        if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
    
    private function e_hoverTimerComplete(e                            : Dynamic= null) : Void
    {
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        
        if (as3hx.Compat.truthy(_hoverSprite == null))
        {
            _hoverSprite = new MouseTooltip(_hoverText, 300);
        }
        
        _hoverPoint.x = _hoverPoint.y = 0;
        
        if (as3hx.Compat.truthy(_hoverPosition == "top" || _hoverPosition == "bottom"))
        {
            _hoverPoint.x -= (_hoverSprite.width / 2);
        }
        if (as3hx.Compat.truthy(_hoverPosition == "left" || _hoverPosition == "right"))
        {
            _hoverPoint.y -= (_hoverSprite.height / 2);
        }
        
        if (as3hx.Compat.truthy(_hoverPosition == "top"))
        {
            _hoverPoint.y -= (height / 2) + _hoverSprite.height + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "bottom"))
        {
            _hoverPoint.y += (height / 2) + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "left"))
        {
            _hoverPoint.x -= (width / 2) + _hoverSprite.width + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "right"))
        {
            _hoverPoint.x += (width / 2) + 2;
        }
        
        var stagePoint                            : Dynamic= this.localToGlobal(_hoverPoint);
        
        // Keep on Stage
        if (as3hx.Compat.truthy(stagePoint.x < 5))
        {
            stagePoint.x = 5;
        }
        
        if (as3hx.Compat.truthy(stagePoint.x + _hoverSprite.width > Main.GAME_WIDTH - 5))
        {
            stagePoint.x = Main.GAME_WIDTH - 5 - _hoverSprite.width;
        }
        
        if (as3hx.Compat.truthy(stagePoint.y < 5))
        {
            stagePoint.y = 5;
        }
        
        if (as3hx.Compat.truthy(stagePoint.y + _hoverSprite.height > Main.GAME_HEIGHT - 5))
        {
            stagePoint.y = Main.GAME_HEIGHT - 5 - _hoverSprite.height;
        }
        
        // Position
        _hoverSprite.x = stagePoint.x;
        _hoverSprite.y = stagePoint.y;
        
        if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))
        {
            _hoverDisplayed = true;
            this.parent.stage.addChild(_hoverSprite);
            this.addEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage, false, 0, true);
        }
        else
        {
            _hoverDisplayed = false;
        }
    }
    
    private function e_removedFromStage(e                            : Dynamic) : Void
    {
        _hoverDisplayed = false;
        this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
        
        if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
}

