package classes.mp.components.userlist;

import classes.Language;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.ui.IScrollPane;
import classes.ui.Text;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.ui.ContextMenu;

class MPUserlistScrollpane extends Sprite implements IScrollPane
{
    public var doScroll(get, never)                             : Dynamic;
    public var scrollFactorVertical(get, never)                             : Dynamic;

    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var _width                             : Dynamic= 100;
    private var _height                             : Dynamic= 100;
    
    private var entryButtons                             : Dynamic= new Array<MPUserListEntry>();
    private var renderElements                             : Dynamic;
    private var renderCount                             : Dynamic= 0;
    
    private var _scrollY                             : Dynamic= 0;
    private var _calcHeight                             : Dynamic= 0;
    
    private var _helper_text                             : Dynamic;
    
    private var roomContextMenu                             : Dynamic;
    
    public function new(parent                             : Dynamic, xpos                             : Dynamic, ypos                             : Dynamic, wid                             : Dynamic, hei                             : Dynamic)
    {
        super();
        _width = wid;
        _height = hei;
        x = xpos;
        y = ypos;
        parent.addChild(this);
        
        scrollRect = new Rectangle(-1, -1, _width + 1, _height);
        
        this.graphics.beginFill(0xFF0000, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        _helper_text = new Text(this, 0, 0, Language.instance.string("mp_user_no_entries_visible"));
        _helper_text.setAreaParams(_width, _height, "center");
    }
    
    /**
     * Sets the data for the Server Browser to use as a reference for drawing.
     * @param list Array on MPUser Items to use.
     */
    public function setRenderList(list                             : Dynamic, sortList                             : Dynamic= true) : Void
    {
        clearButtons(true);
        
        var i                             : Dynamic= null;
        
        _helper_text.visible = (list.length <= 0);
        
        renderCount = list.length;
        
        if (as3hx.Compat.truthy(sortList))
        {
            as3hx.Compat.sortOn(list, ["name"], [as3hx.Compat.ARRAY_CASEINSENSITIVE]);
        }
        
        _scrollY = 0;
        _calcHeight = as3hx.Compat.parseInt(renderCount * MPUserListEntry.ENTRY_HEIGHT);
        
        renderElements = new Array<MPUser>();
        for (i in 0...list.length)
        {
            renderElements[i] = list[i];
        }
        
        updateChildrenVisibility();
    }
    
    /**
     * Creates and Removes User Buttons from the stage, depending on the scroll position.
     * This method uses Pooling on User Buttons to minimize the amount of UserButtons
     * created on screen.
     */
    public function updateChildrenVisibility() : Void
    {
        if (as3hx.Compat.truthy(renderElements == null || renderElements.length == 0))
        {
            return;
        }
        
        var i                             : Dynamic= null;
        
        var entryButton                             : Dynamic= null;
        var _y                             : Dynamic= null;
        var _inBounds                             : Dynamic= null;
        var entryObject                             : Dynamic= null;
        
        var GAP                             : Dynamic= MPUserListEntry.ENTRY_HEIGHT;
        var startingIndex                             : Dynamic= Math.max(0, Math.floor((_scrollY * -1) / GAP) - 1);
        var lastIndex                             : Dynamic= Math.min(renderCount, startingIndex + (height / GAP) + 3);
        var START_POINT                             : Dynamic= as3hx.Compat.parseInt(_scrollY);
        
        // Update Existing
        var len                             : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
        i = len;
        while (as3hx.Compat.truthy(i >= 0))
        {
            entryButton = entryButtons[i];
            entryButton.isStale = true;
            
            _y = START_POINT + entryButton.index * GAP;
            _inBounds = (_y > -GAP && _y < height);
            
            // Unlink UserButton no longer on stage.
            if (as3hx.Compat.truthy(!_inBounds))
            {
                removeEntryButton(entryButton);
            }
            // Update Position
            else
            {
                
                moveEntryButton(_y, entryButton);
            }
            i--;
        }
        
        // Add New User Buttons
        for (i in startingIndex...lastIndex)
        {
            entryObject = renderElements[i];
            
            // Check for Existing Button
            if (as3hx.Compat.truthy(findEntryButton(entryObject) != null))
            {
                continue;
            }
            
            // Create User Button
            _y = START_POINT + i * GAP;
            _inBounds = (_y > -GAP && _y < height);
            
            if (as3hx.Compat.truthy(_inBounds))
            {
                entryButton = getEntryButton();
                entryButton.index = i;
                entryButton.setData(entryObject);
                
                if (as3hx.Compat.truthy(roomContextMenu != null))
                {
                    entryButton.contextMenu = roomContextMenu;
                }
                
                this.addChild(entryButton);
                moveEntryButton(_y, entryButton);
                entryButtons[entryButtons.length] = entryButton;
            }
        }
        
        // Remove Old User Buttons
        len = as3hx.Compat.parseInt(entryButtons.length - 1);
        i = len;
        while (as3hx.Compat.truthy(i >= 0))
        {
            entryButton = entryButtons[i];
            if (as3hx.Compat.truthy(entryButton.isStale))
            {
                removeEntryButton(entryButton);
            }
            i--;
        }
    }
    
    /**
     * Moves the MPUserListEntry to the y value. Also marks the song button
     * as in use for the removal sweep.
     * @param _y
     * @param btn
     */
    public function moveEntryButton(_y                             : Dynamic, btn                             : Dynamic) : Void
    {
        btn.y = _y;
        btn.isStale = false;
    }
    
    /**
     * Finds the on stage MPUserListEntry for the given MPUser.
     * @param room MPUser to look for.
     * @return If a MPUserListEntry exist already for this room.
     */
    public function findEntryButton(room                             : Dynamic) : MPUserListEntry
    {
        if (as3hx.Compat.truthy(entryButtons.length == 0))
        {
            return null;
        }
        
        var len                             : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            if (as3hx.Compat.truthy(entryButtons[len].user == room))
            {
                return entryButtons[len];
            }
            len--;
        }
        return null;
    }
    
