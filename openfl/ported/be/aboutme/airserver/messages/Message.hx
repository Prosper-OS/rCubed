package be.aboutme.airserver.messages;


class Message
{
    public var senderId : Int;
    public var command : String = "";
    public var data : Dynamic = "";
    
    public function new()
    {
    }
    
    public function toString() : String
    {
        return "[Message " + data + "]";
    }
}

