package r3.air.desktop;

import openfl.events.Event;
import openfl.events.EventDispatcher;

class NativeApplication extends EventDispatcher {
	public static inline var EXITING:String = "exiting";

	public static var nativeApplication(default, null):NativeApplication = new NativeApplication();

	public var applicationDescriptor:Dynamic;

	public function new() {
		super();
		applicationDescriptor = null;
	}

	public function exit(errorCode:Int = 0):Void {
		dispatchEvent(new Event(EXITING));
	}
}
