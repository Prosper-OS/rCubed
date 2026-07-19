package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackSpectatorHit extends GamePlaybackEvent
{
    public static inline var ID : Int = 6;
    
    public var direction : String;
    
    public function new(index : Int, timestamp : Float, direction : String)
    {
        super(ID, index, timestamp);
        this.direction = direction;
    }
    
    override public function writeData(output : IDataOutput) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 1);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeByte(direction.charCodeAt(0));
    }
    
    public static function readData(input : IDataInput) : GamePlaybackSpectatorHit
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        var direction : String = String.fromCharCode(input.readByte());
        
        return new GamePlaybackSpectatorHit(index, timestamp, direction);
    }
    
    public function toString() : String
    {
        return "[GamePlaybackSpectatorHit = " + index + ":" + timestamp + ":" + direction + "]";
    }
}

