package be.aboutme.airserver.endpoints.socket.handlers;

import be.aboutme.airserver.messages.serialization.IMessageSerializer;
import openfl.net.Socket;

class SocketClientHandlerFactory
{
    public var type                              : Dynamic= "unknown";
    
    public var messageSerializer                              : Dynamic;
    public var crossDomainPolicyXML                              : Dynamic;
    
    public function new(messageSerializer                              : Dynamic, crossDomainPolicyXML                              : Dynamic= null)
    {
        this.messageSerializer = messageSerializer;
        this.crossDomainPolicyXML = crossDomainPolicyXML;
    }
    
    public function createHandler(socket                              : Dynamic) : SocketClientHandler
    {
        return new SocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
    }
}

