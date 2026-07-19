package game.noteskins;

import openfl.utils.ByteArray;

class EmbedNoteskin3 extends EmbedNoteskinBase
{
    @:meta(Embed(source="NoteSkin3.swf",mimeType="application/octet-stream"))

    private static var EMBED_SWF                       : Dynamic;
    
    private static inline var ID                       : Dynamic= 3;
    
    override public function getData() : Dynamic
    {
        return {
            id : ID,
            name : "BeatMania",
            rotation : 0,
            width : 88,
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

