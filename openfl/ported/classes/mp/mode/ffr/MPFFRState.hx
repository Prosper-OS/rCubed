package classes.mp.mode.ffr;

import classes.mp.MPUser;
import classes.mp.room.MPRoomFFR;

class MPFFRState
{
    public var user                             : Dynamic;
    public var room                             : Dynamic;
    
    public var game_state                             : Dynamic;  // ["menu", "loading", "game", "waiting", "results"]  
    public var playable_state                             : Dynamic= 0;
    public var ready_state                             : Dynamic= false;
    public var loading_state                             : Dynamic= false;
    public var loading_percent                             : Dynamic= 0;
    
    public var song_rate                             : Dynamic= 1;
    
    public var settings                             : Dynamic= null;
    public var noteskin                             : Dynamic= null;
    public var replay_buffer                             : Dynamic= [];
    
    public function new(room                             : Dynamic, user                             : Dynamic)
    {
        this.room = room;
        this.user = user;
    }
    
    public function update(data                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(data.playable_state != null))
        {
            playable_state = data.playable_state;
        }
        
        if (as3hx.Compat.truthy(data.ready_state != null))
        {
            ready_state = data.ready_state;
        }
        
        if (as3hx.Compat.truthy(data.game_state != null))
        {
            game_state = data.game_state;
        }
        
        if (as3hx.Compat.truthy(data.loading_state != null))
        {
            loading_state = data.loading_state;
        }
        
        if (as3hx.Compat.truthy(data.ready_state != null))
        {
            ready_state = data.ready_state;
        }
        
        if (as3hx.Compat.truthy(data.loading_percent != null))
        {
            loading_percent = data.loading_percent;
        }
        
        if (as3hx.Compat.truthy(data.song_rate != null))
        {
            song_rate = data.song_rate;
        }
        
        if (as3hx.Compat.truthy(data.settings != null))
        {
            settings = data.settings;
        }
        
        if (as3hx.Compat.truthy(data.noteskin != null))
        {
            noteskin = data.noteskin;
        }
    }
}

