package classes.mp.components.browser;

import assets.menu.icons.fa.IconLock;
import assets.menu.icons.fa.IconProfile;
import assets.menu.icons.fa.IconUsers;
import classes.Language;
import classes.mp.room.MPRoom;
import classes.ui.Text;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class MPBrowserEntry extends Sprite
{
    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    public static inline var ENTRY_HEIGHT                             : Dynamic= 50;
    
    public var room                             : Dynamic;
    
    private var title                             : Dynamic;
    private var users                             : Dynamic;
    private var range                             : Dynamic;
    private var type                             : Dynamic;
    private var owner                             : Dynamic;
    
    private var lockIcon                             : Dynamic;
    
    public var index                             : Dynamic= 0;
    public var isStale                             : Dynamic= false;
    
    public function new()
    {
        super();
        lockIcon = new IconLock();
        lockIcon.scaleX = lockIcon.scaleY = (15 / lockIcon.height);
        lockIcon.x = 15;
        lockIcon.y = 15;
        this.addChild(lockIcon);
        
        var usersIcon                             : Dynamic= new IconUsers();
        usersIcon.scaleX = usersIcon.scaleY = (17 / usersIcon.width);
        usersIcon.x = 564;
        usersIcon.y = 15;
        this.addChild(usersIcon);
        
        var profileIcon                             : Dynamic= new IconProfile();
        profileIcon.scaleX = profileIcon.scaleY = (15 / profileIcon.height);
        profileIcon.x = 564;
        profileIcon.y = 37;
        this.addChild(profileIcon);
        
        // Text
        title = new Text(this, 6, 6, "???", 16);
        title.setAreaParams(542, 20);
        
        users = new Text(this, 450, 6, "???", 13);
        users.setAreaParams(100, 20, "right");
        
        range = new Text(this, 550, 5, "???", 11);
        range.setAreaParams(100, 20, "right");
        
        type = new Text(this, 6, 27, "???", 12, "#d6d6d6");
        type.setAreaParams(542, 20);
        
        owner = new Text(this, 6, 27, "???", 12, "#d6d6d6");
        owner.setAreaParams(542, 20, "right");
        
        this.mouseChildren = false;
        this.buttonMode = true;
        
        this.addEventListener(MouseEvent.MOUSE_OVER, e_onOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, e_onOut);
        
        draw(false);
    }
    
    public function draw(hover                             : Dynamic) : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, (hover) ? 0.2 : 0.1);
        this.graphics.drawRect(0, 0, 579, ENTRY_HEIGHT);
        this.graphics.endFill();
    }
    
    public function setData(item                             : Dynamic) : Void
    {
        room = item;
        
        title.text = room.name;
        type.text = _lang.string("mp_room_type_" + room.type);
        owner.text = room.ownerName;
        
        if (as3hx.Compat.truthy(room.teamCount > 0))
        {
            users.text = (room.userCount - room.spectatorCount) + "/" + (room.maxPlayers * (room.teamCount - 1)) + ((room.spectatorCount > 0) ? (" - " + room.spectatorCount) : "");
        }
        else
        {
            users.text = Std.string(room.spectatorCount);
        }
        
        if (as3hx.Compat.truthy(room.skillMin >= 0 && room.skillMax >= 0))
        {
            range.visible = true;
            
            if (as3hx.Compat.truthy(room.skillMin == room.skillMax))
            {
                range.text = "[ <font color=\"" + _gvars.getDivisionColor(room.skillMin) + "\">" + room.skillMin + "</font> ]";
            }
            else
            {
                range.text = "[ <font color=\"" + _gvars.getDivisionColor(room.skillMin) + "\">" + room.skillMin + "</font> - <font color=\"" + _gvars.getDivisionColor(room.skillMax) + "\">" + room.skillMax + " </font>]";
            }
        }
        else
        {
            range.visible = false;
        }
        
        range.x = 550 - users.textfield.textWidth - range.width - 10;
        
        if (as3hx.Compat.truthy(item.hasPassword))
        {
            lockIcon.visible = true;
            title.x = 26;
            title.width = range.x + range.width - range.textfield.textWidth - 46;
        }
        else
        {
            lockIcon.visible = false;
            title.x = 6;
            title.width = range.x + range.width - range.textfield.textWidth - 20;
        }
    }
    
    public function clear() : Void
    {
        room = null;
    }
    
    private function e_onOver(event                             : Dynamic) : Void
    {
        draw(true);
    }
    
    private function e_onOut(event                             : Dynamic) : Void
    {
        draw(false);
    }
}

