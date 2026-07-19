package game.events;

import openfl.utils.IDataOutput;

class GamePlaybackEvent
{
    public var id                       : Dynamic;
    public var index                       : Dynamic;
    public var timestamp                       : Dynamic;
    
    public function new(id                       : Dynamic, index                       : Dynamic, timestamp                       : Dynamic)
    {
        this.id = id;
        this.index = index;
        this.timestamp = timestamp;
    }
    
    public function writeData(output                       : Dynamic) : Void
    {
    }
}

