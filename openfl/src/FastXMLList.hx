@:forward
abstract FastXMLList(Dynamic) from Dynamic to Dynamic {
	public function new(?items:Array<FastXML>) {
		this = {
			items: items == null ? [] : items
		};
	}

	public inline function push(value:FastXML):Void {
		items().push(value);
	}

	public inline function get(index:Int):FastXML {
		return items()[index];
	}

	public inline function getArray():Array<FastXML> {
		return items();
	}

	public inline function iterator():Iterator<FastXML> {
		return items().iterator();
	}

	public inline function length():Int {
		return items().length;
	}

	public inline function children():FastXMLList {
		var out = new FastXMLList();
		for (item in items()) {
			for (child in item.children()) {
				out.push(child);
			}
		}
		return out;
	}

	public inline function attributes():FastXMLList {
		var out = new FastXMLList();
		for (item in items()) {
			for (attribute in item.attributes()) {
				out.push(attribute);
			}
		}
		return out;
	}

	public function descendants(name:String = "*"):FastXMLList {
		var out = new FastXMLList();
		for (item in items()) {
			for (descendant in item.descendants(name)) {
				out.push(descendant);
			}
		}
		return out;
	}

	public function toString():String {
		return [for (item in items()) item.toString()].join("\r\n");
	}

	private inline function items():Array<FastXML> {
		return cast Reflect.field(this, "items");
	}
}
