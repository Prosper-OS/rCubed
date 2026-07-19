package popups;

import assets.GameBackgroundColor;
import classes.Language;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.Text;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import menu.MenuPanel;

class PopupMessage extends MenuPanel
{
    //- Background
    private var box                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var titleDisplay                       : Dynamic;
    private var messageDisplay                       : Dynamic;
    
    private var _lang                      : Dynamic;
    
    private var displayTitle                       : Dynamic= "";
    private var dislayText                      : Dynamic= "";
    private var closeOptions                       : Dynamic;
    
    public function new(myParent                       : Dynamic, dislayText                       : Dynamic, displayTitle                       : Dynamic= "")
    {
        super(myParent);
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        _lang = Language.instance;
        this.dislayText = dislayText;
        this.displayTitle = displayTitle;
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
        
        titleDisplay = new Text(box, 5, 5, displayTitle, 20);
        titleDisplay.width = box.width - 10;
        titleDisplay.align = Text.CENTER;
        
        messageDisplay = new Text(box, 5, 0, dislayText, 14);
        messageDisplay.height = box.height;
        messageDisplay.width = box.width - 10;
        messageDisplay.align = Text.CENTER;
        
        //- Close
        closeOptions = new BoxButton(box, box.width - 94.5, box.height - 42, 79.5, 27, _lang.string("menu_close"), 12, clickHandler);
    }
    
    override public function stageRemove() : Void
    {
        closeOptions.dispose();
        box.dispose();
        titleDisplay.dispose();
        messageDisplay.dispose();
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

