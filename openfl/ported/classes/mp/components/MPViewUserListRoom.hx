package classes.mp.components;

import classes.Language;
import classes.mp.MPTeam;
import classes.mp.MPUser;
import classes.mp.commands.MPCRoomTeamChange;
import classes.mp.events.MPEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.room.MPRoom;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;



import classes.mp.Multiplayer;


import classes.mp.room.MPRoomFFR;

import classes.ui.Throbber;



import openfl.geom.Rectangle;

class MPViewUserListRoom extends Sprite
{
    private static var _lang : Language = Language.instance;
    
    private var _width : Float = 200;
    private var _height : Float = 388;
    
    private var room : MPRoom;
    private var users : Array<MPUser>;
    
    private var pane : ScrollPane;
    
    private var scrollbarWidth(default, never) : Float = 15;
    private var scrollbar : ScrollBar;
    private var scrollbarBG : Sprite;
    
    private var useTeamView : Bool = false;
    
    // Team Dividers
    private var labelHeight(default, never) : Float = 27;
    private var teamLabels : Array<TeamLabel> = [];
    private var userLabels : Array<MPViewUserListRoomUserLabel> = [];
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        if (parent != null)
        {
            parent.addChild(this);
        }
    }
    
    public function setRoom(room : MPRoom) : Void
    {
        this.room = room;
        this.users = room.users;
        
        build();
        update();
    }
    
    public function build() : Void
    {
        new Text(this, 5, 0, _lang.string("mp_user_list"), 16, "#FFFFFF").setAreaParams(_width - 60, 30);
        
        pane = new ScrollPane(this, 0, 31, _width, _height - 31, e_scrollMouseWheel);
        pane.addEventListener(MouseEvent.CLICK, e_onUserClick);
        
        // Scroll Bar
        scrollbarBG = new Sprite();
        scrollbarBG.x = _width - scrollbarWidth;
        scrollbarBG.y = 31;
        addChild(scrollbarBG);
        
        scrollbar = new ScrollBar(this, _width - scrollbarWidth, 31, scrollbarWidth, _height - 31, null, new Sprite(), e_scrollbarUpdater);
        
        // Graphics
        redraw();
    }
    
    public function redraw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        
        // BG
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
        
        // Title BG
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, _width, 30);
        this.graphics.endFill();
        
        // Borders
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, 0);
        this.graphics.lineTo(_width, 0);
        this.graphics.lineTo(_width, _height);
        this.graphics.lineTo(0, _height);
        
        // Title
        this.graphics.moveTo(0, 30);
        this.graphics.lineTo(_width, 30);
        
        // Scroll BG
        scrollbarBG.graphics.clear();
        
        scrollbarBG.graphics.lineStyle(0, 0, 0);
        scrollbarBG.graphics.beginFill(0xFFFFFF, 0.05);
        scrollbarBG.graphics.drawRect(0, 0, scrollbarWidth, _height - 31);
        scrollbarBG.graphics.endFill();
        
        scrollbarBG.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        scrollbarBG.graphics.moveTo(-1, 0);
        scrollbarBG.graphics.lineTo(-1, _height - 31);
    }
    
    public function update() : Void
    {
        useTeamView = room.teams.length > 1;
        
        var my : Float = 0;
        
        // Mark as Stale
        teamLabels.forEach(_markStale);
        userLabels.forEach(_markStale);
        
        var MPViewUserListRoomUserLabel : MPViewUserListRoomUserLabel;
        
        var team : MPTeam;
        var user : MPUser;
        
        // Multiple Teams
        if (room.teams.length > 1)
        {
            var teamLabel : TeamLabel;
            
            for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(room),teams) type: null */ in room.teams)
            {
                if (team.spectator)
                {
                    my += labelHeight;
                }
                
                teamLabel = getTeamLabel(team);
                teamLabel.y = my;
                teamLabel.update();
                
                my += labelHeight;
                
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(team),users) type: null */ in team.users)
                {
                    MPViewUserListRoomUserLabel = getUserLabel(user);
                    MPViewUserListRoomUserLabel.team = team;
                    MPViewUserListRoomUserLabel.y = my;
                    MPViewUserListRoomUserLabel.setPlayability(room.canUserPlaySong(user));
                    MPViewUserListRoomUserLabel.update();
                    my += labelHeight;
                }
            }
        }
        // Spectators Only
        else if (room.teams.length == 1)
        {
            for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EArray(EField(EIdent(room),teams),EConst(CInt(0))),users) type: null */ in room.teams[0].users)
            {
                MPViewUserListRoomUserLabel = getUserLabel(user);
                MPViewUserListRoomUserLabel.team = team;
                MPViewUserListRoomUserLabel.y = my;
                MPViewUserListRoomUserLabel.setPlayability(room.canUserPlaySong(user));
                MPViewUserListRoomUserLabel.update();
                my += labelHeight;
            }
        }
        
        if (room.type != "lobby")
        {
            userLabels.forEach(_markRoomOwner);
        }
        
        pane.update();
        
        // Check for Change in Scrollbar appearence, recalculate widths if needed.
        var oldScrollbarVisible : Bool = scrollbar.visible;
        scrollbarBG.visible = scrollbar.visible = (pane.content.height > pane.height - 5);
        
        if (oldScrollbarVisible != scrollbar.visible)
        {
            teamLabels.forEach(_setSize);
            userLabels.forEach(_setSize);
        }
        
        // Garbage Collect
        _removeStale(teamLabels);
        _removeStale(userLabels);
    }
    
    private function _markStale(item : BaseLabel, index : Int = 0, vector : Array<Dynamic> = null) : Void
    {
        item.isStale = true;
    }
    
    private function _setSize(item : BaseLabel, index : Int = 0, vector : Array<Dynamic> = null) : Void
    {
        item.setSize(_width - ((scrollbar.visible) ? scrollbarWidth + 1 : 0), labelHeight);
    }
    
    private function _removeStale(vec : Dynamic) : Void
    {
        var _vec : Array<Dynamic> = try cast(vec, Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
        
        var i : Float = _vec.length - 1;
        while (i >= 0)
        {
            var item : BaseLabel = try cast(Reflect.field(_vec, Std.string(i)), BaseLabel) catch(e:Dynamic) null;
            
            if (item.isStale)
            {
                item.parent.removeChild(item);
                _vec.splice(i, 1)[0];
            }
            i--;
        }
    }
    
    private function _markRoomOwner(item : MPViewUserListRoomUserLabel, index : Int = 0, vector : Array<MPViewUserListRoomUserLabel> = null) : Void
    {
        item.setOwnerCrown(room.owner);
    }
    
    private function e_onUserClick(e : MouseEvent) : Void
    {
        if (Std.is(e.target, MPViewUserListRoomUserLabel))
        {
            var user : MPUser = (try cast(e.target, MPViewUserListRoomUserLabel) catch(e:Dynamic) null).user;
            if (e.ctrlKey)
            {
                dispatchEvent(new MPUserEvent(MPEvent.ROOM_USERLIST_SPECTATE, null, user));
            }
            else
            {
                dispatchEvent(new MPUserEvent(MPEvent.ROOM_USERLIST_SELECT, null, user));
            }
        }
    }
    
    private function e_scrollMouseWheel(e : MouseEvent) : Void
    {
        if (!scrollbar.visible)
        {
            return;
        }
        
        var dist : Float = scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function e_scrollbarUpdater(e : Event) : Void
    {
        if (!scrollbar.visible)
        {
            return;
        }
        
        pane.scrollTo(e.target.scroll);
    }
    
    override private function set_width(value : Float) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value : Float) : Float
    {
        _height = height;
        redraw();
        return value;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    // //////
    
    public function updateGameStates() : Void
    {
        for (label in userLabels)
        {
            label.updateGameState();
        }
    }
    
    // //////
    // Object Pool
    private function getUserLabel(user : MPUser) : MPViewUserListRoomUserLabel
    {
        for (label in userLabels)
        {
            if (user == label.user)
            {
                label.isStale = false;
                return label;
            }
        }
        
        var newLabel : MPViewUserListRoomUserLabel = new MPViewUserListRoomUserLabel(room, user);
        pane.content.addChild(newLabel);
        userLabels.push(newLabel);
        _setSize(newLabel);
        
        return newLabel;
    }
    
    private function getTeamLabel(team : MPTeam) : TeamLabel
    {
        for (label in teamLabels)
        {
            if (team == label.team)
            {
                label.isStale = false;
                return label;
            }
        }
        
        var newLabel : TeamLabel = new TeamLabel(room, team);
        pane.content.addChild(newLabel);
        teamLabels.push(newLabel);
        _setSize(newLabel);
        
        return newLabel;
    }
}



class BaseLabel extends Sprite
{
    private static var _mp : Multiplayer = Multiplayer.instance;
    private static var _lang : Language = Language.instance;
    
    public var isStale : Bool = false;
    
    private var _width : Float = 184;
    private var _height : Float = 27;
    
    public var room : MPRoom;
    public var team : MPTeam;
    
    private var nameText : Text;
    
    @:allow(classes.mp.components)
    private function new(room : MPRoom, team : MPTeam = null)
    {
        super();
        this.room = room;
        this.team = team;
        
        build();
    }
    
    private function build() : Void
    {
    }
    
    private function draw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, _height);
        this.graphics.lineTo(_width, _height);
        
        this.graphics.lineStyle(0, 0x000000, 0);
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
    }
    
    public function setSize(w : Float, h : Float) : Void
    {
        _width = w;
        _height = h;
        resize();
    }
    
    private function resize() : Void
    {
        draw();
        scrollRect = new Rectangle(0, 0, _width + 1, _height + 1);
    }
    
    public function update() : Void
    {
    }
}

