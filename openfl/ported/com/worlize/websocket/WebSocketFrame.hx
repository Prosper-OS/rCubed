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
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;

class WebSocketFrame
{
    public var length(get, never)                          : Dynamic;

    public var fin                          : Dynamic;
    public var rsv1                          : Dynamic;
    public var rsv2                          : Dynamic;
    public var rsv3                          : Dynamic;
    public var opcode                          : Dynamic;
    public var mask                          : Dynamic;
    public var useNullMask                          : Dynamic;
    private var _length                          : Dynamic;
    public var binaryPayload                          : Dynamic;
    public var closeStatus                          : Dynamic;
    
    public var protocolError                          : Dynamic= false;
    public var frameTooLarge                          : Dynamic= false;
    public var dropReason                          : Dynamic;
    
    private static inline var NEW_FRAME                          : Dynamic= 0;
    private static inline var WAITING_FOR_16_BIT_LENGTH                          : Dynamic= 1;
    private static inline var WAITING_FOR_64_BIT_LENGTH                          : Dynamic= 2;
    private static inline var WAITING_FOR_PAYLOAD                          : Dynamic= 3;
    private static inline var COMPLETE                          : Dynamic= 4;
    private var parseState                          : Dynamic= 0;  // Initialize as NEW_FRAME  
    
    private static var _tempMaskBytes                          : Dynamic= new Array<Int>();
    
    private function get_length() : Int
    {
        return _length;
    }
    
