package be.aboutme.airserver;

import be.aboutme.airserver.endpoints.IClientHandler;
import be.aboutme.airserver.events.MessageReceivedEvent;
import be.aboutme.airserver.events.MessagesAvailableEvent;
import be.aboutme.airserver.messages.Message;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:meta(Event(name="messageReceived",type="be.aboutme.airserver.events.MessageReceivedEvent"))

@:meta(Event(name="close",type="openfl.events.Event"))

class Client extends EventDispatcher
{
    public var id(get, never)                              : Dynamic;

    
    private var _id                              : Dynamic;
    
    private function get_id() : Int
    {
        return _id;
    }
    
    private var closed                              : Dynamic;
    private var clientHandler                              : Dynamic;
    
    public function new(id                              : Dynamic, clientHandler                              : Dynamic)
    {
        super();
        this._id = id;
        this.clientHandler = clientHandler;
        
        clientHandler.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
        clientHandler.addEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler, false, 0, true);
    }
    
    private function messagesAvailableHandler(event                              : Dynamic) : Void
    {
        while (as3hx.Compat.truthy(clientHandler.messagesAvailable))
        {
            var message                              : Dynamic= clientHandler.readMessage();
            if (as3hx.Compat.truthy(message != null))
            {
                message.senderId = this.id;
                dispatchEvent(new MessageReceivedEvent(MessageReceivedEvent.MESSAGE_RECEIVED, message));
            }
        }
    }
    
    public function sendMessage(message                              : Dynamic) : Void
    {
        clientHandler.writeMessage(message);
    }
    
    public function close() : Void
    {
        if (as3hx.Compat.truthy(!closed))
        {
            closed = true;
            
            clientHandler.removeEventListener(Event.CLOSE, closeHandler);
            clientHandler.removeEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler);
            clientHandler.close();
            
            dispatchEvent(new Event(Event.CLOSE));
        }
    }
    
    private function closeHandler(event                              : Dynamic) : Void
    {
        close();
    }
    
    override public function toString() : String
    {
        return "[Client, " + clientHandler + "]";
    }
}

