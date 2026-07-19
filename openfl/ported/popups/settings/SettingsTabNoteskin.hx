package popups.settings;

import openfl.errors.Error;
import assets.menu.icons.fa.IconRefresh;
import classes.Alert;
import classes.Language;
import classes.Noteskins;
import classes.NoteskinsStruct;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.BoxIcon;
import classes.ui.PromptInput;
import classes.ui.Text;
import com.bit101.components.ComboBox;
import com.flashfla.utils.SystemUtil;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import game.noteskins.ExternalNoteskin;

class SettingsTabNoteskin extends SettingsTabBase
{
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    private var _noteskins : Noteskins = Noteskins.instance;
    
    private var noteskin_struct : Dynamic = NoteskinsStruct.getDefaultStruct();
    
    private var noteColorComboArray : Array<Dynamic> = [];
    private var optionNoteskins : Array<Dynamic>;
    private var optionNoteskinPreview : Sprite;
    private var optionNoteSkinCombo : ComboBox;
    private var optionNoteSkinComboIgnore : Bool = false;
    private var optionNoteskinComboRefresh : BoxIcon;
    
    private var optionOpenCustomNoteskinEditor : BoxButton;
    private var optionOpenNoteskinFolder : BoxButton;
    private var optionImportCustomNoteskin : BoxButton;
    private var optionExportCustomNoteskin : BoxButton;
    
    private var optionNoteColors : Array<Dynamic>;
    private var arrayColorSprites : Array<Dynamic>;
    private var arrayColorSpritesReplace : Array<Dynamic>;
    
    private var lastNoteskin : Int;
    
    public function new(settingsWindow : SettingsWindow)
    {
        super(settingsWindow);
        
        lastNoteskin = _gvars.activeUser.activeNoteskin;
        
        noteColorComboArray = [];
        for (i in 0...DEFAULT_OPTIONS.noteColors.length)
        {
            noteColorComboArray.push({
                        label : _lang.stringSimple("note_colors_" + DEFAULT_OPTIONS.noteColors[i]),
                        data : DEFAULT_OPTIONS.noteColors[i]
                    });
        }
    }
    
    override private function get_name() : String
    {
        return "noteskin";
    }
    
    override public function openTab() : Void
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(295, 15);
        container.graphics.lineTo(295, 405);
        
        var item : Dynamic;
        var i : Int;
        var xOff : Int = 15;
        var yOff : Int = 15;
        
        optionNoteskinPreview = addNoteImage(xOff + 233, yOff + 32, 64, "blue");
        
        //- Noteskins
        optionNoteskins = [];
        var textNoteskinGroup : Text = new Text(container, xOff, yOff, _lang.string("options_noteskin"), 14);
        textNoteskinGroup.width = 265;
        yOff += 25;
        
        var gameNoteskinCheck : BoxCheck;
        
        var noteskinData : Dynamic = _noteskins.data;
        var noteskin_ids : Array<Dynamic> = [];
        
        for (item/* AS3HX WARNING could not determine type for var: item exp: EIdent(noteskinData) type: Dynamic */ in noteskinData)
        {
            if (Reflect.field(item, "_hidden") == null)
            {
                noteskin_ids.push(item.id);
            }
        }
        
        noteskin_ids.sort(Array.NUMERIC);
        
        for (noteskin_id in noteskin_ids)
        {
            item = Reflect.field(noteskinData, Std.string(noteskin_id));
            new Text(container, xOff + 23, yOff, item.name);
            
            gameNoteskinCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            gameNoteskinCheck.skin = item.id;
            optionNoteskins.push(gameNoteskinCheck);
            
            yOff += 20;
        }
        
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        // Custom
        new Text(container, xOff + 23, yOff, _lang.string("options_noteskin_custom"));
        
        gameNoteskinCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        gameNoteskinCheck.skin = 0;
        optionNoteskins.push(gameNoteskinCheck);
        yOff += 30;
        
        optionNoteSkinCombo = new ComboBox(container, xOff, yOff, "-- Change Custom Noteskin --");
        optionNoteSkinCombo.setSize(240, 22);
        optionNoteSkinCombo.openPosition = ComboBox.BOTTOM;
        optionNoteSkinCombo.fontSize = 11;
        optionNoteSkinCombo.numVisibleItems = 10;
        optionNoteSkinCombo.addEventListener(Event.SELECT, gameNoteSkinSelect);
        setCustomNoteskinCombo();
        
