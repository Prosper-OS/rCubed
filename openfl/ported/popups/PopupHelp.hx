package popups;

import assets.GameBackgroundColor;
import classes.Language;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.Text;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import openfl.text.AntiAliasType;
import openfl.text.StyleSheet;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import menu.MenuPanel;

class PopupHelp extends MenuPanel
{
    private var _lang                       : Dynamic= Language.instance;
    
    //- Background
    private var box                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var titleDisplay                       : Dynamic;
    private var messageDisplay                       : Dynamic;
    
    private var closeOptions                       : Dynamic;
    
    public function new(myParent                       : Dynamic)
    {
        super(myParent);
    }
    
    override public function stageAdd() : Void
    {
        bmp = SpriteUtil.getBitmapSprite(stage);
        this.addChild(bmp);
        
        var bgbox                       : Dynamic= new Box(this, 20, 20, false, false);
        bgbox.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        bgbox.color = GameBackgroundColor.BG_POPUP;
        bgbox.normalAlpha = 0.5;
        bgbox.activeAlpha = 1;
        
        box = new Box(this, 20, 20, false, false);
        box.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        box.activeAlpha = 0.4;
        box.mouseChildren = true;
        box.mouseEnabled = true;
        
        titleDisplay = new Text(box, 5, 5, _lang.string("popup_help_title"), 20);
        titleDisplay.width = box.width - 10;
        titleDisplay.align = Text.CENTER;
        
        //- Message
        var style                       : Dynamic= new StyleSheet();
        style.setStyle("BODY", {
                    color : "#FFFFFF",
                    fontSize : 14
                });
        style.setStyle("A", {
                    textDecoration : "underline",
                    fontWeight : "bold"
                });
        messageDisplay = new TextField();
        messageDisplay.styleSheet = style;
        messageDisplay.x = 5;
        messageDisplay.y = 30;
        messageDisplay.selectable = false;
        messageDisplay.embedFonts = true;
        messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
        messageDisplay.multiline = true;
        messageDisplay.width = box.width - 10;
        messageDisplay.wordWrap = true;
        messageDisplay.autoSize = TextFieldAutoSize.LEFT;
        messageDisplay.htmlText = "<BODY>" + _lang.string("popup_help_text") + "</BODY>";
        
        box.addChild(messageDisplay);
        
        //- Close
        closeOptions = new BoxButton(box, box.width - 94.5, box.height - 42, 79.5, 27, _lang.string("menu_close"), 12, clickHandler);
    }
    
    override public function stageRemove() : Void
    {
        closeOptions.dispose();
        
        box.dispose();
        titleDisplay.dispose();
        this.removeChild(box);
        this.removeChild(bmp);
        bmp = null;
        box = null;
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    //- Close
    {
        
        if (as3hx.Compat.truthy(e.target == closeOptions))
        {
            removePopup();
            return;
        }
    }
}


