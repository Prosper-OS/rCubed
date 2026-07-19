package popups.replays;

import classes.Language;
import classes.replay.Replay;
import classes.ui.IScrollPane;
import classes.ui.Text;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class ReplayHistoryScrollpane extends Sprite implements IScrollPane
{
    public var doScroll(get, never)                       : Dynamic;
    public var scrollFactorVertical(get, never)                       : Dynamic;

    private var _width                       : Dynamic= 100;
    private var _height                       : Dynamic= 100;
    
    private var entryButtons                       : Dynamic= new Array<ReplayHistoryEntry>();
    private var renderElements                       : Dynamic;
    private var renderCount                       : Dynamic= 0;
    
    private var _scrollY                       : Dynamic= 0;
    private var _calcHeight                       : Dynamic= 0;
    
    private var _helper_text                       : Dynamic;
    
    public function new(parent                       : Dynamic, xpos                       : Dynamic, ypos                       : Dynamic, wid                       : Dynamic, hei                       : Dynamic)
    {
        super();
        _width = wid;
        _height = hei;
        x = xpos;
        y = ypos;
        parent.addChild(this);
        
        scrollRect = new Rectangle(-1, -1, _width + 1, _height);
        
        this.graphics.beginFill(0x000000, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        _helper_text = new Text(this, 0, 0, Language.instance.string("replay_no_entries_visible"));
        _helper_text.setAreaParams(_width, _height, "center");
    }
    
    /**
     * Sets the data for the Song Selector to use as a reference for drawing.
     * @param list Array on EngineLevel Items to use.
     */
    public function setRenderList(list                       : Dynamic, sortList                       : Dynamic= true) : Void
    {
        clearButtons(true);
        
        var i                       : Dynamic= null;
        
        _helper_text.visible = (list.length <= 0);
        
        renderCount = list.length;
        
        if (as3hx.Compat.truthy(sortList))
        {
            as3hx.Compat.sortOn(list, ["songname", "score"], [as3hx.Compat.ARRAY_CASEINSENSITIVE, as3hx.Compat.ARRAY_NUMERIC | as3hx.Compat.ARRAY_DESCENDING]);
        }
        
        _scrollY = 0;
        _calcHeight = as3hx.Compat.parseInt((renderCount * (5 + ReplayHistoryEntry.ENTRY_HEIGHT)) + 5);
        
        renderElements = new Array<Replay>();
        for (i in 0...list.length)
        {
            renderElements[i] = list[i];
        }
        
        updateChildrenVisibility();
    }
    
    /**
     * Creates and Removes Song Buttons from the stage, depending on the scroll position.
     * This method uses Pooling on Song Buttons to minimize the amount of SongButtons
     * created on screen.
     */
    public function updateChildrenVisibility() : Void
    {
        if (as3hx.Compat.truthy(renderElements == null || renderElements.length == 0))
        {
            return;
        }
        
        var i                       : Dynamic= null;
        
        var entryButton                       : Dynamic= null;
        var _y                       : Dynamic= null;
        var _inBounds                       : Dynamic= null;
        var entryObject                       : Dynamic= null;
        
        var GAP                       : Dynamic= as3hx.Compat.parseInt(ReplayHistoryEntry.ENTRY_HEIGHT + 5);
        var startingIndex                       : Dynamic= Math.max(0, Math.floor((_scrollY * -1) / GAP) - 1);
        var lastIndex                       : Dynamic= Math.min(renderCount, startingIndex + (height / GAP) + 3);
        var START_POINT                       : Dynamic= as3hx.Compat.parseInt(_scrollY + 5);
        
        // Update Existing
        var len                       : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
        i = len;
        while (as3hx.Compat.truthy(i >= 0))
        {
            entryButton = entryButtons[i];
            entryButton.isStale = true;
            
            _y = START_POINT + entryButton.index * GAP;
            _inBounds = (_y > -GAP && _y < height);
            
            // Unlink SongButton no longer on stage.
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
        
        // Add New Song Buttons
        for (i in startingIndex...lastIndex)
        {
            entryObject = renderElements[i];
            
            // Check for Existing Button
            if (as3hx.Compat.truthy(findEntryButton(entryObject) != null))
            {
                continue;
            }
            
            // Create Song Button
            _y = START_POINT + i * GAP;
            _inBounds = (_y > -GAP && _y < height);
            
            if (as3hx.Compat.truthy(_inBounds))
            {
                entryButton = getEntryButton();
                entryButton.index = i;
                entryButton.setData(entryObject);
                //songButton.highlight = (songObject == selectedSongData);
                this.addChild(entryButton);
                moveEntryButton(_y, entryButton);
                entryButtons[entryButtons.length] = entryButton;
            }
        }
        
        // Remove Old Song Buttons
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
     * Moves the ReplayHistoryEntry to the y value. Also marks the song button
     * as in use for the removal sweep.
     * @param _y
     * @param btn
     */
    public function moveEntryButton(_y                       : Dynamic, btn                       : Dynamic) : Void
    {
        btn.y = _y;
        btn.isStale = false;
    }
    
    /**
     * Finds the on stage ReplayHistoryEntry for the given Replay.
     * @param replay Replay to look for.
     * @return If a ReplayHistoryEntry exist already for this replay.
     */
    public function findEntryButton(replay                       : Dynamic) : ReplayHistoryEntry
    {
        if (as3hx.Compat.truthy(entryButtons.length == 0))
        {
            return null;
        }
        
        var len                       : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            if (as3hx.Compat.truthy(entryButtons[len].replay == replay))
            {
                return entryButtons[len];
            }
            len--;
        }
        return null;
    }
    
    /**
     * Removes the ReplayHistoryEntry from stage, along with moving it
     * back into the object pool.
     * @param btn ReplayHistoryEntry to remove.
     */
    public function removeEntryButton(btn                       : Dynamic) : Void
    {
        var idx                       : Dynamic= Lambda.indexOf(entryButtons, btn);
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
     * Removes all ReplayHistoryEntrys from the stage.
     * @param force Force Remove, regardless of sweep value.
     */
    public function clearButtons(force                       : Dynamic= false) : Void
    {
        var entryButton                       : Dynamic= null;
        
        // Remove Old Entry Buttons
        var len                       : Dynamic= as3hx.Compat.parseInt(entryButtons.length - 1);
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
    
    public function scrollTo(val                       : Dynamic) : Void
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
    public function scrollChildVertical(child                       : Dynamic) : Float
    // Checks
    {
        
        if (as3hx.Compat.truthy(child == null || !this.contains(child) || !doScroll))
        {
            return 0;
        }
        
        var _y                       : Dynamic= as3hx.Compat.parseInt((try cast(child, ReplayHistoryEntry) catch(e:Dynamic) null).index * (ReplayHistoryEntry.ENTRY_HEIGHT + 5));  // Calculate Real Y.  
        
        // Child is to tall, Scroll to top.
        if (as3hx.Compat.truthy(child.height > height))
        {
            return Math.max(Math.min(_y / (_calcHeight - _height), 1), 0);
        }
        
        return Math.max(Math.min(((_y + (child.height / 2)) - (_height / 2)) / (_calcHeight - _height), 1), 0);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /** ReplayHistoryEntry Pool Vector */
    private static var __vectorReplayHistoryEntry                       : Dynamic= new Array<ReplayHistoryEntry>();
    
    /** Retrieves a SongButton instance from the pool. */
    public static function getEntryButton() : ReplayHistoryEntry
    {
        if (as3hx.Compat.truthy(__vectorReplayHistoryEntry.length == 0))
        {
            return new ReplayHistoryEntry();
        }
        else
        {
            return __vectorReplayHistoryEntry.pop();
        }
    }
    
    /** Stores a ReplayHistoryEntry instance in the pool.
     *  Don't keep any references to the object after moving it to the pool! */
    public static function putEntryButton(songbutton                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(songbutton != null))
        {
            songbutton.clear();
            __vectorReplayHistoryEntry[__vectorReplayHistoryEntry.length] = songbutton;
        }
    }
}

