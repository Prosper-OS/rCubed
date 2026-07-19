/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip.crypt;

import com.coltware.airxzip.ZipCRC32;
import com.coltware.airxzip.ZipEntry;
import com.coltware.airxzip.ZipError;
import com.coltware.airxzip.ZipHeader;
import com.coltware.airxzip.ZipInternal;
import openfl.utils.*;

class ZipCrypto implements ICrypto
{
    
    private static var CRYPTHEADLEN : Int = 12;
    
    // Initial keys
    private static var S_KEY1 : Int = 305419896;
    private static var S_KEY2 : Int = 591751049;
    private static var S_KEY3 : Int = 878082192;
    
    private var _key : Array<Dynamic>;
    private var _password : ByteArray;
    private var _header : ZipHeader;
    
    private var _outBytes : ByteArray;
    
    public function new()
    {
    }
    
    public function initEncrypt(password : ByteArray, header : ZipHeader) : Void
    {
        var crc32 : Int = header._crc32;
        _outBytes = new ByteArray();
        _initEncrypt(password, crc32);
        
        header._compressSize += CRYPTHEADLEN;
    }
    
    /**
		 *  ?????????????
		 *
		 */
    private function _initEncrypt(password : ByteArray, crc32 : Int) : Void
    {
        crc32 = crc32 >> 24;
        
        var ret : ByteArray = _outBytes;
        _key = new Array<Dynamic>(3);
        _key[0] = S_KEY1;
        _key[1] = S_KEY2;
        _key[2] = S_KEY3;
        
        password.position = 0;
        while (password.bytesAvailable > 0)
        {
            var n : Int = password.readUnsignedByte();
            updateKeys(n);
        }
        
        var d : Int;
        for (i in 0...CRYPTHEADLEN)
        {
            if (i == CRYPTHEADLEN - 1)
            {
                d = as3hx.Compat.parseInt(crc32 & 0xff);
            }
            else
            {
                d = as3hx.Compat.parseInt(as3hx.Compat.parseInt(crc32 >> 32) & 0xFF);
            }
            d = zencode(d);
            ret.writeByte(d);
        }
    }
    
    /**
		 *  encrypt data
		 */
    public function encrypt(data : ByteArray) : ByteArray
    {
        data.position = 0;
        while (data.bytesAvailable)
        {
            var n : Int = data.readUnsignedByte();
            _outBytes.writeByte(zencode(n));
        }
        _outBytes.position = 0;
        
        return _outBytes;
    }
    
    public function checkDecrypt(entry : ZipEntry) : Bool
    {
        return true;
    }
    
    public function initDecrypt(password : ByteArray, header : ZipHeader) : Void
    {
        this._password = password;
        this._header = header;
    }
    
    public function decrypt(data : ByteArray) : ByteArray
    {
        var check1 : Int = _header._crc32 >>> 24;
        var cryptoHeader : ByteArray = new ByteArray();
        data.readBytes(cryptoHeader, 0, CRYPTHEADLEN);
        var check2 : Int = _initDecrypt(this._password, cryptoHeader);
        check2 = as3hx.Compat.parseInt(check2 & 0xffff);
        if (check1 == check2)
        {
            return _decrypt(data);
        }
        else
        {
            throw new ZipError("password is not match");
        }
    }
    
    /**
		 *  ?????????????
		 *
		 */
    private function _initDecrypt(password : ByteArray, cryptHeader : ByteArray) : Int
    {
        var ret : ByteArray = new ByteArray();
        _key = new Array<Dynamic>(3);
        _key[0] = S_KEY1;
        _key[1] = S_KEY2;
        _key[2] = S_KEY3;
        
        password.position = 0;
        
        while (password.bytesAvailable > 0)
        {
            var n : Int = password.readUnsignedByte();
            updateKeys(n);
        }
        cryptHeader.position = 0;
        
        for (i in 0...CRYPTHEADLEN)
        {
            var b : Int = cryptHeader.readUnsignedByte();
            b = zdecode(b);
        }
        return b;
    }
    
    /**
		 *  ????
		 *
		 */
    private function _decrypt(data : ByteArray) : ByteArray
    {
        var out : ByteArray = new ByteArray();
        while (data.bytesAvailable > 0)
        {
            var n : Int = data.readUnsignedByte();
            n = zdecode(n);
            out.writeByte(n);
        }
        out.position = 0;
        return out;
    }
    
    /**
		 *  ???
		 */
    private function zdecode(n : Int) : Int
    {
        var t : Int = n;
        
        var d : Int = decryptByte();
        n = n ^ d;
        updateKeys(n);
        return n;
    }
    
    /**
		 *  ???
		 */
    private function zencode(n : Int) : Int
    {
        var t : Int = decryptByte();
        updateKeys(n);
        return as3hx.Compat.parseInt(t ^ n);
    }
    
    /**
		 *
		 *  @return unsigned char
		 */
    private function decryptByte() : Int
    {
        var temp : Int = as3hx.Compat.parseInt(_key[2] & 0xFFFF) | 2;
        var ret : Int = as3hx.Compat.parseInt((temp * (temp ^ 1)) >> 8) & 0xFF;
        return ret;
    }
    
    /**
		 *
		 *
		 */
    private function updateKeys(uchar : Int) : Void
    {
        _key[0] = ZipCRC32.getCRC32(_key[0], uchar);
        _key[1] = _key[1] + (_key[0] & 0xFF);
        
        //  ???2????????????Number??????????????????????
        var k2 : Int = _key[1];
        var b1 : Int = 134775000;
        var b2 : Int = 813;
        var t : Int = as3hx.Compat.parseInt(as3hx.Compat.parseInt(k2 * b1) + as3hx.Compat.parseInt(k2 * b2) + 1);
        _key[1] = t;
        
        var k3 : Int = _key[1];
        
        var tmp : Int = _key[1] >> 24;
        _key[2] = as3hx.Compat.parseInt(ZipCRC32.getCRC32(_key[2], tmp));
    }
}
