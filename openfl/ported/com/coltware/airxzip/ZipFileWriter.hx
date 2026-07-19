/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import com.coltware.airxzip.crypt.ICrypto;
import com.coltware.airxzip.crypt.ZipCrypto;
import openfl.events.*;
import r3.air.filesystem.*;
import openfl.system.*;
import openfl.utils.*;

@:meta(Event(name="zipDataCompress",type="com.coltware.airxzip.ZipEvent"))

@:meta(Event(name="zipFileCreated",type="com.coltware.airxzip.ZipEvent"))

/**
 *
 *  ZIP????????????
 *
 */
class ZipFileWriter extends EventDispatcher
{
    private var _headers                            : Dynamic;
    private var _endRecord                            : Dynamic;
    
    private var _stream                            : Dynamic;
    private var _filenameEncoding                            : Dynamic= "utf-8";
    private var _numFiles                            : Dynamic= 0;
    private var _host                            : Dynamic= 0;
    
    public static var HOST_WIN                            : Dynamic= "WIN";
    public static var HOST_UNIX                            : Dynamic= "UNIX";
    
    private var _dirMode                            : Dynamic= as3hx.Compat.parseInt("0770");
    private var _fileMode                            : Dynamic= as3hx.Compat.parseInt("0640");
    
    private var _async                            : Dynamic= false;
    private var _zipStack                            : Dynamic;
    private var _zipWorking                            : Dynamic= false;
    
    /* ???????????????? */
    private var _password                            : Dynamic;
    private var _isCrypt                            : Dynamic= false;
    private var _crypt                            : Dynamic;
    
    public function new(hostType                            : Dynamic= "WIN")
    {
        super();
        _headers = new Array<Dynamic>();
        
        if (as3hx.Compat.truthy(hostType == HOST_WIN))
        {
            if (as3hx.Compat.truthy(Capabilities.language == "ja"))
            {
                if (as3hx.Compat.truthy(Capabilities.version.indexOf("WIN") != -1))
                {
                    _filenameEncoding = "shift_jis";
                }
            }
            _host = 0;
        }
        else if (as3hx.Compat.truthy(hostType == HOST_UNIX))
        {
            _host = 3;
        }
        
        _crypt = new ZipCrypto();
    }
    
    public function setCrypto(crypto                            : Dynamic) : Void
    {
        this._crypt = crypto;
    }
    
    public function setPasswordBytes(bytes                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(bytes != null))
        {
            this._password = bytes;
            this._password.position = 0;
            this._isCrypt = true;
        }
        else
        {
            this._isCrypt = false;
        }
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
        
