package be.aboutme.airserver.events;

import be.aboutme.airserver.endpoints.IClientHandler;
import openfl.events.Event;

class EndPointEvent extends Event
{
    
    public static inline var CLIENT_HANDLER_ADDED : String = "clientHandlerAdded";
    
    public var clientHandler : IClientHandler;
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
    
    override public function clone() : Event
    {
        var e : EndPointEvent = new EndPointEvent(type, bubbles, cancelable);
        e.clientHandler = clientHandler;
        return e;
    }
}

