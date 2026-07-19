package com.flashfla.utils;

import flash.globalization.DateTimeFormatter;

class DateUtil
{
    public static function toRFC822(d : Date) : String
    {
        var dtf : DateTimeFormatter = new DateTimeFormatter("en-US");
        dtf.setDateTimePattern("EEE, dd MMMMM yyyy HH.mm.ss");
        return dtf.formatUTC(Date.now());
    }
    
    public static function minutesToString(length : Int) : String
    {
        if (length == 10080)
        {
            return "1 week";
        }
        if (length == 20160)
        {
            return "2 weeks";
        }
        if (length == 40320)
        {
            return "1 month";
        }
        if (length == 241920)
        {
            return "6 months";
        }
        
        // Years
        var years : Int = Math.floor(length / 525600);
        length -= as3hx.Compat.parseInt(years * 525600);
        
        // days
        var days : Int = Math.floor(length / 1440);
        length -= as3hx.Compat.parseInt(days * 1440);
        
        // hours
        var hours : Int = Math.floor(length / 60);
        length -= as3hx.Compat.parseInt(hours * 60);
        
        // minutes
        var minutes : Int = length;
        
        // Format and return
        var timeParts : Array<Dynamic> = [];
        var sections : Array<Dynamic> = [["year", years], 
        ["day", days], 
        ["hour", hours], 
        ["minute", minutes]
    ];
        
        for (section in sections)
        {
            if (Reflect.field(section, Std.string(1)) > 0)
            {
                timeParts.push(Reflect.field(section, Std.string(1)) + " " + Reflect.field(section, Std.string(0)) + ((Reflect.field(section, Std.string(1)) == 1) ? "" : "s"));
            }
        }
        
        return timeParts.join(", ");
    }

    public function new()
    {
    }
}

