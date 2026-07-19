package classes.mp.mode.ffr.mods;


class MPGameplayModBoolean
{
    public var mod : String;
    public var enabled : Bool = false;
    public var value : Bool;
    
    public function new(mod : String, enabled : Bool = false, value : Bool = false)
    {
        this.mod = mod;
        this.enabled = enabled;
        this.value = value;
    }
}

