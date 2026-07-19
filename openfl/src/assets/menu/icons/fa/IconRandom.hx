package assets.menu.icons.fa;

import openfl.display.MovieClip;

class IconRandom extends MovieClip {
	public function new() {
		super();
		mouseEnabled = false;
		mouseChildren = false;
		graphics.beginFill(0xFFFFFF, 0.18);
		graphics.drawRect(0, 0, 32, 32);
		graphics.endFill();
	}
}