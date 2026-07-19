package game.controls;

import classes.RenderQuality;
import com.greensock.TweenLite;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import game.GameOptions;

class Judge extends GameControl
{
    private var options                       : Dynamic;
    private var indexes                       : Dynamic= JudgeTweens.judge_indexes;
    private var labelDesc                       : Dynamic= [];
    private var field                       : Dynamic;
    private var freeze                       : Dynamic= false;
    
    private var lastScore                       : Dynamic= 100;
    private var frame                       : Dynamic= 0;
    private var subframe                       : Dynamic= 0;
    private var lastTime                       : Dynamic= 0;
    private var sX                       : Dynamic= 0;
    
    private var speedScale                       : Dynamic= 1;
    
    public function new(options                       : Dynamic, parent                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        if (as3hx.Compat.truthy(!this.options.displayJudgeAnimations))
        {
            indexes = JudgeTweens.judge_indexes_static;
        }
        
        speedScale = this.options.judgeSpeed;
        
        labelDesc[100] = {
                    color : options.judgeColors[0],
                    title : "AMAZING!!!"
                };
        labelDesc[50] = {
                    color : options.judgeColors[1],
                    title : "PERFECT!"
                };
        labelDesc[25] = {
                    color : options.judgeColors[2],
                    title : "GOOD"
                };
        labelDesc[5] = {
                    color : options.judgeColors[3],
                    title : "AVERAGE"
                };
        labelDesc[-5] = {
                    color : options.judgeColors[5],
                    title : "BOO!!"
                };
        labelDesc[-10] = {
                    color : options.judgeColors[4],
                    title : "MISS!"
                };
        
        var textFormat                       : Dynamic= new TextFormat(Fonts.AACHEN_LIGHT, as3hx.Compat.parseInt(42 * options.judgeScale), 0xffffff, true);
        
        field = new TextField();
        field.defaultTextFormat = textFormat;
        field.antiAliasType = AntiAliasType.NORMAL;
        field.embedFonts = true;
        field.selectable = false;
        field.autoSize = TextFieldAutoSize.CENTER;
        field.mouseEnabled = false;
        field.doubleClickEnabled = false;
        field.mouseWheelEnabled = false;
        field.tabEnabled = false;
        field.filters = [
                new GlowFilter(0x000000, 1, 5, 5, 10, 3), 
                new GlowFilter(0x000000, 0.65, 9, 9, 2.4, 2)
        ];
        field.x = 0;
        field.y = -30;
        field.visible = true;
        field.alpha = 1;
        addChild(field);
        RenderQuality.cacheDisplayObject(field);
        
        //updateDisplay();
        
        this.mouseChildren = false;
        this.doubleClickEnabled = false;
        this.tabEnabled = false;
    }
    
    public function hideJudge() : Void
    {
        this.frame = 0;
        this.subframe = 0;
        this.alpha = 0;
        this.visible = false;
    }
    
    public function showJudge(newScore                       : Dynamic, doFreeze                       : Dynamic= false) : Void
    // Hide Perfect/Amazing Judge
    {
        
        if (as3hx.Compat.truthy(!options.isEditor && newScore >= 50 && !options.displayPerfect))
        {
            return;
        }
        
        lastScore = newScore;
        
        field.x = sX;
        field.textColor = labelDesc[newScore].color;
        field.text = labelDesc[newScore].title;
        sX = field.x;
        frame = 0;
        subframe = 0;
        freeze = doFreeze;
        lastTime = Math.round(haxe.Timer.stamp() * 1000);
        updateDisplay();
    }
    
    public function updateJudge(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!freeze && this.alpha > 0))
        {
            var curTime                       : Dynamic= Math.round(haxe.Timer.stamp() * 1000);
            subframe += ((curTime - lastTime) / 30) * speedScale;  // Animation keys are 30fps.  
            while (as3hx.Compat.truthy(as3hx.Compat.parseInt(subframe) > frame))
            {
                frame++;
                updateDisplay();
                this.visible = true;
            }
            lastTime = curTime;
        }
    }
    
    public function getTextBounds(targetSpace                       : Dynamic) : Rectangle
    {
        if (as3hx.Compat.truthy(!visible || alpha <= 0.02 || !field.visible || field.text == ""))
        {
            return null;
        }
        
        var bounds                       : Dynamic= null;
        for (i in 0...field.length)
        {
            var charBounds                       : Dynamic= field.getCharBoundaries(i);
            if (as3hx.Compat.truthy(charBounds == null))
            {
                continue;
            }
            
            if (as3hx.Compat.truthy(bounds != null))
            {
                bounds = bounds.union(charBounds);
            }
            else
            {
                bounds = charBounds.clone();
            }
        }
        
        if (as3hx.Compat.truthy(bounds == null))
        {
            return field.getBounds((targetSpace != null) ? targetSpace : this);
        }
        
        var topLeft                       : Dynamic= field.localToGlobal(new Point(bounds.left, bounds.top));
        var bottomRight                       : Dynamic= field.localToGlobal(new Point(bounds.right, bounds.bottom));
        if (as3hx.Compat.truthy(targetSpace != null))
        {
            topLeft = targetSpace.globalToLocal(topLeft);
            bottomRight = targetSpace.globalToLocal(bottomRight);
        }
        
        return new Rectangle(Math.min(topLeft.x, bottomRight.x), Math.min(topLeft.y, bottomRight.y), 
        Math.abs(bottomRight.x - topLeft.x), Math.abs(bottomRight.y - topLeft.y));
    }
    
    private function updateDisplay() : Void
    {
        if (as3hx.Compat.truthy(freeze && frame > 0))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(Reflect.field(as3hx.Compat.field(indexes, lastScore), Std.string(frame)) != null))
        {
            var i                       : Dynamic= Reflect.field(as3hx.Compat.field(indexes, lastScore), Std.string(frame));
            
            field.x = sX + i[1];
            field.y = (i[2] - 30);
            this.scaleX = i[3];
            this.scaleY = i[4];
            this.alpha = i[5];
            
            if (as3hx.Compat.truthy(freeze))
            {
                return;
            }
            
            // Tween
            var next                       : Dynamic= Reflect.field(as3hx.Compat.field(indexes, lastScore), Std.string(frame + i[6]));  // Next Frame  
            if (as3hx.Compat.truthy(i[0] > 0 && next != null))
            {
                TweenLite.to(this, i[0] / speedScale, {
                            scaleX : next[3],
                            scaleY : next[4],
                            alpha : next[5]
                        });
                TweenLite.to(field, i[0] / speedScale, {
                            x : sX + next[1],
                            y : (next[2] - 30)
                        });
            }
        }
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_JUDGE;
    }
    
    override private function get_editorFlags() : Int
    {
        return as3hx.Compat.parseInt(GameControl.FLAG_POSITION | GameControl.FLAG_ROTATE | GameControl.FLAG_OPACITY);
    }
}

