package game;

import arc.ArcGlobals;
import classes.User;
import classes.chart.Song;
import classes.mp.MPUser;
import classes.replay.Replay;
import com.flashfla.utils.ObjectUtil;

class GameOptions
{
    public var isolation(get, set) : Bool;
    public var chartOffset(get, never) : Float;

    public var frameRate : Int = 60;
    public var songRate : Float = 1;
    
    public var scrollDirection : String = "up";
    public var judgeSpeed : Float = 1;
    public var scrollSpeed : Float = 1.5;
    public var receptorSpacing : Int = 80;
    public var receptorSpeed : Float = 1;
    public var noteScale : Float = 1;
    public var judgeScale : Float = 1;
    public var screencutPosition : Float = 0.5;
    public var mods : Array<Dynamic> = [];
    public var noteskin : Int = 1;
    public var accuracyBarFadeFactor : Float = 0.95;
    
    public var offsetGlobal : Float = 0;
    public var visualDelay : Float = 0;
    public var offsetJudge : Float = 0;
    public var autoJudgeOffset : Bool = false;
    
    public var displayGameTopBar : Bool = true;
    public var displayGameBottomBar : Bool = true;
    public var displayJudge : Bool = true;
    public var displayJudgeAnimations : Bool = true;
    public var displayReceptorAnimations : Bool = true;
    public var displayHealth : Bool = true;
    public var displayScore : Bool = true;
    public var displayCombo : Bool = true;
    public var displayRawGoods : Bool = false;
    public var displayComboTotal : Bool = true;
    public var displayAccuracyBar : Bool = true;
    public var displayPA : Bool = true;
    public var displayAmazing : Bool = true;
    public var displayPerfect : Bool = true;
    public var displayScreencut : Bool = false;
    public var displaySongProgress : Bool = true;
    public var displaySongProgressText : Bool = false;
    public var displayMultiplayerScores : Bool = true;
    public var visualHypeMode : String = "full";
    
    public var judgeColors : Array<Dynamic> = [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100];
    public var comboColors : Array<Dynamic> = [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2];  // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood  
    public var enableComboColors : Array<Bool> = [true, true, true, false, false, false, false, false, false];
    public var receptorColors : Array<Dynamic> = [0xFFFFFF, 0xFFFFFF, 0x64FF64, 0xFFFF00, 0xBB8500, 0xA80000];
    public var enableReceptorColors : Array<Bool> = [true, true, true, true, true, false];
    public var gameColors : Array<Dynamic> = [0x1495BD, 0x033242, 0x0C6A88, 0x074B62, 0x000000];
    public var noteDirections : Array<Dynamic> = ["D", "L", "U", "R"];
    public var noteColors : Array<Dynamic> = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
    public var noteSwapColors : Dynamic = {
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
    public var rawGoodTracker : Float = 0;
    public var rawGoodsColor : Float = 0xDC00C2;
    
    public var layout : Dynamic = { };
    
    public var judgeWindow : Array<Dynamic> = null;
    
    public var song : Song = null;
    public var replay : Replay = null;
    public var isEditor : Bool = false;
    public var isAutoplay : Bool = false;
    public var autofail : Array<Dynamic> = [0, 0, 0, 0, 0, 0, 0, 0];
    public var autofail_restart : Bool = false;
    public var personalBestMode : Bool = false;
    public var personalBestTracker : Bool = false;
    
    public var isolationOffset : Int = 0;
    public var isolationLength : Int = 0;
    
    // Multiplayer
    public var isMultiplayer : Bool = false;
    public var isSpectator : Bool = false;
    public var spectatorUser : MPUser;
    
    private function get_isolation() : Bool
    {
        return isolationOffset > 0 || isolationLength > 0;
    }
    
    private function set_isolation(value : Bool) : Bool
    {
        if (!value)
        {
            isolationOffset = isolationLength = 0;
        }
        return value;
    }
    
    public function fillFromUser(user : User) : Void
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
        
        var layoutKey : String = (((isMultiplayer && !isSpectator)) ? "mp" : "sp");
        if (user.gameLayout[layoutKey] == null)
        {
            user.gameLayout[layoutKey] = { };
        }
        layout = user.gameLayout[layoutKey];
    }
    
    public function fillFromArcGlobals() : Void
    {
        var avars : ArcGlobals = ArcGlobals.instance;
        
        isolationOffset = avars.configIsolationStart;
        isolationLength = avars.configIsolationLength;
        
        judgeWindow = avars.configJudge;
    }
    
    public function fillFromReplay(r : Dynamic = null) : Void
    {
        if (r == null)
        {
            r = replay;
        }
        if (r == null)
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
        if (isMultiplayer)
        {
            judgeWindow = null;
            isolationOffset = isolationLength = 0;
        }
    }
    
    public var modCache : Dynamic = null;
    
    public function setModBooleanState(mod : String, value : Bool) : Void
    {
        if (modEnabled(mod) && !value)
        {
            mods.splice(Lambda.indexOf(mods, mod), 1)[0];
            Reflect.deleteField(modCache, mod);
        }
        else if (!modEnabled(mod) && value)
        {
            mods.push(mod);
            Reflect.setField(modCache, mod, true);
        }
    }
    
    public function modEnabled(mod : String) : Bool
    {
        if (modCache == null)
        {
            modCache = { };
            for (gameMod in mods)
            {
                Reflect.setField(modCache, Std.string(gameMod), true);
            }
        }
        return Lambda.has(modCache, mod);
    }
    
