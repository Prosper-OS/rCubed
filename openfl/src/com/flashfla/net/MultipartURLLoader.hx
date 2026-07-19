package com.flashfla.net;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.utils.ByteArray;

class MultipartURLLoader extends EventDispatcher {
	public var ASYNC(get, never):Bool;
	public var PREPARED(get, never):Bool;
	public var dataFormat(get, set):String;
	public var loader(get, never):URLLoader;
	public var requestHeaders:Array<URLRequestHeader> = [];

	private var _loader:URLLoader = new URLLoader();
	private var _variables:Dynamic = {};
	private var _async:Bool = false;
	private var _prepared:Bool = false;

	public function new() {
		super();
	}

	public function load(path:String, async:Bool = false):Void {
		_async = async;
		_prepared = true;
		var request = new URLRequest(path);
		var variables = new URLVariables();
		for (field in Reflect.fields(_variables)) {
			Reflect.setField(variables, field, Reflect.field(_variables, field));
		}
		request.method = URLRequestMethod.POST;
		request.data = variables;
		request.requestHeaders = requestHeaders;
		_loader.load(request);
	}

	public function startLoad():Void {
	}

	public function prepareData():Void {
		_prepared = true;
		dispatchEvent(new Event("dataPrepareComplete"));
	}

	public function close():Void {
		_loader.close();
	}

	public function addVariable(name:String, value:Dynamic = ""):Void {
		Reflect.setField(_variables, name, value);
	}

	public function addFile(fileContent:ByteArray, fileName:String, dataField:String = "Filedata", contentType:String = "application/octet-stream"):Void {
	}

	public function clearVariables():Void {
		_variables = {};
	}

	public function clearFiles():Void {
	}

	public function dispose():Void {
		clearVariables();
		clearFiles();
	}

	public function getBoundary():String {
		return "";
	}

	private function get_ASYNC():Bool {
		return _async;
	}

	private function get_PREPARED():Bool {
		return _prepared;
	}

	private function get_dataFormat():String {
		return _loader.dataFormat;
	}

	private function set_dataFormat(format:String):String {
		_loader.dataFormat = format == null ? URLLoaderDataFormat.TEXT : format;
		return _loader.dataFormat;
	}

	private function get_loader():URLLoader {
		return _loader;
	}
}
