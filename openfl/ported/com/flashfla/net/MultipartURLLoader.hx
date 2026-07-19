package com.flashfla.net;

import openfl.utils.ByteArray;

import openfl.errors.Error;
import com.flashfla.net.events.MultipartURLLoaderEvent;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;

import openfl.utils.Dictionary;
import openfl.utils.Endian;

/**
 * Multipart URL Loader
 *
 * Original idea by Marston Development Studio - http://marstonstudio.com/?p=36
 *
 * History
 * 2009.01.15 version 1.0
 * Initial release
 *
 * 2009.01.19 version 1.1
 * Added options for MIME-types (default is application/octet-stream)
 *
 * 2009.01.20 version 1.2
 * Added clearVariables and clearFiles methods
 * Small code refactoring
 * Public methods documentaion
 *
 * 2009.02.09 version 1.2.1
 * Changed 'useWeakReference' to false (thanx to zlatko)
 * It appears that on some servers setting 'useWeakReference' to true
 * completely disables this event
 *
 * 2009.03.05 version 1.3
 * Added Async property. Now you can prepare data asynchronous before sending it.
 * It will prevent flash player from freezing while constructing request data.
 * You can specify the amount of bytes to write per iteration through BLOCK_SIZE static property.
 * Added events for asynchronous method.
 * Added dataFormat property for returned server data.
 * Removed 'Cache-Control' from headers and added custom requestHeaders array property.
 * Added getter for the URLLoader class used to send data.
 *
 * 2010.02.23
 * Fixed issue 2 (loading failed if not directly dispatched from mouse event)
 * problem and fix reported by gbradley@rocket.co.uk
 *
 * @author Eugene Zatepyakin
 * @version 1.3
 * @link http://blog.inspirit.ru/
 */
class MultipartURLLoader extends EventDispatcher
{
    public var ASYNC(get, never) : Bool;
    public var PREPARED(get, never) : Bool;
    public var dataFormat(get, set) : String;
    public var loader(get, never) : URLLoader;

    public static var BLOCK_SIZE : Int = 64 * 1024;
    
    private var _loader : URLLoader;
    private var _boundary : String;
    private var _variableNames : Array<Dynamic>;
    private var _fileNames : Array<Dynamic>;
    private var _variables : Dictionary<Dynamic, Dynamic>;
    private var _files : Dictionary<Dynamic, Dynamic>;
    
    private var _async : Bool = false;
    private var _path : String;
    private var _data : ByteArray;
    
    private var _prepared : Bool = false;
    private var asyncWriteTimeoutId : Float;
    private var asyncFilePointer : Int = 0;
    private var totalFilesSize : Int = 0;
    private var writtenBytes : Int = 0;
    
    public var requestHeaders : Array<Dynamic>;
    
    public function new()
    {
        super();
        _fileNames = new Array<Dynamic>();
        _files = new Dictionary<Dynamic, Dynamic>();
        _variableNames = new Array<Dynamic>();
        _variables = new Dictionary<Dynamic, Dynamic>();
        _loader = new URLLoader();
        requestHeaders = new Array<Dynamic>();
    }
    
    /**
     * Start uploading data to specified path
     *
     * @param	path	The server script path
     * @param	async	Set to true if you are uploading huge amount of data
     */
    public function load(path : String, async : Bool = false) : Void
    {
        if (path == null || path == "")
        {
            throw new IllegalOperationError("You cant load without specifing PATH");
        }
        
        _path = path;
        _async = async;
        
        if (_async)
        {
            if (!_prepared)
            {
                constructPostDataAsync();
            }
            else
            {
                doSend();
            }
        }
        else
        {
            _data = constructPostData();
            doSend();
        }
    }
    
    /**
     * Start uploading data after async prepare
     */
    public function startLoad() : Void
    {
        if (_path == null || _path == "" || _async == false)
        {
            throw new IllegalOperationError("You can use this method only if loading asynchronous.");
        }
        if (!_prepared && _async)
        {
            throw new IllegalOperationError("You should prepare data before sending when using asynchronous.");
        }
        
        doSend();
    }
    
    /**
     * Prepare data before sending (only if you use asynchronous)
     */
    public function prepareData() : Void
    {
        constructPostDataAsync();
    }
    
