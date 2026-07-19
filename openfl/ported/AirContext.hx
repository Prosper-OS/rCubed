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
    public static var STORAGE_PATH                              : Dynamic;
    
    
    public static function initFolders() : Void
    // song cache
    {
        
        var folder                              : Dynamic= STORAGE_PATH.resolvePath(Constant.SONG_CACHE_PATH);
        if (as3hx.Compat.truthy(!folder.exists))
        {
            folder.createDirectory();
        }
        
        // replays
        folder = STORAGE_PATH.resolvePath(Constant.REPLAY_PATH);
        if (as3hx.Compat.truthy(!folder.exists))
        {
            folder.createDirectory();
        }
        
        // noteskins
        folder = STORAGE_PATH.resolvePath(Constant.NOTESKIN_PATH);
        if (as3hx.Compat.truthy(!folder.exists))
        {
            folder.createDirectory();
        }
    }
    
    public static function createFileName(file_name                              : Dynamic, replace                              : Dynamic= "") : String
    // Remove chars not allowed in Windows filename \ / : * ? " < > |
    {
        
        file_name = new as3hx.Compat.Regex('[~\\\\\\/:\\*\\?\\"<>\\|]', "g").replace(file_name, replace);
        
        // Trim leading and trailing whitespace.
        file_name = new as3hx.Compat.Regex('^\\s+|\\s+$', "gs").replace(file_name, replace);
        
        return file_name;
    }
    
    public static function getLoaderContext() : LoaderContext
    {
        var lc                              : Dynamic= new LoaderContext();
        lc.applicationDomain = new ApplicationDomain(null);
        lc.allowCodeImport = true;
        return lc;
    }
    
    public static function getSongCachePath(song                              : Dynamic) : String
    {
        return Constant.SONG_CACHE_PATH + ((song.songInfo.engine) ? MD5.hash(song.songInfo.engine.id) + "/" + MD5.hash(Std.string(song.songInfo.level_id)) : "57fea2a7e69445179686b7579d5118ef/" + MD5.hash(Std.string(song.id))) + "/";
    }
    
    public static function getReplayPath(song                              : Dynamic) : String
    {
        return Constant.REPLAY_PATH + ((song.songInfo.engine) ? createFileName(song.songInfo.engine.id) : Constant.BRAND_NAME_SHORT_LOWER) + "/";
    }
    
    public static function encodeData(rawData                              : Dynamic, key                              : Dynamic= 0) : ByteArray
    {
        if (as3hx.Compat.truthy(key == 0))
        {
            return rawData;
        }
        
        // Do some XOR stuff on the ByteArray.
        var sp                              : Dynamic= rawData.position;
        rawData.position = 0;
        var storeData                              : Dynamic= new ByteArray();
        storeData.writeBytes(rawData);
        var bi                              : Dynamic= 4;
        while (as3hx.Compat.truthy(bi < rawData.length))
        {
            storeData.position = as3hx.Compat.parseInt(bi);
            var encodedByte                             : Dynamic= storeData.readUnsignedByte() ^ as3hx.Compat.parseInt((key + bi) % 0xFF);
            storeData.position = as3hx.Compat.parseInt(bi);
            storeData.writeByte(encodedByte);
            bi += 4;
        }
        rawData.position = sp;
        storeData.position = 0;
        return storeData;
    }
    
    private static function e_fileError(e                              : Dynamic) : Void
    {
        trace(e);
    }
    
    public static function getAppFile(path                              : Dynamic) : File
    {
        return STORAGE_PATH.resolvePath(path);
    }
    
    public static function doesFileExist(path                              : Dynamic) : Bool
    {
        return STORAGE_PATH.resolvePath(path).exists;
    }
    
    public static function writeFile(file                              : Dynamic, bytes                              : Dynamic, key                              : Dynamic= 0, errorCallback                              : Dynamic= null) : File
    {
        var fileStream                              : Dynamic= new FileStream();
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeBytes(encodeData(bytes, key));
        fileStream.close();
        
        return file;
    }
    
    public static function readFile(file                              : Dynamic, key                              : Dynamic= 0, errorCallback                              : Dynamic= null) : ByteArray
    {
        if (as3hx.Compat.truthy(file.exists))
        {
            var fileStream                              : Dynamic= new FileStream();
            fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            var readData                              : Dynamic= new ByteArray();
            fileStream.open(file, FileMode.READ);
            fileStream.readBytes(readData);
            fileStream.close();
            
            return encodeData(readData, key);
        }
        return null;
    }
    
    public static function readTextFile(file                              : Dynamic, errorCallback                              : Dynamic= null) : String
    {
        if (as3hx.Compat.truthy(file.exists))
        {
            var fileStream                              : Dynamic= new FileStream();
            fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
            fileStream.open(file, FileMode.READ);
            var data                              : Dynamic= fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            
            return data;
        }
        return null;
    }
    
    public static function writeTextFile(file                              : Dynamic, data                              : Dynamic, errorCallback                              : Dynamic= null) : File
    {
        if (as3hx.Compat.truthy(data == null || data.length == 0))
        {
            return file;
        }
        
        var fileStream                              : Dynamic= new FileStream();
        fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.addEventListener(IOErrorEvent.IO_ERROR, (errorCallback != null) ? errorCallback : e_fileError);
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeUTFBytes(data);
        fileStream.close();
        
        return file;
    }
    
    public static function deleteFile(file                              : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(file.exists))
        {
            file.moveToTrash();
            return true;
        }
        return false;
    }
    
    public static function getFileSize(file                              : Dynamic, track                              : Dynamic= null, track_file_paths                              : Dynamic= false) : FileTracker
    {
        if (as3hx.Compat.truthy(track == null))
        {
            track = new FileTracker();
        }
        
        if (as3hx.Compat.truthy(file == null || file.exists == false))
        {
            return track;
        }
        if (as3hx.Compat.truthy(file.isDirectory))
        {
            track.dirs++;
            var files                              : Dynamic= file.getDirectoryListing();
            for (f in as3hx.Compat.iter(files))
            {
                if (as3hx.Compat.truthy(f.isDirectory))
                {
                    getFileSize(f, track, track_file_paths);
                }
                else
                {
                    if (as3hx.Compat.truthy(track_file_paths))
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
            if (as3hx.Compat.truthy(track_file_paths))
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
            if (as3hx.Compat.truthy(SystemUtil.OS.toLowerCase().indexOf("win") == -1))
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

