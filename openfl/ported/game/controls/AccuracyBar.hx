package game.controls;

import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import game.GameOptions;

class AccuracyBar extends GameControl
{
    private static inline var PERSPECTIVE_TOP                       : Dynamic= 0.70;
    private static inline var PERSPECTIVE_BOTTOM                       : Dynamic= 1.00;
    
    private var options                       : Dynamic;
    
    private var bound_lower                       : Dynamic= -117;
    private var bound_upper                       : Dynamic= 117;
    private var bound_range                       : Dynamic= 234;
    
    private var _width                       : Dynamic= 200;
    private var _height                       : Dynamic= 16;
    
    private var _colors                       : Dynamic;
    private var _flashLayer                       : Dynamic;
    private var _flashPool                       : Dynamic= [];
    private var _activeFlashes                       : Dynamic= [];
    private var _flashAge                       : Dynamic= [];
    
    public function new(options                       : Dynamic, parent                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
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
    
    public function onScoreSignal(_score                       : Dynamic, _judgeMS                       : Dynamic) : Void
    {
        var color                       : Dynamic= (_colors[_score] != null) ? _colors[_score] : 0xFFFFFF;
        var xPos                       : Dynamic= (_judgeMS / bound_range * (_width - 6));
        xPos = Math.max(-(_width / 2), Math.min(_width / 2, xPos));
        
        var flash                       : Dynamic= buildAccuracyFlash(color, xPos);
        flash.scaleX = 0.06;
        flash.alpha = 0.95;
        _flashLayer.addChild(flash);
        
        _activeFlashes[_activeFlashes.length] = flash;
        _flashAge[_flashAge.length] = 0;
    }
    
    public function tick() : Void
    {
        var i                       : Dynamic= as3hx.Compat.parseInt(_activeFlashes.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            var flash                       : Dynamic= _activeFlashes[i];
            var age                       : Dynamic= as3hx.Compat.parseInt(_flashAge[i] + 1);
            _flashAge[i] = age;
            
            if (as3hx.Compat.truthy(age <= 3))
            {
                var expand                       : Dynamic= age / 3;
                flash.scaleX = 0.06 + (0.94 * expand);
                flash.alpha = 0.95 + (0.05 * expand);
            }
            else
            {
                var fade                       : Dynamic= (age - 3) / 10;
                if (as3hx.Compat.truthy(fade >= 1))
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
        while (as3hx.Compat.truthy(_flashLayer != null && _flashLayer.numChildren > 0))
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
        
        var judge                       : Dynamic= Constant.JUDGE_WINDOW;
        if (as3hx.Compat.truthy(options.judgeWindow))
        {
            judge = options.judgeWindow;
        }
        
        // Get Judge Window Size
        for (jn in 0...judge.length)
        {
            var jni                       : Dynamic= judge[jn];
            if (as3hx.Compat.truthy(jni.t < bound_lower))
            {
                bound_lower = jni.t;
            }
            
            if (as3hx.Compat.truthy(jni.t > bound_upper))
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
        
        if (as3hx.Compat.truthy(_flashLayer.parent != this))
        {
            addChild(_flashLayer);
        }
    }
    
    private function buildAccuracyFlash(color                       : Dynamic, xPos                       : Dynamic) : Sprite
    {
        var flash                       : Dynamic= (_flashPool.length > 0) ? _flashPool.pop() : new Sprite();
        flash.mouseEnabled = false;
        flash.mouseChildren = false;
        flash.blendMode = BlendMode.ADD;
        flash.visible = true;
        flash.graphics.clear();
        
        var g                       : Dynamic= flash.graphics;
        var widthHalf                       : Dynamic= _width / 2;
        var heightHalf                       : Dynamic= _height / 2;
        var coreHeight                       : Dynamic= _height;
        
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
    
    private function releaseActiveFlash(index                       : Dynamic) : Void
    {
        var flash                       : Dynamic= _activeFlashes[index];
        releaseAccuracyFlash(flash);
        
        var last                       : Dynamic= as3hx.Compat.parseInt(_activeFlashes.length - 1);
        if (as3hx.Compat.truthy(index != last))
        {
            _activeFlashes[index] = _activeFlashes[last];
            _flashAge[index] = _flashAge[last];
        }
        
        as3hx.Compat.setArrayLength(_activeFlashes, last);
        as3hx.Compat.setArrayLength(_flashAge, last);
    }
    
    private function releaseAccuracyFlash(flash                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(flash == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(flash.parent != null))
        {
            flash.parent.removeChild(flash);
        }
        
        flash.visible = false;
        flash.alpha = 1;
        flash.scaleX = flash.scaleY = 1;
        
        if (as3hx.Compat.truthy(_flashPool.length < 24))
        {
            _flashPool.push(flash);
        }
    }
    
    public function drawJudgeRegions() : Void
    // Get Judge Window
    {
        
        var judge                       : Dynamic= Constant.JUDGE_WINDOW;
        if (as3hx.Compat.truthy(options.judgeWindow))
        {
            judge = options.judgeWindow;
        }
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.075);
        
        for (jn in 1...as3hx.Compat.parseInt(judge.length - 1))
        {
            var dX                       : Dynamic= _width * ((Reflect.field(judge[jn], "t") - bound_lower) / bound_range);
            var baseX                       : Dynamic= -(_width / 2) + dX;
            this.graphics.moveTo(perspectiveX(baseX, -(_height / 2) + 1), -(_height / 2) + 1);
            this.graphics.lineTo(perspectiveX(baseX, (_height / 2) - 1), (_height / 2) - 1);
        }
    }
    
    private function drawPerspectiveQuad(g                       : Dynamic, xPos                       : Dynamic, widthValue                       : Dynamic, yPos                       : Dynamic, heightValue                       : Dynamic) : Void
    {
        var yTop                       : Dynamic= yPos;
        var yBottom                       : Dynamic= yPos + heightValue;
        var left                       : Dynamic= xPos;
        var right                       : Dynamic= xPos + widthValue;
        
        g.moveTo(perspectiveX(left, yTop), yTop);
        g.lineTo(perspectiveX(right, yTop), yTop);
        g.lineTo(perspectiveX(right, yBottom), yBottom);
        g.lineTo(perspectiveX(left, yBottom), yBottom);
        g.lineTo(perspectiveX(left, yTop), yTop);
    }
    
    private function perspectiveX(xPos                       : Dynamic, yPos                       : Dynamic) : Float
    {
        var depth                       : Dynamic= (yPos + (_height / 2)) / Math.max(1, _height);
        var scale                       : Dynamic= PERSPECTIVE_TOP + ((PERSPECTIVE_BOTTOM - PERSPECTIVE_TOP) * depth);
        return xPos * scale;
    }
    
    override private function set_width(val                       : Dynamic) : Float
    {
        _width = Math.max(1, val);
        draw();
        return val;
    }
    
    override private function set_height(val                       : Dynamic) : Float
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
        return as3hx.Compat.parseInt(GameControl.FLAG_POSITION | GameControl.FLAG_SIZE | GameControl.FLAG_ROTATE | GameControl.FLAG_OPACITY);
    }
}


