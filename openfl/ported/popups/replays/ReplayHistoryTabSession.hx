package popups.replays;

import classes.Alert;
import classes.Language;
import classes.replay.Replay;
import classes.ui.BoxButton;
import classes.ui.PromptInput;
import openfl.events.Event;

class ReplayHistoryTabSession extends ReplayHistoryTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var btn_import                       : Dynamic;
    
    public function new(replayWindow                       : Dynamic)
    {
        super(replayWindow);
    }
    
    override private function get_name() : String
    {
        return "session";
    }
    
    override public function openTab() : Void
    // Add UI Elements
    {
        
        if (as3hx.Compat.truthy(btn_import == null))
        {
            btn_import = new BoxButton(null, 5, 410, 162, 29, _lang.string("popup_replay_import"), 12, e_importClick);
        }
        parent.addChild(btn_import);
    }
    
    override public function closeTab() : Void
    {
        parent.removeChild(btn_import);
    }
    
    override public function setValues() : Void
    {
        var render_list                       : Dynamic= [];
        for (r/* AS3HX WARNING could not determine type for var: r exp: EField(EIdent(_gvars),replayHistory) type: null */ in as3hx.Compat.iter(_gvars.replayHistory))
        {
            if (as3hx.Compat.truthy(r.song == null))
            {
                continue;
            }
            
            if (as3hx.Compat.truthy(parent.searchText.length >= 1 && r.song.name.toLowerCase().indexOf(parent.searchText) == -1))
            {
                continue;
            }
            
            render_list[render_list.length] = r;
        }
        parent.pane.setRenderList(render_list, false);
        parent.updateScrollPane();
    }
    
    private function e_importClick(e                       : Dynamic) : Void
    {
        new PromptInput(parent, _lang.string("popup_replay_import_window_title"), _lang.string("popup_replay_import"), e_importReplay);
    }
    
    private function e_importReplay(replayString                       : Dynamic) : Void
    {
        var r                       : Dynamic= new Replay(Date.now().getTime());
        r.parseEncode(replayString);
        if (as3hx.Compat.truthy(r.isEdited))
        {
            Alert.add(_lang.string("popup_replay_import_edited"), 180);
        }
        if (as3hx.Compat.truthy(r.isValid()))
        {
            r.loadSongInfo();
            _gvars.replayHistory.unshift(r);
            setValues();
        }
        else
        {
            Alert.add(_lang.string("popup_replay_import_invalid"));
        }
    }
}

