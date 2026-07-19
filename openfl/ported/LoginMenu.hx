import openfl.errors.Error;
import classes.Alert;
import classes.Language;
import classes.Playlist;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.BoxText;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;
import com.flashfla.utils.Crypt;
import com.flashfla.utils.SpriteUtil;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.ui.Keyboard;
import menu.MenuPanel;

class LoginMenu extends MenuPanel
{
    private static var displayAvatarComplete                 : Dynamic;
    private var rememberPassword(get, never)                              : Dynamic;

    private var _gvars                              : Dynamic= GlobalVariables.instance;
    private var _lang                              : Dynamic= Language.instance;
    private var _loader                              : Dynamic;
    
    private var STORED_NONE(default, never)                              : Dynamic= 0;
    private var STORED_PASSWORD(default, never)                              : Dynamic= 1;
    private var STORED_SESSION(default, never)                              : Dynamic= 2;
    
    private var savedInfos                              : Dynamic;
    
    private var box                              : Dynamic;
    private var panel_login                              : Dynamic;
    private var panel_session                              : Dynamic;
    
    private var input_user                              : Dynamic;
    private var input_pass                              : Dynamic;
    private var saveDetails                              : Dynamic;
    
    private var isLoading                              : Dynamic= false;
    
    public function new(myParent                              : Dynamic)
    {
        super(myParent);
        
        savedInfos = loadLoginDetails();
    }
    
