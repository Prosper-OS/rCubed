package game.events;

import openfl.utils.IDataOutput;

class GamePlaybackEvent
{
    public var id : Int;
    public var index : Int;
    public var timestamp : Int;
    
    public function new(id : Int, index : Int, timestamp : Int)
    {
        this.id = id;
        this.index = index;
        this.timestamp = timestamp;
    }
    
    public function writeData(output : IDataOutput) : Void
    {
    }
}

