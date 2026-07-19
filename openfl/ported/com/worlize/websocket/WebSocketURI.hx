package com.worlize.websocket;


class WebSocketURI
{
    public var scheme                          : Dynamic;
    public var host                          : Dynamic;
    public var port                          : Dynamic;
    public var path                          : Dynamic;
    
    public function new(host                          : Dynamic, port                          : Dynamic= 80, scheme                          : Dynamic= "ws", path                          : Dynamic= "/")
    {
        this.host = host;
        this.port = port;
        this.scheme = scheme;
        this.path = path;
    }
}

