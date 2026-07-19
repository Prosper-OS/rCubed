package classes.mp.commands;


class MPCommands
{
    public static inline var UPDATE_LOBBY : String = "{\"t\":\"sys\",\"a\":\"lobby\"}";
    
    public static inline var UPDATE_ROOM_LIST : String = "{\"t\":\"sys\",\"a\":\"room_list\"}";
    
    public static inline var TOGGLE_MODE_READY_STATE : String = "{\"t\":\"mode\",\"a\":\"ready\"}";

    public function new()
    {
    }
}

