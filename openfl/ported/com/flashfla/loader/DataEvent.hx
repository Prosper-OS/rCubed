package com.flashfla.loader;

import openfl.events.Event;

class DataEvent extends Event
{
    public var data : Dynamic;
    
    public function new(type : String, data : Dynamic, bubbles : Bool = false, cancelable : Bool = false)
    {
        this.data = data;
        super(type, bubbles, cancelable);
    }
}

