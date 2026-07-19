package popups.filebrowser;


class FileFolder
{
    public var folder : String;
    public var file : String;
    public var data : Array<FileFolderItem>;
    
    public var author : String;
    public var name : String;
    public var stepauthor : String;
    public var banner : String;
    public var ext : String;
    
    public function new(folder : String, file : String, ext : String, item : FileFolderItem)
    {
        this.folder = folder;
        this.file = file;
        this.ext = ext;
        this.data = [item];
    }
}

