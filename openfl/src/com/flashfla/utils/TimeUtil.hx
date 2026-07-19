package com.flashfla.utils;

class TimeUtil {
	public static function getCurrentDate():String {
		return getFormattedDate(Date.now());
	}

	public static function getFormattedDate(date:Dynamic):String {
		if (date == null) {
			return "";
		}
		var d:Date = cast date;
		var month = d.getMonth() + 1;
		return d.getFullYear() + "/" + doubleDigitFormat(month) + "/" + doubleDigitFormat(d.getDate()) + " " + doubleDigitFormat(d.getHours()) + ":" + doubleDigitFormat(d.getMinutes()) + ":" + doubleDigitFormat(d.getSeconds());
	}

	public static function getTimezoneOffset():Float {
		return 0;
	}

	public static function convertToHHMMSS(seconds:Dynamic):String {
		var value = Math.floor(as3hx.Compat.parseFloat(seconds));
		if (Math.isNaN(value) || value < 0) {
			return "Never";
		}
		var s = Std.int(value % 60);
		var m = Std.int(Math.floor((value % 3600) / 60));
		var h = Std.int(Math.floor(value / 3600));
		return (h == 0 ? "" : doubleDigitFormat(h) + ":") + doubleDigitFormat(m) + ":" + doubleDigitFormat(s);
	}

	public static function convertToHMSS(seconds:Dynamic):String {
		var value = Math.floor(as3hx.Compat.parseFloat(seconds));
		if (Math.isNaN(value) || value < 0) {
			return "0:00";
		}
		var s = Std.int(value % 60);
		var m = Std.int(Math.floor((value % 3600) / 60));
		var h = Std.int(Math.floor(value / 3600));
		return (h == 0 ? "" : doubleDigitFormat(h) + ":") + (h == 0 ? Std.string(m) : doubleDigitFormat(m)) + ":" + doubleDigitFormat(s);
	}

	public static function doubleDigitFormat(num:Dynamic):String {
		var value = as3hx.Compat.parseInt(num);
		return value < 10 ? "0" + value : Std.string(value);
	}
}
