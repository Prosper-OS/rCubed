package game.graph;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

class GraphBase {
	public static var JUDGE_WINDOW_COLORS:Dynamic = {
		"100": 0x97f658,
		"50": 0x12e006,
		"25": 0x01aa0f,
		"5": 0xf99800,
		"0": 0x000000,
		"-5": 0xB06100
	};

	public static var JUDGE_WINDOW_CROSS_COLORS:Dynamic = {
		"100": 0xffffff,
		"50": 0xd0ffd4,
		"25": 0x76dd7e,
		"5": 0xf99800,
		"0": 0xff0000,
		"-5": 0xB06100
	};

	public static var JUDGE_WINDOW_TEXT:Dynamic = {
		"100": "game_amazing",
		"50": "game_perfect",
		"25": "game_good",
		"5": "game_average",
		"0": "game_miss",
		"-5": "game_boo"
	};

	public var graphWidth:Float = 760;
	public var graphHeight:Float = 175;
	public var result:Dynamic;
	public var graph:Sprite;
	public var overlay:Sprite;

	public function new(target:Sprite, overlay:Sprite, result:Dynamic) {
		graph = target;
		this.overlay = overlay;
		this.result = result;
	}

	public function onStage(container:DisplayObjectContainer):Void {
		if (graph != null) graph.graphics.clear();
		if (overlay != null) overlay.graphics.clear();
	}

	public function onStageRemove():Void {
		if (overlay != null) overlay.graphics.clear();
	}

	public function init():Void {
	}

	public function draw():Void {
		if (graph == null) return;
		graph.graphics.clear();
		graph.graphics.lineStyle(1, 0x445566, 0.7);
		graph.graphics.drawRect(0, 0, graphWidth, graphHeight);
		graph.graphics.lineStyle(1, 0x6fe7ff, 0.55);
		graph.graphics.moveTo(0, graphHeight * 0.5);
		graph.graphics.lineTo(graphWidth, graphHeight * 0.5);
	}

	public function drawOverlay(mx:Float, my:Float):Void {
		if (overlay == null) return;
		overlay.graphics.clear();
		if (validHover(mx, my)) {
			overlay.graphics.lineStyle(1, 0xffffff, 0.35);
			overlay.graphics.moveTo(mx, 0);
			overlay.graphics.lineTo(mx, graphHeight);
		}
	}

	public function validHover(mx:Float, my:Float, tolerance:Float = 0):Bool {
		return mx >= -tolerance && my >= -tolerance && mx <= graphWidth + tolerance && my <= graphHeight + tolerance;
	}
}
