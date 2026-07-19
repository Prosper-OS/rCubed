package classes.chart;

import openfl.errors.Error;
import by.blooddy.crypto.MD5;
import classes.SongInfo;
import classes.chart.parse.ChartFFRLegacy;
import com.flashfla.media.MP3Extraction;
import com.flashfla.media.SwfSilencer;
import com.flashfla.net.ForcibleLoader;
import com.flashfla.utils.TimeUtil;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SampleDataEvent;
import openfl.events.SecurityErrorEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundMixer;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import game.GameOptions;

class Song extends EventDispatcher
{
    public var progress(get, never) : Int;
    public var totalNotes(get, never) : Int;
    public var chartTime(get, never) : Float;
    public var chartTimeFormatted(get, never) : String;

    private var _gvars : GlobalVariables = GlobalVariables.instance;
    
    public var musicLoader : Dynamic;
    
    public var id : Int;
    public var songInfo : SongInfo;
    public var type : String;
    
    public var isDirty : Bool = true;
    
    private var baseSound : Sound;
    public var sound : Sound;
    public var background : MovieClip;
    public var chart : NoteChart;
    
    public var noteMod : NoteMod;
    public var options : GameOptions;
    public var soundChannel : SoundChannel;
    public var musicPausePosition : Int;
    public var musicIsPlaying : Bool = false;
    public var mp3Frame : Int = 0;
    public var mp3Rate : Float = 1;
    
    private var rateReverse : Bool = false;
    private var rateRate : Float = 1;
    private var rateSample : Int = 0;
    private var rateSampleCount : Int = 0;
    private var rateSamples : ByteArray = new ByteArray();
    
    public var isLoaded : Bool = false;
    public var isChartLoaded : Bool = false;
    public var isMusicLoaded : Bool = false;
    public var loadFail : Bool = false;
    
    public var isMusicLoaderLoading : Bool = false;
    
    public var bytesSWF : ByteArray = null;
    public var bytesLoaded : Int = 0;
    public var bytesTotal : Int = 0;
    
    private var musicForcibleLoader : ForcibleLoader;
    
    public var musicStartFrames : Int = 0;
    public var musicStartTime : Int = 0;
    
    private var localFileData : ByteArray = null;
    private var localFileHash : String = "";
    
    public function new(songInfo : SongInfo, doLoad : Bool = true)
    {
        super();
        this.songInfo = songInfo;
        this.id = songInfo.level;
        this.type = songInfo.chart_type || NoteChart.FFR_MP3;
        
        options = _gvars.options;
        
        if (type == "EDITOR")
        {
            chart = new NoteChart(null);
            return;
        }
        
        if (doLoad)
        {
            load();
        }
    }
    
    public function unload() : Void
    {
        removeLoaderListeners();
        isLoaded = isChartLoaded = isMusicLoaded = false;
        loadFail = true;
        
        if (musicLoader != null && isMusicLoaderLoading)
        {
            musicLoader.close();
            isMusicLoaderLoading = false;
        }
        
        background = null;
        chart = null;
    }
    
    private function load() : Void
    // Load Stored SWF
    {
        
        var url_file_hash : String = "";
        if ((_gvars.air_useLocalFileCache) && AirContext.doesFileExist(AirContext.getSongCachePath(this) + "data.bin"))
        {
            localFileData = AirContext.readFile(AirContext.getAppFile(AirContext.getSongCachePath(this) + "data.bin"), (songInfo.engine) ? 0 : id);
            localFileHash = MD5.hashBytes(localFileData);
            url_file_hash = "hash=" + localFileHash + "&";
            
            if (songInfo.engine)
            {
                if (localFileData != null && localFileHash == songInfo.swf_hash && type == NoteChart.FFR_MP3)
                {
                    removeLoaderListeners();
                    musicLoader = new Loader();
                    addLoaderListeners(true);
                    musicLoader.loadBytes(localFileData, AirContext.getLoaderContext());
                    return;
                }
            }
        }
        
        switch (type)
        {
            case NoteChart.FFR_MP3:
                musicLoader = new URLLoader();
                addLoaderListeners();
                musicLoader.dataFormat = URLLoaderDataFormat.BINARY;
                musicLoader.load(new URLRequest(urlGen(url_file_hash)));
                isMusicLoaderLoading = true;
            default:
        }
    }
    
    private function get_progress() : Int
    {
        if (musicLoader != null)
        {
            return Math.floor(((bytesLoaded / bytesTotal) * 99) + ((isChartLoaded) ? 1 : 0));
        }
        
        return 0;
    }
    
