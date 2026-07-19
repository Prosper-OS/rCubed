package be.aboutme.airserver.messages.serialization;

import be.aboutme.airserver.messages.Message;

interface IMessageSerializer
{

    function serialize(message                              : Dynamic) : Dynamic
    ;
    function deserialize(serialized                              : Dynamic) : Array<Message>
    ;
}

