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
    
    private var _file : File;  //	Zip????  
    private var _stream : FileStream;
    
    private var _charset : String = "shift_jis";
    
    /*  ????? */
    
    //public static var LOAD_ZIPFILE:String = "loadZipFile";
    
    private var _unzipStack : Array<Dynamic>;
    private var _unzipWorking : Bool = false;
    private var _unzipNum : Int = 0;
    
    private var _endRecord : ZipEndRecord;
    private var _entries : Array<Dynamic>;
    private var _totalEntries : Int = 0;
    
    private var _decryptors : Array<Dynamic>;
    
    /* ???????????????? */
    private var _password : ByteArray;
    
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
    public function check(file : File) : Bool
    {
        if (file.isDirectory)
        {
            return false;
        }
        else if (file.isSymbolicLink)
        {
            return false;
        }
        else
        {
            try
            {
                var s : FileStream = new FileStream();
                s.open(file, FileMode.READ);
                s.endian = Endian.LITTLE_ENDIAN;
                s.position = 0;
                var i : Int = s.readInt();
                s.close();
                if (i == ZipHeader.HEADER_LOCAL_FILE)
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
    public function open(file : File) : Void
    {
        _file = file;
        _stream.open(_file, FileMode.READ);
        
        _stream.endian = Endian.LITTLE_ENDIAN;
        
        _stream.position = _stream.bytesAvailable - ZipEndRecord.LENGTH;
        var pos : Int = 0;
        var sig : Int = 0;
        while (_stream.position > 0)
        {
            pos = _stream.position;
            sig = _stream.readInt();
            if (sig == ZipEndRecord.SIGNATURE)
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
        if (_stream != null)
        {
            _stream.close();
        }
    }
    
    /**
		 *   Add decrypto instance
		 */
    public function addDecrypto(crypto : ICrypto) : Void
    {
        this._decryptors.push(crypto);
    }
    
    public function setPasswordBytes(bytes : ByteArray) : Void
    {
        this._password = bytes;
        this._password.position = 0;
    }
    
    /**
		 *  ??????????????
		 */
    public function setPassword(password : String, charset : String = null) : Void
    {
        var ba : ByteArray = new ByteArray();
        if (charset == null)
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
    public function unzip(entry : ZipEntry) : ByteArray
    {
        var pos : Int = entry.getLocalHeaderOffset();
        
        _stream.position = pos;
        var lzh : ZipHeader = new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes : ByteArray = new ByteArray();
        var size : Int = entry.getCompressSize();
        if (size > 0)
        {
            _stream.readBytes(bytes, 0, entry.getCompressSize());
        }
        
        if (entry.isEncrypted())
        {
            if (this._password == null)
            {
                throw new ZipError("password is NULL");
            }
            
            var decrypt : ICrypto = null;
            var i : Int = 0;
            while (i < _decryptors.length && decrypt == null) {
                var _decrypt : ICrypto = _decryptors[i];
                if (_decrypt.checkDecrypt(entry)) {
                    decrypt = _decrypt;
                }
                i++;
            }
            if (decrypt == null)
            {
                decrypt = new ZipCrypto();
            }
            decrypt.initDecrypt(this._password, lzh);
            bytes = decrypt.decrypt(bytes);
        }
        
        var method : Int = entry.getCompressMethod();
        if (method == ZipEntry.METHOD_NONE)
        {
        }
        else if (method == ZipEntry.METHOD_DEFLATE)
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
    public function rawdata(entry : ZipEntry) : ByteArray
    {
        var pos : Int = entry.getLocalHeaderOffset();
        _stream.position = pos;
        var lzh : ZipHeader = new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes : ByteArray = new ByteArray();
        var size : Int = entry.getCompressSize();
        if (size > 0)
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
    public function unzipAsync(entry : ZipEntry) : Void
    {
        this._unzipStack.push(entry);
        if (_unzipWorking == false)
        {
            this.execUnzip(1000);
        }
    }
    
    private function unzipAsyncTimeout(entry : ZipEntry) : Void
    {
        var event : ZipEvent = new ZipEvent(ZipEvent.ZIP_DATA_UNCOMPRESS);
        var pos : Int = entry.getLocalHeaderOffset();
        _stream.position = pos;
        _stream.position = pos;
        var lzh : ZipHeader = new ZipHeader();
        lzh.readAuto(_stream);
        entry._headerLocal = lzh;
        
        var bytes : ByteArray = new ByteArray();
        var size : Int = entry.getCompressSize();
        if (size > 0)
        {
            _stream.readBytes(bytes, 0, size);
        }
        
        var err : ZipErrorEvent;
        
        if (entry.isEncrypted())
        {
            if (this._password == null)
            {
                err = new ZipErrorEvent(ZipErrorEvent.ZIP_PASSWORD_ERROR);
                this.dispatchEvent(err);
                return;
            }
            
            var decrypt : ICrypto = null;
            var i : Int = 0;
            while (i < _decryptors.length && decrypt == null) {
                var _decrypt : ICrypto = _decryptors[i];
                if (_decrypt.checkDecrypt(entry)) {
                    decrypt = _decrypt;
                }
                i++;
            }
            if (decrypt == null)
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
        
        var method : Int = entry.getCompressMethod();
        if (method == ZipEntry.METHOD_NONE)
        {
        }
        else if (method == ZipEntry.METHOD_DEFLATE)
        {
            event.__DOLLAR__method = CompressionAlgorithm.DEFLATE;
        }
        else
        {
            var e : ZipErrorEvent = new ZipErrorEvent(ZipErrorEvent.ZIP_NO_SUCH_METHOD);
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
    
    private function execUnzip(delay : Int = 10) : Void
    {
        if (_unzipStack.length > 0)
        {
            _unzipWorking = true;
            var entry : ZipEntry = _unzipStack.shift();
            as3hx.Compat.setTimeout(unzipAsyncTimeout, delay, [entry]);
        }
        else
        {
        }
    }
    
    private function ioError(e : Event) : Void
    {
        this.dispatchEvent(e);
    }
    
    private function parseCentralHeaders() : Void
    {
        var offset : Int = _endRecord.getOffset();
        var size : Int = _endRecord.getSize();
        _stream.position = offset;
        var bytes : ByteArray = new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;
        _stream.readBytes(bytes, 0, size);
        bytes.position = 0;
        
        var _tmpBytes : ByteArray = new ByteArray();
        _tmpBytes.endian = Endian.LITTLE_ENDIAN;
        
        while (bytes.bytesAvailable)
        {
            var sig : Int = bytes.readInt();
            var header : ZipHeader = new ZipHeader(sig);
            header.read(bytes, _tmpBytes);
            var entry : ZipEntry = new ZipEntry(_stream);
            entry.setHeader(header);
            _entries.push(entry);
        }
    }
    
    private function readStream(e : Event) : Void
    //trace("byte available " + _stream.bytesAvailable + "/" + _file.size);
    {
        
        var bytes : ByteArray = new ByteArray();
        _stream.endian = Endian.LITTLE_ENDIAN;
        bytes.endian = Endian.LITTLE_ENDIAN;
        while (_stream.bytesAvailable) {
var sig : Int = _stream.readInt();
            if (sig == ZipHeader.HEADER_LOCAL_FILE) {
var header : ZipHeader = new ZipHeader(sig);
                header.read(_stream, bytes);
                
                var contentByteArray : ByteArray = new ByteArray();
                if (header.getCompressSize() > 0)
                {
                    _stream.readBytes(contentByteArray, 0, header.getCompressSize());
                }
                var entry : ZipEntry = new ZipEntry(_stream);
                entry.setHeader(header);
            }
            else if (sig == ZipHeader.HEADER_CENTRAL_DIR) {
var centralHeader : ZipHeader = new ZipHeader(sig);
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
