package classes.mp;

import classes.Alert;
import classes.Language;
import classes.Site;
import classes.SongInfo;
import classes.mp.commands.IMPCommand;
import classes.mp.commands.MPCFFRSong;
import classes.mp.commands.MPCFFRSongRate;
import classes.mp.commands.MPCRoomJoin;
import classes.mp.commands.MPCommands;
import classes.mp.events.MPEvent;
import classes.mp.events.MPRoomEvent;
import classes.mp.events.MPUserEvent;
import classes.mp.pm.MPUserChatHistory;
import classes.mp.room.MPRoom;
import classes.mp.room.MPRoomFFR;
import com.worlize.websocket.WebSocket;
import com.worlize.websocket.WebSocketErrorEvent;
import com.worlize.websocket.WebSocketEvent;
import com.worlize.websocket.WebSocketMessage;
import com.worlize.websocket.WebSocketURI;
import openfl.events.ErrorEvent;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;
import openfl.utils.Dictionary;

class Multiplayer extends EventDispatcher
{
    public var connected(get, never)                             : Dynamic;
    public var inGameRoom(get, never)                             : Dynamic;
    public var isPlayerInRoom(get, never)                             : Dynamic;
    public static var instance(get, never)                             : Dynamic;

    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    private static var _lang                             : Dynamic= Language.instance;
    private static var _site                             : Dynamic= Site.instance;
    
    private static var _instance                             : Dynamic= null;
    
    public static inline var SERVER_VERSION                             : Dynamic= 4;
    
    private var _listeners                             : Dynamic= [];
    
    private var DEBUG                             : Dynamic= false;
    private var AUTO_JOIN_LOBBY                             : Dynamic= true;
    
    private var websocket                             : Dynamic;
    
    public static var VALID_GAME_TYPES                             : Dynamic= ["ffr"];
    
    // Cache for Data
    public var users                             : Dynamic;
    public var users_map                             : Dynamic;
    
    public var rooms                             : Dynamic;
    public var rooms_map                             : Dynamic;
    
    public var pms                             : Dynamic;
    public var pms_map                             : Dynamic;
    
    public var LOBBY                             : Dynamic;
    public var GAME_ROOM                             : Dynamic;
    
    public var SYSTEM_USER                             : Dynamic;
    
    public var currentUser                             : Dynamic;
    public var activeRooms                             : Dynamic;
    
    /**
     * Handles data syncing before server and client before informing the rest of the game.
     * It's based on keeping single references to Rooms/User/Teams to avoid passing data around.
     * Class data should only be modified due to server responsed and not by the client.
     * !!! Don't alter anything in this class directly. !!!
     * Responsible for the loss of Velocity's sanity.
     */
    public function new(en                             : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(en == null))
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    /*
       public override function dispatchEvent(event                            : Dynamic):Boolean
       {
       if (as3hx.Compat.truthy(event is MPEvent))
       trace(event as MPEvent);

       return super.dispatchEvent(event);
       }
     */
    
