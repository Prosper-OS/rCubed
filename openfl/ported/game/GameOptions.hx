package game;

import arc.ArcGlobals;
import classes.User;
import classes.chart.Song;
import classes.mp.MPUser;
import classes.replay.Replay;
import com.flashfla.utils.ObjectUtil;

class GameOptions
{
    public var isolation(get, set)                         : Dynamic;
    public var chartOffset(get, never)                         : Dynamic;

    public var frameRate                         : Dynamic= 60;
    public var songRate                         : Dynamic= 1;
    
    public var scrollDirection                         : Dynamic= "up";
    public var judgeSpeed                         : Dynamic= 1;
    public var scrollSpeed                         : Dynamic= 1.5;
    public var receptorSpacing                         : Dynamic= 80;
    public var receptorSpeed                         : Dynamic= 1;
    public var noteScale                         : Dynamic= 1;
    public var judgeScale                         : Dynamic= 1;
    public var screencutPosition                         : Dynamic= 0.5;
    public var mods                         : Dynamic= [];
    public var noteskin                         : Dynamic= 1;
    public var accuracyBarFadeFactor                         : Dynamic= 0.95;
    
    public var offsetGlobal                         : Dynamic= 0;
    public var visualDelay                         : Dynamic= 0;
    public var offsetJudge                         : Dynamic= 0;
    public var autoJudgeOffset                         : Dynamic= false;
    
    public var displayGameTopBar                         : Dynamic= true;
    public var displayGameBottomBar                         : Dynamic= true;
    public var displayJudge                         : Dynamic= true;
    public var displayJudgeAnimations                         : Dynamic= true;
    public var displayReceptorAnimations                         : Dynamic= true;
    public var displayHealth                         : Dynamic= true;
    public var displayScore                         : Dynamic= true;
    public var displayCombo                         : Dynamic= true;
    public var displayRawGoods                         : Dynamic= false;
    public var displayComboTotal                         : Dynamic= true;
    public var displayAccuracyBar                         : Dynamic= true;
    public var displayPA                         : Dynamic= true;
    public var displayAmazing                         : Dynamic= true;
    public var displayPerfect                         : Dynamic= true;
    public var displayScreencut                         : Dynamic= false;
    public var displaySongProgress                         : Dynamic= true;
    public var displaySongProgressText                         : Dynamic= false;
    public var displayMultiplayerScores                         : Dynamic= true;
    public var visualHypeMode                         : Dynamic= "full";
    
    public var judgeColors                         : Dynamic= [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100];
    public var comboColors                         : Dynamic= [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2];  // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood  
    public var enableComboColors                         : Dynamic= [true, true, true, false, false, false, false, false, false];
    public var receptorColors                         : Dynamic= [0xFFFFFF, 0xFFFFFF, 0x64FF64, 0xFFFF00, 0xBB8500, 0xA80000];
    public var enableReceptorColors                         : Dynamic= [true, true, true, true, true, false];
    public var gameColors                         : Dynamic= [0x1495BD, 0x033242, 0x0C6A88, 0x074B62, 0x000000];
    public var noteDirections                         : Dynamic= ["D", "L", "U", "R"];
    public var noteColors                         : Dynamic= ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
    public var noteSwapColors                         : Dynamic= {
            red : "red",
            blue : "blue",
            purple : "purple",
            yellow : "yellow",
            pink : "pink",
            orange : "orange",
            cyan : "cyan",
            green : "green",
            white : "white"
        };
    public var rawGoodTracker                         : Dynamic= 0;
    public var rawGoodsColor                         : Dynamic= 0xDC00C2;
    
    public var layout                         : Dynamic= { };
    
    public var judgeWindow                         : Dynamic= null;
    
    public var song                         : Dynamic= null;
    public var replay                         : Dynamic= null;
    public var isEditor                         : Dynamic= false;
    public var isAutoplay                         : Dynamic= false;
    public var autofail                         : Dynamic= [0, 0, 0, 0, 0, 0, 0, 0];
    public var autofail_restart                         : Dynamic= false;
    public var personalBestMode                         : Dynamic= false;
    public var personalBestTracker                         : Dynamic= false;
    
