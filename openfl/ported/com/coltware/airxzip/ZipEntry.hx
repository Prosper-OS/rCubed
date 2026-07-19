/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import openfl.events.*;
import openfl.utils.*;

/**
	*  Zip??????
	*/
class ZipEntry extends EventDispatcher
{
    
    public static var METHOD_NONE                            : Dynamic= 0;
    public static var METHOD_DEFLATE                            : Dynamic= 8;
    
    public var _header                            : Dynamic;
    public var _headerLocal                            : Dynamic;
    private var _content                            : Dynamic;
    
    private var _stream                            : Dynamic;
    
    public function new(stream                            : Dynamic)
    {
        super();
        _stream = stream;
    }
    
    /**
		*  @private
		*/
    public function setHeader(h                            : Dynamic) : Void
    {
        _header = h;
    }
    
    public function getHeader() : ZipHeader
    {
        return _header;
    }
    
    /**
		*  ???????
		*
		*/
    public function getCompressMethod() : Int
    {
        return _header.getCompressMethod();
    }
    
    public function isCompressed() : Bool
    {
        var method                            : Dynamic= _header.getCompressMethod();
        if (as3hx.Compat.truthy(method == 0))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    /**
		*  ??????????.
		*
		*  ?????????????????????????
		*  ????????Zip????????????????????????
		*  ????utf-8 ???? shift_jis ??????????????????
		*
		*/
    public function getFilename(charset                            : Dynamic= null) : String
    {
        return _header.getFilename(charset);
    }
    
    /**
		*  
		*  ????????
		*/
    public function isDirectory() : Bool
    {
        return _header.isDirectory();
    }
    /**
		*  ??????.
		*
		*/
    public function getCompressRate() : Float
    {
        return _header.getCompressRate();
    }
    
    public function getUncompressSize() : Int
    {
        return _header.getUncompressSize();
    }
    
    public function getCompressSize() : Int
    {
        return _header.getCompressSize();
    }
    
    /**
		*  ???????
		*
		*/
    public function getDate() : Date
    {
        return _header.getDate();
    }
    
    /**
		 *  ????????????.
		 * 
		 * unzip??????"minimum software version required to extract:"?????????
		 * 
		 */
    public function getVersion() : Int
    {
        return _header._version;
    }
    
    /**
		 *  ????????????????
		 * 
		 * unzip??????"version of encoding software:"????????
		 * 
		 */
    public function getHostVersion() : Int
    {
        return _header.getVersion();
    }
    /**
		 *  CRC32 ???????
		 */
    public function getCrc32() : String
    {
        return Std.string(_header._crc32);
    }
    
    public function isEncrypted() : Bool
    {
        if (as3hx.Compat.truthy((_header._bitFlag & 1) != 0))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /**
		*
		*  LOCAL HEADER?????????????
		*
		* @private
		*/
    public function getLocalHeaderOffset() : Int
    {
        return _header.getLocalHeaderOffset();
    }
    
    
    
    /**
		 * @private
		 */
    public function getLocalHeaderSize() : Int
    {
        return _header.getLocalHeaderSize();
    }
}