    override public function addEventListener(type                             : Dynamic, listener                             : Dynamic, useCapture                             : Dynamic= false, priority                             : Dynamic= 0, useWeakReference                             : Dynamic= false) : Void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        _listeners.push([type, listener, useCapture, priority, useWeakReference]);
    }
    
    override public function removeEventListener(type                             : Dynamic, listener                             : Dynamic, useCapture                             : Dynamic= false) : Void
    {
        super.removeEventListener(type, listener, useCapture);
        var i                             : Dynamic= _listeners.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var lis                             : Dynamic= as3hx.Compat.field(_listeners, i);
            if (as3hx.Compat.truthy(lis[0] == type && lis[1] == listener && lis[2] == useCapture))
            {
                _listeners.splice(i, 1);
            }
            i--;
        }
    }
    
    public function printDebugListeners() : Array<Dynamic>
    {
        return _listeners;
    }
    
    private function get_connected() : Bool
    {
        return websocket != null && websocket.connected;
    }
    
    private function init() : Void
    {
        websocket = new WebSocket(new WebSocketURI(Reflect.field(_site.data, "game_mp_host"), as3hx.Compat.parseInt(Reflect.field(_site.data, "game_mp_port"))), "*", "r3");
        websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
        websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
        websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
        websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
        websocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, handleConnectionFail);
        websocket.addEventListener(ErrorEvent.ERROR, handleErrorEvent);
    }
    
    /**
     * Connect to the Multiplayer Websocket.
     */
    public function connect() : Void
    {
        if (as3hx.Compat.truthy(websocket == null))
        {
            init();
        }
        
        if (as3hx.Compat.truthy(!websocket.connected))
        {
            this.currentUser = null;
            this.users = [];
            this.users_map = new Dictionary<Dynamic, Dynamic>(true);
            
            this.rooms = [];
            this.rooms_map = new Dictionary<Dynamic, Dynamic>(true);
            
            this.pms = [];
            this.pms_map = new Dictionary<Dynamic, Dynamic>(true);
            
            this.activeRooms = [];
            this.LOBBY = null;
            this.GAME_ROOM = null;
            
            SYSTEM_USER = _userUpdateDirect({
                                uid : 1
                            });
            
            websocket.connect();
        }
    }
    
    public function disconnect() : Void
    {
        if (as3hx.Compat.truthy(websocket != null))
        {
            websocket.close();
        }
        
        clearData();
        clearEvents();
    }
    
    private function clearData() : Void
    {
        this.currentUser = null;
        this.users = null;
        this.users_map = null;
        
        this.rooms = null;
        this.rooms_map = null;
        
        this.pms = null;
        this.pms_map = null;
        
        this.activeRooms = null;
        this.LOBBY = null;
        this.GAME_ROOM = null;
        this.SYSTEM_USER = null;
    }
    
    public function clearEvents() : Void
    {
        var i                             : Dynamic= _listeners.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            var lis                             : Dynamic= as3hx.Compat.field(_listeners, i);
            super.removeEventListener(lis[0], lis[1], lis[2]);
            i--;
        }
        as3hx.Compat.setArrayLength(_listeners, 0);
    }
    
    private function handleWebSocketOpen(event                             : Dynamic) : Void
    {
        dispatchEvent(new MPEvent(MPEvent.SOCKET_CONNECT, null));
    }
    
    private function handleWebSocketClosed(event                             : Dynamic) : Void
    {
        dispatchEvent(new MPEvent(MPEvent.SOCKET_DISCONNECT, new MPSocketDataText("disconnect", "Disconnect")));
    }
    
    private function handleConnectionFail(event                             : Dynamic) : Void
    //trace("Connection Failure: " + event.text);
    {
        
        dispatchEvent(new MPEvent(MPEvent.SOCKET_ERROR, new MPSocketDataText("error", event.text)));
    }
    
    private function handleErrorEvent(event                             : Dynamic) : Void
    //trace("Error Event: " + event.text);
    {
        
        dispatchEvent(new MPEvent(MPEvent.SOCKET_ERROR, new MPSocketDataText("error", event.text)));
    }
    
    private function handleWebSocketMessage(event                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(event == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(event.message.type == WebSocketMessage.TYPE_UTF8))
        {
            var tcmd                             : Dynamic= MPSocketDataText.parse(event.message);
            //trace(command);
            
            if (as3hx.Compat.truthy(tcmd == null))
            {
                return;
            }
            
            var _sw0_ = (tcmd.type);            

            switch (_sw0_)
            {
                case "sys":
                    return handleSysCommand(tcmd);
                
                case "room":
                    return handleRoomCommand(tcmd);
                
                case "user":
                    return handleUserCommand(tcmd);
                
                case "mode":
                    return handleModeCommand(tcmd);
                default:
                    if (as3hx.Compat.truthy(DEBUG))
                    {
                        trace(tcmd);
                    }
            }
        }
        else if (as3hx.Compat.truthy(event.message.type == WebSocketMessage.TYPE_BINARY))
        {
            var rcmd                             : Dynamic= MPSocketDataRaw.parse(event.message);
            //trace(command);
            
            if (as3hx.Compat.truthy(rcmd == null))
            {
                return;
            }
            
            var _sw1_ = (rcmd.type);            

            switch (_sw1_)
            {
                case 1:
                    return handleSysRawCommand(rcmd);
                
                case 2:
                    return handleRoomRawCommand(rcmd);
                
                case 3:
                    return handleUserRawCommand(rcmd);
                
                case 4:
                    return handleModeRawCommand(rcmd);
                default:
                    if (as3hx.Compat.truthy(DEBUG))
                    {
                        trace(rcmd);
                    }
            }
        }
    }
    
    public function handleSysCommand(command                             : Dynamic) : Void
    {
        var _sw2_ = (command.action);        

        switch (_sw2_)
        {
            case "login_ok":
                sysLoginOK(command);
            
            case "login_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.SYS_LOGIN_FAIL, command));
                disconnect();
            
            case "room_list":
                sysRoomList(command);
            
            case "user_list":
                sysUserList(command);
            
            case "room_error":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.SYS_ROOM_ERROR, command));
            
            case "user_error":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.SYS_USER_ERROR, command));
            
            case "alert":
                sysAlert(command);
            default:
                dispatchEvent(new MPEvent(MPEvent.SYS_GENERAL_ERROR, command));
        }
    }
    
    public function handleRoomCommand(command                             : Dynamic) : Void
    {
        var _sw3_ = (command.action);        

        switch (_sw3_)
        {
            case "update":
                roomUpdate(command);
            
            case "message":
                roomMessage(command);
            
            case "create_ok":
                roomCreateOK(command);
            
            case "create_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.ROOM_CREATE_FAIL, command));
            
            case "delete_ok":
                roomDeleteOK(command);
            
            case "delete_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.ROOM_DELETE_FAIL, command));
            
            case "join_ok":
                roomJoinOK(command);
            
            case "join_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.ROOM_JOIN_FAIL, command));
            
            case "leave_ok":
                roomLeaveOK(command);
            
            case "leave_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.ROOM_LEAVE_FAIL, command));
            
            case "edit_ok":
                roomEditOK(command);
            
            case "edit_fail":
                Alert.add(_lang.string("mp_error_" + (Std.string(command.data)).toLowerCase()), 240, Alert.RED);
                dispatchEvent(new MPEvent(MPEvent.ROOM_EDIT_FAIL, command));
            
            case "user_join":
                roomUserJoin(command);
            
            case "user_leave":
                roomUserLeave(command);
            
            case "team_add":
                roomTeamAdd(command);
            
            case "team_remove":
                roomTeamRemove(command);
            
            case "team_captain":
                roomTeamCaptain(command);
            
            case "team_update":
                roomTeamUpdate(command);
            default:
                dispatchEvent(new MPEvent(MPEvent.SYS_GENERAL_ERROR, command));
        }
    }
    
    public function handleUserCommand(command                             : Dynamic) : Void
    {
        var _sw4_ = (command.action);        

        switch (_sw4_)
        {
            case "message":
                userMessage(command);
            
            case "room_invite":
                userRoomInvite(command);
            
            case "block_update":
                userBlockUpdate(command);
        }
    }
    
    public function handleModeCommand(command                             : Dynamic) : Void
    {
        roomModeCommand(command);
    }
    
    public function handleSysRawCommand(command                             : Dynamic) : Void
    {
        var _sw5_ = (command.action);        

        switch (_sw5_)
        {
            default:
                dispatchEvent(new MPEvent(MPEvent.SYS_GENERAL_ERROR, null));
        }
    }
    
    public function handleRoomRawCommand(command                             : Dynamic) : Void
    {
        var _sw6_ = (command.action);        

        switch (_sw6_)
        {
            default:
                dispatchEvent(new MPEvent(MPEvent.SYS_GENERAL_ERROR, null));
        }
    }
    
    public function handleUserRawCommand(command                             : Dynamic) : Void
    {
        var _sw7_ = (command.action);        

        switch (_sw7_)
        {
            default:
                dispatchEvent(new MPEvent(MPEvent.SYS_GENERAL_ERROR, null));
        }
    }
    
    public function handleModeRawCommand(command                             : Dynamic) : Void
    {
        roomModeRawCommand(command);
    }
    
    public function sendBytes(data                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(!websocket.connected))
        {
            return false;
        }
        
        websocket.sendBytes(data);
        return true;
    }
    
    public function sendUTF(data                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(!websocket.connected))
        {
            return false;
        }
        
        websocket.sendUTF(data);
        return true;
    }
    
    public function sendCommand(cmd                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(!websocket.connected))
        {
            return false;
        }
        
        websocket.sendUTF(cmd.toJSON());
        return true;
    }
    
    public function updateLobby() : Void
    {
        sendUTF(MPCommands.UPDATE_LOBBY);
    }
    
    public function updateRoomList() : Void
    {
        sendUTF(MPCommands.UPDATE_ROOM_LIST);
    }
    
    public function getRoom(uid                             : Dynamic) : MPRoom
    {
        if (as3hx.Compat.truthy(rooms_map[uid] != null))
        {
            return rooms_map[uid];
        }
        
        return null;
    }
    
    public function setRoom(room                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(rooms_map[room.uid] == null))
        {
            rooms_map[room.uid] = room;
            rooms.push(room);
            
            _roomSort();
        }
    }
    
    public function getUser(uid                             : Dynamic) : MPUser
    {
        if (as3hx.Compat.truthy(users_map[uid] != null))
        {
            return users_map[uid];
        }
        
        return null;
    }
    
    public function setUser(user                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(users_map[user.uid] == null))
        {
            users.push(user);
            users_map[user.uid] = user;
        }
    }
    
    public function garbageCollection() : Void
    {
        _staleUsers();
    }
    
    private function _staleUsers() : Void
    {
        var i                             : Dynamic= null;
        var user                             : Dynamic= null;
        
        // Mark all Users as Stale
        i = users.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            users[as3hx.Compat.parseInt(i)].isStale = true;
            i--;
        }
        
        // Set self as not stale
        currentUser.isStale = false;
        SYSTEM_USER.isStale = false;
        
        // Check References to User in Rooms
        for (room in as3hx.Compat.iter(rooms))
        {
            for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(room),users) type: null */ in as3hx.Compat.iter(room.users))
            {
                user.isStale = false;
            }
        }
        
        // Delete Stale Users
        i = users.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            user = as3hx.Compat.field(users, i);
            
            if (as3hx.Compat.truthy(user.isStale))
            {
                Reflect.deleteField(users_map, Std.string(null));
                users.splice(i, 1);
            }
            i--;
        }
    }
    
    ///////////////////////////////////
    private function sysLoginOK(command                             : Dynamic) : Void
    {
        this.currentUser = new MPUser();
        this.currentUser.update(command.data);
        
        this.users.push(this.currentUser);
        this.users_map[this.currentUser.uid] = this.currentUser;
        
        dispatchEvent(new MPEvent(MPEvent.SYS_LOGIN_OK, command));
    }
    
    private function sysRoomList(command                             : Dynamic) : Void
    {
        var i                             : Dynamic= null;
        var temp_rooms                             : Dynamic= try cast(command.data, Array<Dynamic>) catch(e:Dynamic) null;
        var temp_room                             : Dynamic= null;
        
        // Mark all Rooms as Stale
        i = rooms.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            rooms[as3hx.Compat.parseInt(i)].isStale = true;
            i--;
        }
        
        // Add / Update Existing Rooms
        i = temp_rooms.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            _roomUpdateDirect(as3hx.Compat.field(temp_rooms, i));
            i--;
        }
        
        // Delete Stale Rooms
        i = rooms.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            if (as3hx.Compat.truthy(as3hx.Compat.field(rooms, i).isStale))
            {
                Reflect.deleteField(rooms_map, Std.string(null));
                rooms.splice(i, 1);
            }
            i--;
        }
        
        //_roomSort();
        garbageCollection();
        
        // Find Lobby
        if (as3hx.Compat.truthy(LOBBY == null))
        {
            for (room/* AS3HX WARNING could not determine type for var: room exp: EField(EIdent(this),rooms) type: null */ in as3hx.Compat.iter(this.rooms))
            {
                if (as3hx.Compat.truthy(room.type == "lobby"))
                {
                    LOBBY = room;
                    break;
                }
            }
            
            if (as3hx.Compat.truthy(AUTO_JOIN_LOBBY))
            {
                joinLobby();
            }
        }
        
        dispatchEvent(new MPEvent(MPEvent.SYS_ROOM_LIST, command));
    }
    
    private function sysUserList(command                             : Dynamic) : Void
    {
        var i                             : Dynamic= null;
        var temp_users                             : Dynamic= try cast(command.data, Array<Dynamic>) catch(e:Dynamic) null;
        var temp_user                             : Dynamic= null;
        
        // Add / Update Existing Users
        i = temp_users.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            _userUpdateDirect(as3hx.Compat.field(temp_users, i));
            i--;
        }
        
        garbageCollection();
        
        dispatchEvent(new MPEvent(MPEvent.SYS_USER_LIST, command));
    }
    
    private function sysAlert(command                             : Dynamic) : Void
    {
        var color                             : Dynamic= (command.data.color) ? command.data.color : 0;
        var age                             : Dynamic= (command.data.age) ? command.data.age : 120;
        
        if (as3hx.Compat.truthy(command.data.lang != null))
        {
            Alert.add(_lang.string(command.data.lang), age, color);
        }
        else if (as3hx.Compat.truthy(command.data.msg != null))
        {
            Alert.add(command.data.msg, age, color);
        }
    }
    
    private function roomUpdate(command                             : Dynamic) : Void
    {
        _roomUpdateDirect(command.data);
        
        var room                             : Dynamic= rooms_map[command.data.uid];
        dispatchEvent(new MPRoomEvent(MPEvent.ROOM_UPDATE, command, room));
    }
    
    private function roomCreateOK(command                             : Dynamic) : Void
    {
        _roomUpdateDirect(command.data);
        
        var room                             : Dynamic= rooms_map[command.data.uid];
        room.onJoin();
        activeRooms.push(room);
        
        if (as3hx.Compat.truthy(room.type != "lobby"))
        {
            GAME_ROOM = room;
        }
        
        dispatchEvent(new MPRoomEvent(MPEvent.ROOM_CREATE_OK, command, room));
    }
    
    private function roomJoinOK(command                             : Dynamic) : Void
    {
        _roomUpdateDirect(command.data);
        
        var room                             : Dynamic= rooms_map[command.data.uid];
        room.onJoin();
        activeRooms.push(room);
        
        if (as3hx.Compat.truthy(room.type != "lobby"))
        {
            GAME_ROOM = room;
        }
        
        dispatchEvent(new MPRoomEvent(MPEvent.ROOM_JOIN_OK, command, room));
    }
    
    private function roomLeaveOK(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        room.onLeave();
        
        var idx                             : Dynamic= Lambda.indexOf(activeRooms, room);
        if (as3hx.Compat.truthy(idx != -1))
        {
            activeRooms.splice(idx, 1);
        }
        
        if (as3hx.Compat.truthy(room == GAME_ROOM))
        {
            GAME_ROOM = null;
        }
        
        // Clear Extra Data from Room
        if (as3hx.Compat.truthy(room != null))
        {
            room.clearExtra();
        }
        
        garbageCollection();
        dispatchEvent(new MPRoomEvent(MPEvent.ROOM_LEAVE_OK, command, room));
    }
    
    /**
     * Called when Room Delete command is OK.
     *
     */
    private function roomDeleteOK(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        
        if (as3hx.Compat.truthy(_roomDeleteDirect(command.data)))
        {
            var idx                             : Dynamic= Lambda.indexOf(activeRooms, room);
            if (as3hx.Compat.truthy(idx != -1))
            {
                activeRooms.splice(idx, 1);
            }
            
            if (as3hx.Compat.truthy(room == GAME_ROOM))
            {
                GAME_ROOM = null;
            }
            
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_DELETE_OK, command, room));
        }
        else
        {
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_DELETE_FAIL, command, room));
        }
    }
    
    /**
     * Called when a Room Edit command is OK.
     * Updates the cached room if it exist, or fails otherwise.
     */
    private function roomEditOK(command                             : Dynamic) : Void
    {
        var uid                             : Dynamic= command.data.uid;
        var room                             : Dynamic= rooms_map[uid];
        
        if (as3hx.Compat.truthy(room != null))
        {
            room.update(command.data);
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_EDIT_OK, command, room));
        }
        else
        {
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_EDIT_FAIL, command, room));
        }
    }
    
    private function roomUserJoin(command                             : Dynamic) : Void
    {
        var uid                             : Dynamic= command.data.uid;
        var room                             : Dynamic= rooms_map[uid];
        var user                             : Dynamic= _userUpdateDirect(command.data.user);
        
        if (as3hx.Compat.truthy(room == null))
        {
            return;
        }
        
        // Existing
        if (as3hx.Compat.truthy(user != null))
        {
            user.update(command.data.user);
        }
        // New User
        else
        {
            
            {
                user = new MPUser();
                user.update(command.data.user);
                users.push(user);
                users_map[user.uid] = user;
            }
        }
        
        room.userJoin(user);
        
        dispatchEvent(new MPRoomEvent(MPEvent.ROOM_USER_JOIN, command, room, user));
    }
    
    private function roomUserLeave(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null && user != null))
        {
            room.userLeave(user);
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_USER_LEAVE, command, room, user));
            garbageCollection();
        }
    }
    
    private function roomTeamUpdate(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        
        if (as3hx.Compat.truthy(room != null))
        {
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_TEAM_UPDATE, command, room));
        }
    }
    
    private function roomTeamAdd(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null && user != null))
        {
            room.userJoinTeam(user, command.data.teamUID, command.data.vars);
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_TEAM_ADD, command, room));
        }
    }
    
    private function roomTeamRemove(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null && user != null))
        {
            room.userLeaveTeam(user, command.data.teamUID);
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_TEAM_REMOVE, command, room));
        }
    }
    
    private function roomTeamCaptain(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null && user != null))
        {
            room.userTeamCaptain(user, command.data.teamUID);
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_TEAM_CAPTAIN, command, room));
        }
    }
    
    private function roomMessage(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null && user != null && command.data.message))
        {
            dispatchEvent(new MPRoomEvent(MPEvent.ROOM_MESSAGE, command, room, user));
        }
    }
    
    private function roomModeCommand(command                             : Dynamic) : Void
    {
        var room                             : Dynamic= rooms_map[command.data.uid];
        var user                             : Dynamic= users_map[command.data.userUID];
        
        if (as3hx.Compat.truthy(room != null))
        {
            room.modeCommand(command, user);
        }
    }
    
    private function roomModeRawCommand(command                             : Dynamic) : Void
    {
        command.data.position = 2;
        var roomUID                             : Dynamic= command.data.readUnsignedInt();
        var playerUID                             : Dynamic= command.data.readUnsignedInt();
        
        var room                             : Dynamic= as3hx.Compat.field(rooms_map, roomUID);
        var user                             : Dynamic= as3hx.Compat.field(users_map, playerUID);
        
        if (as3hx.Compat.truthy(room != null))
        {
            room.modeRawCommand(command, user);
        }
    }
    
    private function userMessage(command                             : Dynamic) : Void
    {
        var user_sender                             : Dynamic= _userUpdateDirect(command.data.user);
        var user_chat                             : Dynamic= users_map[command.data.uid];
        
        if (as3hx.Compat.truthy(user_chat != null && user_sender != null && command.data.message))
        {
            _userGetHistory(user_chat).addMessage(user_chat, user_sender, command.data);
            _pmSort();
            dispatchEvent(new MPUserEvent(MPEvent.USER_MESSAGE, command, user_chat, user_sender));
        }
    }
    
    private function userRoomInvite(command                             : Dynamic) : Void
    {
        var user_sender                             : Dynamic= _userUpdateDirect(command.data.user);
        var user                             : Dynamic= users_map[command.data.uid];
        
        if (as3hx.Compat.truthy(user != null && user_sender != null && command.data.name && command.data.code))
        {
            _userGetHistory(user).addGameInvite(user, user_sender, command.data);
            _pmSort();
            dispatchEvent(new MPUserEvent(MPEvent.USER_ROOM_INVITE, command, user));
        }
    }
    
    private function userBlockUpdate(command                             : Dynamic) : Void
    {
        currentUser.blockList = command.data.list;
        dispatchEvent(new MPEvent(MPEvent.USER_BLOCK_UPDATE, command));
    }
    
    private function _roomGetClass(room_data                             : Dynamic) : MPRoom
    {
        var _sw8_ = (room_data.type);        

        switch (_sw8_)
        {
            /* covers case "lobby": */
            default:
                return new MPRoom();
            
            case "ffr":
                return new MPRoomFFR();
        }
    }
    
    /**
     * Create or Update an existing Room object within cache.
     * @param room_data Object Data containing room information.
     */
    private function _roomUpdateDirect(room_data                             : Dynamic) : MPRoom
    {
        var uid                             : Dynamic= room_data.uid;
        var room                             : Dynamic= rooms_map[uid];
        
        // Existing
        if (as3hx.Compat.truthy(room != null))
        {
            room.update(room_data);
        }
        // New Room
        else
        {
            
            {
                room = _roomGetClass(room_data);
                room.update(room_data);
                rooms.push(room);
                rooms_map[room.uid] = room;
            }
        }
        
        return room;
    }
    
    /**
     * Delete MP Room from server command.
     * @param room_data
     * @return
     */
    private function _roomDeleteDirect(room_data                             : Dynamic) : Bool
    {
        var uid                             : Dynamic= room_data.uid;
        var room                             : Dynamic= rooms_map[uid];
        
        // Clear Extra Data from Room.
        if (as3hx.Compat.truthy(room != null))
        {
            room.clear();
            
            var i                             : Dynamic= Lambda.indexOf(rooms, room);
            rooms.splice(i, 1);
            Reflect.deleteField(rooms_map, Std.string(null));
            
            garbageCollection();
            return true;
        }
        return false;
    }
    
    /**
     * Sort the room list based on uid where Lobby is first.
     */
    private function _roomSort() : Void
    {
        rooms.sort(MPRoom.sort);
    }
    
    /**
     * Create or Update an existing User object within cache.
     * @param room_data Object Data containing room information.
     */
    private function _userUpdateDirect(user_data                             : Dynamic) : MPUser
    {
        var uid                             : Dynamic= user_data.uid;
        var user                             : Dynamic= users_map[uid];
        
        // Existing
        if (as3hx.Compat.truthy(user != null))
        {
            user.update(user_data);
        }
        // New Room
        else
        {
            
            {
                user = new MPUser();
                user.update(user_data);
                users.push(user);
                users_map[user.uid] = user;
            }
        }
        
        return user;
    }
    
    /**
     * Get User chat history object, used for displaying PMs.
     * This uses site id instead of uid.
     * @param user
     * @return
     */
    private function _userGetHistory(user                             : Dynamic) : MPUserChatHistory
    {
        var history                             : Dynamic= pms_map[user.sid];
        
        // Create New
        if (as3hx.Compat.truthy(history == null))
        {
            history = new MPUserChatHistory(user);
            pms.push(history);
            pms_map[user.sid] = history;
        }
        
        return history;
    }
    
    /**
     * Sort the chat history based on last message age.
     */
    private function _pmSort() : Void
    {
        pms.sort(MPUserChatHistory.sort);
    }
    
    ///////////////////////////////////
    public function joinLobby() : Void
    {
        if (as3hx.Compat.truthy(LOBBY != null))
        {
            joinRoom(LOBBY);
        }
    }
    
    public function joinRoom(room                             : Dynamic, password                             : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(Lambda.indexOf(activeRooms, room) == -1))
        {
            sendCommand(new MPCRoomJoin(room, password));
        }
    }
    
    private function get_inGameRoom() : Bool
    {
        return connected && GAME_ROOM != null;
    }
    
    private function get_isPlayerInRoom() : Bool
    {
        if (as3hx.Compat.truthy(!connected || GAME_ROOM == null))
        {
            return false;
        }
        
        return GAME_ROOM.isPlayer(this.currentUser);
    }
    
    public function hasUnreadPM() : Bool
    {
        for (history in as3hx.Compat.iter(pms))
        {
            if (as3hx.Compat.truthy(history.newMessage))
            {
                return true;
            }
        }
        
        return false;
    }
    
    ///////////////////////////////////
    // FFR Binding Functions
    
    public function ffrUpdateRate() : Bool
    {
        if (as3hx.Compat.truthy(!connected || GAME_ROOM == null || !(Std.is(GAME_ROOM, MPRoomFFR))))
        {
            return false;
        }
        
        if (as3hx.Compat.truthy(GAME_ROOM.teamSpectator.contains(currentUser)))
        {
            return false;
        }
        
        return sendCommand(new MPCFFRSongRate(try cast(GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null, _gvars.playerUser.songRate));
    }
    
    public function ffrSelectSong(song                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(song == null || !connected || GAME_ROOM == null || !(Std.is(GAME_ROOM, MPRoomFFR))))
        {
            return false;
        }
        
        var cmd                             : Dynamic= new MPCFFRSong(try cast(GAME_ROOM, MPRoomFFR) catch(e:Dynamic) null);
        cmd.name = song.name;
        cmd.author = song.author;
        cmd.time = song.time;
        cmd.note_count = song.note_count;
        cmd.difficulty = song.difficulty;
        cmd.engine = song.engine;
        cmd.id = song.level;
        cmd.level_id = song.level_id;
        
        // File Loader
        if (as3hx.Compat.truthy(song.engine && song.engine.id == "fileloader"))
        {
            cmd.engine = {
                        id : "fileloader",
                        cacheID : song.engine.cache_id,
                        chartID : song.engine.chart_id
                    };
        }
        
        
        return sendCommand(cmd);
    }
    
    ///////////////////////////////////
    private static function get_instance() : Multiplayer
    {
        if (as3hx.Compat.truthy(_instance == null))
        {
            _instance = new Multiplayer(new MultiplayerSingletonEnforcer());
        }
        
        return _instance;
    }
}


class MultiplayerSingletonEnforcer
{

    public function new()
    {
    }
}
