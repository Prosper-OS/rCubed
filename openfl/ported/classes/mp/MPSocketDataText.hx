package classes.mp;

import openfl.errors.Error;
import com.flashfla.utils.ObjectUtil;
import com.worlize.websocket.WebSocketMessage;

class MPSocketDataText
{
    public var type                             : Dynamic;
    public var action                             : Dynamic;
    public var data                             : Dynamic;
    
    public function new(type                             : Dynamic, action                             : Dynamic, data                             : Dynamic= null)
    {
        this.type = type;
        this.action = action;
        this.data = data;
    }
    
    public static function parse(message                             : Dynamic) : MPSocketDataText
    {
        try
        {
            if (as3hx.Compat.truthy(message.type == WebSocketMessage.TYPE_UTF8))
            {
                var strData                             : Dynamic= message.utf8Data;
                if (as3hx.Compat.truthy(strData == null || strData.length == 0))
                {
                    return null;
                }
                
                // JSON String
                if (as3hx.Compat.truthy(strData.charAt(0) == "{"))
                {
                    var json                             : Dynamic= haxe.Json.parse(strData);
                    
                    if (as3hx.Compat.truthy(json.t == null || json.a == null))
                    {
                        return null;
                    }
                    
                    return new MPSocketDataText(json.t, json.a, json.d);
                }
            }
        }
        catch (err : Error)
        {
            trace("parseMessage err:", err);
        }
        
        return null;
    }
    
    public function toString() : String
    {
        return "[MPSocketDataText type=" + type + ", action=" + action + "]\n" + ObjectUtil.print_r(data);
    }
}

