package classes.mp.mode.ffr.mods;


class MPGameplayModBoolean
{
    public var mod                             : Dynamic;
    public var enabled                             : Dynamic= false;
    public var value                             : Dynamic;
    
    public function new(mod                             : Dynamic, enabled                             : Dynamic= false, value                             : Dynamic= false)
    {
        this.mod = mod;
        this.enabled = enabled;
        this.value = value;
    }
}

