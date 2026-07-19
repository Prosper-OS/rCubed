package be.aboutme.airserver.events;

import be.aboutme.airserver.endpoints.IClientHandler;
import openfl.events.Event;

class EndPointEvent extends Event
{
    
    public static inline var CLIENT_HANDLER_ADDED                              : Dynamic= "clientHandlerAdded";
    
    public var clientHandler                              : Dynamic;
    
    public function new(type                              : Dynamic, bubbles                              : Dynamic= false, cancelable                              : Dynamic= false)
    {
        super(type, bubbles, cancelable);
    }
    
    override public function clone() : Event
    {
        var e                              : Dynamic= new EndPointEvent(type, bubbles, cancelable);
        e.clientHandler = clientHandler;
        return e;
    }
}

