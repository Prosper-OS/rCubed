package classes.mp.components.chatlog;

import openfl.display.Sprite;

class MPChatLogEntry extends Sprite
{
    public var built                             : Dynamic= false;
    
    public var _width                             : Dynamic= 200;
    public var _height                             : Dynamic= 30;
    
    public function new()
    {
        super();
    }
    
    public function build(width                             : Dynamic) : Void
    {
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
}

