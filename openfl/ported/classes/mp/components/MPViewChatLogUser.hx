package classes.mp.components;

import classes.Language;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import classes.mp.commands.MPCUserMessage;
import classes.mp.components.chatlog.MPChatLogEntry;
import classes.mp.events.MPEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.pm.MPUserChatHistory;
import classes.ui.BoxText;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;


class MPViewChatLogUser extends Sprite
{
    private static var _lang                             : Dynamic= Language.instance;
    private static var _mp                             : Dynamic= Multiplayer.instance;
    
    private static inline var HISTORY_LIMIT                             : Dynamic= 200;
    
    private var _width                             : Dynamic= 0;
    private var _height                             : Dynamic= 0;
    
    public var history                             : Dynamic;
    public var user                             : Dynamic;
    
    public var displayName                             : Dynamic;
    
    private var messagePlaceholderLeft                             : Dynamic;
    private var messagePlaceholderRight                             : Dynamic;
    private var messageText                             : Dynamic;
    private var _last_message_text                             : Dynamic= "";
    
    private var pane                             : Dynamic;
    private var lastEntry                             : Dynamic;
    
    private var scrollbarWidth(default, never)                             : Dynamic= 15;
    private var scrollbar                             : Dynamic;
    
    private var _cachePositions                             : Dynamic= [];
    
    public function new(parent                             : Dynamic= null, xpos                             : Dynamic= 0, ypos                             : Dynamic= 0, wid                             : Dynamic= 0, hei                             : Dynamic= 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        this._width = wid;
        this._height = hei;
        
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        build();
    }
    
    public function setHistory(history                             : Dynamic) : Void
    {
        this.history = history;
        this.user = history.user;
        this.displayName = user.name;
        
        messageText.visible = true;
        messagePlaceholderRight.visible = messagePlaceholderLeft.visible = (_last_message_text.length <= 0);
        messagePlaceholderLeft.text = sprintf(_lang.string("mp_room_chat_message_user"), {
                            name : displayName
                        });
        
        loadHistory();
    }
    
    public function build() : Void
    // Chat Log
    {
        
        pane = new ScrollPane(this, 1, 1, _width - scrollbarWidth - 1, _height - 31, e_mouseWheelHandler);
        scrollbar = new ScrollBar(this, _width - scrollbarWidth, 1, scrollbarWidth, _height - 1, null, new Sprite(), e_scrollbarUpdater);
        scrollbar.draggerVisibility = false;
        
        // Chat Send
        messagePlaceholderRight = new Text(this, _width - 173, _height - 30, _lang.string("mp_room_chat_message_hint"));
        messagePlaceholderRight.setAreaParams(150, 30, "right");
        messagePlaceholderRight.alpha = 0.35;
        messagePlaceholderRight.visible = false;
        
        messagePlaceholderLeft = new Text(this, 10, _height - 30, "");
        messagePlaceholderLeft.setAreaParams(_width - messagePlaceholderRight.textfield.textWidth - 45, 30, "left");
        messagePlaceholderLeft.alpha = 0.35;
        messagePlaceholderLeft.visible = false;
        
        messageText = new BoxText(this, 0, _height - 30, _width - scrollbarWidth - 2, 29);
        messageText.borderAlpha = 0;
        messageText.borderActiveAlpha = 0;
        messageText.field.y += 2;
        messageText.field.maxChars = 500;
        messageText.addEventListener(Event.CHANGE, e_onMessageType, false, 0, true);
        messageText.visible = false;
        
        // Graphics
        redraw();
    }
    
    private function redraw() : Void
    {
        this.graphics.clear();
        
        // Scrollbar BG
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0xFFFFFF, 0.05);
        this.graphics.drawRect(_width - scrollbarWidth, 1, scrollbarWidth, _height - 1);
        this.graphics.endFill();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        
        // Scrollbar
        this.graphics.moveTo(_width - scrollbarWidth - 1, 1);
        this.graphics.lineTo(_width - scrollbarWidth - 1, _height);
        
