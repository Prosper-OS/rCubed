package game.events;

import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class GamePlaybackScoreState extends GamePlaybackEvent
{
    public static inline var ID : Int = 1;
    
    public var raw_score : Int;
    public var amazing : Int;
    public var perfect : Int;
    public var good : Int;
    public var average : Int;
    public var miss : Int;
    public var boo : Int;
    public var combo : Int;
    public var max_combo : Int;
    
    public function new(index : Int, timestamp : Float)
    {
        super(ID, index, timestamp);
    }
    
    override public function writeData(output : IDataOutput) : Void
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
    
    public static function readData(input : IDataInput) : GamePlaybackScoreState
    {
        var index : Int = input.readUnsignedInt();
        var timestamp : Int = input.readUnsignedInt();
        
        var state : GamePlaybackScoreState = new GamePlaybackScoreState(index, timestamp);
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

