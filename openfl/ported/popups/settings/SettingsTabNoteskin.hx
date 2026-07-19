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
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _noteskins                       : Dynamic= Noteskins.instance;
    
    private var noteskin_struct                       : Dynamic= NoteskinsStruct.getDefaultStruct();
    
    private var noteColorComboArray                       : Dynamic= [];
    private var optionNoteskins                       : Dynamic;
    private var optionNoteskinPreview                       : Dynamic;
    private var optionNoteSkinCombo                       : Dynamic;
    private var optionNoteSkinComboIgnore                       : Dynamic= false;
    private var optionNoteskinComboRefresh                       : Dynamic;
    
    private var optionOpenCustomNoteskinEditor                       : Dynamic;
    private var optionOpenNoteskinFolder                       : Dynamic;
    private var optionImportCustomNoteskin                       : Dynamic;
    private var optionExportCustomNoteskin                       : Dynamic;
    
    private var optionNoteColors                       : Dynamic;
    private var arrayColorSprites                       : Dynamic;
    private var arrayColorSpritesReplace                       : Dynamic;
    
    private var lastNoteskin                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
        
        lastNoteskin = _gvars.activeUser.activeNoteskin;
        
        noteColorComboArray = [];
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.noteColors.length)
        {
            noteColorComboArray.push({
                        label : _lang.stringSimple("note_colors_" + SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]),
                        data : SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]
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
        
        var item                       : Dynamic= null;
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 15;
        
        optionNoteskinPreview = addNoteImage(xOff + 233, yOff + 32, 64, "blue");
        
        //- Noteskins
        optionNoteskins = [];
        var textNoteskinGroup                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_noteskin"), 14);
        textNoteskinGroup.width = 265;
        yOff += 25;
        
        var gameNoteskinCheck                       : Dynamic= null;
        
        var noteskinData                       : Dynamic= _noteskins.data;
        var noteskin_ids                       : Dynamic= [];
        
        for (item/* AS3HX WARNING could not determine type for var: item exp: EIdent(noteskinData) type: Dynamic */ in as3hx.Compat.iter(noteskinData))
        {
            if (as3hx.Compat.truthy(Reflect.field(item, "_hidden") == null))
            {
                noteskin_ids.push(item.id);
            }
        }
        
        noteskin_ids.sort(as3hx.Compat.ARRAY_NUMERIC);
        
        for (noteskin_id in as3hx.Compat.iter(noteskin_ids))
        {
            item = as3hx.Compat.field(noteskinData, noteskin_id);
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
        
        var gameNoteColorTitle                       : Dynamic= new Text(container, xOff + 5, yOff, _lang.string("options_note_colors_title"), 14);
        gameNoteColorTitle.width = 265;
        gameNoteColorTitle.align = Text.CENTER;
        
        var optionNoteColorReset                       : Dynamic= new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
        optionNoteColorReset.color_reset_id = true;
        optionNoteColorReset.color = 0xff0000;
        
        yOff += 28;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionNoteColors = [];
        arrayColorSprites = [];
        arrayColorSpritesReplace = [];
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.noteColors.length)
        {
            arrayColorSprites.push(addNoteImage(xOff + 11, yOff + 11, 22, SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]));
            
            var gameNoteColor                       : Dynamic= new Text(container, xOff + 25, yOff, _lang.string("note_colors_" + SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]));
            gameNoteColor.width = 95;
            
            var gameNoteColorCombo                       : Dynamic= new ComboBox(container, xOff + 125, yOff, _lang.stringSimple("note_colors_" + SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]), noteColorComboArray);
            gameNoteColorCombo.setSize(114, 22);
            gameNoteColorCombo.openPosition = ComboBox.BOTTOM;
            gameNoteColorCombo.fontSize = 11;
            gameNoteColorCombo.numVisibleItems = SettingsTabBase.DEFAULT_OPTIONS.noteColors.length;
            gameNoteColorCombo.addEventListener(Event.SELECT, gameNoteColorSelect);
            optionNoteColors.push(gameNoteColorCombo);
            
            arrayColorSpritesReplace.push(addNoteImage(xOff + 255, yOff + 11, 22, _gvars.activeUser.noteColors[i]));
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        }
        
        yOff += 20;
        var gameSwapAllNoteColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("note_colors_swap_all"));
        gameSwapAllNoteColor.width = 120;
        
        var gameSwapAllNoteColorCombo                       : Dynamic= new ComboBox(container, xOff + 125, yOff, "---", noteColorComboArray);
        gameSwapAllNoteColorCombo.setSize(139, 22);
        gameSwapAllNoteColorCombo.openPosition = ComboBox.BOTTOM;
        gameSwapAllNoteColorCombo.fontSize = 11;
        gameSwapAllNoteColorCombo.numVisibleItems = SettingsTabBase.DEFAULT_OPTIONS.noteColors.length;
        gameSwapAllNoteColorCombo.addEventListener(Event.SELECT, gameSwapAllNoteColorSelect);
    }
    
    private function addNoteImage(xOff                       : Dynamic, yOff                       : Dynamic, receptorSize                       : Dynamic, color                       : Dynamic) : Sprite
    {
        var data                       : Dynamic= _noteskins.getInfo(_gvars.activeUser.activeNoteskin);
        var hasRotation                       : Dynamic= (data.rotation != 0);
        
        var noteHolder                       : Dynamic= new Sprite();
        noteHolder.x = xOff;
        noteHolder.y = yOff;
        container.addChild(noteHolder);
        
        var noteSprite                       : Dynamic= _noteskins.getNote(data.id, color, "U");
        noteSprite.x = -(data.width >> 1);
        noteSprite.y = -(data.height >> 1);
        noteHolder.addChild(noteSprite);
        
        // scale
        if (as3hx.Compat.truthy(hasRotation))
        {
            noteHolder.rotation = data.rotation * 2;
        }
        
        var noteScale                       : Dynamic= Math.min(1, receptorSize / Math.max(noteHolder.width, noteHolder.height));
        noteHolder.scaleX = noteHolder.scaleY = noteScale;
        noteHolder.visible = true;
        
        return noteHolder;
    }
    
    private function replaceNoteImage(oldSprite                       : Dynamic, receptorSize                       : Dynamic, color                       : Dynamic) : Sprite
    {
        var xOff                       : Dynamic= oldSprite.x;
        var yOff                       : Dynamic= oldSprite.y;
        
        oldSprite.parent.removeChild(oldSprite);
        
        return addNoteImage(xOff, yOff, receptorSize, color);
    }
    
    private function updateNoteImages() : Void
    {
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.noteColors.length)
        {
            arrayColorSprites[i] = replaceNoteImage(arrayColorSprites[i], 22, SettingsTabBase.DEFAULT_OPTIONS.noteColors[i]);
            arrayColorSpritesReplace[i] = replaceNoteImage(arrayColorSpritesReplace[i], 22, _gvars.activeUser.noteColors[i]);
        }
        
        optionNoteskinPreview = replaceNoteImage(optionNoteskinPreview, 64, "blue");
    }
    
    override public function setValues() : Void
    // Set Noteskin
    {
        
        for (item in as3hx.Compat.iter(optionNoteskins))
        {
            item.checked = (item.skin == _gvars.activeUser.activeNoteskin);
        }
        
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.noteColors.length)
        {
            (try cast(optionNoteColors[i], ComboBox) catch(e:Dynamic) null).selectedItemByData = _gvars.activeUser.noteColors[i];
        }
        
        if (as3hx.Compat.truthy(lastNoteskin != _gvars.activeUser.activeNoteskin))
        {
            lastNoteskin = _gvars.activeUser.activeNoteskin;
            updateNoteImages();
        }
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    //- Noteskin
    {
        
        if (as3hx.Compat.truthy(e.target.exists("skin")))
        {
            _gvars.activeUser.activeNoteskin = e.target.skin;
        }
        
        //- Custom Refresh
        if (as3hx.Compat.truthy(e.target == optionNoteskinComboRefresh))
        {
            _noteskins.loadExternalNoteskins();
            setCustomNoteskinCombo();
        }
        //- Custom Noteskin Editor
        else if (as3hx.Compat.truthy(e.target == optionOpenCustomNoteskinEditor))
        {
            flash.Lib.getURL(new URLRequest(Constant.NOTESKIN_EDITOR_URL), "_blank");
            return;
        }
        //- Custom Noteskin Folder
        else if (as3hx.Compat.truthy(e.target == optionOpenNoteskinFolder))
        {
            AirContext.STORAGE_PATH.resolvePath(Constant.NOTESKIN_PATH).openWithDefaultApplication();
            return;
        }
        //- Import Custom Noteskin
        else if (as3hx.Compat.truthy(e.target == optionImportCustomNoteskin))
        {
            new PromptInput(parent, _lang.string("popup_noteskin_import_json"), _lang.string("popup_noteskin_import"), e_importNoteskin);
            return;
        }
        //- Export Custom Noteskin
        else if (as3hx.Compat.truthy(e.target == optionExportCustomNoteskin))
        {
            var nsString                       : Dynamic= noteskinsString();
            if (as3hx.Compat.truthy(nsString != null))
            {
                var success                       : Dynamic= SystemUtil.setClipboard(nsString);
                if (as3hx.Compat.truthy(success))
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
        
        if (as3hx.Compat.truthy(e.target.exists("color_reset_id")))
        {
            for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.noteColors.length)
            {
                _gvars.activeUser.noteColors[i] = SettingsTabBase.DEFAULT_OPTIONS.noteColors[i];
            }
        }
        
        setValues();
    }
    
    private function gameNoteColorSelect(e                       : Dynamic) : Void
    {
        var data                       : Dynamic= e.target.selectedItem.data;
        for (i in 0...optionNoteColors.length)
        {
            if (as3hx.Compat.truthy(optionNoteColors[i] == e.target))
            {
                _gvars.activeUser.noteColors[i] = data;
                arrayColorSpritesReplace[i] = replaceNoteImage(arrayColorSpritesReplace[i], 22, _gvars.activeUser.noteColors[i]);
            }
        }
    }
    
    private function gameSwapAllNoteColorSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target.selectedItem == null))
        {
            return;
        }
        
        var data                       : Dynamic= e.target.selectedItem.data;
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
        var extList                       : Dynamic= _noteskins.externalNoteskins;
        var noteskinList                       : Dynamic= [];
        var ns                       : Dynamic= null;
        
        var noteskinData                       : Dynamic= LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_DATA, null);
        var noteskinImport                       : Dynamic= LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_IMPORT, null);
        var noteskinFilename                       : Dynamic= LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_FILE, null);
        
        if (as3hx.Compat.truthy(extList.length > 0))
        {
            for (i in 0...extList.length)
            {
                ns = extList[i];
                
                var nsName                       : Dynamic= new as3hx.Compat.Regex('^\\s+|\\s+$', "gs").replace((ns.data.name.indexOf("Custom Export") != -(1) ? ns.file.substr(0, ns.file.length - 4) : ns.data.name), "");
                if (as3hx.Compat.truthy(nsName.length <= 0))
                {
                    nsName = "<" + ns.file + ">";
                }
                
                noteskinList.push({
                            label : nsName,
                            data : extList[i]
                        });
            }
            as3hx.Compat.sortOn(noteskinList, "label", as3hx.Compat.ARRAY_CASEINSENSITIVE);
        }
        
        if (as3hx.Compat.truthy(noteskinImport != null))
        {
            if (as3hx.Compat.truthy(extList.length > 0))
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
        if (as3hx.Compat.truthy(noteskinFilename != null))
        {
            for (i in 0...noteskinList.length)
            {
                if (as3hx.Compat.truthy(noteskinList[i].data != null && (Std.is(noteskinList[i].data, ExternalNoteskin)) && noteskinList[i].data.file == noteskinFilename))
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
    
    private function gameNoteSkinSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(optionNoteSkinComboIgnore))
        {
            return;
        }
        
        var data                       : Dynamic= e.target.selectedItem.data;
        if (as3hx.Compat.truthy(data == null))
        {
            return;
        }
        else if (as3hx.Compat.truthy(data == optionNoteSkinCombo))
        {
            var json                       : Dynamic= LocalStore.getVariable(Noteskins.CUSTOM_NOTESKIN_IMPORT, null);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_DATA, json);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_FILE, null);
        }
        else
        {
            var extNS                       : Dynamic= try cast(data, ExternalNoteskin) catch(e:Dynamic) null;
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_DATA, extNS.json);
            LocalStore.setVariable(Noteskins.CUSTOM_NOTESKIN_FILE, extNS.file);
        }
        
        if (as3hx.Compat.truthy(_gvars.activeUser.activeNoteskin != 0))
        {
            _gvars.activeUser.activeNoteskin = 0;
            setValues();
        }
        
        _noteskins.loadCustomNoteskin();
        parent.addEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
    }
    
    
    private function e_importNoteskin(noteskinJSON                       : Dynamic) : Void
    {
        try
        {
            var json                       : Dynamic= haxe.Json.parse(noteskinJSON);
            
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
    
    private function e_delayCustomUpdate(e                       : Dynamic) : Void
    // reload images, custom noteskins are async loaded so we just check for them to load
    {
        
        if (as3hx.Compat.truthy(_gvars.activeUser.activeNoteskin == 0))
        {
            if (as3hx.Compat.truthy(_noteskins.data[0] != null && as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes") != null && as3hx.Compat.field(as3hx.Compat.field(as3hx.Compat.field(_noteskins.data, 0), "notes"), "blue") != null))
            {
                parent.removeEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
                if (as3hx.Compat.truthy(parent != null && parent.stage != null))
                {
                    updateNoteImages();
                }
            }
            
            if (as3hx.Compat.truthy(_noteskins.data[0] == null))
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

