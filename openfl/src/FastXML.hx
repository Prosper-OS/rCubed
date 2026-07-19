@:forward
abstract FastXML(Dynamic) from Dynamic to Dynamic {
	public function new(value:Dynamic) {
		this = FastXMLRuntime.wrap(value);
	}

	public var node(get, never):FastXMLNodeAccess;
	public var nodes(get, never):FastXMLNodeListAccess;
	public var att(get, never):Dynamic;
	public var name(get, never):String;
	public var innerData(get, never):Dynamic;
	public var innerHTML(get, never):String;

	private inline function get_node():FastXMLNodeAccess {
		return FastXMLRuntime.nodeAccess(this);
	}

	private inline function get_nodes():FastXMLNodeListAccess {
		return FastXMLRuntime.nodeListAccess(this);
	}

	private inline function get_att():Dynamic {
		return FastXMLRuntime.attributesObject(this);
	}

	private inline function get_name():String {
		return FastXMLRuntime.nodeName(this);
	}

	private inline function get_innerData():Dynamic {
		return FastXMLRuntime.nodeText(this);
	}

	private inline function get_innerHTML():String {
		return FastXMLRuntime.innerHTML(this);
	}

	public inline function attributes():FastXMLList {
		return FastXMLRuntime.attributes(this);
	}

	public inline function children():FastXMLList {
		return FastXMLRuntime.children(this);
	}

	public inline function descendants(name:String = "*"):FastXMLList {
		return FastXMLRuntime.descendants(this, name);
	}

	public inline function getAttribute(name:String):String {
		return FastXMLRuntime.attribute(this, name);
	}

	public inline function toXMLString():String {
		return FastXMLRuntime.toXMLString(this);
	}

	public inline function toString():String {
		return FastXMLRuntime.toXMLString(this);
	}
}

@:forward
abstract FastXMLNodeAccess(Dynamic) from Dynamic to Dynamic {
	public inline function children():FastXMLList {
		return FastXMLRuntime.children(this.__owner);
	}

	public inline function attributes():FastXMLList {
		return FastXMLRuntime.attributes(this.__owner);
	}
}

@:forward
abstract FastXMLNodeListAccess(Dynamic) from Dynamic to Dynamic {
	public inline function children():FastXMLList {
		return FastXMLRuntime.children(this.__owner);
	}
}

class FastXMLRuntime {
	public static function wrap(value:Dynamic):Dynamic {
		var xml:Xml = null;
		if (Std.isOfType(value, Xml)) {
			xml = value;
		} else {
			xml = Xml.parse(Std.string(value));
		}
		if (xml.nodeType == Xml.Document) {
			var first = xml.firstElement();
			if (first != null) {
				xml = first;
			}
		}
		return {__xml: xml};
	}

	public static function nodeAccess(owner:Dynamic):FastXMLNodeAccess {
		var access:Dynamic = {__owner: owner};
		var xml = getXml(owner);
		if (xml != null) {
			for (child in xml.elements()) {
				Reflect.setField(access, child.nodeName, wrap(child));
			}
			Reflect.setField(access, "localName", valueNode(xml.nodeName));
			Reflect.setField(access, "name", valueNode(xml.nodeName));
			Reflect.setField(access, "children", valueNode(childTextArray(xml)));
			Reflect.setField(access, "attribute", attributeAccessor(owner));
			Reflect.setField(access, "toXMLString", valueNode(xml.toString()));
		}
		return access;
	}

	public static function nodeListAccess(owner:Dynamic):FastXMLNodeListAccess {
		var access:Dynamic = {__owner: owner};
		var xml = getXml(owner);
		if (xml != null) {
			for (child in xml.elements()) {
				var existing:FastXMLList = Reflect.field(access, child.nodeName);
				var list = existing == null ? new FastXMLList() : existing;
				list.push(wrap(child));
				Reflect.setField(access, child.nodeName, list);
			}
		}
		return access;
	}

	public static function attributesObject(owner:Dynamic):Dynamic {
		var out:Dynamic = {};
		var xml = getXml(owner);
		if (xml != null) {
			for (name in xml.attributes()) {
				Reflect.setField(out, name, xml.get(name));
			}
		}
		return out;
	}

	public static function attributes(owner:Dynamic):FastXMLList {
		var out = new FastXMLList();
		var xml = getXml(owner);
		if (xml != null) {
			for (name in xml.attributes()) {
				out.push(valueNode(xml.get(name), name));
			}
		}
		return out;
	}

	public static function children(owner:Dynamic):FastXMLList {
		var out = new FastXMLList();
		var xml = getXml(owner);
		if (xml != null) {
			for (child in xml.elements()) {
				out.push(wrap(child));
			}
		}
		return out;
	}

	public static function descendants(owner:Dynamic, name:String):FastXMLList {
		var out = new FastXMLList();
		var xml = getXml(owner);
		if (xml != null) {
			addDescendants(out, xml, name);
		}
		return out;
	}

	public static function attribute(owner:Dynamic, name:String):String {
		var xml = getXml(owner);
		return xml == null ? null : xml.get(name);
	}

	public static function nodeName(owner:Dynamic):String {
		var xml = getXml(owner);
		return xml == null ? "" : xml.nodeName;
	}

	public static function nodeText(owner:Dynamic):String {
		var xml = getXml(owner);
		return xml == null ? "" : collectText(xml);
	}

	public static function innerHTML(owner:Dynamic):String {
		var xml = getXml(owner);
		if (xml == null) {
			return "";
		}
		var buffer = new StringBuf();
		for (child in xml) {
			buffer.add(child.toString());
		}
		return buffer.toString();
	}

	public static function toXMLString(owner:Dynamic):String {
		var xml = getXml(owner);
		return xml == null ? "" : xml.toString();
	}

	private static function getXml(owner:Dynamic):Xml {
		return owner == null ? null : Reflect.field(owner, "__xml");
	}

	private static function attributeAccessor(owner:Dynamic):Dynamic {
		return {
			innerData: function(name:String):String {
				return attribute(owner, name);
			}
		};
	}

	private static function valueNode(value:Dynamic, ?name:String):Dynamic {
		return {
			name: name == null ? "" : name,
			innerData: function(?unused:Dynamic):Dynamic {
				return value;
			},
			toXMLString: {
				innerData: function():String {
					return Std.string(value);
				}
			}
		};
	}

	private static function childTextArray(xml:Xml):Array<String> {
		var values:Array<String> = [];
		for (child in xml.elements()) {
			values.push(collectText(child));
		}
		return values;
	}

	private static function collectText(xml:Xml):String {
		var buffer = new StringBuf();
		for (child in xml) {
			if (child.nodeType == Xml.PCData || child.nodeType == Xml.CData) {
				buffer.add(child.nodeValue);
			}
		}
		return buffer.toString();
	}

	private static function addDescendants(out:FastXMLList, xml:Xml, name:String):Void {
		for (child in xml.elements()) {
			if (name == "*" || child.nodeName == name) {
				out.push(wrap(child));
			}
			addDescendants(out, child, name);
		}
	}
}
