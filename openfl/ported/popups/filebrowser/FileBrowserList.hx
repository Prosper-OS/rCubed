package popups.filebrowser;

import classes.ui.ScrollBar;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import popups.filebrowser.FileBrowserItem;
import popups.filebrowser.FileFolder;

class FileBrowserList extends Sprite
{
    public var doScroll(get, never)                       : Dynamic;
    public var scrollFactorVertical(get, never)                       : Dynamic;
    public var scrollVertical(never, set)                       : Dynamic;

    private static var LAST_SCROLL                       : Dynamic= 0;
    
    private var _pane                       : Dynamic;
    
    private var _width                       : Dynamic= 531;
    private var _height                       : Dynamic= 400;
    
    private var sourceElements                       : Dynamic;
    
    private var _vscroll                       : Dynamic;
    private var songButtons                       : Dynamic= new Array<FileBrowserItem>();
    private var renderElements                       : Dynamic= new Array<FileFolder>();
    private var renderCount                       : Dynamic= 0;
    
    private var filter                       : Dynamic;
    private var filterLastTerm                       : Dynamic;
    
    private var _scrollY                       : Dynamic= 0;
    private var _calcHeight                       : Dynamic= 0;
    
    public var activeIndex                       : Dynamic= 0;
    
    public function new(parent                       : Dynamic= null, xpos                       : Dynamic= 0, ypos                       : Dynamic= 0, filter                       : Dynamic= null)
    {
        super();
        tabChildren = tabEnabled = false;
        
        this.x = xpos;
        this.y = ypos;
        this.filter = filter;
        
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        addChildren();
    }
    
    public function addChildren() : Void
    {
        _pane = new Sprite();
        _pane.addEventListener(MouseEvent.MOUSE_WHEEL, e_scrollWheel);
        addChild(_pane);
        
        _vscroll = new ScrollBar(this, _width - 23, 1, 21, _height - 1, null, null, e_scrollVerticalUpdate);
        
        draw();
        
        scrollRect = new Rectangle(0, 0, _width, _height);
    }
    
    public function draw() : Void
    {
        _pane.graphics.clear();
        _pane.graphics.beginFill(0x000000, 0);
        _pane.graphics.drawRect(0, 0, _width, _height);
        _pane.graphics.endFill();
    }
    
    
    /**
     * Sets the data for the Song Selector to use as a reference for drawing.
     * @param list Array on EngineLevel Items to use.
     */
    public function setRenderList(list                       : Dynamic) : Void
    {
        sourceElements = list;
        
        updateList();
    }
    
