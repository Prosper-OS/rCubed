package classes.mp;

import openfl.errors.Error;
import com.worlize.websocket.WebSocketMessage;
import openfl.utils.ByteArray;

class MPSocketDataRaw
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
    
    public static function parse(message                             : Dynamic) : MPSocketDataRaw
    {
        try
        {
            if (as3hx.Compat.truthy(message == null))
            {
                return null;
            }
            
            // Binary Command
            if (as3hx.Compat.truthy(message.type == WebSocketMessage.TYPE_BINARY))
            {
                if (as3hx.Compat.truthy(message.binaryData == null || message.binaryData.length == 0))
                {
                    return null;
                }
                
                var data                             : Dynamic= message.binaryData;
                var type                             : Dynamic= data.readUnsignedByte();
                var action                             : Dynamic= data.readUnsignedByte();
                
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

