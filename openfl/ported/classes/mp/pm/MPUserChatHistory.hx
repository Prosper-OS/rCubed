package classes.mp.pm;

import classes.Language;
import classes.mp.MPColors;
import classes.mp.MPUser;
import classes.mp.components.MPChatTypes;
import classes.mp.components.chatlog.MPChatLogEntry;
import classes.mp.components.chatlog.MPChatLogEntryText;
import classes.mp.components.chatlog.MPChatLogRoomInvite;
import com.flashfla.utils.Sprintf.sprintf;
import r3.air.desktop.NotificationType;

class MPUserChatHistory
{
    private static var _lang : Language = Language.instance;
    private static var DATE : Date = Date.now();
    
    private var MAX_HISTORY : Int = 200;
    public var messages : Array<MPChatLogEntry> = [];
    public var user : MPUser;
    public var newMessage : Bool = false;
    public var lastMessage : Float = 0;
    
    public function new(user : MPUser)
    {
        this.user = user;
        
        add(new MPChatLogEntryText("<font color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\">" + sprintf(_lang.string("mp_pm_chat_start"), {
                            name : user.name
                        }) + "</font>"));
    }
    
    public function add(entry : MPChatLogEntry) : Void
    {
        lastMessage = Date.now().getTime();
        messages.push(entry);
        
        if (messages.length > MAX_HISTORY)
        {
            messages.splice(0, messages.length - MAX_HISTORY);
        }
    }
    
    public function addMessage(user : MPUser, sender : MPUser, data : Dynamic) : Void
    {
        DATE.setTime(data.timestamp);
        
        var type : Float = data.type;
        var color : String = ((type == MPChatTypes.ADMIN) ? MPColors.MESSAGE_ADMIN_COLOR : ((type == MPChatTypes.MOD) ? MPColors.MESSAGE_MOD_COLOR : MPColors.MESSAGE_COLOR));
        
        var message : String = "";
        
        if (type == MPChatTypes.SYSTEM)
        {
            message += "<font face=\"" + Fonts.BASE_FONT + "\" color=\"" + MPColors.SYSTEM_MESSAGE_COLOR + "\"><i>" + data.message + "</i></font>";
        }
        else
        {
            message += sender.nameHTML + ":  ";
            message += "<font color=\"" + color + "\">" + data.message + "</font>";
        }
        
        add(new MPChatLogEntryText(message));
        newMessage = true;
    }
    
    public function addGameInvite(user : MPUser, sender : MPUser, data : Dynamic) : Void
    {
        Main.window.notifyUser(NotificationType.INFORMATIONAL);
        
        add(new MPChatLogRoomInvite(sender, data));
        newMessage = true;
    }
    
    public function clear() : Void
    {
        as3hx.Compat.setArrayLength(messages, 0);
        newMessage = false;
    }
    
    public static function sort(a : MPUserChatHistory, b : MPUserChatHistory) : Int
    {
        if (a.lastMessage > b.lastMessage)
        {
            return -1;
        }
        
        return 1;
    }
}

