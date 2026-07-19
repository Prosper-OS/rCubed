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
	 * @private
	 * 
	 */
class ZipCRC32
{
    
    public static var CRYPTHEADLEN : Int = 12;
    
    private static var S_KEY1 : Int = 305419896;
    private static var S_KEY2 : Int = 591751049;
    private static var S_KEY3 : Int = 878082192;
    
    private static var _crc32table : Array<Dynamic> = createTable();
    
    private var _key : Array<Dynamic>;
    
    public function new()
    {
    }
    
    private static function createTable() : Array<Dynamic>
    {
        var arr : Array<Dynamic> = new Array<Dynamic>(256);
        var p : Int = 0xEDB88320;
        var c : Int;
        for (i in 0...256)
        {
            c = i;
            for (j in 0...8)
            {
                if ((c & 1) != 0)
                {
                    c = as3hx.Compat.parseInt(p ^ as3hx.Compat.parseInt(c >>> 1));
                }
                else
                {
                    c = as3hx.Compat.parseInt(c >>> 1);
                }
                arr[i] = c;
            }
        }
        return arr;
    }
    
    public static function getByteArrayValue(data : ByteArray) : Int
    {
        var c : Int = 0xffffffff;
        var n : Int = 0;
        for (i in 0...data.length)
        {
            n = as3hx.Compat.parseInt(c ^ data[i]) & 0xFF;
            c = as3hx.Compat.parseInt(_crc32table[n]) ^ as3hx.Compat.parseInt(c >>> 8);
        }
        return as3hx.Compat.parseInt(c ^ 0xffffffff);
    }
    
    public static function getCRC32(n1 : Int, n2 : Int) : Int
    {
        var _idx : Int = as3hx.Compat.parseInt(n1 ^ n2) & 0xFF;
        var _val : Int = _crc32table[_idx] ^ as3hx.Compat.parseInt(n1 >>> 8);
        return _val;
    }
    
    public static function getStringValue(str : String) : Int
    {
        var ba : ByteArray = new ByteArray();
        ba.writeUTFBytes(str);
        return getByteArrayValue(ba);
    }
}
