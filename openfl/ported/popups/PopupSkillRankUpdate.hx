package popups;

import classes.Language;
import classes.ui.Box;
import classes.ui.BoxButton;
import com.greensock.TweenLite;
import com.greensock.easing.BackIn;
import com.greensock.easing.BackOut;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import menu.MenuPanel;

class PopupSkillRankUpdate extends MenuPanel
{
    private var _lang                       : Dynamic= Language.instance;
    
    private var box                       : Dynamic;
    private var closeBox                       : Dynamic;
    private var results                       : Dynamic;
    
    public function new(myParent                       : Dynamic, results                       : Dynamic)
    {
        super(myParent);
        this.results = results;
    }
    
    override public function stageAdd() : Void
    {
        var renderPlane                       : Dynamic= new Sprite();
        var yOffset                       : Dynamic= 5;
        yOffset += renderMessages(renderPlane, yOffset, Reflect.field(results, "positive"), 0x00ff00);
        yOffset += renderMessages(renderPlane, yOffset, Reflect.field(results, "negative"), 0xff0000);
        yOffset += renderMessages(renderPlane, yOffset, Reflect.field(results, "neutral"), 0x0000ff);
        
        box = new Box(this, 9, Main.GAME_HEIGHT + 2, false, false);
        box.setSize(Main.GAME_WIDTH - 20, renderPlane.height + 50);
        box.color = 0x1187AB;
        box.activeAlpha = 1;
        box.normalAlpha = 0.8;
        box.addChild(renderPlane);
        
        closeBox = new BoxButton(box, 682, 7, 72, 35, _lang.string("menu_close"), 12, clickHandler);
        closeBox.buttonMode = true;
        closeBox.mouseChildren = false;
        
        TweenLite.to(box, 0.5, {
                    y : Main.GAME_HEIGHT - (box.height - 40),
                    ease : BackOut.ease
                });
    }
    
    override public function stageRemove() : Void
    {
        closeBox.dispose();
        
        box.dispose();
        box = null;
    }
    
    private function clickHandler(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(e.target == closeBox))
        {
            if (as3hx.Compat.truthy(this.parent.contains(this)))
            {
                TweenLite.to(box, 0.5, {
                            y : Main.GAME_HEIGHT + 2,
                            ease : BackIn.ease,
                            onCompleteParams : [this],
                            onComplete : function(trg                       : Dynamic) : Void
                            {
                                trg.parent.removeChild(trg);
                            }
                        });
            }
        }
    }
    
    private function renderMessages(target                       : Dynamic, offetY                       : Dynamic, messages                       : Dynamic, color                       : Dynamic= 0xFFFFFF) : Float
    {
        if (as3hx.Compat.truthy(messages.length <= 0))
        {
            return 0;
        }
        
        var tf                       : Dynamic= new TextField();
        tf = new TextField();
        tf.x = 10;
        tf.y = offetY + 5;
        tf.height = 30;
        tf.width = Main.GAME_WIDTH - 40;
        tf.wordWrap = true;
        tf.multiline = true;
        tf.embedFonts = true;
        tf.selectable = false;
        tf.autoSize = "left";
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.defaultTextFormat = Constant.TEXT_FORMAT_12;
        tf.htmlText = messages.join("\n");
        target.addChild(tf);
        
        target.graphics.lineStyle(1, 0xffffff, 0);
        target.graphics.beginFill(color, 0.25);
        target.graphics.drawRoundRect(5, offetY, tf.width + 10, tf.height + 10, 15, 15);
        target.graphics.endFill();
        
        return tf.height + 15;
    }
}

