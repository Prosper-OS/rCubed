package classes.mp.events;

import classes.mp.MPSocketDataText;
import classes.mp.MPUser;
import classes.mp.room.MPRoom;

class MPRoomEvent extends MPEvent
{
    public var room                             : Dynamic;
    public var user                             : Dynamic;
    
    public function new(type                             : Dynamic, command                             : Dynamic, room                             : Dynamic, user                             : Dynamic= null)
    {
        super(type, command);
        
        this.room = room;
        this.user = user;
    }
    
    override public function toString() : String
    {
        return "---------------------------------\n[MPRoomEvent type=" + type + "]" + "\n" + command;
    }
}