    /**
     * Stop loader action
     */
    public function close() : Void
    {
        try
        {
            _loader.close();
        }
        catch (e : Error)
        {
        }
    }
    
    /**
     * Add string variable to loader
     * If you have already added variable with the same name it will be overwritten
     *
     * @param	name	Variable name
     * @param	value	Variable value
     */
    public function addVariable(name : String, value : Dynamic = "") : Void
    {
        if (Lambda.indexOf(_variableNames, name) == -1)
        {
            _variableNames.push(name);
        }
        Reflect.setField(_variables, name, value);
        _prepared = false;
    }
    
    /**
     * Add file part to loader
     * If you have already added file with the same fileName it will be overwritten
     *
     * @param	fileContent	File content encoded to ByteArray
     * @param	fileName	Name of the file
     * @param	dataField	Name of the field containg file data
     * @param	contentType	MIME type of the uploading file
     */
    public function addFile(fileContent : ByteArray, fileName : String, dataField : String = "Filedata", contentType : String = "application/octet-stream") : Void
    {
        if (Lambda.indexOf(_fileNames, fileName) == -1)
        {
            _fileNames.push(fileName);
            Reflect.setField(_files, fileName, new FilePart(fileContent, fileName, dataField, contentType));
            totalFilesSize += fileContent.length;
        }
        else
        {
            var f : FilePart = try cast(Reflect.field(_files, fileName), FilePart) catch(e:Dynamic) null;
            totalFilesSize -= f.fileContent.length;
            f.fileContent = fileContent;
            f.fileName = fileName;
            f.dataField = dataField;
            f.contentType = contentType;
            totalFilesSize += fileContent.length;
        }
        
        _prepared = false;
    }
    
    /**
     * Remove all variable parts
     */
    public function clearVariables() : Void
    {
        _variableNames = new Array<Dynamic>();
        _variables = new Dictionary<Dynamic, Dynamic>();
        _prepared = false;
    }
    
    /**
     * Remove all file parts
     */
    public function clearFiles() : Void
    {
        for (name in _fileNames)
        {
            (try cast(Reflect.field(_files, Std.string(name)), FilePart) catch(e:Dynamic) null).dispose();
        }
        _fileNames = new Array<Dynamic>();
        _files = new Dictionary<Dynamic, Dynamic>();
        totalFilesSize = 0;
        _prepared = false;
    }
    
    /**
     * Dispose all class instance objects
     */
    public function dispose() : Void
    {
        as3hx.Compat.clearInterval(asyncWriteTimeoutId);
        removeListener();
        close();
        
        _loader = null;
        _boundary = null;
        _variableNames = null;
        _variables = null;
        _fileNames = null;
        _files = null;
        requestHeaders = null;
        _data = null;
    }
    
    /**
     * Generate random boundary
     * @return	Random boundary
     */
    public function getBoundary() : String
    {
        if (_boundary == null)
        {
            _boundary = "";
            for (i in 0...0x20)
            {
                _boundary += String.fromCharCode(as3hx.Compat.parseInt(97 + Math.random() * 25));
            }
        }
        return _boundary;
    }
    
    private function get_ASYNC() : Bool
    {
        return _async;
    }
    
    private function get_PREPARED() : Bool
    {
        return _prepared;
    }
    
    private function get_dataFormat() : String
    {
        return _loader.dataFormat;
    }
    
    private function set_dataFormat(format : String) : String
    {
        if (format != URLLoaderDataFormat.BINARY && format != URLLoaderDataFormat.TEXT && format != URLLoaderDataFormat.VARIABLES)
        {
            throw new IllegalOperationError("Illegal URLLoader Data Format");
        }
        _loader.dataFormat = format;
        return format;
    }
    
    private function get_loader() : URLLoader
    {
        return _loader;
    }
    
    private function doSend() : Void
    {
        var urlRequest : URLRequest = new URLRequest();
        urlRequest.url = _path;
        //urlRequest.contentType = 'multipart/form-data; boundary=' + getBoundary();
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = _data;
        
        urlRequest.requestHeaders.push(new URLRequestHeader("Content-type", "multipart/form-data; boundary=" + getBoundary()));
        
        if (requestHeaders.length)
        {
            urlRequest.requestHeaders = urlRequest.requestHeaders.concat(requestHeaders);
        }
        
        addListener();
        
        _loader.load(urlRequest);
    }
    
