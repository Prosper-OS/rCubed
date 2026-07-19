package r3.air.desktop;

enum abstract NotificationType(String) from String to String {
	var CRITICAL = "critical";
	var INFORMATIONAL = "informational";
}
