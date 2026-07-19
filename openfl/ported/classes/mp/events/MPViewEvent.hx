package classes.mp.events;

import openfl.events.Event;

class MPViewEvent extends Event
{
    public static inline var CHANGE                             : Dynamic= "change_selected_view";
    
    public var view                             : Dynamic;
    
    public function new(view                             : Dynamic)
    {
        super(CHANGE, false, false);
        
        this.view = view;
    }
}

