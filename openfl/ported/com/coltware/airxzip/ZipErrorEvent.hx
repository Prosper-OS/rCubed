package com.coltware.airxzip;

import openfl.events.ErrorEvent;

class ZipErrorEvent extends ErrorEvent
{
    public static inline var ZIP_NO_SUCH_METHOD                            : Dynamic= "ZipNoSuchMethod";
    /**
		 *  Password is not match or not set(NULL)
		 */
    public static inline var ZIP_PASSWORD_ERROR                            : Dynamic= "ZipPasswordError";
    
    public function new(type                            : Dynamic, bubbles                            : Dynamic= false, cancelable                            : Dynamic= false, text                            : Dynamic= null, id                            : Dynamic= 0)
    {
        super(type, bubbles, cancelable, text, id);
    }
}
