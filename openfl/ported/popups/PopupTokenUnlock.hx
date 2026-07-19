package popups;

import assets.GameBackgroundColor;
import classes.Language;
import classes.ui.Box;
import classes.ui.BoxButton;
import com.flashfla.utils.SpriteUtil;
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import menu.MenuPanel;

class PopupTokenUnlock extends MenuPanel
{
    private var _lang                       : Dynamic= Language.instance;
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    
    //- Background
    private var box                       : Dynamic;
    private var bmp                       : Dynamic;
    
    private var tType                       : Dynamic;
    private var tID                       : Dynamic;
    private var uText                       : Dynamic;
    private var tObject                       : Dynamic;
    
    private var closeOptions                       : Dynamic;
    
    public function new(myParent                       : Dynamic, tokenType                       : Dynamic, tokenID                       : Dynamic, unlockText                       : Dynamic, tokenName                       : Dynamic= null, tokenMessage                       : Dynamic= null)
    {
        super(myParent);
        tType = tokenType;
        tID = tokenID;
        uText = unlockText;
        tObject = as3hx.Compat.orValue(_gvars.TOKENS_TYPE[tType][tID], { });
        if (as3hx.Compat.truthy(tokenName != null))
        {
            Reflect.setField(tObject, "name", tokenName);
        }
        if (as3hx.Compat.truthy(tokenMessage != null))
        {
            Reflect.setField(tObject, "info", tokenMessage);
        }
    }
    
    override public function stageAdd() : Void
    {
        bmp = SpriteUtil.getBitmapSprite(stage);
        bmp.alpha = 0;
        this.addChild(bmp);
        
        var bh                       : Dynamic= new Sprite();
        bh.x = Main.GAME_WIDTH / 2;
        bh.y = Main.GAME_HEIGHT / 2;
        bh.scaleX = 0.5;
        bh.scaleY = 0.5;
        bh.alpha = 0;
        this.addChild(bh);
        
        var bgbox                       : Dynamic= new Box(bh, -((Main.GAME_WIDTH / 2) / 2), -((Main.GAME_HEIGHT - 40) / 2), false, false);
        bgbox.setSize(Main.GAME_WIDTH / 2, Main.GAME_HEIGHT - 40);
        bgbox.color = GameBackgroundColor.BG_POPUP;
        bgbox.normalAlpha = 0.5;
        bgbox.activeAlpha = 1;
        
        box = new Box(bh, -((Main.GAME_WIDTH / 2) / 2), -((Main.GAME_HEIGHT - 40) / 2), false, false);
        box.setSize(Main.GAME_WIDTH / 2, Main.GAME_HEIGHT - 40);
        box.activeAlpha = 0.4;
        
        var th                       : Dynamic= new Sprite();
        var textbmd                       : Dynamic= new BitmapData(box.width, box.height, true, 0x000000);
        
        var messageDisplay                       : Dynamic= null;
        var yOff                       : Dynamic= 0;
        
        if (as3hx.Compat.truthy(tObject != null)) {
messageDisplay = new TextField();
            messageDisplay.x = 10;
            messageDisplay.y = 0;
            messageDisplay.width = box.width - 20;
            messageDisplay.selectable = false;
            messageDisplay.embedFonts = true;
            messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
            messageDisplay.width = box.width - 20;
            messageDisplay.autoSize = TextFieldAutoSize.CENTER;
            messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            messageDisplay.htmlText = "<FONT SIZE=\"20\">" + _lang.string("popup_token_unlock") + "\n" + tObject.name + "</FONT>";
            th.addChild(messageDisplay);
            yOff = messageDisplay.y + messageDisplay.height;
            
            //- Token Message
            messageDisplay = new TextField();
            messageDisplay.x = 10;
            messageDisplay.y = yOff + 5;
            messageDisplay.width = box.width - 20;
            messageDisplay.selectable = false;
            messageDisplay.embedFonts = true;
            messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
            messageDisplay.width = box.width - 20;
            messageDisplay.wordWrap = true;
            messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            messageDisplay.autoSize = TextFieldAutoSize.CENTER;
            messageDisplay.htmlText = new as3hx.Compat.Regex('\\r\\n', "gi").replace(tObject.info, "\n");
            th.addChild(messageDisplay);
            yOff = messageDisplay.y + messageDisplay.height + 15;
        }
        
        // Divider
        th.graphics.lineStyle(1, 0xffffff);
        th.graphics.moveTo(10, yOff);
        th.graphics.lineTo(box.width - 20, yOff);
        
        yOff += 15;
        
        //- Avatar
        var userAvatar                       : Dynamic= _gvars.activeUser.avatar;
        if (as3hx.Compat.truthy(userAvatar.height > 0 && userAvatar.width > 0))
        {
            var avatarbmd                       : Dynamic= new BitmapData(userAvatar.width, userAvatar.height, true, 0x000000);
            avatarbmd.draw(userAvatar);
            var avatarbmp                       : Dynamic= new Bitmap(avatarbmd);
            avatarbmp.x = (box.width / 2) - (userAvatar.width / 2);
            avatarbmp.y = yOff + 15;
            yOff += userAvatar.height + 15;
            th.addChild(avatarbmp);
        }
        
        //- Username
        messageDisplay = new TextField();
        messageDisplay.x = 10;
        messageDisplay.y = yOff;
        messageDisplay.width = box.width - 20;
        messageDisplay.selectable = false;
        messageDisplay.embedFonts = true;
        messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
        messageDisplay.width = box.width - 20;
        messageDisplay.wordWrap = true;
        messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
        messageDisplay.autoSize = TextFieldAutoSize.CENTER;
        messageDisplay.text = _gvars.activeUser.name;
        th.addChild(messageDisplay);
        
        yOff += messageDisplay.height + 15;
        
        // Divider
        th.graphics.lineStyle(1, 0xffffff);
        th.graphics.moveTo(10, yOff);
        th.graphics.lineTo(box.width - 20, yOff);
        
        yOff += 15;
        
        //- Unlock Message
        messageDisplay = new TextField();
        messageDisplay.x = 10;
        messageDisplay.y = yOff + 5;
        messageDisplay.width = box.width - 20;
        messageDisplay.selectable = false;
        messageDisplay.embedFonts = true;
        messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
        messageDisplay.width = box.width - 20;
        messageDisplay.wordWrap = true;
        messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
        messageDisplay.autoSize = TextFieldAutoSize.CENTER;
        messageDisplay.text = uText;
        th.addChild(messageDisplay);
        
        // Draw Text
        textbmd.draw(th);
        box.addChild(new Bitmap(textbmd));
        
        //- Close
        closeOptions = new BoxButton(box, 15, box.height - 42, box.width - 30, 27, _lang.string("menu_close"), 12, clickHandler);
        
        TweenLite.to(bmp, 1, {
                    alpha : 1
                });
        TweenLite.to(bh, 1, {
                    alpha : 1,
                    scaleX : 1,
                    scaleY : 1,
                    ease : Back.easeOut
                });
    }
    
    override public function stageRemove() : Void
    {
        closeOptions.dispose();
        
        box.dispose();
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

