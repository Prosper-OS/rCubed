package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackSpectatorHit extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 6;
    
    public var direction                       : Dynamic;
    
    public function new(index                       : Dynamic, timestamp                       : Dynamic, direction                       : Dynamic)
    {
        super(ID, index, timestamp);
        this.direction = direction;
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(direction.charCodeAt(0));
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackSpectatorHit
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        var direction                       : Dynamic= String.fromCharCode(input.readByte());
        
        return new GamePlaybackSpectatorHit(index, timestamp, direction);
    }
    
    public function toString() : String
    {
        return "[GamePlaybackSpectatorHit = " + index + ":" + timestamp + ":" + direction + "]";
    }
}

