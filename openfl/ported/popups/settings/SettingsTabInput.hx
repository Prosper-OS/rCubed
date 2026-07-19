package popups.settings;

import classes.Language;
import classes.Noteskins;
import classes.ui.BoxText;
import classes.ui.Text;
import com.flashfla.utils.StringUtil;
import openfl.display.MovieClip;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextFieldAutoSize;

class SettingsTabInput extends SettingsTabBase
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _noteskins                       : Dynamic= Noteskins.instance;
    
    private var gameplayInputs                       : Dynamic= ["left", "down", "up", "right"];
    private var menuInputs                       : Dynamic= ["restart", "quit", "options"];
    
    private var optionKeyInputs                       : Dynamic;
    private var keyListenerTarget                       : Dynamic;
    
    private var keysHeld                       : Dynamic= [];
    private var keysHeldText                       : Dynamic;
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "input";
    }
    
    override public function openTab() : Void
    {
        parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandlerDown, true, as3hx.Compat.INT_MAX - 10, true);
        parent.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandlerUp, true, as3hx.Compat.INT_MAX - 10, true);
        
        var i                       : Dynamic= null;
        var xOff                       : Dynamic= 15;
        var yOff                       : Dynamic= 15;
        
        var data                       : Dynamic= _noteskins.getInfo(_gvars.activeUser.activeNoteskin);
        var hasRotation                       : Dynamic= (data.rotation != 0);
        
        optionKeyInputs = [];
        
        container.graphics.lineStyle(1, 0xFFFFFF, 0.2);
        
        // gameplay input
        var keyText                       : Dynamic= null;
        var noteScale                       : Dynamic= -1;
        var inputWidth                       : Dynamic= 60;
        var receptorSize                       : Dynamic= 38;
        var curOffX                       : Dynamic= 0;
        
        for (i in 0...gameplayInputs.length)
        {
            curOffX = xOff + ((inputWidth + 35) * i);
            
            keyText = new Text(container, curOffX + 10, yOff + 4, _lang.string("options_scroll_" + gameplayInputs[i]));
            keyText.setAreaParams(inputWidth, 24, "center");
            
            container.graphics.beginFill(0xFFFFFF, 0.07);
            container.graphics.drawRect(curOffX, yOff, inputWidth + 20, 110);
            container.graphics.endFill();
            
            // Set Image
            var columnDirectionNote                       : Dynamic= _noteskins.getReceptor(data.id, "D");
            
            if (as3hx.Compat.truthy(hasRotation))
            {
                columnDirectionNote.rotation = data.rotation * receptorRotations[i];
            }
            
            if (as3hx.Compat.truthy(noteScale < 0))
            {
                noteScale = Math.min(1, receptorSize / Math.max(columnDirectionNote.width, columnDirectionNote.height));
            }
            
            columnDirectionNote.scaleX = columnDirectionNote.scaleY = noteScale;
            container.addChild(columnDirectionNote);
            
            columnDirectionNote.x = curOffX + 10 + (inputWidth / 2);
            columnDirectionNote.y = yOff + (receptorSize / 2) + 33;
            
            var gameKeyInput                       : Dynamic= new BoxText(container, curOffX + 10, yOff + 80, inputWidth, 20);
            gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
            gameKeyInput.mouseEnabled = true;
            gameKeyInput.mouseChildren = false;
            gameKeyInput.useHandCursor = true;
            gameKeyInput.buttonMode = true;
            gameKeyInput.key = gameplayInputs[i];
            gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
            optionKeyInputs.push(gameKeyInput);
        }
        
        xOff = 395;
        
        for (i in 0...menuInputs.length)
        {
            container.graphics.beginFill(0xFFFFFF, 0.07);
            container.graphics.drawRect(xOff, yOff, 175, 34);
            container.graphics.endFill();
            
            new Text(container, xOff + 74, yOff + 7, _lang.string("options_scroll_" + menuInputs[i]));
            
            var gameKeyInput                      : Dynamic= new BoxText(container, xOff + 8, yOff + 7, 60, 19);
            gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
            gameKeyInput.mouseEnabled = true;
            gameKeyInput.mouseChildren = false;
            gameKeyInput.useHandCursor = true;
            gameKeyInput.buttonMode = true;
            gameKeyInput.key = menuInputs[i];
            gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
            optionKeyInputs.push(gameKeyInput);
            yOff += 38;
        }
        
        drawSeperator(container, 15, 555, 135);
        
        // input tester
        xOff = 15;
        yOff = 155;
        keyText = new Text(container, xOff, yOff, _lang.string("options_input_tester"), 16);
        keyText.setAreaParams(555, 24, "center");
        yOff += 28;
        
        keyText = new Text(container, xOff, yOff, _lang.string("options_input_tester_description"), 12);
        keyText.setAreaParams(555, 24, "center");
        
        keysHeldText = new Text(container, xOff, 285, "", 32);
        keysHeldText.setAreaParams(555, 32, "center");
    }
    
    override public function closeTab() : Void
    {
        parent.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandlerDown, true);
        parent.stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandlerUp, true);
        super.closeTab();
    }
    
    override public function setValues() : Void
    {
        for (item in as3hx.Compat.iter(optionKeyInputs))
        {
            item.text = StringUtil.keyCodeChar(as3hx.Compat.field(_gvars.activeUser, "key" + StringUtil.upperCase(item.key))).toUpperCase();
        }
    }
    
    override public function clickHandler(e                       : Dynamic) : Void
    {
        setValues();
        keyListenerTarget = (try cast(e.target, BoxText) catch(e:Dynamic) null);
        keyListenerTarget.htmlText = _lang.string("options_key_pick");
    }
    
    private function keyHandlerDown(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(keyListenerTarget != null))
        {
            var keyCode                       : Dynamic= e.keyCode;
            var keyChar                       : Dynamic= StringUtil.keyCodeChar(keyCode);
            if (as3hx.Compat.truthy(keyChar != ""))
            {
                Reflect.setField(_gvars.activeUser, "key" + StringUtil.upperCase(keyListenerTarget.key), keyCode);
                keyListenerTarget = null;
                setValues();
            }
            
            return;
        }
        
        if (as3hx.Compat.truthy(Lambda.indexOf(keysHeld, e.keyCode) == -1))
        {
            keysHeld[keysHeld.length] = e.keyCode;
            updateHeldText();
        }
        
        e.stopImmediatePropagation();
    }
    
    private function keyHandlerUp(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Lambda.indexOf(keysHeld, e.keyCode) >= 0))
        {
            keysHeld.splice(Lambda.indexOf(keysHeld, e.keyCode), 1)[0];
            updateHeldText();
        }
    }
    
    private function updateHeldText() : Void
    {
        keysHeld.sort();
        
        var keyText                       : Dynamic= "";
        for (keyCode in as3hx.Compat.iter(keysHeld))
        {
            var keyChar                       : Dynamic= StringUtil.keyCodeChar(keyCode);
            if (as3hx.Compat.truthy(keyChar != ""))
            {
                keyText += " " + keyChar + " ";
            }
        }
        keysHeldText.text = keyText;
    }
}

