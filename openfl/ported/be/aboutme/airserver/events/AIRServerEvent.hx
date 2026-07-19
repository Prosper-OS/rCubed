package be.aboutme.airserver.events;

import be.aboutme.airserver.Client;
import openfl.events.Event;

class AIRServerEvent extends Event
{
    
    public static inline var CLIENT_ADDED : String = "clientAdded";
    public static inline var CLIENT_REMOVED : String = "clientRemoved";
    
    public var client : Client;
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
}

