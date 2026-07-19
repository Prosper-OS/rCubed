/************************************************************************
 *  Copyright 2010-2012 Worlize Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ***********************************************************************/

package com.worlize.websocket;

import openfl.errors.Error;
import by.blooddy.crypto.Base64;
import by.blooddy.crypto.SHA1;
import com.flashfla.utils.StringUtil;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import openfl.net.SecureSocket;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.utils.Timer;

@:meta(Event(name="connectionFail",type="com.worlize.websocket.WebSocketErrorEvent"))

@:meta(Event(name="ioError",type="openfl.events.IOErrorEvent"))

@:meta(Event(name="abnormalClose",type="com.worlize.websocket.WebSocketErrorEvent"))

@:meta(Event(name="message",type="com.worlize.websocket.WebSocketEvent"))

@:meta(Event(name="frame",type="com.worlize.websocket.WebSocketEvent"))

@:meta(Event(name="ping",type="com.worlize.websocket.WebSocketEvent"))

@:meta(Event(name="pong",type="com.worlize.websocket.WebSocketEvent"))

@:meta(Event(name="open",type="com.worlize.websocket.WebSocketEvent"))

@:meta(Event(name="closed",type="com.worlize.websocket.WebSocketEvent"))

class WebSocket extends EventDispatcher
{
    public var readyState(get, never)                          : Dynamic;
    public var bufferedAmount(get, never)                          : Dynamic;
    public var uri(get, never)                          : Dynamic;
    public var protocol(get, never)                          : Dynamic;
    public var extensions(get, never)                          : Dynamic;
    public var host(get, never)                          : Dynamic;
    public var port(get, never)                          : Dynamic;
    public var resource(get, never)                          : Dynamic;
    public var secure(get, never)                          : Dynamic;
    public var connected(get, never)                          : Dynamic;
    public var useNullMask(get, set)                          : Dynamic;

    private static inline var MODE_UTF8                          : Dynamic= 0;
    private static inline var MODE_BINARY                          : Dynamic= 0;
    
    private static var MAX_HANDSHAKE_BYTES                          : Dynamic= 10 * 1024;  // 10KiB  
    private static var SEND_FRAME_BUFFER                          : Dynamic= new ByteArray();
    
    private var _bufferedAmount                          : Dynamic= 0;
    
    private var _readyState                          : Dynamic;
    private var _uri                          : Dynamic;
    private var _protocols                          : Dynamic;
    private var _serverProtocol                          : Dynamic;
    private var _host                          : Dynamic;
    private var _port                          : Dynamic;
    private var _resource                          : Dynamic;
    private var _secure                          : Dynamic;
    private var _origin                          : Dynamic;
    private var _useNullMask                          : Dynamic= false;
    
    private var socket                          : Dynamic;
    private var timeout                          : Dynamic;
    
    private var fatalError                          : Dynamic= false;
    
    private var nonce                          : Dynamic;
    private var base64nonce                          : Dynamic;
    private var serverHandshakeResponse                          : Dynamic;
    private var serverExtensions                          : Dynamic;
    private var serverSupportsDeflate                          : Dynamic;
    private var currentFrame                          : Dynamic;
    private var frameQueue                          : Dynamic;
    private var fragmentationOpcode                          : Dynamic= 0;
    private var fragmentationSize                          : Dynamic= 0;
    
    private var waitingForServerClose                          : Dynamic= false;
    private var closeTimeout                          : Dynamic= 5000;
    private var closeTimer                          : Dynamic;
    
    private var handshakeBytesReceived                          : Dynamic;
    private var handshakeTimer                          : Dynamic;
    private var handshakeTimeout                          : Dynamic= 10000;
    
    public var config                          : Dynamic= new WebSocketConfig();
    
    public var debug                          : Dynamic= false;
    
    public function new(uri                          : Dynamic, origin                          : Dynamic, protocols                          : Dynamic= null, timeout                          : Dynamic= 10000)
    {
        super(null);
        _uri = uri;
        
        if (as3hx.Compat.truthy(Std.is(protocols, String)))
        {
            _protocols = [protocols];
        }
        else
        {
            _protocols = protocols;
        }
        if (as3hx.Compat.truthy(_protocols != null))
        {
            for (i in 0..._protocols.length)
            {
                _protocols[i] = StringTools.trim(_protocols[i]);
            }
        }
        _origin = origin;
        this.timeout = timeout;
        this.handshakeTimeout = timeout;
        init();
    }
    
