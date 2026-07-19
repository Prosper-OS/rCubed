import by.blooddy.crypto.MD5;
import classes.FileTracker;
import classes.chart.Song;
import com.flashfla.utils.SystemUtil;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import r3.air.filesystem.File;
import r3.air.filesystem.FileMode;
import r3.air.filesystem.FileStream;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;

/**
 * Contains methods that deal with AIR specific things, in regular flash builds, these are either excluded or stubbed.
 */
class AirContext
{
    // Windows will store files in the current folder, other OS will use the application storage folder.
    public static var STORAGE_PATH : File;
    
    
    public static function initFolders() : Void
    // song cache
    {
        
        var folder : File = STORAGE_PATH.resolvePath(Constant.SONG_CACHE_PATH);
        if (!folder.exists)
        {
            folder.createDirectory();
        }
        
        // replays
        folder = STORAGE_PATH.resolvePath(Constant.REPLAY_PATH);
        if (!folder.exists)
        {
            folder.createDirectory();
        }
        
        // noteskins
        folder = STORAGE_PATH.resolvePath(Constant.NOTESKIN_PATH);
        if (!folder.exists)
        {
            folder.createDirectory();
        }
    }
    
    public static function createFileName(file_name : String, replace : String = "") : String
    // Remove chars not allowed in Windows filename \ / : * ? " < > |
    {
        
        file_name = new as3hx.Compat.Regex('[~\\\\\\/:\\*\\?\\"<>\\|]', "g").replace(file_name, replace);
        
        // Trim leading and trailing whitespace.
        file_name = new as3hx.Compat.Regex('^\\s+|\\s+$', "gs").replace(file_name, replace);
        
        return file_name;
    }
    
    public static function getLoaderContext() : LoaderContext
    {
        var lc : LoaderContext = new LoaderContext();
        lc.applicationDomain = new ApplicationDomain(null);
        lc.allowCodeImport = true;
        return lc;
    }
    
    public static function getSongCachePath(song : Song) : String
    {
        return Constant.SONG_CACHE_PATH + ((song.songInfo.engine) ? MD5.hash(song.songInfo.engine.id) + "/" + MD5.hash(Std.string(song.songInfo.level_id)) : "57fea2a7e69445179686b7579d5118ef/" + MD5.hash(Std.string(song.id))) + "/";
    }
    
    public static function getReplayPath(song : Song) : String
    {
        return Constant.REPLAY_PATH + ((song.songInfo.engine) ? createFileName(song.songInfo.engine.id) : Constant.BRAND_NAME_SHORT_LOWER) + "/";
    }
    
    public static function encodeData(rawData : ByteArray, key : Int = 0) : ByteArray
    {
        if (key == 0)
        {
            return rawData;
        }
        
        // Do some XOR stuff on the ByteArray.
        var sp : Int = rawData.position;
        rawData.position = 0;
        var storeData : ByteArray = new ByteArray();
        storeData.writeBytes(rawData);
        var bi : Int = 4;
        while (bi < rawData.length)
        {
            storeData[bi] = storeData[bi] ^ (key + bi) % 0xFF;
            bi += 4;
        }
        rawData.position = sp;
        storeData.position = 0;
        return storeData;
    }
    
    private static function e_fileError(e : Event) : Void
    {
        trace(e);
    }
    
    public static function getAppFile(path : String) : File
    {
        return STORAGE_PATH.resolvePath(path);
    }
    
    public static function doesFileExist(path : String) : Bool
    {
        return STORAGE_PATH.resolvePath(path).exists;
    }
    
    public static function writeFile(file : File, bytes : ByteArray, key : Int = 0, errorCallback : Dynamic = null) : File
    {
        var fileStream : FileStream = new FileStream();
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeBytes(encodeData(bytes, key));
        fileStream.close();
        
        return file;
    }
    
    public static function readFile(file : File, key : Int = 0, errorCallback : Dynamic = null) : ByteArray
    {
        if (file.exists)
        {
            var fileStream : FileStream = new FileStream();
            fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            var readData : ByteArray = new ByteArray();
            fileStream.open(file, FileMode.READ);
            fileStream.readBytes(readData);
            fileStream.close();
            
            return encodeData(readData, key);
        }
        return null;
    }
    
    public static function readTextFile(file : File, errorCallback : Dynamic = null) : String
    {
        if (file.exists)
        {
            var fileStream : FileStream = new FileStream();
            fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.open(file, FileMode.READ);
            var data : String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            
            return data;
        }
        return null;
    }
    
    public static function writeTextFile(file : File, data : String, errorCallback : Dynamic = null) : File
    {
        if (data == null || data.length == 0)
        {
            return file;
        }
        
        var fileStream : FileStream = new FileStream();
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeUTFBytes(data);
        fileStream.close();
        
        return file;
    }
    
    public static function deleteFile(file : File) : Bool
    {
        if (file.exists)
        {
            file.moveToTrash();
            return true;
        }
        return false;
    }
    
    public static function getFileSize(file : File, track : FileTracker = null, track_file_paths : Bool = false) : FileTracker
    {
        if (track == null)
        {
            track = new FileTracker();
        }
        
        if (file == null || file.exists == false)
        {
            return track;
        }
        if (file.isDirectory)
        {
            track.dirs++;
            var files : Array<Dynamic> = file.getDirectoryListing();
            for (f in files)
            {
                if (f.isDirectory)
                {
                    getFileSize(f, track, track_file_paths);
                }
                else
                {
                    if (track_file_paths)
                    {
                        track.file_paths.push(f.nativePath);
                    }
                    track.files++;
                    track.size += f.size;
                }
            }
        }
        else
        {
            if (track_file_paths)
            {
                track.file_paths.push(file.nativePath);
            }
            track.files++;
            track.size += file.size;
        }
        return track;
    }

    public function new()
    {
    }
    private static var AirContext_static_initializer = {
        {
            if (SystemUtil.OS.toLowerCase().indexOf("win") == -1)
            {
                STORAGE_PATH = File.applicationStorageDirectory;
            }
            else
            {
                STORAGE_PATH = new File(File.applicationDirectory.nativePath);
            }
        };
        true;
    }

}

