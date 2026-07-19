package menu;

import assets.menu.ScrollBackground;
import assets.menu.ScrollDragger;
import assets.menu.SongSelectionBackground;
import classes.DynamicLoader;
import classes.Language;
import classes.Playlist;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;

class MenuTokens extends MenuPanel
{
    ///- Private Locals
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _playlist                       : Dynamic= Playlist.instanceCanon;
    
    private var background                       : Dynamic;
    private var scrollbar                       : Dynamic;
    private var pane                       : Dynamic;
    
    private var normalTokenButton                       : Dynamic;
    private var skillTokenButton                       : Dynamic;
    private var hideCompleteCheck                       : Dynamic;
    
    private var _lang                       : Dynamic= Language.instance;
    
    public var options                       : Dynamic;
    public var isLoading                       : Dynamic= false;
    
    private static var loadedTokenImages                       : Dynamic= { };
    private static var loadQueue                       : Dynamic= [];
    private static var activeQueue                       : Dynamic= [];
    private static var MAX_ITEMS                       : Dynamic= 20;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    //- Setup Settings
    {
        
        options = {};
        options.active_type = "ski";
        options.filter_complete = false;
        
        //- Add Background
        background = new SongSelectionBackground();
        background.x = 145;
        background.y = 52;
        background.pageBackground.visible = false;
        background.visible = LocalOptions.getVariable("menu_show_song_selection_background", true);
        this.addChild(background);
        
        //- Add ScrollPane
        pane = new ScrollPane(this, 155, 64, 578, 358);
        var border                       : Dynamic= new Sprite();
        border.graphics.lineStyle(1, 0xFFFFFF, 1, true);
        border.graphics.moveTo(0.3, -0.5);
        border.graphics.lineTo(577, -0.5);
        border.graphics.moveTo(0.3, 358.5);
        border.graphics.lineTo(577, 358.5);
        border.alpha = 0.35;
        pane.addChild(border);
        
        //- Add ScrollBar
        scrollbar = new ScrollBar(this, 744, 81, 21, 325, new ScrollDragger(), new ScrollBackground());
        
        // Menu Left
        normalTokenButton = new BoxButton(this, 5, 130, 124, 29, _lang.string("menu_tokens_normal"), 12, onNormalSelect);
        
        skillTokenButton = new BoxButton(this, 5, 164, 124, 29, _lang.string("menu_tokens_skill"), 12, onSkillSelect);
        skillTokenButton.active = true;
        
        var hideLabel                       : Dynamic= new Text(this, 10, 230, _lang.string("menu_tokens_hide_complete"));
        hideCompleteCheck = new BoxCheck(this, 106, 233, hideCompleteClick);
        
        //- Add Content
        buildTokens();
        
        return true;
    }
    
    private function hideCompleteClick(e                       : Dynamic) : Void
    {
        options.filter_complete = !options.filter_complete;
        hideCompleteCheck.checked = options.filter_complete;
        buildTokens();
    }
    
