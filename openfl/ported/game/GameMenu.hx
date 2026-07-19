package game;

import classes.Language;
import com.flashfla.utils.SystemUtil;
import menu.MenuPanel;

class GameMenu extends MenuPanel
{
    public static inline var GAME_LOADING : String = "GameLoading";
    public static inline var GAME_PLAY : String = "GamePlay";
    public static inline var GAME_RESULTS : String = "GameResults";
    public static inline var GAME_MP_WAIT : String = "GameMPWait";
    public static inline var GAME_MP_RESULTS : String = "GameMPResults";
    
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    public var panel : MenuPanel;
    
    public function new(myParent : MenuPanel)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        if (Flags.VALUES[Flags.MP_MENU_RESULTS] != null)
        {
            Flags.VALUES[Flags.MP_MENU_RESULTS] = false;
            switchTo(GAME_MP_RESULTS);
        }
        else if (_gvars.options.isEditor)
        {
            switchTo(GAME_PLAY);
        }
        // Clone Song queue
        else
        {
            
            _gvars.totalSongQueue = _gvars.songQueue.concat();
            switchTo(GAME_LOADING);
        }
        return false;
    }
    
    override public function stageRemove() : Void
    {
        if (panel != null && panel.stage)
        {
            panel.stageRemove();
        }
        
        super.stageRemove();
    }
    
    override public function dispose() : Void
    {
        if (panel != null)
        {
            panel.dispose();
            if (this.contains(panel))
            {
                this.removeChild(panel);
            }
            panel = null;
        }
        super.dispose();
    }
    
    override public function switchTo(_panel : String) : Bool
    //- Check Parent Function first.
    {
        
        if (super.switchTo(_panel))
        {
            _gvars.gameMain.bg.updateDisplay();
            _gvars.gameMain.ver.visible = true;
            
            if (panel != null)
            {
                panel.stageRemove();
                panel.parent.removeChild(panel);
                panel.dispose();
            }
            
            return true;
        }
        
        //- Do Current Panel
        var isFound : Bool = false;
        var initValid : Bool = false;
        
        if (panel != null)
        {
            panel.stageRemove();
            panel.parent.removeChild(panel);
            panel.dispose();
        }
        
        switch (_panel)
        {
            case GAME_LOADING:
                panel = new GameLoading(this);
                _gvars.gameMain.bg.updateDisplay();
                _gvars.gameMain.ver.visible = true;
                isFound = true;
            
            case GAME_PLAY:
                panel = new GameplayDisplay(this);
                _gvars.gameMain.bg.updateDisplay(true);
                _gvars.gameMain.ver.visible = false;
                isFound = true;
            
            case GAME_RESULTS:
                panel = new GameResults(this);
                _gvars.gameMain.ver.visible = true;
                isFound = true;
            
            case GAME_MP_WAIT:
                panel = new GameMultiplayerWait(this);
                _gvars.gameMain.bg.updateDisplay(true);
                _gvars.gameMain.ver.visible = true;
                isFound = true;
            
            case GAME_MP_RESULTS:
                panel = new GameResultsMP(this);
                _gvars.gameMain.ver.visible = true;
                isFound = true;
        }
        this.addChild(panel);
        if (!panel.hasInit)
        {
            initValid = panel.init();
            panel.hasInit = true;
        }
        
        if (initValid)
        {
            panel.stageAdd();
        }
        
        SystemUtil.gc();
        return isFound;
    }
}