    public var isolationOffset                         : Dynamic= 0;
    public var isolationLength                         : Dynamic= 0;
    
    // Multiplayer
    public var isMultiplayer                         : Dynamic= false;
    public var isSpectator                         : Dynamic= false;
    public var spectatorUser                         : Dynamic;
    
    private function get_isolation() : Bool
    {
        return isolationOffset > 0 || isolationLength > 0;
    }
    
    private function set_isolation(value                         : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(!value))
        {
            isolationOffset = isolationLength = 0;
        }
        return value;
    }
    
    public function fillFromUser(user                         : Dynamic) : Void
    {
        frameRate = user.frameRate;
        songRate = user.songRate;
        
        scrollDirection = user.slideDirection;
        judgeSpeed = user.judgeSpeed;
        scrollSpeed = user.gameSpeed;
        receptorSpacing = user.receptorGap;
        receptorSpeed = user.receptorSpeed;
        noteScale = user.noteScale;
        judgeScale = user.judgeScale;
        screencutPosition = user.screencutPosition;
        mods = user.activeMods.concat(user.activeVisualMods);
        modCache = null;
        noteskin = user.activeNoteskin;
        accuracyBarFadeFactor = user.accuracyBarFadeFactor;
        
        offsetGlobal = user.GLOBAL_OFFSET;
        visualDelay = user.VISUAL_DELAY;
        offsetJudge = user.JUDGE_OFFSET;
        autoJudgeOffset = user.AUTO_JUDGE_OFFSET;
        
        displayJudge = user.DISPLAY_JUDGE;
        displayJudgeAnimations = user.DISPLAY_JUDGE_ANIMATIONS;
        displayReceptorAnimations = user.DISPLAY_RECEPTOR_ANIMATIONS;
        displayHealth = user.DISPLAY_HEALTH;
        displayGameTopBar = user.DISPLAY_GAME_TOP_BAR;
        displayGameBottomBar = user.DISPLAY_GAME_BOTTOM_BAR;
        displayScore = user.DISPLAY_SCORE;
        displayCombo = user.DISPLAY_COMBO;
        displayRawGoods = user.DISPLAY_RAWGOODS;
        displayComboTotal = user.DISPLAY_TOTAL;
        displayPA = user.DISPLAY_PACOUNT;
        displayAccuracyBar = user.DISPLAY_ACCURACY_BAR;
        displayAmazing = user.DISPLAY_AMAZING;
        displayPerfect = user.DISPLAY_PERFECT;
        displayScreencut = user.DISPLAY_SCREENCUT;
        displaySongProgress = user.DISPLAY_SONGPROGRESS;
        displaySongProgressText = user.DISPLAY_SONGPROGRESS_TEXT;
        displayMultiplayerScores = user.DISPLAY_MULTIPLAYER_SCORES;
        visualHypeMode = user.visualHypeMode;
        
        judgeColors = user.judgeColors.concat();
        comboColors = user.comboColors.concat();
        enableComboColors = user.enableComboColors.concat();
        receptorColors = user.receptorColors.concat();
        enableReceptorColors = user.enableReceptorColors.concat();
        gameColors = user.gameColors.concat();
        rawGoodTracker = user.rawGoodTracker;
        rawGoodsColor = user.rawGoodsColor;
        
        for (i in 0...noteColors.length)
        {
            Reflect.setField(noteSwapColors, Std.string(noteColors[i]), user.noteColors[i]);
        }
        
        autofail = [user.autofailAmazing, 
                user.autofailPerfect, 
                user.autofailGood, 
                user.autofailAverage, 
                user.autofailMiss, 
                user.autofailBoo, 
                user.autofailRawGoods, 
                user.autofailAaaEquiv
        ];
        
        autofail_restart = user.autofailRestart;
        
        personalBestMode = user.personalBestMode;
        personalBestTracker = user.personalBestTracker;
        
        var layoutKey                         : Dynamic= (((isMultiplayer && !isSpectator)) ? "mp" : "sp");
        if (as3hx.Compat.truthy(user.gameLayout[layoutKey] == null))
        {
            user.gameLayout[layoutKey] = { };
        }
        layout = user.gameLayout[layoutKey];
    }
    
    public function fillFromArcGlobals() : Void
    {
        var avars                         : Dynamic= ArcGlobals.instance;
        
        isolationOffset = avars.configIsolationStart;
        isolationLength = avars.configIsolationLength;
        
        judgeWindow = avars.configJudge;
    }
    
    public function fillFromReplay(r                         : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(r == null))
        {
            r = replay;
        }
        if (as3hx.Compat.truthy(r == null))
        {
            return;
        }
        
        settingsDecode(r.settings);
    }
    
    public function fill() : Void
    {
        fillFromUser(GlobalVariables.instance.activeUser);
        fillFromArcGlobals();
        
        // Force Disable Settings for multiplayer.
        if (as3hx.Compat.truthy(isMultiplayer))
        {
            judgeWindow = null;
            isolationOffset = isolationLength = 0;
        }
    }
    
    public var modCache                         : Dynamic= null;
    
    public function setModBooleanState(mod                         : Dynamic, value                         : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(modEnabled(mod) && !value))
        {
            mods.splice(Lambda.indexOf(mods, mod), 1)[0];
            Reflect.deleteField(modCache, mod);
        }
        else if (as3hx.Compat.truthy(!modEnabled(mod) && value))
        {
            mods.push(mod);
            Reflect.setField(modCache, mod, true);
        }
    }
    
    public function modEnabled(mod                         : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(modCache == null))
        {
            modCache = { };
            for (gameMod in as3hx.Compat.iter(mods))
            {
                Reflect.setField(modCache, Std.string(gameMod), true);
            }
        }
        return Lambda.has(modCache, mod);
    }
    
    public function settingsEncode() : Dynamic
    {
        var i                         : Dynamic= null;
        var settings                         : Dynamic= { };
        Reflect.setField(settings, "viewOffset", offsetGlobal);
        Reflect.setField(settings, "visualDelay", visualDelay);
        Reflect.setField(settings, "judgeOffset", offsetJudge);
        Reflect.setField(settings, "autoJudgeOffset", autoJudgeOffset);
        Reflect.setField(settings, "viewJudge", displayJudge);
        Reflect.setField(settings, "viewJudgeAnimations", displayJudgeAnimations);
        Reflect.setField(settings, "viewReceptorAnimations", displayReceptorAnimations);
        Reflect.setField(settings, "viewHealth", displayHealth);
        Reflect.setField(settings, "viewScore", displayScore);
        Reflect.setField(settings, "viewCombo", displayCombo);
        Reflect.setField(settings, "viewRawGoods", displayRawGoods);
        Reflect.setField(settings, "viewTotal", displayComboTotal);
        Reflect.setField(settings, "viewPACount", displayPA);
        Reflect.setField(settings, "viewAmazing", displayAmazing);
        Reflect.setField(settings, "viewPerfect", displayPerfect);
        Reflect.setField(settings, "viewScreencut", displayScreencut);
        Reflect.setField(settings, "viewSongProgress", displaySongProgress);
        Reflect.setField(settings, "viewSongProgressText", displaySongProgressText);
        Reflect.setField(settings, "viewMultiplayerScores", displayMultiplayerScores);
        Reflect.setField(settings, "viewGameTopBar", displayGameTopBar);
        Reflect.setField(settings, "viewGameBottomBar", displayGameBottomBar);
        Reflect.setField(settings, "viewAccuracyBar", displayAccuracyBar);
        Reflect.setField(settings, "visualHypeMode", visualHypeMode);
        Reflect.setField(settings, "speed", scrollSpeed);
        Reflect.setField(settings, "judgeSpeed", judgeSpeed);
        Reflect.setField(settings, "receptorSpeed", receptorSpeed);
        Reflect.setField(settings, "direction", scrollDirection);
        Reflect.setField(settings, "noteskin", noteskin);
        Reflect.setField(settings, "layout", ObjectUtil.clone(layout));
        Reflect.setField(settings, "gap", receptorSpacing);
        Reflect.setField(settings, "noteScale", noteScale);
        Reflect.setField(settings, "judgeScale", judgeScale);
        Reflect.setField(settings, "screencutPosition", screencutPosition);
        Reflect.setField(settings, "frameRate", frameRate);
        Reflect.setField(settings, "songRate", songRate);
        Reflect.setField(settings, "visual", mods);
        Reflect.setField(settings, "accuracyBarFadeFactor", accuracyBarFadeFactor);
        
        if (as3hx.Compat.truthy(isolation))
        {
            Reflect.setField(settings, "isolationOffset", isolationOffset);
            Reflect.setField(settings, "isolationLength", isolationLength);
        }
        
        Reflect.setField(settings, "noteSwapColours", []);
        for (i in 0...noteColors.length)
        {
            Reflect.setField(Reflect.field(settings, "noteSwapColours"), Std.string(i), as3hx.Compat.field(noteSwapColors, noteColors[i]));
        }
        
        Reflect.setField(settings, "judgeColors", []);
        for (i in 0...judgeColors.length)
        {
            Reflect.setField(Reflect.field(settings, "judgeColors"), Std.string(i), judgeColors[i]);
        }
        
        Reflect.setField(settings, "receptorColors", []);
        for (i in 0...receptorColors.length)
        {
            Reflect.setField(Reflect.field(settings, "receptorColors"), Std.string(i), receptorColors[i]);
        }
        
        Reflect.setField(settings, "enableReceptorColors", []);
        for (i in 0...enableReceptorColors.length)
        {
            Reflect.setField(Reflect.field(settings, "enableReceptorColors"), Std.string(i), enableReceptorColors[i]);
        }
        
        var user                         : Dynamic= GlobalVariables.instance.activeUser;
        Reflect.setField(settings, "keys", [user.keyLeft, user.keyDown, user.keyUp, user.keyRight, user.keyRestart, user.keyQuit, user.keyOptions]);
        
        return settings;
    }
    
    public function settingsDecode(settings                         : Dynamic) : Void
    {
        var i                         : Dynamic= null;
        
        songRate = as3hx.Compat.orValue(Reflect.field(settings, "songRate"), 1);
        
        scrollDirection = as3hx.Compat.orValue(Reflect.field(settings, "direction"), "up");
        judgeSpeed = as3hx.Compat.orValue(Reflect.field(settings, "judgeSpeed"), 1);
        scrollSpeed = as3hx.Compat.orValue(Reflect.field(settings, "speed"), 1.5);
        receptorSpacing = as3hx.Compat.orValue(Reflect.field(settings, "gap"), 80);
        noteScale = as3hx.Compat.orValue(Reflect.field(settings, "noteScale"), 1);
        judgeScale = as3hx.Compat.orValue(Reflect.field(settings, "judgeScale"), 1);
        screencutPosition = as3hx.Compat.orValue(Reflect.field(settings, "screencutPosition"), 0);
        mods = as3hx.Compat.orValue(Reflect.field(settings, "visual"), []);
        modCache = null;
        noteskin = (Reflect.field(settings, "noteskin") != null) ? Reflect.field(settings, "noteskin") : 1;
        accuracyBarFadeFactor = as3hx.Compat.orValue(Reflect.field(settings, "accuracyBarFadeFactor"), 0.95);
        
        offsetGlobal = as3hx.Compat.orValue(Reflect.field(settings, "viewOffset"), 0);
        visualDelay = as3hx.Compat.orValue(Reflect.field(settings, "visualDelay"), 0);
        offsetJudge = as3hx.Compat.orValue(Reflect.field(settings, "judgeOffset"), 0);
        autoJudgeOffset = as3hx.Compat.orValue(Reflect.field(settings, "autoJudgeOffset"), false);
        
        isolationOffset = as3hx.Compat.orValue(Reflect.field(settings, "isolationOffset"), 0);
        isolationLength = as3hx.Compat.orValue(Reflect.field(settings, "isolationLength"), 0);
        
        displayJudge = Reflect.field(settings, "viewJudge");
        displayHealth = Reflect.field(settings, "viewHealth");
        displayCombo = Reflect.field(settings, "viewCombo");
        displayRawGoods = Reflect.field(settings, "viewRawGoods");
        displayComboTotal = Reflect.field(settings, "viewTotal");
        displayPA = Reflect.field(settings, "viewPACount");
        displayAmazing = Reflect.field(settings, "viewAmazing");
        displayPerfect = Reflect.field(settings, "viewPerfect");
        displayScreencut = Reflect.field(settings, "viewScreencut");
        displaySongProgress = Reflect.field(settings, "viewSongProgress");
        displaySongProgressText = Reflect.field(settings, "viewSongProgressText");
        displayMultiplayerScores = Reflect.field(settings, "viewMultiplayerScores");
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewScore") != null))
        {
            displayScore = Reflect.field(settings, "viewScore");
        }
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewGameTopBar") != null))
        {
            displayGameTopBar = Reflect.field(settings, "viewGameTopBar");
        }
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewGameBottomBar") != null))
        {
            displayGameBottomBar = Reflect.field(settings, "viewGameBottomBar");
        }
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewAccuracyBar") != null))
        {
            displayAccuracyBar = Reflect.field(settings, "viewAccuracyBar");
        }
        if (as3hx.Compat.truthy(Reflect.field(settings, "visualHypeMode") != null))
        {
            visualHypeMode = Reflect.field(settings, "visualHypeMode");
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewJudgeAnimations") != null))
        {
            displayJudgeAnimations = Reflect.field(settings, "viewJudgeAnimations");
        }
        if (as3hx.Compat.truthy(Reflect.field(settings, "viewReceptorAnimations") != null))
        {
            displayReceptorAnimations = Reflect.field(settings, "viewReceptorAnimations");
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "noteSwapColours") != null))
        {
            for (i in 0...noteColors.length)
            {
                Reflect.setField(noteSwapColors, Std.string(noteColors[i]), Reflect.field(Reflect.field(settings, "noteSwapColours"), Std.string(i)));
            }
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "judgeColors") != null))
        {
            for (i in 0...judgeColors.length)
            {
                judgeColors[i] = Reflect.field(Reflect.field(settings, "judgeColors"), Std.string(i));
            }
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "receptorColors") != null))
        {
            for (i in 0...receptorColors.length)
            {
                receptorColors[i] = Reflect.field(Reflect.field(settings, "receptorColors"), Std.string(i));
            }
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "enableReceptorColors") != null))
        {
            for (i in 0...enableReceptorColors.length)
            {
                enableReceptorColors[i] = Reflect.field(Reflect.field(settings, "enableReceptorColors"), Std.string(i));
            }
        }
        
        if (as3hx.Compat.truthy(Reflect.field(settings, "layout") != null))
        {
            layout = Reflect.field(settings, "layout");
        }
    }
    
    public function isScoreValid(score                         : Dynamic= true, replay                         : Dynamic= true) : Bool
    {
        var ret                         : Dynamic= false;
        ret = (ret) ? ret : score && (isAutoplay || judgeWindow);
        ret = (ret) ? ret : replay && (modEnabled("reverse") || isolation);
        return !ret;
    }
    
    public function isScoreUpdated(score                         : Dynamic= true, replay                         : Dynamic= true) : Bool
    {
        var ret                         : Dynamic= false;
        ret = (ret) ? ret : score && (isAutoplay || modEnabled("shuffle") || modEnabled("random") || modEnabled("scramble") || judgeWindow);
        ret = (ret) ? ret : replay && (songRate != 1 || modEnabled("reverse"));
        return !ret;
    }
    
    public function getNewNoteColor(color                         : Dynamic) : String
    {
        return Reflect.field(noteSwapColors, color);
    }
    
    private function get_chartOffset() : Float
    {
        return offsetGlobal + visualDelay;
    }
    public function new()
    {
    }

}

