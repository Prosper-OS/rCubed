package menu;

import classes.Language;
import classes.Playlist;
import classes.SongInfo;
import classes.ui.Box;
import classes.ui.Text;
import com.greensock.TweenLite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class TokenItem extends Sprite
{
    public var index                       : Dynamic;
    public var token_info                       : Dynamic;
    public var token_image                       : Dynamic;
    public var token_levels                       : Dynamic;
    
    private var _lang                       : Dynamic= Language.instance;
    
    public function new(token_data                       : Dynamic)
    {
        super();
        this.token_info = token_data;
        this.buttonMode = true;
        this.mouseChildren = false;
        this.useHandCursor = true;
        
        //- Message
        var messageString                       : Dynamic= new as3hx.Compat.Regex('\\r\\n', "gi").replace(Reflect.field(token_info, "info"), "\n");
        
        // Token Levels
        token_levels = (Std.string(Reflect.field(token_info, "sources"))).split(",");
        
        if (as3hx.Compat.truthy(!(Std.is(token_levels, Array)) || token_levels.length == 0))
        {
            token_levels = [0];
        }
        
        // Token unlock conditions
        if (as3hx.Compat.truthy(token_levels.length > 1))
        {
            if (as3hx.Compat.truthy(token_levels[0] == 0))
            {
                messageString += "\r" + _lang.string("menu_tokens_unknown_unlock_condition");
            }
            else
            {
                messageString += "\r\r" + _lang.string("menu_tokens_unlock_by_playing");
                for (item in as3hx.Compat.iter(token_levels))
                {
                    var tempLevel                       : Dynamic= Playlist.instanceCanon.playList[item];
                    messageString += "\r&gt; " + ((tempLevel != null) ? tempLevel.name : "??");
                }
            }
        }
        
        var messageText                       : Dynamic= new TextField();
        messageText.styleSheet = Constant.STYLESHEET;
        messageText.x = 5;
        messageText.y = 20;
        messageText.selectable = false;
        messageText.embedFonts = true;
        messageText.antiAliasType = AntiAliasType.ADVANCED;
        messageText.multiline = true;
        messageText.width = 510;
        messageText.wordWrap = true;
        messageText.autoSize = TextFieldAutoSize.LEFT;
        //messageText.border = true;
        //messageText.borderColor = 0xffffff;
        messageText.htmlText = "<font face=\"" + Fonts.BASE_FONT_CJK + "\" color=\"#FFFFFF\" size=\"12\"><b>" + messageString + "</b></font>";
        
        //- Make Display
        var box                       : Dynamic= new Box(this, 5, 0, false);
        box.setSize(577, Math.max(54, 32 + (messageText.numLines * 17)));
        
        //- Name
        var nameText                       : Dynamic= new Text(box, 5, 0, Reflect.field(token_info, "name"), 14);
        nameText.setAreaParams(350, 27);
        box.addChild(messageText);
    }
    
    public function addTokenImage(image                       : Dynamic, doFade                       : Dynamic= true) : Void
    {
        var bmd                       : Dynamic= (Reflect.field(token_info, "unlock") != null) ? image.bitmapData : image.bitmapData.clone();
        
        token_image = new Sprite();
        if (as3hx.Compat.truthy(Reflect.field(token_info, "unlock") == 0))
        {
            var rc                       : Dynamic= 0.1;
            var gc                       : Dynamic= 0.1;
            var bc                       : Dynamic= 0.1;
            bmd.applyFilter(bmd, bmd.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
        }
        
        token_image.graphics.beginBitmapFill(bmd, null, false);
        token_image.graphics.drawRect(0, 0, bmd.width, bmd.height);
        token_image.graphics.endFill();
        token_image.x = 532;
        token_image.y = 5;
        addChild(token_image);
        
        if (as3hx.Compat.truthy(doFade))
        {
            token_image.alpha = 0;
            TweenLite.to(token_image, 1.25, {
                        alpha : (Reflect.field(token_info, "unlock") != null) ? 1 : 0.7
                    });
        }
        else
        {
            token_image.alpha = (Reflect.field(token_info, "unlock") != null) ? 1 : 0.7;
        }
    }
}

