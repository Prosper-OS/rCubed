package game.events;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class GamePlaybackReader
{
    public static function parse(data : ByteArray, initialPosition : Int = 0, output : Array<GamePlaybackEvent> = null) : Array<GamePlaybackEvent>
    {
        var lastIndex : Int = -1;
        
        // Use new History if not provided.
        if (output == null)
        {
            output = [];
        }
        else if (output.length > 0)
        {
            lastIndex = output[output.length - 1].index;
        }
        
        try
        {
            data.position = initialPosition;
            
            while (data.bytesAvailable > 0)
            {
                var TAG : Int = data.readUnsignedByte();
                var LEN : Int = data.readUnsignedByte();
                
                var event : GamePlaybackEvent;
                
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
                
                if (event == null)
                {
                    continue;
                }
                
                if (event.index > lastIndex)
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