        optionNoteskinComboRefresh = new BoxIcon(container, xOff + 240, yOff + 1, 20, 20, new IconRefresh(), clickHandler);
        optionNoteskinComboRefresh.padding = 7;
        
        yOff += 31;
        
        optionOpenCustomNoteskinEditor = new BoxButton(container, xOff, yOff, 125, 29, _lang.string("options_open_noteskin_editor"), 12, clickHandler);
        optionImportCustomNoteskin = new BoxButton(container, xOff + 135, yOff, 125, 29, _lang.string("options_import_noteskin_json"), 12, clickHandler);
        
        yOff += 39;
        
        optionOpenNoteskinFolder = new BoxButton(container, xOff, yOff, 125, 29, _lang.string("options_open_noteskin_folder"), 12, clickHandler);
        optionExportCustomNoteskin = new BoxButton(container, xOff + 135, yOff, 125, 29, _lang.string("options_copy_noteskin_data"), 12, clickHandler);
        
        /// Col 2
        xOff = 310;
        yOff = 15;
        
        var gameNoteColorTitle : Text = new Text(container, xOff + 5, yOff, _lang.string("options_note_colors_title"), 14);
        gameNoteColorTitle.width = 265;
        gameNoteColorTitle.align = Text.CENTER;
        
        var optionNoteColorReset : BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
        optionNoteColorReset.color_reset_id = true;
        optionNoteColorReset.color = 0xff0000;
        
        yOff += 28;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionNoteColors = [];
        arrayColorSprites = [];
        arrayColorSpritesReplace = [];
        for (i in 0...DEFAULT_OPTIONS.noteColors.length)
        {
            arrayColorSprites.push(addNoteImage(xOff + 11, yOff + 11, 22, DEFAULT_OPTIONS.noteColors[i]));
            
            var gameNoteColor : Text = new Text(container, xOff + 25, yOff, _lang.string("note_colors_" + DEFAULT_OPTIONS.noteColors[i]));
            gameNoteColor.width = 95;
            
            var gameNoteColorCombo : ComboBox = new ComboBox(container, xOff + 125, yOff, _lang.stringSimple("note_colors_" + DEFAULT_OPTIONS.noteColors[i]), noteColorComboArray);
            gameNoteColorCombo.setSize(114, 22);
            gameNoteColorCombo.openPosition = ComboBox.BOTTOM;
            gameNoteColorCombo.fontSize = 11;
            gameNoteColorCombo.numVisibleItems = DEFAULT_OPTIONS.noteColors.length;
            gameNoteColorCombo.addEventListener(Event.SELECT, gameNoteColorSelect);
            optionNoteColors.push(gameNoteColorCombo);
            
            arrayColorSpritesReplace.push(addNoteImage(xOff + 255, yOff + 11, 22, _gvars.activeUser.noteColors[i]));
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        }
        
        yOff += 20;
        var gameSwapAllNoteColor : Text = new Text(container, xOff, yOff, _lang.string("note_colors_swap_all"));
        gameSwapAllNoteColor.width = 120;
        
