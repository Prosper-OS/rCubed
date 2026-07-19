package classes.mp.events;

import classes.mp.MPSocketDataText;
import openfl.events.Event;

class MPEvent extends Event
{
    // Multiplayer Events
    public static inline var SOCKET_CONNECT                             : Dynamic= "socket_connect";
    public static inline var SOCKET_DISCONNECT                             : Dynamic= "socket_disconnect";
    public static inline var SOCKET_ERROR                             : Dynamic= "socket_disconnect";
    
    public static inline var SYS_LOGIN_OK                             : Dynamic= "sys_login_ok";
    public static inline var SYS_LOGIN_FAIL                             : Dynamic= "sys_login_fail";
    public static inline var SYS_GENERAL_ERROR                             : Dynamic= "sys_error";
    public static inline var SYS_ROOM_ERROR                             : Dynamic= "sys_room_error";
    public static inline var SYS_USER_ERROR                             : Dynamic= "sys_user_error";
    public static inline var SYS_ROOM_LIST                             : Dynamic= "sys_room_list";
    public static inline var SYS_USER_LIST                             : Dynamic= "sys_user_list";
    
    public static inline var ROOM_UPDATE                             : Dynamic= "room_update";
    public static inline var ROOM_CREATE_OK                             : Dynamic= "room_create_ok";
    public static inline var ROOM_CREATE_FAIL                             : Dynamic= "room_create_fail";
    public static inline var ROOM_DELETE_OK                             : Dynamic= "room_delete_ok";
    public static inline var ROOM_DELETE_FAIL                             : Dynamic= "room_delete_fail";
    public static inline var ROOM_JOIN_OK                             : Dynamic= "room_join_ok";
    public static inline var ROOM_JOIN_FAIL                             : Dynamic= "room_join_fail";
    public static inline var ROOM_LEAVE_OK                             : Dynamic= "room_leave_ok";
    public static inline var ROOM_LEAVE_FAIL                             : Dynamic= "room_leave_fail";
    public static inline var ROOM_EDIT_OK                             : Dynamic= "room_edit_ok";
    public static inline var ROOM_EDIT_FAIL                             : Dynamic= "room_edit_fail";
    public static inline var ROOM_USER_JOIN                             : Dynamic= "room_user_join";
    public static inline var ROOM_USER_LEAVE                             : Dynamic= "room_user_leave";
    public static inline var ROOM_TEAM_ADD                             : Dynamic= "room_team_add";
    public static inline var ROOM_TEAM_REMOVE                             : Dynamic= "room_team_remove";
    public static inline var ROOM_TEAM_CAPTAIN                             : Dynamic= "room_team_captain";
    public static inline var ROOM_TEAM_UPDATE                             : Dynamic= "room_team_update";
    public static inline var ROOM_MESSAGE                             : Dynamic= "room_message";
    
    public static inline var USER_UPDATE                             : Dynamic= "user_update";
    public static inline var USER_EDIT_OK                             : Dynamic= "user_edit_ok";
    public static inline var USER_EDIT_FAIL                             : Dynamic= "user_edit_fail";
    public static inline var USER_MESSAGE                             : Dynamic= "user_message";
    public static inline var USER_MESSAGE_READ                             : Dynamic= "user_message_read";
    public static inline var USER_ROOM_INVITE                             : Dynamic= "user_room_invite";
    public static inline var USER_BLOCK_UPDATE                             : Dynamic= "user_block_update";
    
    public static inline var FFR_GAME_STATE                             : Dynamic= "ffr_game_state";
    public static inline var FFR_GAME_MODS                             : Dynamic= "ffr_game_mods";
    public static inline var FFR_PLAYABLE_STATE                             : Dynamic= "ffr_playable_state";
    public static inline var FFR_READY_STATE                             : Dynamic= "ffr_ready_state";
    public static inline var FFR_FORCE_START                             : Dynamic= "ffr_force_start";
    public static inline var FFR_SONG_RATE                             : Dynamic= "ffr_song_rate";
    public static inline var FFR_SONG_CHANGE                             : Dynamic= "ffr_song_change";
    public static inline var FFR_SONG_REQUEST                             : Dynamic= "ffr_song_request";
    public static inline var FFR_LOADING_START                             : Dynamic= "ffr_loading_start";
    public static inline var FFR_LOADING                             : Dynamic= "ffr_loading";
    public static inline var FFR_LOADING_ABORT                             : Dynamic= "ffr_loading_abort";
    public static inline var FFR_COUNTDOWN                             : Dynamic= "ffr_countdown";
    public static inline var FFR_MATCH_START                             : Dynamic= "ffr_match_start";
    public static inline var FFR_AUTO_SPECTATE                             : Dynamic= "ffr_auto_spectate";
    public static inline var FFR_SONG_START                             : Dynamic= "ffr_song_start";
    public static inline var FFR_SCORE_UPDATE                             : Dynamic= "ffr_score_update";
    public static inline var FFR_GET_PLAYBACK                             : Dynamic= "ffr_get_playback";
    public static inline var FFR_GET_SCORE_HISTORY                             : Dynamic= "ffr_get_score_histry";
    public static inline var FFR_MATCH_END                             : Dynamic= "ffr_match_end";
    
    public static inline var FFR_RAW_PLAYBACK_APPEND                             : Dynamic= 0;
    public static inline var FFR_RAW_PLAYBACK_REQUEST                             : Dynamic= 1;
    public static inline var FFR_RAW_SCORE_HISTORY_APPEND                             : Dynamic= 2;
    public static inline var FFR_RAW_SCORE_HISTORY_REQUEST                             : Dynamic= 3;
    
    public static inline var RAW_TYPE_SYS                             : Dynamic= 1;
    public static inline var RAW_TYPE_USER                             : Dynamic= 2;
    public static inline var RAW_TYPE_ROOM                             : Dynamic= 3;
    public static inline var RAW_TYPE_MODE                             : Dynamic= 4;
    
    // UI Events
    public static inline var ROOM_USERLIST_SELECT                             : Dynamic= "ROOM_USERLIST_SELECT";
    public static inline var ROOM_USERLIST_SPECTATE                             : Dynamic= "ROOM_USERLIST_SPECTATE";
    
    public var command                             : Dynamic;
    
    public function new(type                             : Dynamic, command                             : Dynamic)
    {
        super(type, false, false);
        
        this.command = command;
    }
    
    override public function toString() : String
    {
        return "---------------------------------\n[MPEvent type=" + type + "]" + "\n" + command;
    }
}

