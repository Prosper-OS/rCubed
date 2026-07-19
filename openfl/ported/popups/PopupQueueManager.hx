package popups;

import assets.GameBackgroundColor;
import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.SongQueueItem;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.PromptInput;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.BlurFilter;
import openfl.geom.Point;
import menu.MenuPanel;
import classes.Alert;








import com.flashfla.utils.SystemUtil;
import com.flashfla.utils.TimeUtil;
import openfl.display.Sprite;

import menu.MainMenu;
import menu.MenuSongSelection;
import popups.PopupQueueManager;

class PopupQueueManager extends MenuPanel
{
    private var TAB_MAIN(default, never)                       : Dynamic= 0;
    private var TAB_PREGEN(default, never)                       : Dynamic= 1;
    
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _playlist                       : Dynamic= Playlist.instanceCanon;
    
    private var CURRENT_TAB                     : Dynamic;
    
    private static var STAT_LIST                       : Dynamic;
    
    //- Background
    private var box                       : Dynamic;
    private var bmd                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var scrollpane                       : Dynamic;
    private var scrollbar                       : Dynamic;
    
    private var menuMain                       : Dynamic;
    private var menuPregen                       : Dynamic;
    private var importBtn                       : Dynamic;
    private var closeBtn                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
        CURRENT_TAB = TAB_MAIN;
    }
    
    override public function stageAdd() : Void
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
        
        var titleDisplay                       : Dynamic= new Text(box, 10, 8, _lang.string("popup_queue_manager"), 20);
        titleDisplay.width = box.width - 10;
        
        menuMain = new BoxButton(box, box.width - 125 * 2 - 30, 8, 125, 25, _lang.string("options_queue_saved"), 12, clickHandler);
        menuMain.menu_select = TAB_MAIN;
        
        menuPregen = new BoxButton(box, box.width - menuMain.width - 15, 8, 125, 25, _lang.string("options_queue_premade"), 12, clickHandler);
        menuPregen.menu_select = TAB_PREGEN;
        
        //- content
        scrollpane = new ScrollPane(box, 10, 42, box.width - 45, 341, mouseWheelHandler);
        scrollpane.graphics.lineStyle(1, 0x64A4B8, 0.25, true);
        scrollpane.graphics.drawRect(0, 0, scrollpane.width - 1, scrollpane.height - 1);
        scrollbar = new ScrollBar(box, 10 + scrollpane.width, 42, 20, 341, null, null, scrollBarMoved);
        
        renderQueues();
        
        //- importBtn
        importBtn = new BoxButton(box, box.width - 180, box.height - 42, 79.5, 27, _lang.string("popup_queue_import"), 12, clickHandler);
        
        //- Close
        closeBtn = new BoxButton(box, box.width - 94.5, box.height - 42, 79.5, 27, _lang.string("menu_close"), 12, clickHandler);
    }
    
    private function scrollBarMoved(e                       : Dynamic) : Void
    {
        scrollpane.scrollTo(scrollbar.scroll);
    }
    
    private function mouseWheelHandler(e                       : Dynamic) : Void
    {
        var dist                       : Dynamic= scrollbar.scroll + (scrollpane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        scrollpane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    override public function stageRemove() : Void
    {
        menuMain.dispose();
        menuPregen.dispose();
        importBtn.dispose();
        closeBtn.dispose();
        
        box.dispose();
        this.removeChild(box);
        this.removeChild(bmp);
        bmd = null;
        bmp = null;
        box = null;
    }
    
    public function renderQueues() : Void
    {
        var yOffset                       : Dynamic= 0;
        var sI                       : Dynamic= null;
        var sX                       : Dynamic= 0;
        
        scrollbar.reset();
        scrollpane.clear();
        
        if (as3hx.Compat.truthy(CURRENT_TAB == TAB_MAIN)) {
if (as3hx.Compat.truthy(_gvars.playerUser.songQueues.length > 0))
            {
                for (sqi/* AS3HX WARNING could not determine type for var: sqi exp: EField(EField(EIdent(_gvars),playerUser),songQueues) type: null */ in as3hx.Compat.iter(_gvars.playerUser.songQueues))
                {
                    if (as3hx.Compat.truthy(sqi.items.length > 0))
                    {
                        sI = new QueueBox(this, sqi);
                        sI.y = yOffset;
                        sI.index = sX;
                        scrollpane.content.addChild(sI);
                        yOffset += as3hx.Compat.parseInt(sI.height + 5);
                        sX += 1;
                    }
                    else
                    {
                        _gvars.playerUser.songQueues.splice(_gvars.playerUser.songQueues.indexOf(sqi), 1);
                    }
                }
            }
            else
            {
                var noSavedDisplay                       : Dynamic= new Text(scrollpane.content, 10, 8, _lang.string("popup_queue_no_queues"));
                noSavedDisplay.width = box.width - 10;
            }
        }
        else if (as3hx.Compat.truthy(CURRENT_TAB == TAB_PREGEN))
        {
            genResultBasedQueues();
            
            // Display Premade Genre Queues
            for (curGenre in as3hx.Compat.iter(Reflect.fields(_playlist.generatedQueues)))
            {
                sI = new QueueBox(this, new SongQueueItem(_lang.string("genre_" + (as3hx.Compat.parseInt(curGenre) - 1)), _playlist.generatedQueues[curGenre]), false, true);
                sI.y = yOffset;
                sI.index = sX;
                scrollpane.content.addChild(sI);
                yOffset += as3hx.Compat.parseInt(sI.height + 5);
                sX += 1;
            }
            
            // Display Premade Stats queues
            for (stat in as3hx.Compat.iter(Reflect.fields(STAT_LIST)))
            {
                sI = new QueueBox(this, Reflect.field(STAT_LIST, stat), false, true);
                sI.y = yOffset;
                sI.index = sX;
                scrollpane.content.addChild(sI);
                yOffset += as3hx.Compat.parseInt(sI.height + 5);
                sX += 1;
            }
        }
        scrollpane.update();
        scrollpane.scrollTo(scrollbar.scroll);
        scrollbar.draggerVisibility = (yOffset > scrollpane.height);
    }
    
    private function e_importSongQueue(songQueueJSON                       : Dynamic) : Void
    {
        var temp                       : Dynamic= SongQueueItem.fromString(songQueueJSON);
        if (as3hx.Compat.truthy(temp.items.length > 0))
        {
            _gvars.playerUser.songQueues.push(temp);
            renderQueues();
        }
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == importBtn))
        {
            new PromptInput(box.parent, _lang.string("popup_queue_import_song_queue"), _lang.string("popup_queue_submit"), e_importSongQueue);
        }
        else if (as3hx.Compat.truthy(e.target == menuPregen))
        {
            CURRENT_TAB = TAB_PREGEN;
            renderQueues();
            return;
        }
        else if (as3hx.Compat.truthy(e.target == menuMain))
        {
            CURRENT_TAB = TAB_MAIN;
            renderQueues();
            return;
        }
        //- Close
        if (as3hx.Compat.truthy(e.target == closeBtn))
        {
            removePopup();
            return;
        }
    }
    
    private function genResultBasedQueues() : Void
    {
        var songlist                       : Dynamic= [];
        STAT_LIST = [];
        for (index in as3hx.Compat.iter(Reflect.fields(_playlist.indexList)))
        {
            var _songInfo                       : Dynamic= _playlist.indexList[index];
            var _rank                       : Dynamic= _gvars.activeUser.getLevelRank(_songInfo);
            var _access                       : Dynamic= _gvars.checkSongAccess(_songInfo);
            
            if (as3hx.Compat.truthy(_access == GlobalVariables.SONG_ACCESS_PLAYABLE))
            {
                var stats                       : Dynamic= GlobalVariables.getSongIconIndex(_songInfo, _rank);
                if (as3hx.Compat.truthy(songlist[stats] == null))
                {
                    songlist[stats] = [];
                }
                songlist[stats].push(_songInfo.level);
            }
        }
        for (rank in as3hx.Compat.iter(Reflect.fields(songlist)))
        {
            var name                       : Dynamic= GlobalVariables.SONG_ICON_TEXT[rank];
            STAT_LIST.push(new SongQueueItem(((name == "") ? "PLAYED" : name), as3hx.Compat.field(songlist, rank)));
        }
    }
}



