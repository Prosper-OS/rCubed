package classes.mp.components.chatlog;

import openfl.display.Sprite;

class MPChatLogEntry extends Sprite
{
    public var built : Bool = false;
    
    private var _width : Float = 200;
    private var _height : Float = 30;
    
    public function new()
    {
        super();
    }
    
    public function build(width : Float) : Void
    {
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
}