    private function onNormalSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(options.active_type != "has"))
        {
            options.active_type = "has";
            normalTokenButton.active = true;
            skillTokenButton.active = false;
            buildTokens();
        }
    }
    
    private function onSkillSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(options.active_type != "ski"))
        {
            options.active_type = "ski";
            normalTokenButton.active = false;
            skillTokenButton.active = true;
            buildTokens();
        }
    }
    
    override public function dispose() : Void
    {
        if (as3hx.Compat.truthy(pane != null))
        {
            pane.dispose();
            this.removeChild(pane);
            pane = null;
        }
        
        normalTokenButton.dispose();
        skillTokenButton.dispose();
        
        super.dispose();
    }
    
    override public function stageAdd() : Void
    //- Add Listeners
    {
        
        if (as3hx.Compat.truthy(stage))
        {
            scrollbar.addEventListener(Event.CHANGE, scrollBarMoved, false, 0, false);
            pane.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false, 0, false);
        }
    }
    
    override public function stageRemove() : Void
    //- Remove Listeners
    {
        
        if (as3hx.Compat.truthy(stage))
        {
            scrollbar.removeEventListener(Event.CHANGE, scrollBarMoved, false);
            pane.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false);
        }
    }
    
    public function buildTokens() : Void
    //- Clear out old MC in content pane
    {
        
        scrollbar.reset();
        pane.clear();
        loadQueue = [];
        
        var yOffset                       : Dynamic= 0;
        var sX                       : Dynamic= 0;
        var token                       : Dynamic= null;
        for (item/* AS3HX WARNING could not determine type for var: item exp: EArray(EField(EIdent(_gvars),TOKENS_TYPE),EField(EIdent(options),active_type)) type: null */ in as3hx.Compat.iter(_gvars.TOKENS_TYPE[options.active_type]))
        {
            if (as3hx.Compat.truthy(options.filter_complete && Reflect.field(item, "unlock") != null))
            {
                continue;
            }
            
            token = new TokenItem(item);
            token.y = yOffset;
            token.addEventListener(MouseEvent.CLICK, e_tokenClick);
            pane.content.addChild(token);
            yOffset += as3hx.Compat.parseInt(token.height + 5);
            sX += 1;
            
            addTokenImageLoader(item, token);
        }
        
        downloadTokenImage();
        
        options.totalItems = sX;
        pane.scrollTo(scrollbar.scroll);
        scrollbar.draggerVisibility = (yOffset > pane.height);
    }
    
    private function e_tokenClick(e                       : Dynamic) : Void
    {
        var token_songs                       : Dynamic= [];
        for (level/* AS3HX WARNING could not determine type for var: level exp: EField(EParent(EBinop(as,EField(EIdent(e),target),EIdent(TokenItem),false)),token_levels) type: null */ in as3hx.Compat.iter((try cast(e.target, TokenItem) catch(e:Dynamic) null).token_levels))
        {
            if (as3hx.Compat.truthy(level > 0))
            {
                var songData                       : Dynamic= _playlist.getSongInfo(level);
                if (as3hx.Compat.truthy(!songData.exists("error")))
                {
                    token_songs.push(songData);
                }
            }
        }
        
        if (as3hx.Compat.truthy(token_songs.length <= 0))
        {
            return;
        }
        
        _gvars.songQueue = token_songs;
        MenuSongSelection.options.queuePlaylist = _gvars.songQueue;
        
        switchTo(MainMenu.MENU_SONGSELECTION);
        MenuSongSelection.options.infoTab = MenuSongSelection.TAB_QUEUE;
        var panel                       : Dynamic= (try cast((try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null).panel, MenuSongSelection) catch(e:Dynamic) null);
        panel.swapToQueue();
    }
    
    private function addTokenImageLoader(token_info                       : Dynamic, token_ui                       : Dynamic) : Void
    {
        var imageHash                       : Dynamic= Reflect.field(token_info, "picture");
        
        if (as3hx.Compat.truthy(Reflect.field(token_info, "picture") == null || Reflect.field(token_info, "picture") == ""))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(Reflect.field(loadedTokenImages, imageHash) != null))
        {
            token_ui.addTokenImage(try cast(Reflect.field(loadedTokenImages, imageHash), Bitmap) catch(e:Dynamic) null, false);
            return;
        }
        
        // Load Image
        loadQueue.push({
                    hash : imageHash,
                    url : Reflect.field(token_info, "picture"),
                    ui : token_ui
                });
    }
    
    private function downloadTokenImage() : Void
    {
        if (as3hx.Compat.truthy(loadQueue.length <= 0 || activeQueue.length >= MAX_ITEMS))
        {
            return;
        }
        
        while (as3hx.Compat.truthy(activeQueue.length < MAX_ITEMS && loadQueue.length > 0))
        {
            var queueItem                       : Dynamic= loadQueue.shift();
            activeQueue.push(queueItem);
            
            // Load Image
            var loader                       : Dynamic= new DynamicLoader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, downloadTokenImageComplete);
            loader.queueItem = queueItem;
            loader.load(new URLRequest(Reflect.field(queueItem, "url")));
        }
    }
    
    private function downloadTokenImageComplete(e                       : Dynamic) : Void
    {
        var queueItem                       : Dynamic= e.target.loader.queueItem;
        
        Reflect.setField(loadedTokenImages, Std.string(Reflect.field(queueItem, "hash")), try cast(e.target.content, Bitmap) catch(e:Dynamic) null);
        
        if (as3hx.Compat.truthy((try cast(Reflect.field(queueItem, "ui"), TokenItem) catch(e:Dynamic) null).parent != null))
        {
            (try cast(Reflect.field(queueItem, "ui"), TokenItem) catch(e:Dynamic) null).addTokenImage(try cast(e.target.content, Bitmap) catch(e:Dynamic) null);
        }
        
        activeQueue.splice(Lambda.indexOf(activeQueue, queueItem), 1)[0];
        
        downloadTokenImage();
    }
    
    private function mouseWheelMoved(e                       : Dynamic) : Void
    {
        var dist                       : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function scrollBarMoved(e                       : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
}

