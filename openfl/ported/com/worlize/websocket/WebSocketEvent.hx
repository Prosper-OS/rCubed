/************************************************************************
 *  Copyright 2010-2012 Worlize Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ***********************************************************************/

package com.worlize.websocket;

import openfl.events.Event;

class WebSocketEvent extends Event
{
    public static inline var OPEN                          : Dynamic= "open";
    public static inline var CLOSED                          : Dynamic= "closed";
    public static inline var MESSAGE                          : Dynamic= "message";
    public static inline var FRAME                          : Dynamic= "frame";
    public static inline var PING                          : Dynamic= "ping";
    public static inline var PONG                          : Dynamic= "pong";
    
    public var message                          : Dynamic;
    public var frame                          : Dynamic;
    
    public function new(type                          : Dynamic, bubbles                          : Dynamic= false, cancelable                          : Dynamic= false)
    {
        super(type, bubbles, cancelable);
    }
}

