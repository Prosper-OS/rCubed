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


@:final class WebSocketCloseStatus
{
    // http://tools.ietf.org/html/rfc6455#section-7.4
    public static inline var NORMAL : Int = 1000;
    public static inline var GOING_AWAY : Int = 1001;
    public static inline var PROTOCOL_ERROR : Int = 1002;
    public static inline var UNPROCESSABLE_INPUT : Int = 1003;
    public static inline var UNDEFINED : Int = 1004;
    public static inline var NO_CODE : Int = 1005;
    public static inline var NO_CLOSE : Int = 1006;
    public static inline var BAD_PAYLOAD : Int = 1007;
    public static inline var POLICY_VIOLATION : Int = 1008;
    public static inline var MESSAGE_TOO_LARGE : Int = 1009;
    public static inline var REQUIRED_EXTENSION : Int = 1010;
    public static inline var SERVER_ERROR : Int = 1011;
    public static inline var FAILED_TLS_HANDSHAKE : Int = 1015;

    public function new()
    {
    }
}

