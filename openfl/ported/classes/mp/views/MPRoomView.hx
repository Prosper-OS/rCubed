package classes.mp.views;

import classes.mp.MPView;
import classes.mp.components.MPMenuRoomButton;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import openfl.display.DisplayObjectContainer;

class MPRoomView extends MPView
{
    public var roomButton                             : Dynamic;
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0)
    {
        super(parent, xpos, ypos);
        
        addRoomEvents();
        build();
    }
    
    public function addRoomEvents() : Void
    {
        _mp.addEventListener(MPEvent.ROOM_EDIT_OK, e_roomEdit);
        _mp.addEventListener(MPEvent.ROOM_UPDATE, e_roomUpdate);
        _mp.addEventListener(MPEvent.ROOM_MESSAGE, e_roomMessage);
        
        _mp.addEventListener(MPEvent.ROOM_TEAM_UPDATE, e_teamUpdate);
        _mp.addEventListener(MPEvent.ROOM_TEAM_ADD, e_teamUpdate);
        _mp.addEventListener(MPEvent.ROOM_TEAM_REMOVE, e_teamUpdate);
        _mp.addEventListener(MPEvent.ROOM_TEAM_CAPTAIN, e_teamUpdate);
        
        _mp.addEventListener(MPEvent.ROOM_USER_JOIN, e_userJoin);
        _mp.addEventListener(MPEvent.ROOM_USER_LEAVE, e_userLeave);
    }
    
    override public function dispose() : Void
    {
        _mp.removeEventListener(MPEvent.ROOM_EDIT_OK, e_roomEdit);
        _mp.removeEventListener(MPEvent.ROOM_UPDATE, e_roomUpdate);
        _mp.removeEventListener(MPEvent.ROOM_MESSAGE, e_roomMessage);
        
        _mp.removeEventListener(MPEvent.ROOM_TEAM_UPDATE, e_teamUpdate);
        _mp.removeEventListener(MPEvent.ROOM_TEAM_ADD, e_teamUpdate);
        _mp.removeEventListener(MPEvent.ROOM_TEAM_REMOVE, e_teamUpdate);
        _mp.removeEventListener(MPEvent.ROOM_TEAM_CAPTAIN, e_teamUpdate);
        
        _mp.removeEventListener(MPEvent.ROOM_USER_JOIN, e_userJoin);
        _mp.removeEventListener(MPEvent.ROOM_USER_LEAVE, e_userLeave);
        
        onExit();
    }
    
    public function setRoomButton(btn                             : Dynamic) : Void
    {
        this.roomButton = btn;
        updateRoomButton();
    }
    
    public function updateRoomButton() : Void
    {
    }
    
    public function e_roomEdit(e                             : Dynamic) : Void
    {
    }
    
    public function e_roomUpdate(e                             : Dynamic) : Void
    {
    }
    
    public function e_roomMessage(e                             : Dynamic) : Void
    {
    }
    
    public function e_teamUpdate(e                             : Dynamic) : Void
    {
    }
    
    public function e_userLeave(e                             : Dynamic) : Void
    {
    }
    
    public function e_userJoin(e                             : Dynamic) : Void
    {
    }
}

