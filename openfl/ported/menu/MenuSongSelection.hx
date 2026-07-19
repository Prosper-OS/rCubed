package menu;

import arc.ArcGlobals;
import assets.GameBackgroundColor;
import assets.menu.GenreSelection;
import assets.menu.ScrollBackground;
import assets.menu.ScrollDragger;
import assets.menu.SongSelectionBackground;
import assets.menu.icons.fa.IconGear;
import assets.menu.icons.fa.IconLeft;
import assets.menu.icons.fa.IconList;
import assets.menu.icons.fa.IconRight;
import assets.menu.icons.fa.IconTrophy;
import classes.Alert;
import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.SongPlayerBytes;
import classes.SongPreview;
import classes.SongQueueItem;
import classes.User;
import classes.chart.Song;
import classes.mp.Multiplayer;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.BoxText;
import classes.ui.PromptInput;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.StarSelector;
import classes.ui.Text;
import classes.ui.Throbber;
import com.bit101.components.ComboBox;
import com.bit101.components.PushButton;
import com.flashfla.net.WebRequest;
import com.flashfla.utils.ArrayUtil;
import com.flashfla.utils.NumberUtil;
import com.flashfla.utils.TimeUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.Sprite;
import openfl.events.ContextMenuEvent;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.ui.ContextMenu;
import openfl.ui.ContextMenuItem;
import openfl.ui.Keyboard;
import game.GameOptions;
import game.SkillRating;
import menu.MenuSongSelectionOptions;
import popups.PopupHighscores;
import popups.PopupQueueManager;
import popups.PopupSongNotes;


import openfl.display.DisplayObjectContainer;



import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.text.AntiAliasType;

import openfl.text.TextFieldAutoSize;
import openfl.utils.Timer;

class MenuSongSelection extends MenuPanel
{
    public static inline var ITEM_PER_PAGE                       : Dynamic= 500;
    
    public static var PLAYLIST_QUEUE                       : Dynamic= -3;
    public static var PLAYLIST_SEARCH                       : Dynamic= -2;
    public static var PLAYLIST_ALL                       : Dynamic= -1;
    
    public static inline var TAB_PLAYLIST                       : Dynamic= 0;
    public static inline var TAB_SEARCH                       : Dynamic= 1;
    public static inline var TAB_QUEUE                       : Dynamic= 2;
    public static inline var TAB_HIGHSCORES                       : Dynamic= 3;
    
    public static inline var GENRE_GENRES                       : Dynamic= 0;
    public static inline var GENRE_DIFFICULTIES                       : Dynamic= 1;
    public static inline var GENRE_SONGFLAGS                       : Dynamic= 2;
    public static inline var GENRE_MODES                       : Dynamic= 2;
    
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _playlist                       : Dynamic= Playlist.instance;
    private var _mp                       : Dynamic= Multiplayer.instance;
    
    private var SORT_VALUE_CACHE                       : Dynamic= { };
    
    private var genreDisplay                       : Dynamic;
    private var genreItems                       : Dynamic= [];
    private var genreListFlags                       : Dynamic= [];
    
    private var GENRE_MODE_TEXT                       : Dynamic;
    private var genre_mode_prev                       : Dynamic;
    private var genre_mode_next                       : Dynamic;
    private var SELECTED_GENRE_BACKGROUND                       : Dynamic;
    
    private var background                       : Dynamic;
    private var scrollbar                       : Dynamic;
    private var pane                       : Dynamic;
    private var pane_filter_text                       : Dynamic;
    
    private var genreLength                       : Dynamic;
    private var songItems                       : Dynamic= [];
    
    private var optionsBox                       : Dynamic;
    private var infoBox                       : Dynamic;
    private var pages                       : Dynamic;
    private var songList                       : Dynamic;
    
    private var GENRE_MODE                       : Dynamic= GENRE_DIFFICULTIES;
    
    // Info Page
    private var searchBox                       : Dynamic;
    private var searchTypeBox                       : Dynamic;
    private var sortTypeBox                       : Dynamic;
    private var sortOrderBox                       : Dynamic;
    private var sortIgnoreChange                       : Dynamic= false;
    
    private static var purchasedWebRequests                       : Dynamic= [];
    
    public static var options                       : Dynamic= new MenuSongSelectionOptions();
    
    private var songItemContextMenu                       : Dynamic;
    private var songItemRemoveQueueContext                       : Dynamic;
    
    public static var previewMusic                       : Dynamic;
    
    ///- Constructor
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        Reflect.setField(Flags.VALUES, Flags.ENABLE_GLOBAL_POPUPS, true);
        
        // Load Default Alt Engine
        if (as3hx.Compat.truthy(_avars.legacyDefaultEngine && as3hx.Compat.field(Flags.VALUES, Flags.LEGACY_ENGINE_DEFAULT_LOAD) == null))
        {
            _avars.configLegacy = _avars.legacyDefaultEngine;
            _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, _playlist.engineChangeHandler);
            _playlist.addEventListener(GlobalVariables.LOAD_ERROR, e_defaultEngineLoadFail);
            _playlist.load();
            
            Reflect.setField(Flags.VALUES, Flags.LEGACY_ENGINE_DEFAULT_LOAD_SKIP, true);
            
