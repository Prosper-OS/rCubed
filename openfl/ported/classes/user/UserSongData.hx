package classes.user;


class UserSongData
{
    public var engine : String;
    public var level_id : String;
    public var notes : String = "";
    public var set_mirror_invert : Bool = false;
    public var set_custom_offsets : Bool = false;
    public var offset_music : Float = 0;
    public var offset_judge : Float = 0;
    public var song_rating : Float = 0;
    public var song_favorite : Bool = false;
    
    public function new(source_engine : String, source_id : String, source_data : Dynamic)
    
    {
engine = source_engine;
        level_id = source_id;
        
        // From JSON
        if (source_data == null)
        {
            return;
        }
        
        if (source_data.notes != null)
        {
            notes = source_data.notes;
        }
        
        if (source_data.set_mirror_invert != null)
        {
            set_mirror_invert = source_data.set_mirror_invert;
        }
        
        if (source_data.set_custom_offsets != null)
        {
            set_custom_offsets = source_data.set_custom_offsets;
        }
        
        if (source_data.offset_music != null)
        {
            offset_music = source_data.offset_music;
        }
        
        if (source_data.offset_judge != null)
        {
            offset_judge = source_data.offset_judge;
        }
        
        if (source_data.song_favorite != null)
        {
            song_favorite = source_data.song_favorite;
        }
        
        if (source_data.song_rating != null)
        {
            song_rating = source_data.song_rating;
        }
    }
    
    /**
     * Called when `JSON.stringify` is called on this object automatically.
     * @param k
     * @return Object representing this class.
     */
    public function toJSON(k : Dynamic) : Dynamic
    {
        var out : Dynamic = { };
        
        if (notes.length > 0)
        {
            Reflect.setField(out, "notes", notes);
        }
        
        if (offset_music != 0)
        {
            Reflect.setField(out, "offset_music", offset_music);
        }
        
        if (offset_judge != 0)
        {
            Reflect.setField(out, "offset_judge", offset_judge);
        }
        
        if (set_mirror_invert)
        {
            Reflect.setField(out, "set_mirror_invert", set_mirror_invert);
        }
        
        if (set_custom_offsets)
        {
            Reflect.setField(out, "set_custom_offsets", set_custom_offsets);
        }
        
        if (song_favorite)
        {
            Reflect.setField(out, "song_favorite", song_favorite);
        }
        
        if (song_rating != 0)
        {
            Reflect.setField(out, "song_rating", song_rating);
        }
        
        return out;
    }
}

