/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import openfl.utils.*;

/**
	*  ZIP???????????????
	*  
	 * @private
	*/
class ZipHeader
{
    
    public static var HEADER_LOCAL_FILE                            : Dynamic= 0x04034b50;
    public static var HEADER_CENTRAL_DIR                            : Dynamic= 0x02014b50;
    public static var HEADER_END_CENTRAL_DIR                            : Dynamic= 0x06054b50;
    
    public static var WIN_DIR                            : Dynamic= 16;
    public static var WIN_FILE                            : Dynamic= 32;
    
    public static var UNIX_DIR                            : Dynamic= 0x4000;
    public static var UNIX_FILE                            : Dynamic= 0x8000;
    
    public var _signature                            : Dynamic;
    public var _version                            : Dynamic;
    public var _bitFlag                            : Dynamic;
    public var _compressMethod                            : Dynamic;
    public var _lastModTime                            : Dynamic;
    public var _lastModDate                            : Dynamic;
    public var _crc32                            : Dynamic;
    public var _compressSize                            : Dynamic;
    public var _uncompressSize                            : Dynamic;
    public var _filenameLength                            : Dynamic;
    public var _extraFieldLength                            : Dynamic;
    public var _filename                            : Dynamic;
    public var _extraField                            : Dynamic;
    
    //  ???? CENTRAL DIRECTORY
    public var _versionBy                            : Dynamic;
    public var _commentLength                            : Dynamic;
    public var _diskNumber                            : Dynamic= 0;
    public var _internalFileAttrs                            : Dynamic= 0;
    public var _externalFileAttrs                            : Dynamic= 0;
    public var _offsetLocalHeader                            : Dynamic;
    public var _comment                            : Dynamic;
    
    public function new(sig                            : Dynamic= 0x04034b50)
    {
        _signature = sig;
    }
    
