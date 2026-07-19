package popups;

import openfl.errors.Error;
import assets.GameBackgroundColor;
import classes.Language;
import classes.filter.EngineLevelFilter;
import classes.filter.SavedFilterButton;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxText;
import classes.ui.PromptInput;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import com.flashfla.utils.ArrayUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.BlurFilter;
import openfl.geom.Point;
import menu.MainMenu;
import menu.MenuPanel;
import menu.MenuSongSelection;

class PopupFilterManager extends MenuPanel
{
    private var pG(get, never)                       : Dynamic;

    public static inline var TAB_FILTER                       : Dynamic= 0;
    public static inline var TAB_LIST                       : Dynamic= 1;
    public static inline var INDENT_GAP                       : Dynamic= 29;
    
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    //- Background
    private var box                       : Dynamic;
    private var bmd                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var tabLabel                       : Dynamic;
    private var filterNameInput                       : Dynamic;
    
    private var importFilterButton                       : Dynamic;
    private var addSavedFilterButton                       : Dynamic;
    private var clearFilterButton                       : Dynamic;
    private var filterListButton                       : Dynamic;
    private var closeButton                       : Dynamic;
    
    private var scrollpane                       : Dynamic;
    private var scrollbar                       : Dynamic;
    
    private var typeSelector                       : Dynamic;
    
    private var SELECTED_FILTER                       : Dynamic;
    
    public var DRAW_TAB                       : Dynamic= TAB_FILTER;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        bmd = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
        bmd.draw(stage);
        bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
        bmp = new Bitmap(bmd);
        
        this.addChild(bmp);
        
        var bgbox                       : Dynamic= new Box(this, 20, 20, false, false);
        bgbox.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        bgbox.color = GameBackgroundColor.BG_POPUP;
        bgbox.normalAlpha = 0.5;
        bgbox.activeAlpha = 1;
        
        box = new Box(this, 20, 20, false, false);
        box.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        box.activeAlpha = 0.4;
        
        // Tab Label
        tabLabel = new Text(box, 10, 8, "", 20);
        tabLabel.width = box.width - 10;
        
        //- Closed
        closeButton = new BoxButton(box, box.width - 105, 5, 100, 31, _lang.string("popup_close"), 12, e_closeButton);
        
        //- Saved
        filterListButton = new BoxButton(box, closeButton.x - 105, 5, 100, 31, _lang.string("popup_filter_saved_filters"), 12, e_toggleTabButton);
        
        //- Clear
        clearFilterButton = new BoxButton(box, filterListButton.x - 105, 5, 100, 31, _lang.string("popup_filter_clear_filter"), 12, e_clearFilterButton);
        
        //- Add
        addSavedFilterButton = new BoxButton(box, filterListButton.x - 105, 5, 100, 31, _lang.string("popup_filter_add_filter"), 12, e_addSavedFilterButton);
        
        //- Import Filter
        importFilterButton = new BoxButton(box, addSavedFilterButton.x - 105, 5, 100, 31, _lang.string("popup_filter_filter_single_import"), 12, e_importFilterButton);
        
        // Filter Name Input
        filterNameInput = new BoxText(box, 5, 5, clearFilterButton.x - 11, 30);
        filterNameInput.addEventListener(Event.CHANGE, e_filterNameUpdate);
        
        //- content
        scrollpane = new ScrollPane(box, 5, 41, box.width - 35, box.height - 46, mouseWheelHandler);
        scrollbar = new ScrollBar(box, 10 + scrollpane.width, 41, 20, scrollpane.height, null, null, e_scrollBarMoved);
        
