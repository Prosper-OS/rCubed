package com.flashfla.media;

import openfl.utils.ByteArray;
import openfl.utils.Endian;

class SwfParser
{
    public static inline var SWF_TAG_END : Int = 0;
    public static inline var SWF_TAG_SHOWFRAME : Int = 1;
    public static inline var SWF_TAG_DOACTION : Int = 12;
    public static inline var SWF_TAG_DEFINESOUND : Int = 14;
    public static inline var SWF_TAG_STREAMHEAD : Int = 18;
    public static inline var SWF_TAG_STREAMBLOCK : Int = 19;
    public static inline var SWF_TAG_STREAMHEAD2 : Int = 45;
    public static inline var SWF_TAG_FILEATTRIBUTES : Int = 69;
    
    public static inline var SWF_ACTION_END : Int = 0x00;
    public static inline var SWF_ACTION_CONSTANTPOOL : Int = 0x88;
    public static inline var SWF_ACTION_PUSH : Int = 0x96;
    public static inline var SWF_ACTION_POP : Int = 0x17;
    public static inline var SWF_ACTION_DUPLICATE : Int = 0x4C;
    public static inline var SWF_ACTION_STORE_REGISTER : Int = 0x87;
    public static inline var SWF_ACTION_GET_VARIABLE : Int = 0x1C;
    public static inline var SWF_ACTION_SET_VARIABLE : Int = 0x1D;
    public static inline var SWF_ACTION_INIT_ARRAY : Int = 0x42;
    public static inline var SWF_ACTION_GET_MEMBER : Int = 0x4E;
    public static inline var SWF_ACTION_SET_MEMBER : Int = 0x4F;
    
    public static inline var SWF_TYPE_STRING_LITERAL : Int = 0;
    public static inline var SWF_TYPE_FLOAT_LITERAL : Int = 1;
    public static inline var SWF_TYPE_NULL : Int = 2;
    public static inline var SWF_TYPE_UNDEFINED : Int = 3;
    public static inline var SWF_TYPE_REGISTER : Int = 4;
    public static inline var SWF_TYPE_BOOLEAN : Int = 5;
    public static inline var SWF_TYPE_DOUBLE : Int = 6;
    public static inline var SWF_TYPE_INTEGER : Int = 7;
    public static inline var SWF_TYPE_CONSTANT8 : Int = 8;
    public static inline var SWF_TYPE_CONSTANT16 : Int = 9;
    
    public static inline var SWF_CODEC_MP3 : Int = 2;
    
    public static function readHeader(data : ByteArray) : Dynamic
    {
        if (data.length == 0)
        {
            return null;
        }
        data.endian = Endian.LITTLE_ENDIAN;
        if (isCompressed(data))
        {
            uncompress(data);
        }
        
        var ret : Dynamic = {};
        
        data.position = 3;
        ret.version = data.readUnsignedByte();
        ret.size = data.readInt();
        
        // SWF Rectangle
        data.position += (4 * (data.readUnsignedByte() >>> 3) - 3 + 7) / 8 + 1;
        
        ret.frameRate = data.readUnsignedShort();
        ret.frameCount = data.readUnsignedShort();
        
        return ret;
    }
    
    public static function readTag(data : ByteArray) : Dynamic
    {
        var ret : Dynamic = {};
        var tag : Int = data.readUnsignedShort();
        var len : Int = tag & 0x3f;
        ret.tag = (tag >>> 6);
        ret.length = ((len == 0x3f) ? data.readUnsignedInt() : len);
        ret.position = data.position;
        return ret;
    }
    
    public static function writeTag(data : ByteArray, tag : Int, length : Int = 0) : Void
    {
        data.writeShort((as3hx.Compat.parseInt(tag << 6) & 0xffc0) | ((length < 0x3f) ? length : 0x3f));
        if (length >= 0x3f)
        {
            data.writeUnsignedInt(length);
        }
    }
    
    public static function readAction(data : ByteArray) : Dynamic
    {
        var ret : Dynamic = {};
        ret.action = data.readUnsignedByte();
        ret.length = (((ret.action & 0x80) != 0)) ? data.readUnsignedShort() : 0;
        ret.position = data.position;
        return ret;
    }
    
    public static function readString(data : ByteArray) : String
    {
        var ret : String = new String();
        while (true)
        {
            var read : Int = data.readUnsignedByte();
            if (read == 0)
            {
                break;
            }
            ret += String.fromCharCode(read);
        }
        return ret;
    }
    
    private static function isCompressed(bytes : ByteArray) : Bool
    {
        return bytes[0] == 0x43;
    }
    
    private static function uncompress(bytes : ByteArray) : Void
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

    public function new()
    {
    }
}

