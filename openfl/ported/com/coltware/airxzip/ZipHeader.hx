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
    
    public static var HEADER_LOCAL_FILE : Int = 0x04034b50;
    public static var HEADER_CENTRAL_DIR : Int = 0x02014b50;
    public static var HEADER_END_CENTRAL_DIR : Int = 0x06054b50;
    
    public static var WIN_DIR : Int = 16;
    public static var WIN_FILE : Int = 32;
    
    public static var UNIX_DIR : Int = 0x4000;
    public static var UNIX_FILE : Int = 0x8000;
    
    public var _signature : Int;
    public var _version : Int;
    public var _bitFlag : Int;
    public var _compressMethod : Int;
    public var _lastModTime : Int;
    public var _lastModDate : Int;
    public var _crc32 : Int;
    public var _compressSize : Int;
    public var _uncompressSize : Int;
    public var _filenameLength : Int;
    public var _extraFieldLength : Int;
    public var _filename : ByteArray;
    public var _extraField : ByteArray;
    
    //  ???? CENTRAL DIRECTORY
    public var _versionBy : Int;
    public var _commentLength : Int;
    public var _diskNumber : Int = 0;
    public var _internalFileAttrs : Int = 0;
    public var _externalFileAttrs : Int = 0;
    public var _offsetLocalHeader : Int;
    public var _comment : ByteArray;
    
    public function new(sig : Int = 0x04034b50)
    {
        _signature = sig;
    }
    
    public function read(stream : IDataInput, bytes : ByteArray) : Void
    {
        if (_signature == HEADER_LOCAL_FILE)
        {
            readLocalHeader(stream, bytes);
        }
        else if (_signature == HEADER_CENTRAL_DIR)
        {
            readCentralHeader(stream, bytes);
        }
    }
    
    public function readAuto(stream : IDataInput) : Void
    {
        var bytes : ByteArray = new ByteArray();
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
        if (_uncompressSize == 0)
        {
            if (_externalFileAttrs == 0)
            {
                return false;
            }
            else if ((_externalFileAttrs & 16) != 0)
            {
                return true;
            }
            else
            {
                var num : Int = as3hx.Compat.parseInt(as3hx.Compat.parseInt(_externalFileAttrs >> 16) & 0xFFFF);
                if ((num & ZipHeader.UNIX_DIR) != 0)
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    public function getCompressRate() : Float
    {
        if (_uncompressSize == 0)
        {
            return 0;
        }
        var num : Float = _compressSize / _uncompressSize;
        return 1 - num;
    }
    
    public function getDate() : Date
    {
        var sec : Int = _lastModTime & 0x001f;
        var min : Int = as3hx.Compat.parseInt(_lastModTime & 0x07e0) >> 5;
        var hour : Int = as3hx.Compat.parseInt(_lastModTime & 0xf800) >> 11;
        var day : Int = as3hx.Compat.parseInt(_lastModDate & 0x001f);
        var month : Int = as3hx.Compat.parseInt(_lastModDate & 0x01e0) >> 5;
        var year : Int = as3hx.Compat.parseInt(((_lastModDate & 0xfe00) >> 9) + 1980);
        var date : Date = new Date(year, month - 1, day, hour, min, sec, 0);
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
    
    public function getFilename(charset : String = null) : String
    {
        if (_filenameLength < 1)
        {
            return "";
        }
        if (charset == null) {
if ((_versionBy >> 8) == 3)
            {
                charset = "utf-8";
            }
            else
            {
                charset = "shift_jis";
            }
        }
        
        var _char : String = charset.toLowerCase();
        if (_char == "utf-8")
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
    
    private function readLocalHeader(stream : IDataInput, bytes : ByteArray) : Void
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
        
        if (_signature == HEADER_LOCAL_FILE) {
stream.readBytes(bytes, 26, _filenameLength + _extraFieldLength);
            
            // ?????
            bytes.position = 26;
            _filename = new ByteArray();
            bytes.readBytes(_filename, 0, _filenameLength);
            
            // ????
            if (_extraFieldLength > 0)
            {
                _extraField = new ByteArray();
                bytes.readBytes(_extraField, 0, _extraFieldLength);
            }
        }
    }
    
    public function writeLocalHeader(stream : IDataOutput) : Void
    {
        this.writeHeader(stream, false);
    }
    
    public function writeCentralHeader(stream : IDataOutput) : Void
    {
        this.writeHeader(stream, true);
    }
    
    /**
		*  ????????
		*
		*/
    private function writeHeader(stream : IDataOutput, isCentral : Bool = false) : Void
    {
        if (isCentral)
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
        
        
        if (_extraFieldLength > 0)
        {
            _extraField.position = 0;
            stream.writeBytes(_extraField);
        }
        
        if (isCentral)
        {
            stream.writeShort(_commentLength);
            stream.writeShort(_diskNumber);
            stream.writeShort(_internalFileAttrs);
            stream.writeUnsignedInt(_externalFileAttrs);
            stream.writeUnsignedInt(_offsetLocalHeader);
        }
        
        _filename.position = 0;
        stream.writeBytes(_filename);
        
        if (_extraFieldLength > 0)
        {
        }
    }
    
    private function readCentralHeader(stream : IDataInput, bytes : ByteArray) : Void
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
        var len : Int = as3hx.Compat.parseInt(_filenameLength + _extraFieldLength + _commentLength);
        stream.readBytes(bytes, 42, len);
        
        // ?????
        bytes.position = 42;
        if (_filenameLength > 0)
        {
            _filename = new ByteArray();
            bytes.readBytes(_filename, 0, _filenameLength);
        }
        // ????
        if (_extraFieldLength > 0)
        {
            _extraField = new ByteArray();
            bytes.readBytes(_extraField, 0, _extraFieldLength);
        }
        
        if (_commentLength > 0)
        {
            _comment = new ByteArray();
            bytes.readBytes(_comment, 0, _commentLength);
        }
    }
    
    
    
    /**
		*  MAC ????Windows???????????????????
		*/
    private function getFilenameUTF8() : String
    {
        if (_filename == null)
        {
            return "";
        }
        
        _filename.position = 0;
        var ch : Int;
        var ba : ByteArray = new ByteArray();
        var ret : String = "";
        while (_filename.bytesAvailable)
        {
            ch = _filename.readUnsignedByte();
            if (ch >= 0x00 && ch <= 0x7F)
            {
                ba.writeByte(ch);
            }
            else if (ch >= 0xC0 && ch <= 0xDF) {
ba.writeByte(ch);
                ba.writeByte(_filename.readUnsignedByte());
            }
            else if (ch >= 0xE0 && ch <= 0xEF) {
var ch1 : Int = _filename.readUnsignedByte();
                var ch2 : Int = _filename.readUnsignedByte();
                
                if (ch == 0xe3 && ch1 == 0x82 && ch2 == 0x99)
                {
                    ba.position--;
                    ch = as3hx.Compat.parseInt(ba.readUnsignedByte() + 1);
                    ba.position--;
                    ba.writeByte(ch);
                }
                else if (ch == 0xe3 && ch1 == 0x82 && ch2 == 0x9a)
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
            else if (ch >= 0xF0 && ch <= 0xF7) {
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

