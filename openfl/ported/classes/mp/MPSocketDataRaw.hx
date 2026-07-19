package classes.mp;

import openfl.errors.Error;
import com.worlize.websocket.WebSocketMessage;
import openfl.utils.ByteArray;

class MPSocketDataRaw
{
    public var type : Float;
    public var action : Float;
    public var data : ByteArray;
    
    public function new(type : Float, action : Float, data : ByteArray = null)
    {
        this.type = type;
        this.action = action;
        this.data = data;
    }
    
    public static function parse(message : WebSocketMessage) : MPSocketDataRaw
    {
        try
        {
            if (message == null)
            {
                return null;
            }
            
            // Binary Command
            if (message.type == WebSocketMessage.TYPE_BINARY)
            {
                if (message.binaryData == null || message.binaryData.length == 0)
                {
                    return null;
                }
                
                var data : ByteArray = message.binaryData;
                var type : Float = data.readUnsignedByte();
                var action : Float = data.readUnsignedByte();
                
                data.position = 0;
                
                return new MPSocketDataRaw(type, action, data);
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
        return "[MPSocketDataRaw type=" + type + ", action=" + action + "]";
    }
}

