package classes.mp.prompts;

import assets.menu.icons.fa.IconClose;
import assets.menu.icons.fa.IconEye;
import assets.menu.icons.fa.IconPlus;
import assets.menu.icons.fa.IconUserX;
import classes.Alert;
import classes.ImageCache;
import classes.Language;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCRoomInvite;
import classes.mp.commands.MPCRoomUserBlock;
import classes.mp.commands.MPCUserBlock;
import classes.mp.commands.MPCUserMessage;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.room.MPRoom;
import classes.ui.BoxButton;
import classes.ui.BoxIcon;
import classes.ui.BoxText;
import classes.ui.Prompt;
import classes.ui.Text;
import classes.ui.Throbber;
import classes.user.UserStats;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

import classes.Playlist;
import classes.SongInfo;


import classes.mp.commands.MPCModBanUser;
import classes.mp.commands.MPCModMuteUser;

import classes.mp.commands.MPCRoomUserOwner;
import classes.mp.prompts.MPUserProfilePrompt;





import classes.user.UserStatsScore;
import com.bit101.components.ComboBox;
import com.flashfla.utils.DateUtil;
import com.flashfla.utils.NumberUtil;




class MPUserProfilePrompt extends Prompt
{
    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    public var user                             : Dynamic;
    public var room                             : Dynamic;
    
    private var roomName                             : Dynamic;
    
    private var btnBlock                             : Dynamic;
    private var btnUnBlock                             : Dynamic;
    private var btnRoomInvite                             : Dynamic;
    private var btnRoomSpectate                             : Dynamic;
    
    private var btnTabProfile                             : Dynamic;
    private var btnTabRoom                             : Dynamic;
    private var btnTabModerator                             : Dynamic;
    
    private var selectedTab                             : Dynamic;
    private var tabProfile                             : Dynamic;
    private var tabRoom                             : Dynamic;
    private var tabModerator                             : Dynamic;
    
    private var closeButton                             : Dynamic;
    
    private var messagePlaceholderLeft                             : Dynamic;
    private var messagePlaceholderRight                             : Dynamic;
    private var messageText                             : Dynamic;
    private var _last_message_text                             : Dynamic= "";
    
    private var throbber                             : Dynamic;
    
