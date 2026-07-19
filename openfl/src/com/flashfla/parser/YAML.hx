package com.flashfla.parser;

class YAML {
	private static final ARRAY_TOKEN:Array<String> = ["- ", "  "];
	private static inline var SLASH_TOKEN:String = "!---slash-replace---!";

	public static function decode(data:String):Dynamic {
		var out:Dynamic = {};
		var bufflines = data.split("\n");
		var buckets:Array<Dynamic> = [out];
		var bucketKeys:Array<Null<String>> = [null];
		var bucketDepths:Array<Int> = [0];
		var bucketDepth = 0;
		var bucketLastDepth = 0;

		for (line in bufflines) {
			bucketDepth = 0;

			var splitIndex = line.indexOf(":");
			if (line.length == 0 || splitIndex < 0) {
				continue;
			}

			var startArrayItem = false;
			var key = line.substr(0, splitIndex);
			var val = parseValue(StringTools.trim(line.substr(splitIndex + 1)));
			var keyToken = key.substr(0, 2);

			if (ARRAY_TOKEN.indexOf(keyToken) >= 0) {
				startArrayItem = startArrayItem || keyToken.indexOf("-") >= 0;
				while (true) {
					key = key.substr(2);
					keyToken = key.substr(0, 2);
					bucketDepth++;
					startArrayItem = startArrayItem || keyToken.indexOf("-") >= 0;
					if (ARRAY_TOKEN.indexOf(keyToken) < 0) {
						break;
					}
				}
			}

			if (startArrayItem && bucketDepth == bucketLastDepth) {
				var stackBucket = buckets.pop();
				var stackBucketKey = bucketKeys.pop();
				bucketDepths.pop();
				if (stackBucketKey == null) {
					pushDynamic(buckets[buckets.length - 1], stackBucket);
				}
			}

			if (bucketDepth < bucketLastDepth) {
				var returnDepth = bucketDepths.pop();
				while (returnDepth >= bucketDepth) {
					var stackBucket = buckets.pop();
					var stackBucketKey = bucketKeys.pop();
					if (stackBucketKey == null) {
						pushDynamic(buckets[buckets.length - 1], stackBucket);
					} else {
						Reflect.setField(buckets[buckets.length - 1], stackBucketKey, stackBucket);
					}

					if (bucketDepths.length <= 1) {
						break;
					}
					returnDepth = bucketDepths.pop();
				}
			}

			if (startArrayItem) {
				buckets.push({});
				bucketKeys.push(null);
				bucketDepths.push(bucketDepth);
			}

			if (val == null) {
				buckets.push([]);
				bucketKeys.push(key);
				bucketDepths.push(bucketDepth);
			} else {
				Reflect.setField(buckets[buckets.length - 1], key, val);
			}

			bucketLastDepth = bucketDepth;
		}

		while (buckets.length > 1) {
			var stackBucket = buckets.pop();
			var stackBucketKey = bucketKeys.pop();
			if (stackBucketKey == null) {
				pushDynamic(buckets[buckets.length - 1], stackBucket);
			} else {
				Reflect.setField(buckets[buckets.length - 1], stackBucketKey, stackBucket);
			}
		}

		return out;
	}

	private static function parseValue(val:String):Dynamic {
		if (val == "" || val.length == 0) {
			return null;
		}
		if (val == "[]") {
			return [];
		}
		if (val == "''") {
			return "";
		}
		if (val.charAt(0) == "'") {
			return val.substr(1, val.length - 2);
		}
		if (val.charAt(0) == '"') {
			var text = val.substr(1, val.length - 2);
			if (text.indexOf("\\\\") >= 0) {
				text = StringTools.replace(text, "\\\\", SLASH_TOKEN);
				text = StringTools.replace(text, "\\", "");
				return StringTools.replace(text, SLASH_TOKEN, "\\");
			}
			return StringTools.replace(text, "\\", "");
		}
		return val;
	}

	private static function pushDynamic(target:Dynamic, value:Dynamic):Void {
		(cast target:Array<Dynamic>).push(value);
	}
}
