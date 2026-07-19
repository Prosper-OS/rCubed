package classes.mp.views;

import classes.mp.components.MPViewChatLogRoom;
import classes.mp.components.MPViewUserListRoom;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.prompts.MPUserProfilePrompt;
import classes.mp.room.MPRoom;
import classes.ui.Text;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

class MPRoomViewLobby extends MPRoomView
{
    public var room                             : Dynamic;
    
    private var _width                             : Dynamic= 409;
    private var _height                             : Dynamic= 388;
    
    private var roomName                             : Dynamic;
    
    private var chat                             : Dynamic;
    private var userlist                             : Dynamic;
    
    private var _userProfilePrompt                             : Dynamic;
    
    public function new(room                             : Dynamic, parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0)
    {
        this.room = room;
        
        super(parent, xpos, ypos);
    }
    
    override public function build() : Void
    {
        super.build();
        
        chat = new MPViewChatLogRoom(this, 0, 30, _width, _height - 30);
        chat.setRoom(room);
        
        // Userlist
        userlist = new MPViewUserListRoom(this, 410, 0);
        userlist.setRoom(room);
        userlist.addEventListener(MPEvent.ROOM_USERLIST_SELECT, e_onUserSelect);
        
        // Name
        new Text(this, 5, 0, "#", 14, "#c0c0c0").setAreaParams(15, 30);
        
        roomName = new Text(this, 20, 0, room.name, 16);
        roomName.setAreaParams(_width - 25, 30);
        
        // Graphics
        redraw();
    }
    
    public function redraw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        
        // Title BG
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, 30);
        this.graphics.endFill();
        
        // BG
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        // Title
        this.graphics.moveTo(1, 30);
        this.graphics.lineTo(_width, 30);
    }
    
    override public function onKeyInput(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_userProfilePrompt != null))
        {
            _userProfilePrompt.onKeyInput(e);
            return;
        }
        
        chat.onKeyInput(e);
    }
    
    public function onChatMessage(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            chat.onChatMessage(e);
        }
    }
    
    override public function updateRoomButton() : Void
    {
        this.roomButton.updateText(room.name, sprintf(_lang.string("mp_btn_user_count"), {
                            count : room.userCount
                        }));
    }
    
    override private function set_width(value                             : Dynamic) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value                             : Dynamic) : Float
    {
        _height = height;
        redraw();
        return value;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    override public function e_roomMessage(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            onChatMessage(e);
        }
    }
    
    override public function e_teamUpdate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
        }
    }
    
    override public function e_userJoin(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            updateRoomButton();
        }
    }
    
    override public function e_userLeave(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room == this.room))
        {
            userlist.update();
            updateRoomButton();
        }
    }
    
    override public function dispose() : Void
    {
        if (as3hx.Compat.truthy(_userProfilePrompt != null))
        {
            _userProfilePrompt.close();
            _userProfilePrompt = null;
        }
        
        super.dispose();
    }
    
    private function e_onUserSelect(e                             : Dynamic) : Void
    {
        _userProfilePrompt = new MPUserProfilePrompt(e.user, this.room, this);
        _userProfilePrompt.addEventListener(Event.CLOSE, e_onProfileClose);
    }
    
    private function e_onProfileClose(e                             : Dynamic) : Void
    {
        _userProfilePrompt.removeEventListener(Event.CLOSE, e_onProfileClose);
        _userProfilePrompt = null;
    }
}