class TeamLabel extends BaseLabel
{
    private var joinText : Text;
    private var _throbber : Throbber;
    
    @:allow(classes.mp.components)
    private function new(room : MPRoom, team : MPTeam)
    {
        super(room, team);
    }
    
    override private function build() : Void
    {
        nameText = new Text(this, 5, 0, "", 11, "#c7c7c7");
        nameText.setAreaParams(_width - 55, _height);
        nameText.cacheAsBitmap = true;
        
        joinText = new Text(this, _width, 0, _lang.string("mp_team_join"), 11);
        joinText.setAreaParams(50, _height, "right");
        joinText.mouseEnabled = true;
        joinText.buttonMode = true;
        joinText.addEventListener(MouseEvent.CLICK, e_onTeamJoin);
        
        _throbber = new Throbber(12, 12, 1);
        _throbber.y = (_height / 2) - 5;
        _throbber.visible = false;
        _throbber.mouseEnabled = false;
        addChild(_throbber);
    }
    
    override private function resize() : Void
    {
        super.resize();
        joinText.x = _width - 55;
        _throbber.x = _width - joinText.textfield.textWidth - 30;
    }
    
    override public function update() : Void
    {
        if (_throbber.visible)
        {
            _throbber.stop();
            _throbber.visible = false;
        }
        
        joinText.visible = team.canJoin && !team.contains(_mp.currentUser) && team.userCount < team.maxUsers;
        
        if (team.spectator)
        {
            nameText.text = team.name;
        }
        else
        {
            nameText.text = team.name + " [" + team.users.length + " / " + team.maxUsers + "]";
        }
    }
    