    // Returns true if frame is complete, false if waiting for more data
    public function addData(input                          : Dynamic, fragmentationType                          : Dynamic, config                          : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(input.bytesAvailable >= 2)) {
if (as3hx.Compat.truthy(parseState == NEW_FRAME))
            {
                var firstByte                          : Dynamic= input.readByte();
                var secondByte                          : Dynamic= input.readByte();
                
                fin = cast(firstByte & 0x80, Bool);
                rsv1 = cast(firstByte & 0x40, Bool);
                rsv2 = cast(firstByte & 0x20, Bool);
                rsv3 = cast(firstByte & 0x10, Bool);
                mask = cast(secondByte & 0x80, Bool);
                opcode = firstByte & 0x0F;
                _length = secondByte & 0x7F;
                
                if (as3hx.Compat.truthy(mask))
                {
                    protocolError = true;
                    dropReason = "Received an illegal masked frame from the server.";
                    return true;
                }
                
                if (as3hx.Compat.truthy(opcode > 0x07))
                {
                    if (as3hx.Compat.truthy(_length > 125))
                    {
                        protocolError = true;
                        dropReason = "Illegal control frame larger than 125 bytes.";
                        return true;
                    }
                    if (as3hx.Compat.truthy(!fin))
                    {
                        protocolError = true;
                        dropReason = "Received illegal fragmented control message.";
                        return true;
                    }
                }
                
                if (as3hx.Compat.truthy(_length == 126))
                {
                    parseState = WAITING_FOR_16_BIT_LENGTH;
                }
                else if (as3hx.Compat.truthy(_length == 127))
                {
                    parseState = WAITING_FOR_64_BIT_LENGTH;
                }
                else
                {
                    parseState = WAITING_FOR_PAYLOAD;
                }
            }
            if (as3hx.Compat.truthy(parseState == WAITING_FOR_16_BIT_LENGTH))
            {
                if (as3hx.Compat.truthy(input.bytesAvailable >= 2))
                {
                    _length = input.readUnsignedShort();
                    parseState = WAITING_FOR_PAYLOAD;
                }
            }
            else if (as3hx.Compat.truthy(parseState == WAITING_FOR_64_BIT_LENGTH))
            {
                if (as3hx.Compat.truthy(input.bytesAvailable >= 8)) {
// So we'll just throw away the most significant
                    // 32 bits and hope for the best.
                    var firstHalf                          : Dynamic= input.readUnsignedInt();
                    if (as3hx.Compat.truthy(firstHalf > 0))
                    {
                        frameTooLarge = true;
                        dropReason = "Unsupported 64-bit length frame received.";
                        return true;
                    }
                    _length = input.readUnsignedInt();
                    parseState = WAITING_FOR_PAYLOAD;
                }
            }
            if (as3hx.Compat.truthy(parseState == WAITING_FOR_PAYLOAD))
            {
                if (as3hx.Compat.truthy(_length > config.maxReceivedFrameSize))
                {
                    frameTooLarge = true;
                    dropReason = "Received frame size of " + _length + "exceeds maximum accepted frame size of " + config.maxReceivedFrameSize;
                    return true;
                }
                else
                {
                    if (as3hx.Compat.truthy(_length == 0))
                    {
                        binaryPayload = new ByteArray();
                        parseState = COMPLETE;
                        return true;
                    }
                    if (as3hx.Compat.truthy(input.bytesAvailable >= _length))
                    {
                        binaryPayload = new ByteArray();
                        binaryPayload.endian = Endian.BIG_ENDIAN;
                        input.readBytes(binaryPayload, 0, _length);
                        binaryPayload.position = 0;
                        parseState = COMPLETE;
                        return true;
                    }
                }
            }
        }
        // If more data is needed but not available on the socket yet,
        // return false.  If there is enough data and the frame parsing
        // has been completed, return true.
        return false;
    }
    
    private function throwAwayPayload(input                          : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(input.bytesAvailable >= _length))
        {
            for (i in 0..._length)
            {
                input.readByte();
            }
            parseState = COMPLETE;
        }
    }
    
    public function send(output                          : Dynamic) : Void
    {
        var maskKey                          : Dynamic= null;
        if (as3hx.Compat.truthy(this.mask && !this.useNullMask)) {
maskKey = Math.ceil(Math.random() * 0xFFFFFFFF);
            _tempMaskBytes[0] = as3hx.Compat.parseInt(maskKey >> 24) & 0xFF;
            _tempMaskBytes[1] = as3hx.Compat.parseInt(maskKey >> 16) & 0xFF;
            _tempMaskBytes[2] = as3hx.Compat.parseInt(maskKey >> 8) & 0xFF;
            _tempMaskBytes[3] = maskKey & 0xFF;
        }
        
        var data                          : Dynamic= null;
        
        var firstByte                          : Dynamic= 0x00;
        var secondByte                          : Dynamic= 0x00;
        if (as3hx.Compat.truthy(fin))
        {
            firstByte = firstByte | 0x80;
        }
        if (as3hx.Compat.truthy(rsv1))
        {
            firstByte = firstByte | 0x40;
        }
        if (as3hx.Compat.truthy(rsv2))
        {
            firstByte = firstByte | 0x20;
        }
        if (as3hx.Compat.truthy(rsv3))
        {
            firstByte = firstByte | 0x10;
        }
        if (as3hx.Compat.truthy(mask))
        {
            secondByte = secondByte | 0x80;
        }
        
        firstByte = firstByte | as3hx.Compat.parseInt(opcode & 0x0F);
        
        if (as3hx.Compat.truthy(opcode == WebSocketOpcode.CONNECTION_CLOSE))
        {
            data = new ByteArray();
            data.endian = Endian.BIG_ENDIAN;
            data.writeShort(closeStatus);
            if (as3hx.Compat.truthy(binaryPayload != null))
            {
                binaryPayload.position = 0;
                data.writeBytes(binaryPayload);
            }
            data.position = 0;
            _length = data.length;
        }
        else if (as3hx.Compat.truthy(binaryPayload != null))
        {
            data = binaryPayload;
            data.endian = Endian.BIG_ENDIAN;
            data.position = 0;
            _length = data.length;
        }
        else
        {
            data = new ByteArray();
            _length = 0;
        }
        
        if (as3hx.Compat.truthy(opcode >= 0x08))
        {
            if (as3hx.Compat.truthy(_length > 125))
            {
                throw new Error("Illegal control frame longer than 125 bytes");
            }
            if (as3hx.Compat.truthy(!fin))
            {
                throw new Error("Control frames must not be fragmented.");
            }
        }
        
        if (as3hx.Compat.truthy(_length <= 125)) {
secondByte = secondByte | as3hx.Compat.parseInt(_length & 0x7F);
        }
        else if (as3hx.Compat.truthy(_length > 125 && _length <= 0xFFFF)) {
secondByte = secondByte | 126;
        }
        else if (as3hx.Compat.truthy(_length > 0xFFFF)) {
secondByte = secondByte | 127;
        }
        
        // output the frame header
        output.writeByte(firstByte);
        output.writeByte(secondByte);
        
        if (as3hx.Compat.truthy(_length > 125 && _length <= 0xFFFF)) {
output.writeShort(_length);
        }
        else if (as3hx.Compat.truthy(_length > 0xFFFF)) {
output.writeUnsignedInt(0x00000000);
            output.writeUnsignedInt(_length);
        }
        
        if (as3hx.Compat.truthy(this.mask))
        {
            if (as3hx.Compat.truthy(this.useNullMask))
            {
                output.writeUnsignedInt(0);
                output.writeBytes(data, 0, data.length);
            }
            // write the mask key to the output
            else
            {
                
                output.writeUnsignedInt(maskKey);
                // Mask and send the payload
                
                var j                          : Dynamic= 0;
                
                var remaining                          : Dynamic= data.bytesAvailable;
                while (as3hx.Compat.truthy(remaining >= 4))
                {
                    output.writeUnsignedInt(data.readUnsignedInt() ^ maskKey);
                    remaining -= 4;
                }
                while (as3hx.Compat.truthy(remaining > 0))
                {
                    output.writeByte(data.readByte() ^ _tempMaskBytes[j]);
                    j += 1;
                    remaining -= 1;
                }
            }
        }
        // Send the payload unmasked
        else
        {
            
            output.writeBytes(data, 0, data.length);
        }
    }

    public function new()
    {
    }
}

