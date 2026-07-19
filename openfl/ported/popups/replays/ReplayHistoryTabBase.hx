package popups.replays;

import classes.replay.Replay;
import classes.ui.ScrollPaneContent;

class ReplayHistoryTabBase
{
    public var name(get, never)                       : Dynamic;

    public var parent                       : Dynamic;
    public var container                       : Dynamic;
    
    public function new(replayWindow                       : Dynamic)
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
    
    public function prepareReplay(r                       : Dynamic) : Replay
    {
        return r;
    }
}

