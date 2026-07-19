package classes.mp.events;

import classes.mp.MPSocketDataText;
import classes.mp.MPUser;

class MPUserEvent extends MPEvent
{
    public var user                             : Dynamic;
    public var user_sender                             : Dynamic;
    
    public function new(type                             : Dynamic, command                             : Dynamic, user                             : Dynamic= null, user_sender                             : Dynamic= null)
    {
        super(type, command);
        
        this.user = user;
        this.user_sender = user_sender;
    }
    
    override public function toString() : String
    {
        return "---------------------------------\n[MPUserEvent type=" + type + "]" + "\n" + command;
    }
}

