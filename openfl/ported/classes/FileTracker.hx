package classes;

import com.flashfla.utils.NumberUtil;

class FileTracker
{
    public var size_human(get, never) : String;

    public var files : Float = 0;
    public var dirs : Float = 0;
    public var size : Float = 0;
    public var file_paths : Array<String> = new Array<String>();
    
    private function get_size_human() : String
    {
        return NumberUtil.bytesToString(size);
    }
    
    public function toString() : String
    {
        return "[files=" + files + " dirs=" + dirs + " size=" + size + " size_human=" + size_human + "]";
    }

    public function new()
    {
    }
}


