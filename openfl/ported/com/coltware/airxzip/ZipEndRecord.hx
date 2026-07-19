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
	 * 
	 * @private
	 * 
	 */
class ZipEndRecord
{
    
    public static var LENGTH                            : Dynamic= 22;
    public static var SIGNATURE                            : Dynamic= 0x06054b50;
    
    private var _signature                            : Dynamic;
    private var _numberDisk                            : Dynamic;
    private var _numberDiskStartCentralDir                            : Dynamic;
    private var _totalEntriesDisk                            : Dynamic;
    private var _totalEntries                            : Dynamic;
    private var _sizeCentralDir                            : Dynamic;
    private var _offsetCentralDir                            : Dynamic;
    private var _commentLength                            : Dynamic;
    private var _comment                            : Dynamic;
    
    
    public function new()
    {
    }
    
    public function write(data                            : Dynamic, fileNum                            : Dynamic, offset                            : Dynamic, centralDirSize                            : Dynamic) : Void
    {
        _signature = SIGNATURE;
        _numberDisk = 0;
        _totalEntries = fileNum;
        _commentLength = 0;
        _sizeCentralDir = centralDirSize;
        _offsetCentralDir = offset;
        
        data.writeUnsignedInt(SIGNATURE);
        
        data.writeShort(_numberDisk);  // Number of this disk  
        
        data.writeShort(0);
        data.writeShort(_totalEntries);
        data.writeShort(_totalEntries);
        
        data.writeUnsignedInt(_sizeCentralDir);
        data.writeUnsignedInt(_offsetCentralDir);
        
        data.writeShort(_commentLength);
    }
    
    public function read(data                            : Dynamic) : Void
    {
        var bytes                            : Dynamic= new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;
        data.readBytes(bytes, 0, LENGTH);
        
        bytes.position = 0;
        _signature = bytes.readInt();
        
        bytes.position = 4;
        _numberDisk = bytes.readUnsignedShort();
        bytes.position = 6;
        _numberDiskStartCentralDir = bytes.readUnsignedShort();
        bytes.position = 8;
        _totalEntriesDisk = bytes.readShort();
        bytes.position = 10;
        _totalEntries = bytes.readShort();
        bytes.position = 12;
        _sizeCentralDir = bytes.readInt();
        bytes.position = 16;
        _offsetCentralDir = bytes.readInt();
        bytes.position = 20;
        _commentLength = bytes.readUnsignedShort();
        
        if (as3hx.Compat.truthy(_commentLength > 0))
        {
            data.readBytes(bytes, LENGTH, _commentLength);
        }
    }
    /**
		*  Central Direcotry ???????????
		*/
    public function getOffset() : Int
    {
        return _offsetCentralDir;
    }
    
    public function getSize() : Int
    {
        return _sizeCentralDir;
    }
    
    /**
		*  TOTAL???????????
		*
		*/
    public function getTotalEntries() : Int
    {
        return _totalEntries;
    }
}
