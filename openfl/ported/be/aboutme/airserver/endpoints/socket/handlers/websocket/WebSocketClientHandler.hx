/*

   The implementation for the websocket version 8 spec is based on the implementation
   in the Bauglir Internet Library. See the disclaimer below:

   BEGIN DISCLAIMER

   /=============================================================================|
   | Project : Bauglir Internet Library                                           |
   |==============================================================================|
   | Content: Generic connection and server                                       |
   |==============================================================================|
   | Copyright (c)2011, Bronislav Klucka                                          |
   | All rights reserved.                                                         |
   | Source code is licenced under original 4-clause BSD licence:                 |
   | http://licence.bauglir.com/bsd4.php                                          |
   |                                                                              |
   |                                                                              |
   | Project download homepage:                                                   |
   |   http://code.google.com/p/bauglir-websocket/                                |
   | Project homepage:                                                            |
   |   http://www.webnt.eu/index.php                                              |
   | WebSocket version 8 spec.:                                                   |
   |   http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-10         |
   |                                                                              |
   |                                                                              |
   |=============================================================================

   END DISCLAIMER

 */

package be.aboutme.airserver.endpoints.socket.handlers.websocket;

import openfl.errors.Error;
import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
import be.aboutme.airserver.events.MessagesAvailableEvent;
import be.aboutme.airserver.messages.Message;
import be.aboutme.airserver.messages.serialization.IMessageSerializer;
import by.blooddy.crypto.Base64;
import by.blooddy.crypto.MD5;
import by.blooddy.crypto.SHA1;
import openfl.events.ProgressEvent;
import openfl.net.Socket;
import openfl.utils.ByteArray;

class WebSocketClientHandler extends SocketClientHandler
{
    public static inline var PROTOCOL_HYBI_00                              : Dynamic= 0;
    public static inline var PROTOCOL_HYBI_10                              : Dynamic= 8;
    public static inline var PROTOCOL_HYBI_17                              : Dynamic= 13;
    
    public static inline var FRAME_CONTINUATION                              : Dynamic= 0x00;
    public static inline var FRAME_TEXT                              : Dynamic= 0x01;
    public static inline var FRAME_BINARY                              : Dynamic= 0x02;
    public static inline var FRAME_CLOSE                              : Dynamic= 0x08;
    public static inline var FRAME_PING                              : Dynamic= 0x09;
    public static inline var FRAME_PONG                              : Dynamic= 0x0A;
    
    public var protocol                              : Dynamic;
    
    public function new(socket                              : Dynamic, messageSerializer                              : Dynamic, crossDomainPolicyXML                              : Dynamic= null)
    {
        super(socket, messageSerializer, crossDomainPolicyXML);
    }
    