    public function new(user                             : Dynamic, room                             : Dynamic, parent                             : Dynamic)
    {
        this.user = user;
        this.room = room;
        
        _mp.addEventListener(MPEvent.USER_BLOCK_UPDATE, e_onBlockUpdate);
        _mp.addEventListener(MPEvent.ROOM_UPDATE, e_onRoomUpdate);
        
        super(parent.stage, 650, 394);
        
        _content.graphics.moveTo(20, 140);
        _content.graphics.lineTo(_width - 20, 140);
        
        //_content.graphics.moveTo(20, 340);
        //_content.graphics.lineTo(_width - 20, 340);
        
        closeButton = new BoxIcon(this, _width - 32, 10, 22, 22, new IconClose(), clickHandler);
        
        // Name
        new Text(this, 136, 18, user.nameHTML, 24).setAreaParams(width - 145, 22);
        
        // Skill Rating
        if (as3hx.Compat.truthy(user.skillRating >= 255))
        {
            new Text(this, 136, 46, _gvars.getDivisionTitle(user.skillRating), 16, _gvars.getDivisionColor(user.skillRating)).setAreaParams(width - 145, 22);
        }
        else
        {
            new Text(this, 136, 46, sprintf(_lang.string("mp_profile_skill_level"), {
                                level : user.skillRating,
                                division : _gvars.getDivisionNumber(user.skillRating) + 1,
                                title : _gvars.getDivisionTitle(user.skillRating)
                            }), 16, _gvars.getDivisionColor(user.skillRating)).setAreaParams(width - 145, 22);
        }
        
        // Avatar
        var avatar                             : Dynamic= ImageCache.getImage(user.avatarURL, 0, 100, 100);
        avatar.x = 26;
        avatar.y = 25;
        addChild(avatar);
        _content.graphics.lineStyle(2, 0xFFFFFF, 0.35);
        _content.graphics.beginFill(0xFFFFFF, 0.1);
        _content.graphics.drawRect(21, 20, 110, 110);
        _content.graphics.endFill();
        
        // Profile Actions
        btnBlock = new BoxIcon(this, 139, 71, 26, 26, new IconUserX(), e_blockUser);
        btnBlock.setHoverText(_lang.string("mp_user_block_add"));
        btnBlock.setIconColor("#ff8989");
        btnBlock.visible = _mp.currentUser.blockList.indexOf(user.sid) == -1;
        
        btnUnBlock = new BoxIcon(this, 139, 71, 26, 26, new IconUserX(), e_blockUser);
        btnUnBlock.setHoverText(_lang.string("mp_user_block_remove"));
        btnUnBlock.setIconColor("#89ffa5");
        btnUnBlock.visible = !btnBlock.visible;
        
        btnBlock.enabled = btnUnBlock.enabled = (user != _mp.currentUser && !user.permissions.admin);
        
        btnRoomInvite = new BoxIcon(this, 168, 71, 26, 26, new IconPlus(), e_inviteUser);
        btnRoomInvite.setHoverText(_lang.string("mp_user_room_invite"));
        btnRoomInvite.setIconColor("#89ffa5");
        btnRoomInvite.enabled = _mp.GAME_ROOM != null;
        
        btnRoomSpectate = new BoxIcon(this, 197, 71, 26, 26, new IconEye(), e_spectateUser);
        btnRoomSpectate.setHoverText(_lang.string("mp_user_room_spectate"));
        btnRoomSpectate.enabled = (room != null && room.type == "ffr");
        
        // Actions
        btnTabProfile = new BoxButton(this, 139, 104, 129, 26, _lang.string("mp_profile_action_general"), 12, clickHandler);
        btnTabRoom = new BoxButton(this, 273, 104, 129, 26, _lang.string("mp_profile_action_owner"), 12, clickHandler);
        btnTabModerator = new BoxButton(this, 407, 104, 129, 26, _lang.string("mp_profile_action_mod"), 12, clickHandler);
        
        // Tabs
        tabProfile = new TabProfile(this, 20, 150, user, room);
        tabRoom = new TabRoom(this, 20, 150, user, room);
        tabModerator = new TabModerator(this, 20, 150, user, room);
        
        selectedTab = tabProfile;
        
        // Loading Indicator
        throbber = new Throbber(32, 32, 3);
        throbber.x = _width / 2 - 16;
        throbber.y = 140 - 16 + (_height - 140) / 2;
        addChild(throbber);
        throbber.start();
        
        // Setup Navigation
        updateNavigation();
        
        // Get Profile Data
        if (as3hx.Compat.truthy(user.sid > 1))
        {
            UserStats.load(user.sid, e_onProfileLoad);
        }
        
        // Messaging
        messagePlaceholderRight = new Text(this, _width - 175, _height - 50, _lang.string("mp_room_chat_message_hint"));
        messagePlaceholderRight.setAreaParams(150, 30, "right");
        messagePlaceholderRight.alpha = 0.35;
        
        messagePlaceholderLeft = new Text(this, 25, _height - 50, sprintf(_lang.string("mp_room_chat_message_user"), {
                            name : user.name
                        }));
        messagePlaceholderLeft.setAreaParams(_width - messagePlaceholderRight.textfield.textWidth - 20, 30, "left");
        messagePlaceholderLeft.alpha = 0.35;
        
        messageText = new BoxText(this, 20, _height - 50, _width - 42, 29);
        messageText.field.y += 2;
        messageText.field.maxChars = 500;
        messageText.addEventListener(Event.CHANGE, e_onMessageType, false, 0, true);
        
        // System User
        if (as3hx.Compat.truthy(user.sid == 1))
        {
            var devText                             : Dynamic= new Text(this, 20, 150, "\"beep boop, i'm a computer\"");
            devText.alpha = 0.1;
            devText.setAreaParams(610, 225, "center");
            
            btnTabProfile.visible = btnTabRoom.visible = btnTabModerator.visible = false;
            tabProfile.visible = tabRoom.visible = tabModerator.visible = false;
            messagePlaceholderRight.visible = messagePlaceholderLeft.visible = messageText.visible = false;
            
            throbber.stop();
            removeChild(throbber);
            throbber = null;
        }
    }
    
