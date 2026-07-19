import openfl.errors.Error;
import openfl.net.SharedObject;

class LocalStore
{
    /** Local Shared Object, this is saved/flushed automatically when the application closes. */
    private static var SO_OBJECT                              : Dynamic= SharedObject.getLocal(Constant.LOCAL_SO_NAME);
    
    /**
     * Returns a top-level cloned object of all SharedObject variables.
     * @return Object
     */
    public static function getAllVariables() : Dynamic
    {
        var out                              : Dynamic= { };
        for (key in as3hx.Compat.iter(Reflect.fields(SO_OBJECT.data)))
        {
            Reflect.setField(out, Std.string(key), as3hx.Compat.field(SO_OBJECT.data, key));
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
        if (as3hx.Compat.truthy(SO_OBJECT.data[key] != null))
        {
            return SO_OBJECT.data[key];
        }
        return defaultValue;
    }
    
    /**
     * Sets a value into the local store.
     * @param key Variable Key
     * @param value Value
     * @param minDiskSize Minimum Local Store Size
     */
    public static function setVariable(key                              : Dynamic, value                              : Dynamic, minDiskSize                              : Dynamic= 0) : Void
    {
        SO_OBJECT.setProperty(key, value);
        
        if (as3hx.Compat.truthy(minDiskSize > 0))
        {
            flush(minDiskSize);
        }
    }
    
    /**
     * Deletes a variable from the local store.
     * @param key Variable Key
     */
    public static function deleteVariable(key                              : Dynamic) : Void
    {
    }
    
    /**
     * Writes shared object to file.
     * @param minDiskSize Minimum Local Store Size
     */
    public static function flush(minDiskSize                              : Dynamic= 0) : Void
    {
        try
        {
            SO_OBJECT.flush(minDiskSize);
        }
        catch (e : Error)
        {
        }
    }

    public function new()
    {
    }
}