    override public function socketDataHandler(event                              : Dynamic) : Void
    //trace("WebSocketClientHandler::socketDataHandler");
    {
        
        if (as3hx.Compat.truthy(socket.bytesAvailable > 0))
        {
            if (as3hx.Compat.truthy(!firstRequestProcessed))
            {
                firstRequestProcessed = true;
                
                //websockets handshake?
                socket.readBytes(socketBytes, 0);
                var message                              : Dynamic= socketBytes.readUTFBytes(socketBytes.bytesAvailable);
                if (as3hx.Compat.truthy(message.indexOf("GET ") == 0))
                {
                    var messageLines                              : Dynamic= message.split("\n");
                    var fields                              : Dynamic= { };
                    var requestedURL                              : Dynamic= "";
                    for (i in 0...messageLines.length)
                    {
                        var line                              : Dynamic= messageLines[i];
                        if (as3hx.Compat.truthy(i == 0))
                        {
                            var getSplit                              : Dynamic= line.split(" ");
                            if (as3hx.Compat.truthy(getSplit.length > 1))
                            {
                                requestedURL = getSplit[1];
                            }
                        }
                        else
                        {
                            var index                              : Dynamic= line.indexOf(":");
                            if (as3hx.Compat.truthy(index > -1))
                            {
                                var key                              : Dynamic= line.substr(0, index);
                                Reflect.setField(fields, key, line.substr(index + 1).replace(new as3hx.Compat.Regex('^([\\s|\\t|\\n]+)?(.*)([\\s|\\t|\\n]+)?$', "gm"), "$2"));
                            }
                        }
                    }
                    
                    //check for any fields stating websocket
                    var isWebsocket                              : Dynamic= (Reflect.field(fields, "Upgrade") != null && Reflect.field(fields, "Upgrade") == "websocket");
                    if (as3hx.Compat.truthy(!isWebsocket))
                    {
                        for (field_name in as3hx.Compat.iter(Reflect.fields(fields)))
                        {
                            if (as3hx.Compat.truthy(field_name.toLowerCase().indexOf("websocket") >= 0))
                            {
                                isWebsocket = true;
                                break;
                            }
                        }
                    }
                    
                    if (as3hx.Compat.truthy(!isWebsocket))
                    {
                        printInvalidConnectionMessage();
                        return;
                    }
                    
                    //check the websocket version
                    if (as3hx.Compat.truthy(Reflect.field(fields, "Sec-WebSocket-Version") != null))
                    {
                        protocol = as3hx.Compat.parseInt(Reflect.field(fields, "Sec-WebSocket-Version"));
                    }
                    else
                    {
                        protocol = PROTOCOL_HYBI_00;
                    }
                    
                    switch (protocol)
                    {
                        case PROTOCOL_HYBI_00:
                            sendHybi00Response(fields, requestedURL);
                        case PROTOCOL_HYBI_10:
                            sendHybi10Response(fields, requestedURL);
                        case PROTOCOL_HYBI_17:
                            sendHybi17Response(fields, requestedURL);
                        default:
                            close();
                    }
                    return;
                }
                else
                {
                    close();
                    return;
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
                
                if (as3hx.Compat.truthy(socketBytes.length > SocketClientHandler.MAX_SOCKET_BYTE_SIZE))
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
    
    public function sendHybi00Response(fields                              : Dynamic, requestedURL                              : Dynamic) : Void
    //draft-ietf-hybi-thewebsocketprotocol-00
    {
        
        //send a response
        var result                              : Dynamic= Reflect.field(fields, "Sec-WebSocket-Key1").match(new as3hx.Compat.Regex('[0-9]', "gi"));
        var key1Nr                              : Dynamic= ((Std.is(result, Array))) ? as3hx.Compat.parseInt(result.join("")) : 1;
        result = Reflect.field(fields, "Sec-WebSocket-Key1").match(new as3hx.Compat.Regex(' ', "gi"));
        var key1SpaceCount                              : Dynamic= ((Std.is(result, Array))) ? result.length : 1;
        var key1Part                              : Dynamic= key1Nr / key1SpaceCount;
        
        result = Reflect.field(fields, "Sec-WebSocket-Key2").match(new as3hx.Compat.Regex('[0-9]', "gi"));
        var key2Nr                              : Dynamic= ((Std.is(result, Array))) ? as3hx.Compat.parseInt(result.join("")) : 1;
        result = Reflect.field(fields, "Sec-WebSocket-Key2").match(new as3hx.Compat.Regex(' ', "gi"));
        var key2SpaceCount                              : Dynamic= ((Std.is(result, Array))) ? result.length : 1;
        var key2Part                              : Dynamic= key2Nr / key2SpaceCount;
        
        //calculate binary md5 hash
        var bytesToHash                              : Dynamic= new ByteArray();
        bytesToHash.writeUnsignedInt(key1Part);
        bytesToHash.writeUnsignedInt(key2Part);
        bytesToHash.writeBytes(socketBytes, socketBytes.length - 8);
        
        //hash it
        var hash                              : Dynamic= MD5.hashBytes(bytesToHash);
        
        var response                              : Dynamic= "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "Sec-WebSocket-Origin: " + Reflect.field(fields, "Origin") + "\r\n" + "Sec-WebSocket-Location: ws://" + Reflect.field(fields, "Host") + requestedURL + "\r\n" + "\r\n";
        var responseBytes                              : Dynamic= new ByteArray();
        responseBytes.writeUTFBytes(response);
        
        var i                              : Dynamic= 0;
        while (as3hx.Compat.truthy(i < hash.length))
        {
            responseBytes.writeByte(as3hx.Compat.parseInt(hash.substr(i, 2)));
            i += 2;
        }
        
        responseBytes.writeByte(0);
        responseBytes.position = 0;
        socket.writeBytes(responseBytes);
        socket.flush();
        socketBytes.clear();
    }
    
    public function sendHybi10Response(fields                              : Dynamic, requestedURL                              : Dynamic) : Void
    //var websocketKey                             : Dynamic= "dGhlIHNhbXBsZSBub25jZQ==";//test
    {
        
        var websocketKey                              : Dynamic= Reflect.field(fields, "Sec-WebSocket-Key");
        
        var guid                              : Dynamic= "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
        var hash                              : Dynamic= websocketKey + guid;
        
        hash = SHA1.hash(hash);
        
        var hashBytes                              : Dynamic= new ByteArray();
        var i                              : Dynamic= 0;
        while (as3hx.Compat.truthy(i < hash.length))
        {
            hashBytes.writeByte(as3hx.Compat.parseInt(hash.substr(i, 2)));
            i += 2;
        }
        
        hash = Base64.encode(hashBytes);
        
        var response                              : Dynamic= "HTTP/1.1 101 Switching Protocols\r\n" + "Upgrade: websocket\r\n" + "Connection: Upgrade\r\n" + "Sec-WebSocket-Accept: " + hash + "\r\n" + "\r\n";
        
        var responseBytes                              : Dynamic= new ByteArray();
        responseBytes.writeUTFBytes(response);
        responseBytes.position = 0;
        socket.writeBytes(responseBytes);
        socket.flush();
        socketBytes.clear();
    }
    
    public function sendHybi17Response(fields                              : Dynamic, requestedURL                              : Dynamic) : Void
    {
        sendHybi10Response(fields, requestedURL);
    }
    
    override public function queueMessagesFromSocketBytes() : Bool
    {
        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
        {
            var input                             : Dynamic= null;
            switch (protocol)
            {
                case PROTOCOL_HYBI_00:
                    input = decodeHybi00Input();
                case PROTOCOL_HYBI_10:
                    input = decodeHybi10Input();
                case PROTOCOL_HYBI_17:
                    input = decodeHybi17Input();
            }
            
            if (as3hx.Compat.truthy(input != null)) {
var deserialized                              : Dynamic= messageSerializer.deserialize(input);
                for (message in as3hx.Compat.iter(deserialized))
                {
                    readQueue.push(message);
                }
                return true;
            }
        }
        return false;
    }
    
    private function decodeHybi00Input() : String
    {
        var messageString                              : Dynamic= "";
        while (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
        {
            var byte                              : Dynamic= socketBytes.readByte();
            switch (byte)
            {
                case 0, -1:
                default:
                    messageString += String.fromCharCode(byte);
            }
        }
        return messageString;
    }
    
    private function decodeHybi10Input() : String
    {
        var messageString                              : Dynamic= "";
        var bt                              : Dynamic= null;
        var len                              : Dynamic= null;
        var mask                              : Dynamic= null;
        var masks                              : Dynamic= [0, 0, 0, 0];
        
        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
        {
            bt = socketBytes.readUnsignedByte();
            
            var aReadFinal                              : Dynamic= (bt & 0x80) == 0x80;
            var aRes1                              : Dynamic= (bt & 0x40) == 0x40;
            var aRes2                              : Dynamic= (bt & 0x20) == 0x20;
            var aRes3                              : Dynamic= (bt & 0x10) == 0x10;
            var aReadCode                              : Dynamic= as3hx.Compat.parseInt(bt & 0x0f);
            
            //frame_close
            if (as3hx.Compat.truthy(aReadCode == FRAME_CLOSE))
            {
                close();
                return null;
            }
            
            //mask & length
            if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
            {
                bt = socketBytes.readUnsignedByte();
                mask = (bt & 0x80) == 0x80;
                len = as3hx.Compat.parseInt(bt & 0x7F);
                if (as3hx.Compat.truthy(len == 126))
                {
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        bt = socketBytes.readUnsignedByte();
                        len = as3hx.Compat.parseInt(bt * 0x100);
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            bt = socketBytes.readUnsignedByte();
                            len = as3hx.Compat.parseInt(len + bt);
                        }
                    }
                }
                else if (as3hx.Compat.truthy(len == 127))
                {
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        bt = socketBytes.readUnsignedByte();
                        len = as3hx.Compat.parseInt(bt * Math.pow(2, 56));
                        bt = socketBytes.readUnsignedByte();
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * Math.pow(2, 48));
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * Math.pow(2, 40));
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * Math.pow(2, 32));
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x1000000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x10000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x100);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                        {
                            len = as3hx.Compat.parseInt(len + bt);
                        }
                    }
                }
                
                if (as3hx.Compat.truthy(!mask))
                {
                    socket.close();
                    return null;
                }
                
                //read mask
                if (as3hx.Compat.truthy(mask))
                {
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        masks[0] = socketBytes.readUnsignedByte();
                    }
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        masks[1] = socketBytes.readUnsignedByte();
                    }
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        masks[2] = socketBytes.readUnsignedByte();
                    }
                    if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                    {
                        masks[3] = socketBytes.readUnsignedByte();
                    }
                }
                
                if (as3hx.Compat.truthy(socketBytes.bytesAvailable > 0))
                {
                    var byteArray                              : Dynamic= new ByteArray();
                    var j                              : Dynamic= 0;
                    var k                              : Dynamic= 0;
                    var previousLength                              : Dynamic= 0;
                    while (as3hx.Compat.truthy(len > 0))
                    {
                        socketBytes.readBytes(byteArray, j, Math.min(len, as3hx.Compat.INT_MAX));
                        k = as3hx.Compat.parseInt(byteArray.length - previousLength);
                        j += k;
                        len -= k;
                        previousLength = byteArray.length;
                    }
                    if (as3hx.Compat.truthy(mask))
                    {
                        for (i in 0...byteArray.length)
                        {
                            byteArray[i] = (byteArray[i] ^ masks[i % 4]);
                        }
                    }
                    
                    byteArray.position = 0;
                    while (as3hx.Compat.truthy(byteArray.bytesAvailable > 0))
                    {
                        var byte                              : Dynamic= byteArray.readUnsignedByte();
                        switch (byte)
                        {
                            default:
                                messageString += String.fromCharCode(byte);
                        }
                    }
                }
            }
        }
        return messageString;
    }
    
    private function decodeHybi17Input() : String
    {
        return decodeHybi10Input();
    }
    
    override public function writeMessage(messageToWrite                              : Dynamic) : Void
    {
        var serialized                              : Dynamic= messageSerializer.serialize(messageToWrite);
        var bytes                              : Dynamic= new ByteArray();
        switch (protocol)
        {
            case PROTOCOL_HYBI_00:
                bytes.writeByte(0);
                bytes.writeUTFBytes(serialized);
                bytes.writeByte(255);
                writeSocketBytes(bytes);
            case PROTOCOL_HYBI_10:
                bytes.writeUTFBytes(serialized);
                sendHybi10Data(true, false, false, false, FRAME_TEXT, bytes);
            case PROTOCOL_HYBI_17:
                bytes.writeUTFBytes(serialized);
                sendHybi17Data(true, false, false, false, FRAME_TEXT, bytes);
        }
    }
    
    /*

     */
    public function sendHybi10Data(aWriteFinal                              : Dynamic, aRes1                              : Dynamic, aRes2                              : Dynamic, aRes3                              : Dynamic, aWriteCode                              : Dynamic, aStream                              : Dynamic) : Bool
    {
        var result                              : Dynamic= !closed;  // && (aWriteCode == FRAME_CLOSE);  
        var bt                              : Dynamic= 0;
        var sendLen                              : Dynamic= 0;
        var i                              : Dynamic= null;
        var len                              : Dynamic= 0;
        var stream                              : Dynamic= new ByteArray();
        var bytes                              : Dynamic= null;
        var masks                              : Dynamic= new ByteArray();
        var send                              : Dynamic= new ByteArray();
        var fMasking                              : Dynamic= false;  //do not mask when we are sending data  
        
        if (as3hx.Compat.truthy(result))
        {
            try {
bt = as3hx.Compat.parseInt(((aWriteFinal) ? 1 : 0) * 0x80);
                bt += as3hx.Compat.parseInt(((aRes1) ? 1 : 0) * 0x40);
                bt += as3hx.Compat.parseInt(((aRes2) ? 1 : 0) * 0x20);
                bt += as3hx.Compat.parseInt(((aRes3) ? 1 : 0) * 0x10);
                bt += aWriteCode;
                
                stream.writeByte(bt);
                
                //length & mask
                len = as3hx.Compat.parseInt(((fMasking) ? 1 : 0) * 0x80);
                if (as3hx.Compat.truthy(aStream.length < 126))
                {
                    len += aStream.length;
                }
                else if (as3hx.Compat.truthy(aStream.length < 65536))
                {
                    len += 126;
                }
                else
                {
                    len += 127;
                }
                stream.writeByte(len);
                
                if (as3hx.Compat.truthy(aStream.length >= 126))
                {
                    bytes = new ByteArray();
                    if (as3hx.Compat.truthy(aStream.length < 65536))
                    {
                        bytes.writeShort(aStream.length);
                    }
                    else
                    {
                        bytes.writeInt(aStream.length);
                    }
                    //reverse?
                    //if (BitConverter.IsLittleEndian) bytes = ReverseBytes(bytes);
                    stream.writeBytes(bytes, 0, bytes.length);
                }
                
                //masking
                if (as3hx.Compat.truthy(fMasking))
                {
                    masks.writeByte(Math.floor(Math.random() * 256));
                    masks.writeByte(Math.floor(Math.random() * 256));
                    masks.writeByte(Math.floor(Math.random() * 256));
                    masks.writeByte(Math.floor(Math.random() * 256));
                    stream.writeBytes(masks, 0, masks.length);
                }
                
                //send data
                aStream.position = 0;
                
                aStream.readBytes(send);
                
                if (as3hx.Compat.truthy(fMasking))
                {
                    for (i in 0...send.length)
                    {
                        send[i] = (send[i] ^ masks[i % 4]);
                    }
                }
                
                stream.writeBytes(send, 0, send.length);
                
                writeSocketBytes(stream);
            }
            catch (e : Error)
            {
                result = false;
            }
        }
        return result;
    }
    
    public function sendHybi17Data(aWriteFinal                              : Dynamic, aRes1                              : Dynamic, aRes2                              : Dynamic, aRes3                              : Dynamic, aWriteCode                              : Dynamic, aStream                              : Dynamic) : Bool
    {
        return sendHybi10Data(aWriteFinal, aRes1, aRes2, aRes3, aWriteCode, aStream);
    }
}

