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
    public var progress(get, never)                             : Dynamic;
    public var totalNotes(get, never)                             : Dynamic;
    public var chartTime(get, never)                             : Dynamic;
    public var chartTimeFormatted(get, never)                             : Dynamic;

    private var _gvars                             : Dynamic= GlobalVariables.instance;
    
    public var musicLoader                             : Dynamic;
    
    public var id                             : Dynamic;
    public var songInfo                             : Dynamic;
    public var type                             : Dynamic;
    
    public var isDirty                             : Dynamic= true;
    
    private var baseSound                             : Dynamic;
    public var sound                             : Dynamic;
    public var background                             : Dynamic;
    public var chart                             : Dynamic;
    
    public var noteMod                             : Dynamic;
    public var options                             : Dynamic;
    public var soundChannel                             : Dynamic;
    public var musicPausePosition                             : Dynamic;
    public var musicIsPlaying                             : Dynamic= false;
    public var mp3Frame                             : Dynamic= 0;
    public var mp3Rate                             : Dynamic= 1;
    
    private var rateReverse                             : Dynamic= false;
    private var rateRate                             : Dynamic= 1;
    private var rateSample                             : Dynamic= 0;
    private var rateSampleCount                             : Dynamic= 0;
    private var rateSamples                             : Dynamic= new ByteArray();
    
    public var isLoaded                             : Dynamic= false;
    public var isChartLoaded                             : Dynamic= false;
    public var isMusicLoaded                             : Dynamic= false;
    public var loadFail                             : Dynamic= false;
    
    public var isMusicLoaderLoading                             : Dynamic= false;
    
    public var bytesSWF                             : Dynamic= null;
    public var bytesLoaded                             : Dynamic= 0;
    public var bytesTotal                             : Dynamic= 0;
    
    private var musicForcibleLoader                             : Dynamic;
    
    public var musicStartFrames                             : Dynamic= 0;
    public var musicStartTime                             : Dynamic= 0;
    
    private var localFileData                             : Dynamic= null;
    private var localFileHash                             : Dynamic= "";
    
    public function new(songInfo                             : Dynamic, doLoad                             : Dynamic= true)
    {
        super();
        this.songInfo = songInfo;
        this.id = songInfo.level;
        this.type = as3hx.Compat.orValue(songInfo.chart_type, NoteChart.FFR_MP3);
        
        options = _gvars.options;
        
        if (as3hx.Compat.truthy(type == "EDITOR"))
        {
            chart = new NoteChart(null);
            return;
        }
        
        if (as3hx.Compat.truthy(doLoad))
        {
            load();
        }
    }
    
    public function unload() : Void
    {
        removeLoaderListeners();
        isLoaded = isChartLoaded = isMusicLoaded = false;
        loadFail = true;
        
        if (as3hx.Compat.truthy(musicLoader != null && isMusicLoaderLoading))
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
        
        var url_file_hash                             : Dynamic= "";
        if (as3hx.Compat.truthy((_gvars.air_useLocalFileCache) && AirContext.doesFileExist(AirContext.getSongCachePath(this) + "data.bin")))
        {
            localFileData = AirContext.readFile(AirContext.getAppFile(AirContext.getSongCachePath(this) + "data.bin"), (songInfo.engine) ? 0 : id);
            localFileHash = MD5.hashBytes(localFileData);
            url_file_hash = "hash=" + localFileHash + "&";
            
            if (as3hx.Compat.truthy(songInfo.engine))
            {
                if (as3hx.Compat.truthy(localFileData != null && localFileHash == songInfo.swf_hash && type == NoteChart.FFR_MP3))
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
        if (as3hx.Compat.truthy(musicLoader != null))
        {
            return Math.floor(((bytesLoaded / bytesTotal) * 99) + ((isChartLoaded) ? 1 : 0));
        }
        
        return 0;
    }
    
    public function getMusicContentLoader(isLoader                             : Dynamic= false) : Dynamic
    {
        if (as3hx.Compat.truthy(isLoader))
        {
            return musicLoader.contentLoaderInfo;
        }
        
        return (type == NoteChart.FFR_MP3) ? musicLoader : musicLoader.contentLoaderInfo;
    }
    
    private function urlGen(fileHash                             : Dynamic= "") : String
    {
        if (as3hx.Compat.truthy(songInfo.engine))
        {
            return ChartFFRLegacy.songUrl(songInfo);
        }
        
        return URLs.resolve(URLs.SONG_DATA_URL) + "?" + fileHash + "id=" + songInfo.play_hash + ((_gvars.userSession != "0") ? "&session=" + _gvars.userSession : "");
    }
    
    private function addLoaderListeners(isLoader                             : Dynamic= false) : Void
    {
        var music                             : Dynamic= getMusicContentLoader(isLoader);
        
        if (as3hx.Compat.truthy(music != null))
        {
            music.addEventListener(Event.COMPLETE, musicCompleteHandler);
            music.addEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
            music.addEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
        }
        
        if (as3hx.Compat.truthy(musicLoader != null))
        {
            musicLoader.addEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }
    }
    
    private function removeLoaderListeners() : Void
    {
        var music                             : Dynamic= getMusicContentLoader();
        
        if (as3hx.Compat.truthy(music != null))
        {
            music.removeEventListener(Event.COMPLETE, musicCompleteHandler);
            music.removeEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
            music.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
        }
        
        if (as3hx.Compat.truthy(musicLoader != null))
        {
            musicLoader.removeEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }
    }
    
    public function loadComplete() : Void
    {
        if (as3hx.Compat.truthy(isChartLoaded && isMusicLoaded))
        {
            removeLoaderListeners();
            isLoaded = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    private function musicProgressHandler(e                             : Dynamic) : Void
    {
        bytesLoaded = e.bytesLoaded;
        bytesTotal = e.bytesTotal;
    }
    
    private function musicCompleteHandler(e                             : Dynamic) : Void
    {
        Logger.success(this, "Music Load Success");
        var chartData                            : Dynamic= null;
        if (as3hx.Compat.truthy(type == NoteChart.FFR_MP3))
        {
            if (as3hx.Compat.truthy(Std.is(e.target, URLLoader)))
            {
                chartData = e.target.data;
            }
            else if (as3hx.Compat.truthy(Std.is(e.target, LoaderInfo)))
            {
                chartData = e.target.bytes;
            }
            
            bytesLoaded = bytesTotal = chartData.length;  // Update Progress Bar in case.  
            
            // Check 404 Response
            if (as3hx.Compat.truthy(chartData.length == 0 || (chartData.length == 3 && chartData.readUTFBytes(3) == "404")))
            {
                loadFail = true;
                return;
            }
            
            // Check for server response for matching hash. Encode Compressed SWF Data
            var storeChartData                            : Dynamic= null;
            if (as3hx.Compat.truthy(_gvars.air_useLocalFileCache)) {
if (as3hx.Compat.truthy(this.songInfo.engine && localFileData != null))
                {
                }
                else if (as3hx.Compat.truthy(chartData.length == 3))
                {
                    chartData.position = 0;
                    var code                             : Dynamic= chartData.readUTFBytes(3);
                    if (as3hx.Compat.truthy(code == "404"))
                    {
                        loadFail = true;
                        return;
                    }
                    if (as3hx.Compat.truthy(code == "403"))
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
            var metadata                             : Dynamic= { };
            loadSoundBytes(MP3Extraction.extractSound(chartData, metadata));
            mp3Frame = as3hx.Compat.parseInt(metadata.frame - 2);
            mp3Rate = MP3Extraction.formatRate(metadata.format) / 44100;
            
            // Generate a SWF containing no audio, used as a background.
            var mloader                             : Dynamic= new Loader();
            var mbytes                             : Dynamic= SwfSilencer.stripSound(chartData);
            mloader.contentLoaderInfo.addEventListener(Event.COMPLETE, backgoundCompleteHandler);
            if (as3hx.Compat.truthy(mbytes == null))
            {
                loadFail = true;
                return;
            }
            mloader.loadBytes(mbytes, AirContext.getLoaderContext());
            
            // Store SWF
            if (as3hx.Compat.truthy(_gvars.air_useLocalFileCache && storeChartData != null))
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
    
    private function backgoundCompleteHandler(e                             : Dynamic) : Void
    {
        var info                             : Dynamic= try cast(e.currentTarget, LoaderInfo) catch(e:Dynamic) null;
        background = try cast(info.content, MovieClip) catch(e:Dynamic) null;
        
        isMusicLoaded = true;
        loadComplete();
    }
    
    private function chartLoadComplete(e                             : Dynamic= null) : Void
    {
        Logger.success(this, "Chart Load Success");
        Logger.info(this, "Chart parsed with " + chart.Notes.length + " notes, " + ((chart.Notes.length > 0) ? TimeUtil.convertToHHMMSS(as3hx.Compat.parseInt(chart.Notes[as3hx.Compat.parseInt(chart.Notes.length - 1)].time)) : "0:00") + " length.");
        
        isChartLoaded = true;
        loadComplete();
    }
    
    private function musicLoadError(err                             : Dynamic= null) : Void
    {
        Logger.error(this, "Music Load Error: " + Logger.event_error(err));
        isMusicLoaderLoading = false;
        removeLoaderListeners();
        loadFail = true;
    }
    
    public function handleDirty(options                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!isDirty))
        {
            return;
        }
        
        // Remove Old Sound
        if (as3hx.Compat.truthy(sound != null))
        {
            sound.removeEventListener("sampleData", onReverseSound);
            sound.removeEventListener("sampleData", onRateSound);
            sound = null;
        }
        
        if (as3hx.Compat.truthy(soundChannel != null))
        {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
            soundChannel.stop();
        }
        
        noteMod = new NoteMod(this, options);
        rateReverse = options.modEnabled("reverse");
        rateRate = options.songRate;
        
        // Add Sound
        if (as3hx.Compat.truthy(rateRate != 1 || rateReverse))
        {
            sound = new Sound();
            
            if (as3hx.Compat.truthy(rateReverse))
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
    
    public function loadSoundBytes(bytes                             : Dynamic) : Void
    {
        bytes.position = 0;
        baseSound = new Sound();
        baseSound.loadCompressedDataFromByteArray(bytes, bytes.length);
    }
    
    public function getSoundObject() : Sound
    {
        if (as3hx.Compat.truthy(rateRate != 1 || rateReverse))
        {
            return baseSound;
        }
        
        return sound;
    }
    
    private function onRateSound(e                             : Dynamic) : Void
    {
        var osamples                             : Dynamic= 0;
        var sample                             : Dynamic= 0;
        var sampleDiff                             : Dynamic= 0;
        while (as3hx.Compat.truthy(osamples < 4096))
        {
            sample = as3hx.Compat.parseInt((e.position + osamples) * rateRate);
            sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
            while (as3hx.Compat.truthy(sampleDiff < 0 || sampleDiff >= rateSampleCount))
            {
                rateSample += rateSampleCount;
                rateSamples.position = 0;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                var seekExtract                             : Dynamic= (sampleDiff < 0 || sampleDiff > 8192);
                rateSampleCount = baseSound.extract(rateSamples, 4096, as3hx.Compat.parseFloat((seekExtract) ? sample * mp3Rate : -1));
                
                if (as3hx.Compat.truthy(seekExtract))
                {
                    rateSample = sample;
                    sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                }
                
                if (as3hx.Compat.truthy(rateSampleCount <= 0))
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
    
    private function onReverseSound(e                             : Dynamic) : Void
    {
        var osamples                             : Dynamic= 0;
        while (as3hx.Compat.truthy(osamples < 4096))
        {
            var sample                             : Dynamic= as3hx.Compat.parseInt((e.position + osamples) * rateRate);
            sample = as3hx.Compat.parseInt((chart.Notes[as3hx.Compat.parseInt(chart.Notes.length - 1)].frame * 1470) - sample + (63 - mp3Frame) * 1470 / rateRate);
            if (as3hx.Compat.truthy(sample < 0))
            {
                return;
            }
            var sampleDiff                             : Dynamic= as3hx.Compat.parseInt(sample - rateSample);
            if (as3hx.Compat.truthy(sampleDiff < 0 || sampleDiff >= rateSampleCount))
            {
                rateSample += rateSampleCount;
                rateSamples.position = 0;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                var seekPosition                             : Dynamic= as3hx.Compat.parseInt(sample - 4095);
                rateSampleCount = baseSound.extract(rateSamples, 4096, seekPosition * mp3Rate);
                rateSample = seekPosition;
                sampleDiff = as3hx.Compat.parseInt(sample - rateSample);
                
                if (as3hx.Compat.truthy(rateSampleCount < 4096))
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
    
    private function stopSound(e                             : Dynamic) : Void
    {
        musicIsPlaying = false;
    }
    
    ///- Song Function
    public function start(seek                             : Dynamic= 0) : Void
    {
        updateMusicOffset();
        
        if (as3hx.Compat.truthy(soundChannel != null))
        {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
            soundChannel.stop();
            soundChannel = null;
        }
        
        if (as3hx.Compat.truthy(sound != null))
        {
            soundChannel = sound.play(musicStartTime + seek);
            soundChannel.soundTransform = SoundMixer.soundTransform;
            soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
        }
        
        if (as3hx.Compat.truthy(background != null))
        {
            background.gotoAndPlay(2 + musicStartFrames + as3hx.Compat.parseInt(seek * 30 / 1000));
        }
        
        musicIsPlaying = true;
    }
    
    public function stop() : Void
    {
        if (as3hx.Compat.truthy(background != null))
        {
            background.stop();
        }
        
        if (as3hx.Compat.truthy(soundChannel != null))
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
        var pausePosition                             : Dynamic= 0;
        if (as3hx.Compat.truthy(soundChannel != null))
        {
            pausePosition = soundChannel.position;
        }
        stop();
        musicPausePosition = pausePosition;
    }
    
    public function resume() : Void
    {
        if (as3hx.Compat.truthy(background != null))
        {
            background.play();
        }
        if (as3hx.Compat.truthy(sound != null))
        {
            soundChannel = sound.play(musicPausePosition);
            soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
        }
        musicIsPlaying = true;
    }
    
    private function playClips(clip                             : Dynamic) : Void
    {
        clip.gotoAndPlay(2 + musicStartFrames);
        for (i in 0...clip.numChildren)
        {
            var subclip                             : Dynamic= try cast(clip.getChildAt(i), MovieClip) catch(e:Dynamic) null;
            if (as3hx.Compat.truthy(subclip != null))
            {
                playClips(subclip);
            }
        }
    }
    
    public function reset() : Void
    {
        stop();
        start();
        if (as3hx.Compat.truthy(background != null))
        {
            playClips(background);
        }
    }
    
    ///- Note Functions
    public function getNote(index                             : Dynamic) : Note
    {
        if (as3hx.Compat.truthy(noteMod.required()))
        {
            return noteMod.transformNote(index);
        }
        
        return chart.Notes[index];
    }
    
    private function get_totalNotes() : Int
    {
        if (as3hx.Compat.truthy(noteMod.required()))
        {
            return noteMod.transformTotalNotes();
        }
        
        if (as3hx.Compat.truthy(!chart.Notes))
        {
            return 0;
        }
        
        return chart.Notes.length;
    }
    
    private function get_chartTime() : Float
    {
        if (as3hx.Compat.truthy(noteMod.required()))
        {
            return noteMod.transformSongLength();
        }
        
        if (as3hx.Compat.truthy(chart.Notes == null || chart.Notes.length <= 0))
        {
            return 0;
        }
        
        return getNote(totalNotes - 1).time + 1;
    }
    
    private function get_chartTimeFormatted() : String
    {
        var totalSecs                             : Dynamic= as3hx.Compat.parseInt(chartTime);
        var minutes                             : Dynamic= Std.string(Math.floor(totalSecs / 60));
        var seconds                             : Dynamic= Std.string(totalSecs % 60);
        
        if (as3hx.Compat.truthy(seconds.length == 1))
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
        
        if (as3hx.Compat.truthy(options.isolation && totalNotes > 0))
        {
            if (as3hx.Compat.truthy(rateReverse))
            {
                musicStartFrames = Math.max(0, chart.Notes[as3hx.Compat.parseInt(chart.Notes.length - 1)].frame - chart.Notes[as3hx.Compat.parseInt(Math.max(0, chart.Notes.length - 1 - options.isolationOffset))].frame - 60);
            }
            else
            {
                musicStartFrames = Math.max(0, chart.Notes[as3hx.Compat.parseInt(options.isolationOffset)].frame - 60);
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
        if (as3hx.Compat.truthy(soundChannel != null))
        {
            return as3hx.Compat.parseInt(soundChannel.position - musicStartTime);
        }
        
        return 0;
    }
}

