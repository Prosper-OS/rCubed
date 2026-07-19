package classes;

import openfl.display.Sprite;

class GameNote extends Sprite
{
    private static var _noteskins : Noteskins = Noteskins.instance;
    
    private var _note : Sprite;
    public var NOTESKIN : Int = 0;
    public var ID : Int = 0;
    public var DIR : String;
    public var COLOR : String;
    public var POSITION : Int = 0;
    public var FRAME : Int = 0;
    public var SPAWN_PROGRESS : Int = 0;
    
    public function new(id : Int, dir : String, color : String, position : Int = 0, frame : Int = 0, activeNoteSkin : Int = 1)
    {
        super();
        this.NOTESKIN = activeNoteSkin;
        this.ID = id;
        this.DIR = dir;
        this.COLOR = color;
        this.POSITION = position;
        this.FRAME = frame;
        
        var _noteInfo : Dynamic = _noteskins.getInfo(activeNoteSkin);
        _note = _noteskins.getNote(activeNoteSkin, this.COLOR, this.DIR);
        _note.x = -(_noteInfo.width >> 1);
        _note.y = -(_noteInfo.height >> 1);
        this.addChild(_note);
    }
    
    public function dispose() : Void
    {
        if (_note != null && this.contains(_note))
        {
            this.removeChild(_note);
        }
        
        _note = null;
    }
}