            var loadTextEngine                       : Dynamic= new Text(this, 0, Main.GAME_HEIGHT / 2 - 15, _lang.string("song_selection_load_default_engine"));
            loadTextEngine.setAreaParams(Main.GAME_WIDTH, 30, Text.CENTER);
        }
        
        Reflect.setField(Flags.VALUES, Flags.LEGACY_ENGINE_DEFAULT_LOAD, true);
        
        if (as3hx.Compat.truthy(as3hx.Compat.field(Flags.VALUES, Flags.LEGACY_ENGINE_DEFAULT_LOAD_SKIP) != null))
        {
            return true;
        }
        
        //- Add Background
        background = new SongSelectionBackground();
        background.x = 145;
        background.y = 52;
        background.visible = LocalOptions.getVariable("menu_show_song_selection_background", true);
        this.addChild(background);
        
        GENRE_MODE = LocalStore.getVariable("genre_mode", GENRE_DIFFICULTIES);
        
        draw();
        
        // Re-Open File Browser
        if (as3hx.Compat.truthy(as3hx.Compat.field(Flags.VALUES, Flags.FILE_LOADER_OPEN) != null))
        {
            Reflect.setField(Flags.VALUES, Flags.FILE_LOADER_OPEN, false);
            switchTo(MainMenu.MENU_LOCAL);
        }
        
        return true;
    }
    
    override public function dispose() : Void
    {
        genreItems = null;
        songItems = null;
        
        if (as3hx.Compat.truthy(genreDisplay != null))
        {
            genreDisplay.removeEventListener(MouseEvent.CLICK, genreClick);
            genre_mode_prev.removeEventListener(MouseEvent.CLICK, clickHandler);
            genre_mode_next.removeEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        if (as3hx.Compat.truthy(pane != null))
        {
            pane.removeEventListener(MouseEvent.CLICK, songItemClicked);
            pane.dispose();
            pane = null;
        }
        
        if (as3hx.Compat.truthy(pane_filter_text != null))
        {
            pane_filter_text.dispose();
            pane_filter_text = null;
        }
        
        if (as3hx.Compat.truthy(pages != null))
        {
            pages.removeEventListener(MouseEvent.CLICK, pageClicked);
        }
        
        if (as3hx.Compat.truthy(searchBox != null))
        {
            searchBox.dispose();
            searchBox = null;
        }
        super.dispose();
    }
    
    override public function draw() : Void
    // Menu Music Context Menu
    {
        
        var songItemContextMenuItem                       : Dynamic= null;
        
        songItemContextMenu = new ContextMenu();
        songItemContextMenuItem = new ContextMenuItem(_lang.stringSimple("song_selection_context_menu_music"));
        songItemContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_setAsMenuMusicContextSelect);
        songItemContextMenu.customItems.push(songItemContextMenuItem);
        
        songItemContextMenuItem = new ContextMenuItem(_lang.stringSimple("song_selection_context_song_preview"), true);
        songItemContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_listenToSongPreviewContextSelect);
        songItemContextMenu.customItems.push(songItemContextMenuItem);
        
        songItemContextMenuItem = new ContextMenuItem(_lang.stringSimple("song_selection_context_chart_preview"));
        songItemContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_playChartPreviewContextSelect);
        songItemContextMenu.customItems.push(songItemContextMenuItem);
        
        songItemContextMenuItem = new ContextMenuItem(_lang.stringSimple("song_selection_context_song_options"));
        songItemContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_songOptionsContextSelect);
        songItemContextMenu.customItems.push(songItemContextMenuItem);
        
        songItemRemoveQueueContext = new ContextMenuItem(_lang.stringSimple("song_selection_context_remove_from_queue"), true);
        songItemRemoveQueueContext.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_removeFromQueueContextSelect);
        songItemContextMenu.customItems.push(songItemRemoveQueueContext);
        
        //- Build Genre Holder
        if (as3hx.Compat.truthy(genreDisplay == null))
        {
            genreDisplay = new Sprite();
            genreDisplay.x = 5;
            genreDisplay.y = 135;
            genreDisplay.addEventListener(MouseEvent.CLICK, genreClick, false, 0, true);
            this.addChild(genreDisplay);
            
            this.graphics.lineStyle(1, 0xffffff, 0.5);
            this.graphics.moveTo(22, 133);
            this.graphics.lineTo(121, 133);
            
            SELECTED_GENRE_BACKGROUND = new GenreSelection();
            
            GENRE_MODE_TEXT = new Text(this, 17, 106, _lang.string("genre_mode_" + GENRE_SONGFLAGS));
            GENRE_MODE_TEXT.align = Text.CENTER;
            GENRE_MODE_TEXT.width = 109;
            GENRE_MODE_TEXT.fontSize = 16;
            
            genre_mode_prev = new IconLeft();
            genre_mode_prev.x = 16;
            genre_mode_prev.y = 119;
            genre_mode_prev.scaleX = genre_mode_prev.scaleY = 0.22;
            genre_mode_prev.buttonMode = true;
            genre_mode_prev.useHandCursor = true;
            genre_mode_prev.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
            this.addChild(genre_mode_prev);
            
            genre_mode_next = new IconRight();
            genre_mode_next.x = 127;
            genre_mode_next.y = 119;
            genre_mode_next.scaleX = genre_mode_next.scaleY = 0.22;
            genre_mode_next.buttonMode = true;
            genre_mode_next.useHandCursor = true;
            genre_mode_next.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
            this.addChild(genre_mode_next);
        }
        
        //- Add Info Box Tabs
        if (as3hx.Compat.truthy(optionsBox != null))
        {
            for (i in 0...optionsBox.numChildren)
            {
                optionsBox.getChildAt(i).removeEventListener(MouseEvent.CLICK, clickHandler, false);
            }
            optionsBox.removeChildren();
        }
        
        optionsBox = new Sprite();
        optionsBox.x = 559;  // 155  
        optionsBox.y = 64;
        this.addChild(optionsBox);
        
        var optionsTexts                       : Dynamic= [[_lang.string("song_selection_menu_search"), "search"], [_lang.string("song_selection_search"), "queue"]];
        for (i in 0...optionsTexts.length)
        {
            var optionActionBox                       : Dynamic= new BoxButton(optionsBox, (i * 88.5), 0, 85.5, 27, optionsTexts[i][0], 11, clickHandler);
            optionActionBox.action = optionsTexts[i][1];
        }
        
        //- Add Song Info Box
        if (as3hx.Compat.truthy(infoBox == null))
        {
            infoBox = new Sprite();
            infoBox.graphics.lineStyle(1, 0xFFFFFF, 0.35, false);
            infoBox.graphics.beginFill(0xFFFFFF, 0.1);
            infoBox.graphics.drawRect(0, 0, 174, 320);
            infoBox.graphics.endFill();
            infoBox.x = 559;  // 155  
            infoBox.y = 94;
            this.addChild(infoBox);
        }
        
        //- Add ScrollPane
        if (as3hx.Compat.truthy(pane == null))
        {
            pane = new ScrollPane(this, 155, 64, 401, 351, mouseWheelHandler);
            pane.graphics.lineStyle(1, 0xFFFFFF, 0.35, false);
            pane.graphics.moveTo(0.2, -0.5);
            pane.graphics.lineTo(399, -0.5);
            pane.graphics.moveTo(0.2, 351.5);
            pane.graphics.lineTo(399, 351.5);
            pane.addEventListener(MouseEvent.CLICK, songItemClicked, false, 0, true);
        }
        
        if (as3hx.Compat.truthy(pane_filter_text == null))
        {
            pane_filter_text = new Text(this, 155, 64, "");
            pane_filter_text.setAreaParams(401, 351, "center");
            pane_filter_text.visible = false;
        }
        
        //- Add ScrollBar
        if (as3hx.Compat.truthy(scrollbar == null))
        {
            scrollbar = new ScrollBar(this, 744, 81, 21, 325, new ScrollDragger(), new ScrollBackground(), scrollBarMoved);
        }
        
        //- Build Content
        buildGenreList();
        buildPlayList();
        buildInfoBox();
    }
    
    override public function stageAdd() : Void
    {
        if (as3hx.Compat.truthy(as3hx.Compat.field(Flags.VALUES, Flags.LEGACY_ENGINE_DEFAULT_LOAD_SKIP) != null))
        {
            return;
        }
        
        //- Add Listeners
        if (as3hx.Compat.truthy(stage))
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);
            buildInfoBox();
        }
    }
    
    override public function stageRemove() : Void
    {
        if (as3hx.Compat.truthy(stage))
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }
    }
    
    /**
     * Called when an Alt Engine fails to load as the default displayed engine.
     * Reloads the song selection panel.
     * @param e
     */
    private function e_defaultEngineLoadFail(e                       : Dynamic) : Void
    {
        _playlist.removeEventListener(GlobalVariables.LOAD_ERROR, e_defaultEngineLoadFail);
        _playlist.engineChangeHandler(e);
        switchTo(Main.GAME_MENU_PANEL);
    }
    
    //******************************************************************************************//
    // Genre Sidebar Logic
    //******************************************************************************************//
    
    /**
     * Builds the array for flag colors if applicable.
     */
    public function buildGenreListFlags() : Void
    {
        if (as3hx.Compat.truthy(!_gvars.activeUser.DISPLAY_GENRE_FLAG))
        {
            return;
        }
        
        genreListFlags = [];
        
        var i                       : Dynamic= null;
        
        //- Build Genre List
        var totalGenres                       : Dynamic= getTotalGenres();
        
        var genre_index                       : Dynamic= null;
        for (genre_index in -1...totalGenres)
        {
            if (as3hx.Compat.truthy(genre_index == PLAYLIST_ALL))
            {
                songList = [];
                
                var len                       : Dynamic= _playlist.indexList.length;
                for (i in 0...len)
                {
                    songList[i] = _playlist.indexList[i];
                }
            }
            // We already know the flag.
            else
            {
                
                if (as3hx.Compat.truthy(GENRE_MODE == GENRE_SONGFLAGS))
                {
                    genreListFlags[genre_index] = ((genre_index >= 2) ? GlobalVariables.SONG_ICON_COLOR[genre_index] : null);
                }
                else if (as3hx.Compat.truthy(GENRE_MODE == GENRE_DIFFICULTIES)) {
if (as3hx.Compat.truthy(genre_index == _gvars.DIFFICULTY_RANGES.length - 1))
                    {
                        songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, function(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
                                        {
                                            return as3hx.Compat.parseFloat(item.difficulty) <= 0 || as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][0]);
                                        });
                    }
                    else
                    {
                        songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, function(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
                                        {
                                            return as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][0]) && as3hx.Compat.parseFloat(item.difficulty) <= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(genre_index)][1]);
                                        });
                    }
                }
                else
                {
                    songList = _playlist.genreList[genre_index + 1];
                }
            }
            
            if (as3hx.Compat.truthy(songList != null))
            {
                var best_flag                       : Dynamic= GlobalVariables.SONG_ICON_AAA;
                for (i in 0...songList.length)
                {
                    var song_flag                       : Dynamic= GlobalVariables.getSongIconIndex(songList[i], _gvars.activeUser.getLevelRank(songList[i]));
                    
                    if (as3hx.Compat.truthy(song_flag == GlobalVariables.SONG_ICON_FC_STAR))
                    {
                        song_flag = GlobalVariables.SONG_ICON_FC;
                    }
                    
                    if (as3hx.Compat.truthy(song_flag < best_flag))
                    {
                        best_flag = song_flag;
                        if (as3hx.Compat.truthy(song_flag <= 1))
                        {
                            break;
                        }
                    }
                }
                genreListFlags[genre_index] = ((best_flag >= 2) ? GlobalVariables.SONG_ICON_COLOR[best_flag] : null);
                songList = null;
            }
        }
    }
    
    /**
     * General builder for the Genre left sidebar display.
     */
    public function buildGenreList() : Void
    // Reset
    {
        
        genreDisplay.removeChildren();
        as3hx.Compat.setArrayLength(genreItems, 0);
        genreDisplay.addChild(SELECTED_GENRE_BACKGROUND);
        
        // Build Genre Flag Array
        buildGenreListFlags();
        
        // Set Genre Text
        GENRE_MODE_TEXT.text = _lang.string("genre_mode_" + GENRE_MODE);
        
        //- Build Genre List
        var totalGenres                       : Dynamic= getTotalGenres();
        
        var genre_index                       : Dynamic= null;
        var position_index                       : Dynamic= -1;
        
        for (genre_index in -1...totalGenres) {
if (as3hx.Compat.truthy(GENRE_MODE == GENRE_GENRES))
            {
                if (as3hx.Compat.truthy(!_gvars.activeUser.DISPLAY_LEGACY_SONGS && !_playlist.engine && genre_index == (Constant.LEGACY_GENRE - 1)))
                {
                    continue;
                }
                position_index++;
            }
            else
            {
                position_index = as3hx.Compat.parseInt(genre_index + 1);
            }
            
            // Flag Color
            var genre_flag                       : Dynamic= genreListFlags[genre_index];
            var genre_text                       : Dynamic= getGenreText(genre_index);
            
            if (as3hx.Compat.truthy(genre_flag != null && _gvars.activeUser.DISPLAY_GENRE_FLAG))
            {
                genre_text = "<font color=\"" + genre_flag + "\">?</font> " + genre_text;
            }
            
            // Build Label
            var songGenre                       : Dynamic= new Text(genreDisplay, 0, 0, genre_text, 14);
            songGenre.height = 22.6;
            songGenre.width = 130.75;
            songGenre.mouseEnabled = true;
            songGenre.useHandCursor = true;
            songGenre.buttonMode = true;
            songGenre.index = genre_index;
            songGenre.position = position_index;
            genreItems.push(songGenre);
        }
        
        updateGenreList();
    }
    
    /**
     * Updates genre position, font size, and selection background.
     */
    private function updateGenreList() : Void
    // Remove Selected Genre Background
    {
        
        SELECTED_GENRE_BACKGROUND.visible = false;
        
        var totalGenres                       : Dynamic= genreItems.length;
        var gap                       : Dynamic= Math.min(23, Math.ceil(337 / (totalGenres + 1)));
        
        for (g in 0...totalGenres)
        {
            genreItems[g].y = gap * genreItems[g].position;
            
            // Set Selected Background
            if (as3hx.Compat.truthy(options.activeGenre == genreItems[g].index))
            {
                genreItems[g].fontSize = 18;
                SELECTED_GENRE_BACKGROUND.y = genreItems[g].y - 2;
                SELECTED_GENRE_BACKGROUND.visible = true;
            }
            else
            {
                genreItems[g].fontSize = 14;
            }
        }
    }
    
    /**
     * Get the text to display for the Genre Button
     * @param gindex Genre Index
     * @return Genre Display Text
     */
    private function getGenreText(gindex                       : Dynamic) : String
    {
        if (as3hx.Compat.truthy(GENRE_MODE == GENRE_GENRES || gindex == PLAYLIST_ALL))
        {
            return _lang.string("genre_" + gindex);
        }
        
        if (as3hx.Compat.truthy(GENRE_MODE == GENRE_DIFFICULTIES))
        {
            return _lang.string("difficulty_title_" + gindex);
        }
        
        if (as3hx.Compat.truthy(gindex == 1))
        {
            return _lang.string("song_selection_played");
        }
        
        return GlobalVariables.SONG_ICON_TEXT[gindex];
    }
    
    /**
     * Get the total genres to display depending on the GENRE_MODE.
     * @return Genre Count
     */
    private function getTotalGenres() : Int
    {
        switch (GENRE_MODE)
        {
            case GENRE_DIFFICULTIES:
                return _gvars.DIFFICULTY_RANGES.length;
            case GENRE_SONGFLAGS:
                return GlobalVariables.SONG_ICON_TEXT.length;
            default:
                return as3hx.Compat.parseInt(((!_gvars.activeUser.DISPLAY_LEGACY_SONGS && !_playlist.engine)) ? _gvars.TOTAL_GENRES - 1 : _gvars.TOTAL_GENRES);
        }
    }
    
    /**
     * Called from the genre display when a genre is clicked.
     * This sets the active genre to the item clicked, resets
     * most of the display parameters and rebuilds the display.
     */
    private function genreClick(e                       : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(e.target.index != null && options.activeGenre != e.target.index))
        {
            options.infoTab = TAB_PLAYLIST;
            options.isFilter = false;
            options.activeGenre = e.target.index;
            options.activeIndex = -1;
            options.activeSongId = -1;
            options.pageNumber = 0;
            options.scroll_position = 0;
            
            resetFilterOptions();
            
            updateGenreList();
            buildPlayList();
            buildInfoBox();
        }
        stage.focus = stage;
    }
    
    //******************************************************************************************//
    // Song Playlist / Item Logic
    //******************************************************************************************//
    /**
     * Generates a valid song list given the applied terms such as genre, search and filters.
     * Is also responsible for displaying the results in the scroll pane.
     */
    public function buildPlayList() : Void
    //- Clear out/reset pane items and pages.
    {
        
        as3hx.Compat.setArrayLength(songItems, 0);
        
        scrollbar.reset();
        pane.clear();
        pane_filter_text.visible = false;
        
        //- Init Variables
        var doPageSlice                       : Dynamic= false;
        var i                       : Dynamic= null;
        var yOffset                       : Dynamic= 0;
        var songInfo                       : Dynamic= null;
        var sI                       : Dynamic= null;
        
        var sourceListLength                       : Dynamic= 0;
        
        //- Set Song array based on selected genre
        // DM_QUEUE
        if (as3hx.Compat.truthy(options.activeGenre == PLAYLIST_QUEUE))
        {
            _gvars.songQueue = options.queuePlaylist;
            songList = _gvars.songQueue;
            sourceListLength = _gvars.songQueue.length;
            genreLength = _gvars.songQueue.length;
            doPageSlice = true;
        }
        // DM_SEARCH
        else if (as3hx.Compat.truthy(options.activeGenre == PLAYLIST_SEARCH)) {
if (as3hx.Compat.truthy(options.isFilter))
            {
                songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, filterSongListOptionsFilter);
                sourceListLength = songList.length;
                genreLength = songList.length;
                doPageSlice = true;
            }
        }
        // DM_ALL
        else if (as3hx.Compat.truthy(options.activeGenre == PLAYLIST_ALL))
        {
            songList = [];
            var len                       : Dynamic= _playlist.indexList.length;
            for (i in 0...len)
            {
                songList[i] = _playlist.indexList[i];
            }
            
            // Song List Filters
            sourceListLength = songList.length;
            songList = filterSongListFlags(songList);
            songList = filterSongListUser(songList);
            
            // List Length and Slice into pages.
            genreLength = songList.length;
            doPageSlice = true;
        }
        // STANDARD_DISPLAY
        else
        {
            
            {
                if (as3hx.Compat.truthy(GENRE_MODE == GENRE_DIFFICULTIES)) {
if (as3hx.Compat.truthy(options.activeGenre == _gvars.DIFFICULTY_RANGES.length - 1))
                    {
                        songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, filterSongListDifficultyMax);
                    }
                    else
                    {
                        songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, filterSongListDifficultyRange);
                    }
                    
                    // Song List Filters
                    sourceListLength = songList.length;
                    songList = filterSongListFlags(songList);
                    songList = filterSongListUser(songList);
                    
                    // Sort and get List Length
                    as3hx.Compat.sortOn(songList, ["access", "difficulty", "name"], [as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
                    genreLength = songList.length;
                }
                else if (as3hx.Compat.truthy(GENRE_MODE == GENRE_SONGFLAGS)) {
songList = getFilteredSongInfoArrayFromVec(_playlist.indexList, filterSongListSongFlags);
                    
                    // Song List Filters
                    sourceListLength = songList.length;
                    songList = filterSongListFlags(songList);
                    songList = filterSongListUser(songList);
                    
                    // Sort, List Length, and Slice into pages.
                    as3hx.Compat.sortOn(songList, ["access", "difficulty", "name"], [as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
                    genreLength = songList.length;
                    doPageSlice = true;
                }
                else
                {
                    songList = _playlist.genreList[options.activeGenre + 1];
                    genreLength = (songList != null) ? songList.length : 0;
                    sourceListLength = genreLength;
                }
            }
        }
        
        songItemRemoveQueueContext.visible = options.activeGenre == PLAYLIST_QUEUE;
        
        // Null Songlist - Somehow.
        if (as3hx.Compat.truthy(songList == null))
        {
            songList = [];
        }
        
        // User Filter
        if (as3hx.Compat.truthy(songList.length > 0))
        {
            if (as3hx.Compat.truthy(options.activeGenre != PLAYLIST_ALL && options.infoTab != TAB_QUEUE))
            {
                sourceListLength = Math.max(sourceListLength, songList.length);
                songList = filterSongListUser(songList);
                genreLength = songList.length;
            }
        }
        
        // Sorting
        if (as3hx.Compat.truthy(options.last_sort_type != null))
        {
            SORT_VALUE_CACHE = { };
            
            var sortOrder                       : Dynamic= (options.last_sort_order == "desc") ? as3hx.Compat.ARRAY_DESCENDING : 0;
            var _sw2_ = (options.last_sort_type);            

            switch (_sw2_)
            {
                case "name", "author", "stepauthor", "style":
                    as3hx.Compat.sortOn(songList, ["access", options.last_sort_type], [as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_CASEINSENSITIVE | sortOrder]);
                case "time_secs", "level", "note_count", "difficulty", "max_nps":
                    as3hx.Compat.sortOn(songList, ["access", options.last_sort_type], [as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_NUMERIC | sortOrder]);
                case "rank":
                    songList.sort(sortByRank, as3hx.Compat.ARRAY_NUMERIC | sortOrder);
                
                case "raw_goods":
                    songList.sort(sortByRawGoods, as3hx.Compat.ARRAY_NUMERIC | sortOrder);
                default:
            }
        }
        
        // Page Splicing
        if (as3hx.Compat.truthy(doPageSlice))
        {
            songList = songList.slice(options.pageNumber * ITEM_PER_PAGE, (options.pageNumber + 1) * ITEM_PER_PAGE);
        }
        
        //- Pages
        drawPages();
        
        // Error Messages
        if (as3hx.Compat.truthy(songList.length == 0))
        {
            pane_filter_text.visible = true;
            if (as3hx.Compat.truthy(options.activeGenre == PLAYLIST_SEARCH))
            {
                pane_filter_text.text = _lang.string("song_selection_filter_no_results_found");
            }
            else if (as3hx.Compat.truthy(sourceListLength > 0))
            {
                pane_filter_text.text = sprintf(_lang.string("song_selection_filter_no_results_hidden"), {
                                    items : sourceListLength
                                });
            }
            else
            {
                pane_filter_text.text = _lang.string("song_selection_filter_no_results");
            }
            
            options.activeIndex = -1;
            options.activeSongId = -1;
            return;
        }
        
        //- Build Playlist
        for (sX in 0...songList.length)
        {
            songInfo = songList[sX];
            sI = new SongItem();
            sI.setData(songInfo, _gvars.activeUser.getLevelRank(songInfo));
            sI.noteEnabled = _gvars.activeUser.DISPLAY_SONG_NOTE;
            sI.setContextMenu(songItemContextMenu);
            sI.y = yOffset;
            sI.index = sX;
            songItems.push(sI);
            pane.content.addChild(sI);
            yOffset += as3hx.Compat.parseInt(sI.height + 2);
        }
        
        // Scroll Position
        pane.scrollTo(options.scroll_position);
        scrollbar.scrollTo(options.scroll_position);
        
        scrollbar.draggerVisibility = (yOffset > pane.height);
        
        //- Update Selected Index
        // Find and select last active song id.
        var hasSelected                       : Dynamic= false;
        for (sX in 0...songList.length)
        {
            songInfo = songList[sX];
            if (as3hx.Compat.truthy(options.activeSongId == songInfo.level))
            {
                setActiveIndex(sX, -1, false, false);
                hasSelected = true;
                break;
            }
        }
        
        // No active valid song found, clear saved actives.
        if (as3hx.Compat.truthy(!hasSelected))
        {
            options.activeIndex = -1;
            options.activeSongId = -1;
        }
        
        // No song selected, select the first in the list if valid.
        if (as3hx.Compat.truthy(options.activeIndex == -1))
        {
            setActiveIndex(0, -1, false, false);
        }
    }
    
    private function getSongRank(song                       : Dynamic, activeUser                       : Dynamic) : Int
    {
        var songRank                       : Dynamic= as3hx.Compat.field(SORT_VALUE_CACHE, song.level);
        if (as3hx.Compat.truthy(songRank != 0))
        {
            return songRank;
        }
        
        var songLevelRank                       : Dynamic= activeUser.getLevelRank(song);
        if (as3hx.Compat.truthy(songLevelRank == null))
        {
            songRank = 1000000000;
        }
        else
        {
            songRank = songLevelRank.rank;
        }
        
        Reflect.setField(SORT_VALUE_CACHE, Std.string(song.level), songRank);
        
        return songRank;
    }
    
    private function sortByRank(songA                       : Dynamic, songB                       : Dynamic) : Int
    {
        var songARank                       : Dynamic= getSongRank(songA, _gvars.activeUser);
        var songBRank                       : Dynamic= getSongRank(songB, _gvars.activeUser);
        
        if (as3hx.Compat.truthy(songA.access != songB.access))
        {
            return (songA.access < songB.access) ? -1 : 1;
        }
        
        if (as3hx.Compat.truthy(songARank == songBRank))
        {
            return (songA.level < songB.level) ? -1 : 1;
        }
        
        return (songARank < songBRank) ? -1 : 1;
    }
    
    private function getSongRawGoods(song                       : Dynamic, activeUser                       : Dynamic) : Float
    {
        var songRawGoods                       : Dynamic= as3hx.Compat.field(SORT_VALUE_CACHE, song.level);
        if (as3hx.Compat.truthy(songRawGoods != 0 && !Math.isNaN(songRawGoods)))
        {
            return songRawGoods;
        }
        
        var songLevelRank                       : Dynamic= activeUser.getLevelRank(song);
        
        if (as3hx.Compat.truthy(songLevelRank == null))
        {
            songRawGoods = 2000000;
        }
        else
        {
            var rawGoods                       : Dynamic= songLevelRank.good + (songLevelRank.average * 1.8) + (songLevelRank.miss * 2.4) + (songLevelRank.boo * 0.2);
            var notesPlayed                       : Dynamic= as3hx.Compat.parseInt(songLevelRank.perfect + songLevelRank.good + songLevelRank.average + songLevelRank.miss);
            var noteCount                       : Dynamic= song.note_count || songLevelRank.arrows;
            
            if (as3hx.Compat.truthy(notesPlayed < noteCount))
            {
                var implicitMisses                       : Dynamic= as3hx.Compat.parseInt(noteCount - notesPlayed);
                songRawGoods = 1000000 + rawGoods + implicitMisses * 2.4;
            }
            else
            {
                songRawGoods = rawGoods;
            }
        }
        
        Reflect.setField(SORT_VALUE_CACHE, Std.string(song.level), songRawGoods);
        
        return songRawGoods;
    }
    
    private function sortByRawGoods(songA                       : Dynamic, songB                       : Dynamic) : Int
    {
        var songARawGoods                       : Dynamic= getSongRawGoods(songA, _gvars.activeUser);
        var songBRawGoods                       : Dynamic= getSongRawGoods(songB, _gvars.activeUser);
        
        if (as3hx.Compat.truthy(songA.access != songB.access))
        {
            return (songA.access < songB.access) ? -1 : 1;
        }
        
        if (as3hx.Compat.truthy(songARawGoods == songBRawGoods))
        {
            return (songA.level < songB.level) ? -1 : 1;
        }
        
        return (songARawGoods < songBRawGoods) ? -1 : 1;
    }
    
    
    /**
     * Filters the `_playlist.indexList` vector of SongInfo into an Array given a specific filter function.
     */
    private function getFilteredSongInfoArrayFromVec(vec                       : Dynamic, filter                       : Dynamic) : Array<Dynamic>
    {
        var filteredArray                       : Dynamic= [];
        
        var filteredSongInfos                       : Dynamic= null;
        filteredSongInfos = _playlist.indexList.filter(filter);
        
        for (songInfo in as3hx.Compat.iter(filteredSongInfos))
        {
            filteredArray.push(songInfo);
        }
        
        return filteredArray;
    }
    
    /**
     * Vector filter for difficulty ranges. This one handles everything at and above the top range and the special case for difficulty 0.
     */
    private function filterSongListDifficultyMax(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
    {
        return as3hx.Compat.parseFloat(item.difficulty) <= 0 || as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][0]);
    }
    
    /**
     * Vector filter for difficulty ranges. This one handles the range between two difficulty points.
     */
    private function filterSongListDifficultyRange(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
    {
        return as3hx.Compat.parseFloat(item.difficulty) >= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][0]) && as3hx.Compat.parseFloat(item.difficulty) <= as3hx.Compat.parseFloat(_gvars.DIFFICULTY_RANGES[as3hx.Compat.parseInt(options.activeGenre)][1]);
    }
    
    /**
     * Array filter for song flags.
     */
    private function filterSongListSongFlags(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
    {
        return GlobalVariables.getSongIconIndex(item, _gvars.activeUser.getLevelRank(item)) == options.activeGenre;
    }
    
    /**
     * Array filter for options.filter
     */
    private function filterSongListOptionsFilter(item                       : Dynamic, index                       : Dynamic, vec                       : Dynamic) : Bool
    {
        return options.filter(item);
    }
    
    /**
     * Process the legacy filter on the given song list if enabled.
     * @param songList Song List Array for Song objects to filter.
     */
    private function filterSongListFlags(songList                       : Dynamic) : Array<Dynamic>
    {
        if (as3hx.Compat.truthy(!_gvars.activeUser.DISPLAY_LEGACY_SONGS))
        {
            songList = songList.filter(filterSongListLegacyFilter);
        }
        
        if (as3hx.Compat.truthy(!_gvars.activeUser.DISPLAY_EXPLICIT_SONGS))
        {
            songList = songList.filter(filterSongListExplicitFilter);
        }
        
        if (as3hx.Compat.truthy(!_gvars.activeUser.DISPLAY_UNRANKED_SONGS))
        {
            songList = songList.filter(filterSongListUnrankedFilter);
        }
        
        return songList;
    }
    
    /**
     * Legacy Array filter for filterSongListFlags.
     */
    private function filterSongListLegacyFilter(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
    {
        return !item.is_legacy;
    }
    
    /**
     * Explicit Array filter for filterSongListFlags.
     */
    private function filterSongListExplicitFilter(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
    {
        return !item.is_explicit;
    }
    
    /**
     * Unranked Array filter for filterSongListFlags.
     */
    private function filterSongListUnrankedFilter(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
    {
        return !item.is_unranked;
    }
    
    /**
     * Process the user filter on the given song list if enabled.
     * @param songList Song List Array for Song objects to filter.
     */
    private function filterSongListUser(songList                       : Dynamic) : Array<Dynamic>
    {
        if (as3hx.Compat.truthy(_gvars.activeFilter != null))
        {
            songList = songList.filter(filterSongListUserFilter);
        }
        
        return songList;
    }
    
    /**
     * Array filter for filterSongListUser.
     */
    private function filterSongListUserFilter(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
    {
        return _gvars.activeFilter.process(item, _gvars.activeUser);
    }
    
    /**
     * Selects and highlights a Song Item in the playlist for the given index.
     * @param index New Index
     * @param last Last Selected Index, if not -1, unhighlights the given index.
     * @param doScroll Scrolls to the song item when true.
     * @param mpUpdate Send update to multiplayer for selection. Only send for user selection events.
     */
    public function setActiveIndex(index                       : Dynamic, last                       : Dynamic, doScroll                       : Dynamic= false, mpUpdate                       : Dynamic= true) : Void
    // No need to do anything if nothing changed, or nothing to select
    {
        
        if (as3hx.Compat.truthy(index == last))
        {
            return;
        }
        
        // Reset on invalid index.
        if (as3hx.Compat.truthy(songItems.length <= 0 || index < 0 || index >= songItems.length))
        {
            options.activeIndex = -1;
            options.activeSongId = -1;
            return;
        }
        
        // Set Index
        options.activeIndex = index;
        
        // "All" uses pages of ITEM_PER_PAGE, so the index will be higher then ITEM_PER_PAGE on other pages. Take care of it.
        if (as3hx.Compat.truthy(options.activeGenre <= -1))
        {
            index %= ITEM_PER_PAGE;
            last %= ITEM_PER_PAGE;
        }
        
        // Set Song
        options.activeSongId = songItems[index].level;
        
        // Set Active Highlights
        songItems[index].active = true;
        if (as3hx.Compat.truthy(last >= 0 && last < songItems.length))
        {
            songItems[last].highlight = false;
            songItems[last].active = false;
        }
        
        // Scroll when doScroll is set.
        if (as3hx.Compat.truthy(doScroll && scrollbar.draggerVisibility))
        {
            var scrollVal                       : Dynamic= ((((songItems[index].y / pane.content.height) > 0.5)) ? ((songItems[index].y + songItems[index].height) / pane.content.height) : ((songItems[index].y) / pane.content.height));
            options.scroll_position = scrollVal;
            pane.scrollTo(scrollVal);
            scrollbar.scrollTo(scrollVal);
        }
    }
    
    /**
     * Called from the playlist scroll pane when a song item is clicked.
     * When a new song is selected, sets the active index and draws the info box for the new song information.
     * If the same item is clicked twice, begins loading of the song.
     * @param e
     */
    private function songItemClicked(e                       : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, SongItem)))
        {
            var tarSongItem                       : Dynamic= (try cast(e.target, SongItem) catch(e:Dynamic) null);
            if (as3hx.Compat.truthy(tarSongItem.index != options.activeIndex))
            {
                options.infoTab = TAB_PLAYLIST;
                setActiveIndex(tarSongItem.index, options.activeIndex);
                buildInfoBox();
            }
            else if (as3hx.Compat.truthy(!tarSongItem.isLocked && options.infoTab == TAB_PLAYLIST))
            {
                if (as3hx.Compat.truthy(_mp.inGameRoom))
                {
                    multiplayerLoad(tarSongItem.level);
                }
                else
                {
                    playSong(tarSongItem.level);
                }
            }
            else
            {
                options.infoTab = TAB_PLAYLIST;
                buildInfoBox();
            }
        }
    }
    
    /**
     * Song Item Context Menu: Display the Song Notes popup for the interacted Song Item.
     * @param e
     */
    private function e_songOptionsContextSelect(e                       : Dynamic) : Void
    {
        var songItem                       : Dynamic= (try cast(e.contextMenuOwner, SongItem) catch(e:Dynamic) null);
        var songInfo                       : Dynamic= _playlist.getSongInfo(songItem.level);
        
        if (as3hx.Compat.truthy(songInfo != null))
        {
            _gvars.gameMain.addPopup(new PopupSongNotes(this, songInfo));
        }
    }
    
    /**
     * Song Item Context Menu: Sets the interacted song as the current menu music.
     * This handles loading the music in the background if not already loaded,
     * or sets the music from the already loaded copy if available.
     * @param e
     */
    private function e_setAsMenuMusicContextSelect(e                       : Dynamic) : Void
    {
        _gvars.options = new GameOptions();
        _gvars.options.fill();
        var songItem                       : Dynamic= (try cast(e.contextMenuOwner, SongItem) catch(e:Dynamic) null);
        var songInfo                       : Dynamic= _playlist.getSongInfo(songItem.level);
        if (as3hx.Compat.truthy(songInfo != null))
        {
            var song                       : Dynamic= _gvars.getSongFile(songInfo);
            if (as3hx.Compat.truthy(song.isLoaded))
            {
                writeMenuMusicBytes(song);
                playMenuMusicSong(song);
            }
            else
            {
                Alert.add(sprintf(_lang.string("song_selection_load_music_for"), {
                                    name : songInfo.name
                                }), 90);
                song.addEventListener(Event.COMPLETE, e_menuMusicConvertSongLoad);
            }
        }
    }
    
    /**
     * Song Item Context Menu: Plays the chart preview of the selected song.
     */
    private function e_playChartPreviewContextSelect(e                       : Dynamic) : Void
    {
        _gvars.options = new GameOptions();
        _gvars.options.fill();
        _gvars.options.replay = new SongPreview(0);
        
        if (as3hx.Compat.truthy(!_gvars.options.replay.isLoaded))
        {
            (try cast(_gvars.options.replay, SongPreview) catch(e:Dynamic) null).setupSongPreview((try cast(e.contextMenuOwner, SongItem) catch(e:Dynamic) null).songInfo);
        }
        
        if (as3hx.Compat.truthy(_gvars.options.replay.isLoaded)) {
_gvars.songQueue = [];
            _gvars.songQueue.push(Playlist.instance.getSongInfo(_gvars.options.replay.level));
            
            // Switch to game
            Alert.add(_lang.string("song_selection_load_play_chart_preview"));
            switchTo(Main.GAME_PLAY_PANEL);
        }
    }
    
    /**
     * Song Item Context Menu: Same as for setting a song as the current menu music,
     * but for playing a song preview instead.
     * @param e
     */
    private function e_listenToSongPreviewContextSelect(e                       : Dynamic) : Void
    {
        _gvars.options = new GameOptions();
        _gvars.options.fill();
        
        var songItem                       : Dynamic= (try cast(e.contextMenuOwner, SongItem) catch(e:Dynamic) null);
        var songInfo                       : Dynamic= _playlist.getSongInfo(songItem.level);
        if (as3hx.Compat.truthy(songInfo != null))
        {
            var song                       : Dynamic= _gvars.getSongFile(songInfo);
            if (as3hx.Compat.truthy(song.isLoaded))
            {
                playSongPreview(song);
            }
            else
            {
                Alert.add(sprintf(_lang.string("song_selection_load_music_for"), {
                                    name : songInfo.name
                                }), 90);
                song.addEventListener(Event.COMPLETE, e_songPreviewConvertSongLoad);
            }
        }
    }
    
    /**
     * Song Item Context Menu: Removes the interacted with Song Item from the Song Queue.
     * @param e
     */
    private function e_removeFromQueueContextSelect(e                       : Dynamic) : Void
    {
        var songItem                       : Dynamic= (try cast(e.contextMenuOwner, SongItem) catch(e:Dynamic) null);
        _gvars.songQueue.removeAt(songItem.index);
        saveQueuePlaylist();
        
        buildPlayList();
        buildInfoBox();
    }
    
    /**
     * Save the queue playlist into the song selection menu options.
     */
    private function saveQueuePlaylist() : Void
    {
        options.queuePlaylist = _gvars.songQueue;
    }
    
    /**
     * Updates the displayed song note for the given level.
     * @param level
     */
    public function updateSongItemNote(level                       : Dynamic) : Void
    {
        for (i in 0...songItems.length)
        {
            if (as3hx.Compat.truthy(options.activeSongId == songItems[i].level))
            {
                songItems[i].updateOrShow();
                if (as3hx.Compat.truthy(options.infoTab == TAB_PLAYLIST))
                {
                    buildInfoBox();
                }
                break;
            }
        }
    }
    
    
    //******************************************************************************************//
    // Info Box Logic
    //******************************************************************************************//
    
    /**
     * General builder for the Info Box.
     */
    public function buildInfoBox() : Void
    {
        if (as3hx.Compat.truthy(infoBox == null))
        {
            return;
        }
        
        // Deselect Buttons
        for (bti in 0...optionsBox.numChildren)
        {
            optionsBox.getChildAt(bti).alpha = 0.75;
        }
        
        // Get Song Details
        var songInfo                       : Dynamic= _playlist.getSongInfo(options.activeSongId);
        
        //- Cleanup old Info Box
        infoBox.removeChildren();
        
        //- Sanity
        if (as3hx.Compat.truthy(songInfo == null && options.infoTab != TAB_QUEUE && options.infoTab != TAB_SEARCH))
        {
            return;
        }
        
        //- Build Info Box
        // Song Search
        if (as3hx.Compat.truthy(options.infoTab == TAB_SEARCH))
        {
            buildInfoBoxSearch();
        }
        // Playlist Queue
        else if (as3hx.Compat.truthy(options.infoTab == TAB_QUEUE))
        {
            buildInfoBoxQueue();
        }
        // Song Ranks
        else if (as3hx.Compat.truthy(options.infoTab == TAB_HIGHSCORES))
        {
            buildInfoBoxHighscores(songInfo);
        }
        // Song Details
        else
        {
            
            buildInfoBoxSongDetails(songInfo);
        }
        
        // Action Buttons for Songs
        if (as3hx.Compat.truthy(options.infoTab == TAB_PLAYLIST || options.infoTab == TAB_HIGHSCORES))
        {
            buildInfoBoxSongActionButtons(songInfo);
        }
        
        // For search, set focus on search box:
        if (as3hx.Compat.truthy(options.infoTab == TAB_SEARCH))
        {
            stage.focus = searchBox.field;
        }
    }
    
    /**
     * Builds Search Display for the InfoBox.
     */
    public function buildInfoBoxSearch() : Void
    {
        sortIgnoreChange = true;
        
        // Highlight Tab Button
        optionsBox.getChildAt(0).alpha = 1;
        
        // Search Box
        if (as3hx.Compat.truthy(searchBox == null))
        {
            searchBox = new BoxText(null, 5, 5, 163, 25);
        }
        
        infoBox.addChild(searchBox);
        
        // Search Type
        var searchTypeBoxItems                       : Dynamic= [{
            label : _lang.stringSimple("song_selection_search_song_name"),
            data : "name"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_author"),
            data : "author"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_stepauthor"),
            data : "stepauthor"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_style"),
            data : "style"
        }
    ];
        
        if (as3hx.Compat.truthy(searchTypeBox != null))
        {
            searchTypeBox.removeEventListener(Event.SELECT, searchTypeSelect);
        }
        
        searchTypeBox = new ComboBox(null, 5, 36, "", searchTypeBoxItems);
        searchTypeBox.setSize(165, 27);
        searchTypeBox.fontSize = 11;
        searchTypeBox.addEventListener(Event.SELECT, searchTypeSelect);
        infoBox.addChild(searchTypeBox);
        
        var searchBtn                       : Dynamic= new BoxButton(infoBox, 5, 68, 164, 25, _lang.string("song_selection_search_panel_search"), 12, clickHandler);
        searchBtn.action = "doSearch";
        
        // Order Type
        new Text(infoBox, 5, 137, _lang.string("song_selection_sort"), 14, "#DDDDDD");
        
        //- data tag should match tag names in SongInfo
        var sortTypeBoxItems                       : Dynamic= [{
            label : _lang.stringSimple("song_selection_search_default"),
            data : null
        }, 
        {
            label : _lang.stringSimple("song_selection_search_song_name"),
            data : "name"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_author"),
            data : "author"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_stepauthor"),
            data : "stepauthor"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_style"),
            data : "style"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_difficulty"),
            data : "difficulty"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_length"),
            data : "time_secs"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_note_count"),
            data : "note_count"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_nps"),
            data : "max_nps"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_id"),
            data : "level"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_rank"),
            data : "rank"
        }, 
        {
            label : _lang.stringSimple("song_selection_search_raw_goods"),
            data : "raw_goods"
        }
    ];
        
        if (as3hx.Compat.truthy(sortTypeBox != null))
        {
            sortTypeBox.removeEventListener(Event.SELECT, sortTypeSelect);
        }
        
        sortTypeBox = new ComboBox(null, 5, 162, "", sortTypeBoxItems);
        sortTypeBox.setSize(165, 25);
        sortTypeBox.fontSize = 11;
        sortTypeBox.numVisibleItems = sortTypeBoxItems.length;
        sortTypeBox.addEventListener(Event.SELECT, sortTypeSelect);
        infoBox.addChild(sortTypeBox);
        
        var sortOrderBoxItems                       : Dynamic= [{
            label : _lang.stringSimple("song_selection_sort_asc"),
            data : "asc"
        }, 
        {
            label : _lang.stringSimple("song_selection_sort_desc"),
            data : "desc"
        }
    ];
        
        if (as3hx.Compat.truthy(sortOrderBox != null))
        {
            sortOrderBox.removeEventListener(Event.SELECT, sortOrderSelect);
        }
        
        sortOrderBox = new ComboBox(null, 5, 191, "", sortOrderBoxItems);
        sortOrderBox.setSize(165, 25);
        sortOrderBox.fontSize = 11;
        sortOrderBox.addEventListener(Event.SELECT, sortOrderSelect);
        infoBox.addChild(sortOrderBox);
        
        // Random Song
        var randomButton                       : Dynamic= new BoxButton(infoBox, 5, 288, 164, 27, _lang.string("song_selection_filter_panel_random"), 12, clickHandler);
        randomButton.action = "doFilterRandom";
        
        // Save Search Parameters
        if (as3hx.Compat.truthy(options.last_search_text != null))
        {
            searchBox.text = options.last_search_text;
            searchBox.field.setSelection(searchBox.field.length, searchBox.field.length);
            options.last_search_text = null;
        }
        
        // Saved Search Type
        if (as3hx.Compat.truthy(options.last_search_type != null))
        {
            searchTypeBox.selectedItemByData = options.last_search_type;
        }
        else if (as3hx.Compat.truthy(searchTypeBox.selectedIndex == -1))
        {
            searchTypeBox.selectedIndex = 0;
        }
        
        // Saved Sort Type
        if (as3hx.Compat.truthy(options.last_sort_type != null))
        {
            sortTypeBox.selectedItemByData = options.last_sort_type;
        }
        else if (as3hx.Compat.truthy(sortTypeBox.selectedIndex == -1))
        {
            sortTypeBox.selectedIndex = 0;
        }
        
        // Saved Sort Order
        if (as3hx.Compat.truthy(options.last_sort_order != null))
        {
            sortOrderBox.selectedItemByData = options.last_sort_order;
        }
        else if (as3hx.Compat.truthy(sortOrderBox.selectedIndex == -1))
        {
            sortOrderBox.selectedIndex = 0;
        }
        
        sortIgnoreChange = false;
    }
    
    /**
     * Builds the Queue Information Display for the InfoBox.
     */
    public function buildInfoBoxQueue() : Void
    {
        var infoTitle                       : Dynamic= null;
        var infoDetails                       : Dynamic= null;
        var tY                       : Dynamic= 0;
        
        // Highlight Tab Button
        optionsBox.getChildAt(1).alpha = 1;
        
        // Get Song Length
        var songTotalLength                       : Dynamic= 0;
        for (qS in as3hx.Compat.iter(Reflect.fields(_gvars.songQueue)))
        {
            songTotalLength += (try cast(_gvars.songQueue[qS], SongInfo) catch(e:Dynamic) null).time_secs;
        }
        
        infoTitle = new Text(infoBox, 5, tY, _lang.string("song_selection_queue_panel_title"), 14, "#DDDDDD");
        infoTitle.width = 164;
        tY += 32;
        
        var queueDisplay                       : Dynamic= [[_lang.string("song_selection_queue_panel_total_songs"), NumberUtil.numberFormat(_gvars.songQueue.length)], [_lang.string("song_selection_queue_panel_total_length"), TimeUtil.convertToHHMMSS(songTotalLength)]];
        
        for (queueItem in as3hx.Compat.iter(Reflect.fields(queueDisplay))) {
infoTitle = new Text(infoBox, 5, tY, Reflect.field(queueDisplay, queueItem)[0], 14, "#DDDDDD");
            infoTitle.width = 164;
            tY += 16;
            
            // Info Display
            infoDetails = new Text(infoBox, 5, tY, Reflect.field(queueDisplay, queueItem)[1]);
            infoDetails.width = 164;
            tY += 23;
        }
        
        var isQueueNotEmpty                       : Dynamic= (options.queuePlaylist.length > 0);
        var isQueueNotAlone                       : Dynamic= (options.queuePlaylist.length > 1);
        
        // Actions
        var songQueuePlay                       : Dynamic= new BoxButton(infoBox, 5, 160, 164, 27, _lang.string("song_selection_queue_panel_play"), 12, clickHandler);
        songQueuePlay.action = "playQueue";
        songQueuePlay.enabled = isQueueNotEmpty;
        
        var songQueuePlayFromHere                       : Dynamic= new BoxButton(infoBox, 5, 192, 164, 27, _lang.string("song_selection_queue_panel_play_from_here"), 12, clickHandler);
        songQueuePlayFromHere.action = "playQueueFromHere";
        songQueuePlayFromHere.enabled = isQueueNotAlone;
        
        var songQueueRandomizer                       : Dynamic= new BoxButton(infoBox, 5, 224, 164, 27, _lang.string("song_selection_queue_panel_randomize"), 12, clickHandler);
        songQueueRandomizer.action = "queueRandomize";
        songQueueRandomizer.enabled = isQueueNotAlone;
        
        var songQueueManager                       : Dynamic= new BoxButton(infoBox, 5, 256, 164, 27, _lang.string("song_selection_queue_panel_manager"), 12, clickHandler);
        songQueueManager.action = "queueManager";
        
        var songQueueSave                       : Dynamic= new BoxButton(infoBox, 5, 288, 79.5, 27, _lang.string("song_selection_queue_panel_save"), 12, clickHandler);
        songQueueSave.action = "queueSave";
        songQueueSave.enabled = isQueueNotEmpty;
        
        var songQueueClear                       : Dynamic= new BoxButton(infoBox, 89.5, 288, 79.5, 27, _lang.string("song_selection_queue_panel_clear"), 12, clickHandler);
        songQueueClear.action = "clearQueue";
        songQueueClear.enabled = isQueueNotEmpty;
    }
    
    /**
     * Builds the Highscore Display for the InfoBox for the given song.
     */
    public function buildInfoBoxHighscores(songInfo                       : Dynamic) : Void
    {
        var infoTitle                       : Dynamic= null;
        var infoDetails                       : Dynamic= null;
        var infoPAHover                       : Dynamic= null;
        var tY                       : Dynamic= 0;
        
        infoTitle = new Text(infoBox, 5, tY, _lang.string("song_selection_song_panel_highscores"), 14, "#DDDDDD");
        infoTitle.width = 164;
        
        // Refresh button
        var refreshBtn                       : Dynamic= new BoxButton(infoBox, infoBox.width - 19 - 2, 2, 19, 19, "R", 12, refreshHighscoresClick);
        var openBtn                       : Dynamic= new BoxButton(infoBox, refreshBtn.x - 19 - 2, 2, 19, 19, "O", 12, openHighscoresClick);
        openBtn.songInfo = songInfo;
        
        var infoRanks                     : Dynamic= as3hx.Compat.orValue(_gvars.activeUser.getLevelRank(songInfo), { });
        var highscores                       : Dynamic= _gvars.getHighscores(songInfo.level);
        if (as3hx.Compat.truthy(highscores != null && Reflect.field(highscores, "1") != null)) {
{
                var lastRank                       : Dynamic= 0;
                var lastScore                       : Dynamic= as3hx.Compat.FLOAT_MAX;
                tY = 21;
                for (r in 1...5)
                {
                    if (as3hx.Compat.truthy(as3hx.Compat.field(highscores, r) != null))
                    {
                        var username                       : Dynamic= Reflect.field(as3hx.Compat.field(highscores, r), "username");
                        var score                       : Dynamic= Reflect.field(as3hx.Compat.field(highscores, r), "score");
                        var isMyPB                       : Dynamic= (!_gvars.activeUser.isGuest) && (_gvars.activeUser.name == username);
                        
                        if (as3hx.Compat.truthy(score < lastScore))
                        {
                            lastScore = score;
                            lastRank = r;
                        }
                        
                        infoPAHover = new HoverPABox(5, tY, Reflect.field(as3hx.Compat.field(highscores, r), "av"));
                        
                        // Username
                        infoTitle = new Text(infoBox, 5, tY, "<font color=\"#CCCCCC\">#" + lastRank + ":</font> " + username, 14);
                        infoTitle.width = 164;
                        infoTitle.fontColor = (isMyPB) ? "#D9FF9E" : "#FFFFFF";
                        tY += 16;
                        
                        // Rank
                        infoDetails = new Text(infoBox, 5, tY, NumberUtil.numberFormat(score), 12);
                        infoDetails.width = 164;
                        infoDetails.fontColor = (isMyPB) ? "#B8D8B3" : "#DDDDDD";
                        tY += 23;
                        
                        // PA Hover Box
                        infoBox.addChild(infoPAHover);
                    }
                }
                
                infoPAHover = new HoverPABox(5, tY, infoRanks.results);
                
                // Username
                infoTitle = new Text(infoBox, 5, tY, "#" + infoRanks.rank + ": " + _gvars.activeUser.name, 14, "#D9FF9E");
                infoTitle.width = 164;
                tY += 16;
                
                // Rank
                infoDetails = new Text(infoBox, 5, tY, NumberUtil.numberFormat(infoRanks.rawscore), 12, "#B8D8B3");
                infoDetails.width = 164;
                tY += 23;
                
                // PA Hover Box
                infoBox.addChild(infoPAHover);
            }
        }
        else
        {
            var throbber                       : Dynamic= new Throbber();
            throbber.x = 75;
            throbber.y = 122;
            infoBox.addChild(throbber);
            throbber.start();
            
            _gvars.addEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
            _gvars.loadHighscores(songInfo.level);
        }
    }
    
    /**
     * Builds the Song Details and Information Display for the InfoBox for the given song.
     */
    public function buildInfoBoxSongDetails(songInfo                       : Dynamic) : Void
    {
        var infoTitle                       : Dynamic= null;
        var infoDetails                       : Dynamic= null;
        var infoPAHover                       : Dynamic= null;
        var tY                       : Dynamic= 0;
        
        var infoRanks                     : Dynamic= as3hx.Compat.orValue(_gvars.activeUser.getLevelRank(songInfo), { });
        var infoDisplay                       : Dynamic= [["song", songInfo.name], 
        ["author", songInfo.author], 
        ["stepfile", songInfo.stepauthor], 
        ["length", ((songInfo.note_count > 0) ? sprintf(_lang.string("song_selection_song_panel_length_value"), {
                    time : songInfo.time,
                    note_count : songInfo.note_count
                }) : songInfo.time)], 
        ["style", songInfo.style], 
        ["best", ((infoRanks.score > 0) ? "\n" + NumberUtil.numberFormat(infoRanks.score) + "\n" + infoRanks.results : _lang.string("song_selection_song_panel_unplayed"))]
    ];
        
        // Get User Star Rating
        var starRating                       : Dynamic= _gvars.playerUser.getSongRating(songInfo);
        if (as3hx.Compat.truthy(starRating > 0))
        {
            var ratingDisplay                       : Dynamic= new StarSelector(infoBox, 109, 5, false);
            ratingDisplay.value = starRating;
            ratingDisplay.scaleX = ratingDisplay.scaleY = 0.4;
            ratingDisplay.alpha = 0.8;
            ratingDisplay.outline = false;
            ratingDisplay.addBackgroundStars();
        }
        
        // Print Song Info
        for (item in as3hx.Compat.iter(Reflect.fields(infoDisplay))) {
infoTitle = new Text(infoBox, 5, tY, _lang.string("song_selection_song_panel_" + as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 0)), 14, "#DDDDDD");
            infoTitle.width = 164;
            tY += 16;
            
            // Info Display
            infoDetails = new Text(infoBox, 5, tY, as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 1), "");
            infoDetails.width = 164;
            tY += 23;
            
            if (as3hx.Compat.truthy(as3hx.Compat.field(as3hx.Compat.field(infoDisplay, item), 0) == "best" && infoRanks.results != null)) {
var rawGoods                       : Dynamic= NumberUtil.numberFormat(SkillRating.getRawGoods(infoRanks), 1, true);
                
                // Get song % played
                var songPercentageString                       : Dynamic= as3hx.Compat.toFixed(Math.min(100, Math.max(0, (infoRanks.perfect + infoRanks.good + infoRanks.average + infoRanks.miss) / songInfo.note_count * 100)), 2);
                
                if (as3hx.Compat.truthy(songPercentageString != "0.00")) {
var hoverString                       : Dynamic= _lang.string("song_selection_song_panel_rghover" + ((songPercentageString != "100.00") ? "_unfinished" : ""));
                    
                    // Add raw goods Hover Box
                    infoPAHover = new HoverPABox(5, tY, sprintf(hoverString, {
                                        raw : rawGoods,
                                        percent : songPercentageString
                                    }));
                    infoBox.addChild(infoPAHover);
                }
            }
        }
    }
    
    /**
     * Add the buttons for Adding to Queue, Highscores, and Play
     */
    public function buildInfoBoxSongActionButtons(songInfo                       : Dynamic) : Void
    {
        var accessLevel                       : Dynamic= _gvars.checkSongAccess(songInfo);
        var isCanonEngine                       : Dynamic= !songInfo.engine;
        if (as3hx.Compat.truthy(accessLevel == GlobalVariables.SONG_ACCESS_PLAYABLE))
        {
            var buttonWidth                       : Dynamic= (isCanonEngine) ? 51.5 : 79.5;
            
            //- Make Display
            var songQueueButton                       : Dynamic= new BoxIcon(infoBox, 5, 256, buttonWidth, 27, new IconList(), songQueueClick);
            songQueueButton.level = songInfo.level;
            songQueueButton.setHoverText(_lang.string("song_selection_song_panel_hover_queue"));
            
            if (as3hx.Compat.truthy(isCanonEngine))
            {
                var songHighscoresButton                       : Dynamic= new BoxIcon(infoBox, 5 + buttonWidth + 5, 256, buttonWidth + 1, 27, new IconTrophy(), clickHandler);
                songHighscoresButton.level = songInfo.level;
                songHighscoresButton.action = "highscores";
                songHighscoresButton.setHoverText((options.infoTab == TAB_HIGHSCORES) ? _lang.string("song_selection_song_panel_hover_info") : _lang.string("song_selection_song_panel_hover_scores"));
            }
            
            var songOptionsButton                       : Dynamic= new BoxIcon(infoBox, 5 + buttonWidth + 6 + ((isCanonEngine) ? (buttonWidth + 5) : 0), 256, buttonWidth, 27, new IconGear(), clickHandler);
            songOptionsButton.level = songInfo.level;
            songOptionsButton.action = "songOptions";
            songOptionsButton.setHoverText(_lang.string("song_selection_song_panel_hover_song_options"));
            
            if (as3hx.Compat.truthy(_mp.inGameRoom))
            {
                var mpText                       : Dynamic= _lang.string((_mp.GAME_ROOM.owner == _mp.currentUser) ? "song_selection_song_panel_mp_select" : "song_selection_song_panel_mp_request");
                var songSelectButton                       : Dynamic= new BoxButton(infoBox, 5, 288, 164, 27, mpText, 14, songLoadClick);
                songSelectButton.level = songInfo.level;
            }
            else
            {
                var songStartButton                       : Dynamic= new BoxButton(infoBox, 5, 288, 164, 27, _lang.string("song_selection_song_panel_play"), 14, songStartClick);
                songStartButton.level = songInfo.level;
            }
        }
        else if (as3hx.Compat.truthy(isCanonEngine))
        {
            var song_price                       : Dynamic= songInfo.price;
            if (as3hx.Compat.truthy(!Math.isNaN(song_price) && song_price > 0))
            {
                var hasEnoughCredits                       : Dynamic= (_gvars.activeUser.credits >= song_price);
                
                var purchasedSongButtonLocked                       : Dynamic= new BoxButton(infoBox, 5, 256, 164, 27, sprintf(_lang.string("song_selection_song_panel_purchase"), {
                            song_price : song_price
                        }), 12, clickHandler);
                purchasedSongButtonLocked.song_details = songInfo;
                purchasedSongButtonLocked.action = "purchase";
                purchasedSongButtonLocked.enabled = hasEnoughCredits;
                
                // Check for existing purchased web request
                if (as3hx.Compat.truthy(purchasedSongButtonLocked.enabled))
                {
                    for (request in as3hx.Compat.iter(purchasedWebRequests))
                    {
                        if (as3hx.Compat.truthy(request.level == songInfo.level))
                        {
                            purchasedSongButtonLocked.enabled = false;
                            break;
                        }
                    }
                }
                
                // Display message if not enough credits
                if (as3hx.Compat.truthy(!hasEnoughCredits))
                {
                    var infoPAHover                       : Dynamic= new HoverPABox(5, 256, sprintf(_lang.string("song_selection_song_panel_purchase_not_enough"), {
                                credits : _gvars.activeUser.credits,
                                price : song_price
                            }));
                    infoPAHover.delay = 50;
                    infoBox.addChild(infoPAHover);
                }
            }
            
            var songHighscoresButtonLocked                       : Dynamic= new BoxButton(infoBox, 5, 288, 164, 27, ((options.infoTab == TAB_HIGHSCORES) ? _lang.string("song_selection_song_panel_info") : _lang.string("song_selection_song_panel_scores")), 12, clickHandler);
            songHighscoresButtonLocked.level = songInfo.level;
            songHighscoresButtonLocked.action = "highscores";
        }
    }
    
    /**
     * Called from Info Box: Adds the active song into the song queue.
     */
    private function songQueueClick(e                       : Dynamic) : Void
    {
        Alert.add(sprintf(_lang.string("song_selection_add_to_queue"), {
                            song_name : _playlist.getSongInfo(e.target.level).name
                        }), 90);
        _gvars.songQueue.push(_playlist.getSongInfo(e.target.level));
        saveQueuePlaylist();
        if (as3hx.Compat.truthy(options.activeGenre == PLAYLIST_QUEUE))
        {
            buildPlayList();
        }
    }
    
    /**
     * Called from Info Box: Attempts to begin play of the active song.
     * @param e
     */
    private function songStartClick(e                       : Dynamic) : Void
    {
        playSong(e.target.level);
    }
    
    /**
     * Called from Info Box: Attempts to load a song for multiplayer gameplay.
     * @param e
     */
    private function songLoadClick(e                       : Dynamic) : Void
    {
        multiplayerLoad(e.target.level);
    }
    
    /**
     * Updates the selected multiplayer song and begins loading the song.
     * It also alerts multiplayer to watch for the other players load status to begin gameplay.
     * @param level Level ID of song to load.
     */
    private function multiplayerLoad(level                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(level < 0))
        {
            return;
        }
        
        _mp.ffrSelectSong(_playlist.getSongInfo(level));
        switchTo(MainMenu.MENU_MULTIPLAYER);
    }
    
    /**
     * Reset the song queue and adds the provided level to the queue and starts the queue.
     * @param level Level ID to add.
     */
    private function playSong(level                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(level < 0))
        {
            return;
        }
        
        _gvars.songQueue = [];
        var songInfo                       : Dynamic= _playlist.getSongInfo(level);
        if (as3hx.Compat.truthy(songInfo != null))
        {
            _gvars.songQueue.push(songInfo);
            playQueue();
        }
    }
    
    /**
     * Begins the current queue, while filtering out unplayable songs to prevent issues.
     */
    private function playQueue(queueIndex                       : Dynamic= 0) : Void
    {
        if (as3hx.Compat.truthy(queueIndex < 0))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(queueIndex != 0))
        {
            _gvars.songQueue = _gvars.songQueue.slice(queueIndex);
        }
        
        _gvars.songQueue = _gvars.songQueue.filter(function(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
                        {
                            return (_gvars.checkSongAccess(item) == GlobalVariables.SONG_ACCESS_PLAYABLE);
                        });
        
        if (as3hx.Compat.truthy(_gvars.songQueue.length <= 0))
        {
            return;
        }
        
        saveSearchTextAndType();
        
        _gvars.options = new GameOptions();
        _gvars.options.fill();
        switchTo(Main.GAME_PLAY_PANEL);
    }
    
    /**
     * Does a song search for a matching term on the selected type.
     * Known types are "name", "author", "stepauthor", "style".
     * @param name Search Term
     */
    private function doSearch(search_term                       : Dynamic) : Void
    {
        var searchTypeParam                     : Dynamic= Reflect.field(searchTypeBox.selectedItem, "data");
        options.activeGenre = PLAYLIST_SEARCH;
        options.activeSongId = -1;
        options.activeIndex = -1;
        options.pageNumber = 0;
        options.isFilter = true;
        options.filter = function(songInfo                       : Dynamic) : Bool
                {
                    return Reflect.field(songInfo, searchTypeParam).toLowerCase().indexOf(search_term.toLowerCase()) > -1;
                };
        options.scroll_position = 0;
        
        updateGenreList();
        buildPlayList();
    }
    
    private function searchTypeSelect(e                       : Dynamic) : Void
    {
        options.last_search_type = Reflect.field(e.target.selectedItem, "data");
    }
    
    private function sortTypeSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(sortIgnoreChange))
        {
            return;
        }
        
        options.last_sort_type = Reflect.field(e.target.selectedItem, "data");
        buildPlayList();
    }
    
    private function sortOrderSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(sortIgnoreChange))
        {
            return;
        }
        
        options.last_sort_order = Reflect.field(e.target.selectedItem, "data");
        buildPlayList();
    }
    
    /**
     * Does a specific search for a selected song from a multiplayer lobby.
     * It will use a song object first to make level ids first, and if none
     * given, will look for an exact match on the song name instead.
     * @param songName Song Name
     * @param songInfo SongInfo Object
     */
    public function multiplayerSelect(songName                       : Dynamic, songInfo                       : Dynamic) : Void
    {
        saveSearchTextAndType();
        options.activeGenre = PLAYLIST_SEARCH;
        options.activeSongId = ((songInfo != null && songInfo.level)) ? songInfo.level : -1;
        options.pageNumber = 0;
        options.isFilter = true;
        if (as3hx.Compat.truthy(songInfo != null))
        {
            options.filter = function(_songInfo                       : Dynamic) : Bool
                    {
                        return _songInfo.level == songInfo.level;
                    };
        }
        else
        {
            options.filter = function(_songInfo                       : Dynamic) : Bool
                    {
                        return _songInfo.name == songName;
                    };
        }
        options.infoTab = TAB_PLAYLIST;
        updateGenreList();
        buildPlayList();
        buildInfoBox();
        
        for (i in 0...songItems.length)
        {
            if (as3hx.Compat.truthy(songItems[i].level == options.activeSongId))
            {
                setActiveIndex(i, -1, true);
            }
        }
    }
    
    /**
     * Called from Info Box: Clears the loaded highscores entries to allow reloading from the server.
     */
    private function refreshHighscoresClick(e                       : Dynamic) : Void
    {
        _gvars.clearHighscores();
        _gvars.activeUser.loadLevelRanks();
        buildInfoBox();
    }
    
    /**
     * Called from Info Box: Open highscores popup for the song.
     */
    private function openHighscoresClick(e                       : Dynamic) : Void
    {
        addPopup(new PopupHighscores(this, e.target.songInfo));
    }
    
    /**
     * Callback function for when highscores are loaded.
     * @param e unused
     */
    private function highscoresLoaded(e                       : Dynamic) : Void
    {
        _gvars.removeEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
        buildInfoBox();
    }
    
    /**
     * Swaps the display between Queue and Playlist
     */
    public function swapToQueue(selectToken                       : Dynamic= true) : Void
    {
        if (as3hx.Compat.truthy(selectToken || options.activeGenre != PLAYLIST_QUEUE))
        {
            options.pageNumber = 0;
            options.activeIndex = -1;
            options.activeSongId = -1;
            options.scroll_position = 0;
        }
        options.activeGenre = ((options.infoTab == TAB_QUEUE) ? PLAYLIST_QUEUE : 0);
        updateGenreList();
        buildPlayList();
        buildInfoBox();
    }
    
    /**
     * Resets the filter options.
     */
    private function resetFilterOptions() : Void
    {
        options.filter = null;
        options.isFilter = false;
    }
    
    /**
     * Save the search text and type.
     */
    private function saveSearchTextAndType() : Void
    {
        if (as3hx.Compat.truthy(searchBox != null))
        {
            options.last_search_text = searchBox.text;
        }
        if (as3hx.Compat.truthy(searchTypeBox != null))
        {
            options.last_search_type = Reflect.field(searchTypeBox.selectedItem, "data");
        }
    }
    
    //******************************************************************************************//
    // Page Related Logic
    //******************************************************************************************//
    
    /**
     * Draws a series of clickable boxes to provided pagnation to the song selection list.
     * If the current genre is ALL, it then provides pages that are split into chunks.
     */
    public function drawPages() : Void
    {
        if (as3hx.Compat.truthy(pages == null))
        {
            pages = new Sprite();
            pages.addEventListener(MouseEvent.CLICK, pageClicked, false, 0, true);
            this.addChild(pages);
        }
        
        pages.removeChildren();
        
        var isBigPage                       : Dynamic= (options.activeGenre <= -1 || GENRE_MODE == GENRE_SONGFLAGS);
        var totalPages                       : Dynamic= getTotalPages(isBigPage);
        
        // Configure Page Background
        var limit                       : Dynamic= ((isBigPage)) ? 7 : 18;
        background.pageBackground.x = ((totalPages > limit)) ? 3 : 32;
        background.pageBackground.width = ((totalPages > limit)) ? 605 : 545;
        
        // Draw Page Boxes
        buildPages(totalPages, isBigPage);
    }
    
    /**
     * Gets the total number of pages for the set genreLength. This number is assumes 12
     * items per page and caps at 20 max pages regardless if more is available.
     * When isBigPage is set, it uses genreLength / ITEM_PER_PAGE to determine page count.
     * @param isBigPage Use Bigger Page Style
     * @return Number of Pages
     */
    private function getTotalPages(isBigPage                       : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(isBigPage))
        {
            return as3hx.Compat.parseInt(Math.ceil(genreLength / ITEM_PER_PAGE));
        }
        return as3hx.Compat.parseInt(Math.min(Math.ceil(genreLength / 12), 20));
    }
    
    /**
     * Generates the page buttons at the bottom of the playlist pane.
     *
     * @param totalPages Page Count
     * @param isBigPage Use Bigger Page Style
     */
    private function buildPages(totalPages                       : Dynamic, isBigPage                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(isBigPage && totalPages > 16))
        {
            isBigPage = false;
        }
        
        var pBox                       : Dynamic= null;
        var page_width                       : Dynamic= ((isBigPage)) ? 72 : 27;
        var page_height                       : Dynamic= 16;
        var pages_per_row                       : Dynamic= as3hx.Compat.parseInt(600 / (page_width + 3));
        
        var page_x                       : Dynamic= null;
        var page_y                       : Dynamic= null;
        var page_scroll                       : Dynamic= null;
        var page_str                       : Dynamic= null;
        
        for (pY in 0...totalPages)
        {
            page_x = (page_width + 3) * (pY % pages_per_row);
            page_y = (page_height + 2) * Math.floor(pY / pages_per_row);
            page_scroll = (pY / (totalPages - 1));
            page_str = Std.string(pY + 1);
            
            if (as3hx.Compat.truthy(isBigPage))
            {
                page_str = ((pY * ITEM_PER_PAGE) + 1) + " - " + ((((pY + 1) * ITEM_PER_PAGE) > genreLength) ? genreLength : ((pY + 1) * ITEM_PER_PAGE));
            }
            
            pBox = new PageBox(pages, page_x, page_y);
            pBox.page = pY;
            pBox.page_scroll = page_scroll;
            pBox.setSize(page_width, page_height);
            pBox.setText(page_str);
        }
        
        pages.x = 145 + ((610 - pages.width) / 2);
        pages.y = (pages.height > 26) ? 417 : 424;
    }
    
    /**
     * Callback for PageBox clicks. Handles either scrolling though the playlist, or
     * swapping pages in the All Genres and Searches.
     * @param e
     */
    private function pageClicked(e                       : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, PageBox)))
        {
            var pagebox                       : Dynamic= (try cast(e.target, PageBox) catch(e:Dynamic) null);
            var targetPage                       : Dynamic= pagebox.page;
            if (as3hx.Compat.truthy(options.activeGenre <= -1 || GENRE_MODE == GENRE_SONGFLAGS))
            {
                if (as3hx.Compat.truthy(options.pageNumber != targetPage))
                {
                    options.activeSongId = -1;
                    options.activeIndex = -1;
                    options.pageNumber = targetPage;
                    options.infoTab = TAB_PLAYLIST;
                    buildPlayList();
                    buildInfoBox();
                }
            }
            else
            {
                options.scroll_position = pagebox.page_scroll;
                scrollbar.scrollTo(options.scroll_position);
                pane.scrollTo(options.scroll_position);
            }
        }
        stage.focus = stage;
    }
    
    //******************************************************************************************//
    // Event Handlers
    //******************************************************************************************//
    /**
     * General Click Handler for multiple objects.
     * @param e
     */
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == genre_mode_prev || e.target == genre_mode_next))
        {
            resetFilterOptions();
            GENRE_MODE = as3hx.Compat.parseInt(GENRE_MODE + ((e.target == genre_mode_prev) ? -1 : 1));
            if (as3hx.Compat.truthy(GENRE_MODE < 0))
            {
                GENRE_MODE = GENRE_MODES;
            }
            if (as3hx.Compat.truthy(GENRE_MODE > GENRE_MODES))
            {
                GENRE_MODE = 0;
            }
            LocalStore.setVariable("genre_mode", GENRE_MODE);
            options.scroll_position = 0;
            options.activeGenre = 0;
            options.activeIndex = -1;
            options.activeSongId = -1;
            options.infoTab = TAB_PLAYLIST;
            buildGenreList();
            buildPlayList();
            buildInfoBox();
        }
        else if (as3hx.Compat.truthy(e.target.action != null))
        {
            var clickAction                       : Dynamic= e.target.action;
            if (as3hx.Compat.truthy(clickAction == "search"))
            {
                resetFilterOptions();
                options.infoTab = ((options.infoTab == TAB_SEARCH) ? TAB_PLAYLIST : TAB_SEARCH);
                buildInfoBox();
                return;
            }
            else if (as3hx.Compat.truthy(clickAction == "playQueue"))
            {
                playQueue();
            }
            else if (as3hx.Compat.truthy(clickAction == "playQueueFromHere"))
            {
                playQueue(options.activeIndex);
            }
            else if (as3hx.Compat.truthy(clickAction == "doSearch"))
            {
                doSearch(searchBox.text);
            }
            else if (as3hx.Compat.truthy(clickAction == "queue"))
            {
                options.infoTab = (options.infoTab == TAB_QUEUE) ? TAB_PLAYLIST : TAB_QUEUE;
                swapToQueue(false);
            }
            else if (as3hx.Compat.truthy(clickAction == "highscores"))
            {
                options.infoTab = ((options.infoTab == TAB_PLAYLIST) ? TAB_HIGHSCORES : TAB_PLAYLIST);
                buildInfoBox();
            }
            else if (as3hx.Compat.truthy(clickAction == "purchase"))
            {
                var songDetails                       : Dynamic= e.target.song_details;
                var purchaseRequest                       : Dynamic= new WebRequest(URLs.resolve(URLs.SONG_PURCHASE_URL), e_purchaseSongComplete, e_purchaseSongFailure);
                purchaseRequest.level = songDetails.level;
                purchaseRequest.load({
                            level : songDetails.level,
                            session : _gvars.userSession
                        });
                purchasedWebRequests.push(purchaseRequest);
                
                e.target.enabled = false;
            }
            else if (as3hx.Compat.truthy(clickAction == "songOptions"))
            {
                var songInfo                       : Dynamic= _playlist.getSongInfo(e.target.level);
                
                if (as3hx.Compat.truthy(songInfo != null))
                {
                    _gvars.gameMain.addPopup(new PopupSongNotes(this, songInfo));
                }
            }
            else if (as3hx.Compat.truthy(clickAction == "clearQueue"))
            {
                _gvars.songQueue = [];
                saveQueuePlaylist();
                buildPlayList();
                buildInfoBox();
            }
            else if (as3hx.Compat.truthy(clickAction == "queueRandomize"))
            {
                for (rq in 0...5)
                {
                    _gvars.songQueue = ArrayUtil.randomize(_gvars.songQueue);
                }
                saveQueuePlaylist();
                buildPlayList();
                buildInfoBox();
            }
            else if (as3hx.Compat.truthy(clickAction == "queueSave"))
            {
                new PromptInput(this, _lang.string("song_selection_song_queue_name_prompt"), _lang.string("song_selection_queue_panel_save"), e_saveSongQueue);
            }
            else if (as3hx.Compat.truthy(clickAction == "queueManager"))
            {
                addPopup(new PopupQueueManager(this));
            }
            else if (as3hx.Compat.truthy(clickAction == "doFilterRandom"))
            {
                var randomList                       : Dynamic= songList.filter(function(item                       : Dynamic, index                       : Dynamic, array                       : Dynamic) : Bool
                        {
                            return ((_gvars.activeFilter) ? _gvars.activeFilter.process(item, _gvars.activeUser) : true) && _gvars.checkSongAccess(item) == GlobalVariables.SONG_ACCESS_PLAYABLE;
                        });
                if (as3hx.Compat.truthy(randomList.length > 0))
                {
                    var random                       : Dynamic= randomList[as3hx.Compat.parseInt(Math.floor(Math.random() * randomList.length))];
                    if (as3hx.Compat.truthy(_mp.inGameRoom))
                    {
                        multiplayerLoad(random.level);
                    }
                    else
                    {
                        playSong(random.level);
                    }
                    return;
                }
                else
                {
                    Alert.add(_lang.string("song_selection_no_songs_random"), 120, Alert.RED);
                }
            }
        }
    }
    
    /**
     * General Keyboard Key Down Handler for multiple objects.
     * @param e
     */
    private function keyHandler(e                       : Dynamic) : Void
    // Don't do anything with popups open.
    {
        
        if (as3hx.Compat.truthy(_gvars.gameMain.current_popup != null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(searchBox != null && options.infoTab == TAB_SEARCH && searchBox.focus))
        {
            var _sw3_ = (e.keyCode);            

            switch (_sw3_)
            {
                case Keyboard.ENTER:
                    doSearch(searchBox.text);
            }
            return;
        }
        
        var newIndex                       : Dynamic= options.activeIndex;
        var lastIndex                       : Dynamic= options.activeIndex;
        var maxGenreIndex                       : Dynamic= as3hx.Compat.parseInt(getTotalGenres() - 1);
        
        var _sw4_ = (e.keyCode);        

        switch (_sw4_)
        {
            case Keyboard.PAGE_UP:
                newIndex -= 11;
            
            case Keyboard.UP:
                newIndex -= 1;
            
            case Keyboard.PAGE_DOWN:
                newIndex += 11;
            
            case Keyboard.DOWN:
                newIndex += 1;
            
            case Keyboard.HOME:
                newIndex = 0;
            
            case Keyboard.END:
                newIndex = as3hx.Compat.parseInt(genreLength - 1);
            
            case Keyboard.TAB:
                resetFilterOptions();
                options.scroll_position = 0;
                options.activeIndex = -1;
                options.activeSongId = -1;
                options.activeGenre = options.activeGenre + ((e.ctrlKey) ? -1 : 1);
                options.infoTab = TAB_PLAYLIST;
                if (as3hx.Compat.truthy(options.activeGenre < -1))
                {
                    options.activeGenre = maxGenreIndex;
                }
                if (as3hx.Compat.truthy(options.activeGenre > maxGenreIndex))
                {
                    options.activeGenre = -1;
                }
                updateGenreList();
                buildPlayList();
                buildInfoBox();
                return;
            
            case Keyboard.ENTER:
                if (as3hx.Compat.truthy(!((Std.is(stage.focus, PushButton)) || (Std.is(stage.focus, TextField))) && options.activeSongId >= 0))
                {
                    if (as3hx.Compat.truthy(_mp.inGameRoom))
                    {
                        multiplayerLoad(options.activeSongId);
                    }
                    else
                    {
                        playSong(options.activeSongId);
                    }
                }
                return;
            default:
                if (as3hx.Compat.truthy(!((Std.is(stage.focus, PushButton)) || (Std.is(stage.focus, TextField))) && ((e.keyCode == Keyboard.BACKSPACE) || (e.keyCode == Keyboard.SPACE) || (e.keyCode >= 48 && e.keyCode <= 111) || (e.keyCode >= 186 && e.keyCode <= 222)))) {
if (as3hx.Compat.truthy(options.infoTab != TAB_SEARCH))
                    {
                        options.infoTab = TAB_SEARCH;
                        buildInfoBox();
                    }
                    stage.focus = searchBox.field;
                }
                return;
        }
        
        if (as3hx.Compat.truthy(genreLength == 0))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(newIndex < 0))
        {
            newIndex = 0;
        }
        else if (as3hx.Compat.truthy(newIndex > genreLength - 1))
        {
            newIndex = as3hx.Compat.parseInt(genreLength - 1);
        }
        
        if (as3hx.Compat.truthy(newIndex != lastIndex))
        {
            setActiveIndex(newIndex, lastIndex, true);
            buildInfoBox();
            stage.focus = null;
        }
    }
    
    /**
     * Mouse Wheel Handler for the Playlist Scroll Pane.
     * Moves the scroll pane based on the scroll delta direction.
     * @param e
     */
    private function mouseWheelHandler(e                       : Dynamic) : Void
    //- Sanity
    {
        
        if (as3hx.Compat.truthy(genreLength == 0 || !scrollbar.draggerVisibility))
        {
            return;
        }
        
        //- Scroll
        options.scroll_position = scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(options.scroll_position);
        scrollbar.scrollTo(options.scroll_position);
    }
    
    /**
     * Scroll Bar Moved Update Handler for the Playlist Scroll Bar.
     * Updates the scroll pane postion based on the scroll bar position.
     * @param e
     */
    private function scrollBarMoved(e                       : Dynamic) : Void
    {
        options.scroll_position = e.target.scroll;
        pane.scrollTo(e.target.scroll);
    }
    
    /**
     * Callback for saving a song queue.
     * @param subevent
     */
    private function e_saveSongQueue(queueName                       : Dynamic) : Void
    {
        var songArray                       : Dynamic= [];
        for (songQueueI in 0..._gvars.songQueue.length)
        {
            songArray[songArray.length] = _gvars.songQueue[songQueueI].level;
        }
        _gvars.playerUser.songQueues.push(new SongQueueItem(queueName, songArray));
        _gvars.playerUser.save();
    }
    
    /**
     * Called when a song purchase completes.
     * @param e
     */
    private function e_purchaseSongComplete(e                       : Dynamic) : Void
    {
        var level_id                       : Dynamic= null;
        
        // Remove Loader and get Level Info
        for (pur_loader in as3hx.Compat.iter(purchasedWebRequests))
        {
            if (as3hx.Compat.truthy(pur_loader.loader == e.target))
            {
                level_id = pur_loader.level;
                purchasedWebRequests.splice(Lambda.indexOf(purchasedWebRequests, pur_loader), 1)[0];
                break;
            }
        }
        
        var response                       : Dynamic= haxe.Json.parse(e.target.data);
        
        if (as3hx.Compat.truthy(Reflect.field(response, "status") == 0))
        {
            var songDetails                       : Dynamic= _playlist.getSongInfo(level_id);
            if (as3hx.Compat.truthy(songDetails != null && !songDetails.exists("error")))
            {
                Alert.add(sprintf(_lang.string("song_purchase_complete"), {
                                    name : songDetails.name
                                }), 120, Alert.DARK_GREEN);
            }
            
            _gvars.activeUser.setPurchasedString(Reflect.field(response, "purchased"));
            _gvars.activeUser.credits = Reflect.field(response, "credits");
            _playlist.updateSongAccess();
            
            buildPlayList();
        }
        else
        {
            Alert.add(_lang.string("song_purchase_error_" + Reflect.field(response, "status")), 120, Alert.RED);
        }
        
        if (as3hx.Compat.truthy(options.activeSongId == level_id && options.infoTab == TAB_PLAYLIST))
        {
            buildInfoBox();
        }
    }
    
    /**
     * Called when a song purchase fails.
     * @param e
     */
    private function e_purchaseSongFailure(e                       : Dynamic) : Void
    // Remove Loader and refresh Info Box if active song.
    {
        
        for (pur_loader in as3hx.Compat.iter(purchasedWebRequests))
        {
            if (as3hx.Compat.truthy(pur_loader.loader == e.target))
            {
                if (as3hx.Compat.truthy(options.activeSongId == pur_loader.level && options.infoTab == TAB_PLAYLIST))
                {
                    buildInfoBox();
                }
                purchasedWebRequests.splice(Lambda.indexOf(purchasedWebRequests, pur_loader), 1)[0];
                break;
            }
        }
    }
    
    //******************************************************************************************//
    // Menu Music
    //******************************************************************************************//
    
    /**
     * Callback for Menu Music Song when loaded and available.
     */
    private function e_menuMusicConvertSongLoad(e                       : Dynamic) : Void
    {
        var song                       : Dynamic= (try cast(e.target, Song) catch(e:Dynamic) null);
        song.removeEventListener(Event.COMPLETE, e_menuMusicConvertSongLoad);
        writeMenuMusicBytes(song);
        playMenuMusicSong(song);
    }
    
    /**
     * Callback for menu song preview when loaded and available.
     */
    private function e_songPreviewConvertSongLoad(e                       : Dynamic) : Void
    {
        var song                       : Dynamic= (try cast(e.target, Song) catch(e:Dynamic) null);
        song.removeEventListener(Event.COMPLETE, e_songPreviewConvertSongLoad);
        playSongPreview(song);
    }
    
    /**
     * Begins play of a loaded Song class object.
     * This updates the stored song name, begins music playback
     * and display the song controls.
     * @param song Song Class to set as menu music.
     */
    private function playMenuMusicSong(song                       : Dynamic) : Void
    {
        Alert.add(_lang.string("song_selection_playing_menu_music"));
        
        LocalStore.setVariable("menu_music", song.songInfo.name);
        var par                       : Dynamic= (try cast((this.my_Parent), MainMenu) catch(e:Dynamic) null);
        par.drawMenuMusicControls();
        par.updateMenuMusicControls();
        
        if (as3hx.Compat.truthy(_gvars.menuMusic))
        {
            _gvars.menuMusic.stop();
        }
        
        if (as3hx.Compat.truthy(previewMusic != null))
        {
            previewMusic.stop();
        }
        
        _gvars.menuMusic = new SongPlayerBytes(song.bytesSWF);
        _gvars.menuMusic.start();
    }
    
    /**
     * Same as playMenuMusicSong, but it plays the song preview without repeat
     * and the song controls aren't drawn.
     */
    private function playSongPreview(song                       : Dynamic) : Void
    {
        Alert.add(_lang.string("song_selection_playing_song_preview"));
        
        if (as3hx.Compat.truthy(_gvars.menuMusic))
        {
            _gvars.menuMusic.stop();
        }
        
        if (as3hx.Compat.truthy(previewMusic != null))
        {
            previewMusic.stop();
        }
        
        previewMusic = new SongPlayerBytes(song.bytesSWF, false, true);
        previewMusic.start();
    }
    
    /**
     * Writes the loaded SWF byte data to the fixed menu music file path location.
     * @param song Song Class to save SWF bytes from.
     */
    private function writeMenuMusicBytes(song                       : Dynamic) : Void
    {
        AirContext.writeFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH), song.bytesSWF);
    }
}




