package classes;

import openfl.errors.Error;

class SongQueueItem
{
    public var name                              : Dynamic;
    public var items                              : Dynamic;
    
    public function new(name                              : Dynamic, items                              : Dynamic)
    {
        this.name = name;
        this.items = items;
    }
    
    public function toString() : String
    {
        return haxe.Json.stringify(this);
    }
    
    public static function fromString(json                              : Dynamic) : SongQueueItem
    {
        try
        {
            var obj                              : Dynamic= haxe.Json.parse(json);
            return new SongQueueItem(obj.name, obj.items);
        }
        catch (e : Error)
        {
        }
        
        return new SongQueueItem("invalid", []);
    }
}

