/**
 * ComboBox.as
 * Keith Peters
 * version 0.9.10
 *
 * A button that exposes a list of choices and displays the chosen item.
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

import assets.menu.icons.fa.IconLeft;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:meta(Event(name="select",type="openfl.events.Event"))

class ComboBox extends Component
{
    public var selectedIndex(get, set) : Int;
    public var selectedItem(get, set) : Dynamic;
    public var selectedItemByData(never, set) : Dynamic;
    public var listItemHeight(get, set) : Float;
    public var openPosition(get, set) : String;
    public var defaultLabel(get, set) : String;
    public var numVisibleItems(get, set) : Int;
    public var items(get, set) : Array<Dynamic>;
    public var listItemClass(get, set) : Class<Dynamic>;
    public var alternateRows(get, set) : Bool;
    public var autoHideScrollBar(get, set) : Bool;
    public var isOpen(get, never) : Bool;
    public var fontSize(never, set) : Int;

    public static inline var TOP : String = "top";
    public static inline var BOTTOM : String = "bottom";
    
    private var _defaultLabel : String = "";
    private var _items : Array<Dynamic>;
    private var _labelButton : PushButton;
    private var _divider : Sprite;
    private var _triangle : IconLeft;
    private var _list : List;
    private var _numVisibleItems : Int = 6;
    private var _open : Bool = false;
    private var _openPosition : String = BOTTOM;
    private var _stage : Stage;
    
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this List.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param defaultLabel The label to show when no item is selected.
     * @param items An array of items to display in the list. Either strings or objects with label property.
     */
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, defaultLabel : String = "", items : Array<Dynamic> = null)
    {
        _defaultLabel = defaultLabel;
        _items = items;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        super(parent, xpos, ypos);
    }
    
    /**
     * Initilizes the component.
     */
    override private function init() : Void
    {
        super.init();
        setSize(100, 22);
        setLabelButtonLabel();
    }
    
    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren() : Void
    {
        super.addChildren();
        _list = new List(null, 0, 0, _items);
        _list.autoHideScrollBar = true;
        _list.addEventListener(Event.SELECT, onSelect);
        
        if (_items != null)
        {
            numVisibleItems = Math.min(6, Math.max(1, _items.length));
        }
        
        _labelButton = new PushButton(this, 0, 0, "", onDropDown);
        
        _divider = new Sprite();
        _divider.mouseEnabled = false;
        addChild(_divider);
        
        _triangle = new IconLeft();
        _triangle.mouseEnabled = false;
        _triangle.scaleX = _triangle.scaleY = 0.15;
        _triangle.rotation = -90;
        _triangle.alpha = 0.75;
        addChild(_triangle);
    }
    
    /**
     * Determines what to use for the main button label and sets it.
     */
    private function setLabelButtonLabel() : Void
    {
        if (selectedItem == null)
        {
            _labelButton.label = _defaultLabel;
        }
        else if (Std.is(selectedItem, String))
        {
            _labelButton.label = Std.string(selectedItem);
        }
        else if (selectedItem.exists("label") && Std.is(selectedItem.label, String))
        {
            _labelButton.label = selectedItem.label;
        }
        else
        {
            _labelButton.label = Std.string(selectedItem);
        }
    }
    
    /**
     * Removes the list from the stage.
     */
    private function removeList() : Void
    {
        if (_stage.contains(_list))
        {
            _stage.removeChild(_list);
        }
        _stage.removeEventListener(MouseEvent.CLICK, onStageClick);
        _triangle.scaleX = 0.15;
    }
    
    
    
    ///////////////////////////////////
    // public methods
    ///////////////////////////////////
    
    override public function draw() : Void
    {
        super.draw();
        _labelButton.setSize(_width, _height);
        _labelButton.draw();
        
        _divider.x = _width - 20;
        _divider.graphics.clear();
        _divider.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        _divider.graphics.moveTo(0, 1);
        _divider.graphics.lineTo(0, _height - 1);
        
        _triangle.x = _width - 10;
        _triangle.y = _height / 2;
        
        _list.setSize(_width - 1, _numVisibleItems * _list.listItemHeight);
    }
    
    
    /**
     * Adds an item to the list.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     */
    public function addItem(item : Dynamic) : Void
    {
        _list.addItem(item);
    }
    
    /**
     * Adds an item to the list at the specified index.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     * @param index The index at which to add the item.
     */
    public function addItemAt(item : Dynamic, index : Int) : Void
    {
        _list.addItemAt(item, index);
    }
    
    /**
     * Removes the referenced item from the list.
     * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
     */
    public function removeItem(item : Dynamic) : Void
    {
        _list.removeItem(item);
    }
    
    /**
     * Removes the item from the list at the specified index
     * @param index The index of the item to remove.
     */
    public function removeItemAt(index : Int) : Void
    {
        _list.removeItemAt(index);
    }
    
    /**
     * Removes all items from the list.
     */
    public function removeAll() : Void
    {
        _list.removeAll();
    }
    
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Called when one of the top buttons is pressed. Either opens or closes the list.
     */
    private function onDropDown(event : MouseEvent) : Void
    {
        _open = !_open;
        if (_open)
        {
            var point : Point = new Point();
            if (_openPosition == BOTTOM)
            {
                point.y = _height;
            }
            else
            {
                point.y = -_numVisibleItems * _list.listItemHeight;
            }
            point = this.localToGlobal(point);
            
            // check for off stage
            if (_openPosition == BOTTOM && (point.y + (_numVisibleItems * _list.listItemHeight)) > _stage.stageHeight)
            {
                point.x = 0;
                point.y = -_numVisibleItems * _list.listItemHeight;
                point = this.localToGlobal(point);
            }
            
            _list.move(point.x, point.y);
            _stage.addChild(_list);
            _stage.addEventListener(MouseEvent.CLICK, onStageClick);
            _triangle.scaleX = -0.15;
        }
        else
        {
            removeList();
        }
    }
    
    /**
     * Called when the mouse is clicked somewhere outside of the combo box when the list is open. Closes the list.
     */
    private function onStageClick(event : MouseEvent) : Void
    // ignore clicks within buttons or list
    {
        
        if (event.target == _labelButton)
        {
            return;
        }
        if (new Rectangle(_list.x, _list.y, _list.width, _list.height).contains(event.stageX, event.stageY))
        {
            return;
        }
        
        _open = false;
        removeList();
    }
    
    /**
     * Called when an item in the list is selected. Displays that item in the label button.
     */
    private function onSelect(event : Event) : Void
    {
        _open = false;
        _triangle.scaleX = 0.15;
        if (stage != null && stage.contains(_list))
        {
            stage.removeChild(_list);
        }
        setLabelButtonLabel();
        dispatchEvent(event);
    }
    
    /**
     * Called when the component is added to the stage.
     */
    private function onAddedToStage(event : Event) : Void
    {
        _stage = stage;
    }
    
    /**
     * Called when the component is removed from the stage.
     */
    private function onRemovedFromStage(event : Event) : Void
    {
        removeList();
    }
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Sets / gets the index of the selected list item.
     */
    private function set_selectedIndex(value : Int) : Int
    {
        _list.selectedIndex = value;
        setLabelButtonLabel();
        return value;
    }
    
    private function get_selectedIndex() : Int
    {
        return _list.selectedIndex;
    }
    
    /**
     * Sets / gets the item in the list, if it exists.
     */
    private function set_selectedItem(item : Dynamic) : Dynamic
    {
        _list.selectedItem = item;
        setLabelButtonLabel();
        return item;
    }
    
    private function get_selectedItem() : Dynamic
    {
        return _list.selectedItem;
    }
    
    private function set_selectedItemByData(item : Dynamic) : Dynamic
    {
        _list.selectedItemByData = item;
        setLabelButtonLabel();
        return item;
    }
    
    /**
     * Sets the height of each list item.
     */
    private function set_listItemHeight(value : Float) : Float
    {
        _list.listItemHeight = value;
        invalidate();
        return value;
    }
    
    private function get_listItemHeight() : Float
    {
        return _list.listItemHeight;
    }
    
    /**
     * Sets / gets the position the list will open on: top or bottom.
     */
    private function set_openPosition(value : String) : String
    {
        _openPosition = value;
        return value;
    }
    
    private function get_openPosition() : String
    {
        return _openPosition;
    }
    
    /**
     * Sets / gets the label that will be shown if no item is selected.
     */
    private function set_defaultLabel(value : String) : String
    {
        _defaultLabel = value;
        setLabelButtonLabel();
        return value;
    }
    
    private function get_defaultLabel() : String
    {
        return _defaultLabel;
    }
    
    /**
     * Sets / gets the number of visible items in the drop down list. i.e. the height of the list.
     */
    private function set_numVisibleItems(value : Int) : Int
    {
        _numVisibleItems = Math.max(1, value);
        invalidate();
        return value;
    }
    
    private function get_numVisibleItems() : Int
    {
        return _numVisibleItems;
    }
    
    /**
     * Sets / gets the list of items to be shown.
     */
    private function set_items(value : Array<Dynamic>) : Array<Dynamic>
    {
        _list.items = value;
        return value;
    }
    
    private function get_items() : Array<Dynamic>
    {
        return _list.items;
    }
    
    /**
     * Sets / gets the class used to render list items. Must extend ListItem.
     */
    private function set_listItemClass(value : Class<Dynamic>) : Class<Dynamic>
    {
        _list.listItemClass = value;
        return value;
    }
    
    private function get_listItemClass() : Class<Dynamic>
    {
        return _list.listItemClass;
    }
    
    /**
     * Sets / gets whether or not every other row will be colored with the alternate color.
     */
    private function set_alternateRows(value : Bool) : Bool
    {
        _list.alternateRows = value;
        return value;
    }
    
    private function get_alternateRows() : Bool
    {
        return _list.alternateRows;
    }
    
    /**
     * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
     */
    private function set_autoHideScrollBar(value : Bool) : Bool
    {
        _list.autoHideScrollBar = value;
        invalidate();
        return value;
    }
    
    private function get_autoHideScrollBar() : Bool
    {
        return _list.autoHideScrollBar;
    }
    
    /**
     * Gets whether or not the combo box is currently open.
     */
    private function get_isOpen() : Bool
    {
        return _open;
    }
    
    private function set_fontSize(val : Int) : Int
    {
        _labelButton.fontSize = val;
        invalidate();
        return val;
    }
}

