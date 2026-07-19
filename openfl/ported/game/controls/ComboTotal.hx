package game.controls;

import openfl.display.DisplayObjectContainer;
import game.GameOptions;

class ComboTotal extends Combo
{
    public function new(options                       : Dynamic, parent                       : Dynamic)
    {
        super(options, parent);
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_TOTAL;
    }
}

