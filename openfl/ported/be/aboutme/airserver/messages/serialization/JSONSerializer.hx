package be.aboutme.airserver.messages.serialization;

import be.aboutme.airserver.messages.Message;

class JSONSerializer implements IMessageSerializer
{
    
    private var messageDelimiter : String;
    
    public function new(messageDelimiter : String = "\n")
    {
        this.messageDelimiter = messageDelimiter;
    }
    
    public function serialize(message : Message) : Dynamic
    {
        return haxe.Json.stringify(message);
    }
    
    public function deserialize(serialized : Dynamic) : Array<Message>
    {
        var split : Array<Dynamic> = serialized.split(messageDelimiter);
        var messages : Array<Message> = new Array<Message>();
        for (input in split)
        {
            if (input.length > 0)
            {
                var decoded : Dynamic = haxe.Json.parse(input);
                var message : Message = new Message();
                if (decoded.exists("senderId"))
                {
                    message.senderId = decoded.senderId;
                }
                if (decoded.exists("command"))
                {
                    message.command = decoded.command;
                }
                if (decoded.exists("data"))
                {
                    message.data = decoded.data;
                }
                else
                {
                    message.data = decoded;
                }
                messages.push(message);
            }
        }
        return messages;
    }
}

