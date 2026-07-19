package be.aboutme.airserver.endpoints;

import be.aboutme.airserver.messages.Message;
import openfl.events.IEventDispatcher;

interface IClientHandler extends IEventDispatcher
{
    
    var messagesAvailable(get, never)                              : Dynamic;

    function close() : Void
    ;
    function readMessage() : Message
    ;
    function writeMessage(messageToWrite                              : Dynamic) : Void
    ;
}

