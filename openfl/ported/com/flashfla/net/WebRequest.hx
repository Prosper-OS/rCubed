package com.flashfla.net;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLVariables;

class WebRequest
{
    public var loader(get, never) : URLLoader;

    private var _loader : URLLoader;
    
    private var _url : String;
    private var _funOnComplete : Dynamic;
    private var _funOnError : Dynamic;
    
    public var active : Bool = false;
    public var loaded : Bool = false;
    
    public function new(url : String, funOnComplete : Dynamic = null, funOnError : Dynamic = null)
    {
        this._url = url;
        this._funOnComplete = funOnComplete;
        this._funOnError = funOnError;
    }
    
    public function load(params : Dynamic = null) : Void
    {
        _loader = new URLLoader();
        _addListeners();
        
        var req : URLRequest = new URLRequest(_url);
        if (params != null)
        {
            req.method = "POST";
            var variables : URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(variables);
            for (key in Reflect.fields(params))
            {
                Reflect.setField(variables, key, Std.string(Reflect.field(params, key)));
            }
            req.data = variables;
        }
        else
        {
            req.method = "GET";
        }
        
        _loader.load(req);
    }
    
    private function get_loader() : URLLoader
    {
        return _loader;
    }
    
    private function e_loadComplete(e : Event) : Void
    {
        _removeListeners();
        if (_funOnComplete != null)
        {
            _funOnComplete(e);
        }
    }
    
    private function e_loadError(e : Event) : Void
    {
        _removeListeners();
        if (_funOnError != null)
        {
            _funOnError(e);
        }
    }
    
    //- Listeners
    private function _addListeners() : Void
    {
        active = true;
        loaded = false;
        _loader.addEventListener(Event.COMPLETE, e_loadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, e_loadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_loadError);
    }
    
    private function _removeListeners() : Void
    {
        active = false;
        loaded = true;
        _loader.removeEventListener(Event.COMPLETE, e_loadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, e_loadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_loadError);
    }
}

