package menu;

import classes.Language;
import classes.SongInfo;
import classes.ui.MouseTooltip;
import classes.ui.Text;
import classes.user.UserSongData;
import classes.user.UserSongNotes;
import com.flashfla.utils.NumberUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.ui.ContextMenu;
import openfl.utils.Timer;

class SongItem extends Sprite
{
    public var songInfo(get, never)                       : Dynamic;
    public var level(get, never)                       : Dynamic;
    public var highlight(get, set)                       : Dynamic;
    public var active(get, set)                       : Dynamic;
    public var noteEnabled(get, set)                       : Dynamic;

    private static var _gvars                       : Dynamic= GlobalVariables.instance;
    private static var _lang                       : Dynamic= Language.instance;
    
    private static var HOVER_POINT_GLOBAL                       : Dynamic= new Point();
    private static var DISABLED_COLORS                       : Dynamic= [0xFF0000, 0xFF0000];
    private static var GRADIENT_COLORS                       : Dynamic= [0xFFFFFF, 0xFFFFFF];
    private static var GRADIENT_ALPHA_HIGHLIGHT                       : Dynamic= [0.35, 0.1225];
    private static var GRADIENT_ALPHA                       : Dynamic= [0.2, 0.04];
    private static var GRADIENT_RATIO                       : Dynamic= [0, 255];
    
    /** Marks the Button as in-use to avoid removal in song selector. */
    //public var garbageSweep                      : Dynamic= false;
    
    /** Calculated y position in the scroll pane. */
    //public var fixed_y                      : Dynamic= 0;
    
    public var index                       : Dynamic= 0;
    
    // Text
    private var _lblSongDifficulty                       : Dynamic;
    private var _lblSongName                       : Dynamic;
    private var _lblSongFlag                       : Dynamic;
    
    private var _lblMessageText                       : Dynamic;
    
    // Display
    private var _width                       : Dynamic= 400;
    private var _height                       : Dynamic= 27;
    private var _highlight                       : Dynamic= false;
    private var _active                       : Dynamic= false;
    
    // Song Data
    private var _songInfo                       : Dynamic;
    private var _songUserInfo                       : Dynamic;
    private var _level                       : Dynamic= 0;
    public var isLocked                       : Dynamic= false;
    public var isFavorite                       : Dynamic= false;
    
    // Hover Data
    private var _hoverEnabled                       : Dynamic= true;
    private var _hoverTimer                       : Dynamic;
    private var _hoverSprite                       : Dynamic;
    private var _hoverTick                       : Dynamic= 0;
    private var _hoverPoint                       : Dynamic;
    
    public function new()
    {
        super();
        //- Set Button Mode
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        //- Events
        this.addEventListener(MouseEvent.ROLL_OVER, e_onHover, false, 0, true);
    }
    
    public function draw() : Void
    {
        var ALPHAS                       : Dynamic= ((highlight) ? GRADIENT_ALPHA_HIGHLIGHT : GRADIENT_ALPHA);
        var COLORS                       : Dynamic= ((songInfo.is_disabled) ? DISABLED_COLORS : GRADIENT_COLORS);
        
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, (highlight) ? 0.8 : 0.55);
        this.graphics.beginGradientFill(GradientType.LINEAR, COLORS, ALPHAS, GRADIENT_RATIO, Constant.GRADIENT_MATRIX);
        this.graphics.drawRect(0, 0, width - 1, height - 1);
        this.graphics.endFill();
        
        // Difficulty Divider
        if (as3hx.Compat.truthy(!isLocked))
        {
            this.graphics.moveTo(32, 0);
            this.graphics.lineTo(32, height - 1);
            
            if (as3hx.Compat.truthy(isFavorite))
            {
                this.graphics.lineStyle(0, 0, 0);
                this.graphics.beginFill(0xf7b9e4, 1);
                this.graphics.moveTo(1, 1);
                this.graphics.lineTo(8, 1);
                this.graphics.lineTo(1, 8);
                this.graphics.lineTo(1, 1);
                this.graphics.endFill();
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Events
    private function e_onHover(e                       : Dynamic) : Void
    {
        _highlight = true;
        draw();
        showHoverMessage(true);
        this.addEventListener(MouseEvent.ROLL_OUT, e_onHoverOut);
    }
    
    private function e_onHoverOut(e                       : Dynamic) : Void
    {
        _highlight = false;
        draw();
        showHoverMessage(false);
        this.removeEventListener(MouseEvent.ROLL_OUT, e_onHoverOut);
    }
    
    /**
     * Displays or hides the note hover for the song item.
     * @param enabled
     */
    public function showHoverMessage(enabled                       : Dynamic) : Void
    // `enabled` accounts for both `active` and `highlight`.
    {
        
        if (as3hx.Compat.truthy(enabled)) {
if (as3hx.Compat.truthy(highlight && (_hoverEnabled && (_songUserInfo != null && _songUserInfo.notes.length > 0))))
            {
                if (as3hx.Compat.truthy(_hoverTimer == null))
                {
                    _hoverTimer = new Timer(500, 1);
                }
                
                if (as3hx.Compat.truthy(!_hoverTimer.running && (_hoverSprite == null || _hoverSprite.parent == null)))
                {
                    _hoverTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
                    _hoverTimer.start();
                }
            }
        }
        else if (as3hx.Compat.truthy(!highlight))
        {
            if (as3hx.Compat.truthy(_hoverTimer != null && _hoverTimer.running))
            {
                _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
                _hoverTimer.stop();
            }
            if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent))
            {
                this.removeEventListener(Event.ENTER_FRAME, e_positionHoverSprite);
                _hoverSprite.parent.removeChild(_hoverSprite);
            }
        }
    }
    
