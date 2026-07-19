package openfl.ui;

import openfl.events.EventDispatcher;

class ContextMenu extends EventDispatcher {
	public var customItems:Array<ContextMenuItem> = [];

	public function new() {
		super();
	}

	public function hideBuiltInItems():Void {
	}
}
