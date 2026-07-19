package popups.settings;

import classes.Language;
import classes.ui.BoxCheck;
import classes.ui.BoxSlider;
import classes.ui.ScrollPaneContent;
import classes.ui.Text;
import com.bit101.components.ComboBox;
import openfl.events.Event;
import openfl.events.MouseEvent;

class SettingsTabVisuals extends SettingsTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var gameUIArray                       : Dynamic= ["GAME_TOP_BAR", 
        "GAME_BOTTOM_BAR", 
        "JUDGE", 
        "HEALTH", 
        "SONGPROGRESS", 
        "SONGPROGRESS_TEXT", 
        "SCORE", 
        "COMBO", 
        "TOTAL", 
        "PACOUNT", 
        "ACCURACY_BAR", 
        "SCREENCUT", 
        "RAWGOODS", 
        "----", 
        "AMAZING", 
        "PERFECT", 
        "RECEPTOR_ANIMATIONS", 
        "JUDGE_ANIMATIONS"
    ];
    
    private var gameMPUIArray                       : Dynamic= ["MULTIPLAYER_SCORES"];
    
    private var gameOtherArray                       : Dynamic= ["GENRE_FLAG", 
        "SONG_FLAG", 
        "SONG_NOTE"
    ];
    
    private var optionDisplays                       : Dynamic;
    
    private var optionAccuracyBarFadeFactor                       : Dynamic;
    private var textAccuracyBarFadeFactor                       : Dynamic;
    
    private var optionHypeMode                       : Dynamic;
    private var hypeModeOptions                       : Dynamic= [{
            label : "Full",
            data : "full"
        }, {
            label : "Reduced",
            data : "reduced"
        }, {
            label : "Off",
            data : "off"
        }];
    
    private var optionReceptorSpeed                       : Dynamic;
    private var textReceptorSpeed                       : Dynamic;
    
    private var optionJudgeSpeed                       : Dynamic;
    private var textJudgeSpeed                       : Dynamic;
    
    private var optionJudgeScale                       : Dynamic;
    private var textJudgeScale                       : Dynamic;
    
    private var legacySongsCheck                       : Dynamic;
    private var explicitSongsCheck                       : Dynamic;
    private var unrankedSongsCheck                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "visual_graphics";
    }
    
    override public function openTab() : Void
    {
        container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        container.graphics.moveTo(295, 15);
        container.graphics.lineTo(295, 555);
        
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 15;
        
        /// Col 1
        //- Display
        optionDisplays = [];
        
        new Text(container, xOff, yOff, _lang.string("options_gameplay_display"), 14);
        yOff += 25;
        
        for (i in 0...gameUIArray.length)
        {
            if (as3hx.Compat.truthy(gameUIArray[i] == "----"))
            {
                yOff += drawSeperator(container, xOff, 266, yOff, 0, 1);
                continue;
            }
            
            new Text(container, xOff + 23, yOff, _lang.string("options_" + gameUIArray[i].toLowerCase()));
            
            var gameDisplayCheck                       : Dynamic= new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            gameDisplayCheck.display = gameUIArray[i];
            optionDisplays.push(gameDisplayCheck);
            yOff += 19;
            
            if (as3hx.Compat.truthy(gameUIArray[i] == "ACCURACY_BAR"))
            {
                yOff = drawAccuracyBarFadeFactor(xOff, yOff, container);
            }
            
            if (as3hx.Compat.truthy(gameUIArray[i] == "RECEPTOR_ANIMATIONS"))
            {
                yOff = drawReceptorSpeed(xOff, yOff, container);
            }
            
            if (as3hx.Compat.truthy(gameUIArray[i] == "JUDGE_ANIMATIONS"))
            {
                yOff = drawJudgeSpeed(xOff, yOff, container);
                yOff = drawJudgeScale(xOff, yOff, container);
            }
        }
        
        /// Col 2
        xOff = 310;
        yOff = 15;
        
        new Text(container, xOff, yOff, "Hype Effects", 14);
        yOff += 25;
        
        new Text(container, xOff + 23, yOff, "In-song hype");
        optionHypeMode = new ComboBox(container, xOff + 126, yOff - 2, "Full", hypeModeOptions);
        optionHypeMode.setSize(126, 22);
        optionHypeMode.openPosition = ComboBox.BOTTOM;
        optionHypeMode.fontSize = 11;
        optionHypeMode.numVisibleItems = hypeModeOptions.length;
        optionHypeMode.addEventListener(Event.SELECT, hypeModeSelect);
        yOff += 31;
        
        yOff += drawSeperator(container, xOff, 266, yOff, -3, 5);
        
        new Text(container, xOff, yOff, _lang.string("options_gameplay_mp_display"), 14);
        yOff += 25;
        
        for (i in 0...gameMPUIArray.length)
        {
            if (as3hx.Compat.truthy(gameMPUIArray[i] == "----"))
            {
                yOff += drawSeperator(container, xOff, 266, yOff, 0, 1);
                continue;
            }
            
            new Text(container, xOff + 23, yOff, _lang.string("options_" + gameMPUIArray[i].toLowerCase()));
            
            var gameMPDisplayCheck                       : Dynamic= new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            gameMPDisplayCheck.display = gameMPUIArray[i];
            optionDisplays.push(gameMPDisplayCheck);
            yOff += 19;
        }
        
        yOff += drawSeperator(container, xOff, 266, yOff, 6, 5);
        
        new Text(container, xOff, yOff, _lang.string("options_playlist_display"), 14);
        yOff += 25;
        
        for (i in 0...gameOtherArray.length)
        {
            if (as3hx.Compat.truthy(gameOtherArray[i] == "----"))
            {
                yOff += drawSeperator(container, xOff, 266, yOff, 0, 1);
                continue;
            }
            
            new Text(container, xOff + 23, yOff, _lang.string("options_" + gameOtherArray[i].toLowerCase()));
            
            var optionModCheck                       : Dynamic= new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
            optionModCheck.display = gameOtherArray[i];
            optionDisplays.push(optionModCheck);
            yOff += 19;
        }
        yOff += 11;
        
        // Legacy Song Display
        new Text(container, xOff + 23, yOff, _lang.string("options_include_legacy_songs"));
        legacySongsCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        legacySongsCheck.addEventListener(MouseEvent.MOUSE_OVER, e_legacyEngineMouseOver, false, 0, true);
        yOff += 19;
        
        // Explicit Song Display
        new Text(container, xOff + 23, yOff, _lang.string("options_include_explicit_songs"));
        explicitSongsCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 19;
        
        // Unranked Song Display
        new Text(container, xOff + 23, yOff, _lang.string("options_include_unranked_songs"));
        unrankedSongsCheck = new BoxCheck(container, xOff + 3, yOff + 3, clickHandler);
        yOff += 19;
    }
    
    
    private function drawAccuracyBarFadeFactor(xOff                       : Dynamic, yOff                       : Dynamic, container                       : Dynamic) : Int
    {
        new Text(container, xOff + 23, yOff, _lang.string("options_accuracy_bar_fade_factor"));
        yOff += 22;
        
        optionAccuracyBarFadeFactor = new BoxSlider(container, xOff + 23, yOff + 3, 100, 10, changeHandler);
        optionAccuracyBarFadeFactor.minValue = 0.5;
        optionAccuracyBarFadeFactor.maxValue = 0.99;
        
        textAccuracyBarFadeFactor = new Text(container, xOff + 128, yOff - 2);
        yOff += 20;
        return as3hx.Compat.parseInt(yOff + 4);
    }
    
    private function drawReceptorSpeed(xOff                       : Dynamic, yOff                       : Dynamic, container                       : Dynamic) : Int
    {
        new Text(container, xOff + 23, yOff, _lang.string("options_receptor_speed"));
        yOff += 22;
        
        optionReceptorSpeed = new BoxSlider(container, xOff + 23, yOff + 3, 100, 10, changeHandler);
        optionReceptorSpeed.minValue = 0.25;
        optionReceptorSpeed.maxValue = 5;
        
        textReceptorSpeed = new Text(container, xOff + 128, yOff - 2);
        yOff += 20;
        return as3hx.Compat.parseInt(yOff + 4);
    }
    
    private function drawJudgeSpeed(xOff                       : Dynamic, yOff                       : Dynamic, container                       : Dynamic) : Int
    {
        new Text(container, xOff + 23, yOff, _lang.string("options_judge_speed"));
        yOff += 22;
        
        optionJudgeSpeed = new BoxSlider(container, xOff + 23, yOff + 3, 100, 10, changeHandler);
        optionJudgeSpeed.minValue = 0.25;
        optionJudgeSpeed.maxValue = 5;
        
        textJudgeSpeed = new Text(container, xOff + 128, yOff - 2);
        yOff += 20;
        
        return as3hx.Compat.parseInt(yOff + 4);
    }
    
    private function drawJudgeScale(xOff                       : Dynamic, yOff                       : Dynamic, container                       : Dynamic) : Int
    {
        new Text(container, xOff + 23, yOff, _lang.string("options_judge_scale"));
        yOff += 22;
        
        optionJudgeScale = new BoxSlider(container, xOff + 23, yOff + 3, 100, 10, changeHandler);
        optionJudgeScale.minValue = 0.25;
        optionJudgeScale.maxValue = 3;
        
        textJudgeScale = new Text(container, xOff + 128, yOff - 2);
        yOff += 20;
        
        return as3hx.Compat.parseInt(yOff + 4);
    }
    
    override public function setValues() : Void
    {
        for (item in as3hx.Compat.iter(optionDisplays))
        {
            item.checked = (as3hx.Compat.field(_gvars.activeUser, "DISPLAY_" + item.display));
        }
        
        optionAccuracyBarFadeFactor.slideValue = _gvars.activeUser.accuracyBarFadeFactor;
        textAccuracyBarFadeFactor.text = as3hx.Compat.toFixed(_gvars.activeUser.accuracyBarFadeFactor * 100, 0) + "%";
        
        optionReceptorSpeed.slideValue = _gvars.activeUser.receptorSpeed;
        textReceptorSpeed.text = as3hx.Compat.toFixed(_gvars.activeUser.receptorSpeed, 2) + "x";
        
        optionJudgeSpeed.slideValue = _gvars.activeUser.judgeSpeed;
        textJudgeSpeed.text = as3hx.Compat.toFixed(_gvars.activeUser.judgeSpeed, 2) + "x";
        
        optionJudgeScale.slideValue = _gvars.activeUser.judgeScale;
        textJudgeScale.text = as3hx.Compat.toFixed(_gvars.activeUser.judgeScale, 2) + "x";
        
        optionHypeMode.selectedItemByData = _gvars.activeUser.visualHypeMode;
        
        legacySongsCheck.checked = _gvars.activeUser.DISPLAY_LEGACY_SONGS;
        explicitSongsCheck.checked = _gvars.activeUser.DISPLAY_EXPLICIT_SONGS;
        unrankedSongsCheck.checked = _gvars.activeUser.DISPLAY_UNRANKED_SONGS;
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target.exists("display")))
        {
            Reflect.setField(_gvars.activeUser, "DISPLAY_" + e.target.display, !as3hx.Compat.field(_gvars.activeUser, "DISPLAY_" + e.target.display));
            e.target.checked = !e.target.checked;
            if (as3hx.Compat.truthy(e.target.display == "GENRE_FLAG" || e.target.display == "SONG_FLAG" || e.target.display == "SONG_NOTE"))
            {
                _gvars.gameMain.activePanel.draw();
            }
        }
        // Songs Flags
        else if (as3hx.Compat.truthy(e.target == legacySongsCheck))
        {
            e.target.checked = !e.target.checked;
            _gvars.activeUser.DISPLAY_LEGACY_SONGS = !_gvars.activeUser.DISPLAY_LEGACY_SONGS;
        }
        else if (as3hx.Compat.truthy(e.target == explicitSongsCheck))
        {
            e.target.checked = !e.target.checked;
            _gvars.activeUser.DISPLAY_EXPLICIT_SONGS = !_gvars.activeUser.DISPLAY_EXPLICIT_SONGS;
        }
        else if (as3hx.Compat.truthy(e.target == unrankedSongsCheck))
        {
            e.target.checked = !e.target.checked;
            _gvars.activeUser.DISPLAY_UNRANKED_SONGS = !_gvars.activeUser.DISPLAY_UNRANKED_SONGS;
        }
        
        parent.checkValidMods();
    }
    
    private function hypeModeSelect(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(optionHypeMode.selectedItem && optionHypeMode.selectedItem.exists("data")))
        {
            _gvars.activeUser.visualHypeMode = optionHypeMode.selectedItem.data;
        }
        
        parent.checkValidMods();
    }
    
    override public function changeHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == optionAccuracyBarFadeFactor))
        {
            _gvars.activeUser.accuracyBarFadeFactor = Math.round(optionAccuracyBarFadeFactor.slideValue * 100) / 100;
            textAccuracyBarFadeFactor.text = as3hx.Compat.toFixed(_gvars.activeUser.accuracyBarFadeFactor * 100, 0) + "%";
        }
        
        if (as3hx.Compat.truthy(e.target == optionJudgeSpeed))
        {
            _gvars.activeUser.judgeSpeed = (Math.round((optionJudgeSpeed.slideValue * 100) / 5) * 5) / 100;  // Snap to 0.05 intervals.  
            textJudgeSpeed.text = as3hx.Compat.toFixed(_gvars.activeUser.judgeSpeed, 2) + "x";
        }
        
        if (as3hx.Compat.truthy(e.target == optionJudgeScale))
        {
            _gvars.activeUser.judgeScale = (Math.round((optionJudgeScale.slideValue * 100) / 5) * 5) / 100;  // Snap to 0.05 intervals.  
            textJudgeScale.text = as3hx.Compat.toFixed(_gvars.activeUser.judgeScale, 2) + "x";
        }
        
        if (as3hx.Compat.truthy(e.target == optionReceptorSpeed))
        {
            _gvars.activeUser.receptorSpeed = (Math.round((optionReceptorSpeed.slideValue * 100) / 5) * 5) / 100;  // Snap to 0.05 intervals.  
            textReceptorSpeed.text = as3hx.Compat.toFixed(_gvars.activeUser.receptorSpeed, 2) + "x";
        }
        
        parent.checkValidMods();
    }
    
    private function e_legacyEngineMouseOver(e                       : Dynamic) : Void
    {
        legacySongsCheck.addEventListener(MouseEvent.MOUSE_OUT, e_legacyEngineMouseOut);
        displayToolTip(legacySongsCheck.x, legacySongsCheck.y + 22, _lang.string("popup_legacy_songs"), "left");
    }
    
    private function e_legacyEngineMouseOut(e                       : Dynamic) : Void
    {
        legacySongsCheck.removeEventListener(MouseEvent.MOUSE_OUT, e_legacyEngineMouseOut);
        hideTooltip();
    }
}

