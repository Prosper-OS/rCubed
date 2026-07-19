package classes.ui;

import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * Simple animated throbber.
 */
class Throbber extends Sprite
{
    public var running(get, never)                            : Dynamic;
    public var currentStep(get, never)                            : Dynamic;
    public var maxSteps(get, never)                            : Dynamic;

    
    /**
     * The colors to use for the lines.  <br>
     * When there are 12 steps the colors are used as follows: <br>
     * - the first color is used at 12 o'clock <br>
     * - the second color is used at 11 o'clock, etc.<br>
     * - the last color is used for all remaining lines
     */
    public var colors                            : Dynamic= [0xffffff];
    public var alphas                            : Dynamic= [1, 0.9, 0.8, 0.7, 0.6, 0.5];
    
    // The alpha value for all lines.
    public var lineAlpha                            : Dynamic= 1;
    
    // The thickness of all lines.
    public var lineThickness                            : Dynamic= 3;
    
    // The delay in milliseconds between drawing the animating lines.
    public var delay                            : Dynamic= 100;
    
    // If true then when this throbber is added to stage it starts (defaults to false).
    public var autoStart                            : Dynamic= false;
    
    // If true then the throbber is hidden when it is stopped.
    public var hideWhenStopped                            : Dynamic= false;
    
    // the last time the lines were drawn
    private var lastDraw                            : Dynamic= 0;
    
    // the width of the throbber
    private var w                            : Dynamic;
    
    // the height of the throbber
    private var h                            : Dynamic;
    
    /**
     * Initializes the throbber with the given width, height, and autoStart values.
     */
    public function new(w                            : Dynamic= 32, h                            : Dynamic= 32, lineThickness                            : Dynamic= 3)
    {
        super();
        this.w = w;
        this.h = h;
        this.lineThickness = lineThickness;
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }
    
    private function addedToStage(event                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(autoStart))
        {
            start();
        }
        else if (as3hx.Compat.truthy(!hideWhenStopped))
        {
            redraw();
        }
    }
    
    private function removedFromStage(event                            : Dynamic) : Void
    {
        stop();
    }
    
    private var _running                            : Dynamic;
    
    // Returns true when the throbber is animating.
    private function get_running() : Bool
    {
        return _running;
    }
    
    private var _currentStep                            : Dynamic= 0;
    
    // Returns the current step in the animation process.
    private function get_currentStep() : Int
    {
        return _currentStep;
    }
    
    // Moves to the next step and redraws.
    public function nextStep() : Void
    {
        _currentStep = as3hx.Compat.parseInt((_currentStep + 1) % maxSteps);
        redraw();
    }
    
    private var _maxSteps                            : Dynamic= 12;
    
    // Returns the maximum number of steps in the animation process.
    private function get_maxSteps() : Int
    {
        return _maxSteps;
    }
    
    // Starts the animation.
    public function start() : Void
    {
        if (as3hx.Compat.truthy(!_running))
        {
            _running = true;
            redraw();
            addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
        }
    }
    
    // Stops the animation.
    public function stop() : Void
    {
        if (as3hx.Compat.truthy(_running))
        {
            _running = false;
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            if (as3hx.Compat.truthy(hideWhenStopped))
            {
                graphics.clear();
                _currentStep = 0;
            }
        }
    }
    
    // Resets back to the first step.  Doesn't stop the animation if it's running.
    public function reset() : Void
    {
        _currentStep = 0;
        if (as3hx.Compat.truthy(!running))
        {
            if (as3hx.Compat.truthy(hideWhenStopped))
            {
                graphics.clear();
            }
            else
            {
                redraw();
            }
        }
    }
    
    private function enterFrameHandler(event                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(running))
        {
            var diff                            : Dynamic= as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - lastDraw);
            if (as3hx.Compat.truthy(diff > delay))
            {
                nextStep();
            }
        }
    }
    
    public function redraw() : Void
    {
        lastDraw = Math.round(haxe.Timer.stamp() * 1000);
        drawLines();
    }
    
    /**
     * Draws the 12 lines.
     */
    public function drawLines() : Void
    {
        var g                            : Dynamic= graphics;
        g.clear();
        
        var midX                            : Dynamic= Math.round(w / 2);
        var midY                            : Dynamic= Math.round(w / 2);
        var radius                            : Dynamic= Math.min(midX, midY);
        
        if (as3hx.Compat.truthy((radius > 0) && (lineThickness > 0) && (lineAlpha > 0)))
        {
            var angle                            : Dynamic= 0;
            var maxAngle                            : Dynamic= (2 * Math.PI);
            var incr                            : Dynamic= maxAngle / maxSteps;
            var lineNum                            : Dynamic= 0;
            while (as3hx.Compat.truthy(angle < maxAngle))
            {
                var color                            : Dynamic= getColor(lineNum);
                g.lineStyle(lineThickness, color, getAlpha(lineNum), true, null, CapsStyle.ROUND);
                
                // figure out the position around the circle
                var x1                            : Dynamic= midX + (radius * Math.sin(angle));
                var y1                            : Dynamic= midY - (radius * Math.cos(angle));
                // make a hole in the center, make each line segment be 40% of the radius
                var dr                            : Dynamic= as3hx.Compat.parseInt(3 * radius / 5);
                var x2                            : Dynamic= midX + (dr * Math.sin(angle));
                var y2                            : Dynamic= midY - (dr * Math.cos(angle));
                g.moveTo(x1, y1);
                g.lineTo(x2, y2);
                
                angle += incr;
                lineNum++;
            }
        }
    }
    
    /**
     * Determines the color based on which line is being drawn.
     */
    private function getColor(lineNum                            : Dynamic) : Int
    {
        var color                            : Dynamic= colors[0];
        if (as3hx.Compat.truthy(currentStep >= 0))
        {
            var diff                            : Dynamic= as3hx.Compat.parseInt(currentStep - lineNum);
            if (as3hx.Compat.truthy(diff < 0))
            {
                diff += maxSteps;
            }
            var index                            : Dynamic= Math.min(colors.length - 1, diff);
            color = colors[index];
        }
        return color;
    }
    
    /**
     * Determines the alpha based on which line is being drawn.
     */
    private function getAlpha(lineNum                            : Dynamic) : Float
    {
        var newAlpha                            : Dynamic= alphas[0];
        if (as3hx.Compat.truthy(currentStep >= 0))
        {
            var diff                            : Dynamic= as3hx.Compat.parseInt(currentStep - lineNum);
            if (as3hx.Compat.truthy(diff < 0))
            {
                diff += maxSteps;
            }
            var index                            : Dynamic= Math.min(alphas.length - 1, diff);
            newAlpha = alphas[index];
        }
        return newAlpha;
    }
}