    override public function stageRemove() : Void
    {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, loginKeyDown);
    }
    
    override public function dispose() : Void
    {
        saveDetails.dispose();
        super.stageRemove();
    }
    
    override public function stageAdd() : Void
    {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, loginKeyDown);
        
        //- BG
        box = new Box(this, (Main.GAME_WIDTH - 300) / 2, (Main.GAME_HEIGHT - 140) / 2, false);
        box.setSize(300, 140);
        
        // Register Button
        var register_online_btn                              : Dynamic= new BoxButton(this, box.x, box.y + box.height + 10, 300, 30, _lang.string("register_online"), 12, registerOnline);
        
        ///
        panel_session = new Sprite();
        
        var draw_pane                              : Dynamic= new Sprite();
        draw_pane.graphics.lineStyle(1, 0xffffff, 0);
        
        draw_pane.graphics.beginFill(0xffffff, 0.1);
        draw_pane.graphics.drawRect(6, 6, 87, 87);
        draw_pane.graphics.endFill();
        
        draw_pane.graphics.lineStyle(1, 0xffffff, 0.3);
        draw_pane.graphics.moveTo(100, 50);
        draw_pane.graphics.lineTo(265, 50);
        draw_pane.graphics.moveTo(1, 98);
        draw_pane.graphics.lineTo(box.width, 98);
        panel_session.addChild(draw_pane);
        
        if (as3hx.Compat.truthy(savedInfos.avatar != null))
        {
            try
            {
                var avatarLoader                              : Dynamic= new Loader();
                avatarLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, displayAvatarComplete);
                avatarLoader.loadBytes(savedInfos.avatar, AirContext.getLoaderContext());
                
                displayAvatarComplete = function(e                              : Dynamic) : Void
                {
                    avatarLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, displayAvatarComplete);
                    
                    var userAvatar                              : Dynamic= avatarLoader;
                    if (as3hx.Compat.truthy(userAvatar != null && userAvatar.height > 0 && userAvatar.width > 0))
                    {
                        SpriteUtil.scaleTo(userAvatar, 77, 77);
                        userAvatar.x = 11 + ((77 - userAvatar.width) / 2);
                        userAvatar.y = 11 + ((77 - userAvatar.height) / 2);
                        panel_session.addChildAt(userAvatar, 1);
                    }
                };
            }
            catch (e : Error)
            {
            }
        }
        
        // Username
        var session_label_user                              : Dynamic= new Text(panel_session, 100, 30, _lang.string("login_continue_as"));
        var session_txt_username                              : Dynamic= new Text(panel_session, 100, 50, (savedInfos.username) ? savedInfos.username : "----", 16, "#F3FAFF");
        
        //- Buttons
        var session_continueAsbtn                              : Dynamic= new SimpleBoxButton(box.width, 98);
        session_continueAsbtn.addEventListener(MouseEvent.CLICK, attemptLoginSession);
        panel_session.addChild(session_continueAsbtn);
        
        var session_guestbtn                              : Dynamic= new BoxButton(panel_session, 6, box.height - 36, 120, 30, _lang.string("login_guest"), 12, playAsGuest);
        var session_changeusertbtn                              : Dynamic= new BoxButton(panel_session, box.width - 126, box.height - 36, 120, 30, _lang.string("login_change_user"), 12, changeUserEvent);
        
        /// Login Screen
        panel_login = new Sprite();
        
        //- Text
        // Username
        var txt_user                              : Dynamic= new Text(panel_login, 5, 5, _lang.string("login_name"));
        input_user = new BoxText(panel_login, 5, 25, 290, 20);
        
        // Password
        var txt_pass                              : Dynamic= new Text(panel_login, 5, 55, _lang.string("login_pass"));
        input_pass = new BoxText(panel_login, 5, 75, 290, 20);
        input_pass.displayAsPassword = true;
        
        // Save Details
        saveDetails = new BoxCheck(panel_login, 92, 113, toggleDetailsSave);
        var txt_save                              : Dynamic= new Text(panel_login, 110, 111, _lang.string("login_remember"));
        
        //- Buttons
        var login_guestbtn                              : Dynamic= new BoxButton(panel_login, 6, box.height - 36, 75, 30, _lang.string("login_guest"), 12, playAsGuest);
        var loginbtn                              : Dynamic= new BoxButton(panel_login, box.width - 81, box.height - 36, 75, 30, _lang.string("login_text"), 12, attemptLogin);
        
        // Set Values
        if (as3hx.Compat.truthy(savedInfos.state == STORED_SESSION))
        {
        }
        else if (as3hx.Compat.truthy(savedInfos.state == STORED_PASSWORD))
        {
            input_user.text = savedInfos.username;
            input_pass.text = savedInfos.password;
            saveDetails.checked = true;
        }
        
        // Set Focus when at textboxes
        if (as3hx.Compat.truthy(savedInfos.state == STORED_SESSION))
        {
            box.addChild(panel_session);
        }
        else if (as3hx.Compat.truthy(savedInfos.state == STORED_NONE || savedInfos.state == STORED_PASSWORD))
        {
            box.addChild(panel_login);
            stage.focus = input_user.field;
            input_user.field.setSelection(input_user.text.length, input_user.text.length);
        }
    }
    
    
    private function get_rememberPassword() : Bool
    {
        return saveDetails.checked;
    }
    
    public function toggleDetailsSave(e                              : Dynamic) : Void
    {
        saveDetails.checked = !saveDetails.checked;
    }
    
    public function playAsGuest(e                              : Dynamic= null) : Void
    {
        switchTo(Main.GAME_MENU_PANEL);
    }
    
    public function registerOnline(e                              : Dynamic= null) : Void
    {
        flash.Lib.getURL(new URLRequest(URLs.resolve(URLs.USER_REGISTER_URL)), "_blank");
    }
    
    private function changeUserEvent(e                              : Dynamic) : Void
    {
        saveLoginDetails(false);
        
        if (as3hx.Compat.truthy(box.contains(panel_session)))
        {
            box.removeChild(panel_session);
        }
        
        box.addChild(panel_login);
        
        if (as3hx.Compat.truthy(savedInfos.username != null))
        {
            input_user.text = savedInfos.username;
        }
        
        stage.focus = input_user.field;
        input_user.field.setSelection(input_user.text.length, input_user.text.length);
    }
    
    public function attemptLoginSession(e                              : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(isLoading))
        {
            return;
        }
        
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                              : Dynamic= new URLRequest(URLs.resolve(URLs.USER_LOGIN_URL));
        var requestVars                              : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.username = savedInfos.username;
        requestVars.token = savedInfos.token;
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        
        Logger.info(this, "Attempting session login for: " + requestVars.username.substr(0, 4) + "..." + requestVars.token.substr(-4));
        
        isLoading = true;
    }
    
    public function attemptLogin(e                              : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(isLoading))
        {
            return;
        }
        
        _loader = new URLLoader();
        addLoaderListeners();
        
        var req                              : Dynamic= new URLRequest(URLs.resolve(URLs.USER_LOGIN_URL));
        var requestVars                              : Dynamic= new URLVariables();
        Constant.addDefaultRequestVariables(requestVars);
        requestVars.username = input_user.text;
        requestVars.password = input_pass.text;
        requestVars.rememberPassword = ((this.rememberPassword) ? "true" : "false");
        req.data = requestVars;
        req.method = URLRequestMethod.POST;
        _loader.load(req);
        
        Logger.info(this, "Attempting login for: " + requestVars.username.substr(0, 4) + "...");
        
        setFields(true);
    }
    
    private function loginKeyDown(event                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(event.keyCode == Keyboard.ENTER)) {
if (as3hx.Compat.truthy(panel_session.stage != null))
            {
                attemptLoginSession(event);
            }
            // Login Screen
            else
            {
                
                {
                    if (as3hx.Compat.truthy(input_user.text.length > 0))
                    {
                        attemptLogin(event);
                    }
                    else
                    {
                        playAsGuest(event);
                    }
                }
            }
        }
    }
    
    private function loginLoadComplete(e                              : Dynamic) : Void
    {
        removeLoaderListeners();
        
        // Parse Response
        var _data                              : Dynamic= null;
        var siteDataString                              : Dynamic= e.target.data;
        try
        {
            _data = haxe.Json.parse(siteDataString);
        }
        catch (err : Error)
        {
            Logger.error(this, "Parse Failure: " + Logger.exception_error(err));
            Logger.error(this, "Wrote invalid response data to log folder. [logs/login.txt]");
            AirContext.writeTextFile(AirContext.getAppFile("logs/login.txt"), siteDataString);
            
            Alert.add(_lang.string("login_connection_error"));
            setFields(false);
            return;
        }  // Has Response  
        
        
        
        if (as3hx.Compat.truthy(_data.result == 4))
        {
            Logger.error(this, "Invalid User/Session");
            isLoading = false;
            Alert.add(_lang.string("login_invalid_session"));
            changeUserEvent(e);
        }
        else if (as3hx.Compat.truthy(_data.result >= 1 && _data.result <= 3))
        {
            Logger.success(this, "Login Success!");
            if (as3hx.Compat.truthy(_data.result == 1 || _data.result == 2))
            {
                saveLoginDetails(this.rememberPassword, _data.session);
            }
            _gvars.userSession = _data.session;
            _gvars.gameMain.loadComplete = false;
            Playlist.clearCanon();
            switchTo("none");
        }
        else
        {
            setFields(false, true);
        }
    }
    
    private function loginLoadError(e                              : Dynamic= null) : Void
    {
        Logger.error(this, "Login Load Error: " + Logger.event_error(e));
        Alert.add(_lang.string("login_connection_error"));
        removeLoaderListeners();
        setFields(false);
    }
    
    private function addLoaderListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, loginLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, loginLoadError);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loginLoadError);
    }
    
    private function removeLoaderListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, loginLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, loginLoadError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loginLoadError);
    }
    
    private function setFields(val                              : Dynamic, isError                              : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(val))
        {
            isLoading = true;
            input_user.selectable = false;
            input_pass.selectable = false;
            input_user.textColor = 0xD6D6D6;
            input_pass.textColor = 0xD6D6D6;
            input_pass.color = 0xD6D6D6;
            input_pass.borderColor = 0xFFFFFF;
        }
        else
        {
            isLoading = false;
            input_user.selectable = true;
            input_pass.selectable = true;
            input_user.textColor = 0xFFFFFF;
            input_pass.textColor = 0xFFFFFF;
            input_pass.color = 0xFFFFFF;
            input_pass.borderColor = 0xFFFFFF;
        }
        
        if (as3hx.Compat.truthy(isError))
        {
            input_pass.text = "";
            input_pass.textColor = 0xFFDBDB;
            input_pass.color = 0xFF0000;
            input_pass.borderColor = 0xFF0000;
        }
    }
    
    public function saveLoginDetails(saveLogin                              : Dynamic= false, session                              : Dynamic= "") : Void
    {
        if (as3hx.Compat.truthy(saveLogin && session != ""))
        {
            LocalStore.setVariable("uUsername", Crypt.Encode(input_user.text));
            LocalStore.setVariable("uSessionToken", Crypt.Encode(session));
        }
        else
        {
            LocalStore.deleteVariable("uPassword");
            LocalStore.deleteVariable("uUsername");
            LocalStore.deleteVariable("uSessionToken");
            LocalStore.deleteVariable("uAvatar");
            
            LocalStore.flush();
        }
    }
    
    public function loadLoginDetails() : Dynamic
    {
        var out                              : Dynamic= {
            state : STORED_NONE
        };
        
        var username                              : Dynamic= LocalStore.getVariable("uUsername", "");
        var sessionToken                              : Dynamic= LocalStore.getVariable("uSessionToken", "");
        
        if (as3hx.Compat.truthy(sessionToken != ""))
        {
            Reflect.setField(out, "state", STORED_SESSION);
            Reflect.setField(out, "username", Crypt.Decode(username));
            Reflect.setField(out, "token", Crypt.Decode(sessionToken));
            Reflect.setField(out, "avatar", LocalStore.getVariable("uAvatar", null));
        }
        else if (as3hx.Compat.truthy(username != ""))
        {
            var password                              : Dynamic= LocalStore.getVariable("uPassword", "");
            
            Reflect.setField(out, "state", STORED_PASSWORD);
            Reflect.setField(out, "username", Crypt.Decode(username));
            Reflect.setField(out, "password", Crypt.Decode(password));
        }
        
        return out;
    }
}

