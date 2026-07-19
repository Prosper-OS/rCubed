package com.flashfla.utils;

import classes.GameNote;

class GameNotePool {
	public var pool:Array<PoolObject>;

	public function new() {
		pool = [];
	}

	public function addObject(object:Dynamic, mark:Dynamic = true):GameNote {
		pool.push(new PoolObject(as3hx.Compat.truthy(mark), object));
		return cast object;
	}

	public function unmarkObject(object:Dynamic, mark:Dynamic = false):Void {
		for (item in pool) {
			if (item.value == object) {
				item.mark = as3hx.Compat.truthy(mark);
			}
		}
	}

	public function unmarkAll(mark:Dynamic = false):Void {
		var next = as3hx.Compat.truthy(mark);
		for (item in pool) {
			item.mark = next;
		}
	}

	public function getObject():GameNote {
		for (item in pool) {
			if (!item.mark) {
				item.mark = true;
				return cast item.value;
			}
		}
		return null;
	}
}

private class PoolObject {
	public var mark:Bool;
	public var value:Dynamic;

	public function new(mark:Bool, value:Dynamic) {
		this.mark = mark;
		this.value = value;
	}
}
