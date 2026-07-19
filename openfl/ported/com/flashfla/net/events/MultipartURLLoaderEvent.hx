package com.flashfla.net.events;

import openfl.events.Event;

/**
 * MultipartURLLoader Event for async data prepare tracking
 * @author Eugene Zatepyakin
 */
class MultipartURLLoaderEvent extends Event
{
    public static inline var DATA_PREPARE_PROGRESS                            : Dynamic= "dataPrepareProgress";
    public static inline var DATA_PREPARE_COMPLETE                            : Dynamic= "dataPrepareComplete";
    
    public var bytesWritten                            : Dynamic= 0;
    public var bytesTotal                            : Dynamic= 0;
    
    public function new(type                            : Dynamic, w                            : Dynamic= 0, t                            : Dynamic= 0)
    {
        super(type);
        
        bytesTotal = t;
        bytesWritten = w;
    }
}

