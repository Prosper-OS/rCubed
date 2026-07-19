package com.flashfla.utils;

class DateUtil {
	public static function toRFC822(d:Dynamic):String {
		var date:Date = Std.isOfType(d, Date) ? cast d : Date.now();
		var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		return days[date.getDay()] + ", " + pad2(date.getDate()) + " " + months[date.getMonth()] + " " + date.getFullYear() + " " + pad2(date.getHours()) + "." + pad2(date.getMinutes()) + "." + pad2(date.getSeconds());
	}

	public static function minutesToString(length:Dynamic):String {
		var minutes = as3hx.Compat.parseInt(length);
		if (minutes == 10080) return "1 week";
		if (minutes == 20160) return "2 weeks";
		if (minutes == 40320) return "1 month";
		if (minutes == 241920) return "6 months";

		var years = Std.int(Math.floor(minutes / 525600));
		minutes -= years * 525600;
		var days = Std.int(Math.floor(minutes / 1440));
		minutes -= days * 1440;
		var hours = Std.int(Math.floor(minutes / 60));
		minutes -= hours * 60;

		var parts:Array<String> = [];
		addPart(parts, years, "year");
		addPart(parts, days, "day");
		addPart(parts, hours, "hour");
		addPart(parts, minutes, "minute");
		return parts.join(", ");
	}

	private static function addPart(parts:Array<String>, value:Int, name:String):Void {
		if (value > 0) {
			parts.push(value + " " + name + (value == 1 ? "" : "s"));
		}
	}

	private static function pad2(value:Int):String {
		return value < 10 ? "0" + value : Std.string(value);
	}
}