        this._isCrypt = true;
    }
    
    /**
     *  UNIX???????????????????????????????
     *
     *  "0775"????8???????????
     *
     */
    public function setDirMode(mode                            : Dynamic) : Void
    {
        _dirMode = as3hx.Compat.parseInt(mode);
    }
    
    /**
     *
     *  UNIX?????????????????????????
     *
     *  "0665" ????8???????????
     *
     */
    public function setFileMode(mode                            : Dynamic) : Void
    {
        _fileMode = as3hx.Compat.parseInt(mode);
    }
    
    /**
     *  ZIP?????????????
     *
     *  ????????????????????
     */
    public function open(file                            : Dynamic) : Void
    {
        _stream = new FileStream();
        _stream.open(file, FileMode.WRITE);
        _stream.endian = Endian.LITTLE_ENDIAN;
        _stream.position = 0;
    }
    
    /**
     * ZIP???????????????????????????
     *
     * ??:???????????????????
     * open???????????
     */
    public function openAsync(file                            : Dynamic) : Void
    {
        _async = true;
        _zipStack = new Array<Dynamic>();
        open(file);
    }
    
    /**
     *  File?zip??????????
     *
     *  ??:????????????????
     */
    public function addFile(file                            : Dynamic, filename                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_async))
        {
            var task                            : Dynamic= {};
            task.type = "file";
            task.file = file;
            task.filename = filename;
            _zipStack.push(task);
            execZip();
        }
        else
        {
            var fs                            : Dynamic= new FileStream();
            fs.open(file, FileMode.READ);
            var bytes                            : Dynamic= new ByteArray();
            fs.readBytes(bytes, 0, file.size);
            fs.close();
            this.internalAddBytes(false, filename, bytes, file.modificationDate);
        }
    }
    
    /**
     *  ByteArray????zip??????????
     */
    public function addBytes(bytes                            : Dynamic, filename                            : Dynamic, date                            : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(_async))
        {
            var task                            : Dynamic= {};
            task.type = "bytes";
            task.filename = filename;
            task.bytes = bytes;
            task.date = date;
            _zipStack.push(task);
            execZip();
        }
        else
        {
            this.internalAddBytes(false, filename, bytes, date);
        }
    }
    
    /**
     *  ?????????????
     */
    public function addDirectory(filename                            : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(filename.charAt(filename.length - 1) != "/"))
        {
            filename += "/";
        }
        if (as3hx.Compat.truthy(_async))
        {
            var task                            : Dynamic= {};
            task.type = "dir";
            task.filename = filename;
            _zipStack.push(task);
            execZip();
        }
        else
        {
            this.internalAddBytes(true, filename);
        }
    }
    
    /**
     *  ZipFileWriter?close??.
     *
     *  ???????????????????????????????
     */
    public function close() : Void
    {
        if (as3hx.Compat.truthy(_async))
        {
            var task                            : Dynamic= {};
            task.type = "close";
            _zipStack.push(task);
            execZip();
        }
        else
        {
            execClose();
        }
    }
    
    private function execClose() : Void
    {
        var len                            : Dynamic= _headers.length;
        var pos1                            : Dynamic= _stream.position;
        for (i in 0...len)
        {
            var header                            : Dynamic= try cast(_headers[i], ZipHeader) catch(e:Dynamic) null;
            header.writeCentralHeader(_stream);
        }
        var pos2                            : Dynamic= _stream.position;
        
        _endRecord = new ZipEndRecord();
        _endRecord.write(_stream, _numFiles, pos1, pos2 - pos1);
        _stream.close();
    }
    
    private function execZip(delay                            : Dynamic= 10) : Void
    {
        if (as3hx.Compat.truthy(_zipStack.length > 0 && _zipWorking == false))
        {
            _zipWorking = true;
            var task                            : Dynamic= _zipStack.shift();
            as3hx.Compat.setTimeout(zipAsyncTimeout, delay, [task]);
        }
    }
    
    private function zipAsyncTimeout(task                            : Dynamic) : Void
    {
        var filename                            : Dynamic= null;
        var bytes                            : Dynamic= null;
        var zipHeader                            : Dynamic= null;
        if (as3hx.Compat.truthy(task.type == "file"))
        {
            var file                            : Dynamic= task.file;
            filename = task.filename;
            var fs                            : Dynamic= new FileStream();
            fs.open(file, FileMode.READ);
            bytes = new ByteArray();
            fs.readBytes(bytes, 0, file.size);
            fs.close();
            zipHeader = this.internalAddBytes(false, filename, bytes, file.modificationDate);
        }
        else if (as3hx.Compat.truthy(task.type == "bytes"))
        {
            filename = task.filename;
            bytes = task.bytes;
            var date                            : Dynamic= task.date;
            zipHeader = this.internalAddBytes(false, filename, bytes, date);
        }
        else if (as3hx.Compat.truthy(task.type == "dir"))
        {
            zipHeader = this.internalAddBytes(true, task.filename);
        }
        else if (as3hx.Compat.truthy(task.type == "close"))
        {
            execClose();
        }
        
        if (as3hx.Compat.truthy(task.type == "close"))
        {
            var end                            : Dynamic= new ZipEvent(ZipEvent.ZIP_FILE_CREATED);
            this.dispatchEvent(end);
        }
        else if (as3hx.Compat.truthy(zipHeader != null))
        {
            var zip                            : Dynamic= new ZipEvent(ZipEvent.ZIP_DATA_COMPRESS);
            zip.__DOLLAR__entry = new ZipEntry(_stream);
            zip.__DOLLAR__entry.setHeader(zipHeader);
            this.dispatchEvent(zip);
        }
        
        _zipWorking = false;
        execZip();
    }
    
    /**
     *
     * @private
     */
    private function internalAddBytes(isDir                            : Dynamic, filename                            : Dynamic, data                            : Dynamic= null, date                            : Dynamic= null) : ZipHeader
    {
        if (as3hx.Compat.truthy(date == null))
        {
            date = Date.now();
        }
        
        var header                            : Dynamic= new ZipHeader();
        
        header._lastModTime = as3hx.Compat.parseInt(date.getSeconds()) | (as3hx.Compat.parseInt(date.getMinutes()) << 5) | (as3hx.Compat.parseInt(date.getHours()) << 11);
        header._lastModDate = as3hx.Compat.parseInt(date.getDate()) | (as3hx.Compat.parseInt(date.getMonth() + 1) << 5) | (as3hx.Compat.parseInt(date.getFullYear() - 1980) << 9);
        
        var filenameBytes                            : Dynamic= new ByteArray();
        filenameBytes.writeMultiByte(filename, _filenameEncoding);
        header._filename = filenameBytes;
        header._filenameLength = filenameBytes.length;
        
        header._extraFieldLength = 0;
        
        //  ?????????????
        if (as3hx.Compat.truthy(_isCrypt))
        {
            header._bitFlag = 0x1;
        }
        else
        {
            header._bitFlag = 0;
        }
        
        /****  ???? CENTRAL ********/
        //  ????
        header._commentLength = 0;
        
        header._diskNumber = 0;
        
        header._internalFileAttrs = 0;
        header._externalFileAttrs = 0;
        header._offsetLocalHeader = _stream.position;
        
        if (as3hx.Compat.truthy(isDir))
        {
            header._compressMethod = 0;
            header._version = 10;
            header._versionBy = (_host << 8 | 10);
            header._crc32 = 0;
            header._compressSize = 0;
            header._uncompressSize = 0;
            if (as3hx.Compat.truthy(_host == 3))
            {
                header._externalFileAttrs = ((ZipHeader.UNIX_DIR | _dirMode) << 16) + ZipHeader.WIN_DIR;
            }
            else
            {
                header._externalFileAttrs = ZipHeader.WIN_DIR;
            }
        }
        else if (as3hx.Compat.truthy(data.length == 0))
        {
            header._compressMethod = 0;
            header._version = 10;
            header._versionBy = (_host << 8 | 10);
            header._crc32 = 0;
            header._compressSize = 0;
            header._uncompressSize = 0;
            
            if (as3hx.Compat.truthy(_host == 3))
            {
                header._externalFileAttrs = ((ZipHeader.UNIX_FILE | _fileMode) << 16);
            }
            else
            {
                header._externalFileAttrs = ZipHeader.WIN_FILE;
            }
        }
        else
        {
            header._compressMethod = 8;
            header._version = 20;
            header._versionBy = (_host << 8 | 20);
            header._crc32 = ZipCRC32.getByteArrayValue(data);
            header._uncompressSize = data.length;
            data.compress(CompressionAlgorithm.DEFLATE);
            header._compressSize = data.length;
            
            if (as3hx.Compat.truthy(_host == 3))
            {
                header._externalFileAttrs = ((ZipHeader.UNIX_FILE | _fileMode) << 16);
            }
            else
            {
                header._externalFileAttrs = ZipHeader.WIN_FILE;
            }
        }
        
        //  ??????????
        if (as3hx.Compat.truthy(isDir == false))
        {
            data.position = 0;
            if (as3hx.Compat.truthy(_isCrypt))
            {
                _crypt.initEncrypt(_password, header);
                header.writeLocalHeader(_stream);
                _stream.writeBytes(_crypt.encrypt(data));
            }
            else
            {
                header.writeLocalHeader(_stream);
                _stream.writeBytes(data);
            }
        }
        else
        {
            header.writeLocalHeader(_stream);
        }
        
        _headers.push(header);
        _numFiles++;
        return header;
    }
}

