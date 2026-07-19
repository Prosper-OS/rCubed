package game.controls;

import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import game.GameOptions;

class AccuracyBar extends GameControl
{
    private static inline var PERSPECTIVE_TOP : Float = 0.70;
    private static inline var PERSPECTIVE_BOTTOM : Float = 1.00;
    
    private var options : GameOptions;
    
    private var bound_lower : Int = -117;
    private var bound_upper : Int = 117;
    private var bound_range : Int = 234;
    
    private var _width : Float = 200;
    private var _height : Float = 16;
    
    private var _colors : Array<Dynamic>;
    private var _flashLayer : Sprite;
    private var _flashPool : Array<Dynamic> = [];
    private var _activeFlashes : Array<Sprite> = [];
    private var _flashAge : Array<Int> = [];
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        updateJudge();
        
        // Parse Colors
        _colors = [];
        _colors[100] = options.judgeColors[0];
        _colors[50] = options.judgeColors[1];
        _colors[25] = options.judgeColors[2];
        _colors[5] = options.judgeColors[3];
        
        _flashLayer = new Sprite();
        _flashLayer.mouseEnabled = false;
        _flashLayer.mouseChildren = false;
        _flashLayer.blendMode = BlendMode.ADD;
        
        draw();
    }
    
    public function onScoreSignal(_score : Int, _judgeMS : Int) : Void
    {
        var color : Int = (_colors[_score] != null) ? _colors[_score] : 0xFFFFFF;
        var xPos : Float = (_judgeMS / bound_range * (_width - 6));
        xPos = Math.max(-(_width / 2), Math.min(_width / 2, xPos));
        
        var flash : Sprite = buildAccuracyFlash(color, xPos);
        flash.scaleX = 0.06;
        flash.alpha = 0.95;
        _flashLayer.addChild(flash);
        
        _activeFlashes[_activeFlashes.length] = flash;
        _flashAge[_flashAge.length] = 0;
    }
    
    public function tick() : Void
    {
        var i : Int = as3hx.Compat.parseInt(_activeFlashes.length - 1);
        while (i >= 0)
        {
            var flash : Sprite = _activeFlashes[i];
            var age : Int = as3hx.Compat.parseInt(_flashAge[i] + 1);
            _flashAge[i] = age;
            
            if (age <= 3)
            {
                var expand : Float = age / 3;
                flash.scaleX = 0.06 + (0.94 * expand);
                flash.alpha = 0.95 + (0.05 * expand);
            }
            else
            {
                var fade : Float = (age - 3) / 10;
                if (fade >= 1)
                {
                    releaseActiveFlash(i);
                    {i--;continue;
                    }
                }
                
                flash.scaleX = 1 + (0.18 * fade);
                flash.alpha = 1 - fade;
            }
            i--;
        }
    }
    
    public function onResetSignal() : Void
    {
        while (_flashLayer != null && _flashLayer.numChildren > 0)
        {
            releaseAccuracyFlash(try cast(_flashLayer.getChildAt(0), Sprite) catch(e:Dynamic) null);
        }
        as3hx.Compat.setArrayLength(_activeFlashes, 0);
        as3hx.Compat.setArrayLength(_flashAge, 0);
    }
    
    /**
     * Updates Judge Region Min Time, Max Time, and Total Size
     * either from the default judge, or a custom set judge.
     */
    public function updateJudge() : Void
    // Get Judge Window
    {
        
        var judge : Array<Dynamic> = Constant.JUDGE_WINDOW;
        if (options.judgeWindow)
        {
            judge = options.judgeWindow;
        }
        
        // Get Judge Window Size
        for (jn in 0...judge.length)
        {
            var jni : Dynamic = judge[jn];
            if (jni.t < bound_lower)
            {
                bound_lower = jni.t;
            }
            
            if (jni.t > bound_upper)
            {
                bound_upper = jni.t;
            }
        }
        
        bound_range = as3hx.Compat.parseInt(bound_upper - bound_lower);
    }
    
    public function draw() : Void
    {
        this.graphics.clear();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.045);
        this.graphics.beginFill(0xBFD8FF, 0.006);
        drawPerspectiveQuad(this.graphics, -(_width / 2), _width, -(_height / 2), _height);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.13);
        this.graphics.moveTo(0, -(_height / 2));
        this.graphics.lineTo(0, _height / 2);
        
        drawJudgeRegions();
        
        if (_flashLayer.parent != this)
        {
            addChild(_flashLayer);
        }
    }
    
    private function buildAccuracyFlash(color : Int, xPos : Float) : Sprite
    {
        var flash : Sprite = (_flashPool.length > 0) ? _flashPool.pop() : new Sprite();
        flash.mouseEnabled = false;
        flash.mouseChildren = false;
        flash.blendMode = BlendMode.ADD;
        flash.visible = true;
        flash.graphics.clear();
        
        var g : Graphics = flash.graphics;
        var widthHalf : Float = _width / 2;
        var heightHalf : Float = _height / 2;
        var coreHeight : Float = _height;
        
        g.beginFill(color, 0.07);
        drawPerspectiveQuad(g, -widthHalf, _width, -heightHalf, _height);
        g.endFill();
        
        g.beginFill(color, 0.16);
        drawPerspectiveQuad(g, xPos - 38, 76, -heightHalf, _height);
        g.endFill();
        
        g.beginFill(0xFFFFFF, 0.12);
        drawPerspectiveQuad(g, -widthHalf, _width, -6, 12);
        g.endFill();
        
        g.beginFill(color, 0.68);
        drawPerspectiveQuad(g, xPos - 2, 4, -heightHalf, coreHeight);
        g.endFill();
        
        g.beginFill(0xFFFFFF, 0.76);
        drawPerspectiveQuad(g, xPos - 0.75, 1.5, -heightHalf, coreHeight);
        g.endFill();
        
        return flash;
    }
    
    private function releaseActiveFlash(index : Int) : Void
    {
        var flash : Sprite = _activeFlashes[index];
        releaseAccuracyFlash(flash);
        
        var last : Int = as3hx.Compat.parseInt(_activeFlashes.length - 1);
        if (index != last)
        {
            _activeFlashes[index] = _activeFlashes[last];
            _flashAge[index] = _flashAge[last];
        }
        
        as3hx.Compat.setArrayLength(_activeFlashes, last);
        as3hx.Compat.setArrayLength(_flashAge, last);
    }
    
    private function releaseAccuracyFlash(flash : Sprite) : Void
    {
        if (flash == null)
        {
            return;
        }
        
        if (flash.parent != null)
        {
            flash.parent.removeChild(flash);
        }
        
        flash.visible = false;
        flash.alpha = 1;
        flash.scaleX = flash.scaleY = 1;
        
        if (_flashPool.length < 24)
        {
            _flashPool.push(flash);
        }
    }
    
    public function drawJudgeRegions() : Void
    // Get Judge Window
    {
        
        var judge : Array<Dynamic> = Constant.JUDGE_WINDOW;
        if (options.judgeWindow)
        {
            judge = options.judgeWindow;
        }
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.075);
        
        for (jn in 1...judge.length - 1)
        {
            var dX : Float = _width * ((Reflect.field(judge[jn], "t") - bound_lower) / bound_range);
            var baseX : Float = -(_width / 2) + dX;
            this.graphics.moveTo(perspectiveX(baseX, -(_height / 2) + 1), -(_height / 2) + 1);
            this.graphics.lineTo(perspectiveX(baseX, (_height / 2) - 1), (_height / 2) - 1);
        }
    }
    
    private function drawPerspectiveQuad(g : Graphics, xPos : Float, widthValue : Float, yPos : Float, heightValue : Float) : Void
    {
        var yTop : Float = yPos;
        var yBottom : Float = yPos + heightValue;
        var left : Float = xPos;
        var right : Float = xPos + widthValue;
        
        g.moveTo(perspectiveX(left, yTop), yTop);
        g.lineTo(perspectiveX(right, yTop), yTop);
        g.lineTo(perspectiveX(right, yBottom), yBottom);
        g.lineTo(perspectiveX(left, yBottom), yBottom);
        g.lineTo(perspectiveX(left, yTop), yTop);
    }
    
    private function perspectiveX(xPos : Float, yPos : Float) : Float
    {
        var depth : Float = (yPos + (_height / 2)) / Math.max(1, _height);
        var scale : Float = PERSPECTIVE_TOP + ((PERSPECTIVE_BOTTOM - PERSPECTIVE_TOP) * depth);
        return xPos * scale;
    }
    
    override private function set_width(val : Float) : Float
    {
        _width = Math.max(1, val);
        draw();
        return val;
    }
    
    override private function set_height(val : Float) : Float
    {
        _height = Math.max(1, val);
        draw();
        return val;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_ACCURACY_BAR;
    }
    
    override private function get_editorFlags() : Int
    {
        return as3hx.Compat.parseInt(FLAG_POSITION | FLAG_SIZE | FLAG_ROTATE | FLAG_OPACITY);
    }
}


