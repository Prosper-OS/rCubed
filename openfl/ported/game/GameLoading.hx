package game;

import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.chart.Song;
import classes.ui.BoxButton;
import classes.ui.ProgressBar;
import com.flashfla.utils.NumberUtil;
import com.greensock.TweenLite;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFormat;
import menu.MenuPanel;

class GameLoading extends MenuPanel
{
    private var _textFormat                          : Dynamic= new TextFormat(Fonts.BASE_FONT_CJK, 16, 0xFFFFFF, true);
    
    private var _gvars                          : Dynamic= GlobalVariables.instance;
    private var _lang                          : Dynamic= Language.instance;
    private var _playlist                          : Dynamic= Playlist.instance;
    
    private var preloader                          : Dynamic;
    private var namedisplay                          : Dynamic;
    private var blackOverlay                          : Dynamic;
    private var loadTimer                          : Dynamic= 0;
    private var cancelLoadButton                          : Dynamic;
    
    private var song                          : Dynamic;
    private var songName                          : Dynamic= "";
    
    public function new(myParent                          : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        _gvars.songRestarts = 0;
        //- Set Active Song
        if (as3hx.Compat.truthy(_gvars.options.song))
        {
            song = _gvars.options.song;
        }
        else if (as3hx.Compat.truthy(_gvars.songQueue.length > 0))
        {
            var songInfo                          : Dynamic= _gvars.songQueue[0];
            _gvars.songQueue.shift();
            
            song = _gvars.getSongFile(songInfo);
            _gvars.options.song = song;
        }
        // No songs in queue? Something went wrong...
        else
        {
            
            {
                switchTo(Main.GAME_MENU_PANEL);
                return false;
            }
        }
        
        if (as3hx.Compat.truthy(song != null && song.isLoaded))
        {
            switchTo(GameMenu.GAME_PLAY);
            return false;
        }
        return true;
    }
    
    override public function stageAdd() : Void
    {
        songName = _lang.wrapFont((song.songInfo.name) ? song.songInfo.name : "Invalid Song / Replay");
        
        //- Preloader Display
        preloader = new ProgressBar(this, 10, Main.GAME_HEIGHT - 30, Main.GAME_WIDTH - 20, 20);
        
        //- Song Name Display
        namedisplay = new TextField();
        namedisplay.x = 10;
        namedisplay.y = Main.GAME_HEIGHT - 58;
        namedisplay.selectable = false;
        namedisplay.embedFonts = true;
        namedisplay.antiAliasType = AntiAliasType.ADVANCED;
        namedisplay.autoSize = "left";
        namedisplay.defaultTextFormat = _textFormat;
        namedisplay.htmlText = songName;
        this.addChild(namedisplay);
        
        //- Frame Listener
        this.addEventListener(Event.ENTER_FRAME, updatePreloader);
    }
    
    override public function stageRemove() : Void
    {
        this.removeEventListener(Event.ENTER_FRAME, updatePreloader);
        
        if (as3hx.Compat.truthy(cancelLoadButton != null))
        {
            cancelLoadButton.dispose();
        }
        
        if (as3hx.Compat.truthy(preloader != null))
        {
            preloader.removeEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
        }
    }
    
    ///- PreloaderHandlers
    private function updatePreloader(e                          : Dynamic) : Void
    {
        loadTimer++;
        
        namedisplay.htmlText = "";
        if (as3hx.Compat.truthy(song.songInfo.name))
        {
            namedisplay.htmlText += song.songInfo.name + " - " + song.progress + "%  --- ";
            
            if (as3hx.Compat.truthy(song.bytesTotal > 0))
            {
                namedisplay.htmlText += "(" + NumberUtil.bytesToString(song.bytesLoaded) + " / " + NumberUtil.bytesToString(song.bytesTotal) + ")";
            }
            else
            {
                namedisplay.htmlText += "Connecting...";
            }
            
            if (as3hx.Compat.truthy(song.loadFail))
            {
                namedisplay.htmlText += " --- <font color=\"#FFC4C4\">[Loading Failed]</font>";
            }
        }
        else
        {
            namedisplay.htmlText += songName;
        }
        
        preloader.update(song.progress / 100);
        
        if (as3hx.Compat.truthy((loadTimer >= 60 || song.loadFail) && cancelLoadButton == null))
        {
            cancelLoadButton = new BoxButton(this, Main.GAME_WIDTH - 85, preloader.y - 35, 75, 25, "Cancel", 12, e_cancelClick);
        }
        
        if (as3hx.Compat.truthy(song.loadFail)) {
_gvars.removeSongFile(song);
            if (as3hx.Compat.truthy(cancelLoadButton != null))
            {
                cancelLoadButton.text = "Return";
            }
            removeEventListener(Event.ENTER_FRAME, updatePreloader);
        }
        
        if (as3hx.Compat.truthy(preloader.isComplete && song.isLoaded))
        {
            removePopup();
            this.removeEventListener(Event.ENTER_FRAME, updatePreloader);
            preloader.addEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
            preloader.remove();
            
            blackOverlay = new Sprite();
            blackOverlay.alpha = 0;
            blackOverlay.graphics.beginFill(0x000000);
            blackOverlay.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            this.addChild(blackOverlay);
            TweenLite.to(blackOverlay, 0.5, {
                        alpha : 1
                    });
        }
    }
    
    private function e_cancelClick(e                          : Dynamic) : Void
    {
        _gvars.removeSongFile(song);
        
        removeEventListener(Event.ENTER_FRAME, updatePreloader);
        switchTo(Main.GAME_MENU_PANEL);
    }
    
    private function preloaderRemoved(e                          : Dynamic= null) : Void
    {
        preloader.removeEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
        switchTo(GameMenu.GAME_PLAY);
    }
}