    public function read(stream                            : Dynamic, bytes                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_signature == HEADER_LOCAL_FILE))
        {
            readLocalHeader(stream, bytes);
        }
        else if (as3hx.Compat.truthy(_signature == HEADER_CENTRAL_DIR))
        {
            readCentralHeader(stream, bytes);
        }
    }
    
    public function readAuto(stream                            : Dynamic) : Void
    {
        var bytes                            : Dynamic= new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;
        _signature = stream.readInt();
        this.read(stream, bytes);
    }
    
    public function getCompressMethod() : Int
    {
        return _compressMethod;
    }
    
    /**
		*  ???????
		*
		*/
    public function getUncompressSize() : Int
    {
        return _uncompressSize;
    }
    /**
		*  ??????????
		*
		*/
    public function getCompressSize() : Int
    {
        return _compressSize;
    }
    /**
		*  ???????(?????)
		*
		*/
    public function isDirectory() : Bool
    {
        if (as3hx.Compat.truthy(_uncompressSize == 0))
        {
            if (as3hx.Compat.truthy(_externalFileAttrs == 0))
            {
                return false;
            }
            else if (as3hx.Compat.truthy((_externalFileAttrs & 16) != 0))
            {
                return true;
            }
            else
            {
                var num                            : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(_externalFileAttrs >> 16) & 0xFFFF);
                if (as3hx.Compat.truthy((num & ZipHeader.UNIX_DIR) != 0))
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    public function getCompressRate() : Float
    {
        if (as3hx.Compat.truthy(_uncompressSize == 0))
        {
            return 0;
        }
        var num                            : Dynamic= _compressSize / _uncompressSize;
        return 1 - num;
    }
    
    public function getDate() : Date
    {
        var sec                            : Dynamic= _lastModTime & 0x001f;
        var min                            : Dynamic= as3hx.Compat.parseInt(_lastModTime & 0x07e0) >> 5;
        var hour                            : Dynamic= as3hx.Compat.parseInt(_lastModTime & 0xf800) >> 11;
        var day                            : Dynamic= as3hx.Compat.parseInt(_lastModDate & 0x001f);
        var month                            : Dynamic= as3hx.Compat.parseInt(_lastModDate & 0x01e0) >> 5;
        var year                            : Dynamic= as3hx.Compat.parseInt(((_lastModDate & 0xfe00) >> 9) + 1980);
        var date                           : Dynamic= new Date(as3hx.Compat.parseInt(year), as3hx.Compat.parseInt(month - 1), as3hx.Compat.parseInt(day), as3hx.Compat.parseInt(hour), as3hx.Compat.parseInt(min), as3hx.Compat.parseInt(sec));
        return date;
    }
    /**
		*  LOCAL FILE HEADER ?????????.
		*
		*/
    public function getLocalHeaderOffset() : Int
    {
        return _offsetLocalHeader;
    }
    
    public function getFilename(charset                            : Dynamic= null) : String
    {
        if (as3hx.Compat.truthy(_filenameLength < 1))
        {
            return "";
        }
        if (as3hx.Compat.truthy(charset == null)) {
if (as3hx.Compat.truthy((_versionBy >> 8) == 3))
            {
                charset = "utf-8";
            }
            else
            {
                charset = "shift_jis";
            }
        }
        
        var _char                            : Dynamic= charset.toLowerCase();
        if (as3hx.Compat.truthy(_char == "utf-8"))
        {
            return getFilenameUTF8();
        }
        else
        {
            _filename.position = 0;
            return _filename.readMultiByte(_filename.bytesAvailable, charset);
        }
    }
    
    /**
		*  LOCAL HEADER?????????.
		* 
		*
		*/
    public function getLocalHeaderSize() : Int
    {
        return as3hx.Compat.parseInt(30 + _filenameLength + _extraFieldLength);
    }
    
    public function readLocalHeader(stream                            : Dynamic, bytes                            : Dynamic) : Void
    {
        stream.readBytes(bytes, 0, 26);
        // ???????
        bytes.position = 0;
        _version = bytes.readUnsignedShort();
        
        // ?????
        bytes.position = 2;
        _bitFlag = bytes.readUnsignedShort();
        
        // ????
        bytes.position = 4;
        _compressMethod = bytes.readUnsignedShort();
        
        //  ??????
        bytes.position = 6;
        _lastModTime = bytes.readUnsignedShort();
        
        // ??????
        bytes.position = 8;
        _lastModDate = bytes.readUnsignedShort();
        
        // CRC32
        bytes.position = 10;
        _crc32 = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 14;
        _compressSize = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 18;
        _uncompressSize = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 22;
        _filenameLength = bytes.readShort();
        
        // ????????
        bytes.position = 24;
        _extraFieldLength = bytes.readShort();
        
        if (as3hx.Compat.truthy(_signature == HEADER_LOCAL_FILE)) {
stream.readBytes(bytes, 26, _filenameLength + _extraFieldLength);
            
            // ?????
            bytes.position = 26;
            _filename = new ByteArray();
            bytes.readBytes(_filename, 0, _filenameLength);
            
            // ????
            if (as3hx.Compat.truthy(_extraFieldLength > 0))
            {
                _extraField = new ByteArray();
                bytes.readBytes(_extraField, 0, _extraFieldLength);
            }
        }
    }
    
    public function writeLocalHeader(stream                            : Dynamic) : Void
    {
        this.writeHeader(stream, false);
    }
    
    public function writeCentralHeader(stream                            : Dynamic) : Void
    {
        this.writeHeader(stream, true);
    }
    
    /**
		*  ????????
		*
		*/
    public function writeHeader(stream                            : Dynamic, isCentral                            : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(isCentral))
        {
            _signature = HEADER_CENTRAL_DIR;
            stream.writeUnsignedInt(HEADER_CENTRAL_DIR);
            stream.writeShort(_versionBy);
        }
        else
        {
            _signature = HEADER_LOCAL_FILE;
            stream.writeUnsignedInt(HEADER_LOCAL_FILE);
        }
        stream.writeShort(_version);
        stream.writeShort(_bitFlag);
        stream.writeShort(_compressMethod);
        stream.writeShort(_lastModTime);
        stream.writeShort(_lastModDate);
        stream.writeUnsignedInt(_crc32);
        stream.writeUnsignedInt(_compressSize);
        stream.writeUnsignedInt(_uncompressSize);
        stream.writeShort(_filenameLength);
        stream.writeShort(_extraFieldLength);
        
        
        if (as3hx.Compat.truthy(_extraFieldLength > 0))
        {
            _extraField.position = 0;
            stream.writeBytes(_extraField);
        }
        
        if (as3hx.Compat.truthy(isCentral))
        {
            stream.writeShort(_commentLength);
            stream.writeShort(_diskNumber);
            stream.writeShort(_internalFileAttrs);
            stream.writeUnsignedInt(_externalFileAttrs);
            stream.writeUnsignedInt(_offsetLocalHeader);
        }
        
        _filename.position = 0;
        stream.writeBytes(_filename);
        
        if (as3hx.Compat.truthy(_extraFieldLength > 0))
        {
        }
    }
    
    public function readCentralHeader(stream                            : Dynamic, bytes                            : Dynamic) : Void
    {
        stream.readBytes(bytes, 0, 42);
        // ??????????
        bytes.position = 0;
        _versionBy = bytes.readUnsignedShort();
        
        // ???????
        bytes.position = 2;
        _version = bytes.readUnsignedShort();
        
        // ?????
        bytes.position = 4;
        _bitFlag = bytes.readUnsignedShort();
        
        // ????
        bytes.position = 6;
        _compressMethod = bytes.readUnsignedShort();
        
        //  ??????
        bytes.position = 8;
        _lastModTime = bytes.readUnsignedShort();
        
        // ??????
        bytes.position = 10;
        _lastModDate = bytes.readUnsignedShort();
        
        // CRC32
        bytes.position = 12;
        _crc32 = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 16;
        _compressSize = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 20;
        _uncompressSize = bytes.readUnsignedInt();
        
        // ???????
        bytes.position = 24;
        _filenameLength = bytes.readShort();
        
        // ????????
        bytes.position = 26;
        _extraFieldLength = bytes.readShort();
        
        // ????
        bytes.position = 28;
        _commentLength = bytes.readUnsignedShort();
        
        bytes.position = 30;
        _diskNumber = bytes.readUnsignedShort();
        
        bytes.position = 32;
        _internalFileAttrs = bytes.readUnsignedShort();
        
        bytes.position = 34;
        _externalFileAttrs = bytes.readUnsignedInt();
        
        bytes.position = 38;
        _offsetLocalHeader = bytes.readUnsignedInt();
        
        //  ????????????????????????????????
        var len                            : Dynamic= as3hx.Compat.parseInt(_filenameLength + _extraFieldLength + _commentLength);
        stream.readBytes(bytes, 42, len);
        
        // ?????
        bytes.position = 42;
        if (as3hx.Compat.truthy(_filenameLength > 0))
        {
            _filename = new ByteArray();
            bytes.readBytes(_filename, 0, _filenameLength);
        }
        // ????
        if (as3hx.Compat.truthy(_extraFieldLength > 0))
        {
            _extraField = new ByteArray();
            bytes.readBytes(_extraField, 0, _extraFieldLength);
        }
        
        if (as3hx.Compat.truthy(_commentLength > 0))
        {
            _comment = new ByteArray();
            bytes.readBytes(_comment, 0, _commentLength);
        }
    }
    
    
    
    /**
		*  MAC ????Windows???????????????????
		*/
    public function getFilenameUTF8() : String
    {
        if (as3hx.Compat.truthy(_filename == null))
        {
            return "";
        }
        
        _filename.position = 0;
        var ch                            : Dynamic= null;
        var ba                            : Dynamic= new ByteArray();
        var ret                            : Dynamic= "";
        while (as3hx.Compat.truthy(_filename.bytesAvailable))
        {
            ch = _filename.readUnsignedByte();
            if (as3hx.Compat.truthy(ch >= 0x00 && ch <= 0x7F))
            {
                ba.writeByte(ch);
            }
            else if (as3hx.Compat.truthy(ch >= 0xC0 && ch <= 0xDF)) {
ba.writeByte(ch);
                ba.writeByte(_filename.readUnsignedByte());
            }
            else if (as3hx.Compat.truthy(ch >= 0xE0 && ch <= 0xEF)) {
var ch1                            : Dynamic= _filename.readUnsignedByte();
                var ch2                            : Dynamic= _filename.readUnsignedByte();
                
                if (as3hx.Compat.truthy(ch == 0xe3 && ch1 == 0x82 && ch2 == 0x99))
                {
                    ba.position--;
                    ch = as3hx.Compat.parseInt(ba.readUnsignedByte() + 1);
                    ba.position--;
                    ba.writeByte(ch);
                }
                else if (as3hx.Compat.truthy(ch == 0xe3 && ch1 == 0x82 && ch2 == 0x9a))
                {
                    ba.position--;
                    ch = as3hx.Compat.parseInt(ba.readUnsignedByte() + 2);
                    ba.position--;
                    ba.writeByte(ch);
                }
                else
                {
                    ba.writeByte(ch);
                    ba.writeByte(ch1);
                    ba.writeByte(ch2);
                }
            }
            else if (as3hx.Compat.truthy(ch >= 0xF0 && ch <= 0xF7)) {
ba.writeByte(ch);
                ba.writeByte(_filename.readUnsignedByte());
                ba.writeByte(_filename.readUnsignedByte());
                ba.writeByte(_filename.readUnsignedByte());
            }
        }
        ba.position = 0;
        ret = ba.readMultiByte(ba.bytesAvailable, "utf-8");
        return ret;
    }
    
    public function getVersion() : Int
    {
        return as3hx.Compat.parseInt(_versionBy & 0xff);
    }
}

