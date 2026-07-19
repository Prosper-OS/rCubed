package classes.ui;

import com.greensock.TweenLite;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;

class ProgressBar extends Sprite
{
    public static inline var LOADER_COMPLETE : String = "LoaderComplete";
    
    private var top_mc : Sprite = new Sprite();
    private var progress_mc : Sprite = new Sprite();
    
    private var curPercent : Float = 0;
    public var isComplete : Bool = false;
    public var barWidth : Int;
    public var barHeight : Int;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, bWidth : Int = 450, bHeight : Int = 20, bSplits : Int = 0, borColor : Int = 0x000000, borSize : Float = 2, bColor : Int = 0x00BFFF)
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
    
    public function update(percent : Float = 0, useTween : Bool = true) : Void
    {
        if (percent < 0)
        {
            percent = 0;
        }
        if (percent > 1)
        {
            percent = 1;
        }
        
        if (curPercent != percent)
        {
            if (useTween)
            {
                TweenLite.to(progress_mc, 0.25, {
                            width : percent * barWidth
                        });
            }
            else
            {
                progress_mc.width = percent * barWidth;
            }
            
            if (percent >= 1)
            {
                dispatchEvent(new Event(LOADER_COMPLETE));
                this.isComplete = true;
            }
        }
    }
    
    public function remove(time : Float = 0.5) : Void
    {
        TweenLite.to(this, time, {
                    alpha : 0,
                    onComplete : removeLoaderBar
                });
    }
    
    private function removeLoaderBar() : Void
    {
        parent.removeChild(this);
    }
}

