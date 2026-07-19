package be.aboutme.airserver.events;

import openfl.events.Event;

class MessagesAvailableEvent extends Event
{
    
    public static inline var MESSAGES_AVAILABLE                              : Dynamic= "messagesAvailable";
    
    public function new(type                              : Dynamic, bubbles                              : Dynamic= false, cancelable                              : Dynamic= false)
    {
        super(type, bubbles, cancelable);
    }
}

