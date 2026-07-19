package classes.mp.components;

import classes.Language;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.mp.events.MPPMSelect;
import classes.mp.pm.MPUserChatHistory;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import assets.menu.icons.fa.IconRight;





import com.greensock.TweenLite;



import openfl.geom.Rectangle;

class MPViewUserListPM extends Sprite
{
    private static var _mp                             : Dynamic= Multiplayer.instance;
    private static var _lang                             : Dynamic= Language.instance;
    
    private var _width                             : Dynamic= 200;
    private var _height                             : Dynamic= 388;
    
    private var pane                             : Dynamic;
    
    private var scrollbarWidth(default, never)                             : Dynamic= 15;
    private var scrollbar                             : Dynamic;
    private var scrollbarBG                             : Dynamic;
    
    private var labelHeight(default, never)                             : Dynamic= 27;
    private var userLabels                             : Dynamic= [];
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        build();
    }
    
    public function build() : Void
    {
        new Text(this, 5, 0, _lang.string("mp_user_list"), 16, "#FFFFFF").setAreaParams(_width - 10, 30);
        
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
        var my                             : Dynamic= 0;
        
        var MPViewUserListPMUserLabel                             : Dynamic= null;
        var chat                             : Dynamic= null;
        
        for (chat/* AS3HX WARNING could not determine type for var: chat exp: EField(EIdent(_mp),pms) type: null */ in as3hx.Compat.iter(_mp.pms))
        {
            MPViewUserListPMUserLabel = getUserLabel(chat);
            MPViewUserListPMUserLabel.y = my;
            MPViewUserListPMUserLabel.update();
            my += labelHeight;
        }
        
        pane.update();
        
        // Check for Change in Scrollbar appearence, recalculate widths if needed.
        var oldScrollbarVisible                             : Dynamic= scrollbar.visible;
        scrollbarBG.visible = scrollbar.visible = (pane.content.height > pane.height - 5);
        
        if (as3hx.Compat.truthy(oldScrollbarVisible != scrollbar.visible))
        {
            userLabels.forEach(_setSize);
        }
    }
    
    public function updateUnread() : Void
    {
        userLabels.forEach(_setUnread);
    }
    
    private function _setSize(item                             : Dynamic, index                             : Dynamic= 0, vector                             : Dynamic= null) : Void
    {
        item.setSize(_width - ((scrollbar.visible) ? scrollbarWidth + 1 : 0), labelHeight);
    }
    
    private function _setUnread(item                             : Dynamic, index                             : Dynamic= 0, vector                             : Dynamic= null) : Void
    {
        item.update();
    }
    
    private function _markUnactive(item                             : Dynamic, index                             : Dynamic= 0, vector                             : Dynamic= null) : Void
    {
        item.setActive(false);
    }
    
    private function e_onUserClick(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Std.is(e.target, MPViewUserListPMUserLabel)))
        {
            userLabels.forEach(_markUnactive);
            
            var label                             : Dynamic= try cast(e.target, MPViewUserListPMUserLabel) catch(e:Dynamic) null;
            label.chat.newMessage = false;
            label.setActive(true);
            label.update();
            
            dispatchEvent(new MPPMSelect(label.chat));
        }
    }
    
    private function e_scrollMouseWheel(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        var dist                             : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function e_scrollbarUpdater(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        pane.scrollTo(e.target.scroll);
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
    
    // //////
    // Object Pool
    private function getUserLabel(chat                             : Dynamic) : MPViewUserListPMUserLabel
    {
        for (label in as3hx.Compat.iter(userLabels))
        {
            if (as3hx.Compat.truthy(chat == label.chat))
            {
                return label;
            }
        }
        
        var newLabel                             : Dynamic= new MPViewUserListPMUserLabel(chat);
        pane.content.addChild(newLabel);
        userLabels.push(newLabel);
        _setSize(newLabel);
        
        return newLabel;
    }
}



class MPViewUserListPMUserLabel extends Sprite
{
    public var _mp                             : Dynamic= Multiplayer.instance;
    public var _lang                             : Dynamic= Language.instance;
    
    public var _width                             : Dynamic= 184;
    public var _height                             : Dynamic= 27;
    
    public var chat                             : Dynamic;
    public var user                             : Dynamic;
    public var messageDot                             : Dynamic;
    private var chevron                             : Dynamic;
    
    public var nameText                             : Dynamic;
    
    private var active                             : Dynamic= false;
    private var hover                             : Dynamic= false;
    
    @:allow(classes.mp.components)
    private function new(chat                             : Dynamic)
    {
        super();
        this.chat = chat;
        this.user = chat.user;
        
        this.buttonMode = true;
        this.mouseChildren = false;
        
        build();
        draw();
    }
    
    public function build() : Void
    {
        nameText = new Text(this, 5, 0, user.userLabelHTML, 11, "#FFFFFF");
        nameText.setAreaParams(_width - 11, _height);
        nameText.cacheAsBitmap = true;
        
        messageDot = new Sprite();
        messageDot.graphics.beginFill(0xffaa42);
        messageDot.graphics.drawCircle(0, 0, 4);
        messageDot.graphics.endFill();
        messageDot.visible = chat.newMessage;
        addChild(messageDot);
        
        chevron = new IconRight();
        chevron.x = 9;
        chevron.y = _height / 2 + 0.5;
        chevron.scaleX = chevron.scaleY = 0.15;
        chevron.visible = false;
        addChild(chevron);
        
        this.addEventListener(MouseEvent.ROLL_OVER, e_showHover);
        this.addEventListener(MouseEvent.ROLL_OUT, e_hideHover);
    }
    
    public function draw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, _height);
        this.graphics.lineTo(_width, _height);
        
        this.graphics.lineStyle(0, 0x000000, 0);
        this.graphics.beginFill(0xFFFFFF, (active && hover) ? 0.15 : ((hover || active) ? 0.08 : 0));
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
    }
    
    public function setSize(w                             : Dynamic, h                             : Dynamic) : Void
    {
        _width = w;
        _height = h;
        resize();
    }
    
    public function resize() : Void
    {
        draw();
        scrollRect = new Rectangle(0, 0, _width + 1, _height + 1);
        nameText.width = nameText.x - 5;
        messageDot.x = _width - 10;
        messageDot.y = _height / 2;
    }
    
    public function update() : Void
    {
        messageDot.visible = chat.newMessage;
    }
    
    public function setActive(newState                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(this.active != newState))
        {
            TweenLite.to(nameText, 0.25, {
                        x : ((newState) ? 15 : 5)
                    });
            this.active = newState;
            this.chevron.visible = newState;
            draw();
        }
    }
    
    private function e_showHover(e                             : Dynamic) : Void
    {
        hover = true;
        draw();
    }
    
    private function e_hideHover(e                             : Dynamic) : Void
    {
        hover = false;
        draw();
    }
}
