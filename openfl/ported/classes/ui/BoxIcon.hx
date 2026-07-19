package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Timer;

class BoxIcon extends Box
{
    public var padding(never, set) : Int;
    public var delay(never, set) : Float;
    public var enabled(get, set) : Bool;

    private var _icon : UIIcon;
    private var _enabled : Bool = true;
    private var _iconPadding : Int = 11;
    
    private var _hoverDisplayed : Bool = false;
    private var _hoverText : String;
    private var _hoverPosition : String = "top";
    private var _hoverSprite : MouseTooltip;
    private var _hoverTimer : Timer = new Timer(500, 1);
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Float = 0, height : Float = 0, icon : Sprite = null, listener : Dynamic = null)
    {
        super(parent, xpos, ypos, true, false);
        super.setSize(width, height);
        
        //- Add Icon
        _icon = new UIIcon(this, icon, width / 2 + 1, height / 2 + 1);
        //_icon.icon.transform.colorTransform = new ColorTransform(0.88, 0.99, 1);
        _icon.setSize(width - _iconPadding, height - _iconPadding);
        
        //- Set Defaults
        this.mouseEnabled = true;
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        //- Set click event listener
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.CLICK, listener);
        }
    }
    
    override public function dispose() : Void
    {
        if (_listener != null)
        {
            this.removeEventListener(MouseEvent.CLICK, _listener);
        }
        
        super.dispose();
    }
    
    public function setIconColor(color : String) : Void
    {
        if (_icon != null)
        {
            _icon.setColor(color);
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
        
        var placePoint : Point = new Point(width / 2, height / 2);
        
        if (_hoverPosition == "top" || _hoverPosition == "bottom")
        {
            placePoint.x -= (_hoverSprite.width / 2);
        }
        if (_hoverPosition == "left" || _hoverPosition == "right")
        {
            placePoint.y -= (_hoverSprite.height / 2);
        }
        
        if (_hoverPosition == "top")
        {
            placePoint.y -= (height / 2) + _hoverSprite.height + 2;
        }
        if (_hoverPosition == "bottom")
        {
            placePoint.y += (height / 2) + 2;
        }
        if (_hoverPosition == "left")
        {
            placePoint.x -= (width / 2) + _hoverSprite.width + 2;
        }
        if (_hoverPosition == "right")
        {
            placePoint.x += (width / 2) + 2;
        }
        
        var stagePoint : Point = this.localToGlobal(placePoint);
        
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
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    private function set_padding(value : Int) : Int
    {
        _iconPadding = value;
        _icon.setSize(width - _iconPadding, height - _iconPadding);
        return value;
    }
    
    private function set_delay(value : Float) : Float
    {
        _hoverTimer.delay = value;
        return value;
    }
    
    override private function set_width(value : Float) : Float
    {
        _icon.setSize(value - _iconPadding, height - _iconPadding);
        super.setSize(value, super.height);
        return value;
    }
    
    override private function set_height(value : Float) : Float
    {
        _icon.setSize(width - _iconPadding, value - _iconPadding);
        super.setSize(super.width, value);
        return value;
    }
    
    override private function get_highlight() : Bool
    {
        return enabled && super.highlight;
    }
    
    private function set_enabled(value : Bool) : Bool
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
    
    /**
     * Remove the hover sprite from the box icon immediately.
     */
    public function purgeHoverSprite() : Void
    {
        if (_hoverSprite != null && _hoverSprite.parent)
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
}

