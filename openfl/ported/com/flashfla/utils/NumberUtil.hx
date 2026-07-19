package com.flashfla.utils;


class NumberUtil
{
    public static function numberFormat(number : Dynamic, maxDecimals : Int = 2, forceDecimals : Bool = false) : String
    {
        var i : Int = 0;
        var inc : Float = Math.pow(10, maxDecimals);
        var str : String = Std.string(Math.round(inc * as3hx.Compat.parseFloat(number)) / inc);
        var hasSep : Bool = str.indexOf(".") == -1;
        var sep : Int = (hasSep) ? str.length : str.indexOf(".");
        var ret : String = (hasSep && !(forceDecimals) ? "" : ".") + str.substr(sep + 1);
        
        if (forceDecimals)
        {
            for (j in 0...maxDecimals - (str.length - ((hasSep) ? sep - 1 : sep)) + 1)
            {
                ret += "0";
            }
        }
        
        while (i + 3 < ((str.substr(0, 1) == "-") ? sep - 1 : sep))
        {
            ret = "," + str.substr(sep - (i += 3), 3) + ret;
        }
        
        return str.substr(0, sep - i) + ret;
    }
    
    public static var fileSizes : Array<Dynamic> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    
    public static function bytesToString(bytes : Float) : String
    {
        var index : Int = Math.floor(Math.log(bytes) / Math.log(1024));
        return (bytes / Math.pow(1024, index)).toFixed(2) + " " + fileSizes[index];
    }
    
    public static function hex2dec(hex : String) : Int
    {
        return (hex != null) ? as3hx.Compat.parseInt(hex) : 0;
    }
    
    public static function dec2hex(dec : Int) : String
    {
        return Std.string(dec).toUpperCase();
    }

    public function new()
    {
    }
}

