package classes.user;


class UserSongData
{
    public var engine                            : Dynamic;
    public var level_id                            : Dynamic;
    public var notes                            : Dynamic= "";
    public var set_mirror_invert                            : Dynamic= false;
    public var set_custom_offsets                            : Dynamic= false;
    public var offset_music                            : Dynamic= 0;
    public var offset_judge                            : Dynamic= 0;
    public var song_rating                            : Dynamic= 0;
    public var song_favorite                            : Dynamic= false;
    
    public function new(source_engine                            : Dynamic, source_id                            : Dynamic, source_data                            : Dynamic)
    
    {
engine = source_engine;
        level_id = source_id;
        
        // From JSON
        if (as3hx.Compat.truthy(source_data == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(source_data.notes != null))
        {
            notes = source_data.notes;
        }
        
        if (as3hx.Compat.truthy(source_data.set_mirror_invert != null))
        {
            set_mirror_invert = source_data.set_mirror_invert;
        }
        
        if (as3hx.Compat.truthy(source_data.set_custom_offsets != null))
        {
            set_custom_offsets = source_data.set_custom_offsets;
        }
        
        if (as3hx.Compat.truthy(source_data.offset_music != null))
        {
            offset_music = source_data.offset_music;
        }
        
        if (as3hx.Compat.truthy(source_data.offset_judge != null))
        {
            offset_judge = source_data.offset_judge;
        }
        
        if (as3hx.Compat.truthy(source_data.song_favorite != null))
        {
            song_favorite = source_data.song_favorite;
        }
        
        if (as3hx.Compat.truthy(source_data.song_rating != null))
        {
            song_rating = source_data.song_rating;
        }
    }
    
    /**
     * Called when `JSON.stringify` is called on this object automatically.
     * @param k
     * @return Object representing this class.
     */
    public function toJSON(k                            : Dynamic) : Dynamic
    {
        var out                            : Dynamic= { };
        
        if (as3hx.Compat.truthy(notes.length > 0))
        {
            Reflect.setField(out, "notes", notes);
        }
        
        if (as3hx.Compat.truthy(offset_music != 0))
        {
            Reflect.setField(out, "offset_music", offset_music);
        }
        
        if (as3hx.Compat.truthy(offset_judge != 0))
        {
            Reflect.setField(out, "offset_judge", offset_judge);
        }
        
        if (as3hx.Compat.truthy(set_mirror_invert))
        {
            Reflect.setField(out, "set_mirror_invert", set_mirror_invert);
        }
        
        if (as3hx.Compat.truthy(set_custom_offsets))
        {
            Reflect.setField(out, "set_custom_offsets", set_custom_offsets);
        }
        
        if (as3hx.Compat.truthy(song_favorite))
        {
            Reflect.setField(out, "song_favorite", song_favorite);
        }
        
        if (as3hx.Compat.truthy(song_rating != 0))
        {
            Reflect.setField(out, "song_rating", song_rating);
        }
        
        return out;
    }
}

