package by.blooddy.crypto;

import haxe.crypto.Md5;
import openfl.utils.ByteArray;

class MD5 {
	public static function hash(value:String):String {
		return Md5.encode(value);
	}

	public static function hashBytes(bytes:ByteArray):String {
		var position = bytes.position;
		bytes.position = 0;
		var value = bytes.readUTFBytes(bytes.length);
		bytes.position = position;
		return Md5.encode(value);
	}
}
