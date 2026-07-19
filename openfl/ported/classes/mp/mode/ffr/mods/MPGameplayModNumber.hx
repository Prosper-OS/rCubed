package classes.mp.mode.ffr.mods;


class MPGameplayModNumber
{
    public var mod                             : Dynamic;
    public var enabled                             : Dynamic= false;
    public var value                             : Dynamic;
    
    public function new(mod                             : Dynamic, enabled                             : Dynamic= false, value                             : Dynamic= 1)
    {
        this.mod = mod;
        this.enabled = enabled;
        this.value = value;
    }
}

