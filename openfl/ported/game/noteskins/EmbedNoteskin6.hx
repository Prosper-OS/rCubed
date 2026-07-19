package game.noteskins;

import openfl.utils.ByteArray;

class EmbedNoteskin6 extends EmbedNoteskinBase
{
    @:meta(Embed(source="NoteSkin6.swf",mimeType="application/octet-stream"))

    private static var EMBED_SWF                       : Dynamic;
    
    private static inline var ID                       : Dynamic= 6;
    
    override public function getData() : Dynamic
    {
        return {
            id : ID,
            name : "Delta",
            rotation : 90,
            width : 64,
            height : 64
        };
    }
    
    override public function getBytes() : ByteArray
    {
        return Type.createInstance(EMBED_SWF, []);
    }
    
    override public function getID() : Int
    {
        return ID;
    }

    public function new()
    {
        super();
    }
}

