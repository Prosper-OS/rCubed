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
    public var id(get, never) : Int;

    
    private var _id : Int;
    
    private function get_id() : Int
    {
        return _id;
    }
    
    private var closed : Bool;
    private var clientHandler : IClientHandler;
    
    public function new(id : Int, clientHandler : IClientHandler)
    {
        super();
        this._id = id;
        this.clientHandler = clientHandler;
        
        clientHandler.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
        clientHandler.addEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler, false, 0, true);
    }
    
    private function messagesAvailableHandler(event : MessagesAvailableEvent) : Void
    {
        while (clientHandler.messagesAvailable)
        {
            var message : Message = clientHandler.readMessage();
            if (message != null)
            {
                message.senderId = this.id;
                dispatchEvent(new MessageReceivedEvent(MessageReceivedEvent.MESSAGE_RECEIVED, message));
            }
        }
    }
    
    public function sendMessage(message : Message) : Void
    {
        clientHandler.writeMessage(message);
    }
    
    public function close() : Void
    {
        if (!closed)
        {
            closed = true;
            
            clientHandler.removeEventListener(Event.CLOSE, closeHandler);
            clientHandler.removeEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler);
            clientHandler.close();
            
            dispatchEvent(new Event(Event.CLOSE));
        }
    }
    
    private function closeHandler(event : Event) : Void
    {
        close();
    }
    
    override public function toString() : String
    {
        return "[Client, " + clientHandler + "]";
    }
}

