package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackSpectatorEnd extends GamePlaybackEvent
{
    public static inline var ID : Int = 7;
    
    public var direction : String;
    
    public function new(index : Int, timestamp : Float)
    {
        super(ID, index, timestamp);
    }
    
    override public function writeData(output : IDataOutput) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(0);
    }
    
    public static function readData(input : IDataInput) : GamePlaybackSpectatorEnd
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        var end_type : Int = input.readByte();
        
        return new GamePlaybackSpectatorEnd(index, timestamp);
    }
    
    public function toString() : String
    {
        return "[GamePlaybackSpectatorEnd = " + index + ":" + timestamp + "]";
    }
}

