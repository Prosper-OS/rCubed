package classes.mp.mode.ffr.mods;


class MPGameplayModNumber
{
    public var mod : String;
    public var enabled : Bool = false;
    public var value : Float;
    
    public function new(mod : String, enabled : Bool = false, value : Float = 1)
    {
        this.mod = mod;
        this.enabled = enabled;
        this.value = value;
    }
}