        var gameSwapAllNoteColorCombo : ComboBox = new ComboBox(container, xOff + 125, yOff, "---", noteColorComboArray);
        gameSwapAllNoteColorCombo.setSize(139, 22);
        gameSwapAllNoteColorCombo.openPosition = ComboBox.BOTTOM;
        gameSwapAllNoteColorCombo.fontSize = 11;
        gameSwapAllNoteColorCombo.numVisibleItems = DEFAULT_OPTIONS.noteColors.length;
        gameSwapAllNoteColorCombo.addEventListener(Event.SELECT, gameSwapAllNoteColorSelect);
    }
    
    private function addNoteImage(xOff : Float, yOff : Float, receptorSize : Float, color : String) : Sprite
    {
        var data : Dynamic = _noteskins.getInfo(_gvars.activeUser.activeNoteskin);
        var hasRotation : Bool = (data.rotation != 0);
        
        var noteHolder : Sprite = new Sprite();
        noteHolder.x = xOff;
        noteHolder.y = yOff;
        container.addChild(noteHolder);
        
        var noteSprite : Sprite = _noteskins.getNote(data.id, color, "U");
        noteSprite.x = -(data.width >> 1);
        noteSprite.y = -(data.height >> 1);
        noteHolder.addChild(noteSprite);
        
        // scale
        if (hasRotation)
        {
            noteHolder.rotation = data.rotation * 2;
        }
        
        var noteScale : Float = Math.min(1, receptorSize / Math.max(noteHolder.width, noteHolder.height));
        noteHolder.scaleX = noteHolder.scaleY = noteScale;
        noteHolder.visible = true;
        
        return noteHolder;
    }
    
    private function replaceNoteImage(oldSprite : Sprite, receptorSize : Float, color : String) : Sprite
    {
        var xOff : Float = oldSprite.x;
        var yOff : Float = oldSprite.y;
        
        oldSprite.parent.removeChild(oldSprite);
        
        return addNoteImage(xOff, yOff, receptorSize, color);
    }
    
    private function updateNoteImages() : Void
    {
        for (i in 0...DEFAULT_OPTIONS.noteColors.length)
        {
            arrayColorSprites[i] = replaceNoteImage(arrayColorSprites[i], 22, DEFAULT_OPTIONS.noteColors[i]);
            arrayColorSpritesReplace[i] = replaceNoteImage(arrayColorSpritesReplace[i], 22, _gvars.activeUser.noteColors[i]);
        }
        
        optionNoteskinPreview = replaceNoteImage(optionNoteskinPreview, 64, "blue");
    }
    
    override public function setValues() : Void
    // Set Noteskin
    {
        
        for (item in optionNoteskins)
        {
            item.checked = (item.skin == _gvars.activeUser.activeNoteskin);
        }
        
        for (i in 0...DEFAULT_OPTIONS.noteColors.length)
        {
            (try cast(optionNoteColors[i], ComboBox) catch(e:Dynamic) null).selectedItemByData = _gvars.activeUser.noteColors[i];
        }
        
        if (lastNoteskin != _gvars.activeUser.activeNoteskin)
        {
            lastNoteskin = _gvars.activeUser.activeNoteskin;
            updateNoteImages();
        }
    }
    
    override public function clickHandler(e : MouseEvent) : Void
    //- Noteskin
    {
        
        if (e.target.exists("skin"))
        {
            _gvars.activeUser.activeNoteskin = e.target.skin;
        }
        
        //- Custom Refresh
        if (e.target == optionNoteskinComboRefresh)
        {
            _noteskins.loadExternalNoteskins();
            setCustomNoteskinCombo();
        }
        //- Custom Noteskin Editor
        else if (e.target == optionOpenCustomNoteskinEditor)
        {
            flash.Lib.getURL(new URLRequest(Constant.NOTESKIN_EDITOR_URL), "_blank");
            return;
        }
        //- Custom Noteskin Folder
        else if (e.target == optionOpenNoteskinFolder)
        {
            AirContext.STORAGE_PATH.resolvePath(Constant.NOTESKIN_PATH).openWithDefaultApplication();
            return;
        }
        //- Import Custom Noteskin
        else if (e.target == optionImportCustomNoteskin)
        {
            new PromptInput(parent, _lang.string("popup_noteskin_import_json"), _lang.string("popup_noteskin_import"), e_importNoteskin);
            return;
        }
        //- Export Custom Noteskin
        else if (e.target == optionExportCustomNoteskin)
        {
            var nsString : String = noteskinsString();
            if (nsString != null)
            {
                var success : Bool = SystemUtil.setClipboard(nsString);
                if (success)
                {
                    Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
                }
                else
                {
                    Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
                }
            }
            return;
        }
        
        if (e.target.exists("color_reset_id"))
        {
            for (i in 0...DEFAULT_OPTIONS.noteColors.length)
            {
                _gvars.activeUser.noteColors[i] = DEFAULT_OPTIONS.noteColors[i];
            }
        }
        
        setValues();
    }
    
    private function gameNoteColorSelect(e : Event) : Void
    {
        var data : Dynamic = e.target.selectedItem.data;
        for (i in 0...optionNoteColors.length)
        {
            if (optionNoteColors[i] == e.target)
            {
                _gvars.activeUser.noteColors[i] = data;
                arrayColorSpritesReplace[i] = replaceNoteImage(arrayColorSpritesReplace[i], 22, _gvars.activeUser.noteColors[i]);
            }
        }
    }
    
    private function gameSwapAllNoteColorSelect(e : Event) : Void
    {
        if (e.target.selectedItem == null)
        {
            return;
        }
        
        var data : Dynamic = e.target.selectedItem.data;
        for (i in 0...optionNoteColors.length)
        {
            _gvars.activeUser.noteColors[i] = data;
            (try cast(optionNoteColors[i], ComboBox) catch(e:Dynamic) null).selectedItemByData = data;
            arrayColorSpritesReplace[i] = replaceNoteImage(arrayColorSpritesReplace[i], 22, _gvars.activeUser.noteColors[i]);
        }
        e.target.selectedItem = null;
    }
    
    private function setCustomNoteskinCombo() : Void
    {
        var extList : Array<ExternalNoteskin> = _noteskins.externalNoteskins;
        var noteskinList : Array<Dynamic> = [];
        var ns : ExternalNoteskin;
        
        var noteskinData : String = LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_DATA, null);
        var noteskinImport : String = LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_IMPORT, null);
        var noteskinFilename : String = LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_FILE, null);
        
        if (extList.length > 0)
        {
            for (i in 0...extList.length)
            {
                ns = extList[i];
                
                var nsName : String = (ns.data.name.indexOf("Custom Export") != -(1) ? ns.file.substr(0, ns.file.length - 4) : ns.data.name).replace(new as3hx.Compat.Regex('^\\s+|\\s+$', "gs"), "");
                if (nsName.length <= 0)
                {
                    nsName = "<" + ns.file + ">";
                }
                
                noteskinList.push({
                            label : nsName,
                            data : extList[i]
                        });
            }
            noteskinList.sortOn("label", Array.CASEINSENSITIVE);
        }
        
        if (noteskinImport != null)
        {
            if (extList.length > 0)
            {
                noteskinList.unshift({
                            label : "------------------------------------",
                            data : null
                        });
            }
            
            noteskinList.unshift({
                        label : "Imported Noteskin",
                        data : optionNoteSkinCombo
                    });
        }
        
        optionNoteSkinComboIgnore = true;
        optionNoteSkinCombo.items = noteskinList;
        
        // select combo box index
        if (noteskinFilename != null)
        {
            for (i in 0...noteskinList.length)
            {
                if (noteskinList[i].data != null && (Std.is(noteskinList[i].data, ExternalNoteskin)) && noteskinList[i].data.file == noteskinFilename)
                {
                    optionNoteSkinCombo.selectedIndex = i;
                    break;
                }
            }
        }
        else
        {
            optionNoteSkinCombo.selectedIndex = 0;
        }
        optionNoteSkinComboIgnore = false;
    }
    
    private function gameNoteSkinSelect(e : Event) : Void
    {
        if (optionNoteSkinComboIgnore)
        {
            return;
        }
        
        var data : Dynamic = e.target.selectedItem.data;
        if (data == null)
        {
            return;
        }
        else if (data == optionNoteSkinCombo)
        {
            var json : String = LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_IMPORT, null);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_DATA, json);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_FILE, null);
        }
        else
        {
            var extNS : ExternalNoteskin = try cast(data, ExternalNoteskin) catch(e:Dynamic) null;
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_DATA, extNS.json);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_FILE, extNS.file);
        }
        
        if (_gvars.activeUser.activeNoteskin != 0)
        {
            _gvars.activeUser.activeNoteskin = 0;
            setValues();
        }
        
        _noteskins.loadCustomNoteskin();
        parent.addEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
    }
    
    
    private function e_importNoteskin(noteskinJSON : String) : Void
    {
        try
        {
            var json : Dynamic = haxe.Json.parse(noteskinJSON);
            
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_DATA, noteskinJSON);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_IMPORT, noteskinJSON);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_FILE, null);
            
            _noteskins.loadCustomNoteskin();
            setCustomNoteskinCombo();
            
            Alert.add(_lang.string("popup_noteskin_saved"), 90, Alert.GREEN);
            
            parent.addEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
        }
        catch (e : Error)
        {
        }
    }
    
    private function e_delayCustomUpdate(e : Event) : Void
    // reload images, custom noteskins are async loaded so we just check for them to load
    {
        
        if (_gvars.activeUser.activeNoteskin == 0)
        {
            if (_noteskins.data[0] != null && _noteskins.data[0]["notes"] != null && _noteskins.data[0]["notes"]["blue"] != null)
            {
                parent.removeEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
                if (parent != null && parent.stage != null)
                {
                    updateNoteImages();
                }
            }
            
            if (_noteskins.data[0] == null)
            {
                parent.removeEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
            }
        }
    }
    
    private function noteskinsString() : String
    {
        return LocalStore.getVariable("custom_noteskin", null);
    }
}

