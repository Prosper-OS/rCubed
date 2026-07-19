package popups.replays;

import classes.replay.Replay;
import classes.ui.ScrollPaneContent;

class ReplayHistoryTabBase
{
    public var name(get, never) : String;

    private var parent : ReplayHistoryWindow;
    public var container : ScrollPaneContent;
    
    public function new(replayWindow : ReplayHistoryWindow)
    {
        this.parent = replayWindow;
    }
    
    private function get_name() : String
    {
        return null;
    }
    
    public function openTab() : Void
    {
    }
    
    public function closeTab() : Void
    {
    }
    
    public function setValues() : Void
    {
    }
    
    public function prepareReplay(r : Replay) : Replay
    {
        return r;
    }
}

