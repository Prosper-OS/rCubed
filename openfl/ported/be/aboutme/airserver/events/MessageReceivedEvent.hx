package be.aboutme.airserver.events;

import be.aboutme.airserver.messages.Message;
import openfl.events.Event;

class MessageReceivedEvent extends Event
{
    
    public static inline var MESSAGE_RECEIVED : String = "messageReceived";
    
    public var message : Message;
    
    public function new(type : String, message : Message, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
        this.message = message;
    }
    
    override public function clone() : Event
    {
        return new MessageReceivedEvent(type, message, bubbles, cancelable);
    }
}

