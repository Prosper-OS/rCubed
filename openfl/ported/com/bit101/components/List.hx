/**
 * List.as
 * Keith Peters
 * version 0.9.10
 *
 * A scrolling list of selectable items.
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
import openfl.events.Event;
import openfl.events.MouseEvent;
import assets.GameBackgroundColor;

@:meta(Event(name="select",type="openfl.events.Event"))

class List extends Component
{
    public var selectedIndex(get, set) : Int;
    public var selectedItem(get, set) : Dynamic;
    public var selectedItemByData(never, set) : Dynamic;
    public var listItemHeight(get, set) : Float;
    public var items(get, set) : Array<Dynamic>;
    public var listItemClass(get, set) : Class<Dynamic>;
    public var alternateRows(get, set) : Bool;
    public var autoHideScrollBar(get, set) : Bool;
    public var reduceUpdates(get, set) : Bool;

    private var _items : Array<Dynamic>;
    private var _itemHolder : Sprite;
    private var _panel : Panel;
    private var _listItemHeight : Float = 20;
    private var _listItemClass : Class<Dynamic> = ListItem;
    private var _scrollbar : VScrollBar;
    private var _selectedIndex : Int = -1;
    private var _alternateRows : Bool = false;
    private var _reduceUpdates : Bool = false;
    
    /**
     * Constructor
     * @param parent The parent DisplayObjectContainer on which to add this List.
     * @param xpos The x position to place this component.
     * @param ypos The y position to place this component.
     * @param items An array of items to display in the list. Either strings or objects with label property.
     */
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, items : Array<Dynamic> = null)
    {
        if (items != null)
        {
            _items = items;
        }
        else
        {
            _items = new Array<Dynamic>();
        }
        super(parent, xpos, ypos);
    }
    
    /**
     * Initilizes the component.
     */
    override private function init() : Void
    {
        super.init();
        setSize(100, 100);
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(Event.RESIZE, onResize);
        makeListItems();
        fillItems();
    }
    
    /**
     * Creates and adds the child display objects of this component.
     */
    override private function addChildren() : Void
    {
        super.addChildren();
        _panel = new Panel(this, 0, 0);
        _panel.color = GameBackgroundColor.BG_POPUP;
        _itemHolder = new Sprite();
        _panel.content.addChild(_itemHolder);
        _scrollbar = new VScrollBar(this, 0, 0, onScroll);
        _scrollbar.setSliderParams(0, 0, 0);
    }
    
    /**
     * Creates all the list items based on data.
     */
    private function makeListItems() : Void
    {
        var item : ListItem;
        while (_itemHolder.numChildren > 0)
        {
            item = cast((_itemHolder.getChildAt(0)), ListItem);
            item.removeEventListener(MouseEvent.CLICK, onSelect);
            _itemHolder.removeChildAt(0);
        }
        
        var numItems : Int = Math.ceil(_height / _listItemHeight);
        numItems = Math.min(numItems, _items.length);
        numItems = Math.max(numItems, 1);
        for (i in 0...numItems)
        {
            item = Type.createInstance(_listItemClass, [_itemHolder, 0, i * _listItemHeight]);
            item.setSize(width, _listItemHeight);
            item.addEventListener(MouseEvent.CLICK, onSelect);
        }
    }
    
    private function fillItems() : Void
    {
        var offset : Int = _scrollbar.value;
        var numItems : Int = Math.ceil(_height / _listItemHeight);
        numItems = Math.min(numItems, _items.length);
        for (i in 0...numItems)
        {
            var item : ListItem = try cast(_itemHolder.getChildAt(i), ListItem) catch(e:Dynamic) null;
            if (offset + i < _items.length)
            {
                item.data = _items[offset + i];
            }
            else
            {
                item.data = "";
            }
            if (offset + i == _selectedIndex)
            {
                item.selected = true;
            }
            else
            {
                item.selected = false;
            }
        }
    }
    
    /**
     * If the selected item is not in view, scrolls the list to make the selected item appear in the view.
     */
    private function scrollToSelection() : Void
    {
        var numItems : Int = Math.ceil(_height / _listItemHeight);
        if (_selectedIndex != -1)
        {
            if (_scrollbar.value > _selectedIndex)
            {  //                    _scrollbar.value = _selectedIndex;  
                
            }
            else if (_scrollbar.value + numItems < _selectedIndex)
            {
                _scrollbar.value = _selectedIndex - numItems + 1;
            }
        }
        else
        {
            _scrollbar.value = 0;
        }
        fillItems();
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
        
        _selectedIndex = Math.min(_selectedIndex, _items.length - 1);
        
        
        // panel
        _panel.setSize(_width, _height);
        _panel.draw();
        
        // scrollbar
        _scrollbar.x = _width - 10;
        var contentHeight : Float = _items.length * _listItemHeight;
        _scrollbar.setThumbPercent(_height / contentHeight);
        var pageSize : Float = Math.floor(_height / _listItemHeight);
        _scrollbar.maximum = Math.max(0, _items.length - pageSize);
        _scrollbar.pageSize = pageSize;
        _scrollbar.height = _height;
        _scrollbar.draw();
        scrollToSelection();
    }
    
    /**
     * Adds an item to the list.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     */
    public function addItem(item : Dynamic) : Void
    {
        _items.push(item);
        invalidate();
        makeListItems();
        fillItems();
    }
    
    /**
     * Adds an item to the list at the specified index.
     * @param item The item to add. Can be a string or an object containing a string property named label.
     * @param index The index at which to add the item.
     */
    public function addItemAt(item : Dynamic, index : Int) : Void
    {
        index = Math.max(0, index);
        index = Math.min(_items.length, index);
        as3hx.Compat.arraySplice(_items, index, 0, [item]);
        invalidate();
        makeListItems();
        fillItems();
    }
    
    /**
     * Removes the referenced item from the list.
     * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
     */
    public function removeItem(item : Dynamic) : Void
    {
        var index : Int = Lambda.indexOf(_items, item);
        removeItemAt(index);
    }
    
    /**
     * Removes the item from the list at the specified index
     * @param index The index of the item to remove.
     */
    public function removeItemAt(index : Int) : Void
    {
        if (index < 0 || index >= _items.length)
        {
            return;
        }
        _items.splice(index, 1);
        invalidate();
        makeListItems();
        fillItems();
    }
    
    /**
     * Removes all items from the list.
     */
    public function removeAll() : Void
    {
        as3hx.Compat.setArrayLength(_items, 0);
        invalidate();
        makeListItems();
        fillItems();
    }
    
    
    
    
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Called when a user selects an item in the list.
     */
    private function onSelect(event : Event) : Void
    {
        if (!(Std.is(event.target, ListItem)))
        {
            return;
        }
        
        var offset : Int = _scrollbar.value;
        
        for (i in 0..._itemHolder.numChildren)
        {
            if (_itemHolder.getChildAt(i) == event.target)
            {
                _selectedIndex = as3hx.Compat.parseInt(i + offset);
            }
            cast((_itemHolder.getChildAt(i)), ListItem).selected = false;
        }
        cast((event.target), ListItem).selected = true;
        dispatchEvent(new Event(Event.SELECT));
    }
    
    /**
     * Called when the user scrolls the scroll bar.
     */
    private function onScroll(event : Event) : Void
    {
        fillItems();
    }
    
    /**
     * Called when the mouse wheel is scrolled over the component.
     */
    private function onMouseWheel(event : MouseEvent) : Void
    {
        _scrollbar.value -= event.delta;
        fillItems();
    }
    
    private function onResize(event : Event) : Void
    {
        makeListItems();
        fillItems();
    }
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    
    /**
     * Sets / gets the index of the selected list item.
     */
    private function set_selectedIndex(value : Int) : Int
    {
        if (value >= 0 && value < _items.length)
        {
            _selectedIndex = value;
        }
        else
        {
            _selectedIndex = -1;
        }
        invalidate();
        dispatchEvent(new Event(Event.SELECT));
        return value;
    }
    
    private function get_selectedIndex() : Int
    {
        return _selectedIndex;
    }
    
    /**
     * Sets / gets the item in the list, if it exists.
     */
    private function set_selectedItem(item : Dynamic) : Dynamic
    {
        var index : Int = Lambda.indexOf(_items, item);
        //			if(index != -1)
        //			{
        selectedIndex = index;
        invalidate();
        dispatchEvent(new Event(Event.SELECT));
        return item;
    }
    
    private function get_selectedItem() : Dynamic
    {
        if (_selectedIndex >= 0 && _selectedIndex < _items.length)
        {
            return _items[_selectedIndex];
        }
        return null;
    }
    
    private function set_selectedItemByData(item : Dynamic) : Dynamic
    {
        for (i in 0..._items.length)
        {
            var it : Dynamic = _items[i];
            if ((Std.is(it, String) || Std.is(it, Float)) && it == item)
            {
                selectedIndex = i;
                break;
            }
            else if (it.exists("data") && it.data == item)
            {
                selectedIndex = i;
                break;
            }
        }
        return item;
    }
    
    
    /**
     * Sets the height of each list item.
     */
    private function set_listItemHeight(value : Float) : Float
    {
        _listItemHeight = value;
        makeListItems();
        invalidate();
        return value;
    }
    
    private function get_listItemHeight() : Float
    {
        return _listItemHeight;
    }
    
    /**
     * Sets / gets the list of items to be shown.
     */
    private function set_items(value : Array<Dynamic>) : Array<Dynamic>
    {
        var needsRedraw : Bool = true;
        if (_reduceUpdates)
        {
            needsRedraw = _items.length != value.length;
            if (!needsRedraw)
            {
                var idx : Int = as3hx.Compat.parseInt(_items.length - 1);
                while (idx >= 0)
                {
                    if (_items[idx].label != value[idx].label || _items[idx].data != value[idx].data)
                    {
                        needsRedraw = true;
                        break;
                    }
                    idx--;
                }
            }
        }
        
        if (needsRedraw)
        {
            _items = value;
            invalidate();
            makeListItems();
            fillItems();
        }
        return value;
    }
    
    private function get_items() : Array<Dynamic>
    {
        return _items;
    }
    
    /**
     * Sets / gets the class used to render list items. Must extend ListItem.
     */
    private function set_listItemClass(value : Class<Dynamic>) : Class<Dynamic>
    {
        _listItemClass = value;
        makeListItems();
        invalidate();
        return value;
    }
    
    private function get_listItemClass() : Class<Dynamic>
    {
        return _listItemClass;
    }
    
    /**
     * Sets / gets whether or not every other row will be colored with the alternate color.
     */
    private function set_alternateRows(value : Bool) : Bool
    {
        _alternateRows = value;
        invalidate();
        return value;
    }
    
    private function get_alternateRows() : Bool
    {
        return _alternateRows;
    }
    
    /**
     * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
     */
    private function set_autoHideScrollBar(value : Bool) : Bool
    {
        _scrollbar.autoHide = value;
        return value;
    }
    
    private function get_autoHideScrollBar() : Bool
    {
        return _scrollbar.autoHide;
    }
    
    /**
     * Sets / gets whether the setting a new list directly should check for changes.
     */
    private function set_reduceUpdates(value : Bool) : Bool
    {
        _reduceUpdates = value;
        return value;
    }
    
    private function get_reduceUpdates() : Bool
    {
        return _reduceUpdates;
    }
}

