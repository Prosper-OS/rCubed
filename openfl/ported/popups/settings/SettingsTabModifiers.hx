package popups.settings;

import classes.Language;
import classes.ui.BoxCheck;
import classes.ui.Text;
import com.flashfla.utils.ArrayUtil;
import openfl.events.MouseEvent;

class SettingsTabModifiers extends SettingsTabBase
{
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    private var optionGameMods : Array<Dynamic>;
    private var optionVisualGameMods : Array<Dynamic>;
    
    public function new(settingsWindow : SettingsWindow)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "game_modifiers";
    }
    
    override public function openTab() : Void
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(295, 15);
        container.graphics.lineTo(295, 405);
        
        var i : Int;
        var xOff : Int = 15;
        var yOff : Int = 15;
        
        /// Col 1
        //- Mods
        optionGameMods = [];
        
        new Text(container, xOff, yOff, _lang.string("options_game_mods"), 14);
        yOff += 25;
        
        var modsData : Array<Dynamic> = _gvars.GAME_MODS;
        for (i in 0...modsData.length)
        {
            if (modsData[i] == "----")
            {
                yOff += drawSeperator(container, xOff, 266, yOff, 2, 3);
                continue;
            }
            
            new Text(container, xOff + 23, yOff, _lang.string("options_mod_" + modsData[i]));
            
            var optionModCheck : BoxCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            optionModCheck.mod = modsData[i];
            optionGameMods.push(optionModCheck);
            yOff += 20;
        }
        
        /// Col 2
        xOff = 310;
        yOff = 15;
        
        //- Visual Mods
        optionVisualGameMods = [];
        
        new Text(container, xOff, yOff, _lang.string("options_visual_mods"), 14);
        yOff += 25;
        
        var modsVisualData : Array<Dynamic> = _gvars.VISUAL_MODS;
        for (i in 0...modsVisualData.length)
        {
            if (modsVisualData[i] == "----")
            {
                yOff += drawSeperator(container, xOff, 266, yOff, 2, 3);
                continue;
            }
            
            new Text(container, xOff + 23, yOff, _lang.string("options_mod_" + modsVisualData[i]));
            
            var optionVisualModCheck : BoxCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            optionVisualModCheck.visual_mod = modsVisualData[i];
            optionVisualGameMods.push(optionVisualModCheck);
            yOff += 20;
        }
    }
    
    override public function setValues() : Void
    {
        var item : Dynamic;
        
        // Set Game Mods
        for (item in optionGameMods)
        {
            item.checked = (_gvars.activeUser.activeMods.indexOf(item.mod) != -1);
        }
        
        // Set Visual Game Mods
        for (item in optionVisualGameMods)
        {
            item.checked = (_gvars.activeUser.activeVisualMods.indexOf(item.visual_mod) != -1);
        }
    }
    
    override public function clickHandler(e : MouseEvent) : Void
    //- Visual Mods
    {
        
        if (e.target.exists("visual_mod"))
        {
            e.target.checked = !e.target.checked;
            var visual_mod : String = e.target.visual_mod;
            if (_gvars.activeUser.activeVisualMods.indexOf(visual_mod) != -1)
            {
                ArrayUtil.removeValue(visual_mod, _gvars.activeUser.activeVisualMods);
            }
            else
            {
                _gvars.activeUser.activeVisualMods.push(visual_mod);
            }
        }
        //- Mods
        else if (e.target.exists("mod"))
        {
            e.target.checked = !e.target.checked;
            var mod : String = e.target.mod;
            if (_gvars.activeUser.activeMods.indexOf(mod) != -1)
            {
                ArrayUtil.removeValue(mod, _gvars.activeUser.activeMods);
            }
            else
            {
                _gvars.activeUser.activeMods.push(mod);
            }
            if (mod == "reverse")
            {
                _gvars.dirtySongFiles();
            }
        }
        
        parent.checkValidMods();
    }
}

