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
    public var entry(get, never) : ZipEntry;
    public var data(get, never) : ByteArray;

    
    public static var ZIP_LOAD_DATA : String = "zipLoadData";
    public static var ZIP_DATA_UNCOMPRESS : String = "zipDataUncompress";
    public static var ZIP_DATA_COMPRESS : String = "zipDataCompress";
    public static var ZIP_FILE_CREATED : String = "zipFileCreated";
    
    public var __DOLLAR__entry : ZipEntry;
    public var __DOLLAR__data : ByteArray;
    public var __DOLLAR__method : String;
    
    public function new(type : String)
    {
        super(type);
    }
    
    private function get_entry() : ZipEntry
    {
        return __DOLLAR__entry;
    }
    
    private function get_data() : ByteArray
    {
        if (__DOLLAR__method != null)
        {
            __DOLLAR__data.uncompress(__DOLLAR__method);
        }
        return __DOLLAR__data;
    }
}
