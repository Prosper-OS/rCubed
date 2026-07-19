package be.aboutme.airserver.events;

import be.aboutme.airserver.messages.Message;
import openfl.events.Event;

class MessageReceivedEvent extends Event
{
    
    public static inline var MESSAGE_RECEIVED                              : Dynamic= "messageReceived";
    
    public var message                              : Dynamic;
    
    public function new(type                              : Dynamic, message                              : Dynamic, bubbles                              : Dynamic= false, cancelable                              : Dynamic= false)
    {
        super(type, bubbles, cancelable);
        this.message = message;
    }
    
    override public function clone() : Event
    {
        return new MessageReceivedEvent(type, message, bubbles, cancelable);
    }
}

