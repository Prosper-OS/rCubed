package classes.mp.events;

import openfl.events.Event;

class MPViewEvent extends Event
{
    public static inline var CHANGE : String = "change_selected_view";
    
    public var view : String;
    
    public function new(view : String)
    {
        super(CHANGE, false, false);
        
        this.view = view;
    }
}

