package com.greensock.easing;

class BackIn {
	public static function ease(t:Float, b:Float = 0, c:Float = 1, d:Float = 1, s:Float = 1.70158):Float {
		t /= d;
		return c * t * t * ((s + 1) * t - s) + b;
	}
}
