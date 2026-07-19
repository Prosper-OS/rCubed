package menu;


class MenuSongSelectionOptions
{
    public var activeGenre                       : Dynamic= 0;
    public var activeIndex                       : Dynamic= -1;
    public var activeSongId                       : Dynamic= -1;
    public var pageNumber                       : Dynamic= 0;
    public var infoTab                       : Dynamic= 0;
    
    public var scroll_position                       : Dynamic= 0;
    
    public var last_search_text                       : Dynamic;
    public var last_search_type                       : Dynamic;
    
    public var last_sort_type                       : Dynamic;
    public var last_sort_order                       : Dynamic;
    
    public var isFilter                       : Dynamic= false;
    public var filter                       : Dynamic= null;
    
    public var queuePlaylist                       : Dynamic= [];

    public function new()
    {
    }
}

