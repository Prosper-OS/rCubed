package be.aboutme.airserver.events;

import be.aboutme.airserver.Client;
import openfl.events.Event;

class AIRServerEvent extends Event
{
    
    public static inline var CLIENT_ADDED                              : Dynamic= "clientAdded";
    public static inline var CLIENT_REMOVED                              : Dynamic= "clientRemoved";
    
    public var client                              : Dynamic;
    
    public function new(type                              : Dynamic, bubbles                              : Dynamic= false, cancelable                              : Dynamic= false)
    {
        super(type, bubbles, cancelable);
    }
}

