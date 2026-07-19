package com.flashfla.media;

import openfl.utils.ByteArray;
import openfl.utils.Endian;

class SwfSilencer
{
    public static function stripSound(data                            : Dynamic, metadata                            : Dynamic= null) : ByteArray
    {
        var odata                            : Dynamic= new ByteArray();
        odata.endian = Endian.LITTLE_ENDIAN;
        
        var header                            : Dynamic= SwfParser.readHeader(data);
        odata.writeBytes(data, 0, data.position);
        
        if (as3hx.Compat.truthy(header.version < 9))
        {
            odata[3] = 9;
        }
        
        var firstTag                            : Dynamic= true;
        var done                            : Dynamic= false;
        while (as3hx.Compat.truthy(data.bytesAvailable > 0 && !done))
        {
            var tag                            : Dynamic= SwfParser.readTag(data);
            var _sw4_ = (tag.tag);            

            switch (_sw4_)
            {
                case SwfParser.SWF_TAG_STREAMBLOCK, SwfParser.SWF_TAG_STREAMHEAD, SwfParser.SWF_TAG_STREAMHEAD2, SwfParser.SWF_TAG_DEFINESOUND:
                case SwfParser.SWF_TAG_END:
                    done = true;
                case SwfParser.SWF_TAG_FILEATTRIBUTES:
                    SwfParser.writeTag(odata, tag.tag, tag.length);
                    var position                            : Dynamic= odata.position;
                    odata.writeBytes(data, tag.position, tag.length);
                    odata[position] = odata[position] | 0x08;
                default:
                    if (as3hx.Compat.truthy(firstTag)) {
SwfParser.writeTag(odata, SwfParser.SWF_TAG_FILEATTRIBUTES, 4);
                        odata.writeUnsignedInt(0x00000008);
                    }
                    SwfParser.writeTag(odata, tag.tag, tag.length);
                    if (as3hx.Compat.truthy(tag.length > 0))
                    {
                        odata.writeBytes(data, tag.position, tag.length);
                    }
            }
            data.position = tag.position + tag.length;
            firstTag = false;
        }
        SwfParser.writeTag(odata, SwfParser.SWF_TAG_END);
        
        if (as3hx.Compat.truthy(metadata != null))
        {
        }
        
        return odata;
    }

    public function new()
    {
    }
}

