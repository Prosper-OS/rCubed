package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackJudgeResult extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 2;
    
    public var noteID                       : Dynamic;
    public var accuracy                       : Dynamic;
    
    public function new(index                       : Dynamic, noteID                       : Dynamic, accuracy                       : Dynamic, timestamp                       : Dynamic)
    {
        super(ID, index, timestamp);
        this.noteID = index;
        this.accuracy = accuracy;
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 4 + 2);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeInt(noteID);
        output.writeShort(accuracy);
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackJudgeResult
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        var noteID                       : Dynamic= input.readInt();
        var accuracy                       : Dynamic= input.readShort();
        
        return new GamePlaybackJudgeResult(index, noteID, accuracy, timestamp);
    }
    
    public function toString() : String
    {
        return index + ":" + timestamp + ":" + noteID + ":" + accuracy;
    }
}

