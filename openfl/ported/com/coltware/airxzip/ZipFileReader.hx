/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import openfl.errors.Error;
import com.coltware.airxzip.crypt.ICrypto;
import com.coltware.airxzip.crypt.ZipCrypto;
import openfl.events.*;
import r3.air.filesystem.*;
import openfl.utils.*;

/**
	 *  ZIP????????????
	 */
class ZipFileReader extends EventDispatcher
{
    
    private var _file                            : Dynamic;  //	Zip????  
    private var _stream                            : Dynamic;
    
    private var _charset                            : Dynamic= "shift_jis";
    
    /*  ????? */
    
    //public static var LOAD_ZIPFILE                           : Dynamic= "loadZipFile";
    
    private var _unzipStack                            : Dynamic;
    private var _unzipWorking                            : Dynamic= false;
    private var _unzipNum                            : Dynamic= 0;
    
    private var _endRecord                            : Dynamic;
    private var _entries                            : Dynamic;
    private var _totalEntries                            : Dynamic= 0;
    
    private var _decryptors                            : Dynamic;
    
    /* ???????????????? */
    private var _password                            : Dynamic;
    
    /**
		 *  dataAsync()??????????????????????????????
		 *
		 * @eventType com.coltware.airxzip.ZipEvent.ZIP_DATA_UNCOMPRESS
		 */
    @:meta(Event(name="zipDataUncompress",type="com.coltware.airxzip.ZipEvent"))

    
    public function new()
    {
        super();
        _stream = new FileStream();
        _stream.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        _unzipStack = new Array<Dynamic>();
        _entries = new Array<Dynamic>();
        _decryptors = new Array<Dynamic>();
    }
    
