package be.aboutme.airserver.messages.serialization;

import be.aboutme.airserver.messages.Message;

interface IMessageSerializer
{

    function serialize(message : Message) : Dynamic
    ;
    function deserialize(serialized : Dynamic) : Array<Message>
    ;
}

