/**
 * Label.as
 * Keith Peters
 * version 0.9.10
 *
 * A Label component for displaying a single line of text.
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
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

@:meta(Event(name="resize",type="openfl.events.Event"))

class Label extends Component
{
    public var text(get, set)                            : Dynamic;
    public var autoSize(get, set)                            : Dynamic;
    public var html(get, set)                            : Dynamic;
    public var textField(get, never)                            : Dynamic;
    public var fontSize(never, set)                            : Dynamic;

    public var _autoSize                            : Dynamic= true;
    public var _text                            : Dynamic= "";
    public var _html                            : Dynamic= false;
    public var _tf                            : Dynamic;
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this Label.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param text The string to use as the initial text in this component.
     */
    public function new(parent                            : Dynamic= null, xpos                            : Dynamic= 0, ypos                            : Dynamic= 0, text                            : Dynamic= "")
    {
        this.text = text;
        super(parent, xpos, ypos);
    }
    
    /**
     * Initializes the component.
     */
    override public function init() : Void
    {
        super.init();
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    /**
     * Creates and adds the child display objects of this component.
     */
    override public function addChildren() : Void
    {
        _height = 18;
        _tf = new TextField();
        _tf.height = _height;
        _tf.embedFonts = true;
        _tf.selectable = false;
        _tf.mouseEnabled = false;
        _tf.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, 8, 0xFFFFFF);
        _tf.antiAliasType = AntiAliasType.ADVANCED;
        _tf.gridFitType = GridFitType.SUBPIXEL;
        _tf.text = _text;
        addChild(_tf);
        draw();
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
        if (as3hx.Compat.truthy(_html))
        {
            _tf.htmlText = _text;
        }
        else
        {
            _tf.text = _text;
        }
        if (as3hx.Compat.truthy(_autoSize))
        {
            _tf.autoSize = TextFieldAutoSize.LEFT;
            _width = _tf.width;
            dispatchEvent(new Event(Event.RESIZE));
        }
        else
        {
            _tf.autoSize = TextFieldAutoSize.NONE;
            _tf.width = _width;
        }
        _height = _tf.height = 18;
    }
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Gets / sets the text of this Label.
     */
    private function set_text(t                            : Dynamic) : String
    {
        _text = t;
        if (as3hx.Compat.truthy(_text == null))
        {
            _text = "";
        }
        invalidate();
        return t;
    }
    
    private function get_text() : String
    {
        return _text;
    }
    
    /**
     * Gets / sets whether or not this Label will autosize.
     */
    private function set_autoSize(b                            : Dynamic) : Bool
    {
        _autoSize = b;
        return b;
    }
    
    private function get_autoSize() : Bool
    {
        return _autoSize;
    }
    
    /**
     * Gets / sets whether or not text will be rendered as HTML or plain text.
     */
    private function set_html(b                            : Dynamic) : Bool
    {
        _html = b;
        invalidate();
        return b;
    }
    
    private function get_html() : Bool
    {
        return _html;
    }
    
    /**
     * Gets the internal TextField of the label if you need to do further customization of it.
     */
    private function get_textField() : TextField
    {
        return _tf;
    }
    
    private function set_fontSize(val                            : Dynamic) : Int
    {
        _tf.defaultTextFormat = new TextFormat(Fonts.BASE_FONT_CJK, val, 0xFFFFFF);
        invalidate();
        return val;
    }
}

