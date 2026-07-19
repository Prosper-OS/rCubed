package be.aboutme.airserver.messages.serialization;

import be.aboutme.airserver.messages.Message;

class JSONSerializer implements IMessageSerializer
{
    
    public var messageDelimiter                              : Dynamic;
    
    public function new(messageDelimiter                              : Dynamic= "\n")
    {
        this.messageDelimiter = messageDelimiter;
    }
    
    public function serialize(message                              : Dynamic) : Dynamic
    {
        return haxe.Json.stringify(message);
    }
    
    public function deserialize(serialized                              : Dynamic) : Array<Message>
    {
        var split                              : Dynamic= serialized.split(messageDelimiter);
        var messages                              : Dynamic= new Array<Message>();
        for (input in as3hx.Compat.iter(split))
        {
            if (as3hx.Compat.truthy(input.length > 0))
            {
                var decoded                              : Dynamic= haxe.Json.parse(input);
                var message                              : Dynamic= new Message();
                if (as3hx.Compat.truthy(decoded.exists("senderId")))
                {
                    message.senderId = decoded.senderId;
                }
                if (as3hx.Compat.truthy(decoded.exists("command")))
                {
                    message.command = decoded.command;
                }
                if (as3hx.Compat.truthy(decoded.exists("data")))
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

