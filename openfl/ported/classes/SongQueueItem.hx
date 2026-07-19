package classes;

import openfl.errors.Error;

class SongQueueItem
{
    public var name : String;
    public var items : Array<Dynamic>;
    
    public function new(name : String, items : Array<Dynamic>)
    {
        this.name = name;
        this.items = items;
    }
    
    public function toString() : String
    {
        return haxe.Json.stringify(this);
    }
    
    public static function fromString(json : String) : SongQueueItem
    {
        try
        {
            var obj : Dynamic = haxe.Json.parse(json);
            return new SongQueueItem(obj.name, obj.items);
        }
        catch (e : Error)
        {
        }
        
        return new SongQueueItem("invalid", []);
    }
}

