package by.blooddy.crypto;

import haxe.crypto.Sha1;
import openfl.utils.ByteArray;

class SHA1 {
	public static function hash(value:String):String {
		return Sha1.encode(value);
	}

	public static function digest(value:ByteArray):ByteArray {
		var hex = hashBytes(value);
		var out = new ByteArray();
		var i = 0;
		while (i < hex.length) {
			out.writeByte(Std.parseInt("0x" + hex.substr(i, 2)));
			i += 2;
		}
		out.position = 0;
		return out;
	}

	private static function hashBytes(bytes:ByteArray):String {
		var position = bytes.position;
		bytes.position = 0;
		var value = bytes.readUTFBytes(bytes.length);
		bytes.position = position;
		return Sha1.encode(value);
	}
}
