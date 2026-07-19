package com.flashfla.media;

import openfl.utils.ByteArray;
import openfl.utils.Endian;

class SwfParser
{
    public static inline var SWF_TAG_END                            : Dynamic= 0;
    public static inline var SWF_TAG_SHOWFRAME                            : Dynamic= 1;
    public static inline var SWF_TAG_DOACTION                            : Dynamic= 12;
    public static inline var SWF_TAG_DEFINESOUND                            : Dynamic= 14;
    public static inline var SWF_TAG_STREAMHEAD                            : Dynamic= 18;
    public static inline var SWF_TAG_STREAMBLOCK                            : Dynamic= 19;
    public static inline var SWF_TAG_STREAMHEAD2                            : Dynamic= 45;
    public static inline var SWF_TAG_FILEATTRIBUTES                            : Dynamic= 69;
    
    public static inline var SWF_ACTION_END                            : Dynamic= 0x00;
    public static inline var SWF_ACTION_CONSTANTPOOL                            : Dynamic= 0x88;
    public static inline var SWF_ACTION_PUSH                            : Dynamic= 0x96;
    public static inline var SWF_ACTION_POP                            : Dynamic= 0x17;
    public static inline var SWF_ACTION_DUPLICATE                            : Dynamic= 0x4C;
    public static inline var SWF_ACTION_STORE_REGISTER                            : Dynamic= 0x87;
    public static inline var SWF_ACTION_GET_VARIABLE                            : Dynamic= 0x1C;
    public static inline var SWF_ACTION_SET_VARIABLE                            : Dynamic= 0x1D;
    public static inline var SWF_ACTION_INIT_ARRAY                            : Dynamic= 0x42;
    public static inline var SWF_ACTION_GET_MEMBER                            : Dynamic= 0x4E;
    public static inline var SWF_ACTION_SET_MEMBER                            : Dynamic= 0x4F;
    
    public static inline var SWF_TYPE_STRING_LITERAL                            : Dynamic= 0;
    public static inline var SWF_TYPE_FLOAT_LITERAL                            : Dynamic= 1;
    public static inline var SWF_TYPE_NULL                            : Dynamic= 2;
    public static inline var SWF_TYPE_UNDEFINED                            : Dynamic= 3;
    public static inline var SWF_TYPE_REGISTER                            : Dynamic= 4;
    public static inline var SWF_TYPE_BOOLEAN                            : Dynamic= 5;
    public static inline var SWF_TYPE_DOUBLE                            : Dynamic= 6;
    public static inline var SWF_TYPE_INTEGER                            : Dynamic= 7;
    public static inline var SWF_TYPE_CONSTANT8                            : Dynamic= 8;
    public static inline var SWF_TYPE_CONSTANT16                            : Dynamic= 9;
    
    public static inline var SWF_CODEC_MP3                            : Dynamic= 2;
    
    public static function readHeader(data                            : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(data.length == 0))
        {
            return null;
        }
        data.endian = Endian.LITTLE_ENDIAN;
        if (as3hx.Compat.truthy(isCompressed(data)))
        {
            uncompress(data);
        }
        
        var ret                            : Dynamic= {};
        
        data.position = 3;
        ret.version = data.readUnsignedByte();
        ret.size = data.readInt();
        
        // SWF Rectangle
        data.position += (4 * (data.readUnsignedByte() >>> 3) - 3 + 7) / 8 + 1;
        
        ret.frameRate = data.readUnsignedShort();
        ret.frameCount = data.readUnsignedShort();
        
        return ret;
    }
    
    public static function readTag(data                            : Dynamic) : Dynamic
    {
        var ret                            : Dynamic= {};
        var tag                            : Dynamic= data.readUnsignedShort();
        var len                            : Dynamic= tag & 0x3f;
        ret.tag = (tag >>> 6);
        ret.length = ((len == 0x3f) ? data.readUnsignedInt() : len);
        ret.position = data.position;
        return ret;
    }
    
    public static function writeTag(data                            : Dynamic, tag                            : Dynamic, length                            : Dynamic= 0) : Void
    {
        data.writeShort((as3hx.Compat.parseInt(tag << 6) & 0xffc0) | ((length < 0x3f) ? length : 0x3f));
        if (as3hx.Compat.truthy(length >= 0x3f))
        {
            data.writeUnsignedInt(length);
        }
    }
    
    public static function readAction(data                            : Dynamic) : Dynamic
    {
        var ret                            : Dynamic= {};
        ret.action = data.readUnsignedByte();
        ret.length = (((ret.action & 0x80) != 0)) ? data.readUnsignedShort() : 0;
        ret.position = data.position;
        return ret;
    }
    
    public static function readString(data                            : Dynamic) : String
    {
        var ret                          : Dynamic= "";
        while (as3hx.Compat.truthy(true))
        {
            var read                            : Dynamic= data.readUnsignedByte();
            if (as3hx.Compat.truthy(read == 0))
            {
                break;
            }
            ret += String.fromCharCode(read);
        }
        return ret;
    }
    
    private static function isCompressed(bytes                            : Dynamic) : Bool
    {
        return bytes[0] == 0x43;
    }
    
    private static function uncompress(bytes                            : Dynamic) : Void
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

    public function new()
    {
    }
}

