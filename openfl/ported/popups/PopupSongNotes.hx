package popups;

import openfl.errors.Error;
import assets.GameBackgroundColor;
import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.HeartSelector;
import classes.ui.StarSelector;
import classes.ui.Text;
import classes.ui.ValidatedText;
import classes.user.UserSongData;
import classes.user.UserSongNotes;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import menu.MainMenu;
import menu.MenuPanel;
import menu.MenuSongSelection;

class PopupSongNotes extends MenuPanel
{
    private var _lang                       : Dynamic= Language.instance;
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _playlist                       : Dynamic= Playlist.instance;
    private var _loader                       : Dynamic;
    
    //- Background
    private var box                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var songInfo                       : Dynamic;
    private var sDetails                       : Dynamic;
    
    private var sRating                       : Dynamic;
    private var sFavorite                       : Dynamic;
    
    private var notesLength                       : Dynamic;
    private var notesField                       : Dynamic;
    private var setMirrorInvert                       : Dynamic;
    private var setCustomOffsets                       : Dynamic;
    
    private var optionMusicOffset                       : Dynamic;
    private var optionJudgeOffset                       : Dynamic;
    
    private var revertOptions                       : Dynamic;
    private var confirmOptions                       : Dynamic;
    private var closeOptions                       : Dynamic;
    private var populateOffsets                       : Dynamic;
    
    public var songRatingValue                       : Dynamic;
    
    public function new(myParent                       : Dynamic, songInfo                       : Dynamic)
    {
        super(myParent);
        this.songInfo = songInfo;
        
        var engineId                       : Dynamic= (songInfo.engine != null) ? songInfo.engine.id : Constant.BRAND_NAME_SHORT_LOWER;
        sDetails = UserSongNotes.getSongDetailsSafe(engineId, songInfo.level_id);
        
        songRatingValue = _gvars.playerUser.getSongRating(songInfo);
    }
    
    override public function stageAdd() : Void
    {
        bmp = SpriteUtil.getBitmapSprite(stage);
        this.addChild(bmp);
        
        var bgbox                       : Dynamic= new Box(this, (Main.GAME_WIDTH - 390) / 2, -1, false, false);
        bgbox.setSize(390, Main.GAME_HEIGHT + 2);
        bgbox.color = GameBackgroundColor.BG_POPUP;
        bgbox.normalAlpha = 0.5;
        bgbox.activeAlpha = 1;
        
        box = new Box(this, bgbox.x, -1, false, false);
        box.setSize(bgbox.width, bgbox.height);
        box.activeAlpha = 0.4;
        
        var titleDisplay                       : Dynamic= new Text(box, 5, 20, "- " + Reflect.field(songInfo, "name") + " -", 20);
        titleDisplay.width = box.width - 10;
        titleDisplay.align = Text.CENTER;
        
        // Divider
        box.graphics.lineStyle(1, 0xffffff);
        box.graphics.moveTo(10, 65);
        box.graphics.lineTo(box.width - 10, 65);
        
        var lblSongRating                       : Dynamic= new Text(box, 20, 69, _lang.string("song_rating_label"), 14);
        lblSongRating.width = 145;
        lblSongRating.align = Text.LEFT;
        
        sRating = new StarSelector(box, 22, 95);
        
        var lblSongFavorite                       : Dynamic= new Text(box, box.width - 165, 68, _lang.string("song_favorite_label"), 14);
        lblSongFavorite.width = 145;
        lblSongFavorite.align = Text.RIGHT;
        
        sFavorite = new HeartSelector(box, box.width - 52, 93);
        
        // Divider
        box.graphics.lineStyle(1, 0xffffff);
        box.graphics.moveTo(10, 130);
        box.graphics.lineTo(box.width - 10, 130);
        
        var xOff                       : Dynamic= 20;
        var yOff                       : Dynamic= 140;
        
        //- Notes Field
        var notesLabel                       : Dynamic= new Text(box, xOff, yOff, _lang.string("song_notes"));
        
        notesLength = new Text(box, box.width - xOff, yOff, "(0 / 250)");
        notesLength.align = "right";
        yOff += 20;
        
        box.graphics.lineStyle(1, 0xffffff, 0.5);
        box.graphics.beginFill(0xffffff, 0.1);
        box.graphics.drawRect(xOff, yOff, box.width - 40, 80);
        box.graphics.endFill();
        
        notesField = new TextField();
        notesField.wordWrap = true;
        notesField.multiline = true;
        notesField.maxChars = 250;
        notesField.type = "input";
        notesField.antiAliasType = AntiAliasType.ADVANCED;
        notesField.embedFonts = true;
        notesField.defaultTextFormat = Constant.TEXT_FORMAT_UNICODE;
        notesField.width = 340;
        notesField.height = 70;
        notesField.x = xOff + 5;
        notesField.y = yOff + 5;
        notesField.addEventListener(Event.CHANGE, e_notesFieldChange);
        box.addChild(notesField);
        yOff += 90;
        
        // Settings
        var setMirrorInvertText                       : Dynamic= new Text(box, xOff + 22, yOff, _lang.string("song_notes_setting_mirror_invert"));
        setMirrorInvert = new BoxCheck(box, xOff + 2, yOff + 2, clickHandler);
        yOff += 30;
        
        var setCustomOffsetsText                       : Dynamic= new Text(box, xOff + 22, yOff, _lang.string("song_notes_setting_custom_offsets"));
        setCustomOffsets = new BoxCheck(box, xOff + 2, yOff + 2, clickHandler);
        yOff += 30;
        
        //- Global Offset
        var gameOffset                       : Dynamic= new Text(box, xOff, yOff, _lang.string("options_global_offset"));
        yOff += 20;
        
        optionMusicOffset = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT, changeHandler);
        optionMusicOffset.text = "0";
        
