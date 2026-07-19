package classes.mp.prompts;

import assets.menu.icons.fa.IconClose;
import classes.Language;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCRoomInvite;
import classes.mp.components.userlist.MPUserListEntry;
import classes.mp.components.userlist.MPUserlistScrollpane;
import classes.mp.room.MPRoom;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.BoxText;
import classes.ui.Prompt;
import classes.ui.ScrollBar;
import classes.ui.Text;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

class MPRoomUserInvitePrompt extends Prompt
{
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    private var scrollbarWidth(default, never) : Float = 15;
    
    private var search_field : BoxText;
    private var search_field_placeholder : Text;
    private var _search_text : String = "";
    
    public var room : MPRoom;
    
    private var closeButton : BoxIcon;
    private var confirmButton : BoxButton;
    
    public var userPane : MPUserlistScrollpane;
    public var userScroll : ScrollBar;
    
    public var invitePane : MPUserlistScrollpane;
    public var inviteScroll : ScrollBar;
    public var inviteUserList : Array<Dynamic> = [];
    
    public function new(room : MPRoom, parent : DisplayObject)
    {
        super(parent.stage, 530, 370);
        
        this.room = room;
        
        new Text(this, 10, 10, _lang.string("mp_room_invite_players"), 16).setAreaParams(width - 45, 22);
        _content.graphics.moveTo(10, 40);
        _content.graphics.lineTo(width - 9, 40);
        
        closeButton = new BoxIcon(this, _width - 32, 10, 22, 22, new IconClose(), e_closeHandler);
        
        // User List
        new Text(this, 9, 43, _lang.string("mp_room_invite_player_list")).setAreaParams(235, 22);
        userPane = new MPUserlistScrollpane(this, 12, 67, 220, 240);
        userPane.addEventListener(MouseEvent.MOUSE_WHEEL, e_userWheelHandler);
        userPane.addEventListener(MouseEvent.CLICK, e_userEntryClick);
        userScroll = new ScrollBar(this, userPane.x + userPane.width + 1, userPane.y, scrollbarWidth, userPane.height, null, new Sprite(), e_userBarUpdater);
        userScroll.draggerVisibility = false;
        
        _content.graphics.beginFill(0xFFFFFF, 0.05);
        _content.graphics.drawRect(userPane.x, userPane.y, userPane.width + scrollbarWidth, userPane.height - 1);
        _content.graphics.endFill();
        _content.graphics.moveTo(userPane.x + userPane.width, userPane.y);
        _content.graphics.lineTo(userPane.x + userPane.width, userPane.y + userPane.height - 1);
        
        // Invite List
        new Text(this, 279, 43, _lang.string("mp_room_invite_player_list_selected")).setAreaParams(235, 22);
        invitePane = new MPUserlistScrollpane(this, 282, 67, 220, 240);
        invitePane.addEventListener(MouseEvent.MOUSE_WHEEL, e_inviteWheelHandler);
        invitePane.addEventListener(MouseEvent.CLICK, e_inviteEntryClick);
        inviteScroll = new ScrollBar(this, invitePane.x + invitePane.width + 1, invitePane.y, scrollbarWidth, invitePane.height, null, new Sprite(), e_userBarUpdater);
        inviteScroll.draggerVisibility = false;
        
        _content.graphics.beginFill(0xFFFFFF, 0.05);
        _content.graphics.drawRect(invitePane.x, invitePane.y, invitePane.width + scrollbarWidth + 1, invitePane.height - 1);
        _content.graphics.endFill();
        _content.graphics.moveTo(invitePane.x + invitePane.width, invitePane.y);
        _content.graphics.lineTo(invitePane.x + invitePane.width, invitePane.y + invitePane.height - 1);
        
        // Search
        search_field_placeholder = new Text(this, 17, _height - 42, _lang.string("mp_user_search"));
        search_field_placeholder.setAreaParams(235, 27, "left");
        search_field_placeholder.alpha = 0.6;
        
        search_field = new BoxText(this, 12, _height - 45, 235, 29);
        search_field.addEventListener(Event.CHANGE, e_searchChange, false, 0, true);
        search_field.field.y += 1;
        
        // Confirm
        confirmButton = new BoxButton(this, _width - 112, _height - 45, 100, 29, _lang.string("mp_room_invite_confirm"), 11, e_confirmHandler);
        
        updateUserList();
    }
    
