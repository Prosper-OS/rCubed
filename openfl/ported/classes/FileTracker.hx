package classes;

import com.flashfla.utils.NumberUtil;

class FileTracker
{
    public var size_human(get, never)                              : Dynamic;

    public var files                              : Dynamic= 0;
    public var dirs                              : Dynamic= 0;
    public var size                              : Dynamic= 0;
    public var file_paths                              : Dynamic= new Array<String>();
    
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