    private function init() : Void
    {
        parseUrl();
        
        validateProtocol();
        
        frameQueue = new Array<WebSocketFrame>();
        fragmentationOpcode = 0x00;
        fragmentationSize = 0;
        
        currentFrame = new WebSocketFrame();
        
        fatalError = false;
        
        closeTimer = new Timer(closeTimeout, 1);
        closeTimer.addEventListener(TimerEvent.TIMER, handleCloseTimer);
        
        handshakeTimer = new Timer(handshakeTimeout, 1);
        handshakeTimer.addEventListener(TimerEvent.TIMER, handleHandshakeTimer);
        
        socket = (secure) ? new SecureSocket() : new Socket();
        socket.endian = Endian.BIG_ENDIAN;
        socket.timeout = timeout;
        
        socket.addEventListener(Event.CONNECT, handleSocketConnect);
        socket.addEventListener(IOErrorEvent.IO_ERROR, handleSocketIOError);
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSocketSecurityError);
        socket.addEventListener(Event.CLOSE, handleSocketClose);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
        
        _readyState = WebSocketState.INIT;
    }
    
    private function validateProtocol() : Void
    {
        if (as3hx.Compat.truthy(_protocols != null))
        {
            var separators                          : Dynamic= ["(", ")", "<", ">", "@", 
            ",", ";", ":", "\\", "\"", 
            "/", "[", "]", "?", "=", 
            "{", "}", " ", String.fromCharCode(9)
        ];
            
            for (p in 0..._protocols.length)
            {
                var protocol                          : Dynamic= _protocols[p];
                for (i in 0...protocol.length)
                {
                    var charCode                          : Dynamic= protocol.charCodeAt(i);
                    var char                          : Dynamic= protocol.charAt(i);
                    if (as3hx.Compat.truthy(charCode < 0x21 || charCode > 0x7E || Lambda.indexOf(separators, char) != -1))
                    {
                        throw new WebSocketError("Illegal character '" + String.fromCharCode(char) + "' in subprotocol.");
                    }
                }
            }
        }
    }
    
    public function connect() : Void
    {
        if (as3hx.Compat.truthy(_readyState == WebSocketState.OPEN && !socket.connected))
        {
            _readyState = WebSocketState.CLOSED;
        }
        
        if (as3hx.Compat.truthy(_readyState == WebSocketState.INIT || _readyState == WebSocketState.CLOSED))
        {
            _readyState = WebSocketState.CONNECTING;
            generateNonce();
            handshakeBytesReceived = 0;
            
            socket.connect(_host, _port);
            if (as3hx.Compat.truthy(debug))
            {
                Logger.info(this, "Connecting to " + _host + " on port " + _port);
            }
        }
    }
    
    public function addBinaryChainBuildingCertificate(certificate                          : Dynamic, trusted                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!secure))
        {
            throw new Error("addBinaryChainBuildingCertificate only available for secure websockets");
        }
        
        (try cast(socket, SecureSocket) catch(e:Dynamic) null).addBinaryChainBuildingCertificate(certificate, trusted);
    }
    
    private function parseUrl() : Void
    {
        _host = _uri.host;
        var scheme                          : Dynamic= _uri.scheme.toLowerCase();
        if (as3hx.Compat.truthy(scheme == "wss"))
        {
            _secure = true;
            _port = 443;
        }
        else if (as3hx.Compat.truthy(scheme == "ws"))
        {
            _secure = false;
            _port = 80;
        }
        else
        {
            throw new Error("Unsupported scheme: " + scheme);
        }
        
        if (as3hx.Compat.truthy(!Math.isNaN(_uri.port) && _uri.port != 0))
        {
            _port = _uri.port;
        }
        
        _resource = _uri.path;
    }
    
    private function generateNonce() : Void
    {
        nonce = new ByteArray();
        for (i in 0...16)
        {
            nonce.writeByte(Math.round(Math.random() * 0xFF));
        }
        nonce.position = 0;
        base64nonce = Base64.encode(nonce);
    }
    
    private function get_readyState() : Int
    {
        return _readyState;
    }
    
    private function get_bufferedAmount() : Int
    {
        return _bufferedAmount;
    }
    
    private function get_uri() : String
    {
        var uri                          : Dynamic= null;
        uri = (_secure) ? "wss://" : "ws://";
        uri += _host;
        if (as3hx.Compat.truthy((_secure && _port != 443) || (!_secure && _port != 80)))
        {
            uri += (":" + Std.string(_port));
        }
        uri += _resource;
        return uri;
    }
    
    private function get_protocol() : String
    {
        return _serverProtocol;
    }
    
    private function get_extensions() : Array<Dynamic>
    {
        return [];
    }
    
    private function get_host() : String
    {
        return _host;
    }
    
    private function get_port() : Int
    {
        return _port;
    }
    
    private function get_resource() : String
    {
        return _resource;
    }
    
    private function get_secure() : Bool
    {
        return _secure;
    }
    
    private function get_connected() : Bool
    {
        return readyState == WebSocketState.OPEN;
    }
    
    // Pseudo masking is useful for speeding up wbesocket usage in a controlled environment,
    // such as a self-contained AIR app for mobile where the client can be resonably sure of
    // not intending to screw up proxies by confusing them with HTTP commands in the frame body
    // Probably not a good idea to enable if being used on the web in general cases.
    private function set_useNullMask(val                          : Dynamic) : Bool
    {
        _useNullMask = val;
        return val;
    }
    
    private function get_useNullMask() : Bool
    {
        return _useNullMask;
    }
    
    private function verifyConnectionForSend() : Void
    {
        if (as3hx.Compat.truthy(_readyState == WebSocketState.CONNECTING))
        {
            throw new WebSocketError("Invalid State: Cannot send data before connected.");
        }
    }
    
    public function sendUTF(data                          : Dynamic) : Void
    {
        verifyConnectionForSend();
        var frame                          : Dynamic= new WebSocketFrame();
        frame.opcode = WebSocketOpcode.TEXT_FRAME;
        frame.binaryPayload = new ByteArray();
        frame.binaryPayload.writeMultiByte(data, "utf-8");
        fragmentAndSend(frame);
    }
    
    public function sendBytes(data                          : Dynamic) : Void
    {
        verifyConnectionForSend();
        var frame                          : Dynamic= new WebSocketFrame();
        frame.opcode = WebSocketOpcode.BINARY_FRAME;
        frame.binaryPayload = data;
        fragmentAndSend(frame);
    }
    
    public function ping(payload                          : Dynamic= null) : Void
    {
        verifyConnectionForSend();
        var frame                          : Dynamic= new WebSocketFrame();
        frame.fin = true;
        frame.opcode = WebSocketOpcode.PING;
        if (as3hx.Compat.truthy(payload != null))
        {
            frame.binaryPayload = payload;
        }
        sendFrame(frame);
    }
    
    private function pong(binaryPayload                          : Dynamic= null) : Void
    {
        verifyConnectionForSend();
        var frame                          : Dynamic= new WebSocketFrame();
        frame.fin = true;
        frame.opcode = WebSocketOpcode.PONG;
        frame.binaryPayload = binaryPayload;
        sendFrame(frame);
    }
    
    private function fragmentAndSend(frame                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(frame.opcode > 0x07))
        {
            throw new WebSocketError("You cannot fragment control frames.");
        }
        
        var threshold                          : Dynamic= config.fragmentationThreshold;
        
        if (as3hx.Compat.truthy(config.fragmentOutgoingMessages && frame.binaryPayload && frame.binaryPayload.length > threshold))
        {
            frame.binaryPayload.position = 0;
            var length                          : Dynamic= frame.binaryPayload.length;
            var numFragments                          : Dynamic= Math.ceil(length / threshold);
            for (i in 1...numFragments + 1)
            {
                var currentFrame                          : Dynamic= new WebSocketFrame();
                
                // continuation opcode except for first frame.
                currentFrame.opcode = ((i == 1)) ? frame.opcode : 0x00;
                
                // fin set on last frame only
                currentFrame.fin = (i == numFragments);
                
                // length is likely to be shorter on the last fragment
                var currentLength                          : Dynamic= ((i == numFragments)) ? length - (threshold * (i - 1)) : threshold;
                frame.binaryPayload.position = threshold * (i - 1);
                
                // Slice the right portion of the original payload
                currentFrame.binaryPayload = new ByteArray();
                frame.binaryPayload.readBytes(currentFrame.binaryPayload, 0, currentLength);
                
                sendFrame(currentFrame);
            }
        }
        else
        {
            frame.fin = true;
            sendFrame(frame);
        }
    }
    
    private function sendFrame(frame                          : Dynamic, force                          : Dynamic= false) : Void
    {
        SEND_FRAME_BUFFER.length = 0;
        frame.mask = true;
        frame.useNullMask = _useNullMask;
        frame.send(SEND_FRAME_BUFFER);
        sendData(SEND_FRAME_BUFFER);
    }
    
    private function sendData(data                          : Dynamic, fullFlush                          : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(!connected))
        {
            return;
        }
        data.position = 0;
        socket.writeBytes(data, 0, data.bytesAvailable);
        socket.flush();
        data.clear();
    }
    
    public function close(waitForServer                          : Dynamic= true) : Void
    {
        if (as3hx.Compat.truthy(!socket.connected && _readyState == WebSocketState.CONNECTING))
        {
            _readyState = WebSocketState.CLOSED;
            try
            {
                socket.close();
            }
            catch (e : Error)
            
            /* do nothing */{
                
                
            }
        }
        if (as3hx.Compat.truthy(socket.connected))
        {
            var frame                          : Dynamic= new WebSocketFrame();
            frame.rsv1 = frame.rsv2 = frame.rsv3 = frame.mask = false;
            frame.fin = true;
            frame.opcode = WebSocketOpcode.CONNECTION_CLOSE;
            frame.closeStatus = WebSocketCloseStatus.NORMAL;
            var buffer                          : Dynamic= new ByteArray();
            frame.mask = true;
            frame.send(buffer);
            sendData(buffer, true);
            
            if (as3hx.Compat.truthy(waitForServer))
            {
                waitingForServerClose = true;
                closeTimer.stop();
                closeTimer.reset();
                closeTimer.start();
            }
            dispatchClosedEvent();
        }
    }
    
    private function handleCloseTimer(event                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(waitingForServerClose)) {
// connection, so we'll just close it.
            if (as3hx.Compat.truthy(socket.connected))
            {
                socket.close();
            }
        }
    }
    
    private function handleSocketConnect(event                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, "Socket Connected");
        }
        sendHandshake();
    }
    
    private function handleSocketClose(event                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, "Socket Disconnected");
        }
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Socket Disconnected", 0));
        dispatchClosedEvent();
    }
    
    private function handleSocketData(event                          : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(_readyState == WebSocketState.CONNECTING))
        {
            readServerHandshake();
            return;
        }
        
        // addData returns true if the frame is complete, and false
        // if more data is needed.
        while (as3hx.Compat.truthy(socket.connected && currentFrame.addData(socket, fragmentationOpcode, config) && !fatalError))
        {
            if (as3hx.Compat.truthy(currentFrame.protocolError))
            {
                drop(WebSocketCloseStatus.PROTOCOL_ERROR, currentFrame.dropReason);
                return;
            }
            else if (as3hx.Compat.truthy(currentFrame.frameTooLarge))
            {
                drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, currentFrame.dropReason);
                return;
            }
            if (as3hx.Compat.truthy(!config.assembleFragments))
            {
                var frameEvent                          : Dynamic= new WebSocketEvent(WebSocketEvent.FRAME);
                frameEvent.frame = currentFrame;
                dispatchEvent(frameEvent);
            }
            processFrame(currentFrame);
            currentFrame = new WebSocketFrame();
        }
    }
    
    private function inflate(data                          : Dynamic) : Void
    {
        data.position = data.length;
        data.writeUnsignedInt(65535);  // 00 00 ff ff  
        data[0] = data[0] | 1;  // not sure why flash wants this bit set  
        data.inflate();
    }
    
    private function processFrame(frame                          : Dynamic) : Void
    {
        var event                          : Dynamic= null;
        var i                          : Dynamic= null;
        var currentFrame                          : Dynamic= null;
        
        if (as3hx.Compat.truthy(frame.rsv1 && !serverSupportsDeflate))
        {
            drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Received frame with rsv1 set without permessage-deflate negotiated.");
        }
        if (as3hx.Compat.truthy(frame.rsv2 || frame.rsv3))
        {
            drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Received frame with reserved bit set without a negotiated extension.");
            return;
        }
        
        var _sw0_ = (frame.opcode);        

        switch (_sw0_)
        {
            case WebSocketOpcode.BINARY_FRAME:
                if (as3hx.Compat.truthy(config.assembleFragments))
                {
                    if (as3hx.Compat.truthy(frameQueue.length == 0))
                    {
                        if (as3hx.Compat.truthy(frame.fin))
                        {
                            event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                            event.message = new WebSocketMessage();
                            event.message.type = WebSocketMessage.TYPE_BINARY;
                            if (as3hx.Compat.truthy(frame.rsv1))
                            {
                                inflate(frame.binaryPayload);
                            }
                            event.message.binaryData = frame.binaryPayload;
                            dispatchEvent(event);
                        }
                        else if (as3hx.Compat.truthy(frameQueue.length == 0)) {
frameQueue.push(frame);
                            fragmentationOpcode = frame.opcode;
                        }
                    }
                    else
                    {
                        drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Illegal BINARY_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                        return;
                    }
                }
            case WebSocketOpcode.TEXT_FRAME:
                if (as3hx.Compat.truthy(config.assembleFragments))
                {
                    if (as3hx.Compat.truthy(frameQueue.length == 0))
                    {
                        if (as3hx.Compat.truthy(frame.fin))
                        {
                            event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                            event.message = new WebSocketMessage();
                            event.message.type = WebSocketMessage.TYPE_UTF8;
                            if (as3hx.Compat.truthy(frame.rsv1))
                            {
                                inflate(frame.binaryPayload);
                            }
                            event.message.utf8Data = frame.binaryPayload.readMultiByte(frame.binaryPayload.length, "utf-8");
                            dispatchEvent(event);
                        }
                        // beginning of a fragmented message
                        else
                        {
                            
                            frameQueue.push(frame);
                            fragmentationOpcode = frame.opcode;
                        }
                    }
                    else
                    {
                        drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Illegal TEXT_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                        return;
                    }
                }
            case WebSocketOpcode.CONTINUATION:
                if (as3hx.Compat.truthy(config.assembleFragments))
                {
                    if (as3hx.Compat.truthy(fragmentationOpcode == WebSocketOpcode.CONTINUATION && frame.opcode == WebSocketOpcode.CONTINUATION))
                    {
                        drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Unexpected continuation frame.");
                        return;
                    }
                    
                    fragmentationSize += frame.length;
                    
                    if (as3hx.Compat.truthy(fragmentationSize > config.maxMessageSize))
                    {
                        drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, "Maximum message size exceeded.");
                        return;
                    }
                    
                    frameQueue.push(frame);
                    
                    if (as3hx.Compat.truthy(frame.fin)) {
// message now.  We also have to decode the utf-8 data
                        // for text frames after combining all the fragments.
                        event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                        event.message = new WebSocketMessage();
                        var messageOpcode                          : Dynamic= frameQueue[0].opcode;
                        var binaryData                          : Dynamic= new ByteArray();
                        var totalLength                          : Dynamic= 0;
                        for (i in 0...frameQueue.length)
                        {
                            totalLength += frameQueue[i].length;
                        }
                        if (as3hx.Compat.truthy(totalLength > config.maxMessageSize))
                        {
                            drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, "Message size of " + totalLength + " bytes exceeds maximum accepted message size of " + config.maxMessageSize + " bytes.");
                            return;
                        }
                        for (i in 0...frameQueue.length)
                        {
                            currentFrame = frameQueue[i];
                            binaryData.writeBytes(currentFrame.binaryPayload, 0, currentFrame.binaryPayload.length);
                            currentFrame.binaryPayload.clear();
                        }
                        
                        // inflate if rsv1 is set in the first frame
                        if (as3hx.Compat.truthy(frameQueue[0].rsv1))
                        {
                            inflate(binaryData);
                        }
                        
                        binaryData.position = 0;
                        switch (messageOpcode)
                        {
                            case WebSocketOpcode.BINARY_FRAME:
                                event.message.type = WebSocketMessage.TYPE_BINARY;
                                event.message.binaryData = binaryData;
                            case WebSocketOpcode.TEXT_FRAME:
                                event.message.type = WebSocketMessage.TYPE_UTF8;
                                event.message.utf8Data = binaryData.readMultiByte(binaryData.length, "utf-8");
                            default:
                                drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Unexpected first opcode in fragmentation sequence: 0x" + Std.string(messageOpcode));
                                return;
                        }
                        frameQueue = new Array<WebSocketFrame>();
                        fragmentationOpcode = 0x00;
                        fragmentationSize = 0;
                        dispatchEvent(event);
                    }
                }
            case WebSocketOpcode.PING:
                if (as3hx.Compat.truthy(debug))
                {
                    Logger.info(this, "Received Ping");
                }
                var pingEvent                          : Dynamic= new WebSocketEvent(WebSocketEvent.PING, false, true);
                pingEvent.frame = frame;
                if (as3hx.Compat.truthy(dispatchEvent(pingEvent)))
                {
                    pong(frame.binaryPayload);
                }
            case WebSocketOpcode.PONG:
                if (as3hx.Compat.truthy(debug))
                {
                    Logger.info(this, "Received Pong");
                }
                var pongEvent                          : Dynamic= new WebSocketEvent(WebSocketEvent.PONG);
                pongEvent.frame = frame;
                dispatchEvent(pongEvent);
            case WebSocketOpcode.CONNECTION_CLOSE:
                if (as3hx.Compat.truthy(debug))
                {
                    Logger.info(this, "Received close frame");
                }
                if (as3hx.Compat.truthy(waitingForServerClose)) {
if (as3hx.Compat.truthy(debug))
                    {
                        Logger.info(this, "Got close confirmation from server.");
                    }
                    closeTimer.stop();
                    waitingForServerClose = false;
                    socket.close();
                }
                else
                {
                    if (as3hx.Compat.truthy(debug))
                    {
                        Logger.info(this, "Sending close response to server.");
                    }
                    close(false);
                    socket.close();
                }
            default:
                if (as3hx.Compat.truthy(debug))
                {
                    Logger.info(this, "Unrecognized Opcode: 0x" + Std.string(frame.opcode));
                }
                drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Unrecognized Opcode: 0x" + Std.string(frame.opcode));
        }
    }
    
    private function handleSocketIOError(event                          : Dynamic) : Void
    {
        Logger.error(this, "handleSocketIOError: " + Logger.event_error(event));
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "IO Error", event.errorID));
        dispatchClosedEvent();
    }
    
    private function handleSocketSecurityError(event                          : Dynamic) : Void
    {
        Logger.error(this, "handleSocketSecurityError: " + Logger.event_error(event));
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Security Error", event.errorID));
        dispatchClosedEvent();
    }
    
    private function sendHandshake() : Void
    {
        serverHandshakeResponse = "";
        
        var hostValue                          : Dynamic= host;
        if (as3hx.Compat.truthy((_secure && _port != 443) || (!_secure && _port != 80)))
        {
            hostValue += (":" + Std.string(_port));
        }
        
        var text                          : Dynamic= "";
        text += "GET " + resource + " HTTP/1.1\r\n";
        text += "Host: " + hostValue + "\r\n";
        text += "Upgrade: websocket\r\n";
        text += "Connection: Upgrade\r\n";
        text += "Sec-WebSocket-Key: " + base64nonce + "\r\n";
        if (as3hx.Compat.truthy(_origin != null))
        {
            text += "Origin: " + _origin + "\r\n";
        }
        text += "Sec-WebSocket-Version: 13\r\n";
        if (as3hx.Compat.truthy(_protocols != null))
        {
            var protosList                          : Dynamic= _protocols.join(", ");
            text += "Sec-WebSocket-Protocol: " + protosList + "\r\n";
        }
        
        // we offer permessage-deflate option and accept compressed data from the server, although
        // we never send compressed data ourselves. server_no_context_takeover is needed cause
        // there's no way to make flash's ByteArray.inflate re-use a sliding window
        text += "Sec-WebSocket-Extensions: permessage-deflate; server_no_context_takeover\r\n";
        
        // TODO: Handle Extensions
        text += "\r\n";
        
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, text);
        }
        
        socket.writeMultiByte(text, "us-ascii");
        socket.flush();
        
        handshakeTimer.stop();
        handshakeTimer.reset();
        handshakeTimer.start();
    }
    
    private function failHandshake(message                          : Dynamic= "Unable to complete websocket handshake.") : Void
    {
        if (as3hx.Compat.truthy(debug))
        {
            Logger.error(this, message);
        }
        _readyState = WebSocketState.CLOSED;
        if (as3hx.Compat.truthy(socket.connected))
        {
            socket.close();
        }
        
        handshakeTimer.stop();
        handshakeTimer.reset();
        
        var errorEvent                          : Dynamic= new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
        errorEvent.text = message;
        dispatchEvent(errorEvent);
        
        var event                          : Dynamic= new WebSocketEvent(WebSocketEvent.CLOSED);
        dispatchEvent(event);
    }
    
    private function failConnection(message                          : Dynamic) : Void
    {
        _readyState = WebSocketState.CLOSED;
        if (as3hx.Compat.truthy(socket.connected))
        {
            socket.close();
        }
        
        var errorEvent                          : Dynamic= new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
        errorEvent.text = message;
        dispatchEvent(errorEvent);
        
        var event                          : Dynamic= new WebSocketEvent(WebSocketEvent.CLOSED);
        dispatchEvent(event);
    }
    
    private function drop(closeReason                          : Dynamic= WebSocketCloseStatus.PROTOCOL_ERROR, reasonText                          : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(!connected))
        {
            return;
        }
        fatalError = true;
        var logText                          : Dynamic= "WebSocket: Dropping Connection. Code: " + Std.string(closeReason);
        if (as3hx.Compat.truthy(reasonText != null))
        {
            logText += (" - " + reasonText);
        }
        Logger.info(this, logText);
        
        frameQueue = new Array<WebSocketFrame>();
        fragmentationSize = 0;
        if (as3hx.Compat.truthy(closeReason != WebSocketCloseStatus.NORMAL))
        {
            var errorEvent                          : Dynamic= new WebSocketErrorEvent(WebSocketErrorEvent.ABNORMAL_CLOSE);
            errorEvent.text = "Close reason: " + closeReason;
            dispatchEvent(errorEvent);
        }
        sendCloseFrame(closeReason, reasonText, true);
        dispatchClosedEvent();
        socket.close();
    }
    
    private function sendCloseFrame(reasonCode                          : Dynamic= WebSocketCloseStatus.NORMAL, reasonText                          : Dynamic= null, force                          : Dynamic= false) : Void
    {
        var frame                          : Dynamic= new WebSocketFrame();
        frame.fin = true;
        frame.opcode = WebSocketOpcode.CONNECTION_CLOSE;
        frame.closeStatus = reasonCode;
        if (as3hx.Compat.truthy(reasonText != null))
        {
            frame.binaryPayload = new ByteArray();
            frame.binaryPayload.writeUTFBytes(reasonText);
        }
        sendFrame(frame, force);
    }
    
    private function readServerHandshake() : Void
    {
        var upgradeHeader                          : Dynamic= false;
        var connectionHeader                          : Dynamic= false;
        var serverProtocolHeaderMatch                          : Dynamic= false;
        var keyValidated                          : Dynamic= false;
        var headersTerminatorIndex                          : Dynamic= -1;
        
        // Load in HTTP Header lines until we encounter a double-newline.
        while (as3hx.Compat.truthy(headersTerminatorIndex == -1 && readHandshakeLine()))
        {
            if (as3hx.Compat.truthy(handshakeBytesReceived > MAX_HANDSHAKE_BYTES))
            {
                failHandshake("Received more than " + MAX_HANDSHAKE_BYTES + " bytes during handshake.");
                return;
            }
            
            headersTerminatorIndex = serverHandshakeResponse.search(new as3hx.Compat.Regex('\\r?\\n\\r?\\n', ""));
        }
        if (as3hx.Compat.truthy(headersTerminatorIndex == -1))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, "Server Response Headers:\n" + serverHandshakeResponse);
        }
        
        // Slice off the trailing \r\n\r\n from the handshake data
        serverHandshakeResponse = serverHandshakeResponse.substring(0, headersTerminatorIndex);
        
        var lines                          : Dynamic= serverHandshakeResponse.split(new as3hx.Compat.Regex('\\r?\\n', ""));
        
        // Validate status line
        var responseLine                          : Dynamic= lines.shift();
        var responseLineMatch                          : Dynamic= responseLine.match(new as3hx.Compat.Regex('^(HTTP\\/\\d\\.\\d) (\\d{3}) ?(.*)$', "i"));
        if (as3hx.Compat.truthy(responseLineMatch.length == 0))
        {
            failHandshake("Unable to find correctly-formed HTTP status line.");
            return;
        }
        var httpVersion                          : Dynamic= responseLineMatch[1];
        var statusCode                          : Dynamic= as3hx.Compat.parseInt(responseLineMatch[2]);
        var statusDescription                          : Dynamic= responseLineMatch[3];
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, "HTTP Status Received: " + statusCode + " " + statusDescription);
        }
        
        // Verify correct status code received
        if (as3hx.Compat.truthy(statusCode != 101))
        {
            failHandshake("An HTTP response code other than 101 was received.  Actual Response Code: " + statusCode + " " + statusDescription);
            return;
        }
        
        // Interpret HTTP Response Headers
        serverExtensions = [];
        try
        {
            while (as3hx.Compat.truthy(lines.length > 0))
            {
                responseLine = lines.shift();
                var header                          : Dynamic= parseHTTPHeader(responseLine);
                var lcName                          : Dynamic= header.name.toLowerCase();
                var lcValue                          : Dynamic= header.value.toLowerCase();
                if (as3hx.Compat.truthy(lcName == "upgrade" && lcValue == "websocket"))
                {
                    upgradeHeader = true;
                }
                else if (as3hx.Compat.truthy(lcName == "connection" && lcValue == "upgrade"))
                {
                    connectionHeader = true;
                }
                else if (as3hx.Compat.truthy(lcName == "sec-websocket-extensions" && header.value))
                {
                    var extensionsThisLine                          : Dynamic= header.value.split(",");
                    serverExtensions = serverExtensions.concat(extensionsThisLine);
                }
                else if (as3hx.Compat.truthy(lcName == "sec-websocket-accept"))
                {
                    var byteArray                          : Dynamic= new ByteArray();
                    byteArray.writeUTFBytes(base64nonce + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11");
                    var expectedKey                          : Dynamic= Base64.encode(SHA1.digest(byteArray));
                    if (as3hx.Compat.truthy(debug))
                    {
                        Logger.info(this, "Expected Sec-WebSocket-Accept value: " + expectedKey);
                    }
                    if (as3hx.Compat.truthy(header.value == expectedKey))
                    {
                        keyValidated = true;
                    }
                }
                else if (as3hx.Compat.truthy(lcName == "sec-websocket-protocol"))
                {
                    if (as3hx.Compat.truthy(_protocols != null))
                    {
                        for (protocol in as3hx.Compat.iter(_protocols))
                        {
                            if (as3hx.Compat.truthy(protocol == header.value))
                            {
                                _serverProtocol = protocol;
                            }
                        }
                    }
                }
            }
        }
        catch (e : Error)
        {
            failHandshake("There was an error while parsing the following HTTP Header line:\n" + responseLine);
            return;
        }
        
        if (as3hx.Compat.truthy(!upgradeHeader))
        {
            failHandshake("The server response did not include a valid Upgrade: websocket header.");
            return;
        }
        if (as3hx.Compat.truthy(!connectionHeader))
        {
            failHandshake("The server response did not include a valid Connection: upgrade header.");
            return;
        }
        if (as3hx.Compat.truthy(!keyValidated))
        {
            failHandshake("Unable to validate server response for Sec-Websocket-Accept header.");
            return;
        }
        
        if (as3hx.Compat.truthy(_protocols != null && _serverProtocol == null))
        {
            failHandshake("The server can not respond in any of our requested protocols");
            return;
        }
        
        if (as3hx.Compat.truthy(debug))
        {
            Logger.info(this, "Server Extensions: " + serverExtensions.join(" | "));
        }
        
        serverSupportsDeflate = false;
        for (ext in as3hx.Compat.iter(serverExtensions))
        {
            if (as3hx.Compat.truthy(ext.indexOf("permessage-deflate") != -1))
            {
                serverSupportsDeflate = true;
            }
        }
        
        // The connection is validated!!
        handshakeTimer.stop();
        handshakeTimer.reset();
        
        serverHandshakeResponse = null;
        _readyState = WebSocketState.OPEN;
        
        // prepare for first frame
        currentFrame = new WebSocketFrame();
        frameQueue = new Array<WebSocketFrame>();
        
        dispatchEvent(new WebSocketEvent(WebSocketEvent.OPEN));
        
        // Start reading data
        handleSocketData();
        return;
    }
    
    private function handleHandshakeTimer(event                          : Dynamic) : Void
    {
        failHandshake("Timed out waiting for server response.");
    }
    
    private function parseHTTPHeader(line                          : Dynamic) : Dynamic
    {
        var header                          : Dynamic= line.split(new as3hx.Compat.Regex('\\: +', ""));
        return (header.length == 2) ? {
            name : header[0],
            value : header[1]
        } : null;
    }
    
    // Return true if the header is completely read
    private function readHandshakeLine() : Bool
    {
        var char                          : Dynamic= null;
        while (as3hx.Compat.truthy(socket.bytesAvailable))
        {
            char = socket.readMultiByte(1, "us-ascii");
            handshakeBytesReceived++;
            serverHandshakeResponse += char;
            if (as3hx.Compat.truthy(char == "\n"))
            {
                return true;
            }
        }
        return false;
    }
    
    private function dispatchClosedEvent() : Void
    {
        if (as3hx.Compat.truthy(handshakeTimer.running))
        {
            handshakeTimer.stop();
        }
        if (as3hx.Compat.truthy(_readyState != WebSocketState.CLOSED))
        {
            _readyState = WebSocketState.CLOSED;
            var event                          : Dynamic= new WebSocketEvent(WebSocketEvent.CLOSED);
            dispatchEvent(event);
        }
    }
}