    public function onKeyInput(e : KeyboardEvent) : Void
    {
    }
    
    private function e_searchChange(e : Event) : Void
    {
        _search_text = search_field.text.toLowerCase();
        search_field_placeholder.visible = (_search_text.length <= 0);
        
        updateUserList();
    }
    
    private function updateUserList() : Void
    {
        var render_list : Array<Dynamic> = [];
        for (r/* AS3HX WARNING could not determine type for var: r exp: EField(EIdent(_mp),users) type: null */ in _mp.users)
        {
            if (_search_text.length >= 1 && r.name.toLowerCase().indexOf(_search_text) == -1)
            {
                continue;
            }
            
            if (r.sid <= 1)
            {
                continue;
            }
            
            render_list[render_list.length] = r;
        }
        userPane.setRenderList(render_list);
        
        userPane.scrollTo(0);
        userScroll.scrollTo(0);
        
        userScroll.draggerVisibility = userPane.doScroll;
    }
    
    public function e_userWheelHandler(e : MouseEvent) : Void
    // Sanity
    {
        
        if (!userScroll.draggerVisibility)
        {
            return;
        }
        
        // Scroll
        var newScrollPosition : Float = userScroll.scroll + (userPane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        userPane.scrollTo(newScrollPosition);
        userScroll.scrollTo(newScrollPosition);
    }
    
    private function e_userBarUpdater(e : Event) : Void
    {
        userPane.scrollTo(e.target.scroll);
    }
    
    public function e_userEntryClick(e : MouseEvent) : Void
    {
        if (Std.is(e.target, MPUserListEntry))
        {
            var target : MPUserListEntry = try cast(e.target, MPUserListEntry) catch(e:Dynamic) null;
            var targetUser : MPUser = target.user;
            var idx : Float = Lambda.indexOf(inviteUserList, targetUser);
            
            if (idx >= 0)
            {
                inviteUserList.splice(idx, 1);
            }
            else
            {
                inviteUserList.push(targetUser);
            }
            
            invitePane.setRenderList(inviteUserList);
            
            invitePane.scrollTo(0);
            inviteScroll.scrollTo(0);
            
            inviteScroll.draggerVisibility = userPane.doScroll;
        }
    }
    
    public function e_inviteWheelHandler(e : MouseEvent) : Void
    // Sanity
    {
        
        if (!inviteScroll.draggerVisibility)
        {
            return;
        }
        
        // Scroll
        var newScrollPosition : Float = inviteScroll.scroll + (invitePane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        invitePane.scrollTo(newScrollPosition);
        inviteScroll.scrollTo(newScrollPosition);
    }
    
    private function e_inviteBarUpdater(e : Event) : Void
    {
        invitePane.scrollTo(e.target.scroll);
    }
    
    public function e_inviteEntryClick(e : MouseEvent) : Void
    {
        if (Std.is(e.target, MPUserListEntry))
        {
            var target : MPUserListEntry = try cast(e.target, MPUserListEntry) catch(e:Dynamic) null;
            var targetUser : MPUser = target.user;
            var idx : Float = Lambda.indexOf(inviteUserList, targetUser);
            
            if (idx >= 0)
            {
                inviteUserList.splice(idx, 1);
            }
            
            invitePane.setRenderList(inviteUserList);
            
            invitePane.scrollTo(0);
            inviteScroll.scrollTo(0);
            
            inviteScroll.draggerVisibility = userPane.doScroll;
        }
    }
    
    private function e_confirmHandler(e : MouseEvent) : Void
    {
        for (user in inviteUserList)
        {
            _mp.sendCommand(new MPCRoomInvite(user, room));
        }
        
        close();
        dispatchEvent(new Event(Event.CLOSE));
    }
    
    private function e_closeHandler(e : MouseEvent) : Void
    {
        close();
        dispatchEvent(new Event(Event.CLOSE));
    }
}

