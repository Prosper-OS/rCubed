package com.greensock;

import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.ColorTransform;

class TweenLite {
	public static var defaultOverwrite:Dynamic = "auto";

	private static var active:Array<TweenLite> = [];
	private static var ticking:Bool = false;

	private var target:Dynamic;
	private var duration:Float;
	private var vars:Dynamic;
	private var startTime:Float;
	private var delay:Float;
	private var repeat:Int;
	private var yoyo:Bool;
	private var completed:Bool = false;
	private var props:Array<TweenProperty> = [];
	private var startTint:Null<Int>;
	private var endTint:Null<Int>;

	public function new(target:Dynamic, duration:Float, vars:Dynamic) {
		this.target = target;
		this.duration = Math.max(0, duration);
		this.vars = vars == null ? {} : vars;
		this.delay = numberField(this.vars, "delay", 0);
		this.repeat = Std.int(numberField(this.vars, "repeat", 0));
		this.yoyo = boolField(this.vars, "yoyo", false);
		this.startTime = now() + this.delay;
		captureProperties();
	}

	public static function to(target:Dynamic, duration:Float, vars:Dynamic):TweenLite {
		var tween = new TweenLite(target, duration, vars);
		active.push(tween);
		ensureTicker();
		if (duration <= 0 && tween.delay <= 0) {
			tween.apply(1);
			tween.finish();
		}
		return tween;
	}

	public static function killTweensOf(target:Dynamic):Void {
		active = active.filter(function(tween) return tween.target != target);
	}

	private static function ensureTicker():Void {
		if (ticking) {
			return;
		}
		ticking = true;
		if (Lib.current != null) {
			Lib.current.addEventListener(Event.ENTER_FRAME, tick);
		}
	}

	private static function tick(_:Event):Void {
		var t = now();
		var i = active.length - 1;
		while (i >= 0) {
			var tween = active[i];
			if (tween.completed) {
				active.splice(i, 1);
			} else {
				tween.update(t);
				if (tween.completed) {
					active.splice(i, 1);
				}
			}
			i--;
		}
		if (active.length == 0 && Lib.current != null) {
			Lib.current.removeEventListener(Event.ENTER_FRAME, tick);
			ticking = false;
		}
	}

	private static inline function now():Float {
		return haxe.Timer.stamp();
	}

	private function update(t:Float):Void {
		if (t < startTime) {
			return;
		}
		var ratio = duration <= 0 ? 1 : Math.min(1, (t - startTime) / duration);
		apply(ease(ratio));
		callOptional("onUpdate", "onUpdateParams");
		if (ratio >= 1) {
			if (repeat == -1 || repeat > 0) {
				if (repeat > 0) {
					repeat--;
				}
				if (yoyo) {
					for (prop in props) {
						var tmp = prop.start;
						prop.start = prop.end;
						prop.end = tmp;
					}
					var tintTmp = startTint;
					startTint = endTint;
					endTint = tintTmp;
				}
				startTime = t;
			} else {
				finish();
			}
		}
	}

	private function finish():Void {
		if (completed) {
			return;
		}
		completed = true;
		apply(1);
		callOptional("onComplete", "onCompleteParams");
	}

	private function captureProperties():Void {
		for (field in Reflect.fields(vars)) {
			if (isReserved(field)) {
				continue;
			}
			if (field == "autoAlpha") {
				var alpha = numericValue(Reflect.field(vars, field), 1);
				props.push({name: "alpha", start: numericProperty(target, "alpha", 1), end: alpha});
				continue;
			}
			if (field == "tint") {
				captureTint(Reflect.field(vars, field));
				continue;
			}
			var endValue = Reflect.field(vars, field);
			if (Std.isOfType(endValue, Int) || Std.isOfType(endValue, Float)) {
				props.push({name: field, start: numericProperty(target, field, 0), end: numericValue(endValue, 0)});
			}
		}
	}

	private function apply(ratio:Float):Void {
		for (prop in props) {
			Reflect.setProperty(target, prop.name, prop.start + ((prop.end - prop.start) * ratio));
		}
		if (endTint != null) {
			applyTint(ratio);
		}
		if (Reflect.hasField(vars, "autoAlpha") && Std.isOfType(target, DisplayObject)) {
			cast(target, DisplayObject).visible = numericProperty(target, "alpha", 1) > 0.001;
		}
	}

	private function ease(ratio:Float):Float {
		var easing = Reflect.field(vars, "ease");
		if (easing == null) {
			return ratio;
		}
		if (Reflect.isFunction(easing)) {
			return numericValue(Reflect.callMethod(null, easing, [ratio, 0, 1, 1]), ratio);
		}
		var method = Reflect.field(easing, "ease");
		if (Reflect.isFunction(method)) {
			return numericValue(Reflect.callMethod(easing, method, [ratio, 0, 1, 1]), ratio);
		}
		return ratio;
	}

	private function captureTint(value:Dynamic):Void {
		if (!Std.isOfType(target, DisplayObject)) {
			return;
		}
		var object = cast(target, DisplayObject);
		startTint = colorFromTransform(object.transform.colorTransform);
		endTint = value == null ? 0xFFFFFF : Std.int(value);
	}

	private function applyTint(ratio:Float):Void {
		if (!Std.isOfType(target, DisplayObject) || startTint == null || endTint == null) {
			return;
		}
		var sr = (startTint >> 16) & 0xFF;
		var sg = (startTint >> 8) & 0xFF;
		var sb = startTint & 0xFF;
		var er = (endTint >> 16) & 0xFF;
		var eg = (endTint >> 8) & 0xFF;
		var eb = endTint & 0xFF;
		var r = Std.int(sr + ((er - sr) * ratio));
		var g = Std.int(sg + ((eg - sg) * ratio));
		var b = Std.int(sb + ((eb - sb) * ratio));
		var object = cast(target, DisplayObject);
		var transform = object.transform.colorTransform;
		transform.color = (r << 16) | (g << 8) | b;
		object.transform.colorTransform = transform;
	}

	private static function colorFromTransform(transform:ColorTransform):Int {
		return transform.color;
	}

	private function callOptional(callbackField:String, paramsField:String):Void {
		var callback = Reflect.field(vars, callbackField);
		if (!Reflect.isFunction(callback)) {
			return;
		}
		var params:Dynamic = Reflect.field(vars, paramsField);
		Reflect.callMethod(null, callback, Std.isOfType(params, Array) ? cast params : []);
	}

	private static function isReserved(field:String):Bool {
		return switch (field) {
			case "delay", "ease", "onComplete", "onCompleteParams", "onUpdate", "onUpdateParams", "repeat", "yoyo", "useFrames", "overwrite", "immediateRender": true;
			default: false;
		}
	}

	private static function numericProperty(target:Dynamic, field:String, fallback:Float):Float {
		return numericValue(Reflect.getProperty(target, field), fallback);
	}

	private static function numericValue(value:Dynamic, fallback:Float):Float {
		if (Std.isOfType(value, Int) || Std.isOfType(value, Float)) {
			return value;
		}
		var parsed = Std.parseFloat(Std.string(value));
		return Math.isNaN(parsed) ? fallback : parsed;
	}

	private static function numberField(source:Dynamic, field:String, fallback:Float):Float {
		return numericValue(Reflect.field(source, field), fallback);
	}

	private static function boolField(source:Dynamic, field:String, fallback:Bool):Bool {
		var value = Reflect.field(source, field);
		return value == null ? fallback : value == true;
	}
}

private typedef TweenProperty = {
	var name:String;
	var start:Float;
	var end:Float;
}
