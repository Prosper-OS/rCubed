package classes;

import classes.replay.Replay;

class SongPreview extends Replay
{
    public function new(song_id                              : Dynamic)
    {
        super(song_id);
        this.level = song_id;
    }
    
    public function setupSongPreview(songData                              : Dynamic= null) : Void
    {
        var _gvars                              : Dynamic= GlobalVariables.instance;
        
        if (as3hx.Compat.truthy(songData == null))
        {
            songData = Playlist.instanceCanon.playList[this.level];
        }
        
        if (as3hx.Compat.truthy(songData == null))
        {
            return;
        }
        
        this.level = songData.level;
        
        this.user = new User(false, false);
        this.user.siteId = 1743546;
        this.user.name = "Song Preview";
        this.user.skillLevel = _gvars.MAX_DIFFICULTY;
        this.user.loadAvatar();
        
        this.timestamp = Math.floor((Date.now()).getTime() / 1000);
        this.settings = _gvars.playerUser.settings;
        
        this.isPreview = true;
        this.isLoaded = true;
        
        _gvars.options.fill();
    }
}