class QueueBox extends Sprite
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _playlist                       : Dynamic= Playlist.instanceCanon;
    
    //- Song Details
    public var box                       : Dynamic;
    public var index                       : Dynamic;
    private var copyBtn                       : Dynamic;
    private var deleteBtn                       : Dynamic;
    private var playBtn                       : Dynamic;
    private var renameBtn                       : Dynamic;
    private var queueItem                       : Dynamic;
    private var popup                       : Dynamic;
    
    @:allow(popups)
    private function new(p                       : Dynamic, qi                       : Dynamic, longview                       : Dynamic= true, premade                       : Dynamic= false)
    {
        super();
        this.popup = p;
        this.queueItem = qi;
        
        //- Make Display
        var yOffset                       : Dynamic= 25;
        
        // Draw Box
        box = new Box(this, 0, 0, false);
        box.setSize(690, !(longview) ? 35 : queueItem.items.length * 20 + 30);
        
        // Add Song Names
        var totalTime                       : Dynamic= 0;
        for (songid/* AS3HX WARNING could not determine type for var: songid exp: EField(EIdent(queueItem),items) type: null */ in as3hx.Compat.iter(queueItem.items))
        {
            var songInfo                       : Dynamic= _playlist.playList[songid];
            if (as3hx.Compat.truthy(songInfo != null))
            {
                if (as3hx.Compat.truthy(longview))
                {
                    var access                       : Dynamic= _gvars.checkSongAccess(songInfo);
                    var songName                       : Dynamic= new Text(box, 5, yOffset, " - " + songInfo.name + " [" + songInfo.time + "]", 12, (access == GlobalVariables.SONG_ACCESS_PLAYABLE) ? "#FFFFFF" : "#FF9797");
                    yOffset += 20;
                }
                totalTime += songInfo.time_secs;
            }
        }
        
        // Add Queue Names + Info
        var queueName                       : Dynamic= new Text(box, 5, 5, queueItem.name + " [" + TimeUtil.convertToHHMMSS(totalTime) + "]", 14);
        
        if (as3hx.Compat.truthy(!premade)) {
copyBtn = new BoxButton(box, box.width - 75, 5, 70, 25, _lang.string("popup_queue_copy"));
            
            //- Delete Button
            deleteBtn = new BoxButton(box, copyBtn.x - 75, 5, 70, 25, _lang.string("popup_queue_delete"));
            
            //- Rename Button
            renameBtn = new BoxButton(box, deleteBtn.x - 75, 5, 70, 25, _lang.string("popup_queue_rename"));
        }
        
        //- PLAY Button
        playBtn = new BoxButton(box, ((renameBtn != null) ? renameBtn.x - 75 : box.width - 75), 5, 70, 25, _lang.string("popup_queue_play"));
        
        this.addEventListener(MouseEvent.CLICK, clickEvent);
    }
    
    private function clickEvent(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == copyBtn))
        {
            copyQueue();
        }
        else if (as3hx.Compat.truthy(e.target == deleteBtn))
        {
            deleteQueue();
        }
        else if (as3hx.Compat.truthy(e.target == playBtn))
        {
            playQueue();
        }
        else if (as3hx.Compat.truthy(e.target == renameBtn))
        {
            renameQueue();
        }
    }
    
    private function copyQueue() : Void
    {
        var queueString                       : Dynamic= Std.string(this.queueItem);
        var success                       : Dynamic= SystemUtil.setClipboard(queueString);
        if (as3hx.Compat.truthy(success))
        {
            Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
        }
        else
        {
            Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }
    }
    
    private function deleteQueue() : Void
    {
        _gvars.playerUser.songQueues.splice(_gvars.playerUser.songQueues.indexOf(this.queueItem), 1);
        popup.renderQueues();
        _gvars.playerUser.save();
    }
    
    private function playQueue() : Void
    {
        var newSongQueue                       : Dynamic= [];
        for (songid/* AS3HX WARNING could not determine type for var: songid exp: EField(EIdent(queueItem),items) type: null */ in as3hx.Compat.iter(queueItem.items))
        {
            var songInfo                       : Dynamic= _playlist.playList[songid];
            if (as3hx.Compat.truthy(songInfo != null))
            {
                var access                       : Dynamic= _gvars.checkSongAccess(songInfo);
                if (as3hx.Compat.truthy(access == GlobalVariables.SONG_ACCESS_PLAYABLE))
                {
                    newSongQueue.push(songInfo);
                }
            }
        }
        
        popup.removePopup();
        
        if (as3hx.Compat.truthy(newSongQueue.length <= 0))
        {
            return;
        }
        
        _gvars.songQueue = newSongQueue;
        MenuSongSelection.options.queuePlaylist = newSongQueue;
        if (as3hx.Compat.truthy(_gvars.gameMain.activePanel != null && Std.is(_gvars.gameMain.activePanel, MainMenu)))
        {
            var mmmenu                       : Dynamic= (try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null);
            if (as3hx.Compat.truthy(mmmenu.panel != null && (Std.is(mmmenu.panel, MenuSongSelection))))
            {
                var msmenu                       : Dynamic= (try cast(mmmenu.panel, MenuSongSelection) catch(e:Dynamic) null);
                msmenu.buildPlayList();
                msmenu.buildInfoBox();
            }
        }
    }
    
    private function e_renameQueue(queueName                       : Dynamic) : Void
    {
        queueItem.name = queueName;
        popup.renderQueues();
        _gvars.playerUser.save();
    }
    
    private function renameQueue() : Void
    {
        new PromptInput(this.popup, _lang.string("popup_queue_rename_no_caps"), _lang.string("popup_queue_rename"), e_renameQueue);
    }
    
    public function dispose() : Void
    //- Remove is already existed.
    {
        
        if (as3hx.Compat.truthy(box != null))
        {
            copyBtn.dispose();
            deleteBtn.dispose();
            playBtn.dispose();
            renameBtn.dispose();
            
            box.dispose();
            this.removeChild(box);
            box = null;
        }
    }
}
