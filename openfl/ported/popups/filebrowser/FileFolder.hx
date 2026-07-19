package popups.filebrowser;


class FileFolder
{
    public var folder                       : Dynamic;
    public var file                       : Dynamic;
    public var data                       : Dynamic;
    
    public var author                       : Dynamic;
    public var name                       : Dynamic;
    public var stepauthor                       : Dynamic;
    public var banner                       : Dynamic;
    public var ext                       : Dynamic;
    
    public function new(folder                       : Dynamic, file                       : Dynamic, ext                       : Dynamic, item                       : Dynamic)
    {
        this.folder = folder;
        this.file = file;
        this.ext = ext;
        this.data = [item];
    }
}