        // new type selector
        typeSelector = new Sprite();
        typeSelector.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.8);
        typeSelector.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        typeSelector.graphics.endFill();
        typeSelector.graphics.beginFill(GameBackgroundColor.BG_POPUP, 1);
        typeSelector.graphics.drawRect(Main.GAME_WIDTH / 2 - 200, -1, 400, Main.GAME_HEIGHT + 2);
        typeSelector.graphics.endFill();
        typeSelector.graphics.lineStyle(1, 0xffffff, 1);
        typeSelector.graphics.beginFill(0xFFFFFF, 0.25);
        typeSelector.graphics.drawRect(Main.GAME_WIDTH / 2 - 200, -1, 400, Main.GAME_HEIGHT + 2);
        typeSelector.graphics.endFill();
        
        var typeSelectorTitle                       : Dynamic= new Text(typeSelector, Main.GAME_WIDTH / 2 - 200, 5, _lang.string("filter_editor_add_filter"));
        typeSelectorTitle.width = 400;
        typeSelectorTitle.align = Text.CENTER;
        
        var typeButton                       : Dynamic= null;
        var typeOptions                       : Dynamic= EngineLevelFilter.createOptions(EngineLevelFilter.FILTERS, "type");
        for (i in 0...typeOptions.length)
        {
            typeButton = new BoxButton(typeSelector, (Main.GAME_WIDTH / 2 - 200) + 10 + (195 * (i % 2)), 30 + (Math.floor(i / 2) * 35), 185, 25, Reflect.field(typeOptions[i], "label"), 12, e_addFilterSelection);
            typeButton.tag = Reflect.field(typeOptions[i], "data");
        }
        
        draw();
        
        return true;
    }
    
    override public function draw() : Void
    {
        scrollbar.reset();
        scrollpane.clear();
        
        pG.clear();
        
        // Active Filter Editor
        if (as3hx.Compat.truthy(DRAW_TAB == TAB_FILTER))
        {
            filterListButton.text = _lang.string("popup_filter_saved_filters");
            importFilterButton.visible = false;
            if (as3hx.Compat.truthy(_gvars.activeFilter != null))
            {
                addSavedFilterButton.visible = tabLabel.visible = false;
                filterNameInput.visible = clearFilterButton.visible = true;
                filterNameInput.text = _gvars.activeFilter.name;
                
                drawFilter(_gvars.activeFilter, 0, 0);
            }
            else
            {
                tabLabel.text = _lang.string("popup_filter_no_active_filter");
                addSavedFilterButton.visible = tabLabel.visible = true;
                filterNameInput.visible = clearFilterButton.visible = false;
            }
        }
        // Saved Filters List
        else if (as3hx.Compat.truthy(DRAW_TAB == TAB_LIST))
        {
            tabLabel.text = _lang.string("popup_filter_saved_filters");
            filterListButton.text = _lang.string("popup_filter_active_filter");
            filterNameInput.visible = clearFilterButton.visible = false;
            addSavedFilterButton.visible = tabLabel.visible = true;
            importFilterButton.visible = true;
            var yPos                       : Dynamic= -40;
            var savedFilterButton                       : Dynamic= null;
            for (item/* AS3HX WARNING could not determine type for var: item exp: EField(EField(EIdent(_gvars),activeUser),filters) type: null */ in as3hx.Compat.iter(_gvars.activeUser.filters))
            {
                savedFilterButton = new SavedFilterButton(scrollpane.content, 0, yPos += 40, item, this);
            }
        }
        
        scrollpane.scrollTo(scrollbar.scroll);
        scrollbar.draggerVisibility = (scrollpane.content.height > scrollpane.height);
    }
    
    /**
     * Draws and adds the filter boxes to the scrollpane. This draws filters using recursion for multiple levels.
     * @param	filter Current Filter to Draw
     * @param	indent Indentation Level
     * @param	yPos Starting Y-Position on the scrollpane.
     * @return Bottom Y-Position of the draw filter.
     */
    private function drawFilter(filter                       : Dynamic, indent                       : Dynamic= 0, yPos                       : Dynamic= 0) : Float
    {
        var xPos                       : Dynamic= INDENT_GAP * indent;
        pG.lineStyle(1, 0xFFFFFF, 0.55);
        var _sw1_ = (filter.type);        

        switch (_sw1_)
        {
            case EngineLevelFilter.FILTER_AND, EngineLevelFilter.FILTER_OR:
                // Render AND / OR Label
                if (as3hx.Compat.truthy(indent > 0)) {
pG.moveTo(xPos - 4, yPos + 14);
                    pG.lineTo(xPos - INDENT_GAP + 10, yPos + 14);
                    
                    // Remove Filter Button
                    var removeFilter                       : Dynamic= new BoxButton(scrollpane.content, xPos, yPos, 23, 23, "?", 10, e_removeFilter);
                    removeFilter.tag = filter;
                    removeFilter.color = 0xFF0000;
                    removeFilter.normalAlpha = 0.35;
                    removeFilter.activeAlpha = 0.45;
                    
                    // AND / OR Label
                    var type_text                       : Dynamic= new Text(scrollpane.content, xPos + 29, yPos + 2, _lang.string("filter_type_" + filter.type));
                    
                    yPos -= 8;
                }
                else
                {
                    yPos -= 40;
                }
                
                var topYPos                       : Dynamic= yPos + 46;  // Store Starting y Position for Line later.  
                
                // Render Filters
                for (i in 0...filter.filters.length)
                {
                    yPos = drawFilter(filter.filters[i], indent + 1, yPos += 40);
                }
                
                // Add Filter Button
                pG.moveTo(xPos + INDENT_GAP - 4, yPos + 57);
                pG.lineTo(xPos + 10, yPos + 57);
                
                var addFilter                       : Dynamic= new BoxButton(scrollpane.content, xPos + INDENT_GAP, yPos += 44, 23, 23, "+", 14, e_addFilter);
                addFilter.tag = filter;
                addFilter.color = 0x27D200;
                addFilter.normalAlpha = 0.35;
                addFilter.activeAlpha = 0.45;
                
                pG.moveTo(xPos + 10, topYPos);
                pG.lineTo(xPos + 10, yPos + 14);
                yPos -= 8;
            default:
                pG.moveTo(xPos - 4, yPos + 17);
                pG.lineTo(xPos - INDENT_GAP + 10, yPos + 17);
                new FilterItemButton(scrollpane.content, xPos, yPos, filter, this);
        }
        return yPos;
    }
    
    private function get_pG() : Graphics
    {
        return scrollpane.content.graphics;
    }
    
    private function mouseWheelHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(scrollbar.draggerVisibility))
        {
            var dist                       : Dynamic= scrollbar.scroll + (scrollpane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
            scrollpane.scrollTo(dist);
            scrollbar.scrollTo(dist);
        }
    }
    
    private function e_scrollBarMoved(e                       : Dynamic) : Void
    {
        scrollpane.scrollTo(scrollbar.scroll);
    }
    
    private function e_filterNameUpdate(e                       : Dynamic) : Void
    {
        _gvars.activeFilter.name = filterNameInput.text;
    }
    
    private function e_closeButton(e                       : Dynamic) : Void
    {
        removePopup();
        if (as3hx.Compat.truthy(_gvars.activeUser == _gvars.playerUser))
        {
            _gvars.activeUser.saveLocal();
            _gvars.activeUser.save();
        }
        
        if (as3hx.Compat.truthy(_gvars.gameMain.activePanel != null && Std.is(_gvars.gameMain.activePanel, MainMenu)))
        {
            var mmmenu                       : Dynamic= (try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null);
            mmmenu.buildMenuItems();
            
            if (as3hx.Compat.truthy(mmmenu.panel != null && (Std.is(mmmenu.panel, MenuSongSelection))))
            {
                var msmenu                       : Dynamic= (try cast(mmmenu.panel, MenuSongSelection) catch(e:Dynamic) null);
                msmenu.buildPlayList();
                msmenu.buildInfoBox();
            }
        }
    }
    
    private function e_toggleTabButton(e                       : Dynamic) : Void
    {
        DRAW_TAB = ((DRAW_TAB == TAB_FILTER) ? TAB_LIST : TAB_FILTER);
        draw();
    }
    
    private function e_clearFilterButton(e                       : Dynamic) : Void
    {
        _gvars.activeFilter = null;
        draw();
    }
    
    private function e_addSavedFilterButton(e                       : Dynamic) : Void
    {
        _gvars.activeUser.filters.push(new EngineLevelFilter(true));
        
        if (as3hx.Compat.truthy(DRAW_TAB == TAB_FILTER))
        {
            _gvars.activeFilter = _gvars.activeUser.filters[as3hx.Compat.parseInt(_gvars.activeUser.filters.length - 1)];
        }
        
        draw();
    }
    
    private function e_importFilterButton(e                       : Dynamic) : Void
    {
        new PromptInput(box.parent, _lang.string("popup_filter_filter_single_import"), _lang.string("popup_filter_import"), e_importFilter);
    }
    
    private function e_importFilter(filterJSON                       : Dynamic) : Void
    {
        try
        {
            var item                       : Dynamic= haxe.Json.parse(filterJSON);
            var filter                       : Dynamic= new EngineLevelFilter();
            filter.setup(item);
            filter.is_default = false;
            _gvars.activeUser.filters.push(filter);
            draw();
        }
        catch (e : Error)
        {
        }
    }
    
    private function e_addFilter(e                       : Dynamic) : Void
    {
        var filterButton                      : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null);
        SELECTED_FILTER = (filterButton != null) ? filterButton.tag : null;
        addChild(typeSelector);
    }
    
    private function e_addFilterSelection(e                       : Dynamic) : Void
    {
        removeChild(typeSelector);
        var newFilter                       : Dynamic= new EngineLevelFilter();
        newFilter.type = e.target.tag;
        newFilter.parent_filter = SELECTED_FILTER;
        
        SELECTED_FILTER.filters.push(newFilter);
        draw();
    }
    
    private function e_removeFilter(e                       : Dynamic) : Void
    {
        var removeFilterButton                    : Dynamic= (try cast(e.target, BoxButton) catch(e:Dynamic) null);
        var filter                     : Dynamic= (removeFilterButton != null) ? removeFilterButton.tag : null;
        if (as3hx.Compat.truthy(ArrayUtil.remove(filter, filter.parent_filter.filters)))
        {
            draw();
        }
    }
}