    /**
     * Removes the MPUserListEntry from stage, along with moving it
     * back into the object pool.
     * @param btn MPUserListEntry to remove.
     */
    public function removeEntryButton(btn                             : Dynamic) : Void
    {
        var idx                             : Dynamic= Lambda.indexOf(entryButtons, btn);
        if (as3hx.Compat.truthy(idx >= 0))
        {
            entryButtons.splice(idx, 1);
        }
        
        btn.parent.removeChild(btn);
        putEntryButton(btn);
    }
    
    /**
     * Clears the component of old data.
     */
    public function clear() : Void
    {
        clearButtons(true);
        
        renderCount = 0;
        renderElements = null;
        _calcHeight = 0;
    }
    
    /**
     * Removes all MPUserListEntrys from the stage.
     * @param force Force Remove, regardless of sweep value.
     */
    public function clearButtons(force                             : Dynamic= false) : Void
    {
        var entryButton                             : Dynamic= null;
        
        // Remove Old Entry Buttons
        var len                             : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            entryButton = entryButtons[len];
            if (as3hx.Compat.truthy(entryButton.isStale || force))
            {
                removeEntryButton(entryButton);
            }
            len--;
        }
    }
    
    /**
     * Check the requirement if scrolling should happen.
     * @return
     */
    private function get_doScroll() : Bool
    {
        return _calcHeight > _height;
    }
    
    /**
     * Gets the current vertical scroll factor.
     * Scroll factor is the percent of the height the scrollpane is compared to the overall content height.
     */
    private function get_scrollFactorVertical() : Float
    {
        return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(height / _calcHeight, 1), 0), 0));
    }
    
    public function scrollTo(val                             : Dynamic) : Void
    {
        _scrollY = -((_calcHeight - _height) * Math.max(Math.min(val, 1), 0));
        updateChildrenVisibility();
    }
    
    /**
     *
     * Gets the vertical scroll value required to display a specified child.
     * @param	child Child to show.
     * @return	Scroll Value required to show child in center of scroll pane.
     */
    public function scrollChildVertical(child                             : Dynamic) : Float
    // Checks
    {
        
        if (as3hx.Compat.truthy(child == null || !this.contains(child) || !doScroll))
        {
            return 0;
        }
        
        var _y                             : Dynamic= as3hx.Compat.parseInt((try cast(child, MPUserListEntry) catch(e:Dynamic) null).index * (MPUserListEntry.ENTRY_HEIGHT + 5));  // Calculate Real Y.  
        
        // Child is to tall, Scroll to top.
        if (as3hx.Compat.truthy(child.height > height))
        {
            return Math.max(Math.min(_y / (_calcHeight - _height), 1), 0);
        }
        
        return Math.max(Math.min(((_y + (child.height / 2)) - (_height / 2)) / (_calcHeight - _height), 1), 0);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /** MPUserListEntry Pool Vector */
    private static var __vectorMPUserListEntry                             : Dynamic= new Array<MPUserListEntry>();
    
    /** Retrieves a UserButton instance from the pool. */
    public static function getEntryButton() : MPUserListEntry
    {
        if (as3hx.Compat.truthy(__vectorMPUserListEntry.length == 0))
        {
            return new MPUserListEntry();
        }
        else
        {
            return __vectorMPUserListEntry.pop();
        }
    }
    
    /** Stores a MPUserListEntry instance in the pool.
     *  Don't keep any references to the object after moving it to the pool! */
    public static function putEntryButton(roomButton                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(roomButton != null))
        {
            roomButton.clear();
            __vectorMPUserListEntry[__vectorMPUserListEntry.length] = roomButton;
        }
    }
}

