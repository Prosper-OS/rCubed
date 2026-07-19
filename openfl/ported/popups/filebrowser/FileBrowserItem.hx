package popups.filebrowser;

import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import popups.filebrowser.FileFolder;

class FileBrowserItem extends Sprite
{
    public var highlight(get, set)                       : Dynamic;

    public static inline var FIXED_WIDTH                       : Dynamic= 500;
    public static inline var FIXED_HEIGHT                       : Dynamic= 42;
    
    private static var COLUMN_COLORS                       : Dynamic= [null, "c1ffff", "e3ffcc", "edddff", "ffffff", "67c7f7", "1ddb00", "ffb600", "f40202", "ac00e5", "7641f2"];
    private static var EXT_COLORS                       : Dynamic= {
            sm : 0x0f78ad,
            ssc : 0xce4f00,
            osu : 0xdd73d6,
            qua : 0xa168c9
        };
    
    private var COLUMN_COUNTS                       : Dynamic= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    /** Index in Vector */
    public var index                       : Dynamic= 0;
    
    /** Marks the Button as in-use to avoid removal in song selector. */
    public var isStale                       : Dynamic= true;
    
    public var songData                       : Dynamic;
    
    private var _color                       : Dynamic= 0x000000;
    private var _highcolor                       : Dynamic= 0x000000;
    
    private var _over                       : Dynamic= false;
    private var _highlight                       : Dynamic= false;
    
    private var _lblSongName                       : Dynamic;
    private var _lblAuthorName                       : Dynamic;
    private var _lblType                       : Dynamic;
    private var _lblColumnType                       : Dynamic;
    
    public function new(parent                       : Dynamic= null, xpos                       : Dynamic= 0, ypos                       : Dynamic= 0)
    {
        super();
        COLUMN_COUNTS.fixed = true;
        tabChildren = tabEnabled = false;
        
        this.x = xpos;
        this.y = ypos;
        
        this.buttonMode = true;
        this.useHandCursor = true;
        this.mouseChildren = false;
        
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        
        _lblSongName = new Text(this, 5, 4, "--", 13);
        _lblSongName.setAreaParams(FIXED_WIDTH - 100, 16);
        
        _lblAuthorName = new Text(this, 5, 22, "--", 11);
        _lblAuthorName.setAreaParams(FIXED_WIDTH - 100, 16);
        
        _lblType = new Text(this, 5, 1, "--", 10);
        _lblType.setAreaParams(FIXED_WIDTH - 7, 16, "right");
        
        _lblColumnType = new Text(this, 5, 25, "--", 10);
        _lblColumnType.setAreaParams(FIXED_WIDTH - 8, 16, "right");
        
        drawBox();
        
        addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
    }
    
    /**
     * Draws the background rectangle.
     */
    public function drawBox() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35, true);
        if (as3hx.Compat.truthy(highlight))
        {
            this.graphics.beginFill(0x777777, 0.5);
        }
        else
        {
            this.graphics.beginFill(0x000000, 0.15);
        }
        this.graphics.drawRect(0, 0, FIXED_WIDTH, FIXED_HEIGHT);
        this.graphics.endFill();
        
        var textWidth                       : Dynamic= _lblType.textfield.textWidth;
        this.graphics.lineStyle(0, 0, 0, true);
        this.graphics.beginFill(_color, 0.75);
        this.graphics.drawRoundRectComplex(FIXED_WIDTH - textWidth - 10, 1, textWidth + 10, 17, 0, 0, 5, 0);
        this.graphics.endFill();
        
        textWidth = _lblColumnType.textfield.textWidth;
        this.graphics.beginFill(0x000000, 0.75);
        this.graphics.drawRoundRectComplex(FIXED_WIDTH - textWidth - 9, FIXED_HEIGHT - 17, textWidth + 9, 17, 5, 0, 0, 0);
        this.graphics.endFill();
    }
    
    ///////////////////////////////////
    // public methods
    ///////////////////////////////////
    
    private var chartLookIndex                       : Dynamic;
    private var chartLookChartIndex                       : Dynamic;
    private var chartLookData                       : Dynamic;
    
    public function setData(songData                       : Dynamic) : Void
    {
        this.songData = songData;
        _lblSongName.text = songData.name;
        _lblAuthorName.text = songData.author + " <font color=\"#cccccc\">[" + songData.stepauthor + "]</font>";
        _lblType.text = songData.ext.toUpperCase();
        
        // Reset
        for (chartLookIndex in 0...COLUMN_COUNTS.length)
        {
            COLUMN_COUNTS[chartLookIndex] = 0;
        }
        
        // Count Column Charts
        for (chartLookIndex in 0...songData.data.length)
        {
            chartLookData = songData.data[chartLookIndex].info.chart;
            for (chartLookChartIndex in 0...chartLookData.length)
            {
                Reflect.setField(COLUMN_COUNTS, Std.string(Reflect.field(chartLookData[chartLookChartIndex], "type")), as3hx.Compat.parseInt(as3hx.Compat.field(COLUMN_COUNTS, Reflect.field(chartLookData[chartLookChartIndex], "type"))) + 1);
            }
        }
        
        // Build
        var columnString                       : Dynamic= "";
        for (chartLookIndex in 4...COLUMN_COUNTS.length)
        {
            if (as3hx.Compat.truthy(COLUMN_COUNTS[chartLookIndex] > 0))
            {
                columnString += "<font color=\"#" + (as3hx.Compat.orValue(COLUMN_COLORS[chartLookIndex], "ffffff")) + "\">" + chartLookIndex + "K</font>  ";
            }
        }
        
        _lblColumnType.text = columnString.substring(0, columnString.length - 2);
        
        _color = as3hx.Compat.parseInt(as3hx.Compat.orValue(as3hx.Compat.field(EXT_COLORS, songData.ext), 0));
        
        drawBox();
    }
    
    ///////////////////////////////////
    // event handlers
    ///////////////////////////////////
    
    /**
     * Internal mouseOver handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseOver(event                       : Dynamic) : Void
    {
        _over = true;
        addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        drawBox();
    }
    
    /**
     * Internal mouseOut handler.
     * @param event The MouseEvent passed by the system.
     */
    public function onMouseOut(event                       : Dynamic) : Void
    {
        _over = false;
        removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        drawBox();
    }
    
    ///////////////////////////////////
    // getter/setters
    ///////////////////////////////////
    private function get_highlight() : Bool
    {
        return _highlight || _over;
    }
    
    private function set_highlight(val                       : Dynamic) : Bool
    {
        _highlight = val;
        drawBox();
        return val;
    }
}