    public function updateList() : Void
    {
        if (as3hx.Compat.truthy(sourceElements == null || sourceElements.length <= 0))
        {
            return;
        }
        
        clearButtons(true);
        
        var i                       : Dynamic= null;
        var filterList                       : Dynamic= null;
        
        if (as3hx.Compat.truthy(filter.type != null && filter.term != null && filter.term.length >= 2))
        {
            filterLastTerm = filter.term.toLowerCase();
            
            if (as3hx.Compat.truthy(filter.type == "any"))
            {
                filterList = sourceElements.filter(_filterAny);
            }
            else if (as3hx.Compat.truthy(filter.type == "author"))
            {
                filterList = sourceElements.filter(_filterAuthor);
            }
            else if (as3hx.Compat.truthy(filter.type == "name"))
            {
                filterList = sourceElements.filter(_filterName);
            }
            else if (as3hx.Compat.truthy(filter.type == "stepauthor"))
            {
                filterList = sourceElements.filter(_filterStepauthor);
            }
        }
        
        if (as3hx.Compat.truthy(filterList == null))
        {
            filterList = sourceElements;
        }
        
        renderCount = filterList.length;
        
        _scrollY = 0;
        _calcHeight = as3hx.Compat.parseInt(Math.ceil(renderCount) * (5 + FileBrowserItem.FIXED_HEIGHT));
        _vscroll.visible = doScroll;
        
        as3hx.Compat.setArrayLength(renderElements, renderCount);
        for (i in 0...filterList.length)
        {
            renderElements[i] = filterList[i];
        }
        
        // Scroll to last place.
        _vscroll.scrollTo(LAST_SCROLL);
        scrollVertical = LAST_SCROLL;
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
        
        var songButton                       : Dynamic= null;
        var _y                       : Dynamic= null;
        var _inBounds                       : Dynamic= null;
        var songObject                       : Dynamic= null;
        
        var GAP                       : Dynamic= as3hx.Compat.parseInt(FileBrowserItem.FIXED_HEIGHT + 5);
        var startingIndex                       : Dynamic= as3hx.Compat.parseInt(Math.max(0, Math.floor((_scrollY * -1) / GAP) - 1));
        var lastIndex                       : Dynamic= Math.min(renderCount, startingIndex + (Math.ceil(_height / GAP)) + 4);
        var START_POINT                       : Dynamic= as3hx.Compat.parseInt(_scrollY);
        
        // Update Existing
        var len                       : Dynamic= as3hx.Compat.parseInt(songButtons.length - 1);
        i = len;
        while (as3hx.Compat.truthy(i >= 0))
        {
            songButton = songButtons[i];
            songButton.isStale = true;
            
            _y = START_POINT + as3hx.Compat.parseInt(songButton.index) * GAP;
            _inBounds = (_y > -GAP && _y < _height);
            
            // Unlink SongButton no longer on stage.
            if (as3hx.Compat.truthy(!_inBounds))
            {
                removeSongButton(songButton);
            }
            // Update Position
            else
            {
                
                moveSongButton(_y, songButton);
            }
            i--;
        }
        
        // Add New Song Buttons
        for (i in startingIndex...lastIndex)
        {
            songObject = renderElements[i];
            
            // Check for Existing Button
            if (as3hx.Compat.truthy(findSongButton(songObject) != null))
            {
                continue;
            }
            
            // Create Song Button
            _y = START_POINT + i * GAP;
            _inBounds = (_y > -GAP && _y < height);
            
            if (as3hx.Compat.truthy(_inBounds))
            {
                songButton = getSongButton();
                songButton.index = i;
                songButton.setData(songObject);
                
                if (as3hx.Compat.truthy(i == activeIndex))
                {
                    songButton.highlight = true;
                }
                
                _pane.addChild(songButton);
                moveSongButton(_y, songButton);
                songButtons[songButtons.length] = songButton;
            }
        }
        
        // Remove Old Song Buttons
        len = as3hx.Compat.parseInt(songButtons.length - 1);
        i = len;
        while (as3hx.Compat.truthy(i >= 0))
        {
            songButton = songButtons[i];
            if (as3hx.Compat.truthy(songButton.isStale))
            {
                removeSongButton(songButton);
            }
            i--;
        }
    }
    
    /**
     * Moves the FileBrowserItem to the y value. Also marks the song button
     * as in use for the removal sweep.
     * @param _y
     * @param btn
     */
    public function moveSongButton(_y                       : Dynamic, btn                       : Dynamic) : Void
    {
        btn.y = _y;
        btn.isStale = false;
    }
    
    /**
     * Finds the on stage SongButton for the given FileFolder.
     * @param level FileFolder to look for.
     * @return If a FileBrowserItem exist already for this level.
     */
    public function findSongButton(level                       : Dynamic) : FileBrowserItem
    {
        if (as3hx.Compat.truthy(songButtons.length == 0))
        {
            return null;
        }
        
        var len                       : Dynamic= as3hx.Compat.parseInt(songButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            if (as3hx.Compat.truthy(songButtons[len].songData == level))
            {
                return songButtons[len];
            }
            len--;
        }
        return null;
    }
    
    /**
     * Finds the on stage SongButton for the given FileFolder.
     * @param level FileFolder to look for.
     * @return If a FileBrowserItem exist already for this level.
     */
    public function findSongButtonByIndex(index                       : Dynamic) : FileBrowserItem
    {
        if (as3hx.Compat.truthy(songButtons.length == 0))
        {
            return null;
        }
        
        var len                       : Dynamic= as3hx.Compat.parseInt(songButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            if (as3hx.Compat.truthy(songButtons[len].index == index))
            {
                return songButtons[len];
            }
            len--;
        }
        return null;
    }
    
