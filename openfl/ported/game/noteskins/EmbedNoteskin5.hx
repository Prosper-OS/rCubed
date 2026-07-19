package game.noteskins;

import openfl.utils.ByteArray;

class EmbedNoteskin5 extends EmbedNoteskinBase
{
    @:meta(Embed(source="NoteSkin5.swf",mimeType="application/octet-stream"))

    private static var EMBED_SWF : Class<Dynamic>;
    
    private static inline var ID : Int = 5;
    
    override public function getData() : Dynamic
    {
        return {
            id : ID,
            name : "Metal",
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

