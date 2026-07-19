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
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    private var optionJudgeColors : Array<Dynamic>;
    private var optionComboColors : Array<Dynamic>;
    private var optionComboColorCheck : BoxCheck;
    private var optionReceptorColors : Array<Dynamic>;
    private var optionReceptorColorCheck : BoxCheck;
    private var optionGameColors : Array<Dynamic>;
    private var optionRawGoodTracker : ValidatedText;
    private var optionRawGoodsColor : String;
    private var optionPersonalBestTracker : BoxCheck;
    
    public function new(settingsWindow : SettingsWindow)
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
        
        var i : Int;
        var xOff : Int = 15;
        var yOff : Int = 10;
        
        /// Col 1
        var gameJudgeColorTitle : Text = new Text(container, xOff, yOff, _lang.string("options_judge_colors_title"), 14);
        gameJudgeColorTitle.width = 265;
        gameJudgeColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionJudgeColors = [];
        for (i in 0...judgeTitles.length)
        {
            var gameJudgeColor : Text = new Text(container, xOff, yOff, _lang.string("game_" + judgeTitles[i]));
            gameJudgeColor.width = 115;
            
            var optionJudgeColor : ValidatedText = new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionJudgeColor.judge_color_id = i;
            optionJudgeColor.field.maxChars = 7;
            
            var gameJudgeColorDisplay : ColorField = new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
            gameJudgeColorDisplay.key_name = "optionJudgeColor";
            
            var optionJudgeColorReset : BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
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
        
        var gameRawGoodsColor : Text = new Text(container, xOff, yOff, _lang.string("game_raw_goods"));
        gameRawGoodsColor.width = 115;
        
        var optionRawGoodsColor : ValidatedText = new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
        optionRawGoodsColor.rawgoods_color_id = 1;
        optionRawGoodsColor.field.maxChars = 7;
        
        var gameRawGoodsColorDisplay : ColorField = new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
        gameRawGoodsColorDisplay.key_name = "optionRawGoodsColor";
        
        var optionRawGoodsColorReset : BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
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
        
        var gameGameColorTitle : Text = new Text(container, xOff, yOff, _lang.string("options_game_colors_title"), 14);
        gameGameColorTitle.width = 265;
        gameGameColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionGameColors = [];
        for (i in 0...DEFAULT_OPTIONS.gameColors.length)
        {
            if (i == 2 || i == 3)
            {
                optionGameColors.push(null);
                continue;
            }
            
            var gameGameColor : Text = new Text(container, xOff, yOff, _lang.string("options_game_colors_" + i));
            gameGameColor.width = 115;
            
            var optionGameColor : ValidatedText = new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionGameColor.game_color_id = i;
            optionGameColor.field.maxChars = 7;
            
            var gameGameColorDisplay : ColorField = new ColorField(container, xOff + 195, yOff, 0, 45, 21, changeHandler);
            gameGameColorDisplay.key_name = "gameGameColorDisplay";
            
            var optionGameColorReset : BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, clickHandler);
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
        
        var gameComboColorTitle : Text = new Text(container, xOff, yOff, _lang.string("options_combo_colors_title"), 14);
        gameComboColorTitle.width = 265;
        gameComboColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionComboColors = [];
        for (i in 0...DEFAULT_OPTIONS.comboColors.length)
        {
            var gameComboColor : Text = new Text(container, xOff, yOff, _lang.string("options_combo_colors_" + i));
            gameComboColor.width = 95;
            
            var optionComboColor : ValidatedText = new ValidatedText(container, xOff + 100, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionComboColor.combo_color_id = i;
            optionComboColor.field.maxChars = 7;
            
            var gameComboColorDisplay : ColorField = new ColorField(container, xOff + 175, yOff, 0, 45, 21, changeHandler);
            gameComboColorDisplay.key_name = "gameComboColorDisplay";
            
            var optionComboColorReset : BoxButton = new BoxButton(container, xOff + 225, yOff, 20, 21, "R", 12, clickHandler);
            optionComboColorReset.combo_color_reset_id = i;
            optionComboColorReset.color = 0xff0000;
            
            if (i > 0)
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
        
        var gameRawGoodTracker : Text = new Text(container, xOff, yOff, _lang.string("options_raw_goods_tracker"));
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
        
        var gameReceptorColorTitle : Text = new Text(container, xOff, yOff, _lang.string("options_receptor_colors_title"), 14);
        gameReceptorColorTitle.width = 265;
        gameReceptorColorTitle.align = Text.CENTER;
        yOff += 20;
        yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
        
        optionReceptorColors = [];
        for (i in 0...DEFAULT_OPTIONS.receptorColors.length)
        {
            var gameReceptorColor : Text = new Text(container, xOff, yOff, _lang.string("options_receptor_colors_" + i));
            gameReceptorColor.width = 95;
            
            var optionReceptorColor : ValidatedText = new ValidatedText(container, xOff + 100, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
            optionReceptorColor.receptor_color_id = i;
            optionReceptorColor.field.maxChars = 7;
            
            var gameReceptorColorDisplay : ColorField = new ColorField(container, xOff + 175, yOff, 0, 45, 21, changeHandler);
            gameReceptorColorDisplay.key_name = "gameReceptorColorDisplay";
            
            var optionReceptorColorReset : BoxButton = new BoxButton(container, xOff + 225, yOff, 20, 21, "R", 12, clickHandler);
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
        var i : Int;
        
        // Set Judge Colors
        for (i in 0...judgeTitles.length)
        {
            Reflect.setField(optionJudgeColors[i], "text", "#" + StringUtil.pad(Std.string(_gvars.activeUser.judgeColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT)).text;
            Reflect.setField(optionJudgeColors[i], "display", _gvars.activeUser.judgeColors[i]).color;
        }
        
        // Set Raw Goods Display Color
        Reflect.setField(optionJudgeColors[judgeTitles.length], "text", "#" + StringUtil.pad(Std.string(_gvars.activeUser.rawGoodsColor).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT)).text;
        Reflect.setField(optionJudgeColors[judgeTitles.length], "display", _gvars.activeUser.rawGoodsColor).color;
        
        // Set Combo Colors
        for (i in 0...DEFAULT_OPTIONS.comboColors.length)
        {
            Reflect.setField(optionComboColors[i], "text", "#" + StringUtil.pad(Std.string(_gvars.activeUser.comboColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT)).text;
            Reflect.setField(optionComboColors[i], "display", _gvars.activeUser.comboColors[i]).color;
            if (i > 0)
            {
                Reflect.setField(optionComboColors[i], "enable", (_gvars.activeUser.enableComboColors[i])).checked;
            }
        }
        
        // Set Receptor Colors
        for (i in 0...DEFAULT_OPTIONS.receptorColors.length)
        {
            Reflect.setField(optionReceptorColors[i], "text", "#" + StringUtil.pad(Std.string(_gvars.activeUser.receptorColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT)).text;
            Reflect.setField(optionReceptorColors[i], "display", _gvars.activeUser.receptorColors[i]).color;
            Reflect.setField(optionReceptorColors[i], "enable", (_gvars.activeUser.enableReceptorColors[i])).checked;
        }
        
        // Set Raw Good Tracker
        optionRawGoodTracker.text = Std.string(_gvars.activeUser.rawGoodTracker);
        
        // Personal Best Mode
        optionPersonalBestTracker.checked = _gvars.activeUser.personalBestTracker;
        
        // Set Game Colors
        for (i in 0...DEFAULT_OPTIONS.gameColors.length)
        {
            if (i == 2 || i == 3)
            {
                continue;
            }
            
            Reflect.setField(optionGameColors[i], "text", "#" + StringUtil.pad(Std.string(_gvars.activeUser.gameColors[i]).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT)).text;
            Reflect.setField(optionGameColors[i], "display", _gvars.activeUser.gameColors[i]).color;
        }
    }
    
    override public function clickHandler(e : MouseEvent) : Void
    // Judge Color Reset
    {
        
        if (e.target.exists("judge_color_reset_id"))
        {
            _gvars.activeUser.judgeColors[e.target.judge_color_reset_id] = DEFAULT_OPTIONS.judgeColors[e.target.judge_color_reset_id];
            setValues();
        }
        
        // Raw Goods Color Reset
        if (e.target.exists("rawgoods_color_reset_id"))
        {
            _gvars.activeUser.rawGoodsColor = DEFAULT_OPTIONS.rawGoodsColor;
            setValues();
        }
        // Combo Color Reset
        else if (e.target.exists("combo_color_reset_id"))
        {
            _gvars.activeUser.comboColors[e.target.combo_color_reset_id] = DEFAULT_OPTIONS.comboColors[e.target.combo_color_reset_id];
            setValues();
        }
        // Combo Color Enable/Disable
        else if (e.target.exists("combo_color_enable_id"))
        {
            _gvars.activeUser.enableComboColors[e.target.combo_color_enable_id] = !_gvars.activeUser.enableComboColors[e.target.combo_color_enable_id];
            e.target.checked = !e.target.checked;
        }
        // Receptor Color Reset
        else if (e.target.exists("receptor_color_reset_id"))
        {
            _gvars.activeUser.receptorColors[e.target.receptor_color_reset_id] = DEFAULT_OPTIONS.receptorColors[e.target.receptor_color_reset_id];
            setValues();
        }
        // Receptor Color Enable/Disable
        else if (e.target.exists("receptor_color_enable_id"))
        {
            _gvars.activeUser.enableReceptorColors[e.target.receptor_color_enable_id] = !_gvars.activeUser.enableReceptorColors[e.target.receptor_color_enable_id];
            e.target.checked = !e.target.checked;
        }
        else if (e.target == optionPersonalBestTracker)
        {
            _gvars.activeUser.personalBestTracker = !_gvars.activeUser.personalBestTracker;
            optionPersonalBestTracker.checked = _gvars.activeUser.personalBestTracker;
            optionRawGoodTracker.selectable = !_gvars.activeUser.personalBestTracker;
            
            if (_gvars.activeUser.personalBestTracker)
            {
                optionRawGoodTracker.alpha = 0.4;
            }
            else
            {
                optionRawGoodTracker.alpha = 1;
            }
        }
        // Game Background Color Reset
        else if (e.target.exists("game_color_reset_id"))
        {
            var gid : Int = e.target.game_color_reset_id;
            _gvars.activeUser.gameColors[gid] = DEFAULT_OPTIONS.gameColors[gid];
            
            if (gid == 0)
            {
                _gvars.activeUser.gameColors[2] = ColorUtil.darkenColor(DEFAULT_OPTIONS.gameColors[gid], 0.27);
            }
            if (gid == 1)
            {
                _gvars.activeUser.gameColors[3] = ColorUtil.brightenColor(DEFAULT_OPTIONS.gameColors[gid], 0.08);
            }
            
            setValues();
        }
    }
    
    private function e_personalBestTrackerMouseOver(e : Event) : Void
    {
        optionPersonalBestTracker.addEventListener(MouseEvent.MOUSE_OUT, e_personalBestTrackerMouseOut);
        displayToolTip(optionPersonalBestTracker.x, optionPersonalBestTracker.y - 45, _lang.string("popup_personalbest_tracker"));
    }
    
    private function e_personalBestTrackerMouseOut(e : Event) : Void
    {
        optionPersonalBestTracker.removeEventListener(MouseEvent.MOUSE_OUT, e_personalBestTrackerMouseOut);
        hideTooltip();
    }
    
    override public function changeHandler(e : Event) : Void
    {
        if (e.target == optionRawGoodTracker)
        {
            _gvars.activeUser.rawGoodTracker = optionRawGoodTracker.validate(0, 0);
        }
        else if (e.target.exists("judge_color_id"))
        {
            var jid : Int = e.target.judge_color_id;
            _gvars.activeUser.judgeColors[jid] = e.target.validate(0, 0);
            Reflect.setField(optionJudgeColors[jid], "display", _gvars.activeUser.judgeColors[jid]).color;
        }
        else if (e.target.exists("rawgoods_color_id"))
        {
            _gvars.activeUser.rawGoodsColor = e.target.validate(0, 0);
            Reflect.setField(optionJudgeColors[judgeTitles.length], "display", _gvars.activeUser.rawGoodsColor).color;
        }
        else if (e.target.exists("combo_color_id"))
        {
            var cid : Int = e.target.combo_color_id;
            _gvars.activeUser.comboColors[cid] = e.target.validate(0, 0);
            Reflect.setField(optionComboColors[cid], "display", _gvars.activeUser.comboColors[cid]).color;
        }
        else if (e.target.exists("receptor_color_id"))
        {
            var rid : Int = e.target.receptor_color_id;
            _gvars.activeUser.receptorColors[rid] = e.target.validate(0, 0);
            Reflect.setField(optionReceptorColors[rid], "display", _gvars.activeUser.receptorColors[rid]).color;
        }
        else if (e.target.exists("game_color_id"))
        {
            var gid : Int = e.target.game_color_id;
            var newColorG : Float = e.target.validate(0, 0);
            _gvars.activeUser.gameColors[gid] = newColorG;
            
            if (gid == 0)
            {
                _gvars.activeUser.gameColors[2] = ColorUtil.darkenColor(newColorG, 0.27);
            }
            if (gid == 1)
            {
                _gvars.activeUser.gameColors[3] = ColorUtil.brightenColor(newColorG, 0.08);
            }
            
            Reflect.setField(optionGameColors[gid], "display", _gvars.activeUser.gameColors[gid]).color;
        }
        else if (Std.is(e.target, ColorField))
        {
            var sourceArray : Array<Dynamic>;
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
            for (item in sourceArray)
            {
                if (item != null && item.display == e.target)
                {
                    (try cast(item.text, BoxText) catch(e:Dynamic) null).text = "#" + StringUtil.pad(Std.string((try cast(e.target, ColorField) catch(e:Dynamic) null).color).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
                    (try cast(item.text, BoxText) catch(e:Dynamic) null).dispatchEvent(new Event(Event.CHANGE));
                }
            }
        }
    }
}