        // Chat
        this.graphics.moveTo(1, _height - 30);
        this.graphics.lineTo(_width - scrollbarWidth - 1, _height - 30);
    }
    
    public function onKeyInput(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.keyCode == Keyboard.ENTER && e.target == messageText.field))
        {
            _mp.sendCommand(new MPCUserMessage(user, _last_message_text));
            _last_message_text = "";
            messageText.text = "";
            messagePlaceholderRight.visible = messagePlaceholderLeft.visible = true;
        }
    }
    
    public function update(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(history == null || history.messages.length <= 0 || e.user.sid != history.user.sid))
        {
            return;
        }
        
        // Find newest rendered message.
        var found                             : Dynamic= false;
        var i                             : Dynamic= null;
        i = as3hx.Compat.parseInt(history.messages.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            if (as3hx.Compat.truthy(history.messages[i] == lastEntry))
            {
                found = true;
                break;
            }
            i--;
        }
        
        // Add all newest messages.
        i = (found) ? i + 1 : 0;
        while (as3hx.Compat.truthy(i < history.messages.length))
        {
            addItem(history.messages[as3hx.Compat.parseInt(i)]);
            i++;
        }
        
        history.newMessage = false;
        _mp.dispatchEvent(new MPUserEvent(MPEvent.USER_MESSAGE_READ, null, e.user));
    }
    
    private function e_onMessageType(e                             : Dynamic) : Void
    {
        _last_message_text = messageText.text;
        messagePlaceholderRight.visible = messagePlaceholderLeft.visible = (_last_message_text.length <= 0);
    }
    
    private function loadHistory() : Void
    {
        pane.clear();
        
        as3hx.Compat.setArrayLength(_cachePositions, 0);
        
        var startY                             : Dynamic= 5;
        var endY                             : Dynamic= null;
        
        for (i in 0...history.messages.length)
        {
            var entry                             : Dynamic= history.messages[i];
            
            entry.build(pane.width - 1);
            
            endY = as3hx.Compat.parseInt(startY + entry.height);
            _cachePositions.push(new MPViewChatLogUserCLItemCache(entry, startY, endY));
            
            // Add to Pane
            entry.y = startY;
            addPaneChild(entry);
            startY = endY;
        }
        
        lastEntry = _cachePositions[as3hx.Compat.parseInt(_cachePositions.length - 1)].entry;
        
        pane.update();
        scrollbar.draggerVisibility = startY > pane.height;
        scrollbar.scrollTo((scrollbar.draggerVisibility) ? 1 : 0);
    }
    
    public function addItem(entry                             : Dynamic) : Void
    // Build Item Elements
    {
        
        entry.build(pane.width - 1);
        
        // Get Start and End Y Positions
        var startY                             : Dynamic= _cachePositions[as3hx.Compat.parseInt(_cachePositions.length - 1)].endY;
        var endY                             : Dynamic= as3hx.Compat.parseInt(startY + entry.height);
        _cachePositions.push(new MPViewChatLogUserCLItemCache(entry, startY, endY));
        
        // Add to Pane
        entry.y = startY;
        addPaneChild(entry);
        lastEntry = entry;
        
        scrollbar.draggerVisibility = endY > pane.height;
    }
    
    private function addPaneChild(entry                             : Dynamic) : Void
    {
        var lastScrollPosition                             : Dynamic= scrollbar.scroll;
        var lastCacheItem                             : Dynamic= _cachePositions[as3hx.Compat.parseInt(_cachePositions.length - 1)];
        var shouldScrollStart                             : Dynamic= lastCacheItem.startY < pane.height && lastCacheItem.endY > pane.height;  // Item crosses height bounds.  
        var yShiftValue                             : Dynamic= 0;
        
        if (as3hx.Compat.truthy(_cachePositions.length > HISTORY_LIMIT))
        {
            while (as3hx.Compat.truthy(_cachePositions.length > HISTORY_LIMIT))
            {
                pane.content.removeChild(_cachePositions[0].entry);
                _cachePositions.shift();
            }
            
            yShiftValue = _cachePositions[0].startY;
            
            // Reposition All Items
            var historyItem                             : Dynamic= null;
            var lastY                             : Dynamic= 0;
            for (i in 0...HISTORY_LIMIT)
            {
                historyItem = _cachePositions[i];
                historyItem.startY = lastY;
                historyItem.endY = lastY + historyItem.entry.height;
                historyItem.entry.y = lastY;
                historyItem.entry.visible = false;
                
                lastY = historyItem.endY;
            }
        }
        pane.content.addChild(entry);
        
        // Scroll Newest if near bottom, or scroll has started.
        if (as3hx.Compat.truthy(lastScrollPosition > 0.99 || shouldScrollStart))
        {
            pane.update();
            
            pane.scrollTo(1);
            scrollbar.scrollTo(1);
        }
        // Keep Scroll position when adding/removing items.
        else
        {
            
            {
                pane.content.y += yShiftValue;
                
                if (as3hx.Compat.truthy(pane.content.y > 0))
                {
                    pane.content.y = 0;
                }
                
                pane.update();
                
                scrollbar.scrollTo(-pane.content.y / (pane.content.height - pane.height));
            }
        }
    }
    
    /**
     * Mouse Wheel Handler for the Chat Log Pane.
     * Moves the scroll pane based on the scroll delta direction.
     * @param e
     */
    private function e_mouseWheelHandler(e                             : Dynamic) : Void
    // Sanity
    {
        
        if (as3hx.Compat.truthy(!scrollbar.draggerVisibility))
        {
            return;
        }
        
        // Scroll
        var newScrollPosition                             : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(newScrollPosition);
        scrollbar.scrollTo(newScrollPosition);
    }
    
    private function e_scrollbarUpdater(e                             : Dynamic) : Void
    {
        pane.scrollTo(e.target.scroll);
    }
}



class MPViewChatLogUserCLItemCache
{
    public var startY                             : Dynamic;
    public var endY                             : Dynamic;
    public var entry                             : Dynamic;
    
    @:allow(classes.mp.components)
    private function new(entry                             : Dynamic, startY                             : Dynamic, endY                             : Dynamic)
    {
        this.startY = startY;
        this.endY = endY;
        this.entry = entry;
    }
}
