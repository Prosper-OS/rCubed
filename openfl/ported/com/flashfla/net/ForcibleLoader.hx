/*
 * ForcibleLoader
 *
 * Licensed under the MIT License
 *
 * Copyright (c) 2007-2009 BeInteractive! (www.be-interactive.org) and
 *                         Spark project  (www.libspark.org)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
package com.flashfla.net;

import openfl.display.Loader;
import openfl.errors.EOFError;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

/**
 * Loads a SWF file as version 9 format forcibly even if version is under 9.
 *
 * Usage:
 * <pre>
 * var loader:Loader = Loader(addChild(new Loader()));
 * var fLoader:ForcibleLoader = new ForcibleLoader(loader);
 * fLoader.load(new URLRequest('swf7.swf'));
 * </pre>
 *
 * @author yossy:beinteractive
 * @see http://www.be-interactive.org/?itemid=250
 * @see http://fladdict.net/blog/2007/05/avm2avm1swf.html
 */
class ForcibleLoader
{
    public var loader(get, set) : Loader;

    
    public function new(loader : Loader)
    {
        this.loader = loader;
        
        _stream = new URLStream();
        _stream.addEventListener(Event.COMPLETE, completeHandler);
        _stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        _stream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
    }
    
    private var _loader : Loader;
    private var _stream : URLStream;
    
    public var inputBytes : ByteArray;
    
    private function get_loader() : Loader
    {
        return _loader;
    }
    
    private function set_loader(value : Loader) : Loader
    {
        _loader = value;
        return value;
    }
    
    public function load(request : URLRequest) : Void
    {
        _stream.load(request);
    }
    
    private function completeHandler(event : Event) : Void
    {
        inputBytes = new ByteArray();
        _stream.readBytes(inputBytes);
        _stream.close();
        inputBytes.endian = Endian.LITTLE_ENDIAN;
        
        if (inputBytes.length <= 3)
        {
            return;
        }
        
        if (isCompressed(inputBytes))
        {
            uncompress(inputBytes);
        }
        
        var version : Int = as3hx.Compat.parseInt(inputBytes[3]);
        
        if (version < 9)
        {
            updateVersion(inputBytes, 9);
        }
        if (version > 7)
        {
            flagSWF9Bit(inputBytes);
        }
        else
        {
            insertFileAttributesTag(inputBytes);
        }
        loader.loadBytes(inputBytes, AirContext.getLoaderContext());
    }
    
    private function isCompressed(bytes : ByteArray) : Bool
    {
        return bytes[0] == 0x43;
    }
    
    private function uncompress(bytes : ByteArray) : Void
    {
        var cBytes : ByteArray = new ByteArray();
        cBytes.writeBytes(bytes, 8);
        bytes.length = 8;
        bytes.position = 8;
        cBytes.uncompress();
        bytes.writeBytes(cBytes);
        bytes[0] = 0x46;
        cBytes.length = 0;
    }
    
    private function getBodyPosition(bytes : ByteArray) : Int
    {
        var result : Int = 0;
        
        result += 3;  // FWS/CWS  
        result += 1;  // version(byte)  
        result += 4;  // length(32bit-uint)  
        
        var rectNBits : Int = bytes[result] >>> 3;
        result += as3hx.Compat.parseInt((5 + rectNBits * 4) / 8);  // stage(rect)  
        
        result += 2;
        
        result += 1;  // frameRate(byte)  
        result += 2;  // totalFrames(16bit-uint)  
        
        return result;
    }
    
    private function findFileAttributesPosition(offset : Int, bytes : ByteArray) : Int
    {
        bytes.position = offset;
        
        try
        {
            while (true)
            {
                var byte : Int = bytes.readShort();
                var tag : Int = byte >>> 6;
                if (tag == 69)
                {
                    return as3hx.Compat.parseInt(bytes.position - 2);
                }
                var length : Int = byte & 0x3f;
                if (length == 0x3f)
                {
                    length = bytes.readInt();
                }
                bytes.position += length;
            }
        }
        catch (e : EOFError)
        {
        }
        
        return -1;
    }
    
    private function flagSWF9Bit(bytes : ByteArray) : Void
    {
        var pos : Int = findFileAttributesPosition(getBodyPosition(bytes), bytes);
        if (pos != -1)
        {
            bytes[pos + 2] = bytes[pos + 2] | 0x08;
        }
        else
        {
            insertFileAttributesTag(bytes);
        }
    }
    
    private function insertFileAttributesTag(bytes : ByteArray) : Void
    {
        var pos : Int = getBodyPosition(bytes);
        var afterBytes : ByteArray = new ByteArray();
        afterBytes.writeBytes(bytes, pos);
        bytes.length = pos;
        bytes.position = pos;
        bytes.writeByte(0x44);
        bytes.writeByte(0x11);
        bytes.writeByte(0x08);
        bytes.writeByte(0x00);
        bytes.writeByte(0x00);
        bytes.writeByte(0x00);
        bytes.writeBytes(afterBytes);
        afterBytes.length = 0;
    }
    
    private function updateVersion(bytes : ByteArray, version : Int) : Void
    {
        bytes[3] = version;
    }
    
    private function ioErrorHandler(event : IOErrorEvent) : Void
    {
        loader.dispatchEvent(event.clone());
    }
    
    private function securityErrorHandler(event : SecurityErrorEvent) : Void
    {
        loader.dispatchEvent(event.clone());
    }
    
    private function progressHandler(event : ProgressEvent) : Void
    {
        loader.dispatchEvent(event.clone());
    }
}

