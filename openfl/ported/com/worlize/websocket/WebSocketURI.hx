package com.worlize.websocket;


class WebSocketURI
{
    public var scheme : String;
    public var host : String;
    public var port : Int;
    public var path : String;
    
    public function new(host : String, port : Int = 80, scheme : String = "ws", path : String = "/")
    {
        this.host = host;
        this.port = port;
        this.scheme = scheme;
        this.path = path;
    }
}

