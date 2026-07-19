package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackKeyUp extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 4;
    
    public var key                       : Dynamic;
    
    public function new(index                       : Dynamic, timestamp                       : Dynamic, key                       : Dynamic)
    {
        super(ID, index, timestamp);
        this.key = key;
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(key);
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackKeyUp
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        var key                       : Dynamic= input.readUnsignedByte();
        
        return new GamePlaybackKeyUp(index, timestamp, key);
    }
}