    /**
     * Removes the SongButton from stage, along with moving it
     * back into the object pool.
     * @param btn SongButton to remove.
     */
    public function removeSongButton(btn                       : Dynamic) : Void
    {
        var idx                       : Dynamic= Lambda.indexOf(songButtons, btn);
        if (as3hx.Compat.truthy(idx >= 0))
        {
            songButtons.splice(idx, 1);
        }
        
        btn.parent.removeChild(btn);
        putSongButton(btn);
    }
    
    /**
     * Clears the component of old data.
     */
    public function clear() : Void
    {
        clearButtons();
        
        renderCount = 0;
        renderElements = null;
        _calcHeight = 0;
        _vscroll.visible = false;
        _vscroll.scrollTo(0);
    }
    
    /**
     * Removes all SongButtons from the stage.
     * @param force Force Remove, regardless of sweep value.
     */
    public function clearButtons(force                       : Dynamic= false) : Void
    {
        var songButton                       : Dynamic= null;
        
        // Remove Old Song Buttons
        var len                       : Dynamic= as3hx.Compat.parseInt(songButtons.length - 1);
        while (as3hx.Compat.truthy(len >= 0))
        {
            songButton = songButtons[len];
            if (as3hx.Compat.truthy(songButton.isStale || force))
            {
                removeSongButton(songButton);
            }
            len--;
        }
    }
    
    /**
     * Resets the scroll back to 0;
     */
    public function scrollReset() : Void
    {
        _vscroll.scrollTo(0);
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
        return as3hx.Compat.parseFloat(as3hx.Compat.orValue(Math.max(Math.min(_height / _calcHeight, 1), 0), 0));
    }
    
    private function set_scrollVertical(val                       : Dynamic) : Float
    {
        _scrollY = -((_calcHeight - _height) * Math.max(Math.min(val, 1), 0));
        LAST_SCROLL = val;
        updateChildrenVisibility();
        return val;
    }
    
    private function e_scrollWheel(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(doScroll))
        {
            _vscroll.scrollTo(_vscroll.scroll + (scrollFactorVertical / 2) * ((e.delta > 1) ? -1 : 1));
            scrollVertical = _vscroll.scroll;
        }
    }
    
    private function e_scrollVerticalUpdate(e                       : Dynamic) : Void
    {
        scrollVertical = _vscroll.scroll;
    }
    
    private function _filterAny(item                       : Dynamic, index                       : Dynamic, arr                       : Dynamic) : Bool
    {
        return item.name.toLowerCase().indexOf(filterLastTerm) >= 0 || item.author.toLowerCase().indexOf(filterLastTerm) >= 0 || item.stepauthor.toLowerCase().indexOf(filterLastTerm) >= 0;
    }
    
    private function _filterAuthor(item                       : Dynamic, index                       : Dynamic, arr                       : Dynamic) : Bool
    {
        return item.author.toLowerCase().indexOf(filterLastTerm) >= 0;
    }
    
    private function _filterName(item                       : Dynamic, index                       : Dynamic, arr                       : Dynamic) : Bool
    {
        return item.name.toLowerCase().indexOf(filterLastTerm) >= 0;
    }
    
    private function _filterStepauthor(item                       : Dynamic, index                       : Dynamic, arr                       : Dynamic) : Bool
    {
        return item.stepauthor.toLowerCase().indexOf(filterLastTerm) >= 0;
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /** SongButton Pool Vector */
    private static var __vectorSongButton                       : Dynamic= new Array<FileBrowserItem>();
    
    /** Retrieves a SongButton instance from the pool. */
    public static function getSongButton() : FileBrowserItem
    {
        if (as3hx.Compat.truthy(__vectorSongButton.length == 0))
        {
            return new FileBrowserItem();
        }
        else
        {
            return __vectorSongButton.pop();
        }
    }
    
    /** Stores a SongButton instance in the pool.
     *  Don't keep any references to the object after moving it to the pool! */
    public static function putSongButton(songbutton                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(songbutton != null))
        {
            songbutton.highlight = false;
            __vectorSongButton[__vectorSongButton.length] = songbutton;
        }
    }
}

