package com.flashfla.net;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;

class WebRequest {
	public var loader(get, never):URLLoader;

	private var _loader:URLLoader;
	private var _url:String;
	private var _funOnComplete:Dynamic;
	private var _funOnError:Dynamic;

	public var active:Bool = false;
	public var loaded:Bool = false;

	public function new(url:String, funOnComplete:Dynamic = null, funOnError:Dynamic = null) {
		_url = url;
		_funOnComplete = funOnComplete;
		_funOnError = funOnError;
	}

	public function load(params:Dynamic = null):Void {
		_loader = new URLLoader();
		addListeners();

		var request = new URLRequest(_url);
		if (params != null) {
			request.method = URLRequestMethod.POST;
			var variables = new URLVariables();
			Constant.addDefaultRequestVariables(variables);
			for (key in Reflect.fields(params)) {
				Reflect.setField(variables, key, Std.string(Reflect.field(params, key)));
			}
			request.data = variables;
		} else {
			request.method = URLRequestMethod.GET;
		}

		_loader.load(request);
	}

	private function get_loader():URLLoader {
		return _loader;
	}

	private function onLoadComplete(event:Event):Void {
		removeListeners();
		if (_funOnComplete != null) {
			Reflect.callMethod(null, _funOnComplete, [event]);
		}
	}

	private function onLoadError(event:Event):Void {
		removeListeners();
		if (_funOnError != null) {
			Reflect.callMethod(null, _funOnError, [event]);
		}
	}

	private function addListeners():Void {
		active = true;
		loaded = false;
		_loader.addEventListener(Event.COMPLETE, onLoadComplete);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
	}

	private function removeListeners():Void {
		active = false;
		loaded = true;
		if (_loader == null) {
			return;
		}
		_loader.removeEventListener(Event.COMPLETE, onLoadComplete);
		_loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
	}
}
