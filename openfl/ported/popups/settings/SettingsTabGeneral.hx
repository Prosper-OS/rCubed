package popups.settings;

import arc.ArcGlobals;
import classes.Alert;
import classes.Language;
import classes.mp.Multiplayer;
import classes.ui.BoxCheck;
import classes.ui.BoxSlider;
import classes.ui.PromptInput;
import classes.ui.Text;
import classes.ui.ValidatedText;
import com.flashfla.utils.ArrayUtil;
import com.flashfla.utils.StringUtil;
import openfl.events.ContextMenuEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.ui.ContextMenu;
import openfl.ui.ContextMenuItem;

class SettingsTabGeneral extends SettingsTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var _mp                       : Dynamic= Multiplayer.instance;
    
    private var optionGameSpeed                       : Dynamic;
    private var optionReceptorSpacing                       : Dynamic;
    private var textNoteScale                       : Dynamic;
    private var optionNoteScale                       : Dynamic;
    private var textGameVolume                       : Dynamic;
    private var optionGameVolume                       : Dynamic;
    private var textMenuVolume                       : Dynamic;
    private var optionMenuVolume                       : Dynamic;
    
    private var optionOffset                       : Dynamic;
    private var optionVisualDelay                       : Dynamic;
    private var optionJudgeOffset                       : Dynamic;
    private var optionJudgeOffsetAuto                       : Dynamic;
    private var optionAutofail                       : Dynamic;
    private var optionAutofailEquivInput                       : Dynamic;
    private var optionAutofailRestart                       : Dynamic;
    private var optionPersonalBestMode                       : Dynamic;
    
    private var optionScrollDirections                       : Dynamic;
    private var optionMirrorMod                       : Dynamic;
    private var optionRate                       : Dynamic;
    private var optionIsolation                       : Dynamic;
    private var optionIsolationTotal                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "general";
    }
    
    override public function openTab() : Void
    {
        container.graphics.beginFill(0, 0.05);
        container.graphics.drawRect(198, 0, 196, 418);
        container.graphics.endFill();
        
        container.graphics.lineStyle(1, 0xFFFFFF, 0.05);
        container.graphics.moveTo(197, 0);
        container.graphics.lineTo(197, 418);
        container.graphics.moveTo(394, 0);
        container.graphics.lineTo(394, 418);
        
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 15;
        
        /// Col 1
        //- Speed
        new Text(container, xOff, yOff, _lang.string("options_speed"));
        yOff += 22;
        
        optionGameSpeed = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_FLOAT_P, changeHandler);
        yOff += 30;
        
        //- Receptor Spacing
        new Text(container, xOff, yOff, _lang.string("options_receptor_spacing"));
        yOff += 22;
        
        optionReceptorSpacing = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_INT, changeHandler);
        yOff += 30;
        
        yOff += drawSeperator(container, xOff, 170, yOff, 2, 4);
        
        //- Global Offset
        new Text(container, xOff, yOff, _lang.string("options_global_offset"));
        yOff += 22;
        
        optionOffset = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_FLOAT, changeHandler);
        yOff += 30;
        
        //- Visual Delay
        new Text(container, xOff, yOff, "Visual Delay");
        yOff += 22;
        
        optionVisualDelay = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_FLOAT, changeHandler);
        yOff += 30;
        
        //- Judge Offset
        var judgeOffsetText                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_judge_offset"));
        judgeOffsetText.mouseEnabled = true;
        judgeOffsetText.contextMenu = arcJudgeMenu(parent);
        yOff += 22;
        
        optionJudgeOffset = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_FLOAT, changeHandler);
        yOff += 30;
        
        //- Auto Judge Offset
        new Text(container, xOff + 22, yOff, _lang.string("options_auto_judge_offset"));
        
        optionJudgeOffsetAuto = new BoxCheck(container, xOff + 2, yOff + 3, clickHandler);
        optionJudgeOffsetAuto.addEventListener(MouseEvent.MOUSE_OVER, e_autoJudgeMouseOver, false, 0, true);
        yOff += 25;
        
        yOff += drawSeperator(container, xOff, 170, yOff, -4, 5);
        
        // Game Volume
        new Text(container, xOff, yOff, _lang.string("options_volume"));
        yOff += 22;
        
        optionGameVolume = new BoxSlider(container, xOff, yOff, 130, 10, changeHandler);
        optionGameVolume.maxValue = 1.25;
        yOff += 10;
        
        textGameVolume = new Text(container, xOff, yOff, Math.round(_gvars.activeUser.gameVolume * 100) + "%");
        yOff += 30;
        
        // Menu Music Volume
        new Text(container, xOff, yOff, _lang.string("air_options_menu_volume"));
        yOff += 22;
        
        optionMenuVolume = new BoxSlider(container, xOff, yOff, 130, 10, changeHandler);
        optionMenuVolume.maxValue = 1.25;
        yOff += 10;
        
        textMenuVolume = new Text(container, xOff, yOff, Math.round(_gvars.menuMusicSoundVolume * 100) + "%");
        yOff += 30;
        
        /// Col 2
        xOff = 211;
        yOff = 15;
        
        //- Note Scale
        new Text(container, xOff, yOff, _lang.string("options_note_scale"));
        yOff += 22;
        
        optionNoteScale = new BoxSlider(container, xOff, yOff, 130, 10, changeHandler);
        optionNoteScale.minValue = 0.1;
        optionNoteScale.maxValue = 1.5;
        yOff += 10;
        
        textNoteScale = new Text(container, xOff, yOff, Math.round(_gvars.activeUser.noteScale * 100) + "%");
        yOff += 22;
        
        yOff += drawSeperator(container, xOff, 170, yOff, 3, 5);
        
        // Autofail
        optionAutofail = [];
        
        new Text(container, xOff, yOff, _lang.string("options_autofail"));
        yOff += 22;
        
        for (i in 0...judgeTitles.length)
        {
            new Text(container, xOff + 72, yOff + 1, _lang.string("game_" + judgeTitles[i]));
            
            var optionAutofailInput                       : Dynamic= new ValidatedText(container, xOff, yOff, 65, 20, ValidatedText.R_INT_P, changeHandler);
            optionAutofailInput.autofail = judgeTitles[i];
            optionAutofailInput.field.maxChars = 5;
            optionAutofail.push(optionAutofailInput);
            yOff += 25;
        }
        // raw goods aren't a judge title, and is two words - so separate accordingly
        new Text(container, xOff + 72, yOff + 1, _lang.string("game_raw_goods"));
        
        var optionAutofailInput                      : Dynamic= new ValidatedText(container, xOff, yOff, 65, 20, ValidatedText.R_FLOAT_P, changeHandler);
        optionAutofailInput.autofail = "rawGoods";
        optionAutofailInput.field.maxChars = 6;
        optionAutofail.push(optionAutofailInput);
        yOff += 25;
        
        // AAA Equiv autofail
        new Text(container, xOff + 72, yOff + 1, _lang.string("options_autofail_equiv"));
        
        optionAutofailEquivInput = new ValidatedText(container, xOff, yOff, 65, 20, ValidatedText.R_FLOAT_P, changeHandler);
        optionAutofailEquivInput.autofail = "aaaEquiv";
        optionAutofailEquivInput.field.maxChars = 6;
        optionAutofail.push(optionAutofailEquivInput);
        optionAutofailEquivInput.addEventListener(MouseEvent.MOUSE_OVER, e_autofailEquivMouseOver, false, 0, true);
        
        if (as3hx.Compat.truthy(_avars.configLegacy != null))
        {
            optionAutofailEquivInput.alpha = 0.5;
            optionAutofailEquivInput.selectable = false;
        }
        
        yOff += 34;
        
        // Autofail Restart
        new Text(container, xOff + 22, yOff - 4, _lang.string("options_autofail_restart"));
        
        optionAutofailRestart = new BoxCheck(container, xOff, yOff, clickHandler);
        yOff += 25;
        
        // Personal Best Mode
        new Text(container, xOff + 22, yOff - 4, _lang.string("options_personalbest_mode"));
        
        optionPersonalBestMode = new BoxCheck(container, xOff, yOff, clickHandler);
        optionPersonalBestMode.addEventListener(MouseEvent.MOUSE_OVER, e_personalBestModeMouseOver, false, 0, true);
        yOff += 25;
        
        /// Col 3
        xOff = 407;
        yOff = 15;
        
        //- Direction
        optionScrollDirections = [];
        
        new Text(container, xOff, yOff, _lang.string("options_scroll"));
        yOff += 20;
        
        var directionData                       : Dynamic= _gvars.SCROLL_DIRECTIONS;
        for (i in 0...directionData.length)
        {
            new Text(container, xOff + 22, yOff - 1, _lang.string("options_scroll_" + directionData[i]));
            
            var optionScrollCheck                       : Dynamic= new BoxCheck(container, xOff + 2, yOff + 3, clickHandler);
            optionScrollCheck.slideDirection = directionData[i];
            optionScrollDirections.push(optionScrollCheck);
            yOff += 21;
        }
        
        yOff += drawSeperator(container, xOff, 170, yOff, 5, 6);
        
        // Mirror Mod
        new Text(container, xOff + 22, yOff - 1, _lang.string("options_mod_mirror"));
        
        optionMirrorMod = new BoxCheck(container, xOff + 2, yOff + 3, clickHandler);
        optionMirrorMod.visual_mod = "mirror";
        yOff += 25;
        
        yOff += drawSeperator(container, xOff, 170, yOff, 1);
        
        // Song Rate
        new Text(container, xOff, yOff, _lang.string("options_rate"));
        yOff += 22;
        
        optionRate = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_FLOAT_P, changeHandler);
        yOff += 30;
        
        //- Isolation
        new Text(container, xOff, yOff, _lang.string("options_isolation_start"));
        yOff += 22;
        
        optionIsolation = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_INT_P, changeHandler);
        yOff += 30;
        
        new Text(container, xOff, yOff, _lang.string("options_isolation_notes"));
        yOff += 22;
        
        optionIsolationTotal = new ValidatedText(container, xOff, yOff, 130, 20, ValidatedText.R_INT_P, changeHandler);
        yOff += 30;
        
        // set Text class max width
        setTextMaxWidth(166);
    }
    
    override public function setValues() : Void
    {
        var i                       : Dynamic= null;
        var item                       : Dynamic= null;
        
        // Set Speed
        optionGameSpeed.text = Std.string(_gvars.activeUser.gameSpeed);
        
        // Set Scroll
        for (item in as3hx.Compat.iter(optionScrollDirections))
        {
            item.checked = (_gvars.activeUser.slideDirection == item.slideDirection);
        }
        
        // Set Offset
        optionOffset.text = Std.string(_gvars.activeUser.GLOBAL_OFFSET);
        
        // Set Visual Delay
        optionVisualDelay.text = Std.string(_gvars.activeUser.VISUAL_DELAY);
        
        // Set Judge Offset
        optionJudgeOffset.text = Std.string(_gvars.activeUser.JUDGE_OFFSET);
        
        // Set Auto Judge Offset
        optionJudgeOffsetAuto.checked = _gvars.activeUser.AUTO_JUDGE_OFFSET;
        optionJudgeOffset.selectable = !_gvars.activeUser.AUTO_JUDGE_OFFSET;
        optionJudgeOffset.alpha = (_gvars.activeUser.AUTO_JUDGE_OFFSET) ? 0.55 : 1.0;
        
        // Set Receptor Spacing
        optionReceptorSpacing.text = Std.string(_gvars.activeUser.receptorGap);
        
        // Set Note Scale
        optionNoteScale.slideValue = _gvars.activeUser.noteScale;
        
        // Set Volume
        optionGameVolume.slideValue = _gvars.activeUser.gameVolume;
        
        // Set Menu Volume
        optionMenuVolume.slideValue = _gvars.menuMusicSoundVolume;
        
        // Set Song Rate
        optionRate.text = Std.string(_gvars.activeUser.songRate);
        
        // Mirror Mod
        optionMirrorMod.checked = (_gvars.activeUser.activeVisualMods.indexOf(optionMirrorMod.visual_mod) != -1);
        
        // Set Autofails
        for (item in as3hx.Compat.iter(optionAutofail))
        {
            item.text = as3hx.Compat.field(_gvars.activeUser, "autofail" + StringUtil.upperCase(item.autofail));
        }
        
        // Autofail Restart
        optionAutofailRestart.checked = _gvars.activeUser.autofailRestart;
        
        // Personal Best Mode
        optionPersonalBestMode.checked = _gvars.activeUser.personalBestMode;
        
        optionIsolation.text = Std.string(_avars.configIsolationStart + 1);
        optionIsolationTotal.text = Std.string(_avars.configIsolationLength);
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    {
        var item                       : Dynamic= null;
        
        if (as3hx.Compat.truthy(e.target == optionJudgeOffsetAuto))
        {
            _gvars.activeUser.AUTO_JUDGE_OFFSET = !_gvars.activeUser.AUTO_JUDGE_OFFSET;
            optionJudgeOffset.selectable = !_gvars.activeUser.AUTO_JUDGE_OFFSET;
            optionJudgeOffset.alpha = (_gvars.activeUser.AUTO_JUDGE_OFFSET) ? 0.55 : 1.0;
            optionJudgeOffsetAuto.checked = _gvars.activeUser.AUTO_JUDGE_OFFSET;
        }
        else if (as3hx.Compat.truthy(e.target == optionAutofailRestart))
        {
            _gvars.activeUser.autofailRestart = !_gvars.activeUser.autofailRestart;
            optionAutofailRestart.checked = _gvars.activeUser.autofailRestart;
        }
        else if (as3hx.Compat.truthy(e.target == optionPersonalBestMode))
        {
            _gvars.activeUser.personalBestMode = !_gvars.activeUser.personalBestMode;
            optionPersonalBestMode.checked = _gvars.activeUser.personalBestMode;
        }
        else if (as3hx.Compat.truthy(e.target.exists("slideDirection")))
        {
            var dir                       : Dynamic= e.target.slideDirection;
            _gvars.activeUser.slideDirection = dir;
            
            for (item in as3hx.Compat.iter(optionScrollDirections))
            {
                item.checked = (_gvars.activeUser.slideDirection == item.slideDirection);
            }
        }
        else if (as3hx.Compat.truthy(e.target == optionMirrorMod))
        {
            var visual_mod                       : Dynamic= optionMirrorMod.visual_mod;
            if (as3hx.Compat.truthy(_gvars.activeUser.activeVisualMods.indexOf(visual_mod) != -1))
            {
                ArrayUtil.removeValue(visual_mod, _gvars.activeUser.activeVisualMods);
            }
            else
            {
                _gvars.activeUser.activeVisualMods.push(visual_mod);
            }
            optionMirrorMod.checked = !optionMirrorMod.checked;
        }
        
        parent.checkValidMods();
    }
    
    override public function changeHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == optionGameSpeed))
        {
            _gvars.activeUser.gameSpeed = optionGameSpeed.validate(1, 0.1);
        }
        else if (as3hx.Compat.truthy(e.target == optionOffset))
        {
            _gvars.activeUser.GLOBAL_OFFSET = optionOffset.validate(0);
        }
        else if (as3hx.Compat.truthy(e.target == optionVisualDelay))
        {
            _gvars.activeUser.VISUAL_DELAY = optionVisualDelay.validate(0);
        }
        else if (as3hx.Compat.truthy(e.target == optionJudgeOffset))
        {
            _gvars.activeUser.JUDGE_OFFSET = optionJudgeOffset.validate(0);
        }
        else if (as3hx.Compat.truthy(e.target == optionReceptorSpacing))
        {
            _gvars.activeUser.receptorGap = optionReceptorSpacing.validate(80);
        }
        else if (as3hx.Compat.truthy(e.target == optionNoteScale))
        {
            var sliderValue                       : Dynamic= Math.round(Math.max(Math.min(optionNoteScale.slideValue, optionNoteScale.maxValue), optionNoteScale.minValue) * 100);
            
            // Snap to larger value when close.
            var snapTarget                       : Dynamic= 25;
            var snapValue                       : Dynamic= as3hx.Compat.parseInt(sliderValue % snapTarget);
            if (as3hx.Compat.truthy(snapValue == 1 || snapValue == snapTarget - 1))
            {
                sliderValue = as3hx.Compat.parseInt(Math.round(sliderValue / snapTarget) * snapTarget);
            }
            
            _gvars.activeUser.noteScale = sliderValue / 100;
            textNoteScale.text = sliderValue + "%";
        }
        else if (as3hx.Compat.truthy(e.target == optionGameVolume))
        {
            _gvars.activeUser.gameVolume = optionGameVolume.slideValue;
            textGameVolume.text = Math.round(_gvars.activeUser.gameVolume * 100) + "%";
        }
        else if (as3hx.Compat.truthy(e.target == optionRate))
        {
            var newSongRate                       : Dynamic= optionRate.validate(1, 0.1);
            newSongRate = Math.max(0.1, Math.min(200, Math.round(newSongRate * 1000) / 1000));
            if (as3hx.Compat.truthy(Math.isNaN(newSongRate) || !Math.isFinite(newSongRate)))
            {
                newSongRate = 1;
            }
            
            _gvars.activeUser.songRate = newSongRate;
            _gvars.dirtySongFiles();
            
            // MP Update
            _mp.ffrUpdateRate();
        }
        else if (as3hx.Compat.truthy(e.target == optionIsolation))
        {
            _avars.configIsolationStart = optionIsolation.validate(1, 1) - 1;
            _avars.configIsolation = as3hx.Compat.orValue(_avars.configIsolationStart > 0, _avars.configIsolationLength > 0);
        }
        else if (as3hx.Compat.truthy(e.target == optionIsolationTotal))
        {
            _avars.configIsolationLength = optionIsolationTotal.validate(0);
            _avars.configIsolation = as3hx.Compat.orValue(_avars.configIsolationStart > 0, _avars.configIsolationLength > 0);
        }
        else if (as3hx.Compat.truthy(e.target == optionMenuVolume))
        {
            _gvars.menuMusicSoundVolume = optionMenuVolume.slideValue;
            if (as3hx.Compat.truthy(Math.isNaN(_gvars.menuMusicSoundVolume)))
            {
                _gvars.menuMusicSoundVolume = 1;
            }
            _gvars.menuMusicSoundVolume = Math.max(Math.min(_gvars.menuMusicSoundVolume, optionMenuVolume.maxValue), optionMenuVolume.minValue);
            textMenuVolume.text = Math.round(_gvars.menuMusicSoundVolume * 100) + "%";
            _gvars.menuMusicSoundTransform.volume = _gvars.menuMusicSoundVolume;
            
            if (as3hx.Compat.truthy(_gvars.menuMusic && _gvars.menuMusic.isPlaying))
            {
                _gvars.menuMusic.soundChannel.soundTransform = _gvars.menuMusicSoundTransform;
            }
        }
        else if (as3hx.Compat.truthy(e.target.exists("autofail")))
        {
            var autofail                       : Dynamic= StringUtil.upperCase(e.target.autofail);
            Reflect.setField(_gvars.activeUser, "autofail" + autofail, e.target.validate(0, 0));
        }
        
        parent.checkValidMods();
    }
    
    private function e_autoJudgeMouseOver(e                       : Dynamic) : Void
    {
        optionJudgeOffsetAuto.addEventListener(MouseEvent.MOUSE_OUT, e_autoJudgeMouseOut);
        displayToolTip(optionJudgeOffsetAuto.x, optionJudgeOffsetAuto.y + 25, _lang.string("popup_auto_judge_offset"));
    }
    
    private function e_autoJudgeMouseOut(e                       : Dynamic) : Void
    {
        optionJudgeOffsetAuto.removeEventListener(MouseEvent.MOUSE_OUT, e_autoJudgeMouseOut);
        hideTooltip();
    }
    
    private function e_personalBestModeMouseOver(e                       : Dynamic) : Void
    {
        optionPersonalBestMode.addEventListener(MouseEvent.MOUSE_OUT, e_personalBestModeMouseOut);
        displayToolTip(optionPersonalBestMode.x, optionPersonalBestMode.y - 45, _lang.string("popup_personalbest_mode"));
    }
    
    private function e_personalBestModeMouseOut(e                       : Dynamic) : Void
    {
        optionPersonalBestMode.removeEventListener(MouseEvent.MOUSE_OUT, e_personalBestModeMouseOut);
        hideTooltip();
    }
    
    private function e_autofailEquivMouseOver(e                       : Dynamic) : Void
    {
        optionAutofailEquivInput.addEventListener(MouseEvent.MOUSE_OUT, e_autofailEquivMouseOut);
        
        if (as3hx.Compat.truthy(_avars.configLegacy != null))
        {
            displayToolTip(optionAutofailEquivInput.x + 65, optionAutofailEquivInput.y - 45, _lang.string("popup_autofail_equiv") + " " + _lang.string("altengine_setting_ignored"));
        }
        else
        {
            displayToolTip(optionAutofailEquivInput.x + 65, optionAutofailEquivInput.y - 45, _lang.string("popup_autofail_equiv"));
        }
    }
    
    private function e_autofailEquivMouseOut(e                       : Dynamic) : Void
    {
        optionAutofailEquivInput.removeEventListener(MouseEvent.MOUSE_OUT, e_autofailEquivMouseOut);
        hideTooltip();
    }
    
    private function arcJudgeMenu(parent                       : Dynamic) : ContextMenu
    {
        var judgeMenu                       : Dynamic= new ContextMenu();
        var judgeItem                       : Dynamic= new ContextMenuItem("Custom Judge Windows");
        judgeItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(event                       : Dynamic) : Void
                {
                    new PromptInput(parent, "Judge Window", "SUBMIT", e_changeJudgeWindow);
                });
        judgeMenu.customItems.push(judgeItem);
        return judgeMenu;
    }
    
    private function e_changeJudgeWindow(judgeWindow                       : Dynamic) : Void
    {
        _avars.configJudge = null;
        var judge                       : Dynamic= null;
        for (item/* AS3HX WARNING could not determine type for var: item exp: ECall(EField(EIdent(judgeWindow),split),[EConst(CString(:))]) type: null */ in as3hx.Compat.iter(judgeWindow.split(":")))
        {
            if (as3hx.Compat.truthy(judge == null))
            {
                judge = new Array<Dynamic>();
            }
            var items                       : Dynamic= item.split(",");
            if (as3hx.Compat.truthy(items.length != 2))
            {
                judge = null;
                break;
            }
            judge.push({
                        t : as3hx.Compat.parseInt(items[0]),
                        s : as3hx.Compat.parseInt(items[1])
                    });
        }
        
        _avars.configJudge = judge;
        
        if (as3hx.Compat.truthy(judge != null))
        {
            Alert.add(_lang.string("judge_window_set"));
        }
        else
        {
            Alert.add(_lang.string("judge_window_cleared"));
        }
    }
}

