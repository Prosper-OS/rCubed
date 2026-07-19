package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackScoreState extends GamePlaybackEvent
{
    public static inline var ID                       : Dynamic= 1;
    
    public var raw_score                       : Dynamic;
    public var amazing                       : Dynamic;
    public var perfect                       : Dynamic;
    public var good                       : Dynamic;
    public var average                       : Dynamic;
    public var miss                       : Dynamic;
    public var boo                       : Dynamic;
    public var combo                       : Dynamic;
    public var max_combo                       : Dynamic;
    
    public function new(index                       : Dynamic, timestamp                       : Dynamic)
    {
        super(ID, index, timestamp);
    }
    
    override public function writeData(output                       : Dynamic) : Void
    {
        output.writeByte(ID);
        output.writeByte(4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4);  // Length of everything below this.  
        output.writeUnsignedInt(index);
        output.writeUnsignedInt(timestamp);
        output.writeInt(raw_score);
        output.writeInt(amazing);
        output.writeInt(perfect);
        output.writeInt(good);
        output.writeInt(average);
        output.writeInt(miss);
        output.writeInt(boo);
        output.writeInt(combo);
        output.writeInt(max_combo);
    }
    
    public static function readData(input                       : Dynamic) : GamePlaybackScoreState
    {
        var index                       : Dynamic= input.readUnsignedInt();
        var timestamp                       : Dynamic= input.readUnsignedInt();
        
        var state                       : Dynamic= new GamePlaybackScoreState(index, timestamp);
        state.raw_score = input.readInt();
        state.amazing = input.readInt();
        state.perfect = input.readInt();
        state.good = input.readInt();
        state.average = input.readInt();
        state.miss = input.readInt();
        state.boo = input.readInt();
        state.combo = input.readInt();
        state.max_combo = input.readInt();
        
        return state;
    }
    
    public function toString() : String
    {
        return index + ":" + timestamp + ":" + raw_score;
    }
}