    private function updateNavigation() : Void
    {
        if (as3hx.Compat.truthy(!_mp.currentUser.permissions.mod))
        {
            btnTabModerator.visible = false;
        }
        
        if (as3hx.Compat.truthy(room == null || room.type == "lobby"))
        {
            btnTabRoom.visible = false;
        }
        else if (as3hx.Compat.truthy(room.owner != _mp.currentUser))
        {
            btnTabRoom.enabled = false;
            
            if (as3hx.Compat.truthy(selectedTab == tabRoom))
            {
                selectTab(tabProfile);
            }
        }
        
        if (as3hx.Compat.truthy(btnTabRoom.visible == false && btnTabModerator.visible == false))
        {
            btnTabProfile.visible = false;
        }
    }
    
    private function selectTab(tab                             : Dynamic) : Void
    {
        selectedTab.visible = false;
        selectedTab = tab;
        selectedTab.visible = true;
    }
    
    private function e_onProfileLoad(data                             : Dynamic) : Void
    {
        throbber.stop();
        removeChild(throbber);
        throbber = null;
        
        if (as3hx.Compat.truthy(stage))
        {
            tabProfile.update(data);
            
            if (as3hx.Compat.truthy(selectedTab == tabProfile))
            {
                tabProfile.visible = true;
            }
        }
    }
    
    private function clickHandler(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == btnTabProfile))
        {
            selectTab(tabProfile);
        }
        else if (as3hx.Compat.truthy(e.target == btnTabRoom))
        {
            selectTab(tabRoom);
        }
        else if (as3hx.Compat.truthy(e.target == btnTabModerator))
        {
            selectTab(tabModerator);
        }
        if (as3hx.Compat.truthy(e.target == closeButton))
        {
            close();
            dispatchEvent(new Event(Event.CLOSE));
        }
    }
    
    override public function close() : Void
    {
        if (as3hx.Compat.truthy(throbber != null))
        {
            throbber.stop();
            removeChild(throbber);
            throbber = null;
        }
        
        _mp.removeEventListener(MPEvent.USER_BLOCK_UPDATE, e_onBlockUpdate);
        _mp.removeEventListener(MPEvent.ROOM_UPDATE, e_onRoomUpdate);
        
        super.close();
    }
    
    public function onKeyInput(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.keyCode == Keyboard.ENTER && e.target == messageText.field))
        {
            sendChatMessage(0);
        }
    }
    
    private function e_inviteUser(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomInvite(user, _mp.GAME_ROOM));
    }
    
    private function e_spectateUser(e                             : Dynamic) : Void
    {
        dispatchEvent(new MPUserEvent(MPEvent.ROOM_USERLIST_SPECTATE, null, user));
    }
    
    private function e_blockUser(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCUserBlock(user));
    }
    
    private function e_onBlockUpdate(e                             : Dynamic) : Void
    {
        var target                             : Dynamic= e.command.data.sid;
        if (as3hx.Compat.truthy(target == user.sid))
        {
            if (as3hx.Compat.truthy(_mp.currentUser.blockList.indexOf(target) == -1))
            {
                Alert.add(sprintf(_lang.string("mp_user_block_unblocked"), {
                                    name : user.name
                                }), 120, Alert.GREEN);
            }
            else
            {
                Alert.add(sprintf(_lang.string("mp_user_block_blocked"), {
                                    name : user.name
                                }), 120, Alert.RED);
            }
            
            btnBlock.visible = _mp.currentUser.blockList.indexOf(user.sid) == -1;
            btnUnBlock.visible = !btnBlock.visible;
        }
    }
    
    private function e_onRoomUpdate(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.room != room))
        {
            return;
        }
        
        updateNavigation();
    }
    
    private function e_onMessageType(e                             : Dynamic) : Void
    {
        _last_message_text = messageText.text;
        messagePlaceholderRight.visible = messagePlaceholderLeft.visible = (_last_message_text.length <= 0);
    }
    
    public function sendChatMessage(type                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_last_message_text.length > 0))
        {
            _mp.sendCommand(new MPCUserMessage(user, _last_message_text, type));
            _last_message_text = "";
            messageText.text = "";
            messagePlaceholderRight.visible = messagePlaceholderLeft.visible = true;
        }
    }
}



