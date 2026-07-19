package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackSpectatorEnd extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 7;
    
    public var direction                       : Dynamic;
    
    public function new(index                       : Dynamic, timestamp                       : Dynamic)
    {
        super(ID, index, timestamp);
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(0);
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackSpectatorEnd
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        var end_type                       : Dynamic= input.readByte();
        
        return new GamePlaybackSpectatorEnd(index, timestamp);
    }
    
    public function toString() : String
    {
        return "[GamePlaybackSpectatorEnd = " + index + ":" + timestamp + "]";
    }
}

