/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import openfl.events.Event;
import openfl.utils.*;

/**
	 *  ZIP???????????????
	 *
	 */
class ZipEvent extends Event
{
    public var entry(get, never)                            : Dynamic;
    public var data(get, never)                            : Dynamic;

    
    public static var ZIP_LOAD_DATA                            : Dynamic= "zipLoadData";
    public static var ZIP_DATA_UNCOMPRESS                            : Dynamic= "zipDataUncompress";
    public static var ZIP_DATA_COMPRESS                            : Dynamic= "zipDataCompress";
    public static var ZIP_FILE_CREATED                            : Dynamic= "zipFileCreated";
    
    public var __DOLLAR__entry                            : Dynamic;
    public var __DOLLAR__data                            : Dynamic;
    public var __DOLLAR__method                            : Dynamic;
    
    public function new(type                            : Dynamic)
    {
        super(type);
    }
    
    private function get_entry() : ZipEntry
    {
        return __DOLLAR__entry;
    }
    
    private function get_data() : ByteArray
    {
        if (as3hx.Compat.truthy(__DOLLAR__method != null))
        {
            __DOLLAR__data.uncompress(__DOLLAR__method);
        }
        return __DOLLAR__data;
    }
}
