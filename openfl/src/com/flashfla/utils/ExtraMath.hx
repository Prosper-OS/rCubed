package com.flashfla.utils;

class ExtraMath {
	public static function getRandomFraction(min:Dynamic, max:Dynamic, roundOff:Dynamic = 2, exceptArray:Dynamic = null):Float {
		var lo = as3hx.Compat.parseFloat(min);
		var hi = as3hx.Compat.parseFloat(max);
		var places = as3hx.Compat.parseInt(roundOff);
		var except = as3hx.Compat.toArray(exceptArray);
		var value:Float;
		do {
			var scale = Math.pow(10, places);
			value = Math.floor((Math.random() * (hi - lo) + lo) * scale) / scale;
		} while (except.indexOf(value) >= 0);
		return value;
	}

	public static function getRandom(min:Dynamic, max:Dynamic, exceptArray:Dynamic = null):Int {
		var series = getSeries(as3hx.Compat.parseInt(min), as3hx.Compat.parseInt(max));
		var except = as3hx.Compat.toArray(exceptArray);
		series = series.filter(function(value) return except.indexOf(value) < 0);
		if (series.length == 0) {
			return as3hx.Compat.parseInt(min);
		}
		return series[Std.int(Math.floor(Math.random() * series.length))];
	}

	public static function getRandomSeries(min:Dynamic, max:Dynamic, count:Dynamic = -1, exceptArray:Dynamic = null):Array<Dynamic> {
		var series:Array<Dynamic> = cast getSeries(as3hx.Compat.parseInt(min), as3hx.Compat.parseInt(max));
		var except = as3hx.Compat.toArray(exceptArray);
		series = series.filter(function(value) return except.indexOf(value) < 0);
		var wanted = as3hx.Compat.parseInt(count);
		if (wanted < 0) {
			return series;
		}
		var out:Array<Dynamic> = [];
		while (wanted > 0 && series.length > 0) {
			var index = Std.int(Math.floor(Math.random() * series.length));
			out.push(series.splice(index, 1)[0]);
			wanted--;
		}
		return out;
	}

	public static function getSeries(min:Dynamic, max:Dynamic, dif:Dynamic = 1):Array<Int> {
		var out:Array<Int> = [];
		var step = as3hx.Compat.parseInt(dif);
		if (step == 0) {
			step = 1;
		}
		var value = as3hx.Compat.parseInt(min);
		var end = as3hx.Compat.parseInt(max);
		while ((step > 0 && value <= end) || (step < 0 && value >= end)) {
			out.push(value);
			value += step;
		}
		return out;
	}

	public static function getPrimeList(min:Dynamic, max:Dynamic, count:Dynamic = -1, randomised:Dynamic = false):Array<Dynamic> {
		var series:Array<Dynamic> = [];
		for (value in as3hx.Compat.parseInt(min)...as3hx.Compat.parseInt(max) + 1) {
			if (isPrime(value)) {
				series.push(value);
			}
		}
		return takeSeries(series, count, randomised);
	}

	public static function getCompositeList(min:Dynamic, max:Dynamic, count:Dynamic = -1, randomised:Dynamic = false):Array<Dynamic> {
		var series:Array<Dynamic> = [];
		for (value in as3hx.Compat.parseInt(min)...as3hx.Compat.parseInt(max) + 1) {
			if (!isPrime(value)) {
				series.push(value);
			}
		}
		return takeSeries(series, count, randomised);
	}

	public static function getPrimeFactors(num:Dynamic):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		var value = as3hx.Compat.parseInt(num);
		for (i in 2...value + 1) {
			if (value % i == 0 && isPrime(i)) {
				out.push(i);
			}
		}
		return out;
	}

	public static function getFactors(num:Dynamic):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		var value = as3hx.Compat.parseInt(num);
		for (i in 1...value + 1) {
			if (value % i == 0) {
				out.push(i);
			}
		}
		return out;
	}

	public static function getGCD(a:Dynamic, b:Dynamic):Int {
		var left = Math.floor(Math.abs(as3hx.Compat.parseFloat(a)));
		var right = Math.floor(Math.abs(as3hx.Compat.parseFloat(b)));
		while (right != 0) {
			var next = left % right;
			left = right;
			right = next;
		}
		return Std.int(left);
	}

	public static function getLCM(a:Dynamic, b:Dynamic):Int {
		var left = as3hx.Compat.parseInt(a);
		var right = as3hx.Compat.parseInt(b);
		var gcd = getGCD(left, right);
		return gcd == 0 ? 0 : Std.int(Math.abs(left * right) / gcd);
	}

	public static function getCommonMultiples(a:Dynamic, b:Dynamic, cnt:Dynamic = 1):Array<Dynamic> {
		var lcm = getLCM(a, b);
		return cast getSeries(lcm, lcm * as3hx.Compat.parseInt(cnt), lcm);
	}

	public static function isPrime(num:Dynamic):Bool {
		var value = as3hx.Compat.parseInt(num);
		if (value == 2) return true;
		if (value <= 1) return false;
		for (i in 2...value) {
			if (value % i == 0) {
				return false;
			}
		}
		return true;
	}

	private static function takeSeries(series:Array<Dynamic>, count:Dynamic, randomised:Dynamic):Array<Dynamic> {
		var wanted = as3hx.Compat.parseInt(count);
		if (wanted < 0) {
			return series;
		}
		var out:Array<Dynamic> = [];
		for (i in 0...wanted) {
			if (series.length == 0) break;
			var index = as3hx.Compat.truthy(randomised) ? Std.int(Math.floor(Math.random() * series.length)) : 0;
			out.push(series.splice(index, 1)[0]);
		}
		return out;
	}
}
