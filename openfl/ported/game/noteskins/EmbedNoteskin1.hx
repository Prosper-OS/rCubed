package game.noteskins;

import openfl.utils.ByteArray;

class EmbedNoteskin1 extends EmbedNoteskinBase
{
    @:meta(Embed(source="NoteSkin1.swf",mimeType="application/octet-stream"))

    private static var EMBED_SWF                       : Dynamic;
    
    private static inline var ID                       : Dynamic= 1;
    
    override public function getData() : Dynamic
    {
        return {
            id : ID,
            name : "Default",
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

