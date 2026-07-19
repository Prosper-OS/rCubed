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
    public var messagesAvailable(get, never) : Bool;

    
    public static var MAX_SOCKET_BYTE_SIZE : Int = 1024 * 1024 * 8;
    
    private function get_messagesAvailable() : Bool
    {
        return readQueue.length > 0;
    }
    
    private var socketBytes : ByteArray;
    private var readQueue : Array<Message>;
    
    private var closed : Bool;
    private var firstRequestProcessed : Bool;
    private var socket : Socket;
    
    private var messageSerializer : IMessageSerializer;
    private var crossDomainPolicyXML : FastXML;
    
    public function new(socket : Socket, messageSerializer : IMessageSerializer, crossDomainPolicyXML : FastXML = null)
    {
        super();
        this.socket = socket;
        this.messageSerializer = messageSerializer;
        this.crossDomainPolicyXML = crossDomainPolicyXML;
        
        if (crossDomainPolicyXML == null)
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
        if (!closed)
        {
            closed = true;
            if (socket.connected)
            {
                socket.close();
            }
            
            //dispatch close event
            dispatchEvent(new Event(Event.CLOSE));
        }
    }
    
    public function readMessage() : Message
    {
        var message : Message = null;
        if (readQueue.length > 0)
        {
            message = readQueue.shift();
        }
        return message;
    }
    
    public function writeMessage(messageToWrite : Message) : Void
    {  //override this method in the inheriting classes  
        
    }
    
    public function printInvalidConnectionMessage() : Void
    {
        var response : String = "HTTP/1.0 200 OK\nContent-Type: text/html\n\nPlease use <a href=\"" + Constant.WEBSOCKET_OVERLAY_URL + "\">" + Constant.WEBSOCKET_OVERLAY_URL + "</a> to access overlay features.";
        var responseBytes : ByteArray = new ByteArray();
        responseBytes.writeUTFBytes(response);
        responseBytes.position = 0;
        socket.writeBytes(responseBytes);
        socket.flush();
        socketBytes.clear();
        this.close();
    }
    
    private function socketCloseHandler(event : Event) : Void
    {
        close();
    }
    
    private function socketIOErrorHandler(event : IOErrorEvent) : Void
    {
    }
    
    private function socketDataHandler(event : ProgressEvent) : Void
    {
        if (socket.bytesAvailable > 0) {
if (!firstRequestProcessed)
            {
                firstRequestProcessed = true;
                //process each byte, and send a cross domain reply, before the NULL byte
                while (socket.bytesAvailable > 0)
                {
                    var byte : Int = socket.readByte();
                    socketBytes.writeByte(byte);
                    if (byte == 62) {
socketBytes.position = 0;
                        var msg : String = socketBytes.readUTFBytes(socketBytes.length);
                        try
                        {
                            var msgXML : FastXML = new FastXML(msg);
                            if (msgXML.node.name.innerData() == "policy-file-request") {
var crossDomainReply : ByteArray = new ByteArray();
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
            if (queueMessagesFromSocketBytes())
            {
                socketBytes.clear();
            }
            //prevent overflow
            else
            {
                
                if (socketBytes.length > MAX_SOCKET_BYTE_SIZE)
                {
                    socketBytes.clear();
                }
            }
            if (readQueue.length > 0)
            {
                dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
            }
        }
    }
    
    private function queueMessagesFromSocketBytes() : Bool
    {
        return false;
    }
    
    private function writeSocketBytes(bytes : ByteArray) : Void
    {
        socket.writeBytes(bytes);
        socket.flush();
    }
    
    private function securityErrorHandler(event : SecurityErrorEvent) : Void
    {
    }
    
    override public function toString() : String
    {
        return "[SocketClientHandler local=" + socket.localAddress + ":" + socket.localPort + ", remote=" + socket.remoteAddress + ":" + socket.remotePort;
    }
}

