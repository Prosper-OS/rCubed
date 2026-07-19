package game;

import classes.Language;
import com.flashfla.utils.SystemUtil;
import menu.MenuPanel;

class GameMenu extends MenuPanel
{
    public static inline var GAME_LOADING                          : Dynamic= "GameLoading";
    public static inline var GAME_PLAY                          : Dynamic= "GamePlay";
    public static inline var GAME_RESULTS                          : Dynamic= "GameResults";
    public static inline var GAME_MP_WAIT                          : Dynamic= "GameMPWait";
    public static inline var GAME_MP_RESULTS                          : Dynamic= "GameMPResults";
    
    private var _gvars                          : Dynamic= GlobalVariables.instance;
    private var _lang                          : Dynamic= Language.instance;
    
    public var panel                          : Dynamic;
    
    public function new(myParent                          : Dynamic)
    {
        super(myParent);
    }
    
    override public function init() : Bool
    {
        if (as3hx.Compat.truthy(as3hx.Compat.field(Flags.VALUES, Flags.MP_MENU_RESULTS) != null))
        {
            Reflect.setField(Flags.VALUES, Flags.MP_MENU_RESULTS, false);
            switchTo(GAME_MP_RESULTS);
        }
        else if (as3hx.Compat.truthy(_gvars.options.isEditor))
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
        if (as3hx.Compat.truthy(panel != null && panel.stage))
        {
            panel.stageRemove();
        }
        
        super.stageRemove();
    }
    
    override public function dispose() : Void
    {
        if (as3hx.Compat.truthy(panel != null))
        {
            panel.dispose();
            if (as3hx.Compat.truthy(this.contains(panel)))
            {
                this.removeChild(panel);
            }
            panel = null;
        }
        super.dispose();
    }
    
    override public function switchTo(_panel                          : Dynamic) : Bool
    //- Check Parent Function first.
    {
        
        if (as3hx.Compat.truthy(super.switchTo(_panel)))
        {
            _gvars.gameMain.bg.updateDisplay();
            _gvars.gameMain.ver.visible = true;
            
            if (as3hx.Compat.truthy(panel != null))
            {
                panel.stageRemove();
                panel.parent.removeChild(panel);
                panel.dispose();
            }
            
            return true;
        }
        
        //- Do Current Panel
        var isFound                          : Dynamic= false;
        var initValid                          : Dynamic= false;
        
        if (as3hx.Compat.truthy(panel != null))
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
        if (as3hx.Compat.truthy(!panel.hasInit))
        {
            initValid = panel.init();
            panel.hasInit = true;
        }
        
        if (as3hx.Compat.truthy(initValid))
        {
            panel.stageAdd();
        }
        
        SystemUtil.gc();
        return isFound;
    }
}

