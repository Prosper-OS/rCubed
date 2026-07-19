package as3hx;

class Compat {
	public static inline var INT_MAX:Int = 2147483647;
	public static inline var INT_MIN:Int = -2147483648;
	public static inline var FLOAT_MAX:Float = 1.7976931348623157e+308;
	public static inline var FLOAT_MIN:Float = 2.2250738585072014e-308;

	private static var timers:Array<haxe.Timer> = [];

	public static function typeof(value:Dynamic):String {
		return switch (Type.typeof(value)) {
			case TNull: "object";
			case TInt, TFloat: "number";
			case TBool: "boolean";
			case TFunction: "function";
			case TClass(c) if (Type.getClassName(c) == "String"): "string";
			case TClass(c) if (Type.getClassName(c) == "Xml"): "xml";
			default: "object";
		}
	}

	public static function parseInt(value:Dynamic):Int {
		if (Std.isOfType(value, Int)) {
			return value;
		}
		if (Std.isOfType(value, Float)) {
			return Std.int(value);
		}
		var text = Std.string(value);
		var parsed = text.indexOf("0x") == 0 || text.indexOf("0X") == 0
			? Std.parseInt(text)
			: Std.parseInt(text);
		return parsed == null ? 0 : parsed;
	}

	public static function parseFloat(value:Dynamic):Float {
		if (Std.isOfType(value, Float) || Std.isOfType(value, Int)) {
			return value;
		}
		var parsed = Std.parseFloat(Std.string(value));
		return Math.isNaN(parsed) ? 0 : parsed;
	}

	public static function setArrayLength<T>(array:Array<T>, length:Int):Void {
		if (length < 0) {
			length = 0;
		}
		if (array.length > length) {
			array.splice(length, array.length - length);
		} else {
			while (array.length < length) {
				array.push(null);
			}
		}
	}

	public static function arraySplice<T>(array:Array<T>, startIndex:Int, deleteCount:Int, ?values:Array<T>):Array<T> {
		var removed = array.splice(startIndex, deleteCount);
		if (values != null) {
			for (i in 0...values.length) {
				array.insert(startIndex + i, values[i]);
			}
		}
		return removed;
	}

	public static function setTimeout(callback:Dynamic, delay:Int, ?values:Array<Dynamic>):Int {
		if (values == null) {
			values = [];
		}
		var timer = new haxe.Timer(delay);
		timers.push(timer);
		var id = timers.length - 1;
		timer.run = function() {
			Reflect.callMethod(null, callback, values);
			clearTimeout(id);
		};
		return id;
	}

	public static function clearTimeout(id:Int):Void {
		if (id >= 0 && id < timers.length && timers[id] != null) {
			timers[id].stop();
			timers[id] = null;
		}
	}

	public static function setInterval(callback:Dynamic, delay:Int, ?values:Array<Dynamic>):Int {
		if (values == null) {
			values = [];
		}
		var timer = new haxe.Timer(delay);
		timers.push(timer);
		var id = timers.length - 1;
		timer.run = function() Reflect.callMethod(null, callback, values);
		return id;
	}

	public static function clearInterval(id:Int):Void {
		clearTimeout(id);
	}

	public static function toFixed(value:Float, fractionDigits:Int):String {
		var scale = Math.pow(10, fractionDigits);
		var rounded = Math.round(value * scale) / scale;
		var text = Std.string(rounded);
		var dot = text.indexOf(".");
		if (fractionDigits == 0) {
			return dot >= 0 ? text.substr(0, dot) : text;
		}
		if (dot < 0) {
			text += ".";
			dot = text.length - 1;
		}
		while (text.length - dot - 1 < fractionDigits) {
			text += "0";
		}
		return text;
	}
}

typedef Regex = FlashRegExpAdapter;

class FlashRegExpAdapter {
	private var regex:EReg;
	private var global:Bool;

	public function new(pattern:String, options:String = "") {
		regex = new EReg(pattern, options);
		global = options.indexOf("g") >= 0;
	}

	public function exec(value:String):Null<Array<String>> {
		if (!regex.match(value)) {
			return null;
		}
		var matches:Array<String> = [];
		var index = 0;
		while (true) {
			try {
				matches.push(regex.matched(index));
				index++;
			} catch (_:Dynamic) {
				break;
			}
		}
		return matches;
	}

	public function test(value:String):Bool {
		return regex.match(value);
	}

	public function match(value:String):Bool {
		return regex.match(value);
	}

	public function matched(index:Int):String {
		return regex.matched(index);
	}

	public function matchedLeft():String {
		return regex.matchedLeft();
	}

	public function matchedRight():String {
		return regex.matchedRight();
	}

	public function matchedPos():{pos:Int, len:Int} {
		return regex.matchedPos();
	}

	public function matchSub(value:String, pos:Int, len:Int = -1):Bool {
		return regex.matchSub(value, pos, len);
	}

	public function replace(value:String, by:String):String {
		return global ? regex.replace(value, by) : replaceFirst(value, by);
	}

	public function split(value:String):Array<String> {
		return regex.split(value);
	}

	public function map(value:String, callback:EReg->String):String {
		return regex.map(value, callback);
	}

	private function replaceFirst(value:String, by:String):String {
		if (!regex.match(value)) {
			return value;
		}
		return regex.matchedLeft() + by + regex.matchedRight();
	}
}
