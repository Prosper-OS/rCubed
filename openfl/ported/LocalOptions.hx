import openfl.errors.Error;
import r3.air.filesystem.File;

class LocalOptions
{
    private static inline var FILE_NAME                              : Dynamic= "options.json";
    
    private static var SO_OBJECT                              : Dynamic= { };
    
    public static function init() : Void
    {
        var json_file                              : Dynamic= File.applicationStorageDirectory.resolvePath(FILE_NAME);
        
        // Use JSON first
        if (as3hx.Compat.truthy(json_file.exists))
        {
            var json_str                              : Dynamic= AirContext.readTextFile(json_file);
            if (as3hx.Compat.truthy(json_str != null))
            {
                try
                {
                    SO_OBJECT = haxe.Json.parse(json_str);
                    Logger.debug("LocalOptions", "Loaded \"" + json_file.nativePath + "\"");
                }
                catch (e : Error)
                {
                    Logger.error("LocalOptions", "Error parsing \"" + json_file.nativePath + "\"");
                }
            }
        }
        else
        {
            importFromLocalStore();
        }
    }
    
    /**
     * Returns a top-level cloned object of all SharedObject variables.
     * @return Object
     */
    public static function getAllVariables() : Dynamic
    {
        var out                              : Dynamic= { };
        for (key in as3hx.Compat.iter(Reflect.fields(SO_OBJECT)))
        {
            Reflect.setField(out, key, Reflect.field(SO_OBJECT, key));
        }
        return out;
    }
    
    /**
     * Gets a locally stored value if it exist, if not returns the provided default value.
     * @param key Variable Key
     * @param defaultValue Default Value
     */
    public static function getVariable(key                              : Dynamic, defaultValue                              : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(Reflect.field(SO_OBJECT, key) != null))
        {
            return Reflect.field(SO_OBJECT, key);
        }
        return defaultValue;
    }
    
    /**
     * Sets a value into the local store.
     * @param key Variable Key
     * @param value Value
     * @param minDiskSize Minimum Local Store Size
     */
    public static function setVariable(key                              : Dynamic, value                              : Dynamic) : Void
    {
        Reflect.setField(SO_OBJECT, key, value);
    }
    
    /**
     * Deletes a variable from the local store.
     * @param key Variable Key
     */
    public static function deleteVariable(key                              : Dynamic) : Void
    {
        Reflect.deleteField(SO_OBJECT, key);
    }
    
    /**
     * Writes shared object to file.
     * @param minDiskSize Minimum Local Store Size
     */
    public static function flush(minDiskSize                              : Dynamic= 0) : Void
    {
        AirContext.writeTextFile(File.applicationStorageDirectory.resolvePath(FILE_NAME), haxe.Json.stringify(SO_OBJECT, null, "  "));
    }
    
    public static function importFromLocalStore() : Void
    {
        Logger.debug("LocalOptions", "Importing from LocalStore");
        
        Reflect.setField(SO_OBJECT, "legacy_engines", LocalStore.getVariable("legacyEngines", null));
        Reflect.setField(SO_OBJECT, "legacy_default_engine", LocalStore.getVariable("legacyDefaultEngine", null));
        Reflect.setField(SO_OBJECT, "rolling_music_offset", LocalStore.getVariable("arcMusicOffset", 0));
    }

    public function new()
    {
    }
}

