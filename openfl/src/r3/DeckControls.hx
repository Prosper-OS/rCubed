package r3;

import openfl.ui.Keyboard;

class DeckControls {
	public static inline var L4:Int = Keyboard.LEFT;
	public static inline var L5:Int = Keyboard.DOWN;
	public static inline var R4:Int = Keyboard.UP;
	public static inline var R5:Int = Keyboard.RIGHT;

	public static function toLane(keyCode:Int):Int {
		return switch (keyCode) {
			case Keyboard.LEFT, 65: 0;
			case Keyboard.DOWN, 83: 1;
			case Keyboard.UP, 75: 2;
			case Keyboard.RIGHT, 76: 3;
			default: -1;
		}
	}
}
