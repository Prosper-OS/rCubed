package game.controls;

import openfl.display.DisplayObjectContainer;
import game.GameOptions;

class ComboTotal extends Combo
{
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super(options, parent);
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_TOTAL;
    }
}

