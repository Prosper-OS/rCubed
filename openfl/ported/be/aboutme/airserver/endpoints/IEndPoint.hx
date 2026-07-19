package be.aboutme.airserver.endpoints;

import openfl.events.IEventDispatcher;

interface IEndPoint extends IEventDispatcher
{

    function open() : Bool
    ;
    function close() : Void
    ;
    function type() : String
    ;
    function currentPort() : Int
    ;
}

