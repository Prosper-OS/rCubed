package popups.settings;

import classes.Language;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.BoxText;
import classes.ui.ColorField;
import classes.ui.Text;
import classes.ui.ValidatedText;
import com.flashfla.utils.ColorUtil;
import com.flashfla.utils.StringUtil;
import openfl.events.Event;
import openfl.events.MouseEvent;

class SettingsTabColors extends SettingsTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var optionJudgeColors                       : Dynamic;
    private var optionComboColors                       : Dynamic;
    private var optionComboColorCheck                       : Dynamic;
    private var optionReceptorColors                       : Dynamic;
    private var optionReceptorColorCheck                       : Dynamic;
    private var optionGameColors                       : Dynamic;
    private var optionRawGoodTracker                       : Dynamic;
    private var optionRawGoodsColor                       : Dynamic;
    private var optionPersonalBestTracker                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "colors";
    }
    
    override public function openTab() : Void
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(295, 10);
        container.graphics.lineTo(295, 675);
        
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 10;
        
        /// Col 1
        var gameJudgeColorTitle                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_judge_colors_title"), 14);
        gameJudgeColorTitle.width = 265;
        gameJudgeColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionJudgeColors = [];
        for (i in 0...judgeTitles.length)
        {
            var gameJudgeColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("game_" + judgeTitles[i]));
            gameJudgeColor.width = 115;
            
            var optionJudgeColor                       : Dynamic= new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionJudgeColor.judge_color_id = i;
            optionJudgeColor.field.maxChars = 7;
            
            var gameJudgeColorDisplay                       : Dynamic= new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
            gameJudgeColorDisplay.key_name = "optionJudgeColor";
            
            var optionJudgeColorReset                       : Dynamic= new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
            optionJudgeColorReset.judge_color_reset_id = i;
            optionJudgeColorReset.color = 0xff0000;
            optionJudgeColors.push({
                        text : optionJudgeColor,
                        display : gameJudgeColorDisplay,
                        reset : optionJudgeColorReset
                    });
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        }
        
        var gameRawGoodsColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("game_raw_goods"));
        gameRawGoodsColor.width = 115;
        
        var optionRawGoodsColor                       : Dynamic= new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
        optionRawGoodsColor.rawgoods_color_id = 1;
        optionRawGoodsColor.field.maxChars = 7;
        
        var gameRawGoodsColorDisplay                       : Dynamic= new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
        gameRawGoodsColorDisplay.key_name = "optionRawGoodsColor";
        
        var optionRawGoodsColorReset                       : Dynamic= new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
        optionRawGoodsColorReset.rawgoods_color_reset_id = 1;
        optionRawGoodsColorReset.color = 0xDC00C2;
        optionJudgeColors.push({
                    text : optionRawGoodsColor,
                    display : gameRawGoodsColorDisplay,
                    reset : optionRawGoodsColorReset
                });
        
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        yOff += 5;
        
        var gameGameColorTitle                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_game_colors_title"), 14);
        gameGameColorTitle.width = 265;
        gameGameColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionGameColors = [];
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.gameColors.length)
        {
            if (as3hx.Compat.truthy(i == 2 || i == 3))
            {
                optionGameColors.push(null);
                continue;
            }
            
            var gameGameColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_game_colors_" + i));
            gameGameColor.width = 115;
            
            var optionGameColor                       : Dynamic= new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionGameColor.game_color_id = i;
            optionGameColor.field.maxChars = 7;
            
            var gameGameColorDisplay                       : Dynamic= new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
            gameGameColorDisplay.key_name = "gameGameColorDisplay";
            
            var optionGameColorReset                       : Dynamic= new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
            optionGameColorReset.game_color_reset_id = i;
            optionGameColorReset.color = 0xff0000;
            optionGameColors.push({
                        text : optionGameColor,
                        display : gameGameColorDisplay,
                        reset : optionGameColorReset
                    });
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        }
        
        /// Col 2
        xOff = 310;
        yOff = 10;
        
        var gameComboColorTitle                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_combo_colors_title"), 14);
        gameComboColorTitle.width = 265;
        gameComboColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionComboColors = [];
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.comboColors.length)
        {
            var gameComboColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_combo_colors_" + i));
            gameComboColor.width = 95;
            
            var optionComboColor                       : Dynamic= new ValidatedText(container, xOff + 100, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionComboColor.combo_color_id = i;
            optionComboColor.field.maxChars = 7;
            
            var gameComboColorDisplay                       : Dynamic= new ColorField(container, xOff + 175, yOff, 0, 45, 21, changeHandler);
            gameComboColorDisplay.key_name = "gameComboColorDisplay";
            
            var optionComboColorReset                       : Dynamic= new BoxButton(container, xOff + 225, yOff, 20, 21, "R", 12, clickHandler);
            optionComboColorReset.combo_color_reset_id = i;
            optionComboColorReset.color = 0xff0000;
            
            if (as3hx.Compat.truthy(i > 0))
            {
                optionComboColorCheck = new BoxCheck(container, xOff + 250, yOff + 3, clickHandler);
                optionComboColorCheck.combo_color_enable_id = i;
            }
            
            optionComboColors.push({
                        text : optionComboColor,
                        display : gameComboColorDisplay,
                        reset : optionComboColorReset,
                        enable : optionComboColorCheck
                    });
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 265, yOff, -3, -4);
        }
        
        var gameRawGoodTracker                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_raw_goods_tracker"));
        gameRawGoodTracker.width = 144;
        optionRawGoodTracker = new ValidatedText(container, xOff + 149, yOff, 70, 20, ValidatedText.R_FLOAT_P, changeHandler);
        yOff += 32;
        
        // Personal Best tracking via Combo color
        new Text(container, xOff + 24, yOff - 3, _lang.string("options_personalbest_tracker"));
        
        optionPersonalBestTracker = new BoxCheck(container, xOff + 4, yOff, clickHandler);
        optionPersonalBestTracker.addEventListener(MouseEvent.MOUSE_OVER, e_personalBestTrackerMouseOver, false, 0, true);
        
        // Receptor Colors
        yOff += 28;
        yOff += drawSeperator(container, xOff, 265, yOff, -3, -4);
        yOff += 30;
        
        var gameReceptorColorTitle                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_receptor_colors_title"), 14);
        gameReceptorColorTitle.width = 265;
        gameReceptorColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionReceptorColors = [];
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.receptorColors.length)
        {
            var gameReceptorColor                       : Dynamic= new Text(container, xOff, yOff, _lang.string("options_receptor_colors_" + i));
            gameReceptorColor.width = 95;
            
            var optionReceptorColor                       : Dynamic= new ValidatedText(container, xOff + 100, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionReceptorColor.receptor_color_id = i;
            optionReceptorColor.field.maxChars = 7;
            
            var gameReceptorColorDisplay                       : Dynamic= new ColorField(container, xOff + 175, yOff, 0, 45, 21, changeHandler);
            gameReceptorColorDisplay.key_name = "gameReceptorColorDisplay";
            
            var optionReceptorColorReset                       : Dynamic= new BoxButton(container, xOff + 225, yOff, 20, 21, "R", 12, clickHandler);
            optionReceptorColorReset.receptor_color_reset_id = i;
            optionReceptorColorReset.color = 0xff0000;
            
            optionReceptorColorCheck = new BoxCheck(container, xOff + 250, yOff + 3, clickHandler);
            optionReceptorColorCheck.receptor_color_enable_id = i;
            optionReceptorColors.push({
                        text : optionReceptorColor,
                        display : gameReceptorColorDisplay,
                        reset : optionReceptorColorReset,
                        enable : optionReceptorColorCheck
                    });
            
            yOff += 20;
            yOff += drawSeperator(container, xOff, 265, yOff, -3, -4);
        }
    }
    
    override public function setValues() : Void
    {
        var i                       : Dynamic= null;
        
        // Set Judge Colors
        for (i in 0...judgeTitles.length)
        {
            Reflect.field(optionJudgeColors[i], "text").text = "#" + StringUtil.pad(Std.string(_gvars.activeUser.judgeColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
            Reflect.field(optionJudgeColors[i], "display").color = _gvars.activeUser.judgeColors[i];
        }
        
        // Set Raw Goods Display Color
        Reflect.field(optionJudgeColors[judgeTitles.length], "text").text = "#" + StringUtil.pad(Std.string(_gvars.activeUser.rawGoodsColor).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
        Reflect.field(optionJudgeColors[judgeTitles.length], "display").color = _gvars.activeUser.rawGoodsColor;
        
        // Set Combo Colors
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.comboColors.length)
        {
            Reflect.field(optionComboColors[i], "text").text = "#" + StringUtil.pad(Std.string(_gvars.activeUser.comboColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
            Reflect.field(optionComboColors[i], "display").color = _gvars.activeUser.comboColors[i];
            if (as3hx.Compat.truthy(i > 0))
            {
                Reflect.field(optionComboColors[i], "enable").checked = (_gvars.activeUser.enableComboColors[i]);
            }
        }
        
        // Set Receptor Colors
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.receptorColors.length)
        {
            Reflect.field(optionReceptorColors[i], "text").text = "#" + StringUtil.pad(Std.string(_gvars.activeUser.receptorColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
            Reflect.field(optionReceptorColors[i], "display").color = _gvars.activeUser.receptorColors[i];
            Reflect.field(optionReceptorColors[i], "enable").checked = (_gvars.activeUser.enableReceptorColors[i]);
        }
        
        // Set Raw Good Tracker
        optionRawGoodTracker.text = Std.string(_gvars.activeUser.rawGoodTracker);
        
        // Personal Best Mode
        optionPersonalBestTracker.checked = _gvars.activeUser.personalBestTracker;
        
        // Set Game Colors
        for (i in 0...SettingsTabBase.DEFAULT_OPTIONS.gameColors.length)
        {
            if (as3hx.Compat.truthy(i == 2 || i == 3))
            {
                continue;
            }
            
            Reflect.field(optionGameColors[i], "text").text = "#" + StringUtil.pad(Std.string(_gvars.activeUser.gameColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
            Reflect.field(optionGameColors[i], "display").color = _gvars.activeUser.gameColors[i];
        }
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    // Judge Color Reset
    {
        
        if (as3hx.Compat.truthy(e.target.exists("judge_color_reset_id")))
        {
            _gvars.activeUser.judgeColors[e.target.judge_color_reset_id] = SettingsTabBase.DEFAULT_OPTIONS.judgeColors[e.target.judge_color_reset_id];
            setValues();
        }
        
        // Raw Goods Color Reset
        if (as3hx.Compat.truthy(e.target.exists("rawgoods_color_reset_id")))
        {
            _gvars.activeUser.rawGoodsColor = SettingsTabBase.DEFAULT_OPTIONS.rawGoodsColor;
            setValues();
        }
        // Combo Color Reset
        else if (as3hx.Compat.truthy(e.target.exists("combo_color_reset_id")))
        {
            _gvars.activeUser.comboColors[e.target.combo_color_reset_id] = SettingsTabBase.DEFAULT_OPTIONS.comboColors[e.target.combo_color_reset_id];
            setValues();
        }
        // Combo Color Enable/Disable
        else if (as3hx.Compat.truthy(e.target.exists("combo_color_enable_id")))
        {
            _gvars.activeUser.enableComboColors[e.target.combo_color_enable_id] = !_gvars.activeUser.enableComboColors[e.target.combo_color_enable_id];
            e.target.checked = !e.target.checked;
        }
        // Receptor Color Reset
        else if (as3hx.Compat.truthy(e.target.exists("receptor_color_reset_id")))
        {
            _gvars.activeUser.receptorColors[e.target.receptor_color_reset_id] = SettingsTabBase.DEFAULT_OPTIONS.receptorColors[e.target.receptor_color_reset_id];
            setValues();
        }
        // Receptor Color Enable/Disable
        else if (as3hx.Compat.truthy(e.target.exists("receptor_color_enable_id")))
        {
            _gvars.activeUser.enableReceptorColors[e.target.receptor_color_enable_id] = !_gvars.activeUser.enableReceptorColors[e.target.receptor_color_enable_id];
            e.target.checked = !e.target.checked;
        }
        else if (as3hx.Compat.truthy(e.target == optionPersonalBestTracker))
        {
            _gvars.activeUser.personalBestTracker = !_gvars.activeUser.personalBestTracker;
            optionPersonalBestTracker.checked = _gvars.activeUser.personalBestTracker;
            optionRawGoodTracker.selectable = !_gvars.activeUser.personalBestTracker;
            
            if (as3hx.Compat.truthy(_gvars.activeUser.personalBestTracker))
            {
                optionRawGoodTracker.alpha = 0.4;
            }
            else
            {
                optionRawGoodTracker.alpha = 1;
            }
        }
        // Game Background Color Reset
        else if (as3hx.Compat.truthy(e.target.exists("game_color_reset_id")))
        {
            var gid                       : Dynamic= e.target.game_color_reset_id;
            _gvars.activeUser.gameColors[gid] = SettingsTabBase.DEFAULT_OPTIONS.gameColors[gid];
            
            if (as3hx.Compat.truthy(gid == 0))
            {
                _gvars.activeUser.gameColors[2] = ColorUtil.darkenColor(SettingsTabBase.DEFAULT_OPTIONS.gameColors[gid], 0.27);
            }
            if (as3hx.Compat.truthy(gid == 1))
            {
                _gvars.activeUser.gameColors[3] = ColorUtil.brightenColor(SettingsTabBase.DEFAULT_OPTIONS.gameColors[gid], 0.08);
            }
            
            setValues();
        }
    }
    
    private function e_personalBestTrackerMouseOver(e                       : Dynamic) : Void
    {
        optionPersonalBestTracker.addEventListener(MouseEvent.MOUSE_OUT, e_personalBestTrackerMouseOut);
        displayToolTip(optionPersonalBestTracker.x, optionPersonalBestTracker.y - 45, _lang.string("popup_personalbest_tracker"));
    }
    
    private function e_personalBestTrackerMouseOut(e                       : Dynamic) : Void
    {
        optionPersonalBestTracker.removeEventListener(MouseEvent.MOUSE_OUT, e_personalBestTrackerMouseOut);
        hideTooltip();
    }
    
    override public function changeHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == optionRawGoodTracker))
        {
            _gvars.activeUser.rawGoodTracker = optionRawGoodTracker.validate(0, 0);
        }
        else if (as3hx.Compat.truthy(e.target.exists("judge_color_id")))
        {
            var jid                       : Dynamic= e.target.judge_color_id;
            _gvars.activeUser.judgeColors[jid] = e.target.validate(0, 0);
            Reflect.field(optionJudgeColors[jid], "display").color = _gvars.activeUser.judgeColors[jid];
        }
        else if (as3hx.Compat.truthy(e.target.exists("rawgoods_color_id")))
        {
            _gvars.activeUser.rawGoodsColor = e.target.validate(0, 0);
            Reflect.field(optionJudgeColors[judgeTitles.length], "display").color = _gvars.activeUser.rawGoodsColor;
        }
        else if (as3hx.Compat.truthy(e.target.exists("combo_color_id")))
        {
            var cid                       : Dynamic= e.target.combo_color_id;
            _gvars.activeUser.comboColors[cid] = e.target.validate(0, 0);
            Reflect.field(optionComboColors[cid], "display").color = _gvars.activeUser.comboColors[cid];
        }
        else if (as3hx.Compat.truthy(e.target.exists("receptor_color_id")))
        {
            var rid                       : Dynamic= e.target.receptor_color_id;
            _gvars.activeUser.receptorColors[rid] = e.target.validate(0, 0);
            Reflect.field(optionReceptorColors[rid], "display").color = _gvars.activeUser.receptorColors[rid];
        }
        else if (as3hx.Compat.truthy(e.target.exists("game_color_id")))
        {
            var gid                       : Dynamic= e.target.game_color_id;
            var newColorG                       : Dynamic= e.target.validate(0, 0);
            _gvars.activeUser.gameColors[gid] = newColorG;
            
            if (as3hx.Compat.truthy(gid == 0))
            {
                _gvars.activeUser.gameColors[2] = ColorUtil.darkenColor(newColorG, 0.27);
            }
            if (as3hx.Compat.truthy(gid == 1))
            {
                _gvars.activeUser.gameColors[3] = ColorUtil.brightenColor(newColorG, 0.08);
            }
            
            Reflect.field(optionGameColors[gid], "display").color = _gvars.activeUser.gameColors[gid];
        }
        else if (as3hx.Compat.truthy(Std.is(e.target, ColorField)))
        {
            var sourceArray                       : Dynamic= null;
            var _sw0_ = (e.target.key_name);            

            switch (_sw0_)
            {
                case "optionJudgeColor":
                    sourceArray = optionJudgeColors;
                case "optionRawGoodsColor":
                    sourceArray = optionJudgeColors;
                case "gameComboColorDisplay":
                    sourceArray = optionComboColors;
                case "gameReceptorColorDisplay":
                    sourceArray = optionReceptorColors;
                case "gameGameColorDisplay":
                    sourceArray = optionGameColors;
            }
            for (item in as3hx.Compat.iter(sourceArray))
            {
                if (as3hx.Compat.truthy(item != null && item.display == e.target))
                {
                    (try cast(item.text, BoxText) catch(e:Dynamic) null).text = "#" + StringUtil.pad(Std.string((try cast(e.target, ColorField) catch(e:Dynamic) null).color).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
                    (try cast(item.text, BoxText) catch(e:Dynamic) null).dispatchEvent(new Event(Event.CHANGE));
                }
            }
        }
    }
}

