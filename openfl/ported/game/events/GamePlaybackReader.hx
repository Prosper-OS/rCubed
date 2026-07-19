package game.events;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class GamePlaybackReader
{
    public static function parse(data                       : Dynamic, initialPosition                       : Dynamic= 0, output                       : Dynamic= null) : Array<GamePlaybackEvent>
    {
        var lastIndex                       : Dynamic= -1;
        
        // Use new History if not provided.
        if (as3hx.Compat.truthy(output == null))
        {
            output = [];
        }
        else if (as3hx.Compat.truthy(output.length > 0))
        {
            lastIndex = output[as3hx.Compat.parseInt(output.length - 1)].index;
        }
        
        try
        {
            data.position = initialPosition;
            
            while (as3hx.Compat.truthy(data.bytesAvailable > 0))
            {
                var TAG                       : Dynamic= data.readUnsignedByte();
                var LEN                       : Dynamic= data.readUnsignedByte();
                
                var event                       : Dynamic= null;
                
                switch (TAG)
                {
                    case GamePlaybackScoreState.ID:
                        event = GamePlaybackScoreState.readData(data);
                    
                    case GamePlaybackJudgeResult.ID:
                        event = GamePlaybackJudgeResult.readData(data);
                    
                    case GamePlaybackKeyDown.ID:
                        event = GamePlaybackKeyDown.readData(data);
                    
                    case GamePlaybackKeyUp.ID:
                        event = GamePlaybackKeyUp.readData(data);
                    
                    case GamePlaybackFocusChange.ID:
                        event = GamePlaybackFocusChange.readData(data);
                    
                    case GamePlaybackSpectatorHit.ID:
                        event = GamePlaybackSpectatorHit.readData(data);
                    
                    case GamePlaybackSpectatorEnd.ID:
                        event = GamePlaybackSpectatorEnd.readData(data);
                    default:
                        trace("unknown tag", TAG, "length", LEN);
                        event = null;
                        data.position += LEN;
                }
                
                if (as3hx.Compat.truthy(event == null))
                {
                    continue;
                }
                
                if (as3hx.Compat.truthy(event.index > lastIndex))
                {
                    output.push(event);
                }
            }
        }
        catch (e : Error)
        {
            return null;
        }
        
        return output;
    }

    public function new()
    {
    }
}

