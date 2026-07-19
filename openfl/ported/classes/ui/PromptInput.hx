package classes.ui;

import assets.menu.icons.fa.IconClose;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

class PromptInput extends Prompt
{
    public var _callback                             : Dynamic= null;
    
    public var _text                             : Dynamic;
    public var _textfield                             : Dynamic;
    public var _submit_button                             : Dynamic;
    public var _close_button                             : Dynamic;
    
    public function new(parent                             : Dynamic, title                             : Dynamic= "", buttonText                             : Dynamic= "", callback                             : Dynamic= null, displayAsPassword                             : Dynamic= false)
    {
        super(parent, 400, 120);
        
        this._callback = callback;
        
        //- Add Text
        _text = new Text(this, 9, 10, title, 16);
        _text.setAreaParams(width - 45, 22);
        
        //- Add Close Button
        _close_button = new BoxIcon(this, _width - 32, 10, 22, 22, new IconClose(), closePrompt);
        
        //- Add Textfield
        _textfield = new BoxText(this, 10, 43, _width - 21, 26);
        _textfield.field.y += 1;
        _textfield.displayAsPassword = displayAsPassword;
        _textfield.field.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
        stage.focus = _textfield.field;
        
        //- Add Submit Button
        _submit_button = new BoxButton(this, _width - 130, _height - 39, 120, 29, buttonText, 12, submitPrompt);
    }
    
    public function closePrompt(e                             : Dynamic= null) : Void
    {
        _textfield.field.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
        _textfield.dispose();
        _submit_button.dispose();
        _close_button.dispose();
        _text.dispose();
        
        close();
    }
    
    public function submitPrompt(e                             : Dynamic= null) : Void
    {
        if (as3hx.Compat.truthy(this._callback != null && _textfield.field.text.length > 0))
        {
            this._callback(_textfield.field.text);
        }
        
        dispatchEvent(new Event(Event.CLOSE));
        closePrompt();
    }
    
    public function keyDown(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.keyCode == Keyboard.ENTER))
        {
            submitPrompt();
        }
        else if (as3hx.Compat.truthy(e.keyCode == Keyboard.ESCAPE))
        {
            closePrompt();
        }
    }
}

