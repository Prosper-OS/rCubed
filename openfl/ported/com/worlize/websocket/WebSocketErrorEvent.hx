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

import openfl.events.ErrorEvent;

class WebSocketErrorEvent extends ErrorEvent
{
    public static inline var CONNECTION_FAIL                          : Dynamic= "connectionFail";
    public static inline var ABNORMAL_CLOSE                          : Dynamic= "abnormalClose";
    
    public function new(type                          : Dynamic, bubbles                          : Dynamic= false, cancelable                          : Dynamic= false, text                          : Dynamic= "")
    {
        super(type, bubbles, cancelable, text);
    }
}

