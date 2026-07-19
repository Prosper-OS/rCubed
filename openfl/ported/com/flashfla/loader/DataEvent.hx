package com.flashfla.loader;

import openfl.events.Event;

class DataEvent extends Event
{
    public var data                            : Dynamic;
    
    public function new(type                            : Dynamic, data                            : Dynamic, bubbles                            : Dynamic= false, cancelable                            : Dynamic= false)
    {
        this.data = data;
        super(type, bubbles, cancelable);
    }
}

