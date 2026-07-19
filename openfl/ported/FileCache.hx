import openfl.errors.Error;

class FileCache
{
    public var cacheFound(get, never)                              : Dynamic;
    public var keys(get, never)                              : Dynamic;
    public var cache(get, never)                              : Dynamic;

    private var CACHE                              : Dynamic;
    
    private var CACHE_FILE_NAME                              : Dynamic;
    private var CACHE_FILE_VERSION                              : Dynamic= 1;
    
    private var _cacheFound                              : Dynamic= false;
    private var _didLoad                              : Dynamic= false;
    private var _isDirty                              : Dynamic= false;
    
    public function new(cache_name                              : Dynamic, cache_version                              : Dynamic)
    {
        CACHE_FILE_NAME = cache_name;
        CACHE_FILE_VERSION = as3hx.Compat.parseInt(cache_version);
        CACHE = getDefaultCacheObject();
        
        load();
    }
    
    public function load() : Void
    {
        if (as3hx.Compat.truthy(_didLoad))
        {
            return;
        }
        
        _didLoad = true;
        
        var data                              : Dynamic= AirContext.readTextFile(AirContext.getAppFile(CACHE_FILE_NAME));
        if (as3hx.Compat.truthy(data != null && data.length > 2))
        {
            try
            {
                var FILE_CACHE                              : Dynamic= haxe.Json.parse(data);
                
                // valid cache & version
                if (as3hx.Compat.truthy((as3hx.Compat.orValue(Reflect.field(FILE_CACHE, "cache_version"), 0) == CACHE_FILE_VERSION) && Reflect.field(FILE_CACHE, "keys") != null))
                {
                    CACHE = FILE_CACHE;
                    _cacheFound = true;
                }
                Logger.debug(this, "Loaded Cache \"" + CACHE_FILE_NAME + "\"");
            }
            catch (e : Error)
            {
                Logger.error(this, "Error on Cache \"" + CACHE_FILE_NAME + "\"");
            }
        }
        else
        {
            Logger.error(this, "Cache \"" + CACHE_FILE_NAME + "\" missing or null");
        }
    }
    
    public function save() : Void
    {
        if (as3hx.Compat.truthy(_isDirty))
        {
            AirContext.writeTextFile(AirContext.getAppFile(CACHE_FILE_NAME), haxe.Json.stringify(CACHE));
            _isDirty = false;
            _cacheFound = true;
            Logger.debug(this, "Saving Cache \"" + CACHE_FILE_NAME + "\"");
        }
        else
        {
            Logger.debug(this, "No Cache \"" + CACHE_FILE_NAME + "\" changes to save");
        }
    }
    
    public function findKey(condition                              : Dynamic) : String
    {
        for (key in as3hx.Compat.iter(Reflect.fields(Reflect.field(CACHE, "keys"))))
        {
            if (as3hx.Compat.truthy(condition(Reflect.field(Reflect.field(CACHE, "keys"), key))))
            {
                return key;
            }
        }
        
        return null;
    }
    
    public function findValue(condition                              : Dynamic) : Dynamic
    {
        for (entry/* AS3HX WARNING could not determine type for var: entry exp: EArray(EIdent(CACHE),EConst(CString(keys))) type: Dynamic */ in as3hx.Compat.iter(Reflect.field(CACHE, "keys")))
        {
            if (as3hx.Compat.truthy(condition(entry)))
            {
                return entry;
            }
        }
        
        return null;
    }
    
    public function findValues(condition                              : Dynamic) : Dynamic
    {
        return Reflect.field(CACHE, "keys").filter(condition);
    }
    
    public function getValue(path                              : Dynamic) : Dynamic
    {
        return Reflect.field(Reflect.field(CACHE, "keys"), path) || null;
    }
    
    public function setValue(path                              : Dynamic, value                              : Dynamic) : Void
    {
        Reflect.setField(Reflect.field(CACHE, "keys"), path, value);
        _isDirty = true;
    }
    
    public function deleteKey(path                              : Dynamic) : Void
    {
        Reflect.deleteField(Reflect.field(CACHE, "keys"), path);
        _isDirty = true;
    }
    
    public function clear() : Void
    {
        CACHE = getDefaultCacheObject();
        _isDirty = true;
    }
    
    private function get_cacheFound() : Bool
    {
        return _cacheFound;
    }
    
    private function get_keys() : Array<String>
    {
        var v                              : Dynamic= [];
        
        for (key in as3hx.Compat.iter(Reflect.fields(Reflect.field(CACHE, "keys"))))
        {
            v[v.length] = key;
        }
        
        return v;
    }
    
    private function get_cache() : Dynamic
    {
        return Reflect.field(CACHE, "keys");
    }
    
    private function getDefaultCacheObject() : Dynamic
    {
        return {
            cache_version : CACHE_FILE_VERSION,
            keys : { }
        };
    }
}

