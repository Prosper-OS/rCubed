package be.aboutme.airserver.events;

import openfl.events.Event;

class MessagesAvailableEvent extends Event
{
    
    public static inline var MESSAGES_AVAILABLE : String = "messagesAvailable";
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
}

