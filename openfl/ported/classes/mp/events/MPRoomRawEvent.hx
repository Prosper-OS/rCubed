package classes.mp.events;

import classes.mp.MPSocketDataRaw;
import classes.mp.MPUser;
import classes.mp.room.MPRoom;
import openfl.events.Event;

class MPRoomRawEvent extends Event
{
    public var room : MPRoom;
    public var user : MPUser;
    public var command : MPSocketDataRaw;
    
    public function new(type : String, command : MPSocketDataRaw, room : MPRoom, user : MPUser = null)
    {
        super(type);
        
        this.command = command;
        this.room = room;
        this.user = user;
    }
}