class TabProfile extends Sprite
{
    private static var _lang                             : Dynamic= Language.instance;
    
    private var prompt                             : Dynamic;
    
    @:allow(classes.mp.prompts)
    private function new(parent                             : Dynamic, xpos                             : Dynamic, ypos                             : Dynamic, user                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.prompt = parent;
        this.x = xpos;
        this.y = ypos;
        this.visible = false;
        
        parent.addChild(this);
    }
    
    public function update(data                             : Dynamic) : Void
    {
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(315, 11);
        this.graphics.lineTo(315, 175);
        
        // Display Scores
        new Text(this, 0, 0, _lang.string("mp_profile_top_5_scores"), 15).setAreaParams(295, 22);
        var len                             : Dynamic= Math.min(5, data.equiv_scores.length);
        for (i in 0...len)
        {
            var entry                             : Dynamic= new ProfileScoreEntry(data.equiv_scores[i]);
            entry.y = 30 + (30 * i);
            addChild(entry);
        }
        
        // Progress Bars
        new Text(this, 335, 0, _lang.string("mp_profile_stats"), 15).setAreaParams(295, 22);
        statProgressBar(335, 30, data.aaa, data.total_songs, 0xeae2b9, "AAAs", "#eae2b9");
        statProgressBar(335, 60, data.fc, data.total_songs, 0xbdedbb, "FCs", "#bdedbb");
        statProgressBar(335, 90, data.tier_total, data.total_tier_points, 0xb9c1ea, "Tier Points", "#b9c1ea");
    }
    
    private function statProgressBar(ox                             : Dynamic, oy                             : Dynamic, value                             : Dynamic, total                             : Dynamic, color                             : Dynamic, label                             : Dynamic, textColor                             : Dynamic) : Void
    {
        this.graphics.lineStyle(1, color, 0.35);
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(ox, oy, 274, 25);
        this.graphics.endFill();
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(color, 0.1);
        this.graphics.drawRect(ox + 1, oy + 1, (value / total) * (274 - 2), 24);
        this.graphics.endFill();
        
        new Text(this, ox + 5, oy, label, 12, textColor).setAreaParams(264, 26);
        new Text(this, ox + 5, oy, value + " / " + total, 12, textColor).setAreaParams(264, 26, "right");
    }
}

class TabRoom extends Sprite
{
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var prompt                             : Dynamic;
    private var room                             : Dynamic;
    
    private var btnOwner                             : Dynamic;
    private var btnKick                             : Dynamic;
    private var btnBan                             : Dynamic;
    
    @:allow(classes.mp.prompts)
    private function new(parent                             : Dynamic, xpos                             : Dynamic, ypos                             : Dynamic, user                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.prompt = parent;
        this.room = room;
        this.x = xpos;
        this.y = ypos;
        this.visible = false;
        
        parent.addChild(this);
        
        btnOwner = new BoxButton(this, 0, 0, 200, 24, "Promote to Room Owner", 12, e_onPromoteOwner);
        btnBan = new BoxButton(this, 0, 35, 200, 24, "<font color=\"#ff9b9b\">Ban User</font>", 12, e_onBan);
        btnKick = new BoxButton(this, 0, 70, 200, 24, "Kick User", 12, e_onKick);
    }
    
    private function e_onPromoteOwner(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomUserOwner(room, prompt.user));
    }
    
    private function e_onBan(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomUserBlock(room, prompt.user, 1));
    }
    
    private function e_onKick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCRoomUserBlock(room, prompt.user, 0));
    }
}

class TabModerator extends Sprite
{
    private static var BAN_LENGTHS                             : Dynamic= [2, 5, 30, 60, 1440, 2880, 10080, 20160, 40320, 241920, 525600, 1051200, 52560000];
    
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var prompt                             : Dynamic;
    
