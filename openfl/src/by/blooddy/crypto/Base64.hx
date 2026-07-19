package by.blooddy.crypto;

import haxe.crypto.Base64 as HaxeBase64;
import haxe.io.Bytes;
import openfl.utils.ByteArray;

class Base64 {
	public static function encode(value:Dynamic):String {
		return HaxeBase64.encode(toBytes(value));
	}

	public static function decode(value:String):ByteArray {
		var bytes = HaxeBase64.decode(value);
		var out = new ByteArray();
		out.writeBytes(ByteArray.fromBytes(bytes));
		out.position = 0;
		return out;
	}

	private static function toBytes(value:Dynamic):Bytes {
		if (value != null && Reflect.hasField(value, "readUTFBytes") && Reflect.hasField(value, "length")) {
			var byteArray:ByteArray = cast value;
			var position = byteArray.position;
			byteArray.position = 0;
			var bytes = byteArray.readUTFBytes(byteArray.length);
			byteArray.position = position;
			return Bytes.ofString(bytes);
		}

		return Bytes.ofString(Std.string(value));
	}
}
