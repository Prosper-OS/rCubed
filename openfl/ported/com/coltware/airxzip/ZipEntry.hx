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
    
    public static var METHOD_NONE : Int = 0;
    public static var METHOD_DEFLATE : Int = 8;
    
    public var _header : ZipHeader;
    public var _headerLocal : ZipHeader;
    private var _content : ByteArray;
    
    private var _stream : IDataInput;
    
    public function new(stream : IDataInput)
    {
        super();
        _stream = stream;
    }
    
    /**
		*  @private
		*/
    public function setHeader(h : ZipHeader) : Void
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
        var method : Int = _header.getCompressMethod();
        if (method == 0)
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
    public function getFilename(charset : String = null) : String
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
        if ((_header._bitFlag & 1) != 0)
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
