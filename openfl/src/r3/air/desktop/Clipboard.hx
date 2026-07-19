package r3.air.desktop;

class Clipboard {
	public static var generalClipboard(default, null):Clipboard = new Clipboard();

	private var data:Map<String, Dynamic> = [];

	public function new() {
	}

	public function clear():Void {
		data.clear();
	}

	public function setData(format:String, value:Dynamic, serializable:Bool = true):Void {
		data.set(format, value);
	}

	public function getData(format:String):Dynamic {
		return data.get(format);
	}
}
