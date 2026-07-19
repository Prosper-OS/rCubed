package classes;

import openfl.display.Sprite;

class GameNote extends Sprite
{
    private static var _noteskins                              : Dynamic= Noteskins.instance;
    
    private var _note                              : Dynamic;
    public var NOTESKIN                              : Dynamic= 0;
    public var ID                              : Dynamic= 0;
    public var DIR                              : Dynamic;
    public var COLOR                              : Dynamic;
    public var POSITION                              : Dynamic= 0;
    public var FRAME                              : Dynamic= 0;
    public var SPAWN_PROGRESS                              : Dynamic= 0;
    
    public function new(id                              : Dynamic, dir                              : Dynamic, color                              : Dynamic, position                              : Dynamic= 0, frame                              : Dynamic= 0, activeNoteSkin                              : Dynamic= 1)
    {
        super();
        this.NOTESKIN = activeNoteSkin;
        this.ID = id;
        this.DIR = dir;
        this.COLOR = color;
        this.POSITION = position;
        this.FRAME = frame;
        
        var _noteInfo                              : Dynamic= _noteskins.getInfo(activeNoteSkin);
        _note = _noteskins.getNote(activeNoteSkin, this.COLOR, this.DIR);
        _note.x = -(_noteInfo.width >> 1);
        _note.y = -(_noteInfo.height >> 1);
        this.addChild(_note);
    }
    
    public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_note != null && this.contains(_note)))
        {
            this.removeChild(_note);
        }
        
        _note = null;
    }
}


