package be.aboutme.airserver.endpoints.socket.handlers;

import openfl.errors.Error;
import be.aboutme.airserver.endpoints.IClientHandler;
import be.aboutme.airserver.events.MessagesAvailableEvent;
import be.aboutme.airserver.messages.Message;
import be.aboutme.airserver.messages.serialization.IMessageSerializer;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.Socket;
import openfl.utils.ByteArray;

class SocketClientHandler extends EventDispatcher implements IClientHandler
{
    public var messagesAvailable(get, never)                              : Dynamic;

    
    public static var MAX_SOCKET_BYTE_SIZE                              : Dynamic= 1024 * 1024 * 8;
    
    private function get_messagesAvailable() : Bool
    {
        return readQueue.length > 0;
    }
    
    public var socketBytes                              : Dynamic;
    public var readQueue                              : Dynamic;
    
    public var closed                              : Dynamic;
    public var firstRequestProcessed                              : Dynamic;
    public var socket                              : Dynamic;
    
    public var messageSerializer                              : Dynamic;
    public var crossDomainPolicyXML                              : Dynamic;
    
    public function new(socket                              : Dynamic, messageSerializer                              : Dynamic, crossDomainPolicyXML                              : Dynamic= null)
    {
        super();
        this.socket = socket;
        this.messageSerializer = messageSerializer;
        this.crossDomainPolicyXML = crossDomainPolicyXML;
        
        if (as3hx.Compat.truthy(crossDomainPolicyXML == null))
        {
            crossDomainPolicyXML = new FastXML("<?xml version=\"1.0\"?>" + "<!DOCTYPE cross-domain-policy SYSTEM \"/xml/dtds/cross-domain-policy.dtd\">" + "<cross-domain-policy>" + "   <allow-access-from domain=\"*\" to-ports=\"*\" />" + "</cross-domain-policy>");
        }
        this.crossDomainPolicyXML = crossDomainPolicyXML;
        
        socketBytes = new ByteArray();
        readQueue = new Array<Message>();
        
        socket.addEventListener(Event.CLOSE, socketCloseHandler, false, 0, true);
        socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler, false, 0, true);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
    }
    
    public function close() : Void
    {
        if (as3hx.Compat.truthy(!closed))
        {
            closed = true;
            if (as3hx.Compat.truthy(socket.connected))
            {
                socket.close();
            }
            
            //dispatch close event
            dispatchEvent(new Event(Event.CLOSE));
        }
    }
    
    public function readMessage() : Message
    {
        var message                              : Dynamic= null;
        if (as3hx.Compat.truthy(readQueue.length > 0))
        {
            message = readQueue.shift();
        }
        return message;
    }
    
    public function writeMessage(messageToWrite                              : Dynamic) : Void
    {  //override this method in the inheriting classes  
        
    }
    
    public function printInvalidConnectionMessage() : Void
    {
        var response                              : Dynamic= "HTTP/1.0 200 OK\nContent-Type: text/html\n\nPlease use <a href=\"" + Constant.WEBSOCKET_OVERLAY_URL + "\">" + Constant.WEBSOCKET_OVERLAY_URL + "</a> to access overlay features.";
        var responseBytes                              : Dynamic= new ByteArray();
        responseBytes.writeUTFBytes(response);
        responseBytes.position = 0;
        socket.writeBytes(responseBytes);
        socket.flush();
        socketBytes.clear();
        this.close();
    }
    
    public function socketCloseHandler(event                              : Dynamic) : Void
    {
        close();
    }
    
    public function socketIOErrorHandler(event                              : Dynamic) : Void
    {
    }
    
    public function socketDataHandler(event                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(socket.bytesAvailable > 0)) {
if (as3hx.Compat.truthy(!firstRequestProcessed))
            {
                firstRequestProcessed = true;
                //process each byte, and send a cross domain reply, before the NULL byte
                while (as3hx.Compat.truthy(socket.bytesAvailable > 0))
                {
                    var byte                              : Dynamic= socket.readByte();
                    socketBytes.writeByte(byte);
                    if (as3hx.Compat.truthy(byte == 62)) {
socketBytes.position = 0;
                        var msg                              : Dynamic= socketBytes.readUTFBytes(socketBytes.length);
                        try
                        {
                            var msgXML                              : Dynamic= new FastXML(msg);
                            if (as3hx.Compat.truthy(msgXML.node.name.innerData() == "policy-file-request")) {
var crossDomainReply                              : Dynamic= new ByteArray();
                                crossDomainReply.writeUTFBytes(crossDomainPolicyXML.node.toXMLString.innerData());
                                crossDomainReply.writeByte(0);
                                socket.writeBytes(crossDomainReply);
                                socket.flush();
                                //stop right here
                                socketBytes.clear();
                                return;
                            }
                        }
                        catch (e : Error)
                        {
                        }
                    }
                }
            }
            else
            {
                socket.readBytes(socketBytes, socketBytes.position);
            }
            socketBytes.position = 0;
            if (as3hx.Compat.truthy(queueMessagesFromSocketBytes()))
            {
                socketBytes.clear();
            }
            //prevent overflow
            else
            {
                
                if (as3hx.Compat.truthy(socketBytes.length > MAX_SOCKET_BYTE_SIZE))
                {
                    socketBytes.clear();
                }
            }
            if (as3hx.Compat.truthy(readQueue.length > 0))
            {
                dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
            }
        }
    }
    
    public function queueMessagesFromSocketBytes() : Bool
    {
        return false;
    }
    
    public function writeSocketBytes(bytes                              : Dynamic) : Void
    {
        socket.writeBytes(bytes);
        socket.flush();
    }
    
    public function securityErrorHandler(event                              : Dynamic) : Void
    {
    }
    
    override public function toString() : String
    {
        return "[SocketClientHandler local=" + socket.localAddress + ":" + socket.localPort + ", remote=" + socket.remoteAddress + ":" + socket.remotePort;
    }
}

