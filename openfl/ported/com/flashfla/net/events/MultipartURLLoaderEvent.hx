package com.flashfla.net.events;

import openfl.events.Event;

/**
 * MultipartURLLoader Event for async data prepare tracking
 * @author Eugene Zatepyakin
 */
class MultipartURLLoaderEvent extends Event
{
    public static inline var DATA_PREPARE_PROGRESS : String = "dataPrepareProgress";
    public static inline var DATA_PREPARE_COMPLETE : String = "dataPrepareComplete";
    
    public var bytesWritten : Int = 0;
    public var bytesTotal : Int = 0;
    
    public function new(type : String, w : Int = 0, t : Int = 0)
    {
        super(type);
        
        bytesTotal = t;
        bytesWritten = w;
    }
}

