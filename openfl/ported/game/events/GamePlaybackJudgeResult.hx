package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackJudgeResult extends GamePlaybackEvent
{
    public static inline var ID : Int = 2;
    
    public var noteID : Int;
    public var accuracy : Int;
    
    public function new(index : Int, noteID : Int, accuracy : Int, timestamp : Float)
    {
        super(ID, index, timestamp);
        this.noteID = index;
        this.accuracy = accuracy;
    }
    
    override public function writeData(output : IDataOutput) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 4 + 2);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeInt(noteID);
        output.writeShort(accuracy);
    }
    
    public static function readData(input : IDataInput) : GamePlaybackJudgeResult
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        var noteID : Int = input.readInt();
        var accuracy : Int = input.readShort();
        
        return new GamePlaybackJudgeResult(index, noteID, accuracy, timestamp);
    }
    
    public function toString() : String
    {
        return index + ":" + timestamp + ":" + noteID + ":" + accuracy;
    }
}

