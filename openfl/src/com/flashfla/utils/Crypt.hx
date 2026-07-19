package com.flashfla.utils;

class Crypt {
	public static var B64Chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	public static function Encode(src:String):String {
		var output = B64Encode(src == null ? "" : src);
		var gLength = Math.ceil(Math.random() * 8) + 1;
		for (_ in 0...Std.int(gLength)) {
			output += B64Chars.charAt(Std.int(Math.floor(Math.random() * 63)));
		}
		output = Std.int(gLength) + output;
		var g = 4;
		while (g < output.length) {
			output = output.substr(0, g) + B64Chars.charAt(Std.int(Math.floor(Math.random() * 63))) + output.substr(g);
			g += 5;
		}
		return B64Encode(ROT255(output));
	}

	public static function Decode(src:String):String {
		if (src == null || src.length == 0) {
			return "";
		}
		var input = ROT255(B64Decode(src));
		var output = "";
		var n = 0;
		while (n <= input.length + 4) {
			output += input.substr(n, 4);
			n += 5;
		}
		var garbage = Std.parseInt(output.charAt(0));
		if (garbage == null) {
			garbage = 0;
		}
		output = output.substr(1, output.length - garbage - 1);
		return B64Decode(output);
	}

	public static function B64Encode(src:String):String {
		var i = 0;
		var output = new StringBuf();
		while (i < src.length) {
			var chr1 = codeOrNaN(src, i++);
			var chr2 = codeOrNaN(src, i++);
			var chr3 = codeOrNaN(src, i++);
			var enc1 = chr1 >> 2;
			var enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			var enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			var enc4 = chr3 & 63;
			if (chr2 < 0) {
				enc3 = 64;
				enc4 = 64;
			} else if (chr3 < 0) {
				enc4 = 64;
			}
			output.add(B64Chars.charAt(enc1));
			output.add(B64Chars.charAt(enc2));
			output.add(B64Chars.charAt(enc3));
			output.add(B64Chars.charAt(enc4));
		}
		return output.toString();
	}

	public static function B64Decode(src:String):String {
		var i = 0;
		var output = new StringBuf();
		while (i < src.length) {
			var enc1 = B64Chars.indexOf(src.charAt(i++));
			var enc2 = B64Chars.indexOf(src.charAt(i++));
			var enc3 = B64Chars.indexOf(src.charAt(i++));
			var enc4 = B64Chars.indexOf(src.charAt(i++));
			var chr1 = (enc1 << 2) | (enc2 >> 4);
			var chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			var chr3 = ((enc3 & 3) << 6) | enc4;
			output.addChar(chr1);
			if (enc3 != 64) {
				output.addChar(chr2);
			}
			if (enc4 != 64) {
				output.addChar(chr3);
			}
		}
		return output.toString();
	}

	public static function ROT255(src:String):String {
		var mL = src.length;
		var output = new StringBuf();
		for (i in 0...mL) {
			output.addChar(codeOrNaN(src, i) ^ ((mL + i * 4) % 255));
		}
		return output.toString();
	}

	public static function toCharCode(s:String):String {
		var values:Array<String> = [];
		for (i in 0...s.length) {
			values.push(Std.string(codeOrNaN(s, i)));
		}
		return "String.fromCharCode(" + values.join(",") + ")";
	}

	private static function codeOrNaN(src:String, index:Int):Int {
		var code = src.charCodeAt(index);
		return code == null ? -1 : code;
	}
}
