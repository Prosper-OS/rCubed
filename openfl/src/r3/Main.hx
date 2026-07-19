package r3;

import openfl.Lib;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class Main extends Sprite {
	private var canvas:Shape;
	private var hud:TextField;
	private var pressed:Array<Bool> = [false, false, false, false];
	private var lanePulse:Array<Float> = [0, 0, 0, 0];
	private var lastTime:Float = 0;
	private var elapsed:Float = 0;

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		canvas = new Shape();
		addChild(canvas);

		hud = new TextField();
		hud.selectable = false;
		hud.mouseEnabled = false;
		hud.defaultTextFormat = hudFormat(16, true);
		addChild(hud);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(Event.RESIZE, onResize);
		addEventListener(Event.ENTER_FRAME, onFrame);

		lastTime = Lib.getTimer() / 1000;
		draw();
	}

	private function onResize(event:Event):Void {
		draw();
	}

	private function onFrame(event:Event):Void {
		var now = Lib.getTimer() / 1000;
		var dt = Math.min(0.05, Math.max(0, now - lastTime));
		lastTime = now;
		elapsed += dt;

		for (i in 0...lanePulse.length) {
			lanePulse[i] = Math.max(0, lanePulse[i] - dt * 6);
		}

		draw();
	}

	private function onKeyDown(event:KeyboardEvent):Void {
		setLaneState(event.keyCode, true);
	}

	private function onKeyUp(event:KeyboardEvent):Void {
		setLaneState(event.keyCode, false);
	}

	private function setLaneState(keyCode:Int, isDown:Bool):Void {
		var lane = DeckControls.toLane(keyCode);
		if (lane < 0) {
			return;
		}

		if (isDown && !pressed[lane]) {
			lanePulse[lane] = 1;
		}
		pressed[lane] = isDown;
	}

	private function draw():Void {
		var sw = stage.stageWidth;
		var sh = stage.stageHeight;
		var g = canvas.graphics;
		g.clear();

		drawBackground(g, sw, sh);

		var centerX = sw * 0.5;
		var topY = sh * 0.12;
		var bottomY = sh * 0.84;
		var bottomWidth = Math.min(sw * 0.52, 620);
		var topWidth = bottomWidth * 0.76;
		var laneColors = [0x66F5FF, 0xFFFFFF, 0xBDFE6A, 0xFF70D8];

		drawLaneField(g, centerX, topY, bottomY, topWidth, bottomWidth, laneColors);
		drawPreviewNotes(g, centerX, topY, bottomY, topWidth, bottomWidth, laneColors);
		drawReceptors(g, centerX, bottomY, bottomWidth, laneColors);
		drawHud(sw, sh);
	}

	private function drawBackground(g:Graphics, sw:Int, sh:Int):Void {
		var matrix = new Matrix();
		matrix.createGradientBox(sw, sh, Math.PI * 0.5, 0, 0);
		g.beginGradientFill(GradientType.LINEAR, [0x05070B, 0x111827, 0x05070B], [1, 1, 1], [0, 130, 255], matrix);
		g.drawRect(0, 0, sw, sh);
		g.endFill();

		var sweep = (Math.sin(elapsed * 0.8) + 1) * 0.5;
		var bandY = sh * (0.35 + sweep * 0.18);
		matrix.identity();
		matrix.createGradientBox(sw, sh * 0.28, 0, 0, bandY - sh * 0.14);
		g.beginGradientFill(GradientType.LINEAR, [0x00E5FF, 0x7CFF6B, 0xFF4FD8], [0, 0.14, 0], [0, 128, 255], matrix);
		g.drawRect(0, bandY - sh * 0.14, sw, sh * 0.28);
		g.endFill();
	}

	private function drawLaneField(g:Graphics, centerX:Float, topY:Float, bottomY:Float, topWidth:Float, bottomWidth:Float, colors:Array<Int>):Void {
		var topLeft = centerX - topWidth * 0.5;
		var bottomLeft = centerX - bottomWidth * 0.5;
		var laneCount = 4;

		for (i in 0...laneCount) {
			var t0 = i / laneCount;
			var t1 = (i + 1) / laneCount;
			var x0Top = topLeft + topWidth * t0;
			var x1Top = topLeft + topWidth * t1;
			var x0Bottom = bottomLeft + bottomWidth * t0;
			var x1Bottom = bottomLeft + bottomWidth * t1;
			var pulse = lanePulse[i];
			var alpha = pressed[i] ? 0.25 : 0.12 + pulse * 0.16;

			g.beginFill(colors[i], alpha);
			g.moveTo(x0Top, topY);
			g.lineTo(x1Top, topY);
			g.lineTo(x1Bottom, bottomY);
			g.lineTo(x0Bottom, bottomY);
			g.lineTo(x0Top, topY);
			g.endFill();

			g.lineStyle(1 + pulse * 2, colors[i], 0.26 + pulse * 0.38);
			g.moveTo(x0Top, topY);
			g.lineTo(x0Bottom, bottomY);
			if (i == laneCount - 1) {
				g.moveTo(x1Top, topY);
				g.lineTo(x1Bottom, bottomY);
			}
		}

		g.lineStyle(2, 0xEAF2FF, 0.28);
		g.moveTo(topLeft, topY);
		g.lineTo(topLeft + topWidth, topY);
		g.lineTo(bottomLeft + bottomWidth, bottomY);
		g.lineTo(bottomLeft, bottomY);
		g.lineTo(topLeft, topY);
	}

	private function drawPreviewNotes(g:Graphics, centerX:Float, topY:Float, bottomY:Float, topWidth:Float, bottomWidth:Float, colors:Array<Int>):Void {
		var topLeft = centerX - topWidth * 0.5;
		var bottomLeft = centerX - bottomWidth * 0.5;
		var laneCount = 4;

		for (lane in 0...laneCount) {
			for (note in 0...3) {
				var raw = (elapsed * 0.42 + lane * 0.16 + note * 0.34) % 1;
				var perspective = raw * raw * (3 - 2 * raw);
				var laneCenterTop = topLeft + topWidth * ((lane + 0.5) / laneCount);
				var laneCenterBottom = bottomLeft + bottomWidth * ((lane + 0.5) / laneCount);
				var x = lerp(laneCenterTop, laneCenterBottom, perspective);
				var y = lerp(topY, bottomY, raw);
				var size = lerp(20, 54, perspective);
				var alpha = 0.32 + perspective * 0.58;
				drawArrow(g, x, y, size, colors[lane], alpha);
			}
		}
	}

	private function drawReceptors(g:Graphics, centerX:Float, y:Float, width:Float, colors:Array<Int>):Void {
		var left = centerX - width * 0.5;
		var laneWidth = width / 4;

		for (lane in 0...4) {
			var pulse = lanePulse[lane];
			var x = left + laneWidth * (lane + 0.5);
			var size = 58 + pulse * 14;
			var color = pressed[lane] ? colors[lane] : 0xFFFFFF;

			g.lineStyle(4 + pulse * 2, color, pressed[lane] ? 0.95 : 0.72);
			drawArrow(g, x, y, size, color, pressed[lane] ? 0.28 : 0.08);
		}
	}

	private function drawArrow(g:Graphics, x:Float, y:Float, size:Float, color:Int, alpha:Float):Void {
		var half = size * 0.5;
		var stem = size * 0.22;

		g.beginFill(color, alpha);
		g.moveTo(x, y - half);
		g.lineTo(x + half, y - stem * 0.15);
		g.lineTo(x + stem, y - stem * 0.15);
		g.lineTo(x + stem, y + half);
		g.lineTo(x - stem, y + half);
		g.lineTo(x - stem, y - stem * 0.15);
		g.lineTo(x - half, y - stem * 0.15);
		g.lineTo(x, y - half);
		g.endFill();
	}

	private function drawHud(sw:Int, sh:Int):Void {
		hud.width = sw;
		hud.height = 64;
		hud.x = 0;
		hud.y = Math.max(16, sh * 0.035);
		hud.defaultTextFormat = hudFormat(sw < 900 ? 13 : 16, true);
		hud.text = "R3 OpenFL Port Foundation\nSteam Deck L4/L5/R4/R5: map to Left/Down/Up/Right";
	}

	private function hudFormat(size:Int, bold:Bool):TextFormat {
		var format = new TextFormat("_sans", size, 0xEAF2FF, bold);
		format.align = TextFormatAlign.CENTER;
		return format;
	}

	private function lerp(a:Float, b:Float, amount:Float):Float {
		return a + (b - a) * amount;
	}
}
