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
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    private var _noteskins : Noteskins = Noteskins.instance;
    
    private var gameplayInputs : Array<Dynamic> = ["left", "down", "up", "right"];
    private var menuInputs : Array<Dynamic> = ["restart", "quit", "options"];
    
    private var optionKeyInputs : Array<Dynamic>;
    private var keyListenerTarget : BoxText;
    
    private var keysHeld : Array<Dynamic> = [];
    private var keysHeldText : Text;
    
    public function new(settingsWindow : SettingsWindow)
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
        
        var i : Int;
        var xOff : Int = 15;
        var yOff : Int = 15;
        
        var data : Dynamic = _noteskins.getInfo(_gvars.activeUser.activeNoteskin);
        var hasRotation : Bool = (data.rotation != 0);
        
        optionKeyInputs = [];
        
        container.graphics.lineStyle(1, 0xFFFFFF, 0.2);
        
        // gameplay input
        var keyText : Text;
        var noteScale : Float = -1;
        var inputWidth : Int = 60;
        var receptorSize : Float = 38;
        var curOffX : Float = 0;
        
        for (i in 0...gameplayInputs.length)
        {
            curOffX = xOff + ((inputWidth + 35) * i);
            
            keyText = new Text(container, curOffX + 10, yOff + 4, _lang.string("options_scroll_" + gameplayInputs[i]));
            keyText.setAreaParams(inputWidth, 24, "center");
            
            container.graphics.beginFill(0xFFFFFF, 0.07);
            container.graphics.drawRect(curOffX, yOff, inputWidth + 20, 110);
            container.graphics.endFill();
            
            // Set Image
            var columnDirectionNote : MovieClip = _noteskins.getReceptor(data.id, "D");
            
            if (hasRotation)
            {
                columnDirectionNote.rotation = data.rotation * receptorRotations[i];
            }
            
            if (noteScale < 0)
            {
                noteScale = Math.min(1, receptorSize / Math.max(columnDirectionNote.width, columnDirectionNote.height));
            }
            
            columnDirectionNote.scaleX = columnDirectionNote.scaleY = noteScale;
            container.addChild(columnDirectionNote);
            
            columnDirectionNote.x = curOffX + 10 + (inputWidth / 2);
            columnDirectionNote.y = yOff + (receptorSize / 2) + 33;
            
            var gameKeyInput : BoxText = new BoxText(container, curOffX + 10, yOff + 80, inputWidth, 20);
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
            
            gameKeyInput = new BoxText(container, xOff + 8, yOff + 7, 60, 19);
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
        for (item in optionKeyInputs)
        {
            item.text = StringUtil.keyCodeChar(_gvars.activeUser["key" + StringUtil.upperCase(item.key)]).toUpperCase();
        }
    }
    
    override public function clickHandler(e : MouseEvent) : Void
    {
        setValues();
        keyListenerTarget = (try cast(e.target, BoxText) catch(e:Dynamic) null);
        keyListenerTarget.htmlText = _lang.string("options_key_pick");
    }
    
    private function keyHandlerDown(e : KeyboardEvent) : Void
    {
        if (keyListenerTarget != null)
        {
            var keyCode : Int = e.keyCode;
            var keyChar : String = StringUtil.keyCodeChar(keyCode);
            if (keyChar != "")
            {
                _gvars.activeUser["key" + StringUtil.upperCase(keyListenerTarget.key)] = keyCode;
                keyListenerTarget = null;
                setValues();
            }
            
            return;
        }
        
        if (Lambda.indexOf(keysHeld, e.keyCode) == -1)
        {
            keysHeld[keysHeld.length] = e.keyCode;
            updateHeldText();
        }
        
        e.stopImmediatePropagation();
    }
    
    private function keyHandlerUp(e : KeyboardEvent) : Void
    {
        if (Lambda.indexOf(keysHeld, e.keyCode) >= 0)
        {
            keysHeld.splice(Lambda.indexOf(keysHeld, e.keyCode), 1)[0];
            updateHeldText();
        }
    }
    
    private function updateHeldText() : Void
    {
        keysHeld.sort();
        
        var keyText : String = "";
        for (keyCode in keysHeld)
        {
            var keyChar : String = StringUtil.keyCodeChar(keyCode);
            if (keyChar != "")
            {
                keyText += " " + keyChar + " ";
            }
        }
        keysHeldText.text = keyText;
    }
}

