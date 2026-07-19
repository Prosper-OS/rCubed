package com.greensock.easing;

class BackOut {
	public static function ease(t:Float, b:Float = 0, c:Float = 1, d:Float = 1, s:Float = 1.70158):Float {
		t = t / d - 1;
		return c * (t * t * ((s + 1) * t + s) + 1) + b;
	}
}
