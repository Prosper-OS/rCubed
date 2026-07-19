package classes.mp.components;

import classes.ui.Box;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;

class MPMenuRoomButton extends Box
{
    private var _name : Text;
    private var _state : Text;
    
    private var _listener : Dynamic = null;
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Float = 0, height : Float = 0, listener : Dynamic = null)
    {
        super(parent, xpos, ypos, true, false);
        super.setSize(width, height);
        
        //- Add Text
        _name = new Text(this, 2, 0, "---name---", 10, "#FFFFFF");
        _name.setAreaParams(width - 4, height / 2 + 1, "center");
        
        _state = new Text(this, 0, height / 2, "----state----", 10, "#FFFFFF");
        _state.setAreaParams(width - 4, height / 2 + 1, "center");
        
        //- Set Defaults
        this.mouseEnabled = true;
        this.mouseChildren = false;
        this.useHandCursor = true;
        this.buttonMode = true;
        
        //- Set click event listener
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(MouseEvent.CLICK, listener);
        }
    }
    
    override public function dispose() : Void
    {
        if (_listener != null)
        {
            this.removeEventListener(MouseEvent.CLICK, _listener);
        }
        
        super.dispose();
        
        if (_name != null)
        {
            _name.dispose();
        }
    }
    
    override public function draw() : Void
    {
        super.draw();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(5, height / 2);
        this.graphics.lineTo(_width - 5, height / 2);
    }
    
    public function updateText(name : String, state : String) : Void
    {
        _name.text = name;
        _state.text = state;
    }
}

