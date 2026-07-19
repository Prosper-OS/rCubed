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
 * var loader                           : Dynamic= Loader(addChild(new Loader()));
 * var fLoader                           : Dynamic= new ForcibleLoader(loader);
 * fLoader.load(new URLRequest('swf7.swf'));
 * </pre>
 *
 * @author yossy:beinteractive
 * @see http://www.be-interactive.org/?itemid=250
 * @see http://fladdict.net/blog/2007/05/avm2avm1swf.html
 */
class ForcibleLoader
{
    public var loader(get, set)                            : Dynamic;

    
    public function new(loader                            : Dynamic)
    {
        this.loader = loader;
        
        _stream = new URLStream();
        _stream.addEventListener(Event.COMPLETE, completeHandler);
        _stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        _stream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
    }
    
    private var _loader                            : Dynamic;
    private var _stream                            : Dynamic;
    
    public var inputBytes                            : Dynamic;
    
    private function get_loader() : Loader
    {
        return _loader;
    }
    
    private function set_loader(value                            : Dynamic) : Loader
    {
        _loader = value;
        return value;
    }
    
    public function load(request                            : Dynamic) : Void
    {
        _stream.load(request);
    }
    
    private function completeHandler(event                            : Dynamic) : Void
    {
        inputBytes = new ByteArray();
        _stream.readBytes(inputBytes);
        _stream.close();
        inputBytes.endian = Endian.LITTLE_ENDIAN;
        
        if (as3hx.Compat.truthy(inputBytes.length <= 3))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(isCompressed(inputBytes)))
        {
            uncompress(inputBytes);
        }
        
        var version                            : Dynamic= as3hx.Compat.parseInt(inputBytes[3]);
        
        if (as3hx.Compat.truthy(version < 9))
        {
            updateVersion(inputBytes, 9);
        }
        if (as3hx.Compat.truthy(version > 7))
        {
            flagSWF9Bit(inputBytes);
        }
        else
        {
            insertFileAttributesTag(inputBytes);
        }
        loader.loadBytes(inputBytes, AirContext.getLoaderContext());
    }
    
    private function isCompressed(bytes                            : Dynamic) : Bool
    {
        return bytes[0] == 0x43;
    }
    
    private function uncompress(bytes                            : Dynamic) : Void
    {
        var cBytes                            : Dynamic= new ByteArray();
        cBytes.writeBytes(bytes, 8);
        bytes.length = 8;
        bytes.position = 8;
        cBytes.uncompress();
        bytes.writeBytes(cBytes);
        bytes[0] = 0x46;
        cBytes.length = 0;
    }
    
    private function getBodyPosition(bytes                            : Dynamic) : Int
    {
        var result                            : Dynamic= 0;
        
        result += 3;  // FWS/CWS  
        result += 1;  // version(byte)  
        result += 4;  // length(32bit-uint)  
        
        var rectNBits                            : Dynamic= bytes[result] >>> 3;
        result += as3hx.Compat.parseInt((5 + rectNBits * 4) / 8);  // stage(rect)  
        
        result += 2;
        
        result += 1;  // frameRate(byte)  
        result += 2;  // totalFrames(16bit-uint)  
        
        return result;
    }
    
    private function findFileAttributesPosition(offset                            : Dynamic, bytes                            : Dynamic) : Int
    {
        bytes.position = offset;
        
        try
        {
            while (as3hx.Compat.truthy(true))
            {
                var byte                            : Dynamic= bytes.readShort();
                var tag                            : Dynamic= byte >>> 6;
                if (as3hx.Compat.truthy(tag == 69))
                {
                    return as3hx.Compat.parseInt(bytes.position - 2);
                }
                var length                            : Dynamic= byte & 0x3f;
                if (as3hx.Compat.truthy(length == 0x3f))
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
    
    private function flagSWF9Bit(bytes                            : Dynamic) : Void
    {
        var pos                            : Dynamic= findFileAttributesPosition(getBodyPosition(bytes), bytes);
        if (as3hx.Compat.truthy(pos != -1))
        {
            bytes[pos + 2] = bytes[pos + 2] | 0x08;
        }
        else
        {
            insertFileAttributesTag(bytes);
        }
    }
    
    private function insertFileAttributesTag(bytes                            : Dynamic) : Void
    {
        var pos                            : Dynamic= getBodyPosition(bytes);
        var afterBytes                            : Dynamic= new ByteArray();
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
    
    private function updateVersion(bytes                            : Dynamic, version                            : Dynamic) : Void
    {
        bytes[3] = version;
    }
    
    private function ioErrorHandler(event                            : Dynamic) : Void
    {
        loader.dispatchEvent(event.clone());
    }
    
    private function securityErrorHandler(event                            : Dynamic) : Void
    {
        loader.dispatchEvent(event.clone());
    }
    
    private function progressHandler(event                            : Dynamic) : Void
    {
        loader.dispatchEvent(event.clone());
    }
}