    public function getMusicContentLoader(isLoader : Bool = false) : Dynamic
    {
        if (isLoader)
        {
            return musicLoader.contentLoaderInfo;
        }
        
        return (type == NoteChart.FFR_MP3) ? musicLoader : musicLoader.contentLoaderInfo;
    }
    
    private function urlGen(fileHash : String = "") : String
    {
        if (songInfo.engine)
        {
            return ChartFFRLegacy.songUrl(songInfo);
        }
        
        return URLs.resolve(URLs.SONG_DATA_URL) + "?" + fileHash + "id=" + songInfo.play_hash + ((_gvars.userSession != "0") ? "&session=" + _gvars.userSession : "");
    }
    
    private function addLoaderListeners(isLoader : Bool = false) : Void
    {
        var music : Dynamic = getMusicContentLoader(isLoader);
        
        if (music != null)
        {
            music.addEventListener(Event.COMPLETE, musicCompleteHandler);
            music.addEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
            music.addEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
        }
        
        if (musicLoader != null)
        {
            musicLoader.addEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }
    }
    
    private function removeLoaderListeners() : Void
    {
        var music : Dynamic = getMusicContentLoader();
        
        if (music != null)
        {
            music.removeEventListener(Event.COMPLETE, musicCompleteHandler);
            music.removeEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
            music.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
        }
        
        if (musicLoader != null)
        {
            musicLoader.removeEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }
    }
    
