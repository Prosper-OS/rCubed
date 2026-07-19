package com.flashfla.utils;


class Crypt
{
    public static var B64Chars : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    /**
     * Preforms a Crypt Encode
     */
    public static function Encode(src : String) : String
    {
        var output : String = "";
        var gLength : Float = Math.ceil(Math.random() * 8) + 1;
        
        // Base64 Encode Input
        output = cast((src), B64Encode);
        
        // Add the random garbage data to the end
        for (c in 0...gLength)
        {
            output += B64Chars.charAt(Math.floor(Math.random() * 63));
        }
        
        // Add the total characters to the beginning, and flip/reverse the string.
        output = gLength + output;
        // output = flipString(gLength + output);
        
        // Add garbage chars every 4 characters
        var g : Int = 4;
        while (g < output.length)
        {
            output = output.substr(0, g) + B64Chars.charAt(Math.floor(Math.random() * 63)) + output.substr(g);
            g += 5;
        }
        
        output = cast((output), ROT255);
        output = cast((output), B64Encode);
        return output;
    }
    
    /**
     * Decodes a Crypt Encode
     */
    public static function Decode(src : String) : String
    {
        if (src.length == 0)
        {
            return "";
        }
        
        var input : String = "";
        var output : String = "";
        
        // Decode
        input = cast((src), B64Decode);
        input = cast((input), ROT255);
        
        // Rip out every 5th char as it's garbage.
        var n : Int = 0;
        while (n <= (input.length + 4))
        {
            output += input.substr(n, 4);
            n += 5;
        }
        
        // Flip the string
        // output = flipString(output);
        
        // Rip garbage data
        output = output.substr(1, output.length - as3hx.Compat.parseFloat(output.charAt(0)) - 1);
        
        // Do decoding another round of decoding
        output = cast((output), B64Decode);
        
        return output;
    }
    
    /**
     * Encodes a base64 string.
     */
    public static function B64Encode(src : String) : String
    {
        var i : Float = 0;
        var output : String = "";
        var chr1 : Float;
        var chr2 : Float;
        var chr3 : Float;
        var enc1 : Float;
        var enc2 : Float;
        var enc3 : Float;
        var enc4 : Float;
        
        // Do the normal Base64
        while (i < src.length)
        {
            chr1 = src.charCodeAt(i++);
            chr2 = src.charCodeAt(i++);
            chr3 = src.charCodeAt(i++);
            enc1 = chr1 >> 2;
            enc2 = ((as3hx.Compat.parseInt(chr1) & 3) << 4) | (chr2 >> 4);
            enc3 = ((as3hx.Compat.parseInt(chr2) & 15) << 2) | (chr3 >> 6);
            enc4 = as3hx.Compat.parseInt(chr3) & 63;
            if (Math.isNaN(chr2))
            {
                enc3 = enc4 = 64;
            }
            else if (Math.isNaN(chr3))
            {
                enc4 = 64;
            }
            output += B64Chars.charAt(enc1) + B64Chars.charAt(enc2) + B64Chars.charAt(enc3) + B64Chars.charAt(enc4);
        }
        return output;
    }
    
    /**
     * Decodes a base64 string.
     */
    public static function B64Decode(src : String) : String
    {
        var i : Float = 0;
        var output : String = "";
        var chr1 : Float;
        var chr2 : Float;
        var chr3 : Float;
        var enc1 : Float;
        var enc2 : Float;
        var enc3 : Float;
        var enc4 : Float;
        while (i < src.length)
        {
            enc1 = B64Chars.indexOf(src.charAt(i++));
            enc2 = B64Chars.indexOf(src.charAt(i++));
            enc3 = B64Chars.indexOf(src.charAt(i++));
            enc4 = B64Chars.indexOf(src.charAt(i++));
            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((as3hx.Compat.parseInt(enc2) & 15) << 4) | (enc3 >> 2);
            chr3 = ((as3hx.Compat.parseInt(enc3) & 3) << 6) | enc4;
            output += String.fromCharCode(chr1);
            if (enc3 != 64)
            {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64)
            {
                output = output + String.fromCharCode(chr3);
            }
        }
        return output;
    }
    
    /**
     * Preforms a ROT255.
     */
    public static function ROT255(src : String) : String
    {
        var mL : Int = src.length;
        var arr : Array<Dynamic> = new Array<Dynamic>(mL);
        
        // 255 XOR Wrap
        for (i in 0...mL)
        {
            arr[i] = src.charCodeAt(i) ^ ((mL + i * 4) % 255);
        }
        
        return String.fromCharCode.apply(null, arr);
    }
    
    /**
     * Converts the input to a charCode array.
     */
    public static function toCharCode(s : String) : String
    {
        var output : String = "";
        for (c in 0...s.length)
        {
            output += s.charCodeAt(c) + ",";
        }
        output = output.substr(0, output.length - 1);
        return "String.fromCharCode(" + output + ")";
    }
    
    /**
     * Reverses the input string.
     */
    private static function flipString(s : String) : String
    {
        return s.split("").reverse().join("");
    }

    public function new()
    {
    }
}

