package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Timer;

class BoxButton extends Box
{
    public var enabled(get, set)                             : Dynamic;
    public var text(get, set)                             : Dynamic;
    public var textColor(never, set)                             : Dynamic;

    private var _text                             : Dynamic;
    private var _enabled                             : Dynamic= true;
    
    private var _listener                             : Dynamic= null;
    
    private var _hoverDisplayed                             : Dynamic= false;
    private var _hoverText                             : Dynamic;
    private var _hoverPosition                             : Dynamic= "top";
    private var _hoverSprite                             : Dynamic;
    private var _hoverTimer                             : Dynamic;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, width                             : Dynamic= 0, height                             : Dynamic= 0, text                             : Dynamic= "", size                             : Dynamic= 12, listener                             : Dynamic= null)
    {
        super(parent, xpos, ypos, true, false);
        super.setSize(width, height);
        
        //- Add Text
        _text = new Text(this, 0, 0, text, size, "#FFFFFF");
        _text.setAreaParams(width, height + 1, Text.CENTER);
        
        //- Set Defaults
        this.mouseEnabled = true;
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        //- Set click event listener
        if (as3hx.Compat.truthy(listener != null))
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.CLICK, listener);
        }
    }
    
    override public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_listener != null))
        {
            this.removeEventListener(MouseEvent.CLICK, _listener);
        }
        
        super.dispose();
        
        if (as3hx.Compat.truthy(_text != null))
        {
            _text.dispose();
        }
        
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
    public function setHoverText(hover_text                             : Dynamic, position                             : Dynamic= "top") : Void
    {
        if (as3hx.Compat.truthy(hover_text != _hoverText)) {
if (as3hx.Compat.truthy(_hoverText == null))
            {
                this.addEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
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
    
    private function e_hoverRollOver(e                             : Dynamic= null) : Void
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
    
    private function e_hoverRollOut(e                             : Dynamic) : Void
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
    
    private function e_hoverTimerComplete(e                             : Dynamic= null) : Void
    {
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        
        if (as3hx.Compat.truthy(_hoverSprite == null))
        {
            _hoverSprite = new MouseTooltip(_hoverText, 300);
        }
        
        var placePoint                             : Dynamic= new Point(width / 2, height / 2);
        
        if (as3hx.Compat.truthy(_hoverPosition == "top" || _hoverPosition == "bottom"))
        {
            placePoint.x -= (_hoverSprite.width / 2);
        }
        if (as3hx.Compat.truthy(_hoverPosition == "left" || _hoverPosition == "right"))
        {
            placePoint.y -= (_hoverSprite.height / 2);
        }
        
        if (as3hx.Compat.truthy(_hoverPosition == "top"))
        {
            placePoint.y -= (height / 2) + _hoverSprite.height + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "bottom"))
        {
            placePoint.y += (height / 2) + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "left"))
        {
            placePoint.x -= (width / 2) + _hoverSprite.width + 2;
        }
        if (as3hx.Compat.truthy(_hoverPosition == "right"))
        {
            placePoint.x += (width / 2) + 2;
        }
        
        var stagePoint                             : Dynamic= this.localToGlobal(placePoint);
        
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
    
    private function e_removedFromStage(e                             : Dynamic) : Void
    {
        _hoverDisplayed = false;
        this.removeEventListener(Event.REMOVED_FROM_STAGE, e_removedFromStage);
        
        if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    override private function set_width(value                             : Dynamic) : Float
    {
        _text.width = value;
        super.setSize(value, super.height);
        return value;
    }
    
    override private function set_height(value                             : Dynamic) : Float
    {
        _text.height = value;
        super.setSize(super.width, value);
        return value;
    }
    
    override private function get_highlight() : Bool
    {
        return enabled && super.highlight;
    }
    
    private function set_enabled(value                             : Dynamic) : Bool
    {
        _enabled = value;
        this.mouseEnabled = value;
        this.useHandCursor = value;
        this.alpha = (value) ? 1 : 0.5;
        setHoverStatus(value);
        return value;
    }
    
    private function get_enabled() : Bool
    {
        return _enabled;
    }
    
    private function get_text() : String
    {
        return _text.text;
    }
    
    private function set_text(value                             : Dynamic) : String
    {
        _text.text = value;
        return value;
    }
    
    private function set_textColor(color                             : Dynamic) : String
    {
        _text.fontColor = color;
        return color;
    }
}

