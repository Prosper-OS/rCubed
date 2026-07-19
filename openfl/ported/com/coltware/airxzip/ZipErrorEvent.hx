package com.coltware.airxzip;

import openfl.events.ErrorEvent;

class ZipErrorEvent extends ErrorEvent
{
    public static inline var ZIP_NO_SUCH_METHOD : String = "ZipNoSuchMethod";
    /**
		 *  Password is not match or not set(NULL)
		 */
    public static inline var ZIP_PASSWORD_ERROR : String = "ZipPasswordError";
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, text : String = null, id : Int = 0)
    {
        super(type, bubbles, cancelable, text, id);
    }
}
