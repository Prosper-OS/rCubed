package by.blooddy.crypto.image;

import openfl.display.BitmapData;
import openfl.utils.ByteArray;

class PNGEncoder {
	public static function encode(bitmapData:BitmapData):ByteArray {
		return bitmapData.encode(bitmapData.rect, new openfl.display.PNGEncoderOptions());
	}
}
