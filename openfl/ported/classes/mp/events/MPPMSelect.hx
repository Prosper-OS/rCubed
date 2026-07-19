package classes.mp.events;

import classes.mp.pm.MPUserChatHistory;
import openfl.events.Event;

class MPPMSelect extends Event
{
    public static inline var CHAT_SELECT : String = "chat_select";
    
    public var chat : MPUserChatHistory;
    
    public function new(chat : MPUserChatHistory)
    {
        this.chat = chat;
        super(CHAT_SELECT);
    }
}

