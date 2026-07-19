package game.controls;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

class ProgressBarGame extends GameControl
{
    private var top_mc : Sprite = new Sprite();
    private var progress_mc : Sprite = new Sprite();
    
    public var barWidth : Int;
    public var barHeight : Int;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, bWidth : Int = 458, bHeight : Int = 20, bSplits : Int = 4, borColor : Int = 0x545454, borSize : Float = 0.1, bColor : Int = 0x00BFFF)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.x = xpos;
        this.y = ypos;
        
        // Draw Background
        top_mc.graphics.beginFill(0xFFFFFF, 0.0);
        top_mc.graphics.lineStyle(0);
        top_mc.graphics.drawRect(0, 0, bWidth, bHeight);
        top_mc.graphics.endFill();
        
        // Draw Gloss
        top_mc.graphics.beginFill(0xFFFFFF, 0.5);
        top_mc.graphics.lineStyle(1, 0x000000, 0);
        top_mc.graphics.drawRect(1, 1, bWidth - 2, (bHeight - 2) / 2);
        top_mc.graphics.endFill();
        
        // Draw Border
        top_mc.graphics.lineStyle(borSize, borColor, 1);
        top_mc.graphics.drawRect(0, 0, bWidth, bHeight);
        if (bSplits > 0)
        {
            top_mc.graphics.lineStyle(borSize, borColor, 0.75);
            var spacing : Float = bWidth / bSplits;
            for (sX in 0...bSplits)
            {
                top_mc.graphics.moveTo(spacing * sX, 0);
                top_mc.graphics.lineTo(spacing * sX, bHeight);
            }
        }
        
        // Draw Progress Bar
        progress_mc.graphics.beginFill(bColor);
        progress_mc.graphics.lineStyle(1, 0x000000, 0);
        progress_mc.graphics.drawRect(0, 0, bWidth, bHeight);
        progress_mc.graphics.endFill();
        progress_mc.width = 0;
        
        // Add the clips to the stage
        addChild(progress_mc);
        addChild(top_mc);
        
        this.mouseChildren = false;
        this.barWidth = bWidth;
        this.barHeight = height;
    }
    
    public function update(value : Float = 0, useTween : Bool = true) : Void
    {
        if (value < 0)
        {
            value = 0;
        }
        if (value > 1)
        {
            value = 1;
        }
        
        progress_mc.width = value * barWidth;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_PROGRESS_BAR;
    }
}

