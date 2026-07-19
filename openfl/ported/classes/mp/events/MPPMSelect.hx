package classes.mp.events;

import classes.mp.pm.MPUserChatHistory;
import openfl.events.Event;

class MPPMSelect extends Event
{
    public static inline var CHAT_SELECT                             : Dynamic= "chat_select";
    
    public var chat                             : Dynamic;
    
    public function new(chat                             : Dynamic)
    {
        this.chat = chat;
        super(CHAT_SELECT);
    }
}

