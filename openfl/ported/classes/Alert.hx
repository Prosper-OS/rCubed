package classes;

import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;

import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class Alert
{
    public static inline var RED                              : Dynamic= 0x6D0E0E;
    public static inline var GREEN                              : Dynamic= 0x116D0E;
    public static inline var DARK_GREEN                              : Dynamic= 0x084400;
    public static inline var BLUE                              : Dynamic= 0x0E3F6D;
    
    public static var STAGE_REF                              : Dynamic;
    
    private static var ALERT_DISPLAY                              : Dynamic;
    private static var ALERT_QUEUE                              : Dynamic= [];
    private static var HAS_EVENT                              : Dynamic= false;
    
    public static function init(ref                              : Dynamic) : Void
    {
        STAGE_REF = ref;
        ALERT_DISPLAY = new AlertDisplay();
    }
    
    public static function add(message                              : Dynamic, age                              : Dynamic= 120, color                              : Dynamic= 0x000000) : Void
    // Nothing is being displayed, start a new one.
    {
        
        if (as3hx.Compat.truthy(ALERT_DISPLAY.isFinished))
        {
            ALERT_DISPLAY.setData(message, age, color);
            ALERT_DISPLAY.x = Main.GAME_WIDTH - ALERT_DISPLAY.width - 5;
            ALERT_DISPLAY.y = Main.GAME_HEIGHT - ALERT_DISPLAY.height - 5;
            STAGE_REF.addChild(ALERT_DISPLAY);
            
            if (as3hx.Compat.truthy(!HAS_EVENT))
            {
                STAGE_REF.addEventListener(Event.ENTER_FRAME, alertOnFrame, false, as3hx.Compat.INT_MAX - 2);
                HAS_EVENT = true;
            }
        }
        else
        {
            ALERT_QUEUE.push(new AlertQueueItem(message, age, color));
        }
    }
    
    private static function alertOnFrame(e                              : Dynamic) : Void
    // Progress Active Alert
    {
        
        if (as3hx.Compat.truthy(!ALERT_DISPLAY.isFinished))
        {
            ALERT_DISPLAY.progress();
            if (as3hx.Compat.truthy(ALERT_DISPLAY.time > ALERT_DISPLAY.age))
            {
                ALERT_DISPLAY.isFinished = true;
                STAGE_REF.removeChild(ALERT_DISPLAY);
                
                if (as3hx.Compat.truthy(ALERT_QUEUE.length == 0))
                {
                    STAGE_REF.removeEventListener(Event.ENTER_FRAME, alertOnFrame);
                    HAS_EVENT = false;
                }
            }
        }
        // Add new alert if the old alert is finished
        else if (as3hx.Compat.truthy(ALERT_QUEUE.length > 0))
        {
            var newAlert                              : Dynamic= ALERT_QUEUE.pop();
            add(newAlert.message, newAlert.age, newAlert.color);
        }
    }

    public function new()
    {
    }
}


class AlertQueueItem
{
    public var message                              : Dynamic;
    public var age                              : Dynamic;
    public var color                              : Dynamic;
    
    @:allow(classes)
    private function new(message                              : Dynamic, age                              : Dynamic= 120, color                              : Dynamic= 0x000000)
    {
        this.age = age;
        this.color = color;
    }
}


class AlertDisplay extends Sprite
{
    public var message                              : Dynamic;
    public var age                              : Dynamic= 120;
    public var time                              : Dynamic= 0;
    public var isFinished                              : Dynamic= true;
    
    private var _textfield                              : Dynamic;
    
    @:allow(classes)
    private function new()
    {
        super();
        this.mouseEnabled = false;
        this.mouseChildren = false;
        _textfield = new TextField();
        _textfield.x = 6;
        _textfield.y = 2;
        _textfield.selectable = false;
        _textfield.embedFonts = true;
        _textfield.antiAliasType = AntiAliasType.ADVANCED;
        _textfield.autoSize = TextFieldAutoSize.LEFT;
        _textfield.defaultTextFormat = Constant.TEXT_FORMAT;
        
        this.addChild(_textfield);
    }
    
    public function setData(message                              : Dynamic, age                              : Dynamic= 120, color                              : Dynamic= 0x000000) : Void
    {
        _textfield.htmlText = message;
        
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 2, true);
        this.graphics.beginFill(color, 0.75);
        this.graphics.drawRect(0, 0, _textfield.width + 13, _textfield.height + 5);
        this.graphics.endFill();
        
        this.age = age;
        this.time = 0;
        this.alpha = 0;
        
        this.isFinished = false;
    }
    
    public function progress() : Void
    {
        time += 1;
        if (as3hx.Compat.truthy(time <= 15))
        {
            this.alpha = (time / 15);
        }
        else if (as3hx.Compat.truthy(time >= age - 14))
        {
            this.alpha = 1 + ((age - 14 - time) / 15);
        }
        else
        {
            this.alpha = 1;
        }
    }
}
