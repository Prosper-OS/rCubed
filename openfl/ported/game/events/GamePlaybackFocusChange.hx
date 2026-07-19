package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackFocusChange extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 5;
    
    public var isFocus                       : Dynamic;
    
    public function new(index                       : Dynamic, timestamp                       : Dynamic, isFocus                       : Dynamic)
    {
        super(ID, index, timestamp);
        this.isFocus = isFocus;
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte((isFocus) ? 1 : 0);
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackFocusChange
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        var isFocus                       : Dynamic= (input.readUnsignedByte() == 1) ? true : false;
        
        return new GamePlaybackFocusChange(index, timestamp, isFocus);
    }
}

