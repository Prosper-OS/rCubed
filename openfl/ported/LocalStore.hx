import openfl.errors.Error;
import openfl.net.SharedObject;

class LocalStore
{
    /** Local Shared Object, this is saved/flushed automatically when the application closes. */
    private static var SO_OBJECT : SharedObject = SharedObject.getLocal(Constant.LOCAL_SO_NAME);
    
    /**
     * Returns a top-level cloned object of all SharedObject variables.
     * @return Object
     */
    public static function getAllVariables() : Dynamic
    {
        var out : Dynamic = { };
        for (key in Reflect.fields(SO_OBJECT.data))
        {
            Reflect.setField(out, key, SO_OBJECT.data[key]);
        }
        return out;
    }
    
    /**
     * Gets a locally stored value if it exist, if not returns the provided default value.
     * @param key Variable Key
     * @param defaultValue Default Value
     */
    public static function getVariable(key : String, defaultValue : Dynamic) : Dynamic
    {
        if (SO_OBJECT.data[key] != null)
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
    public static function setVariable(key : String, value : Dynamic, minDiskSize : Int = 0) : Void
    {
        SO_OBJECT.setProperty(key, value);
        
        if (minDiskSize > 0)
        {
            flush(minDiskSize);
        }
    }
    
    /**
     * Deletes a variable from the local store.
     * @param key Variable Key
     */
    public static function deleteVariable(key : String) : Void
    {
    }
    
    /**
     * Writes shared object to file.
     * @param minDiskSize Minimum Local Store Size
     */
    public static function flush(minDiskSize : Int = 0) : Void
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

