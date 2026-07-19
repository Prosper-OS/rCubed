package openfl.ui;

import openfl.events.EventDispatcher;

class ContextMenuItem extends EventDispatcher {
	public var caption:String;
	public var separatorBefore:Bool;
	public var enabled:Bool;
	public var visible:Bool;

	public function new(caption:String, separatorBefore:Bool = false, enabled:Bool = true, visible:Bool = true) {
		super();
		this.caption = caption;
		this.separatorBefore = separatorBefore;
		this.enabled = enabled;
		this.visible = visible;
	}
}
