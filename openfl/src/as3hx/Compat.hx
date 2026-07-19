package as3hx;

class Compat {
	public static inline var INT_MAX:Int = 2147483647;
	public static inline var INT_MIN:Int = -2147483648;
	public static inline var FLOAT_MAX:Float = 1.7976931348623157e+308;
	public static inline var FLOAT_MIN:Float = 2.2250738585072014e-308;
	public static inline var ARRAY_CASEINSENSITIVE:Int = 1;
	public static inline var ARRAY_DESCENDING:Int = 2;
	public static inline var ARRAY_NUMERIC:Int = 16;

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

	public static function truthy(value:Dynamic):Bool {
		if (value == null) {
			return false;
		}
		if (Std.isOfType(value, Bool)) {
			return value;
		}
		if (Std.isOfType(value, Int) || Std.isOfType(value, Float)) {
			return value != 0 && !Math.isNaN(value);
		}
		if (Std.isOfType(value, String)) {
			return value != "";
		}
		return true;
	}

	public static function orValue(left:Dynamic, right:Dynamic):Dynamic {
		return truthy(left) ? left : right;
	}

	public static function field(value:Dynamic, key:Dynamic):Dynamic {
		if (value == null) {
			return null;
		}
		if (Std.isOfType(value, Array)) {
			var index = parseInt(key);
			var array:Array<Dynamic> = cast value;
			return index >= 0 && index < array.length ? array[index] : null;
		}
		return Reflect.field(value, Std.string(key));
	}

	public static function iter(value:Dynamic):Iterator<Dynamic> {
		return toArray(value).iterator();
	}

	public static function toArray(value:Dynamic):Array<Dynamic> {
		if (value == null) {
			return [];
		}
		if (Std.isOfType(value, Array)) {
			return cast value;
		}
		if (Std.isOfType(value, String)) {
			var text = Std.string(value);
			var chars:Array<Dynamic> = [];
			for (i in 0...text.length) {
				chars.push(text.charAt(i));
			}
			return chars;
		}
		var iterator = Reflect.field(value, "iterator");
		if (iterator != null && Reflect.isFunction(iterator)) {
			try {
				var out:Array<Dynamic> = [];
				var it:Iterator<Dynamic> = cast Reflect.callMethod(value, iterator, []);
				for (item in it) {
					out.push(item);
				}
				return out;
			} catch (_:Dynamic) {
			}
		}
		var fields = Reflect.fields(value);
		var values:Array<Dynamic> = [];
		for (field in fields) {
			values.push(Reflect.field(value, field));
		}
		return values;
	}

	public static function sortOn(array:Dynamic, fields:Dynamic, options:Dynamic = 0):Dynamic {
		if (!Std.isOfType(array, Array)) {
			return array;
		}
		var list:Array<Dynamic> = cast array;
		var fieldList:Array<Dynamic> = Std.isOfType(fields, Array) ? cast fields : [fields];
		var optionList:Array<Dynamic> = Std.isOfType(options, Array) ? cast options : [options];
		list.sort(function(a:Dynamic, b:Dynamic):Int {
			for (i in 0...fieldList.length) {
				var option = i < optionList.length ? as3hx.Compat.parseInt(optionList[i]) : 0;
				var result = compareValues(fieldValue(a, fieldList[i]), fieldValue(b, fieldList[i]), option);
				if (result != 0) {
					return result;
				}
			}
			return 0;
		});
		return array;
	}

	public static function compareValues(a:Dynamic, b:Dynamic, options:Int = 0):Int {
		var descending = (options & ARRAY_DESCENDING) != 0;
		var numeric = (options & ARRAY_NUMERIC) != 0;
		var caseInsensitive = (options & ARRAY_CASEINSENSITIVE) != 0;
		var result:Int;
		if (numeric) {
			var af = parseFloat(a);
			var bf = parseFloat(b);
			result = af < bf ? -1 : (af > bf ? 1 : 0);
		} else {
			var asText = Std.string(a);
			var bsText = Std.string(b);
			if (caseInsensitive) {
				asText = asText.toLowerCase();
				bsText = bsText.toLowerCase();
			}
			result = asText < bsText ? -1 : (asText > bsText ? 1 : 0);
		}
		return descending ? -result : result;
	}

	private static function fieldValue(value:Dynamic, field:Dynamic):Dynamic {
		if (Std.isOfType(value, Array)) {
			var index = Std.parseInt(Std.string(field));
			if (index != null) {
				return (cast value:Array<Dynamic>)[index];
			}
		}
		return Reflect.field(value, Std.string(field));
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
