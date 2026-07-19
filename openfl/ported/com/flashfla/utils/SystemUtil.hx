package com.flashfla.utils;

import openfl.errors.Error;
import r3.air.desktop.Clipboard;
import r3.air.desktop.ClipboardFormats;
import openfl.system.Capabilities;
import openfl.system.System;

class SystemUtil
{
    public static var versionArray                           : Dynamic;
    public static var OS                           : Dynamic;
    public static var flashMajorVersion                           : Dynamic;
    public static var flashMinorVersion                           : Dynamic;
    public static var flashBuildVersion                           : Dynamic;
    
    
    
    public static function getFlashVersion() : Dynamic
    {
        return {
            os : OS,
            major : flashMajorVersion,
            minor : flashMinorVersion,
            build : flashBuildVersion
        };
    }
    
    public static function gc() : Void
    {
        System.gc();
    }
    
    public static function setClipboard(value                           : Dynamic) : Bool
    // FP10+
    {
        
        try
        {
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, value);
            return true;
        }
        catch (e : Error) {
{ };
        }
        
        
        
        try
        {
            System.setClipboard(value);
            return true;
        }
        catch (e : Error)
        {
        }
        
        return false;
    }

    public function new()
    {
    }
    private static var SystemUtil_static_initializer = {
        {
            // Get the player?s version by using the openfl.system.Capabilities class.
            versionArray = StringUtil.splitMultiple(Capabilities.version, [" ", ","]);
            
            //versionArray = ["WIN", 9, 0, 0];
            
            OS = versionArray[0].toLowerCase();
            flashMajorVersion = as3hx.Compat.parseInt(versionArray[1]);
            flashMinorVersion = as3hx.Compat.parseInt(versionArray[2]);
            flashBuildVersion = as3hx.Compat.parseInt(versionArray[3]);
        };
        true;
    }

}