class PageBox extends Sprite
{
    public var page                       : Dynamic;
    public var page_scroll                       : Dynamic;
    
    private var page_text                       : Dynamic;
    private var draw_width                       : Dynamic= 27;
    private var draw_height                       : Dynamic= 16;
    
    @:allow(menu)
    private function new(parent                       : Dynamic, x                       : Dynamic, y                       : Dynamic)
    {
        super();
        this.x = x;
        this.y = y;
        
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        parent.addChild(this);
    }
    
    public function setSize(w                       : Dynamic, h                       : Dynamic) : Void
    {
        draw_width = w;
        draw_height = h;
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.5, false);
        this.graphics.beginFill(GameBackgroundColor.BG_STATIC, 1);
        this.graphics.drawRect(0, 0, draw_width, draw_height);
        this.graphics.endFill();
        
        if (as3hx.Compat.truthy(page_text != null))
        {
            page_text.width = draw_width;
            page_text.height = draw_height - 1;
        }
    }
    
    public function setText(str                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(page_text == null))
        {
            page_text = new Text(this, 0, 0, str, draw_height - 4);
            page_text.width = draw_width;
            page_text.height = draw_height;
            page_text.align = Text.CENTER;
        }
        else
        {
            page_text.text = str;
        }
    }
}

class HoverPABox extends Sprite
{
    public var delay(never, set)                       : Dynamic;

