package classes.mp.events;

import classes.mp.MPSocketDataRaw;
import classes.mp.MPUser;
import classes.mp.room.MPRoom;
import openfl.events.Event;

class MPRoomRawEvent extends Event
{
    public var room                             : Dynamic;
    public var user                             : Dynamic;
    public var command                             : Dynamic;
    
    public function new(type                             : Dynamic, command                             : Dynamic, room                             : Dynamic, user                             : Dynamic= null)
    {
        super(type);
        
        this.command = command;
        this.room = room;
        this.user = user;
    }
}

