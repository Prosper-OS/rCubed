package r3.air.filesystem;

import haxe.io.Bytes;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;

class FileStream extends EventDispatcher {
	private var file:File;
	private var mode:String;
	private var buffer:ByteArray;

	public function new() {
		super();
		buffer = new ByteArray();
	}

	public function open(file:File, mode:String):Void {
		this.file = file;
		this.mode = mode;
		buffer = new ByteArray();
		if ((mode == FileMode.READ || mode == FileMode.UPDATE) && file.exists && !file.isDirectory) {
			buffer.writeBytes(ByteArray.fromBytes(file.load()));
			buffer.position = 0;
		}
	}

	public function close():Void {
		if (file != null && (mode == FileMode.WRITE || mode == FileMode.APPEND || mode == FileMode.UPDATE)) {
			file.save(buffer);
		}
	}

	public function readBytes(out:ByteArray):Void {
		buffer.readBytes(out, 0, buffer.length);
	}

	public function writeBytes(bytes:ByteArray):Void {
		buffer.writeBytes(bytes);
	}

	public function writeUTFBytes(value:String):Void {
		buffer.writeUTFBytes(value);
	}

	public function readUTFBytes(length:UInt):String {
		return buffer.readUTFBytes(length);
	}
}
