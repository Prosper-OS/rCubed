package com.flashfla.utils;

class VectorUtil {
	public static function fromArr(arr:Dynamic):Array<Dynamic> {
		return as3hx.Compat.toArray(arr).copy();
	}

	public static function inVector(vec:Dynamic, items:Dynamic):Bool {
		var values = as3hx.Compat.toArray(vec);
		var needles = as3hx.Compat.toArray(items);
		if (values.length == 0 || needles.length == 0 || values.length < needles.length) {
			return false;
		}
		for (needle in needles) {
			for (value in values) {
				if (value == needle) {
					return true;
				}
			}
		}
		return false;
	}

	public static function removeFirst(value:Dynamic, vec:Dynamic):Bool {
		if (!Std.isOfType(vec, Array)) {
			return false;
		}
		var values:Array<Dynamic> = cast vec;
		var index = values.indexOf(value);
		if (index < 0) {
			return false;
		}
		values.splice(index, 1);
		return true;
	}

	public static function binarySearch(vec:Dynamic, target:Dynamic, prop:Dynamic):Int {
		var values = as3hx.Compat.toArray(vec);
		var n = values.length;
		if (n == 0) {
			return -1;
		}
		var targetValue = as3hx.Compat.parseFloat(target);
		var propName = Std.string(prop);
		if (targetValue <= as3hx.Compat.parseFloat(Reflect.field(values[0], propName))) {
			return 0;
		}
		if (targetValue >= as3hx.Compat.parseFloat(Reflect.field(values[n - 1], propName))) {
			return n - 1;
		}
		var i = 0;
		var j = n;
		var mid = 0;
		while (i < j) {
			mid = Std.int((i + j) / 2);
			var midValue = as3hx.Compat.parseFloat(Reflect.field(values[mid], propName));
			if (midValue == targetValue) {
				return mid;
			}
			if (targetValue < midValue) {
				if (mid > 0) {
					var prevValue = as3hx.Compat.parseFloat(Reflect.field(values[mid - 1], propName));
					if (targetValue > prevValue) {
						return (targetValue - prevValue >= midValue - targetValue) ? mid : mid - 1;
					}
				}
				j = mid;
			} else {
				if (mid < n - 1) {
					var nextValue = as3hx.Compat.parseFloat(Reflect.field(values[mid + 1], propName));
					if (targetValue < nextValue) {
						return (targetValue - midValue >= nextValue - targetValue) ? mid + 1 : mid;
					}
				}
				i = mid + 1;
			}
		}
		return mid;
	}
}