    private function e_onTeamJoin(e : MouseEvent) : Void
    {
        _mp.sendCommand(new MPCRoomTeamChange(room, team));
        _throbber.visible = true;
        _throbber.start();
    }
}

class MPViewUserListRoomUserLabel extends BaseLabel
{
    private static var NAME_CROWN : String = " <font color=\"#FDCF53\" face=\"" + Fonts.FONT_AWESOME + "\">\uf521</font>";
    
    public var user : MPUser;
    
    private var canPlay : Bool = false;
    private var altText : Text;
    
    private var hover : Sprite;
    
    @:allow(classes.mp.components)
    private function new(room : MPRoom, user : MPUser)
    {
        this.user = user;
        this.buttonMode = true;
        this.mouseChildren = false;
        super(room);
    }
    
    override private function build() : Void
    {
        nameText = new Text(this, 5, 0, user.userLabelHTML, 11, "#FFFFFF");
        nameText.setAreaParams(_width - 11, _height);
        nameText.cacheAsBitmap = true;
        
        altText = new Text(this, _width - 50, 0, "", 11, "#d3d3d3");
        altText.setAreaParams(40, _height, "right");
        altText.cacheAsBitmap = true;
        
        hover = new Sprite();
        hover.visible = false;
        addChild(hover);
        
        this.addEventListener(MouseEvent.ROLL_OVER, e_showHover);
        this.addEventListener(MouseEvent.ROLL_OUT, e_hideHover);
    }
    
