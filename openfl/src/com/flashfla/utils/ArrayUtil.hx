package com.flashfla.utils;

class ArrayUtil {
	public static function in_array(inAr:Dynamic, items:Dynamic):Bool {
		var left = as3hx.Compat.toArray(inAr);
		var right = as3hx.Compat.toArray(items);
		for (item in right) {
			for (value in left) {
				if (value == item) {
					return true;
				}
			}
		}
		return false;
	}

	public static function remove(value:Dynamic, arr:Dynamic):Bool {
		if (!Std.isOfType(arr, Array)) {
			return false;
		}
		var list:Array<Dynamic> = cast arr;
		var index = list.indexOf(value);
		if (index < 0) {
			return false;
		}
		list.splice(index, 1);
		return true;
	}

	public static function removeValue(value:Dynamic, arr:Dynamic):Void {
		if (!Std.isOfType(arr, Array)) {
			return;
		}
		var list:Array<Dynamic> = cast arr;
		var i = list.length - 1;
		while (i >= 0) {
			if (list[i] == value) {
				list.splice(i, 1);
			}
			i--;
		}
	}

	public static function randomize(ar:Dynamic):Array<Dynamic> {
		var source = as3hx.Compat.toArray(ar).copy();
		var out:Array<Dynamic> = [];
		while (source.length > 0) {
			var index = Std.int(Math.floor(Math.random() * source.length));
			out.push(source.splice(index, 1)[0]);
		}
		return out;
	}
}
