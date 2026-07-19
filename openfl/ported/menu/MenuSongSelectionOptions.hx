package menu;


class MenuSongSelectionOptions
{
    public var activeGenre : Int = 0;
    public var activeIndex : Int = -1;
    public var activeSongId : Int = -1;
    public var pageNumber : Int = 0;
    public var infoTab : Int = 0;
    
    public var scroll_position : Float = 0;
    
    public var last_search_text : String;
    public var last_search_type : String;
    
    public var last_sort_type : String;
    public var last_sort_order : String;
    
    public var isFilter : Bool = false;
    public var filter : Dynamic = null;
    
    public var queuePlaylist : Array<Dynamic> = [];

    public function new()
    {
    }
}

