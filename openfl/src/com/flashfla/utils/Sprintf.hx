package com.flashfla.utils;

class Sprintf {
	public static function sprintf(raw:String, values:Dynamic = null):String {
		if (raw == null || values == null) {
			return raw;
		}

		var out = raw;
		for (field in Reflect.fields(values)) {
			out = StringTools.replace(out, "%(" + field + ")s", Std.string(Reflect.field(values, field)));
			out = StringTools.replace(out, "{" + field + "}", Std.string(Reflect.field(values, field)));
		}
		return out;
	}
}
