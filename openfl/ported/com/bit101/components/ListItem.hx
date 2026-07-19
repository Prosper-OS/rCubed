/**
 * ListItem.as
 * Keith Peters
 * version 0.9.10
 *
 * A single item in a list.
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
import openfl.events.MouseEvent;

class ListItem extends Component
{
    public var data(get, set)                            : Dynamic;
    public var selected(get, set)                            : Dynamic;

    public var _data                            : Dynamic;
    public var _label                            : Dynamic;
    public var _selected                            : Dynamic;
    public var _mouseOver                            : Dynamic= false;
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this ListItem.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param data The string to display as a label or object with a label property.
     */
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0, data                            : Dynamic= null)
    {
        _data = data;
        buttonMode = true;
        super(parent, xpos, ypos);
    }
    
    /**
     * Initilizes the component.
     */
    override public function init() : Void
    {
        super.init();
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        setSize(100, 20);
    }
    
    /**
     * Creates and adds the child display objects of this component.
     */
    override public function addChildren() : Void
    {
        super.addChildren();
        _label = new Label(this, 5, 0);
        _label.fontSize = 11;
        _label.draw();
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
        graphics.clear();
        
        if (as3hx.Compat.truthy(_selected && _mouseOver))
        {
            graphics.beginFill(0xFFFFFF, 0.45);
        }
        else if (as3hx.Compat.truthy(_selected))
        {
            graphics.beginFill(0xFFFFFF, 0.35);
        }
        else if (as3hx.Compat.truthy(_mouseOver))
        {
            graphics.beginFill(0xFFFFFF, 0.25);
        }
        else
        {
            graphics.beginFill(0xFFFFFF, 0.1);
        }
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
        
        if (as3hx.Compat.truthy(_data == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(Std.is(_data, String)))
        {
            _label.text = Std.string(_data);
        }
        else if (as3hx.Compat.truthy(_data.exists("label") && Std.is(_data.label, String)))
        {
            _label.text = _data.label;
        }
        else
        {
            _label.text = Std.string(_data);
        }
    }
    
    
    
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Called when the user rolls the mouse over the item. Changes the background color.
     */
    public function onMouseOver(event                            : Dynamic) : Void
    {
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        _mouseOver = true;
        invalidate();
    }
    
    /**
     * Called when the user rolls the mouse off the item. Changes the background color.
     */
    public function onMouseOut(event                            : Dynamic) : Void
    {
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        _mouseOver = false;
        invalidate();
    }
    
    
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Sets/gets the string that appears in this item.
     */
    private function set_data(value                            : Dynamic) : Dynamic
    {
        _data = value;
        invalidate();
        return value;
    }
    
    private function get_data() : Dynamic
    {
        return _data;
    }
    
    /**
     * Sets/gets whether or not this item is selected.
     */
    private function set_selected(value                            : Dynamic) : Bool
    {
        _selected = value;
        invalidate();
        return value;
    }
    
    private function get_selected() : Bool
    {
        return _selected;
    }
}

