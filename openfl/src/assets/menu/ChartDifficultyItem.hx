package assets.menu;

import openfl.display.MovieClip;

class ChartDifficultyItem extends MovieClip {
	public function new() {
		super();
		mouseEnabled = false;
		mouseChildren = false;
		graphics.beginFill(0xFFFFFF, 0.18);
		graphics.drawRect(0, 0, 32, 32);
		graphics.endFill();
	}
}