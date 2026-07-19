package com.greensock.easing;

class SineInOut {
	public static function ease(t:Float, b:Float = 0, c:Float = 1, d:Float = 1):Float {
		return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
	}
}
