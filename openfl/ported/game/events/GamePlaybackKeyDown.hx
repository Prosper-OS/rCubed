package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackKeyDown extends GamePlaybackEvent
{
    public static inline var ID : Int = 3;
    
    public var key : Int;
    
    public function new(index : Int, timestamp : Float, key : Int)
    {
        super(ID, index, timestamp);
        this.key = key;
    }
    
    override public function writeData(output : IDataOutput) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(key);
    }
    
    public static function readData(input : IDataInput) : GamePlaybackKeyDown
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        var key : Int = input.readUnsignedByte();
        
        return new GamePlaybackKeyDown(index, timestamp, key);
    }
}

