package popups.filebrowser;


class FileFolderItem
{
    public var loc : String;
    public var info : Dynamic;
    
    public function new(loc : String, info : Dynamic)
    {
        this.loc = loc;
        this.info = info;
    }
}