    /**
     * TimerEvent.TIMER_COMPLETE For the hover / active timer.
     * Displays the song note sprite when the timer completes.
     * @param e
     */
    private function e_hoverTimerComplete(e                       : Dynamic= null) : Void
    {
        _hoverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_hoverTimerComplete);
        
        if (as3hx.Compat.truthy(this.parent != null))
        {
            if (as3hx.Compat.truthy(_hoverSprite == null))
            {
                _hoverSprite = new MouseTooltip("", _width - 1);
            }
            
            update();
            positionHoverSprite();
            this.parent.addChild(_hoverSprite);
            _hoverSprite.visible = true;  // Adding a child to the ScrollPane makes it invisible until a scroll update is sent.  
            this.addEventListener(Event.ENTER_FRAME, e_positionHoverSprite);
        }
    }
    
    /**
     * Event.ENTER_FRAME For note position on stage.
     * This updates the note position every 5 frames so the message
     * is supposedly visible when scrolled to high or low.
     * @param e
     */
    private function e_positionHoverSprite(e                       : Dynamic) : Void
    // Only check 12 times per second instead of 60.
    {
        
        if (as3hx.Compat.truthy(++_hoverTick > 5))
        {
            if (as3hx.Compat.truthy(_hoverSprite != null && _hoverSprite.parent != null))
            {
                positionHoverSprite();
                _hoverTick = 0;
            }
            else
            {
                this.removeEventListener(Event.ENTER_FRAME, e_positionHoverSprite);
            }
        }
    }
    
    /**
     * Updates the Notes hover sprite to be above or below the item
     * depending on the position on screen.
     */
    private function positionHoverSprite() : Void
    {
        if (as3hx.Compat.truthy(_hoverSprite != null))
        {
            _hoverPoint = this.localToGlobal(HOVER_POINT_GLOBAL);
            
            if (as3hx.Compat.truthy(_hoverPoint.y > Main.GAME_HEIGHT / 2))
            {
                _hoverSprite.y = this.y - _hoverSprite.height - 2;
            }
            else
            {
                _hoverSprite.y = this.y + _height + 2;
            }
            
            _hoverSprite.x = this.x;
        }
    }
    
    /**
     * Updates the note text, or displays the new note if previously empty.
     * This is called when closing PopupSongNotes.
     */
    public function updateOrShow() : Void
    // Check for Changes
    {
        
        if (as3hx.Compat.truthy(_songUserInfo == null))
        {
            _songUserInfo = UserSongNotes.getSongUserInfo(songInfo);
        }
        
        // Update Favorite
        isFavorite = (_songUserInfo != null && _songUserInfo.song_favorite);
        _lblSongDifficulty.text = getDifficultyText();
        draw();
        
        // Update Note
        if (as3hx.Compat.truthy(_hoverSprite != null))
        {
            update();
        }
        else
        {
            showHoverMessage(true);
        }
    }
    
    /**
     * Update the note sprite message.
     */
    public function update() : Void
    {
        if (as3hx.Compat.truthy(_hoverSprite != null))
        {
            _hoverSprite.message = "<font face=\"" + Fonts.BASE_FONT_CJK + "\" >" + _songUserInfo.notes + "</font>";
        }
    }
    
    ////////////////////////////////////////////////////////////////////////
    //- Getters / Setters
    public function setData(songInfo                       : Dynamic, rank                       : Dynamic) : Void
    {
        _songInfo = songInfo;
        _level = songInfo.level;
        isLocked = !(!as3hx.Compat.truthy(songInfo.access) || songInfo.access == GlobalVariables.SONG_ACCESS_PLAYABLE);
        
        // Song Details
        _songUserInfo = UserSongNotes.getSongUserInfo(songInfo);
        isFavorite = (_songUserInfo != null && _songUserInfo.song_favorite);
        
        // Song Name
        var songname                       : Dynamic= songInfo.name;
        
        if (as3hx.Compat.truthy(songInfo.is_explicit))
        {
            songname = "<font color=\"#e89200\">[E]</font> " + songname;
        }
        if (as3hx.Compat.truthy(songInfo.is_legacy))
        {
            songname = "<font color=\"#004587\">[L]</font> " + songname;
        }
        
        _lblSongName = new Text(this, 0, 0, songname, 14);
        
        // Locked Song Item, basically anything but playable songs.
        if (as3hx.Compat.truthy(isLocked))
        {
            this.mouseChildren = (songInfo.access == GlobalVariables.SONG_ACCESS_TOKEN);
            
            var _message                       : Dynamic= getSongLockText();
            
            _lblMessageText = new TextField();
            _lblMessageText.styleSheet = Constant.STYLESHEET;
            _lblMessageText.x = 5;
            _lblMessageText.y = 20;
            _lblMessageText.selectable = false;
            _lblMessageText.embedFonts = true;
            _lblMessageText.antiAliasType = AntiAliasType.ADVANCED;
            _lblMessageText.multiline = true;
            _lblMessageText.width = 395;
            _lblMessageText.wordWrap = true;
            _lblMessageText.autoSize = TextFieldAutoSize.LEFT;
            _lblMessageText.htmlText = "<font face=\"" + Fonts.BASE_FONT_CJK + "\" color=\"#FFFFFF\" size=\"10\"><b>" + _message + "</b></font>";
            this.addChild(_lblMessageText);
            
            _lblSongName.x = 5;
            _lblSongName.setAreaParams(390, 27);
            
            // Set SongItem Height
            _height = (29 + (_lblMessageText.numLines * 13));
        }
        // Playable Song
        else
        {
            
            {
                // Song Name
                _lblSongName.x = 36;
                
                // Song Difficulty
                _lblSongDifficulty = new Text(this, 1, 0, getDifficultyText(), 14);
                _lblSongDifficulty.setAreaParams(30, 27, Text.CENTER);
                
                // Song Flag
                var FLAG_TEXT                       : Dynamic= GlobalVariables.getSongIcon(_songInfo, rank);
                if (as3hx.Compat.truthy(FLAG_TEXT != "" && GlobalVariables.instance.activeUser.DISPLAY_SONG_FLAG))
                {
                    _lblSongFlag = new Text(this, 296, 0, FLAG_TEXT, 14);
                    _lblSongFlag.setAreaParams(100, 27, Text.RIGHT);
                    
                    // Adjust Song Name to not overlap song flag.
                    _lblSongName.setAreaParams(347 - _lblSongFlag.textfield.textWidth, 27);
                }
                else
                {
                    _lblSongName.setAreaParams(353, 27);
                }
                _height = 27;
            }
        }
        
        showHoverMessage(false);
        draw();
    }
    
    public function setContextMenu(val                       : Dynamic) : Void
    {
        Reflect.setField(this, "contextMenu", val);
    }
    
    public function getDifficultyText() : String
    {
        if (as3hx.Compat.truthy(isFavorite))
        {
            return "<font color=\"#f7b9e4\">" + _songInfo.difficulty + "</font>";
        }
        
        if (as3hx.Compat.truthy(songInfo.is_unranked))
        {
            return "<font color=\"#9C9C9C\">" + _songInfo.difficulty + "</font>";
        }
        
        return Std.string(songInfo.difficulty);
    }
    
    public function getSongLockText() : String
    {
        var _sw5_ = (songInfo.access);        

        switch (_sw5_)
        {
            case GlobalVariables.SONG_ACCESS_CREDITS:
                return sprintf(_lang.string("song_selection_banned_credits"), {
                            more_needed : NumberUtil.numberFormat(songInfo.credits - _gvars.activeUser.credits),
                            user_credits : NumberUtil.numberFormat(_gvars.activeUser.credits),
                            song_price : NumberUtil.numberFormat(songInfo.credits)
                        });
            
            case GlobalVariables.SONG_ACCESS_PURCHASED:
                return sprintf(_lang.string("song_selection_banned_purchased"), {
                            song_price : NumberUtil.numberFormat(songInfo.price)
                        });
            
            case GlobalVariables.SONG_ACCESS_VETERAN:
                return _lang.string("song_selection_banned_veteran");
            
            case GlobalVariables.SONG_ACCESS_TOKEN:
                return _gvars.TOKENS[songInfo.level].info;
            
            case GlobalVariables.SONG_ACCESS_BANNED:
                return _lang.string("song_selection_banned_invalid");
        }
        return sprintf(_lang.string("song_selection_banned_unknown"), {
                    access : songInfo.access
                });
    }
    
    private function get_songInfo() : SongInfo
    {
        return _songInfo;
    }
    
    private function get_level() : Int
    {
        return _level;
    }
    
    private function set_highlight(val                       : Dynamic) : Bool
    {
        _highlight = val;
        draw();
        showHoverMessage(val);
        return val;
    }
    
    private function get_highlight() : Bool
    {
        return _highlight || _active;
    }
    
    private function set_active(val                       : Dynamic) : Bool
    {
        _active = val;
        draw();
        showHoverMessage(val);
        return val;
    }
    
    private function get_active() : Bool
    {
        return _active;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    private function get_noteEnabled() : Bool
    {
        return _hoverEnabled;
    }
    
    private function set_noteEnabled(val                       : Dynamic) : Bool
    {
        _hoverEnabled = val;
        return val;
    }
}
