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
    public var running(get, never) : Bool;
    public var currentStep(get, never) : Int;
    public var maxSteps(get, never) : Int;

    
    /**
     * The colors to use for the lines.  <br>
     * When there are 12 steps the colors are used as follows: <br>
     * - the first color is used at 12 o'clock <br>
     * - the second color is used at 11 o'clock, etc.<br>
     * - the last color is used for all remaining lines
     */
    public var colors : Array<Dynamic> = [0xffffff];
    public var alphas : Array<Dynamic> = [1, 0.9, 0.8, 0.7, 0.6, 0.5];
    
    // The alpha value for all lines.
    public var lineAlpha : Float = 1;
    
    // The thickness of all lines.
    public var lineThickness : Int = 3;
    
    // The delay in milliseconds between drawing the animating lines.
    public var delay : Int = 100;
    
    // If true then when this throbber is added to stage it starts (defaults to false).
    public var autoStart : Bool = false;
    
    // If true then the throbber is hidden when it is stopped.
    public var hideWhenStopped : Bool = false;
    
    // the last time the lines were drawn
    private var lastDraw : Int = 0;
    
    // the width of the throbber
    private var w : Float;
    
    // the height of the throbber
    private var h : Float;
    
    /**
     * Initializes the throbber with the given width, height, and autoStart values.
     */
    public function new(w : Int = 32, h : Int = 32, lineThickness : Int = 3)
    {
        super();
        this.w = w;
        this.h = h;
        this.lineThickness = lineThickness;
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }
    
    private function addedToStage(event : Event) : Void
    {
        if (autoStart)
        {
            start();
        }
        else if (!hideWhenStopped)
        {
            redraw();
        }
    }
    
    private function removedFromStage(event : Event) : Void
    {
        stop();
    }
    
    private var _running : Bool;
    
    // Returns true when the throbber is animating.
    private function get_running() : Bool
    {
        return _running;
    }
    
    private var _currentStep : Int = 0;
    
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
    
    private var _maxSteps : Int = 12;
    
    // Returns the maximum number of steps in the animation process.
    private function get_maxSteps() : Int
    {
        return _maxSteps;
    }
    
    // Starts the animation.
    public function start() : Void
    {
        if (!_running)
        {
            _running = true;
            redraw();
            addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
        }
    }
    
    // Stops the animation.
    public function stop() : Void
    {
        if (_running)
        {
            _running = false;
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            if (hideWhenStopped)
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
        if (!running)
        {
            if (hideWhenStopped)
            {
                graphics.clear();
            }
            else
            {
                redraw();
            }
        }
    }
    
    private function enterFrameHandler(event : Event) : Void
    {
        if (running)
        {
            var diff : Int = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - lastDraw);
            if (diff > delay)
            {
                nextStep();
            }
        }
    }
    
    private function redraw() : Void
    {
        lastDraw = Math.round(haxe.Timer.stamp() * 1000);
        drawLines();
    }
    
    /**
     * Draws the 12 lines.
     */
    private function drawLines() : Void
    {
        var g : Graphics = graphics;
        g.clear();
        
        var midX : Int = Math.round(w / 2);
        var midY : Int = Math.round(w / 2);
        var radius : Int = Math.min(midX, midY);
        
        if ((radius > 0) && (lineThickness > 0) && (lineAlpha > 0))
        {
            var angle : Float = 0;
            var maxAngle : Float = (2 * Math.PI);
            var incr : Float = maxAngle / maxSteps;
            var lineNum : Int = 0;
            while (angle < maxAngle)
            {
                var color : Int = getColor(lineNum);
                g.lineStyle(lineThickness, color, getAlpha(lineNum), true, null, CapsStyle.ROUND);
                
                // figure out the position around the circle
                var x1 : Float = midX + (radius * Math.sin(angle));
                var y1 : Float = midY - (radius * Math.cos(angle));
                // make a hole in the center, make each line segment be 40% of the radius
                var dr : Int = as3hx.Compat.parseInt(3 * radius / 5);
                var x2 : Float = midX + (dr * Math.sin(angle));
                var y2 : Float = midY - (dr * Math.cos(angle));
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
    private function getColor(lineNum : Int) : Int
    {
        var color : Int = colors[0];
        if (currentStep >= 0)
        {
            var diff : Int = as3hx.Compat.parseInt(currentStep - lineNum);
            if (diff < 0)
            {
                diff += maxSteps;
            }
            var index : Int = Math.min(colors.length - 1, diff);
            color = colors[index];
        }
        return color;
    }
    
    /**
     * Determines the alpha based on which line is being drawn.
     */
    private function getAlpha(lineNum : Int) : Float
    {
        var newAlpha : Float = alphas[0];
        if (currentStep >= 0)
        {
            var diff : Int = as3hx.Compat.parseInt(currentStep - lineNum);
            if (diff < 0)
            {
                diff += maxSteps;
            }
            var index : Int = Math.min(alphas.length - 1, diff);
            newAlpha = alphas[index];
        }
        return newAlpha;
    }
}

