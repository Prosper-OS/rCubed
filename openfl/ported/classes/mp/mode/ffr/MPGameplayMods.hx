package classes.mp.mode.ffr;

import classes.chart.Song;
import classes.mp.mode.ffr.mods.MPGameplayModBoolean;
import classes.mp.mode.ffr.mods.MPGameplayModNumber;
import game.GameOptions;

class MPGameplayMods
{
    public var rate                             : Dynamic= new MPGameplayModNumber("rate");
    public var hidden                             : Dynamic= new MPGameplayModBoolean("hidden");
    public var sudden                             : Dynamic= new MPGameplayModBoolean("sudden");
    public var blink                             : Dynamic= new MPGameplayModBoolean("blink");
    public var rotating                             : Dynamic= new MPGameplayModBoolean("rotating");
    public var rotate_cw                             : Dynamic= new MPGameplayModBoolean("rotate_cw");
    public var rotate_ccw                             : Dynamic= new MPGameplayModBoolean("rotate_ccw");
    public var wave                             : Dynamic= new MPGameplayModBoolean("wave");
    public var drunk                             : Dynamic= new MPGameplayModBoolean("drunk");
    public var tornado                             : Dynamic= new MPGameplayModBoolean("tornado");
    public var mini_resize                             : Dynamic= new MPGameplayModBoolean("mini_resize");
    public var tap_pulse                             : Dynamic= new MPGameplayModBoolean("tap_pulse");
    public var nobackground                             : Dynamic= new MPGameplayModBoolean("nobackground");
    
    public function update(data                             : Dynamic) : Void
    {
        rate.enabled = data.exists(rate.mod);
        rate.value = (rate.enabled) ? data.rate : 1;
        
        hidden.enabled = data.exists(hidden.mod);
        hidden.value = (hidden.enabled) ? data.hidden : false;
        
        sudden.enabled = data.exists(sudden.mod);
        sudden.value = (sudden.enabled) ? data.sudden : false;
        
        blink.enabled = data.exists(blink.mod);
        blink.value = (blink.enabled) ? data.blink : false;
        
        rotating.enabled = data.exists(rotating.mod);
        rotating.value = (rotating.enabled) ? data.rotating : false;
        
        rotate_cw.enabled = data.exists(rotate_cw.mod);
        rotate_cw.value = (rotate_cw.enabled) ? data.rotate_cw : false;
        
        rotate_ccw.enabled = data.exists(rotate_ccw.mod);
        rotate_ccw.value = (rotate_ccw.enabled) ? data.rotate_ccw : false;
        
        wave.enabled = data.exists(wave.mod);
        wave.value = (wave.enabled) ? data.wave : false;
        
        drunk.enabled = data.exists(drunk.mod);
        drunk.value = (drunk.enabled) ? data.drunk : false;
        
        tornado.enabled = data.exists(tornado.mod);
        tornado.value = (tornado.enabled) ? data.tornado : false;
        
        mini_resize.enabled = data.exists(mini_resize.mod);
        mini_resize.value = (mini_resize.enabled) ? data.mini_resize : false;
        
        tap_pulse.enabled = data.exists(tap_pulse.mod);
        tap_pulse.value = (tap_pulse.enabled) ? data.tap_pulse : false;
        
        nobackground.enabled = data.exists(nobackground.mod);
        nobackground.value = (nobackground.enabled) ? data.nobackground : false;
    }
    
    /**
     * Check if any gameplay override mod is enabled.
     * @return
     */
    public function enabled() : Bool
    {
        return rate.enabled || hidden.enabled || sudden.enabled || blink.enabled || rotating.enabled || rotate_cw.enabled || rotate_ccw.enabled || wave.enabled || drunk.enabled || tornado.enabled || mini_resize.enabled || tap_pulse.enabled || nobackground.enabled;
    }
    
    /**
     * Apply gameplay modifications.
     * @param options
     * @param song
     */
    public function apply(options                             : Dynamic, song                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(rate.enabled && options.songRate != rate.value))
        {
            options.songRate = rate.value;
            song.isDirty = true;
        }
        
        if (as3hx.Compat.truthy(hidden.enabled))
        {
            options.setModBooleanState(hidden.mod, hidden.value);
        }
        
        if (as3hx.Compat.truthy(sudden.enabled))
        {
            options.setModBooleanState(sudden.mod, sudden.value);
        }
        
        if (as3hx.Compat.truthy(blink.enabled))
        {
            options.setModBooleanState(blink.mod, blink.value);
        }
        
        if (as3hx.Compat.truthy(rotating.enabled))
        {
            options.setModBooleanState(rotating.mod, rotating.value);
        }
        
        if (as3hx.Compat.truthy(rotate_cw.enabled))
        {
            options.setModBooleanState(rotate_cw.mod, rotate_cw.value);
        }
        
        if (as3hx.Compat.truthy(rotate_ccw.enabled))
        {
            options.setModBooleanState(rotate_ccw.mod, rotate_ccw.value);
        }
        
        if (as3hx.Compat.truthy(wave.enabled))
        {
            options.setModBooleanState(wave.mod, wave.value);
        }
        
        if (as3hx.Compat.truthy(drunk.enabled))
        {
            options.setModBooleanState(drunk.mod, drunk.value);
        }
        
        if (as3hx.Compat.truthy(tornado.enabled))
        {
            options.setModBooleanState(tornado.mod, tornado.value);
        }
        
        if (as3hx.Compat.truthy(mini_resize.enabled))
        {
            options.setModBooleanState(mini_resize.mod, mini_resize.value);
        }
        
        if (as3hx.Compat.truthy(tap_pulse.enabled))
        {
            options.setModBooleanState(tap_pulse.mod, tap_pulse.value);
        }
        
        if (as3hx.Compat.truthy(nobackground.enabled))
        {
            options.setModBooleanState(nobackground.mod, nobackground.value);
        }
        
        song.handleDirty(options);
    }

    public function new()
    {
    }
}

