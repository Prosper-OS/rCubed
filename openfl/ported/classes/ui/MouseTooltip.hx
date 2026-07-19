package classes.ui;

import assets.GameBackgroundColor;
import openfl.display.Sprite;
import openfl.text.AntiAliasType;
import openfl.text.TextField;

class MouseTooltip extends Sprite
{
    public var message(get, set) : String;

    private var msg : TextField;
    private var maxWidth : Int = 250;
    
    public function new(string : String = "", maxWidth : Int = 250)
    {
        super();
        this.mouseEnabled = false;
        this.mouseChildren = false;
        
        msg = new TextField();
        msg.x = 5;
        msg.selectable = false;
        msg.embedFonts = true;
        msg.antiAliasType = AntiAliasType.ADVANCED;
        msg.autoSize = "left";
        msg.defaultTextFormat = Constant.TEXT_FORMAT_12;
        addChild(msg);
        
        this.maxWidth = maxWidth;
        
        if (string != "")
        {
            message = string;
        }
    }
    
    private function set_message(value : String) : String
    {
        if (value != msg.htmlText)
        {
            msg.wordWrap = false;
            msg.multiline = false;
            msg.htmlText = value;
            if (msg.width > maxWidth)
            {
                msg.wordWrap = true;
                msg.multiline = true;
                msg.width = maxWidth - 10;
            }
            
            this.graphics.clear();
            
            if (msg.textWidth > 0)
            {
                this.graphics.lineStyle(1, 0xffffff, 0.75);
                this.graphics.beginFill(GameBackgroundColor.BG_DARK, 0.95);
                this.graphics.drawRect(0, 0, msg.width + 10, msg.height + 2);
                this.graphics.endFill();
            }
        }
        return value;
    }
    
    private function get_message() : String
    {
        return msg.htmlText;
    }
}

