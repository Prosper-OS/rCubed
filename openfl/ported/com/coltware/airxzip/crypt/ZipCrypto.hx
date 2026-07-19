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
    
    private static var CRYPTHEADLEN                            : Dynamic= 12;
    
    // Initial keys
    private static var S_KEY1                            : Dynamic= 305419896;
    private static var S_KEY2                            : Dynamic= 591751049;
    private static var S_KEY3                            : Dynamic= 878082192;
    
    private var _key                            : Dynamic;
    private var _password                            : Dynamic;
    private var _header                            : Dynamic;
    
    private var _outBytes                            : Dynamic;
    
    public function new()
    {
    }
    
    public function initEncrypt(password                            : Dynamic, header                            : Dynamic) : Void
    {
        var crc32                            : Dynamic= header._crc32;
        _outBytes = new ByteArray();
        _initEncrypt(password, crc32);
        
        header._compressSize += CRYPTHEADLEN;
    }
    
    /**
		 *  ?????????????
		 *
		 */
    private function _initEncrypt(password                            : Dynamic, crc32                            : Dynamic) : Void
    {
        crc32 = crc32 >> 24;
        
        var ret                            : Dynamic= _outBytes;
        _key = [];
        as3hx.Compat.setArrayLength(_key, 3);
        _key[0] = S_KEY1;
        _key[1] = S_KEY2;
        _key[2] = S_KEY3;
        
        password.position = 0;
        while (as3hx.Compat.truthy(password.bytesAvailable > 0))
        {
            var n                            : Dynamic= password.readUnsignedByte();
            updateKeys(n);
        }
        
        var d                            : Dynamic= null;
        for (i in 0...CRYPTHEADLEN)
        {
            if (as3hx.Compat.truthy(i == CRYPTHEADLEN - 1))
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
    public function encrypt(data                            : Dynamic) : ByteArray
    {
        data.position = 0;
        while (as3hx.Compat.truthy(data.bytesAvailable))
        {
            var n                            : Dynamic= data.readUnsignedByte();
            _outBytes.writeByte(zencode(n));
        }
        _outBytes.position = 0;
        
        return _outBytes;
    }
    
    public function checkDecrypt(entry                            : Dynamic) : Bool
    {
        return true;
    }
    
    public function initDecrypt(password                            : Dynamic, header                            : Dynamic) : Void
    {
        this._password = password;
        this._header = header;
    }
    
    public function decrypt(data                            : Dynamic) : ByteArray
    {
        var check1                            : Dynamic= _header._crc32 >>> 24;
        var cryptoHeader                            : Dynamic= new ByteArray();
        data.readBytes(cryptoHeader, 0, CRYPTHEADLEN);
        var check2                            : Dynamic= _initDecrypt(this._password, cryptoHeader);
        check2 = as3hx.Compat.parseInt(check2 & 0xffff);
        if (as3hx.Compat.truthy(check1 == check2))
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
    private function _initDecrypt(password                            : Dynamic, cryptHeader                            : Dynamic) : Int
    {
        var ret                            : Dynamic= new ByteArray();
        _key = [];
        as3hx.Compat.setArrayLength(_key, 3);
        _key[0] = S_KEY1;
        _key[1] = S_KEY2;
        _key[2] = S_KEY3;
        
        password.position = 0;
        
        while (as3hx.Compat.truthy(password.bytesAvailable > 0))
        {
            var n                            : Dynamic= password.readUnsignedByte();
            updateKeys(n);
        }
        cryptHeader.position = 0;
        var b             : Dynamic= 0;
        var b              : Dynamic= 0;
        var b               : Dynamic= 0;
        var b                : Dynamic= 0;
        var b                 : Dynamic= 0;
        var b                  : Dynamic= 0;
        var b                   : Dynamic= 0;
        var b                    : Dynamic= 0;
        var b                     : Dynamic= 0;
        var b                      : Dynamic= 0;
        var b                       : Dynamic= 0;
        var b                        : Dynamic= 0;
        var b                         : Dynamic= 0;
        var b                          : Dynamic= 0;
        var b                           : Dynamic= 0;
        
        for (i in 0...CRYPTHEADLEN)
        {
            var b                            : Dynamic= cryptHeader.readUnsignedByte();
            b = zdecode(b);
        }
        return as3hx.Compat.parseInt(b);
    }
    
    /**
		 *  ????
		 *
		 */
    private function _decrypt(data                            : Dynamic) : ByteArray
    {
        var out                            : Dynamic= new ByteArray();
        while (as3hx.Compat.truthy(data.bytesAvailable > 0))
        {
            var n                            : Dynamic= data.readUnsignedByte();
            n = zdecode(n);
            out.writeByte(n);
        }
        out.position = 0;
        return out;
    }
    
    /**
		 *  ???
		 */
    public function zdecode(n                            : Dynamic) : Int
    {
        var t                            : Dynamic= n;
        
        var d                            : Dynamic= decryptByte();
        n = n ^ d;
        updateKeys(n);
        return n;
    }
    
    /**
		 *  ???
		 */
    public function zencode(n                            : Dynamic) : Int
    {
        var t                            : Dynamic= decryptByte();
        updateKeys(n);
        return as3hx.Compat.parseInt(t ^ n);
    }
    
    /**
		 *
		 *  @return unsigned char
		 */
    public function decryptByte() : Int
    {
        var temp                            : Dynamic= as3hx.Compat.parseInt(_key[2] & 0xFFFF) | 2;
        var ret                        : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(temp * (temp ^ 1)) >> 8) & 0xFF;
        return ret;
    }
    
    /**
		 *
		 *
		 */
    public function updateKeys(uchar                            : Dynamic) : Void
    {
        _key[0] = ZipCRC32.getCRC32(_key[0], uchar);
        _key[1] = _key[1] + (_key[0] & 0xFF);
        
        //  ???2????????????Number??????????????????????
        var k2                            : Dynamic= _key[1];
        var b1                            : Dynamic= 134775000;
        var b2                            : Dynamic= 813;
        var t                            : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(k2 * b1) + as3hx.Compat.parseInt(k2 * b2) + 1);
        _key[1] = t;
        
        var k3                            : Dynamic= _key[1];
        
        var tmp                            : Dynamic= _key[1] >> 24;
        _key[2] = as3hx.Compat.parseInt(ZipCRC32.getCRC32(_key[2], tmp));
    }
}
