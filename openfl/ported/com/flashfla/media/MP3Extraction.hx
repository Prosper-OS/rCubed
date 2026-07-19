package com.flashfla.media;

import openfl.utils.ByteArray;

class MP3Extraction
{
    public static function extractSound(data : ByteArray, metadata : Dynamic = null) : ByteArray
    {
        var header : Dynamic = SwfParser.readHeader(data);
        
        if (header == null)
        {
            return null;
        }
        
        var mp3 : ByteArray = new ByteArray();
        var frame : Int = 0;
        var mp3Frame : Int = 0;
        var mp3Seek : Int = 0;
        var mp3Samples : Int = 0;
        var mp3Id : Int = 0;
        var mp3Format : Int = 0;
        var mp3Stream : Bool = false;
        var done : Bool = false;
        while (data.bytesAvailable > 0 && !done)
        {
            var tag : Dynamic = SwfParser.readTag(data);
            var _sw2_ = (tag.tag);            

            switch (_sw2_)
            {
                case SwfParser.SWF_TAG_END:
                    done = true;
                case SwfParser.SWF_TAG_SHOWFRAME:
                    frame++;
                case SwfParser.SWF_TAG_STREAMBLOCK:
                    if (!mp3Stream)
                    {
                        break;
                    }
                    if ((tag.length - 4) == 0)
                    {
                        break;
                    }
                    if (mp3Frame == 0)
                    {
                        mp3Frame = as3hx.Compat.parseInt(frame + 1);
                    }
                    mp3Samples += data.readUnsignedShort();  // frame samples  
                    data.readUnsignedShort();  // seek samples  
                    mp3.writeBytes(data, data.position, tag.length - 4);
                case SwfParser.SWF_TAG_STREAMHEAD, SwfParser.SWF_TAG_STREAMHEAD2:
                    data.readUnsignedByte();
                    mp3Format = data.readUnsignedByte();
                    data.readUnsignedShort();  // average frame samples  
                    mp3Seek = data.readUnsignedShort();
                    if ((as3hx.Compat.parseInt(mp3Format >>> 4) & 0xf) == SwfParser.SWF_CODEC_MP3)
                    {
                        mp3Stream = true;
                    }
                case SwfParser.SWF_TAG_DEFINESOUND:
                    if (!mp3Stream)
                    {
                        var id : Int = data.readUnsignedShort();
                        var format : Int = data.readUnsignedByte();
                        if ((as3hx.Compat.parseInt(format >>> 4) & 0xf) == SwfParser.SWF_CODEC_MP3)
                        {
                            mp3Id = id;
                            mp3Format = format;
                            mp3Samples = data.readInt();
                            mp3Seek = data.readUnsignedShort();
                            mp3.writeBytes(data, data.position, tag.length - 9);
                            done = true;
                        }
                    }
                default:
            }
            data.position = tag.position + tag.length;
        }
        
        if (metadata != null)
        {
            metadata.frame = mp3Frame - 1;
            metadata.samples = mp3Samples;
            metadata.seek = mp3Seek;
            metadata.id = mp3Id;
            metadata.format = mp3Format;
        }
        
        return mp3;
    }
    
    public static function formatRate(format : Int) : Int
    {
        var _sw3_ = ((format & 0x0C) >> 2);        

        switch (_sw3_)
        {
            case 0:
                return 5500;
            case 1:
                return 11000;
            case 2:
                return 22050;
            case 3:
                return 44100;
        }
        return 0;
    }

    public function new()
    {
    }
}

