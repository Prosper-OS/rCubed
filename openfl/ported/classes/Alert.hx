package classes;

import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;

import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class Alert
{
    public static inline var RED : Int = 0x6D0E0E;
    public static inline var GREEN : Int = 0x116D0E;
    public static inline var DARK_GREEN : Int = 0x084400;
    public static inline var BLUE : Int = 0x0E3F6D;
    
    public static var STAGE_REF : Stage;
    
    private static var ALERT_DISPLAY : AlertDisplay;
    private static var ALERT_QUEUE : Array<Dynamic> = [];
    private static var HAS_EVENT : Bool = false;
    
    public static function init(ref : Stage) : Void
    {
        STAGE_REF = ref;
        ALERT_DISPLAY = new AlertDisplay();
    }
    
    public static function add(message : String, age : Int = 120, color : Int = 0x000000) : Void
    // Nothing is being displayed, start a new one.
    {
        
        if (ALERT_DISPLAY.isFinished)
        {
            ALERT_DISPLAY.setData(message, age, color);
            ALERT_DISPLAY.x = Main.GAME_WIDTH - ALERT_DISPLAY.width - 5;
            ALERT_DISPLAY.y = Main.GAME_HEIGHT - ALERT_DISPLAY.height - 5;
            STAGE_REF.addChild(ALERT_DISPLAY);
            
            if (!HAS_EVENT)
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
    
    private static function alertOnFrame(e : Event) : Void
    // Progress Active Alert
    {
        
        if (!ALERT_DISPLAY.isFinished)
        {
            ALERT_DISPLAY.progress();
            if (ALERT_DISPLAY.time > ALERT_DISPLAY.age)
            {
                ALERT_DISPLAY.isFinished = true;
                STAGE_REF.removeChild(ALERT_DISPLAY);
                
                if (ALERT_QUEUE.length == 0)
                {
                    STAGE_REF.removeEventListener(Event.ENTER_FRAME, alertOnFrame);
                    HAS_EVENT = false;
                }
            }
        }
        // Add new alert if the old alert is finished
        else if (ALERT_QUEUE.length > 0)
        {
            var newAlert : AlertQueueItem = ALERT_QUEUE.pop();
            add(newAlert.message, newAlert.age, newAlert.color);
        }
    }

    public function new()
    {
    }
}


class AlertQueueItem
{
    public var message : String;
    public var age : Int;
    public var color : Int;
    
    @:allow(classes)
    private function new(message : String, age : Int = 120, color : Int = 0x000000)
    {
        this.message = message;
        this.age = age;
        this.color = color;
    }
}


class AlertDisplay extends Sprite
{
    public var message : String;
    public var age : Int = 120;
    public var time : Int = 0;
    public var isFinished : Bool = true;
    
    private var _textfield : TextField;
    
    @:allow(classes)
    private function new()
    {
        super();
        this.mouseEnabled = false;
        this.mouseChildren = false;
        
        this.message = message;
        
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
    
    public function setData(message : String, age : Int = 120, color : Int = 0x000000) : Void
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
        if (time <= 15)
        {
            this.alpha = (time / 15);
        }
        else if (time >= age - 14)
        {
            this.alpha = 1 + ((age - 14 - time) / 15);
        }
        else
        {
            this.alpha = 1;
        }
    }
}