    public function settingsEncode() : Dynamic
    {
        var i : Int;
        var settings : Dynamic = { };
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
        
        if (isolation)
        {
            Reflect.setField(settings, "isolationOffset", isolationOffset);
            Reflect.setField(settings, "isolationLength", isolationLength);
        }
        
        Reflect.setField(settings, "noteSwapColours", []);
        for (i in 0...noteColors.length)
        {
            Reflect.setField(Reflect.field(settings, "noteSwapColours"), Std.string(i), Reflect.field(noteSwapColors, Std.string(noteColors[i])));
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
        
        var user : User = GlobalVariables.instance.activeUser;
        Reflect.setField(settings, "keys", [user.keyLeft, user.keyDown, user.keyUp, user.keyRight, user.keyRestart, user.keyQuit, user.keyOptions]);
        
        return settings;
    }
    
    public function settingsDecode(settings : Dynamic) : Void
    {
        var i : Int;
        
        songRate = Reflect.field(settings, "songRate") || 1;
        
        scrollDirection = Reflect.field(settings, "direction") || "up";
        judgeSpeed = Reflect.field(settings, "judgeSpeed") || 1;
        scrollSpeed = Reflect.field(settings, "speed") || 1.5;
        receptorSpacing = (Reflect.field(settings, "gap") || 80) ? 1 : 0;
        noteScale = Reflect.field(settings, "noteScale") || 1;
        judgeScale = Reflect.field(settings, "judgeScale") || 1;
        screencutPosition = Reflect.field(settings, "screencutPosition") || 0;
        mods = Reflect.field(settings, "visual") || [];
        modCache = null;
        noteskin = (Reflect.field(settings, "noteskin") != null) ? Reflect.field(settings, "noteskin") : 1;
        accuracyBarFadeFactor = Reflect.field(settings, "accuracyBarFadeFactor") || 0.95;
        
        offsetGlobal = Reflect.field(settings, "viewOffset") || 0;
        visualDelay = Reflect.field(settings, "visualDelay") || 0;
        offsetJudge = Reflect.field(settings, "judgeOffset") || 0;
        autoJudgeOffset = Reflect.field(settings, "autoJudgeOffset") || false;
        
        isolationOffset = (Reflect.field(settings, "isolationOffset") || 0) ? 1 : 0;
        isolationLength = (Reflect.field(settings, "isolationLength") || 0) ? 1 : 0;
        
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
        
        if (Reflect.field(settings, "viewScore") != null)
        {
            displayScore = Reflect.field(settings, "viewScore");
        }
        if (Reflect.field(settings, "viewGameTopBar") != null)
        {
            displayGameTopBar = Reflect.field(settings, "viewGameTopBar");
        }
        if (Reflect.field(settings, "viewGameBottomBar") != null)
        {
            displayGameBottomBar = Reflect.field(settings, "viewGameBottomBar");
        }
        if (Reflect.field(settings, "viewAccuracyBar") != null)
        {
            displayAccuracyBar = Reflect.field(settings, "viewAccuracyBar");
        }
        if (Reflect.field(settings, "visualHypeMode") != null)
        {
            visualHypeMode = Reflect.field(settings, "visualHypeMode");
        }
        
        if (Reflect.field(settings, "viewJudgeAnimations") != null)
        {
            displayJudgeAnimations = Reflect.field(settings, "viewJudgeAnimations");
        }
        if (Reflect.field(settings, "viewReceptorAnimations") != null)
        {
            displayReceptorAnimations = Reflect.field(settings, "viewReceptorAnimations");
        }
        
        if (Reflect.field(settings, "noteSwapColours") != null)
        {
            for (i in 0...noteColors.length)
            {
                Reflect.setField(noteSwapColors, Std.string(noteColors[i]), Reflect.field(Reflect.field(settings, "noteSwapColours"), Std.string(i)));
            }
        }
        
        if (Reflect.field(settings, "judgeColors") != null)
        {
            for (i in 0...judgeColors.length)
            {
                judgeColors[i] = Reflect.field(Reflect.field(settings, "judgeColors"), Std.string(i));
            }
        }
        
        if (Reflect.field(settings, "receptorColors") != null)
        {
            for (i in 0...receptorColors.length)
            {
                receptorColors[i] = Reflect.field(Reflect.field(settings, "receptorColors"), Std.string(i));
            }
        }
        
        if (Reflect.field(settings, "enableReceptorColors") != null)
        {
            for (i in 0...enableReceptorColors.length)
            {
                enableReceptorColors[i] = Reflect.field(Reflect.field(settings, "enableReceptorColors"), Std.string(i));
            }
        }
        
        if (Reflect.field(settings, "layout") != null)
        {
            layout = Reflect.field(settings, "layout");
        }
    }
    
    public function isScoreValid(score : Bool = true, replay : Bool = true) : Bool
    {
        var ret : Bool = false;
        ret = (ret) ? ret : score && (isAutoplay || judgeWindow);
        ret = (ret) ? ret : replay && (modEnabled("reverse") || isolation);
        return !ret;
    }
    
    public function isScoreUpdated(score : Bool = true, replay : Bool = true) : Bool
    {
        var ret : Bool = false;
        ret = (ret) ? ret : score && (isAutoplay || modEnabled("shuffle") || modEnabled("random") || modEnabled("scramble") || judgeWindow);
        ret = (ret) ? ret : replay && (songRate != 1 || modEnabled("reverse"));
        return !ret;
    }
    
    public function getNewNoteColor(color : String) : String
    {
        return Reflect.field(noteSwapColors, color);
    }
    
    private function get_chartOffset() : Float
    {
        return offsetGlobal + visualDelay;
    }

    public function new()
    {
        super();
    }
}

