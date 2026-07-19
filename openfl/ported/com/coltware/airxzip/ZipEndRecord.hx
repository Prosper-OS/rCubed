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
    
    public static var LENGTH : Int = 22;
    public static var SIGNATURE : Int = 0x06054b50;
    
    private var _signature : Int;
    private var _numberDisk : Int;
    private var _numberDiskStartCentralDir : Int;
    private var _totalEntriesDisk : Int;
    private var _totalEntries : Int;
    private var _sizeCentralDir : Int;
    private var _offsetCentralDir : Int;
    private var _commentLength : Int;
    private var _comment : ByteArray;
    
    
    public function new()
    {
    }
    
    public function write(data : IDataOutput, fileNum : Int, offset : Int, centralDirSize : Int) : Void
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
    
    public function read(data : IDataInput) : Void
    {
        var bytes : ByteArray = new ByteArray();
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
        
        if (_commentLength > 0)
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
