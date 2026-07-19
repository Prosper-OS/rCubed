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
    
    public static var CRYPTHEADLEN                            : Dynamic= 12;
    
    private static var S_KEY1                            : Dynamic= 305419896;
    private static var S_KEY2                            : Dynamic= 591751049;
    private static var S_KEY3                            : Dynamic= 878082192;
    
    private static var _crc32table                            : Dynamic= createTable();
    
    private var _key                            : Dynamic;
    
    public function new()
    {
    }
    
    private static function createTable() : Array<Dynamic>
    {
        var arr                         : Dynamic= [];
        as3hx.Compat.setArrayLength(arr, 256);
        var p                            : Dynamic= 0xEDB88320;
        var c                            : Dynamic= null;
        for (i in 0...256)
        {
            c = i;
            for (j in 0...8)
            {
                if (as3hx.Compat.truthy((c & 1) != 0))
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
    
    public static function getByteArrayValue(data                            : Dynamic) : Int
    {
        var c                            : Dynamic= 0xffffffff;
        var n                            : Dynamic= 0;
        for (i in 0...data.length)
        {
            n = as3hx.Compat.parseInt(c ^ data[i]) & 0xFF;
            c = as3hx.Compat.parseInt(_crc32table[n]) ^ as3hx.Compat.parseInt(c >>> 8);
        }
        return as3hx.Compat.parseInt(c ^ 0xffffffff);
    }
    
    public static function getCRC32(n1                            : Dynamic, n2                            : Dynamic) : Int
    {
        var _idx                            : Dynamic= as3hx.Compat.parseInt(n1 ^ n2) & 0xFF;
        var _val                            : Dynamic= _crc32table[_idx] ^ as3hx.Compat.parseInt(n1 >>> 8);
        return _val;
    }
    
    public static function getStringValue(str                            : Dynamic) : Int
    {
        var ba                            : Dynamic= new ByteArray();
        ba.writeUTFBytes(str);
        return getByteArrayValue(ba);
    }
}
