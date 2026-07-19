package com.flashfla.utils;


class TimeUtil
{
    public static function getCurrentDate() : String
    {
        return getFormattedDate(Date.now());
    }
    
    public static function getFormattedDate(date : Date) : String
    {
        if (date == null)
        {
            return "";
        }
        var month : String = ((date.getMonth() < 9) ? "0" : "") + (date.getMonth() + 1);
        var day : String = ((date.getDate() < 10) ? "0" : "") + date.getDate();
        return date.getFullYear() + "/" + month + "/" + day + " " + date.toLocaleTimeString();
    }
    
    public static function getTimezoneOffset() : Float
    // Create two dates: one summer and one winter
    {
        
        var d1 : Date = new Date(0, 0, 1);
        var d2 : Date = new Date(0, 6, 1);
        
        // Use current month to determin which to use
        var curMonth : Int = Date.now().getMonth();
        if (curMonth >= 0 && curMonth <= 5)
        {
            return d1.timezoneOffset;
        }
        else
        {
            return d2.timezoneOffset;
        }
    }
    
    public static function convertToHHMMSS(_seconds : Float) : String
    {
        if (Math.isNaN(_seconds) || _seconds < 0)
        {
            return "Never";
        }
        
        var s : Float = _seconds % 60;
        var m : Float = Math.floor((_seconds % 3600) / 60);
        var h : Float = Math.floor(_seconds / 3600);
        
        var hourStr : String = ((h == 0)) ? "" : doubleDigitFormat(h) + ":";
        var minuteStr : String = doubleDigitFormat(m) + ":";
        var secondsStr : String = doubleDigitFormat(s);
        
        return hourStr + minuteStr + secondsStr;
    }
    
    public static function convertToHMSS(_seconds : Float) : String
    {
        if (Math.isNaN(_seconds) || _seconds < 0)
        {
            return "0:00";
        }
        
        var s : Float = _seconds % 60;
        var m : Float = Math.floor((_seconds % 3600) / 60);
        var h : Float = Math.floor(_seconds / 3600);
        
        var hourStr : String = ((h == 0) ? ("") : (doubleDigitFormat(h) + ":"));
        var minuteStr : String = ((h == 0) ? Std.string(m) : doubleDigitFormat(m)) + ":";
        var secondsStr : String = doubleDigitFormat(s);
        
        return hourStr + minuteStr + secondsStr;
    }
    
    public static function doubleDigitFormat(_num : Int) : String
    {
        if (_num < 10)
        {
            return "0" + _num;
        }
        
        return Std.string(_num);
    }

    public function new()
    {
    }
}

