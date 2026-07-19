package classes;

import com.flashfla.media.MP3Extraction;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.ByteArray;

class SongPlayerBytes
{
    public var sound                              : Dynamic;
    public var soundChannel                              : Dynamic;
    
    public var isPlaying                              : Dynamic= false;
    public var userPaused                              : Dynamic= false;
    public var userStopped                              : Dynamic= false;
    
    private var pausePosition                              : Dynamic= 0;
    private var _noRepeat                              : Dynamic;
    
    public function new(swfBytes                              : Dynamic, isMP3File                              : Dynamic= false, noRepeat                              : Dynamic= false)
    {
        if (as3hx.Compat.truthy(swfBytes != null && swfBytes.length > 0))
        {
            if (as3hx.Compat.truthy(!isMP3File))
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
        if (as3hx.Compat.truthy(sound == null || userPaused))
        {
            return;
        }
        
        stop();
        soundChannel = sound.play(pausePosition);
        soundChannel.soundTransform = GlobalVariables.instance.menuMusicSoundTransform;
        soundChannel.addEventListener(Event.SOUND_COMPLETE, onComplete);
        isPlaying = true;
    }
    
    private function onComplete(e                              : Dynamic) : Void
    {
        cast((e.target), SoundChannel).removeEventListener(e.type, onComplete);
        pausePosition = 0;
        if (as3hx.Compat.truthy(_noRepeat))
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
        if (as3hx.Compat.truthy(soundChannel != null))
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