    private function constructPostDataAsync() : Void
    {
        as3hx.Compat.clearInterval(asyncWriteTimeoutId);
        
        _data = new ByteArray();
        _data.endian = Endian.BIG_ENDIAN;
        
        _data = constructVariablesPart(_data);
        
        asyncFilePointer = 0;
        writtenBytes = 0;
        _prepared = false;
        if (_fileNames.length)
        {
            nextAsyncLoop();
        }
        else
        {
            _data = closeDataObject(_data);
            _prepared = true;
            dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE));
        }
    }
    
    private function constructPostData() : ByteArray
    {
        var postData : ByteArray = new ByteArray();
        postData.endian = Endian.BIG_ENDIAN;
        
        postData = constructVariablesPart(postData);
        postData = constructFilesPart(postData);
        
        postData = closeDataObject(postData);
        
        return postData;
    }
    
    private function closeDataObject(postData : ByteArray) : ByteArray
    {
        postData = cast((postData), BOUNDARY);
        postData = cast((postData), DOUBLEDASH);
        return postData;
    }
    
    private function constructVariablesPart(postData : ByteArray) : ByteArray
    {
        var i : Int;
        var bytes : String;
        
        for (name in _variableNames)
        {
            postData = cast((postData), BOUNDARY);
            postData = cast((postData), LINEBREAK);
            bytes = "Content-Disposition: form-data; name=\"" + name + "\"";
            for (i in 0...bytes.length)
            {
                postData.writeByte(bytes.charCodeAt(i));
            }
            postData = cast((postData), LINEBREAK);
            postData = cast((postData), LINEBREAK);
            postData.writeUTFBytes(Reflect.field(_variables, Std.string(name)));
            postData = cast((postData), LINEBREAK);
        }
        
        return postData;
    }
    
    private function constructFilesPart(postData : ByteArray) : ByteArray
    {
        var i : Int;
        var bytes : String;
        
        if (_fileNames.length)
        {
            for (name in _fileNames)
            {
                postData = getFilePartHeader(postData, try cast(Reflect.field(_files, Std.string(name)), FilePart) catch(e:Dynamic) null);
                postData = getFilePartData(postData, try cast(Reflect.field(_files, Std.string(name)), FilePart) catch(e:Dynamic) null);
                
                if (i != _fileNames.length - 1)
                {
                    postData = cast((postData), LINEBREAK);
                }
                i++;
            }
            postData = closeFilePartsData(postData);
        }
        
        return postData;
    }
    
    private function closeFilePartsData(postData : ByteArray) : ByteArray
    {
        var i : Int;
        var bytes : String;
        
        postData = cast((postData), LINEBREAK);
        postData = cast((postData), BOUNDARY);
        postData = cast((postData), LINEBREAK);
        bytes = "Content-Disposition: form-data; name=\"Upload\"";
        for (i in 0...bytes.length)
        {
            postData.writeByte(bytes.charCodeAt(i));
        }
        postData = cast((postData), LINEBREAK);
        postData = cast((postData), LINEBREAK);
        bytes = "Submit Query";
        for (i in 0...bytes.length)
        {
            postData.writeByte(bytes.charCodeAt(i));
        }
        postData = cast((postData), LINEBREAK);
        
        return postData;
    }
    
    private function getFilePartHeader(postData : ByteArray, part : FilePart) : ByteArray
    {
        var i : Int;
        var bytes : String;
        
        postData = cast((postData), BOUNDARY);
        postData = cast((postData), LINEBREAK);
        bytes = "Content-Disposition: form-data; name=\"Filename\"";
        for (i in 0...bytes.length)
        {
            postData.writeByte(bytes.charCodeAt(i));
        }
        postData = cast((postData), LINEBREAK);
        postData = cast((postData), LINEBREAK);
        postData.writeUTFBytes(part.fileName);
        postData = cast((postData), LINEBREAK);
        
        postData = cast((postData), BOUNDARY);
        postData = cast((postData), LINEBREAK);
        bytes = "Content-Disposition: form-data; name=\"" + part.dataField + "\"; filename=\"";
        for (i in 0...bytes.length)
        {
            postData.writeByte(bytes.charCodeAt(i));
        }
        postData.writeUTFBytes(part.fileName);
        postData = cast((postData), QUOTATIONMARK);
        postData = cast((postData), LINEBREAK);
        bytes = "Content-Type: " + part.contentType;
        for (i in 0...bytes.length)
        {
            postData.writeByte(bytes.charCodeAt(i));
        }
        postData = cast((postData), LINEBREAK);
        postData = cast((postData), LINEBREAK);
        
        return postData;
    }
    
    private function getFilePartData(postData : ByteArray, part : FilePart) : ByteArray
    {
        postData.writeBytes(part.fileContent, 0, part.fileContent.length);
        
        return postData;
    }
    
    private function onProgress(event : ProgressEvent) : Void
    {
        dispatchEvent(event);
    }
    
    private function onComplete(event : Event) : Void
    {
        removeListener();
        dispatchEvent(event);
    }
    
    private function onIOError(event : IOErrorEvent) : Void
    {
        removeListener();
        dispatchEvent(event);
    }
    
    private function onSecurityError(event : SecurityErrorEvent) : Void
    {
        removeListener();
        dispatchEvent(event);
    }
    
    private function onHTTPStatus(event : HTTPStatusEvent) : Void
    {
        dispatchEvent(event);
    }
    
    private function addListener() : Void
    {
        _loader.addEventListener(Event.COMPLETE, onComplete, false, 0, false);
        _loader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, false);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, false);
        _loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, false);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, false);
    }
    
    private function removeListener() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, onComplete);
        _loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
    }
    
    private function BOUNDARY(p : ByteArray) : ByteArray
    {
        var l : Int = getBoundary().length;
        p = cast((p), DOUBLEDASH);
        for (i in 0...l)
        {
            p.writeByte(_boundary.charCodeAt(i));
        }
        return p;
    }
    
    private function LINEBREAK(p : ByteArray) : ByteArray
    {
        p.writeShort(0x0d0a);
        return p;
    }
    
    private function QUOTATIONMARK(p : ByteArray) : ByteArray
    {
        p.writeByte(0x22);
        return p;
    }
    
    private function DOUBLEDASH(p : ByteArray) : ByteArray
    {
        p.writeShort(0x2d2d);
        return p;
    }
    
    private function nextAsyncLoop() : Void
    {
        var fp : FilePart;
        
        if (asyncFilePointer < _fileNames.length)
        {
            fp = try cast(Reflect.field(_files, Std.string(_fileNames[asyncFilePointer])), FilePart) catch(e:Dynamic) null;
            _data = getFilePartHeader(_data, fp);
            
            asyncWriteTimeoutId = as3hx.Compat.setTimeout(writeChunkLoop, 10, [_data, fp.fileContent, 0]);
            
            asyncFilePointer++;
        }
        else
        {
            _data = closeFilePartsData(_data);
            _data = closeDataObject(_data);
            
            _prepared = true;
            
            dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, totalFilesSize, totalFilesSize));
            dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE));
        }
    }
    
    private function writeChunkLoop(dest : ByteArray, data : ByteArray, p : Int = 0) : Void
    {
        var len : Int = Math.min(BLOCK_SIZE, data.length - p);
        dest.writeBytes(data, p, len);
        
        if (len < BLOCK_SIZE || p + len >= data.length) {
dest = cast((dest), LINEBREAK);
            nextAsyncLoop();
            return;
        }
        
        p += len;
        writtenBytes += len;
        if (writtenBytes % BLOCK_SIZE * 2 == 0)
        {
            dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, writtenBytes, totalFilesSize));
        }
        
        asyncWriteTimeoutId = as3hx.Compat.setTimeout(writeChunkLoop, 10, [dest, data, p]);
    }
}


class FilePart
{
    
    
    public var fileContent : ByteArray;
    public var fileName : String;
    public var dataField : String;
    public var contentType : String;
    
    @:allow(com.flashfla.net)
    private function new(fileContent : ByteArray, fileName : String, dataField : String = "Filedata", contentType : String = "application/octet-stream")
    {
        this.fileContent = fileContent;
        this.fileName = fileName;
        this.dataField = dataField;
        this.contentType = contentType;
    }
    
    public function dispose() : Void
    {
        fileContent = null;
        fileName = null;
        dataField = null;
        contentType = null;
    }
}