    public function loadComplete() : Void
    {
        if (isChartLoaded && isMusicLoaded)
        {
            removeLoaderListeners();
            isLoaded = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    private function musicProgressHandler(e : ProgressEvent) : Void
    {
        bytesLoaded = e.bytesLoaded;
        bytesTotal = e.bytesTotal;
    }
    
    private function musicCompleteHandler(e : Event) : Void
    {
        Logger.success(this, "Music Load Success");
        var chartData : ByteArray;
        if (type == NoteChart.FFR_MP3)
        {
            if (Std.is(e.target, URLLoader))
            {
                chartData = e.target.data;
            }
            else if (Std.is(e.target, LoaderInfo))
            {
                chartData = e.target.bytes;
            }
            
            bytesLoaded = bytesTotal = chartData.length;  // Update Progress Bar in case.  
            
            // Check 404 Response
            if (chartData.length == 0 || (chartData.length == 3 && chartData.readUTFBytes(3) == "404"))
            {
                loadFail = true;
                return;
            }
            
            // Check for server response for matching hash. Encode Compressed SWF Data
            var storeChartData : ByteArray;
            if (_gvars.air_useLocalFileCache) {
if (this.songInfo.engine && localFileData != null)
                {
                }
                else if (chartData.length == 3)
                {
                    chartData.position = 0;
                    var code : String = chartData.readUTFBytes(3);
                    if (code == "404")
                    {
                        loadFail = true;
                        return;
                    }
                    if (code == "403")
                    {
                        chartData = localFileData;
                        bytesLoaded = bytesTotal = localFileData.length;
                    }
                }
                else
                {
                    storeChartData = AirContext.encodeData(chartData, (this.songInfo.engine) ? 0 : this.id);
                }
            }
            
            // Parse Chart
            chart = NoteChart.parseChart(NoteChart.FFR_LEGACY, songInfo, chartData);
            chartLoadComplete(e);
            
            // Extract MP3 Data and load into Sound.
            var metadata : Dynamic = { };
            loadSoundBytes(MP3Extraction.extractSound(chartData, metadata));
            mp3Frame = as3hx.Compat.parseInt(metadata.frame - 2);
            mp3Rate = MP3Extraction.formatRate(metadata.format) / 44100;
            
            // Generate a SWF containing no audio, used as a background.
            var mloader : Loader = new Loader();
            var mbytes : ByteArray = SwfSilencer.stripSound(chartData);
            mloader.contentLoaderInfo.addEventListener(Event.COMPLETE, backgoundCompleteHandler);
            if (mbytes == null)
            {
                loadFail = true;
                return;
            }
            mloader.loadBytes(mbytes, AirContext.getLoaderContext());
            
            // Store SWF
            if (_gvars.air_useLocalFileCache && storeChartData != null)
            {
                try
                {
                    Logger.info(this, "Saving Cache File for " + this.id + " / " + this.songInfo.level_id);
                    AirContext.writeFile(AirContext.getAppFile(AirContext.getSongCachePath(this) + "data.bin"), storeChartData);
                }
                catch (err : Error)
                {
                    Logger.error(this, "Cache write failed: " + Logger.exception_error(err));
                }
            }
            
            loadComplete();
        }
        
        bytesSWF = chartData;
    }
    
    private function backgoundCompleteHandler(e : Event) : Void
    {
        var info : LoaderInfo = try cast(e.currentTarget, LoaderInfo) catch(e:Dynamic) null;
        background = try cast(info.content, MovieClip) catch(e:Dynamic) null;
        
        isMusicLoaded = true;
        loadComplete();
    }
    
    private function chartLoadComplete(e : Event = null) : Void
    {
        Logger.success(this, "Chart Load Success");
        Logger.info(this, "Chart parsed with " + chart.Notes.length + " notes, " + ((chart.Notes.length > 0) ? TimeUtil.convertToHHMMSS(chart.Notes[chart.Notes.length - 1].time) : "0:00") + " length.");
        
        isChartLoaded = true;
        loadComplete();
    }
    
    private function musicLoadError(err : ErrorEvent = null) : Void
    {
        Logger.error(this, "Music Load Error: " + Logger.event_error(err));
        isMusicLoaderLoading = false;
        removeLoaderListeners();
        loadFail = true;
    }
    
    public function handleDirty(options : GameOptions) : Void
    {
        if (!isDirty)
        {
            return;
        }
        
        // Remove Old Sound
        if (sound != null)
        {
            sound.removeEventListener("sampleData", onReverseSound);
            sound.removeEventListener("sampleData", onRateSound);
            sound = null;
        }
        
        if (soundChannel != null)
        {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
            soundChannel.stop();
        }
        
        noteMod = new NoteMod(this, options);
        rateReverse = options.modEnabled("reverse");
        rateRate = options.songRate;
        
        // Add Sound
        if (rateRate != 1 || rateReverse)
        {
            sound = new Sound();
            
            if (rateReverse)
            {
                sound.addEventListener("sampleData", onReverseSound);
            }
            else
            {
                sound.addEventListener("sampleData", onRateSound);
            }
        }
        else
        {
            sound = baseSound;
        }
        
        isDirty = false;
    }
    
    public function loadSoundBytes(bytes : ByteArray) : Void
    {
        bytes.position = 0;
        baseSound = new Sound();
        baseSound.loadCompressedDataFromByteArray(bytes, bytes.length);
    }
    
    public function getSoundObject() : Sound
    {
        if (rateRate != 1 || rateReverse)
        {
            return baseSound;
        }
        
        return sound;
    }
    
    private function onRateSound(e : SampleDataEvent) : Void
    {
        var osamples : Int = 0;
        var sample : Int = 0;
        var sampleDiff : Int = 0;
        while (osamples < 4096)
        {
            sample = as3hx.Compat.parseInt((e.position + osamples) * rateRate);
            sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
            while (sampleDiff < 0 || sampleDiff >= rateSampleCount)
            {
                rateSample += rateSampleCount;
                rateSamples.position = 0;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                var seekExtract : Bool = (sampleDiff < 0 || sampleDiff > 8192);
                rateSampleCount = (try cast(baseSound, Dynamic) catch(e:Dynamic) null).extract(rateSamples, 4096, (seekExtract) ? sample * mp3Rate : -1);
                
                if (seekExtract)
                {
                    rateSample = sample;
                    sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                }
                
                if (rateSampleCount <= 0)
                {
                    return;
                }
            }
            rateSamples.position = 8 * sampleDiff;
            e.data.writeFloat(rateSamples.readFloat());
            e.data.writeFloat(rateSamples.readFloat());
            osamples++;
        }
    }
    
    private function onReverseSound(e : SampleDataEvent) : Void
    {
        var osamples : Int = 0;
        while (osamples < 4096)
        {
            var sample : Int = as3hx.Compat.parseInt((e.position + osamples) * rateRate);
            sample = as3hx.Compat.parseInt((chart.Notes[chart.Notes.length - 1].frame * 1470) - sample + (63 - mp3Frame) * 1470 / rateRate);
            if (sample < 0)
            {
                return;
            }
            var sampleDiff : Int = as3hx.Compat.parseInt(sample - rateSample);
            if (sampleDiff < 0 || sampleDiff >= rateSampleCount)
            {
                rateSample += rateSampleCount;
                rateSamples.position = 0;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                var seekPosition : Int = as3hx.Compat.parseInt(sample - 4095);
                rateSampleCount = baseSound.extract(rateSamples, 4096, seekPosition * mp3Rate);
                rateSample = seekPosition;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                
                if (rateSampleCount < 4096)
                {
                    rateSamples.position = rateSampleCount * 8;
                    for (i in rateSampleCount...4096)
                    {
                        rateSamples.writeFloat(0);
                        rateSamples.writeFloat(0);
                    }
                    rateSampleCount = 4096;
                }
            }
            rateSamples.position = 8 * sampleDiff;
            e.data.writeFloat(rateSamples.readFloat());
            e.data.writeFloat(rateSamples.readFloat());
            osamples++;
        }
    }
    
    private function stopSound(e : Dynamic) : Void
    {
        musicIsPlaying = false;
    }
    
    ///- Song Function
    public function start(seek : Int = 0) : Void
    {
        updateMusicOffset();
        
        if (soundChannel != null)
        {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
            soundChannel.stop();
            soundChannel = null;
        }
        
        if (sound != null)
        {
            soundChannel = sound.play(musicStartTime + seek);
            soundChannel.soundTransform = SoundMixer.soundTransform;
            soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
        }
        
        if (background != null)
        {
            background.gotoAndPlay(2 + musicStartFrames + as3hx.Compat.parseInt(seek * 30 / 1000));
        }
        
        musicIsPlaying = true;
    }
    
    public function stop() : Void
    {
        if (background != null)
        {
            background.stop();
        }
        
        if (soundChannel != null)
        {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
            soundChannel.stop();
            musicPausePosition = 0;
            soundChannel = null;
        }
        musicIsPlaying = false;
    }
    
    public function pause() : Void
    {
        var pausePosition : Int = 0;
        if (soundChannel != null)
        {
            pausePosition = soundChannel.position;
        }
        stop();
        musicPausePosition = pausePosition;
    }
    
    public function resume() : Void
    {
        if (background != null)
        {
            background.play();
        }
        if (sound != null)
        {
            soundChannel = sound.play(musicPausePosition);
            soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
        }
        musicIsPlaying = true;
    }
    
    private function playClips(clip : MovieClip) : Void
    {
        clip.gotoAndPlay(2 + musicStartFrames);
        for (i in 0...clip.numChildren)
        {
            var subclip : MovieClip = try cast(clip.getChildAt(i), MovieClip) catch(e:Dynamic) null;
            if (subclip != null)
            {
                playClips(subclip);
            }
        }
    }
    
    public function reset() : Void
    {
        stop();
        start();
        if (background != null)
        {
            playClips(background);
        }
    }
    
    ///- Note Functions
    public function getNote(index : Int) : Note
    {
        if (noteMod.required())
        {
            return noteMod.transformNote(index);
        }
        
        return chart.Notes[index];
    }
    
    private function get_totalNotes() : Int
    {
        if (noteMod.required())
        {
            return noteMod.transformTotalNotes();
        }
        
        if (!chart.Notes)
        {
            return 0;
        }
        
        return chart.Notes.length;
    }
    
    private function get_chartTime() : Float
    {
        if (noteMod.required())
        {
            return noteMod.transformSongLength();
        }
        
        if (!chart.Notes || chart.Notes.length <= 0)
        {
            return 0;
        }
        
        return getNote(totalNotes - 1).time + 1;
    }
    
    private function get_chartTimeFormatted() : String
    {
        var totalSecs : Int = as3hx.Compat.parseInt(chartTime);
        var minutes : String = Std.string(Math.floor(totalSecs / 60));
        var seconds : String = Std.string(totalSecs % 60);
        
        if (seconds.length == 1)
        {
            seconds = "0" + seconds;
        }
        
        return minutes + ":" + seconds;
    }
    
    public function updateMusicOffset() : Void
    {
        options = _gvars.options;
        rateReverse = options.modEnabled("reverse");
        rateRate = options.songRate;
        noteMod.start(options);
        
        if (options.isolation && totalNotes > 0)
        {
            if (rateReverse)
            {
                musicStartFrames = Math.max(0, chart.Notes[chart.Notes.length - 1].frame - chart.Notes[Math.max(0, chart.Notes.length - 1 - options.isolationOffset)].frame - 60);
            }
            else
            {
                musicStartFrames = Math.max(0, chart.Notes[options.isolationOffset].frame - 60);
            }
        }
        else
        {
            musicStartFrames = 0;
        }
        
        musicStartTime = as3hx.Compat.parseInt(musicStartFrames / options.songRate * 1000 / 30);
    }
    
    public function getPosition() : Int
    {
        if (soundChannel != null)
        {
            return as3hx.Compat.parseInt(soundChannel.position - musicStartTime);
        }
        
        return 0;
    }
}

