package classes;

import com.flashfla.media.MP3Extraction;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.ByteArray;

class SongPlayerBytes
{
    public var sound : Sound;
    public var soundChannel : SoundChannel;
    
    public var isPlaying : Bool = false;
    public var userPaused : Bool = false;
    public var userStopped : Bool = false;
    
    private var pausePosition : Int = 0;
    private var _noRepeat : Bool;
    
    public function new(swfBytes : ByteArray, isMP3File : Bool = false, noRepeat : Bool = false)
    {
        if (swfBytes != null && swfBytes.length > 0)
        {
            if (!isMP3File)
            {
                swfBytes = MP3Extraction.extractSound(swfBytes);
            }
            
            swfBytes.position = 0;
            sound = new Sound();
            sound.loadCompressedDataFromByteArray(swfBytes, swfBytes.length);
        }
        _noRepeat = noRepeat;
    }
    
    public function start() : Void
    {
        if (sound == null || userPaused)
        {
            return;
        }
        
        stop();
        soundChannel = sound.play(pausePosition);
        soundChannel.soundTransform = GlobalVariables.instance.menuMusicSoundTransform;
        soundChannel.addEventListener(Event.SOUND_COMPLETE, onComplete);
        isPlaying = true;
    }
    
    private function onComplete(e : Event) : Void
    {
        cast((e.target), SoundChannel).removeEventListener(e.type, onComplete);
        pausePosition = 0;
        if (_noRepeat)
        {
            isPlaying = false;
        }
        else
        {
            start();
        }
    }
    
    public function stop() : Void
    {
        if (soundChannel != null)
        {
            soundChannel.stop();
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
        }
        
        isPlaying = false;
    }
    
    public function userPause() : Void
    {
        pausePosition = soundChannel.position;
        userPaused = true;
        stop();
    }
    
    public function userStart() : Void
    {
        userPaused = userStopped = false;
        start();
    }
    
    public function userStop() : Void
    {
        pausePosition = 0;
        userStopped = true;
        stop();
    }
}