    override private function resize() : Void
    {
        super.resize();
        altText.x = _width - 50;
        nameText.width = altText.x - nameText.x - 5;
        
        hover.graphics.clear();
        hover.graphics.beginFill(0xFFFFFF, 0.05);
        hover.graphics.drawRect(0, 0, _width, _height);
        hover.graphics.endFill();
    }
    
    override public function update() : Void
    {
        draw();
    }
    
    override private function draw() : Void
    {
        super.draw();
        
        if (team != null && !team.spectator)
        {
            nameText.width = _width - 42;
            
            var barColor : Int = (canPlay) ? ((room.isPlayerReady(user)) ? 0x8eff6b : 0xfff76b) : 0xff6b6b;
            
            this.graphics.lineStyle(0, 0, 0);
            this.graphics.beginFill(barColor, 0.5);
            this.graphics.drawRect(_width - 8, 1, 8, _height - 1);
            this.graphics.endFill();
        }
        else
        {
            nameText.width = _width - 11;
        }
    }
    
    public function setOwnerCrown(owner : MPUser) : Void
    {
        nameText.text = user.userLabelHTML + ((owner == user) ? NAME_CROWN : "");
    }
    
    public function setPlayability(state : Bool) : Void
    {
        canPlay = state;
    }
    
    public function updateGameState() : Void
    {
        if (Std.is(room, MPRoomFFR))
        {
            var castRoom : MPRoomFFR = try cast(room, MPRoomFFR) catch(e:Dynamic) null;
            var playerState : String = castRoom.getPlayerState(user);
            
            if (playerState == "menu")
            {
                var song_rate : Float = castRoom.getPlayerSongRate(user);
                var rate_text : String = (castRoom.mods.rate.enabled || song_rate != 1) ? "[" + song_rate + "x]" : "";
                
                if (castRoom.mods.rate.enabled)
                {
                    rate_text = "<font color=\"#eda8a8\">" + rate_text;
                }
                
                altText.text = rate_text;
            }
            else if (playerState == "loading")
            {
                altText.text = castRoom.getPlayerLoadingProgress(user) + "%";
            }
            else if (playerState == "game")
            {
                altText.text = "[Playing]";
            }
            else if (playerState == "waiting")
            {
                altText.text = "[Waiting]";
            }
            else if (playerState == "results")
            {
                altText.text = "[Results]";
            }
            else
            {
                altText.text = "";
            }
        }
    }
    
    private function e_showHover(e : MouseEvent) : Void
    {
        hover.visible = true;
    }
    
    private function e_hideHover(e : MouseEvent) : Void
    {
        hover.visible = false;
    }
}
