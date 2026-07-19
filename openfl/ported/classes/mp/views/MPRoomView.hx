package classes.mp.views;

import classes.mp.MPView;
import classes.mp.components.MPMenuRoomButton;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import openfl.display.DisplayObjectContainer;

class MPRoomView extends MPView
{
    private var roomButton : MPMenuRoomButton;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0)
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
    
    public function setRoomButton(btn : MPMenuRoomButton) : Void
    {
        this.roomButton = btn;
        updateRoomButton();
    }
    
    private function updateRoomButton() : Void
    {
    }
    
    private function e_roomEdit(e : MPRoomEvent) : Void
    {
    }
    
    private function e_roomUpdate(e : MPRoomEvent) : Void
    {
    }
    
    private function e_roomMessage(e : MPRoomEvent) : Void
    {
    }
    
    private function e_teamUpdate(e : MPRoomEvent) : Void
    {
    }
    
    private function e_userLeave(e : MPRoomEvent) : Void
    {
    }
    
    private function e_userJoin(e : MPRoomEvent) : Void
    {
    }
}

