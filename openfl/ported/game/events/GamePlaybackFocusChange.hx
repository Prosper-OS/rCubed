package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackFocusChange extends GamePlaybackEvent
{
    public static inline var ID : Int = 5;
    
    public var isFocus : Bool;
    
    public function new(index : Int, timestamp : Int, isFocus : Bool)
    {
        super(ID, index, timestamp);
        this.isFocus = isFocus;
    }
    
    override public function writeData(output : IDataOutput) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte((isFocus) ? 1 : 0);
    }
    
    public static function readData(input : IDataInput) : GamePlaybackFocusChange
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        var isFocus : Bool = (input.readUnsignedByte() == 1) ? true : false;
        
        return new GamePlaybackFocusChange(index, timestamp, isFocus);
    }
}