    private var inputLength                             : Dynamic;
    private var inputPremade                             : Dynamic;
    
    private var btnBan                             : Dynamic;
    private var btnMute                             : Dynamic;
    private var btnKick                             : Dynamic;
    
    private var messageMod                             : Dynamic;
    private var messageAdmin                             : Dynamic;
    
    @:allow(classes.mp.prompts)
    private function new(parent                             : Dynamic, xpos                             : Dynamic, ypos                             : Dynamic, user                             : Dynamic, room                             : Dynamic)
    {
        super();
        this.prompt = parent;
        this.x = xpos;
        this.y = ypos;
        this.visible = false;
        
        parent.addChild(this);
        
        new Text(this, 0, 0, "Ban/Mute Length (minutes):");
        inputLength = new BoxText(this, 0, 30, 149, 23);
        
        inputPremade = new ComboBox(this, 161, 30, "---", buildDurationLength());
        inputPremade.setSize(151, 25);
        inputPremade.fontSize = 11;
        inputPremade.addEventListener(Event.SELECT, e_durationChange);
        
        btnMute = new BoxButton(this, 0, 65, 150, 24, "<font color=\"#ffd6d6\">Mute User</font>", 12, e_onMute);
        btnBan = new BoxButton(this, 161, 65, 150, 24, "<font color=\"#ff9b9b\">Ban User</font>", 12, e_onBan);
        btnKick = new BoxButton(this, 322, 65, 150, 24, "Kick User", 12, e_onKick);
        
        messageMod = new BoxButton(this, 0, 163, 150, 24, "<font color=\"#A6F968\">Message as Mod</font>", 12, e_sendAsMod);
        messageAdmin = new BoxButton(this, 161, 163, 150, 24, "<font color=\"#F25C5C\">Message as Admin</font>", 12, e_sendAsAdmin);
    }
    
    private function e_onMute(e                             : Dynamic) : Void
    {
        var duration                             : Dynamic= as3hx.Compat.parseInt(inputLength.text);
        if (as3hx.Compat.truthy(Math.isNaN(duration) || duration <= 0))
        {
            return;
        }
        
        _mp.sendCommand(new MPCModMuteUser(prompt.user, duration));
    }
    
    private function e_onBan(e                             : Dynamic) : Void
    {
        var duration                             : Dynamic= as3hx.Compat.parseInt(inputLength.text);
        if (as3hx.Compat.truthy(Math.isNaN(duration) || duration <= 0))
        {
            return;
        }
        
        _mp.sendCommand(new MPCModBanUser(prompt.user, duration));
    }
    
    private function e_onKick(e                             : Dynamic) : Void
    {
        _mp.sendCommand(new MPCModBanUser(prompt.user, 0));
    }
    
    private function e_durationChange(e                             : Dynamic) : Void
    {
        inputLength.text = Std.string(inputPremade.selectedItem.data);
    }
    
    private function e_sendAsMod(e                             : Dynamic) : Void
    {
        prompt.sendChatMessage(1);
    }
    
    private function e_sendAsAdmin(e                             : Dynamic) : Void
    {
        prompt.sendChatMessage(2);
    }
    
    private function buildDurationLength() : Array<Dynamic>
    {
        var out                             : Dynamic= [];
        
        for (i in 0...BAN_LENGTHS.length)
        {
            out.push({
                        data : BAN_LENGTHS[i],
                        label : DateUtil.minutesToString(BAN_LENGTHS[i])
                    });
        }
        
        return out;
    }
}

class ProfileScoreEntry extends Sprite
{
    private static var _playlist                             : Dynamic= Playlist.instanceCanon;
    
    public var score                             : Dynamic;
    
    @:allow(classes.mp.prompts)
    private function new(score                             : Dynamic)
    {
        super();
        this.score = score;
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, 295, 25);
        this.graphics.endFill();
        
        var song                             : Dynamic= _playlist.playList[score.level_id];
        
        new Text(this, 5, 0, song.name, 11).setAreaParams(245, 26);
        new Text(this, 5, 0, NumberUtil.numberFormat(score.weight, 2, true), 11, "#cccccc").setAreaParams(285, 26, "right");
    }
}
