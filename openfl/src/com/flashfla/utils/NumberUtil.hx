package com.flashfla.utils;

class NumberUtil {
	public static var fileSizes:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];

	public static function numberFormat(number:Dynamic, maxDecimals:Dynamic = 2, forceDecimals:Dynamic = false):String {
		var decimals = as3hx.Compat.parseInt(maxDecimals);
		var value = as3hx.Compat.parseFloat(number);
		var fixed = as3hx.Compat.toFixed(value, decimals);
		if (!as3hx.Compat.truthy(forceDecimals) && fixed.indexOf(".") >= 0) {
			while (fixed.length > 0 && fixed.charAt(fixed.length - 1) == "0") {
				fixed = fixed.substr(0, fixed.length - 1);
			}
			if (fixed.charAt(fixed.length - 1) == ".") {
				fixed = fixed.substr(0, fixed.length - 1);
			}
		}
		var parts = fixed.split(".");
		var intPart = parts[0];
		var sign = "";
		if (StringTools.startsWith(intPart, "-")) {
			sign = "-";
			intPart = intPart.substr(1);
		}
		var grouped = "";
		while (intPart.length > 3) {
			grouped = "," + intPart.substr(intPart.length - 3) + grouped;
			intPart = intPart.substr(0, intPart.length - 3);
		}
		grouped = sign + intPart + grouped;
		return parts.length > 1 && parts[1] != "" ? grouped + "." + parts[1] : grouped;
	}

	public static function bytesToString(bytes:Dynamic):String {
		var value = Math.max(0, as3hx.Compat.parseFloat(bytes));
		if (value < 1) {
			return "0 B";
		}
		var index = Std.int(Math.min(fileSizes.length - 1, Math.floor(Math.log(value) / Math.log(1024))));
		return as3hx.Compat.toFixed(value / Math.pow(1024, index), 2) + " " + fileSizes[index];
	}

	public static function hex2dec(hex:Dynamic):Int {
		if (hex == null) return 0;
		var text = Std.string(hex);
		if (!StringTools.startsWith(text, "0x") && !StringTools.startsWith(text, "0X")) {
			text = "0x" + text;
		}
		var parsed = Std.parseInt(text);
		return parsed == null ? 0 : parsed;
	}

	public static function dec2hex(dec:Dynamic):String {
		return StringTools.hex(as3hx.Compat.parseInt(dec)).toUpperCase();
	}
}
