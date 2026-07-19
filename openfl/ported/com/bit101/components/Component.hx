/**
 * Component.as
 * Keith Peters
 * version 0.9.10
 *
 * Base class for all components
 *
 * Copyright (c) 2011 Keith Peters
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 *
 * Components with text make use of the font PF Ronda Seven by Yuusuke Kamiyamane
 * This is a free font obtained from http://www.dafont.com/pf-ronda-seven.font
 */

package com.bit101.components;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.filters.DropShadowFilter;

@:meta(Event(name="resize",type="openfl.events.Event"))

@:meta(Event(name="draw",type="openfl.events.Event"))

class Component extends Sprite
{
    public var tag(get, set)                            : Dynamic;
    public var enabled(get, set)                            : Dynamic;

    // NOTE: Flex 4 introduces DefineFont4, which is used by default and does not work in native text fields.
    // Use the embedAsCFF="false" param to switch back to DefineFont4. In earlier Flex 4 SDKs this was cff="false".
    // So if you are using the Flex 3.x sdk compiler, switch the embed statment below to expose the correct version.
    
    // Flex 4.7 (labs/beta) sdk:
    // SWF generated with fontswf utility bundled with the AIR SDK released on labs.adobe.com with Flash Builder 4.7 (including ASC 2.0)
    //[Embed(source="../../../../assets/pf_ronda_seven.swf", symbol="PF Ronda Seven")]
    
    // Flex 4.x sdk:
    //		[Embed(source="/assets/pf_ronda_seven.ttf", embedAsCFF="false", fontName="PF Ronda Seven", mimeType="application/x-font")]
    // Flex 3.x sdk:
    //		[Embed(source="/assets/pf_ronda_seven.ttf", fontName="PF Ronda Seven", mimeType="application/x-font")]
    public var Ronda                            : Dynamic;
    
    public var _width                            : Dynamic= 0;
    public var _height                            : Dynamic= 0;
    public var _tag                            : Dynamic= -1;
    public var _enabled                            : Dynamic= true;
    
    public static inline var DRAW                            : Dynamic= "draw";
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this component.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     */
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0)
    {
        super();
        move(xpos, ypos);
        init();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
    }
    
    /**
     * Initilizes the component.
     */
    public function init() : Void
    {
        addChildren();
        invalidate();
    }
    
    /**
     * Overriden in subclasses to create child display objects.
     */
    public function addChildren() : Void
    {
    }
    
    /**
     * Marks the component to be redrawn on the next frame.
     */
    override public function invalidate() : Void
    //			draw();
    {
        
        addEventListener(Event.ENTER_FRAME, onInvalidate);
    }
    
    
    
    
    ///////////////////////////////////
    // public methods
    ///////////////////////////////////
    
    /**
     * Utility method to set up usual stage align and scaling.
     */
    public static function initStage(stage                            : Dynamic) : Void
    {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
    }
    
    /**
     * Moves the component to the specified position.
     * @param xpos the x position to move the component
     * @param ypos the y position to move the component
     */
    public function move(xpos                            : Dynamic, ypos                            : Dynamic) : Void
    {
        x = Math.round(xpos);
        y = Math.round(ypos);
    }
    
    /**
     * Sets the size of the component.
     * @param w The width of the component.
     * @param h The height of the component.
     */
    public function setSize(w                            : Dynamic, h                            : Dynamic) : Void
    {
        _width = w;
        _height = h;
        dispatchEvent(new Event(Event.RESIZE));
        invalidate();
    }
    
    /**
     * Abstract draw function.
     */
    public function draw() : Void
    {
        dispatchEvent(new Event(Component.DRAW));
    }
    
    
    
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Called one frame after invalidate is called.
     */
    public function onInvalidate(event                            : Dynamic) : Void
    {
        removeEventListener(Event.ENTER_FRAME, onInvalidate);
        draw();
    }
    
    
    
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Sets/gets the width of the component.
     */
    override private function set_width(w                            : Dynamic) : Float
    {
        _width = w;
        invalidate();
        dispatchEvent(new Event(Event.RESIZE));
        return w;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    /**
     * Sets/gets the height of the component.
     */
    override private function set_height(h                            : Dynamic) : Float
    {
        _height = h;
        invalidate();
        dispatchEvent(new Event(Event.RESIZE));
        return h;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    /**
     * Sets/gets in integer that can identify the component.
     */
    private function set_tag(value                            : Dynamic) : Int
    {
        _tag = value;
        return value;
    }
    
    private function get_tag() : Int
    {
        return _tag;
    }
    
    /**
     * Overrides the setter for x to always place the component on a whole pixel.
     */
    override private function set_x(value                            : Dynamic) : Float
    {
        super.x = Math.round(value);
        return value;
    }
    
    /**
     * Overrides the setter for y to always place the component on a whole pixel.
     */
    override private function set_y(value                            : Dynamic) : Float
    {
        super.y = Math.round(value);
        return value;
    }
    
    /**
     * Sets/gets whether this component is enabled or not.
     */
    private function set_enabled(value                            : Dynamic) : Bool
    {
        _enabled = value;
        mouseEnabled = mouseChildren = _enabled;
        tabEnabled = value;
        alpha = (_enabled) ? 1.0 : 0.5;
        return value;
    }
    
    private function get_enabled() : Bool
    {
        return _enabled;
    }
}

