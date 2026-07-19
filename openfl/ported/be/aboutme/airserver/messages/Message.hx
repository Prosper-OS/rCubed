package be.aboutme.airserver.messages;


class Message
{
    public var senderId                              : Dynamic;
    public var command                              : Dynamic= "";
    public var data                              : Dynamic= "";
    
    public function new()
    {
    }
    
    public function toString() : String
    {
        return "[Message " + data + "]";
    }
}