        //- Apply Current Offsets
        populateOffsets = new BoxButton(box, xOff + 110, yOff, 180, 27, _lang.string("song_notes_setting_apply_current_offsets"), 12, clickHandler);
        yOff += 30;
        
        //- Judge Offset
        var gameJudgeOffset                       : Dynamic= new Text(box, xOff, yOff, _lang.string("options_judge_offset"));
        yOff += 20;
        
        optionJudgeOffset = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT, changeHandler);
        optionJudgeOffset.text = "0";
        
        //- Revert
        revertOptions = new BoxButton(box, 20, box.height - 42, 80, 27, _lang.string("menu_revert"), 12, clickHandler);
        revertOptions.color = 0xff0000;
        
        //- Close
        closeOptions = new BoxButton(box, box.width - 100, box.height - 42, 80, 27, _lang.string("menu_close"), 12, clickHandler);
        
        //- Confirm
        confirmOptions = new BoxButton(box, closeOptions.x - 95, box.height - 42, 80, 27, _lang.string("menu_confirm"), 12, clickHandler);
        
        refreshFields();
    }
    
    private function refreshFields() : Void
    {
        if (as3hx.Compat.truthy(sDetails != null))
        {
            sRating.value = songRatingValue;
            sFavorite.checked = sDetails.song_favorite;
            notesField.text = sDetails.notes;
            notesLength.text = "(" + notesField.length + " / 250)";
            setMirrorInvert.checked = sDetails.set_mirror_invert;
            setCustomOffsets.checked = sDetails.set_custom_offsets;
            optionMusicOffset.text = Std.string(sDetails.offset_music);
            optionJudgeOffset.text = Std.string(sDetails.offset_judge);
        }
    }
    
    private function e_notesFieldChange(e                       : Dynamic) : Void
    {
        notesLength.text = "(" + notesField.length + " / 250)";
    }
    
    override public function stageRemove() : Void
    {
        notesField.removeEventListener(Event.CHANGE, e_notesFieldChange);
        setMirrorInvert.dispose();
        setCustomOffsets.dispose();
        optionJudgeOffset.dispose();
        optionMusicOffset.dispose();
        
        notesLength.dispose();
        populateOffsets.dispose();
        optionJudgeOffset.dispose();
        optionMusicOffset.dispose();
        revertOptions.dispose();
        closeOptions.dispose();
        confirmOptions.dispose();
        
        box.dispose();
        bmp = null;
        box = null;
    }
    
    private function changeHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, ValidatedText)))
        {
            (try cast(e.target, ValidatedText) catch(e:Dynamic) null).validate(0);
        }
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    //- Use Inverse Chart Mirror
    {
        
        if (as3hx.Compat.truthy(e.target == setMirrorInvert))
        {
            setMirrorInvert.checked = !setMirrorInvert.checked;
        }
        //- Use Custom Offsets
        else if (as3hx.Compat.truthy(e.target == setCustomOffsets))
        {
            setCustomOffsets.checked = !setCustomOffsets.checked;
        }
        //- Apply Current Offsets
        else if (as3hx.Compat.truthy(e.target == populateOffsets))
        {
            setCustomOffsets.checked = true;
            optionMusicOffset.text = Std.string(_gvars.activeUser.GLOBAL_OFFSET);
            optionJudgeOffset.text = Std.string(_gvars.activeUser.JUDGE_OFFSET);
            optionMusicOffset.validate(0);
            optionJudgeOffset.validate(0);
        }
        //- Revert
        else if (as3hx.Compat.truthy(e.target == revertOptions))
        {
            sFavorite.checked = false;
            setMirrorInvert.checked = false;
            setCustomOffsets.checked = false;
            notesField.text = "";
            notesLength.text = "(0 / 250)";
            optionMusicOffset.text = "0";
            optionJudgeOffset.text = "0";
            optionMusicOffset.validate(0);
            optionJudgeOffset.validate(0);
        }
        //- Confirm Rating
        else if (as3hx.Compat.truthy(e.target == confirmOptions))
        {
            saveRatings();
            saveDetails();
            removePopup();
            
            // Update the Note Hover Directly
            if (as3hx.Compat.truthy(_gvars.gameMain.activePanel != null && Std.is(_gvars.gameMain.activePanel, MainMenu)))
            {
                var mmmenu                       : Dynamic= (try cast(_gvars.gameMain.activePanel, MainMenu) catch(e:Dynamic) null);
                if (as3hx.Compat.truthy(mmmenu.panel != null && (Std.is(mmmenu.panel, MenuSongSelection))))
                {
                    var msmenu                       : Dynamic= (try cast(mmmenu.panel, MenuSongSelection) catch(e:Dynamic) null);
                    msmenu.updateSongItemNote(songInfo.level);
                }
            }
            
            return;
        }
        //- Close
        else if (as3hx.Compat.truthy(e.target == closeOptions))
        {
            removePopup();
            return;
        }
    }
    
    private function saveDetails() : Void
    {
        sDetails.song_favorite = sFavorite.checked;
        sDetails.offset_music = optionMusicOffset.validate(0);
        sDetails.offset_judge = optionJudgeOffset.validate(0);
        sDetails.set_mirror_invert = setMirrorInvert.checked;
        sDetails.set_custom_offsets = setCustomOffsets.checked;
        sDetails.notes = notesField.text;
        
        // Song Rating
        if (as3hx.Compat.truthy(sDetails.engine != Constant.BRAND_NAME_SHORT_LOWER))
        {
            sDetails.song_rating = sRating.value;
        }
        else
        {
            Reflect.setField(_gvars.playerUser.songRatings, Std.string(Reflect.field(songInfo, "level")), sRating.value);
        }
        
        _gvars.writeUserSongData();
    }
    
    private function saveRatings() : Void
    {
        if (as3hx.Compat.truthy(sRating.value == songRatingValue || sDetails.engine != Constant.BRAND_NAME_SHORT_LOWER))
        {
            return;
        }
        
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                       : Dynamic= new URLRequest(URLs.resolve(URLs.SONG_RATING_URL) + "?d=" + Date.now().getTime());
        var requestVars                       : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.session = _gvars.userSession;
        requestVars.id = Reflect.field(songInfo, "level");
        requestVars.song_rating = sRating.value;
        requestVars.chart_rating = 2.5;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, ratingLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, ratingLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ratingLoadError);
    }
    
    private function ratingLoadComplete(e                       : Dynamic) : Void
    {
        removeLoaderListeners();
        
        try
        {
            var _data                       : Dynamic= haxe.Json.parse(e.target.data);
            if (as3hx.Compat.truthy(Reflect.field(_data, "result") != null && Reflect.field(_data, "result") == "success"))
            {
                Reflect.setField(_gvars.playerUser.songRatings, Std.string(Reflect.field(songInfo, "level")), sRating.value);
                
                //Alert.add("Saved rating for " + sObject["name"] + "!", 120, Alert.GREEN);
                
                if (as3hx.Compat.truthy(Reflect.field(_data, "type") != null && Reflect.field(_data, "type") == 1))
                {
                    Reflect.setField(as3hx.Compat.field(_playlist.playList, Reflect.field(songInfo, "level")), "song_rating", Reflect.field(_data, "new_value"));
                }
            }
            else
            {  //Alert.add("Failed to save song rating.", 120, Alert.RED);  
                
            }
        }
        catch (e : Error)
        {
        }
    }
    
    private function removeLoaderListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, ratingLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, ratingLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, ratingLoadError);
    }
    
    private function ratingLoadError(e                       : Dynamic) : Void
    {
        removeLoaderListeners();
    }
}

