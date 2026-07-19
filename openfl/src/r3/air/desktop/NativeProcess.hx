package r3.air.desktop;

class NativeProcess {
	public static var isSupported(default, null):Bool = false;

	public function new() {
	}

	public function start(info:NativeProcessStartupInfo):Void {
		throw "NativeProcess is not available in the OpenFL port yet";
	}
}
