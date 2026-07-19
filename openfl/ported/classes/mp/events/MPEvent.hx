package classes.mp.events;

import classes.mp.MPSocketDataText;
import openfl.events.Event;

class MPEvent extends Event
{
    // Multiplayer Events
    public static inline var SOCKET_CONNECT : String = "socket_connect";
    public static inline var SOCKET_DISCONNECT : String = "socket_disconnect";
    public static inline var SOCKET_ERROR : String = "socket_disconnect";
    
    public static inline var SYS_LOGIN_OK : String = "sys_login_ok";
    public static inline var SYS_LOGIN_FAIL : String = "sys_login_fail";
    public static inline var SYS_GENERAL_ERROR : String = "sys_error";
    public static inline var SYS_ROOM_ERROR : String = "sys_room_error";
    public static inline var SYS_USER_ERROR : String = "sys_user_error";
    public static inline var SYS_ROOM_LIST : String = "sys_room_list";
    public static inline var SYS_USER_LIST : String = "sys_user_list";
    
    public static inline var ROOM_UPDATE : String = "room_update";
    public static inline var ROOM_CREATE_OK : String = "room_create_ok";
    public static inline var ROOM_CREATE_FAIL : String = "room_create_fail";
    public static inline var ROOM_DELETE_OK : String = "room_delete_ok";
    public static inline var ROOM_DELETE_FAIL : String = "room_delete_fail";
    public static inline var ROOM_JOIN_OK : String = "room_join_ok";
    public static inline var ROOM_JOIN_FAIL : String = "room_join_fail";
    public static inline var ROOM_LEAVE_OK : String = "room_leave_ok";
    public static inline var ROOM_LEAVE_FAIL : String = "room_leave_fail";
    public static inline var ROOM_EDIT_OK : String = "room_edit_ok";
    public static inline var ROOM_EDIT_FAIL : String = "room_edit_fail";
    public static inline var ROOM_USER_JOIN : String = "room_user_join";
    public static inline var ROOM_USER_LEAVE : String = "room_user_leave";
    public static inline var ROOM_TEAM_ADD : String = "room_team_add";
    public static inline var ROOM_TEAM_REMOVE : String = "room_team_remove";
    public static inline var ROOM_TEAM_CAPTAIN : String = "room_team_captain";
    public static inline var ROOM_TEAM_UPDATE : String = "room_team_update";
    public static inline var ROOM_MESSAGE : String = "room_message";
    
    public static inline var USER_UPDATE : String = "user_update";
    public static inline var USER_EDIT_OK : String = "user_edit_ok";
    public static inline var USER_EDIT_FAIL : String = "user_edit_fail";
    public static inline var USER_MESSAGE : String = "user_message";
    public static inline var USER_MESSAGE_READ : String = "user_message_read";
    public static inline var USER_ROOM_INVITE : String = "user_room_invite";
    public static inline var USER_BLOCK_UPDATE : String = "user_block_update";
    
    public static inline var FFR_GAME_STATE : String = "ffr_game_state";
    public static inline var FFR_GAME_MODS : String = "ffr_game_mods";
    public static inline var FFR_PLAYABLE_STATE : String = "ffr_playable_state";
    public static inline var FFR_READY_STATE : String = "ffr_ready_state";
    public static inline var FFR_FORCE_START : String = "ffr_force_start";
    public static inline var FFR_SONG_RATE : String = "ffr_song_rate";
    public static inline var FFR_SONG_CHANGE : String = "ffr_song_change";
    public static inline var FFR_SONG_REQUEST : String = "ffr_song_request";
    public static inline var FFR_LOADING_START : String = "ffr_loading_start";
    public static inline var FFR_LOADING : String = "ffr_loading";
    public static inline var FFR_LOADING_ABORT : String = "ffr_loading_abort";
    public static inline var FFR_COUNTDOWN : String = "ffr_countdown";
    public static inline var FFR_MATCH_START : String = "ffr_match_start";
    public static inline var FFR_AUTO_SPECTATE : String = "ffr_auto_spectate";
    public static inline var FFR_SONG_START : String = "ffr_song_start";
    public static inline var FFR_SCORE_UPDATE : String = "ffr_score_update";
    public static inline var FFR_GET_PLAYBACK : String = "ffr_get_playback";
    public static inline var FFR_GET_SCORE_HISTORY : String = "ffr_get_score_histry";
    public static inline var FFR_MATCH_END : String = "ffr_match_end";
    
    public static inline var FFR_RAW_PLAYBACK_APPEND : Int = 0;
    public static inline var FFR_RAW_PLAYBACK_REQUEST : Int = 1;
    public static inline var FFR_RAW_SCORE_HISTORY_APPEND : Int = 2;
    public static inline var FFR_RAW_SCORE_HISTORY_REQUEST : Int = 3;
    
    public static inline var RAW_TYPE_SYS : Int = 1;
    public static inline var RAW_TYPE_USER : Int = 2;
    public static inline var RAW_TYPE_ROOM : Int = 3;
    public static inline var RAW_TYPE_MODE : Int = 4;
    
    // UI Events
    public static inline var ROOM_USERLIST_SELECT : String = "ROOM_USERLIST_SELECT";
    public static inline var ROOM_USERLIST_SPECTATE : String = "ROOM_USERLIST_SPECTATE";
    
    public var command : MPSocketDataText;
    
    public function new(type : String, command : MPSocketDataText)
    {
        super(type, false, false);
        
        this.command = command;
    }
    
    override public function toString() : String
    {
        return "---------------------------------\n[MPEvent type=" + type + "]" + "\n" + command;
    }
}

