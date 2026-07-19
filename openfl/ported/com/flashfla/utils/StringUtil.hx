package com.flashfla.utils;

import openfl.errors.Error;
class StringUtil
{
    public static var KEY_ARRAY : Array<Dynamic> = ["", "", "", "", "", "", "", "", 
        "Backspace", "Tab", "", "", "Clear", "Enter", "", "", "Shift", "Ctrl", "Alt", "Pause", "Capslock", 
        "", "", "", "", "", "", "Esc", "", "", "", "", "Space", "PgUp", "PgDown", "End", "Home", 
        "Left", "Up", "Right", "Down", "", "", "", "", "Insert", "Delete", "", 
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "", "", "", "", "", "", "", 
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
        "Win L", "Win R", "Context", "", "", 
        "Num 0", "Num 1", "Num 2", "Num 3", "Num 4", "Num 5", "Num 6", "Num 7", "Num 8", "Num 9", 
        "*", "+", "", "-", ".", "/", 
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", 
        "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20", "F21", "F22", "F23", "F24", 
        "", "", "", "", "", "", "", "", "Num Lock", "Sc Lk", "", "", "", "", "", "", "", "", "", "", 
        "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 
        "", "", "", "", "", "", "", ";", "=", ",", "-", ".", "/", "`", "", "", "", "", "", "", "", "", 
        "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "[", "\\", "]", "'"
    ];
    
    public static inline var STR_PAD_LEFT : String = "LeftPad";
    public static inline var STR_PAD_RIGHT : String = "RightPad";
    
    public static function fromCharArray(hexArray : Array<Dynamic>) : String
    {
        var output : String = "";
        for (char in hexArray)
        {
            output += String.fromCharCode(char);
        }
        return output;
    }
    
    public static function toHex(input : String) : String
    {
        var out : String = "";
        for (c in 0...input.length)
        {
            out += "0x" + pad(Std.string(as3hx.Compat.parseFloat(input.charCodeAt(c))).toUpperCase(), 2, "0", STR_PAD_LEFT) + ",";
        }
        return out.substr(0, out.length - 1);
    }
    
    public static function pad(input : String, pad_length : Int, pad_string : String = " ", pad_type : String = null) : String
    {
        var ret : String = input;
        
        if (pad_type == null)
        {
            pad_type = STR_PAD_LEFT;
        }
        
        if (pad_string == "")
        {
            return input;
        }
        
        if (pad_type == STR_PAD_LEFT)
        {
            while (ret.length < pad_length)
            {
                ret = pad_string + ret;
            }
        }
        else if (pad_type == STR_PAD_RIGHT)
        {
            while (ret.length < pad_length)
            {
                ret += pad_string;
            }
        }
        
        return ret;
    }
    
    public static function upperCase(str : String) : String
    {
        return str.substr(0, 1).toUpperCase() + str.substr(1, str.length);
    }
    
    public static function keyCodeChar(input : Int) : String
    {
        return KEY_ARRAY[input] || ("[" + Std.string(input) + "]");
    }
    
    public static function getURLPieces(urlStr : String) : Array<Dynamic>
    {
        return splitMultiple(new as3hx.Compat.Regex('http(s|):\\/\\/', "").replace(urlStr, "").toLowerCase(), ["/", ".", "?", "&", "="]);
    }
    
    public static function splitMultiple(str : String, delimiters : Array<Dynamic>) : Array<Dynamic>
    {
        if (delimiters.length > 1)
        {
            for (i in 1...delimiters.length)
            {
                str = str.split(delimiters[i]).join(delimiters[0]);
            }
        }
        return str.split(delimiters[0]);
    }
    
    public static function htmlEscape(str : String) : String
    {
        return StringTools.htmlEscape(str, true);
    }
    
    public static function htmlUnescape(str : String) : String
    {
        return StringTools.htmlUnescape(str);
    }
    
    public static function stripMessage(str : String) : String
    {
        if (str == null)
        {
            return "";
        }
        while (str.length && str.charAt(str.length - 1) == "\n")
        {
            str = str.substr(0, str.length - 1);
        }
        while (str.length && str.charAt(0) == "\n")
        {
            str = str.substr(1);
        }
        return str;
    }
    
    public static function stringsAreEqual(s1 : String, s2 : String, caseSensitive : Bool) : Bool
    {
        if (caseSensitive)
        {
            return (s1 == s2);
        }
        else
        {
            return (s1.toUpperCase() == s2.toUpperCase());
        }
    }
    
    public static function trim(input : String) : String
    {
        return ltrim(rtrim(input));
    }
    
    public static function ltrim(input : String) : String
    {
        var size : Float = input.length;
        for (i in 0...size)
        {
            if (input.charCodeAt(i) > 32)
            {
                return input.substring(i);
            }
        }
        return "";
    }
    
    public static function rtrim(input : String) : String
    {
        var size : Float = input.length;
        var i : Float = size;
        while (i > 0)
        {
            if (input.charCodeAt(i - 1) > 32)
            {
                return input.substring(0, i);
            }
            i--;
        }
        
        return "";
    }
    
    public static function beginsWith(input : String, prefix : String) : Bool
    {
        return (prefix == input.substring(0, prefix.length));
    }
    
    public static function endsWith(input : String, suffix : String) : Bool
    {
        return (suffix == input.substring(input.length - suffix.length));
    }
    
    public static function remove(input : String, remove : String) : String
    {
        return StringUtil.replace(input, remove, "");
    }
    
    public static function replace(input : String, replace : String, replaceWith : String) : String
    {
        var sb : String = "";
        var found : Bool = false;
        
        var sLen : Float = input.length;
        var rLen : Float = replace.length;
        
        for (i in 0...sLen)
        {
            if (input.charAt(i) == replace.charAt(0))
            {
                found = true;
                for (j in 0...rLen)
                {
                    if (!(input.charAt(i + j) == replace.charAt(j)))
                    {
                        found = false;
                        break;
                    }
                }
                
                if (found)
                {
                    sb += replaceWith;
                    i = i + (rLen - 1);
                    continue;
                }
            }
            sb += input.charAt(i);
        }
        return sb;
    }
    
    public static function containsHtml(text : String) : Bool
    {
        return text && (text.indexOf("<") >= 0 && text.indexOf(">") >= 0 && text.indexOf("</") >= 0);
    }
    
    public static function stripHtml(text : String) : String
    {
        return (text != null) ? new as3hx.Compat.Regex('<[^>]+>', "ig").replace(text, "") : null;
    }

    public function new()
    {
    }
}

