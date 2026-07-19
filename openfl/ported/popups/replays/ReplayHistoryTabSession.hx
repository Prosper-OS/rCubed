package popups.replays;

import classes.Alert;
import classes.Language;
import classes.replay.Replay;
import classes.ui.BoxButton;
import classes.ui.PromptInput;
import openfl.events.Event;

class ReplayHistoryTabSession extends ReplayHistoryTabBase
{
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    private var btn_import : BoxButton;
    
    public function new(replayWindow : ReplayHistoryWindow)
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
        
        if (btn_import == null)
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
        var render_list : Array<Dynamic> = [];
        for (r/* AS3HX WARNING could not determine type for var: r exp: EField(EIdent(_gvars),replayHistory) type: null */ in _gvars.replayHistory)
        {
            if (r.song == null)
            {
                continue;
            }
            
            if (parent.searchText.length >= 1 && r.song.name.toLowerCase().indexOf(parent.searchText) == -1)
            {
                continue;
            }
            
            render_list[render_list.length] = r;
        }
        parent.pane.setRenderList(render_list, false);
        parent.updateScrollPane();
    }
    
    private function e_importClick(e : Event) : Void
    {
        new PromptInput(parent, _lang.string("popup_replay_import_window_title"), _lang.string("popup_replay_import"), e_importReplay);
    }
    
    private function e_importReplay(replayString : String) : Void
    {
        var r : Replay = new Replay(Date.now().getTime());
        r.parseEncode(replayString);
        if (r.isEdited)
        {
            Alert.add(_lang.string("popup_replay_import_edited"), 180);
        }
        if (r.isValid())
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

