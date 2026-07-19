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


@:final class WebSocketOpcode
{
    // non-control opcodes
    public static inline var CONTINUATION                          : Dynamic= 0x00;
    public static inline var TEXT_FRAME                          : Dynamic= 0x01;
    public static inline var BINARY_FRAME                          : Dynamic= 0x02;
    public static inline var EXT_DATA                          : Dynamic= 0x03;
    // 0x04 - 0x07 = Reserved for further control frames
    
    // Control opcodes
    public static inline var CONNECTION_CLOSE                          : Dynamic= 0x08;
    public static inline var PING                          : Dynamic= 0x09;
    public static inline var PONG                          : Dynamic= 0x0A;
    public static inline var EXT_CONTROL                          : Dynamic= 0x0B;

    public function new()
    {
    }
}

