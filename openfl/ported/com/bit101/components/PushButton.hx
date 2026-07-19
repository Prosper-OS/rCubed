/**
 * PushButton.as
 * Keith Peters
 * version 0.9.10
 *
 * A basic button component with a label.
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
 */

package com.bit101.components;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class PushButton extends Component
{
    public var label(get, set)                            : Dynamic;
    public var selected(get, set)                            : Dynamic;
    public var toggle(get, set)                            : Dynamic;
    public var fontSize(never, set)                            : Dynamic;
    public var align(never, set)                            : Dynamic;

    public var _label                            : Dynamic;
    public var _labelText                            : Dynamic= "";
    public var _over                            : Dynamic= false;
    public var _down                            : Dynamic= false;
    public var _selected                            : Dynamic= false;
    public var _toggle                            : Dynamic= false;
    public var _align                            : Dynamic= "left";
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this PushButton.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param label The string to use for the initial label of this component.
     * @param defaultHandler The event handling function to handle the default event for this component (click in this case).
     */
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0, label                            : Dynamic= "", defaultHandler                            : Dynamic= null)
    {
        super(parent, xpos, ypos);
        if (as3hx.Compat.truthy(defaultHandler != null))
        {
            addEventListener(MouseEvent.CLICK, defaultHandler);
        }
        this.label = label;
    }
    
    /**
     * Initializes the component.
     */
    override public function init() : Void
    {
        super.init();
        buttonMode = true;
        useHandCursor = true;
        setSize(100, 20);
    }
    
    /**
     * Creates and adds the child display objects of this component.
     */
    override public function addChildren() : Void
    {
        _label = new Label();
        addChild(_label);
        
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
        addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
    }
    
    /**
     * Draws the face of the button, color based on state.
     */
    public function drawFace() : Void
    {
        this.graphics.clear();
        if (as3hx.Compat.truthy(_down))
        {
            this.graphics.lineStyle(1, 0xFFFFFF, 0.55, true);
            this.graphics.beginFill(0xFFFFFF, 0.1225);
        }
        else
        {
            this.graphics.lineStyle(1, 0xFFFFFF, 0.35, true);
            this.graphics.beginFill(0xFFFFFF, 0.07);
        }
        this.graphics.drawRect(0, 0, _width - 1, _height - 1);
        this.graphics.endFill();
    }
    
    
    ///////////////////////////////////
    // public methods
    ///////////////////////////////////
    
    /**
     * Draws the visual ui of the component.
     */
    override public function draw() : Void
    {
        super.draw();
        
        drawFace();
        
        _label.text = _labelText;
        _label.autoSize = true;
        _label.draw();
        if (as3hx.Compat.truthy(_label.width > _width - 4))
        {
            _label.autoSize = false;
            _label.width = _width - 4;
        }
        else
        {
            _label.autoSize = true;
        }
        _label.draw();
        
        if (as3hx.Compat.truthy(_align == "center"))
        {
            _label.move(_width / 2 - _label.width / 2, _height / 2 - _label.height / 2 - 1);
        }
        else
        {
            _label.move(5, _height / 2 - _label.height / 2 - 1);
        }
    }
    
    
    
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Internal mouseOver handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseOver(event                            : Dynamic) : Void
    {
        _over = true;
        addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
    }
    
    /**
     * Internal mouseOut handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseOut(event                            : Dynamic) : Void
    {
        _over = false;
        removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
    }
    
    /**
     * Internal mouseOut handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseGoDown(event                            : Dynamic) : Void
    {
        _down = true;
        drawFace();
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }
    
    /**
     * Internal mouseUp handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseGoUp(event                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_toggle && _over))
        {
            _selected = !_selected;
        }
        _down = _selected;
        drawFace();
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
    }
    
    
    
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Sets / gets the label text shown on this Pushbutton.
     */
    private function set_label(str                            : Dynamic) : String
    {
        _labelText = str;
        draw();
        return str;
    }
    
    private function get_label() : String
    {
        return _labelText;
    }
    
    private function set_selected(value                            : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(!_toggle))
        {
            value = false;
        }
        
        _selected = value;
        _down = _selected;
        drawFace();
        return value;
    }
    
    private function get_selected() : Bool
    {
        return _selected;
    }
    
    private function set_toggle(value                            : Dynamic) : Bool
    {
        _toggle = value;
        return value;
    }
    
    private function get_toggle() : Bool
    {
        return _toggle;
    }
    
    private function set_fontSize(val                            : Dynamic) : Int
    {
        _label.fontSize = val;
        return val;
    }
    
    private function set_align(dir                            : Dynamic) : String
    {
        _align = dir;
        draw();
        return dir;
    }
}

