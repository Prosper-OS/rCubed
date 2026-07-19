package be.aboutme.airserver.endpoints.socket.handlers;

import be.aboutme.airserver.messages.serialization.IMessageSerializer;
import openfl.net.Socket;

class SocketClientHandlerFactory
{
    public var type : String = "unknown";
    
    private var messageSerializer : IMessageSerializer;
    private var crossDomainPolicyXML : FastXML;
    
    public function new(messageSerializer : IMessageSerializer, crossDomainPolicyXML : FastXML = null)
    {
        this.messageSerializer = messageSerializer;
        this.crossDomainPolicyXML = crossDomainPolicyXML;
    }
    
    public function createHandler(socket : Socket) : SocketClientHandler
    {
        return new SocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
    }
}

