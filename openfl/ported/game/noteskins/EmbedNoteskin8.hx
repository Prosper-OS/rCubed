package game.noteskins;

import openfl.utils.ByteArray;

class EmbedNoteskin8 extends EmbedNoteskinBase
{
    @:meta(Embed(source="NoteSkin8.swf",mimeType="application/octet-stream"))

    private static var EMBED_SWF                       : Dynamic;
    
    private static inline var ID                       : Dynamic= 8;
    
    override public function getData() : Dynamic
    {
        return {
            id : ID,
            name : "BeatMania (v2)",
            rotation : 0,
            width : 70,
            height : 51
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