    private var _width                       : Dynamic;
    private var _height                       : Dynamic;
    
    private var _hoverText                       : Dynamic;
    private var _hoverSprite                       : Dynamic;
    private var _hoverSpriteText                       : Dynamic;
    private var _hoverTimer                       : Dynamic= new Timer(500, 1);
    
    @:allow(menu)
    private function new(xpos                       : Dynamic, ypos                       : Dynamic, text                       : Dynamic, width                       : Dynamic= 165, height                       : Dynamic= 38)
    {
        super();
        // No Hover Text, do nothing.
        if (as3hx.Compat.truthy(text == null))
        {
            return;
        }
        
        this._hoverText = text;
        this._width = width;
        this._height = height;
        this.x = xpos;
        this.y = ypos;
        
        this.mouseChildren = false;
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        this.addEventListener(MouseEvent.ROLL_OVER, e_hoverRollOver);
    }
    
    private function set_delay(val                       : Dynamic) : Int
    {
        _hoverTimer.delay = val;
        return val;
    }
    
    
    private function e_hoverRollOver(e                       : Dynamic) : Void
    {
        this.addEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        
        if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))
        {
            drawHoverSprite();
            _hoverTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
            _hoverTimer.start();
        }
    }
    
    private function e_hoverRollOut(e                       : Dynamic) : Void
    {
        _hoverTimer.stop();
        this.removeEventListener(MouseEvent.ROLL_OUT, e_hoverRollOut);
        this.removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);
        
        if (as3hx.Compat.truthy(_hoverSprite.parent))
        {
            _hoverSprite.parent.removeChild(_hoverSprite);
        }
    }
    
    private function e_hoverTimerComplete(e                       : Dynamic) : Void
    {
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        
        var placePoint                       : Dynamic= new Point(0, -_hoverSprite.height);
        
        // Center on Label
        placePoint.x = -(_hoverSprite.width / 2) + (width / 2);
        
        var stagePoint                       : Dynamic= this.localToGlobal(placePoint);
        
        // Keep on Stage
        if (as3hx.Compat.truthy(stagePoint.x < 5))
        {
            stagePoint.x = 5;
        }
        
        if (as3hx.Compat.truthy(stagePoint.x + _hoverSprite.width > Main.GAME_WIDTH - 5))
        {
            stagePoint.x = Main.GAME_WIDTH - 5 - _hoverSprite.width;
        }
        
        if (as3hx.Compat.truthy(stagePoint.y < 5))
        {
            stagePoint.y = 5;
        }
        
        if (as3hx.Compat.truthy(stagePoint.y + _hoverSprite.height > Main.GAME_HEIGHT - 5))
        {
            stagePoint.y = Main.GAME_HEIGHT - 5 - _hoverSprite.height;
        }
        
        // Position
        _hoverSprite.x = stagePoint.x;
        _hoverSprite.y = stagePoint.y;
        
        if (as3hx.Compat.truthy(this.parent != null && this.parent.stage != null))
        {
            this.parent.stage.addChild(_hoverSprite);
            this.addEventListener(Event.ENTER_FRAME, e_onEnterFrame, false, 0, true);
        }
    }
    
    private function e_onEnterFrame(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(this.parent == null || this.parent.stage == null))
        {
            this.removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);
            
            if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
            {
                _hoverSprite.parent.removeChild(_hoverSprite);
            }
        }
    }
    
    private function drawHoverSprite() : Void
    {
        if (as3hx.Compat.truthy(_hoverSprite == null))
        {
            _hoverSprite = new Sprite();
            _hoverSprite.mouseEnabled = false;
            _hoverSprite.mouseChildren = false;
            
            _hoverSpriteText = new TextField();
            _hoverSpriteText.x = 4;
            _hoverSpriteText.y = 2;
            _hoverSpriteText.embedFonts = true;
            _hoverSpriteText.selectable = false;
            _hoverSpriteText.mouseEnabled = false;
            _hoverSpriteText.defaultTextFormat = Constant.TEXT_FORMAT;
            _hoverSpriteText.autoSize = TextFieldAutoSize.LEFT;
            _hoverSpriteText.antiAliasType = AntiAliasType.ADVANCED;
            //_hoverSpriteText.border = true;
            _hoverSpriteText.cacheAsBitmap = true;
            _hoverSprite.addChild(_hoverSpriteText);
            
            _hoverSpriteText.htmlText = _hoverText;
            
            var minWidth                       : Dynamic= Math.max(_width, _hoverSpriteText.width + 8);
            _hoverSpriteText.x = (minWidth - _hoverSpriteText.width) / 2;
            _hoverSprite.graphics.lineStyle(1, 0xFFFFFF, 0.5, false);
            _hoverSprite.graphics.beginFill(GameBackgroundColor.BG_DARK, 0.9);
            _hoverSprite.graphics.drawRect(0, 0, minWidth, _hoverSpriteText.height + 4);
            _hoverSprite.graphics.endFill();
        }
    }
}
