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
    private static inline var PROTOCOL_HYBI_00 : Int = 0;
    private static inline var PROTOCOL_HYBI_10 : Int = 8;
    private static inline var PROTOCOL_HYBI_17 : Int = 13;
    
    private static inline var FRAME_CONTINUATION : Int = 0x00;
    private static inline var FRAME_TEXT : Int = 0x01;
    private static inline var FRAME_BINARY : Int = 0x02;
    private static inline var FRAME_CLOSE : Int = 0x08;
    private static inline var FRAME_PING : Int = 0x09;
    private static inline var FRAME_PONG : Int = 0x0A;
    
    private var protocol : Int;
    
    public function new(socket : Socket, messageSerializer : IMessageSerializer, crossDomainPolicyXML : FastXML = null)
    {
        super(socket, messageSerializer, crossDomainPolicyXML);
    }
    
    override private function socketDataHandler(event : ProgressEvent) : Void
    //trace("WebSocketClientHandler::socketDataHandler");
    {
        
        if (socket.bytesAvailable > 0)
        {
            if (!firstRequestProcessed)
            {
                firstRequestProcessed = true;
                
                //websockets handshake?
                socket.readBytes(socketBytes, 0);
                var message : String = socketBytes.readUTFBytes(socketBytes.bytesAvailable);
                if (message.indexOf("GET ") == 0)
                {
                    var messageLines : Array<Dynamic> = message.split("\n");
                    var fields : Dynamic = { };
                    var requestedURL : String = "";
                    for (i in 0...messageLines.length)
                    {
                        var line : String = messageLines[i];
                        if (i == 0)
                        {
                            var getSplit : Array<Dynamic> = line.split(" ");
                            if (getSplit.length > 1)
                            {
                                requestedURL = getSplit[1];
                            }
                        }
                        else
                        {
                            var index : Int = line.indexOf(":");
                            if (index > -1)
                            {
                                var key : String = line.substr(0, index);
                                Reflect.setField(fields, key, line.substr(index + 1).replace(new as3hx.Compat.Regex('^([\\s|\\t|\\n]+)?(.*)([\\s|\\t|\\n]+)?$', "gm"), "$2"));
                            }
                        }
                    }
                    
                    //check for any fields stating websocket
                    var isWebsocket : Bool = (Reflect.field(fields, "Upgrade") != null && Reflect.field(fields, "Upgrade") == "websocket");
                    if (!isWebsocket)
                    {
                        for (field_name in Reflect.fields(fields))
                        {
                            if (field_name.toLowerCase().indexOf("websocket") >= 0)
                            {
                                isWebsocket = true;
                                break;
                            }
                        }
                    }
                    
                    if (!isWebsocket)
                    {
                        printInvalidConnectionMessage();
                        return;
                    }
                    
                    //check the websocket version
                    if (Reflect.field(fields, "Sec-WebSocket-Version") != null)
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
    
    private function sendHybi00Response(fields : Dynamic, requestedURL : String) : Void
    //draft-ietf-hybi-thewebsocketprotocol-00
    {
        
        //send a response
        var result : Dynamic = Reflect.field(fields, "Sec-WebSocket-Key1").match(new as3hx.Compat.Regex('[0-9]', "gi"));
        var key1Nr : Int = ((Std.is(result, Array))) ? as3hx.Compat.parseInt(result.join("")) : 1;
        result = Reflect.field(fields, "Sec-WebSocket-Key1").match(new as3hx.Compat.Regex(' ', "gi"));
        var key1SpaceCount : Int = ((Std.is(result, Array))) ? result.length : 1;
        var key1Part : Float = key1Nr / key1SpaceCount;
        
        result = Reflect.field(fields, "Sec-WebSocket-Key2").match(new as3hx.Compat.Regex('[0-9]', "gi"));
        var key2Nr : Int = ((Std.is(result, Array))) ? as3hx.Compat.parseInt(result.join("")) : 1;
        result = Reflect.field(fields, "Sec-WebSocket-Key2").match(new as3hx.Compat.Regex(' ', "gi"));
        var key2SpaceCount : Int = ((Std.is(result, Array))) ? result.length : 1;
        var key2Part : Float = key2Nr / key2SpaceCount;
        
        //calculate binary md5 hash
        var bytesToHash : ByteArray = new ByteArray();
        bytesToHash.writeUnsignedInt(key1Part);
        bytesToHash.writeUnsignedInt(key2Part);
        bytesToHash.writeBytes(socketBytes, socketBytes.length - 8);
        
        //hash it
        var hash : String = MD5.hashBytes(bytesToHash);
        
        var response : String = "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "Sec-WebSocket-Origin: " + Reflect.field(fields, "Origin") + "\r\n" + "Sec-WebSocket-Location: ws://" + Reflect.field(fields, "Host") + requestedURL + "\r\n" + "\r\n";
        var responseBytes : ByteArray = new ByteArray();
        responseBytes.writeUTFBytes(response);
        
        var i : Int = 0;
        while (i < hash.length)
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
    
    private function sendHybi10Response(fields : Dynamic, requestedURL : String) : Void
    //var websocketKey:String = "dGhlIHNhbXBsZSBub25jZQ==";//test
    {
        
        var websocketKey : String = Reflect.field(fields, "Sec-WebSocket-Key");
        
        var guid : String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
        var hash : String = websocketKey + guid;
        
        hash = SHA1.hash(hash);
        
        var hashBytes : ByteArray = new ByteArray();
        var i : Int = 0;
        while (i < hash.length)
        {
            hashBytes.writeByte(as3hx.Compat.parseInt(hash.substr(i, 2)));
            i += 2;
        }
        
        hash = Base64.encode(hashBytes);
        
        var response : String = "HTTP/1.1 101 Switching Protocols\r\n" + "Upgrade: websocket\r\n" + "Connection: Upgrade\r\n" + "Sec-WebSocket-Accept: " + hash + "\r\n" + "\r\n";
        
        var responseBytes : ByteArray = new ByteArray();
        responseBytes.writeUTFBytes(response);
        responseBytes.position = 0;
        socket.writeBytes(responseBytes);
        socket.flush();
        socketBytes.clear();
    }
    
    private function sendHybi17Response(fields : Dynamic, requestedURL : String) : Void
    {
        sendHybi10Response(fields, requestedURL);
    }
    
    override private function queueMessagesFromSocketBytes() : Bool
    {
        if (socketBytes.bytesAvailable > 0)
        {
            var input : String;
            switch (protocol)
            {
                case PROTOCOL_HYBI_00:
                    input = decodeHybi00Input();
                case PROTOCOL_HYBI_10:
                    input = decodeHybi10Input();
                case PROTOCOL_HYBI_17:
                    input = decodeHybi17Input();
            }
            
            if (input != null) {
var deserialized : Array<Message> = messageSerializer.deserialize(input);
                for (message in deserialized)
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
        var messageString : String = "";
        while (socketBytes.bytesAvailable > 0)
        {
            var byte : Int = socketBytes.readByte();
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
        var messageString : String = "";
        var bt : Int;
        var len : Int;
        var mask : Bool;
        var masks : Array<Dynamic> = [0, 0, 0, 0];
        
        if (socketBytes.bytesAvailable > 0)
        {
            bt = socketBytes.readUnsignedByte();
            
            var aReadFinal : Bool = (bt & 0x80) == 0x80;
            var aRes1 : Bool = (bt & 0x40) == 0x40;
            var aRes2 : Bool = (bt & 0x20) == 0x20;
            var aRes3 : Bool = (bt & 0x10) == 0x10;
            var aReadCode : Int = as3hx.Compat.parseInt(bt & 0x0f);
            
            //frame_close
            if (aReadCode == FRAME_CLOSE)
            {
                close();
                return null;
            }
            
            //mask & length
            if (socketBytes.bytesAvailable > 0)
            {
                bt = socketBytes.readUnsignedByte();
                mask = (bt & 0x80) == 0x80;
                len = as3hx.Compat.parseInt(bt & 0x7F);
                if (len == 126)
                {
                    if (socketBytes.bytesAvailable > 0)
                    {
                        bt = socketBytes.readUnsignedByte();
                        len = as3hx.Compat.parseInt(bt * 0x100);
                        if (socketBytes.bytesAvailable > 0)
                        {
                            bt = socketBytes.readUnsignedByte();
                            len = as3hx.Compat.parseInt(len + bt);
                        }
                    }
                }
                else if (len == 127)
                {
                    if (socketBytes.bytesAvailable > 0)
                    {
                        bt = socketBytes.readUnsignedByte();
                        len = as3hx.Compat.parseInt(bt * 0x100000000000000);
                        bt = socketBytes.readUnsignedByte();
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x1000000000000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x10000000000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x100000000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x1000000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x10000);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt * 0x100);
                            bt = socketBytes.readUnsignedByte();
                        }
                        if (socketBytes.bytesAvailable > 0)
                        {
                            len = as3hx.Compat.parseInt(len + bt);
                        }
                    }
                }
                
                if (!mask)
                {
                    socket.close();
                    return null;
                }
                
                //read mask
                if (mask)
                {
                    if (socketBytes.bytesAvailable > 0)
                    {
                        masks[0] = socketBytes.readUnsignedByte();
                    }
                    if (socketBytes.bytesAvailable > 0)
                    {
                        masks[1] = socketBytes.readUnsignedByte();
                    }
                    if (socketBytes.bytesAvailable > 0)
                    {
                        masks[2] = socketBytes.readUnsignedByte();
                    }
                    if (socketBytes.bytesAvailable > 0)
                    {
                        masks[3] = socketBytes.readUnsignedByte();
                    }
                }
                
                if (socketBytes.bytesAvailable > 0)
                {
                    var byteArray : ByteArray = new ByteArray();
                    var j : Int = 0;
                    var k : Int = 0;
                    var previousLength : Int = 0;
                    while (len > 0)
                    {
                        socketBytes.readBytes(byteArray, j, Math.min(len, as3hx.Compat.INT_MAX));
                        k = as3hx.Compat.parseInt(byteArray.length - previousLength);
                        j += k;
                        len -= k;
                        previousLength = byteArray.length;
                    }
                    if (mask)
                    {
                        for (i in 0...byteArray.length)
                        {
                            byteArray[i] = (byteArray[i] ^ masks[i % 4]);
                        }
                    }
                    
                    byteArray.position = 0;
                    while (byteArray.bytesAvailable > 0)
                    {
                        var byte : Int = byteArray.readUnsignedByte();
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
    
    override public function writeMessage(messageToWrite : Message) : Void
    {
        var serialized : String = messageSerializer.serialize(messageToWrite);
        var bytes : ByteArray = new ByteArray();
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
    private function sendHybi10Data(aWriteFinal : Bool, aRes1 : Bool, aRes2 : Bool, aRes3 : Bool, aWriteCode : Int, aStream : ByteArray) : Bool
    {
        var result : Bool = !closed;  // && (aWriteCode == FRAME_CLOSE);  
        var bt : Int = 0;
        var sendLen : Int = 0;
        var i : Int;
        var len : Int = 0;
        var stream : ByteArray = new ByteArray();
        var bytes : ByteArray;
        var masks : ByteArray = new ByteArray();
        var send : ByteArray = new ByteArray();
        var fMasking : Bool = false;  //do not mask when we are sending data  
        
        if (result)
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
                if (aStream.length < 126)
                {
                    len += aStream.length;
                }
                else if (aStream.length < 65536)
                {
                    len += 126;
                }
                else
                {
                    len += 127;
                }
                stream.writeByte(len);
                
                if (aStream.length >= 126)
                {
                    bytes = new ByteArray();
                    if (aStream.length < 65536)
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
                if (fMasking)
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
                
                if (fMasking)
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
    
    private function sendHybi17Data(aWriteFinal : Bool, aRes1 : Bool, aRes2 : Bool, aRes3 : Bool, aWriteCode : Int, aStream : ByteArray) : Bool
    {
        return sendHybi10Data(aWriteFinal, aRes1, aRes2, aRes3, aWriteCode, aStream);
    }
}