    /**
		 *  ?????ZIP??????????
		 *
		 * ??:??????0x04034b50??????????
		 */
    public function check(file                            : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(file.isDirectory))
        {
            return false;
        }
        else if (as3hx.Compat.truthy(file.isSymbolicLink))
        {
            return false;
        }
        else
        {
            try
            {
                var s                            : Dynamic= new FileStream();
                s.open(file, FileMode.READ);
                s.endian = Endian.LITTLE_ENDIAN;
                s.position = 0;
                var i                            : Dynamic= s.readInt();
                s.close();
                if (as3hx.Compat.truthy(i == ZipHeader.HEADER_LOCAL_FILE))
                {
                    return true;
                }
            }
            catch (err : Error)
            {
                return false;
            }
            return false;
        }
    }
    
    /**
		 * ????????????
		 *
		 */
    public function open(file                            : Dynamic) : Void
    {
        _file = file;
        _stream.open(_file, FileMode.READ);
        
        _stream.endian = Endian.LITTLE_ENDIAN;
        
        _stream.position = _stream.bytesAvailable - ZipEndRecord.LENGTH;
        var pos                            : Dynamic= 0;
        var sig                            : Dynamic= 0;
        while (as3hx.Compat.truthy(_stream.position > 0))
        {
            pos = _stream.position;
            sig = _stream.readInt();
            if (as3hx.Compat.truthy(sig == ZipEndRecord.SIGNATURE))
            {
                _endRecord = new ZipEndRecord();
                _stream.position = pos;
                _endRecord.read(_stream);
                //_endRecord.dumpLogInfo();
                
                _entries = new Array<Dynamic>();
                _totalEntries = _endRecord.getTotalEntries();
                
                break;
            }
            _stream.position = pos - 1;
        }
    }
    
    public function close() : Void
    {
        if (as3hx.Compat.truthy(_stream != null))
        {
            _stream.close();
        }
    }
    
    /**
		 *   Add decrypto instance
		 */
    public function addDecrypto(crypto                            : Dynamic) : Void
    {
        this._decryptors.push(crypto);
    }
    
    public function setPasswordBytes(bytes                            : Dynamic) : Void
    {
        this._password = bytes;
        this._password.position = 0;
    }
    
    /**
		 *  ??????????????
		 */
    public function setPassword(password                            : Dynamic, charset                            : Dynamic= null) : Void
    {
        var ba                            : Dynamic= new ByteArray();
        if (as3hx.Compat.truthy(charset == null))
        {
            ba.writeUTFBytes(password);
        }
        else
        {
            ba.writeMultiByte(password, charset);
        }
        this._password = ba;
        this._password.position = 0;
    }
    
    /**
		 *  Zip????????????????????
		 *
		 */
    public function getEntries() : Array<Dynamic>
    {
        parseCentralHeaders();
        return _entries;
    }
    
    /**
		 *
		 *  ????ByteArray?????
		 *
		 */
    public function unzip(entry                            : Dynamic) : ByteArray
    {
        var pos                            : Dynamic= entry.getLocalHeaderOffset();
        
        _stream.position = pos;
        var lzh                            : Dynamic= new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes                            : Dynamic= new ByteArray();
        var size                            : Dynamic= entry.getCompressSize();
        if (as3hx.Compat.truthy(size > 0))
        {
            _stream.readBytes(bytes, 0, entry.getCompressSize());
        }
        
        if (as3hx.Compat.truthy(entry.isEncrypted()))
        {
            if (as3hx.Compat.truthy(this._password == null))
            {
                throw new ZipError("password is NULL");
            }
            
            var decrypt                            : Dynamic= null;
            var i                            : Dynamic= 0;
            while (as3hx.Compat.truthy(i < _decryptors.length && decrypt == null)) {
                var _decrypt                            : Dynamic= _decryptors[i];
                if (as3hx.Compat.truthy(_decrypt.checkDecrypt(entry))) {
                    decrypt = _decrypt;
                }
                i++;
            }
            if (as3hx.Compat.truthy(decrypt == null))
            {
                decrypt = new ZipCrypto();
            }
            decrypt.initDecrypt(this._password, lzh);
            bytes = decrypt.decrypt(bytes);
        }
        
        var method                            : Dynamic= entry.getCompressMethod();
        if (as3hx.Compat.truthy(method == ZipEntry.METHOD_NONE))
        {
        }
        else if (as3hx.Compat.truthy(method == ZipEntry.METHOD_DEFLATE))
        {
            bytes.uncompress(CompressionAlgorithm.DEFLATE);
        }
        else
        {
            throw new ZipError("not support compress method : " + method);
        }
        return bytes;
    }
    
    /**
		 *  ????????????????
		 *
		 */
    public function rawdata(entry                            : Dynamic) : ByteArray
    {
        var pos                            : Dynamic= entry.getLocalHeaderOffset();
        _stream.position = pos;
        var lzh                            : Dynamic= new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes                            : Dynamic= new ByteArray();
        var size                            : Dynamic= entry.getCompressSize();
        if (as3hx.Compat.truthy(size > 0))
        {
            _stream.readBytes(bytes, 0, entry.getCompressSize());
        }
        bytes.position = 0;
        return bytes;
    }
    
    /**
		 *  ????????????????
		 *
		 *	@eventType com.coltware.airxzip.ZipEvent.ZIP_DATA_UNCOMPRESS
		 *
		 */
    public function unzipAsync(entry                            : Dynamic) : Void
    {
        this._unzipStack.push(entry);
        if (as3hx.Compat.truthy(_unzipWorking == false))
        {
            this.execUnzip(1000);
        }
    }
    
    private function unzipAsyncTimeout(entry                            : Dynamic) : Void
    {
        var event                            : Dynamic= new ZipEvent(ZipEvent.ZIP_DATA_UNCOMPRESS);
        var pos                            : Dynamic= entry.getLocalHeaderOffset();
        _stream.position = pos;
        _stream.position = pos;
        var lzh                            : Dynamic= new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes                            : Dynamic= new ByteArray();
        var size                            : Dynamic= entry.getCompressSize();
        if (as3hx.Compat.truthy(size > 0))
        {
            _stream.readBytes(bytes, 0, size);
        }
        
        var err                            : Dynamic= null;
        
        if (as3hx.Compat.truthy(entry.isEncrypted()))
        {
            if (as3hx.Compat.truthy(this._password == null))
            {
                err = new ZipErrorEvent(ZipErrorEvent.ZIP_PASSWORD_ERROR);
                this.dispatchEvent(err);
                return;
            }
            
            var decrypt                            : Dynamic= null;
            var i                            : Dynamic= 0;
            while (as3hx.Compat.truthy(i < _decryptors.length && decrypt == null)) {
                var _decrypt                            : Dynamic= _decryptors[i];
                if (as3hx.Compat.truthy(_decrypt.checkDecrypt(entry))) {
                    decrypt = _decrypt;
                }
                i++;
            }
            if (as3hx.Compat.truthy(decrypt == null))
            {
                decrypt = new ZipCrypto();
            }
            decrypt.initDecrypt(this._password, lzh);
            
            try
            {
                bytes = decrypt.decrypt(bytes);
            }
            catch (ze : ZipError)
            {
                err = new ZipErrorEvent(ZipErrorEvent.ZIP_PASSWORD_ERROR);
                this.dispatchEvent(err);
            }
        }
        
        var method                            : Dynamic= entry.getCompressMethod();
        if (as3hx.Compat.truthy(method == ZipEntry.METHOD_NONE))
        {
        }
        else if (as3hx.Compat.truthy(method == ZipEntry.METHOD_DEFLATE))
        {
            event.__DOLLAR__method = CompressionAlgorithm.DEFLATE;
        }
        else
        {
            var e                            : Dynamic= new ZipErrorEvent(ZipErrorEvent.ZIP_NO_SUCH_METHOD);
            this.dispatchEvent(e);
            return;
        }
        
        event.__DOLLAR__entry = entry;
        event.__DOLLAR__data = bytes;
        this.dispatchEvent(event);
        _unzipWorking = false;
        _unzipNum++;
        
        execUnzip();
    }
    
    private function execUnzip(delay                            : Dynamic= 10) : Void
    {
        if (as3hx.Compat.truthy(_unzipStack.length > 0))
        {
            _unzipWorking = true;
            var entry                            : Dynamic= _unzipStack.shift();
            as3hx.Compat.setTimeout(unzipAsyncTimeout, delay, [entry]);
        }
        else
        {
        }
    }
    
    private function ioError(e                            : Dynamic) : Void
    {
        this.dispatchEvent(e);
    }
    
    public function parseCentralHeaders() : Void
    {
        var offset                            : Dynamic= _endRecord.getOffset();
        var size                            : Dynamic= _endRecord.getSize();
        _stream.position = offset;
        var bytes                            : Dynamic= new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;
        _stream.readBytes(bytes, 0, size);
        bytes.position = 0;
        
        var _tmpBytes                            : Dynamic= new ByteArray();
        _tmpBytes.endian = Endian.LITTLE_ENDIAN;
        
        while (as3hx.Compat.truthy(bytes.bytesAvailable))
        {
            var sig                            : Dynamic= bytes.readInt();
            var header                            : Dynamic= new ZipHeader(sig);
            header.read(bytes, _tmpBytes);
            var entry                            : Dynamic= new ZipEntry(_stream);
            entry.setHeader(header);
            _entries.push(entry);
        }
    }
    
    private function readStream(e                            : Dynamic) : Void
    //trace("byte available " + _stream.bytesAvailable + "/" + _file.size);
    {
        
        var bytes                            : Dynamic= new ByteArray();
        _stream.endian = Endian.LITTLE_ENDIAN;
        bytes.endian = Endian.LITTLE_ENDIAN;
        while (as3hx.Compat.truthy(_stream.bytesAvailable)) {
var sig                            : Dynamic= _stream.readInt();
            if (as3hx.Compat.truthy(sig == ZipHeader.HEADER_LOCAL_FILE)) {
var header                            : Dynamic= new ZipHeader(sig);
                header.read(_stream, bytes);
                
                var contentByteArray                            : Dynamic= new ByteArray();
                if (as3hx.Compat.truthy(header.getCompressSize() > 0))
                {
                    _stream.readBytes(contentByteArray, 0, header.getCompressSize());
                }
                var entry                            : Dynamic= new ZipEntry(_stream);
                entry.setHeader(header);
            }
            else if (as3hx.Compat.truthy(sig == ZipHeader.HEADER_CENTRAL_DIR)) {
var centralHeader                            : Dynamic= new ZipHeader(sig);
                centralHeader.read(_stream, bytes);
            }
            //trace("sig NG " + sig.toString(16));
            else
            {
                
                break;
            }
        }
    }
}
