package com.flashfla.utils;

class StringUtil {
	public static var KEY_ARRAY:Array<String> = ["", "", "", "", "", "", "", "",
		"Backspace", "Tab", "", "", "Clear", "Enter", "", "", "Shift", "Ctrl", "Alt", "Pause", "Capslock",
		"", "", "", "", "", "", "Esc", "", "", "", "", "Space", "PgUp", "PgDown", "End", "Home",
		"Left", "Up", "Right", "Down", "", "", "", "", "Insert", "Delete", "",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "", "", "", "", "", "", "",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"Win L", "Win R", "Context", "", "",
		"Num 0", "Num 1", "Num 2", "Num 3", "Num 4", "Num 5", "Num 6", "Num 7", "Num 8", "Num 9",
		"*", "+", "", "-", ".", "/",
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		"F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20", "F21", "F22", "F23", "F24",
		"", "", "", "", "", "", "", "", "Num Lock", "Sc Lk", "", "", "", "", "", "", "", "", "", "",
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
		"", "", "", "", "", "", "", ";", "=", ",", "-", ".", "/", "`", "", "", "", "", "", "", "", "",
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "[", "\\", "]", "'"
	];

	public static inline var STR_PAD_LEFT:String = "LeftPad";
	public static inline var STR_PAD_RIGHT:String = "RightPad";

	public static function fromCharArray(hexArray:Dynamic):String {
		var output = "";
		for (char in as3hx.Compat.iter(hexArray)) {
			output += String.fromCharCode(as3hx.Compat.parseInt(char));
		}
		return output;
	}

	public static function toHex(input:Dynamic):String {
		var text = Std.string(input);
		var out:Array<String> = [];
		for (i in 0...text.length) {
			out.push("0x" + pad(StringTools.hex(text.charCodeAt(i)).toUpperCase(), 2, "0", STR_PAD_LEFT));
		}
		return out.join(",");
	}

	public static function pad(input:Dynamic, pad_length:Dynamic, pad_string:Dynamic = " ", pad_type:Dynamic = null):String {
		var ret = Std.string(input);
		var target = as3hx.Compat.parseInt(pad_length);
		var piece = Std.string(pad_string);
		var mode = pad_type == null ? STR_PAD_LEFT : Std.string(pad_type);
		if (piece == "") {
			return ret;
		}
		while (ret.length < target) {
			ret = mode == STR_PAD_RIGHT ? ret + piece : piece + ret;
		}
		return ret;
	}

	public static function upperCase(str:Dynamic):String {
		var text = Std.string(str);
		return text.length == 0 ? "" : text.substr(0, 1).toUpperCase() + text.substr(1);
	}

	public static function keyCodeChar(input:Dynamic):String {
		var index = as3hx.Compat.parseInt(input);
		if (index >= 0 && index < KEY_ARRAY.length && KEY_ARRAY[index] != "") {
			return KEY_ARRAY[index];
		}
		return "[" + Std.string(input) + "]";
	}

	public static function getURLPieces(urlStr:Dynamic):Array<Dynamic> {
		var text = new as3hx.Compat.Regex("http(s|):\\/\\/", "").replace(Std.string(urlStr), "").toLowerCase();
		return cast splitMultiple(text, ["/", ".", "?", "&", "="]);
	}

	public static function splitMultiple(str:Dynamic, delimiters:Dynamic):Array<Dynamic> {
		var text = Std.string(str);
		var parts = as3hx.Compat.toArray(delimiters);
		if (parts.length == 0) {
			return [text];
		}
		var first = Std.string(parts[0]);
		for (i in 1...parts.length) {
			text = text.split(Std.string(parts[i])).join(first);
		}
		return cast text.split(first);
	}

	public static function htmlEscape(str:Dynamic):String {
		return StringTools.htmlEscape(Std.string(str), true);
	}

	public static function htmlUnescape(str:Dynamic):String {
		return StringTools.htmlUnescape(Std.string(str));
	}

	public static function stripMessage(str:Dynamic):String {
		if (str == null) return "";
		var text = Std.string(str);
		while (text.length > 0 && text.charAt(text.length - 1) == "\n") {
			text = text.substr(0, text.length - 1);
		}
		while (text.length > 0 && text.charAt(0) == "\n") {
			text = text.substr(1);
		}
		return text;
	}

	public static function stringsAreEqual(s1:Dynamic, s2:Dynamic, caseSensitive:Dynamic):Bool {
		var left = Std.string(s1);
		var right = Std.string(s2);
		return as3hx.Compat.truthy(caseSensitive) ? left == right : left.toUpperCase() == right.toUpperCase();
	}

	public static function trim(input:Dynamic):String {
		return StringTools.trim(Std.string(input));
	}

	public static function ltrim(input:Dynamic):String {
		return StringTools.ltrim(Std.string(input));
	}

	public static function rtrim(input:Dynamic):String {
		return StringTools.rtrim(Std.string(input));
	}

	public static function beginsWith(input:Dynamic, prefix:Dynamic):Bool {
		return StringTools.startsWith(Std.string(input), Std.string(prefix));
	}

	public static function endsWith(input:Dynamic, suffix:Dynamic):Bool {
		return StringTools.endsWith(Std.string(input), Std.string(suffix));
	}

	public static function remove(input:Dynamic, remove:Dynamic):String {
		return replace(input, remove, "");
	}

	public static function replace(input:Dynamic, replace:Dynamic, replaceWith:Dynamic):String {
		return Std.string(input).split(Std.string(replace)).join(Std.string(replaceWith));
	}

	public static function containsHtml(text:Dynamic):Bool {
		if (text == null) return false;
		var value = Std.string(text);
		return value.indexOf("<") >= 0 && value.indexOf(">") >= 0 && value.indexOf("</") >= 0;
	}

	public static function stripHtml(text:Dynamic):String {
		return text != null ? new as3hx.Compat.Regex("<[^>]+>", "ig").replace(Std.string(text), "") : null;
	}
}
