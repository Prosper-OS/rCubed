package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPFFRState
{
    public var user : MPUser;
    public var room : MPRoomFFR;
    
    public var game_state : String;  // ["menu", "loading", "game", "waiting", "results"]  
    public var playable_state : Int = 0;
    public var ready_state : Bool = false;
    public var loading_state : Bool = false;
    public var loading_percent : Float = 0;
    
    public var song_rate : Float = 1;
    
    public var settings : Dynamic = null;
    public var noteskin : String = null;
    public var replay_buffer : Array<Dynamic> = [];
    
    public function new(room : MPRoomFFR, user : MPUser)
    {
        this.room = room;
        this.user = user;
    }
    
    public function update(data : Dynamic) : Void
    {
        if (data.playable_state != null)
        {
            playable_state = data.playable_state;
        }
        
        if (data.ready_state != null)
        {
            ready_state = data.ready_state;
        }
        
        if (data.game_state != null)
        {
            game_state = data.game_state;
        }
        
        if (data.loading_state != null)
        {
            loading_state = data.loading_state;
        }
        
        if (data.ready_state != null)
        {
            ready_state = data.ready_state;
        }
        
        if (data.loading_percent != null)
        {
            loading_percent = data.loading_percent;
        }
        
        if (data.song_rate != null)
        {
            song_rate = data.song_rate;
        }
        
        if (data.settings != null)
        {
            settings = data.settings;
        }
        
        if (data.noteskin != null)
        {
            noteskin = data.noteskin;
        }
    }
}

