package be.aboutme.airserver.endpoints.socket.handlers.websocket;

import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
import be.aboutme.airserver.messages.serialization.IMessageSerializer;
import be.aboutme.airserver.messages.serialization.JSONSerializer;
import openfl.net.Socket;

class WebSocketClientHandlerFactory extends SocketClientHandlerFactory
{
    
    public function new(messageSerializer                              : Dynamic= null, crossDomainPolicyXML                              : Dynamic= null)
    {
        if (as3hx.Compat.truthy(messageSerializer == null))
        {
            messageSerializer = new JSONSerializer();
        }
        super(messageSerializer, crossDomainPolicyXML);
        
        type = "websocket";
    }
    
    override public function createHandler(socket                              : Dynamic) : SocketClientHandler
    {
        return new WebSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
    }
}

