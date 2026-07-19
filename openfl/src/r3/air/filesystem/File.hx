package r3.air.filesystem;

import haxe.io.Bytes;
import sys.FileSystem;

class File {
	public static var separator(default, null):String = Sys.systemName() == "Windows" ? "\\" : "/";
	public static var applicationDirectory(default, null):File = new File(Sys.getCwd());
	public static var applicationStorageDirectory(default, null):File = new File(Sys.getCwd());
	public static var desktopDirectory(default, null):File = new File(Sys.getCwd());
	public static var documentsDirectory(default, null):File = new File(Sys.getCwd());
	public static var userDirectory(default, null):File = new File(Sys.getCwd());

	public var nativePath:String;
	public var url(get, never):String;
	public var exists(get, never):Bool;
	public var isDirectory(get, never):Bool;
	public var isHidden(get, never):Bool;
	public var name(get, never):String;
	public var extension(get, never):String;
	public var parent(get, never):File;
	public var modificationDate(get, never):Date;

	public function new(path:String = "") {
		nativePath = path == null ? "" : path;
	}

	public function resolvePath(path:String):File {
		return new File(haxe.io.Path.join([nativePath, path]));
	}

	public function createDirectory():Void {
		if (!FileSystem.exists(nativePath)) {
			FileSystem.createDirectory(nativePath);
		}
	}

	public function deleteFile():Void {
		if (FileSystem.exists(nativePath) && !FileSystem.isDirectory(nativePath)) {
			sys.FileSystem.deleteFile(nativePath);
		}
	}

	public function getDirectoryListing():Array<File> {
		if (!FileSystem.exists(nativePath) || !FileSystem.isDirectory(nativePath)) {
			return [];
		}

		return [for (entry in FileSystem.readDirectory(nativePath)) new File(haxe.io.Path.join([nativePath, entry]))];
	}

	public function load():Bytes {
		return sys.io.File.getBytes(nativePath);
	}

	public function save(bytes:Bytes, filename:String = null):Void {
		var path = filename == null ? nativePath : haxe.io.Path.join([nativePath, filename]);
		sys.io.File.saveBytes(path, bytes);
	}

	private function get_url():String {
		return "file://" + nativePath;
	}

	private function get_exists():Bool {
		return FileSystem.exists(nativePath);
	}

	private function get_isDirectory():Bool {
		return FileSystem.exists(nativePath) && FileSystem.isDirectory(nativePath);
	}

	private function get_isHidden():Bool {
		return get_name().indexOf(".") == 0;
	}

	private function get_name():String {
		return haxe.io.Path.withoutDirectory(nativePath);
	}

	private function get_extension():String {
		var fileName = get_name();
		var index = fileName.lastIndexOf(".");
		return index >= 0 && index < fileName.length - 1 ? fileName.substr(index + 1) : "";
	}

	private function get_parent():File {
		return new File(haxe.io.Path.directory(nativePath));
	}

	private function get_modificationDate():Date {
		return FileSystem.exists(nativePath) ? FileSystem.stat(nativePath).mtime : Date.fromTime(0);
	}
}
