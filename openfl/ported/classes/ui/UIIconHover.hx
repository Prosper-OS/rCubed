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
    private var _hoverDisplayed : Bool = false;
    private var _hoverText : String;
    private var _hoverPosition : String = "top";
    private var _hoverSprite : MouseTooltip;
    private var _hoverTimer : Timer;
    private var _hoverPoint : Point;
    
    public function new(parent : DisplayObjectContainer = null, sprite : DisplayObject = null, xpos : Float = 0, ypos : Float = 0)
    {
        super(parent, sprite, xpos, ypos);
    }
    
    public function dispose() : Void
    {
        if (_hoverText != null)
        {
            _hoverTimer.stop();
            _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
            _hoverTimer = null;
            this.removeEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
            this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
            this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
            
            if (_hoverSprite != null && _hoverSprite.parent)
            {
                _hoverSprite.parent.removeChild(_hoverSprite);
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Hover
    public function setHoverText(hover_text : String, position : String = "top") : Void
    {
        if (hover_text != _hoverText) {
if (_hoverText == null)
            {
                this.addEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
                _hoverPoint = new Point();
            }
            // Previous Text, clean-up old.
            else
            {
                
                {
                    if (_hoverSprite != null)
                    {
                        if (_hoverSprite.parent)
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
            if (hover_text == null)
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
        if (_hoverDisplayed && _hoverText != null)
        {
            e_hoverTimerComplete();
        }
    }
    
    private function e_hoverRollOver(e : MouseEvent = null) : Void
    {
        this.addEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        
        if (this.parent && this.parent.stage)
        {
            if (_hoverTimer == null)
            {
                _hoverTimer = new Timer(500, 1);
            }
            
            _hoverTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
            _hoverTimer.start();
        }
    }
    
    private function e_hoverRollOut(e : MouseEvent) : Void
    {
        _hoverDisplayed = false;
        _hoverTimer.stop();
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
        
        if (_hoverSprite != null && _hoverSprite.parent)
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
    
    private function e_hoverTimerComplete(e : Event = null) : Void
    {
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        
        if (_hoverSprite == null)
        {
            _hoverSprite = new MouseTooltip(_hoverText, 300);
        }
        
        _hoverPoint.x = _hoverPoint.y = 0;
        
        if (_hoverPosition == "top" || _hoverPosition == "bottom")
        {
            _hoverPoint.x -= (_hoverSprite.width / 2);
        }
        if (_hoverPosition == "left" || _hoverPosition == "right")
        {
            _hoverPoint.y -= (_hoverSprite.height / 2);
        }
        
        if (_hoverPosition == "top")
        {
            _hoverPoint.y -= (height / 2) + _hoverSprite.height + 2;
        }
        if (_hoverPosition == "bottom")
        {
            _hoverPoint.y += (height / 2) + 2;
        }
        if (_hoverPosition == "left")
        {
            _hoverPoint.x -= (width / 2) + _hoverSprite.width + 2;
        }
        if (_hoverPosition == "right")
        {
            _hoverPoint.x += (width / 2) + 2;
        }
        
        var stagePoint : Point = this.localToGlobal(_hoverPoint);
        
        // Keep on Stage
        if (stagePoint.x < 5)
        {
            stagePoint.x = 5;
        }
        
        if (stagePoint.x + _hoverSprite.width > Main.GAME_WIDTH - 5)
        {
            stagePoint.x = Main.GAME_WIDTH - 5 - _hoverSprite.width;
        }
        
        if (stagePoint.y < 5)
        {
            stagePoint.y = 5;
        }
        
        if (stagePoint.y + _hoverSprite.height > Main.GAME_HEIGHT - 5)
        {
            stagePoint.y = Main.GAME_HEIGHT - 5 - _hoverSprite.height;
        }
        
        // Position
        _hoverSprite.x = stagePoint.x;
        _hoverSprite.y = stagePoint.y;
        
        if (this.parent && this.parent.stage)
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
    
    private function e_removedFromStage(e : Event) : Void
    {
        _hoverDisplayed = false;
        this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
        
        if (_hoverSprite != null && _hoverSprite.parent)
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
}

