package popups;

import assets.GameBackgroundColor;
import classes.Language;
import classes.SongInfo;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.Text;
import classes.ui.Throbber;
import com.flashfla.loader.DataEvent;
import com.flashfla.utils.NumberUtil;
import com.flashfla.utils.ObjectUtil;
import com.flashfla.utils.SpriteUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import menu.MenuPanel;

class PopupHighscores extends MenuPanel
{
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _lang : Language = Language.instance;
    
    // - Background
    private var box : Box;
    private var bmp : Bitmap;
    
    private var page : Int = 0;
    private var maxPage : Int = 1000;
    private var throbber : Throbber;
    private var pageText : Text;
    private var myUsernameText : Text;
    private var myScoreText : Text;
    private var myAVText : Text;
    private var songInfo : SongInfo;
    private var scorePane : Sprite;
    
    private var prevBtn : BoxButton;
    private var nextBtn : BoxButton;
    private var closeBtn : BoxButton;
    private var refreshBtn : BoxButton;
    
    public function new(myParent : MenuPanel, songInfo : SongInfo)
    {
        super(myParent);
        this.songInfo = songInfo;
    }
    
    override public function stageAdd() : Void
    {
        bmp = SpriteUtil.getBitmapSprite(stage);
        this.addChild(bmp);
        
        var bgbox : Box = new Box(this, 20, 20, false, false);
        bgbox.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        bgbox.color = GameBackgroundColor.BG_POPUP;
        bgbox.normalAlpha = 0.5;
        bgbox.activeAlpha = 1;
        
        box = new Box(this, 20, 20, false, false);
        box.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40);
        box.activeAlpha = 0.4;
        
        var titleDisplay : Text = new Text(box, 5, 8, songInfo.name, 20);
        titleDisplay.width = box.width - 10;
        titleDisplay.align = Text.CENTER;
        
        pageText = new Text(box, 200, box.height - 42, sprintf(_lang.string("popup_highscores_page_number"), {
                            page : page + 1
                        }));
        
        var infoRanks : Dynamic = _gvars.activeUser.getLevelRank(songInfo);
        // Username
        myUsernameText = new Text(box, 25, 345, "#" + infoRanks.rank + ": " + _gvars.activeUser.name, 16, "#D9FF9E");
        myUsernameText.width = 350;
        
        // Score
        myScoreText = new Text(box, 400, 345, NumberUtil.numberFormat(infoRanks.rawscore), 15, "#B8D8B3");
        myScoreText.width = 120;
        
        // AV
        myAVText = new Text(box, 545, 345, infoRanks.results, 15, "#99B793");
        myAVText.width = 180;
        
        //- Previous
        prevBtn = new BoxButton(box, 10, box.height - 42, 79.5, 27, _lang.string("popup_highscores_previous"), 12, clickHandler);
        
        //- Next
        nextBtn = new BoxButton(box, 100, box.height - 42, 79.5, 27, _lang.string("popup_highscores_next"), 12, clickHandler);
        
        //- Close
        closeBtn = new BoxButton(box, box.width - 94.5, box.height - 42, 79.5, 27, _lang.string("menu_close"), 12, clickHandler);
        
        //- Refresh
        refreshBtn = new BoxButton(box, box.width - 184.5, box.height - 42, 79.5, 27, _lang.string("popup_highscores_refresh"), 12, clickHandler);
        
        //- Render List
        renderHighscores();
    }
    
    private function renderHighscores() : Void
    {
        if (scorePane != null && box != null && box.contains(scorePane))
        {
            box.removeChild(scorePane);
            scorePane = null;
        }
        scorePane = new Sprite();
        scorePane.y = 50;
        if (box != null)
        {
            box.addChild(scorePane);
        }
        
        var textLine : Text;
        var urank : Text;
        var tY : Int = 0;
        
        if (throbber != null)
        {
            if (box != null && box.contains(throbber))
            {
                box.removeChild(throbber);
            }
            throbber.stop();
        }
        
        if (page > maxPage)
        {
            page = maxPage;
        }
        
        var highscores : Dynamic = _gvars.getHighscores(songInfo.level);
        if (highscores != null && (Reflect.field(highscores, Std.string((10 * page) + 1)) != null)) {
textLine = new Text(scorePane, 25, tY, _lang.string("popup_highscores_username"), 16, "#C6F0FF");
            textLine.width = 350;
            
            // Score
            textLine = new Text(scorePane, 400, tY, _lang.string("popup_highscores_score"), 15, "#C6F0FF");
            textLine.width = 120;
            
            // AV
            textLine = new Text(scorePane, 545, tY, _lang.string("popup_highscores_pa_spread"), 15, "#C6F0FF");
            textLine.width = 180;
            tY += 30;
            
            var lastRank : Int = 0;
            var lastScore : Float = as3hx.Compat.FLOAT_MAX;
            for (vr in 1...10)
            {
                var r : Int = as3hx.Compat.parseInt((10 * page) + vr);
                if (Reflect.field(highscores, Std.string(r)) != null)
                {
                    var username : String = Reflect.field(Reflect.field(highscores, Std.string(r)), "username");
                    var score : Float = Reflect.field(Reflect.field(highscores, Std.string(r)), "score");
                    var av : String = Reflect.field(Reflect.field(highscores, Std.string(r)), "av");
                    var level : String = Std.string(Math.floor(Reflect.field(Reflect.field(highscores, Std.string(r)), "level")));
                    var isMyPB : Bool = (!_gvars.activeUser.isGuest) && (_gvars.activeUser.name == username);
                    
                    // Username
                    textLine = new Text(scorePane, 25, tY, "<font color=\"#CCCCCC\">#" + r + ":</font> " + username + " <font size=\"13\" color=\"#CCCCCC\">[Lv " + level + "]</font>", 16);
                    textLine.width = 350;
                    textLine.fontColor = (isMyPB) ? "#D9FF9E" : "#FFFFFF";
                    
                    // Score
                    textLine = new Text(scorePane, 400, tY, NumberUtil.numberFormat(score), 15);
                    textLine.width = 120;
                    textLine.fontColor = (isMyPB) ? "#B8D8B3" : "#DDDDDD";
                    
                    // AV
                    textLine = new Text(scorePane, 545, tY, av, 15);
                    textLine.width = 180;
                    textLine.fontColor = (isMyPB) ? "#99B793" : "#BBBBBB";
                    tY += 25;
                }
                else
                {
                    maxPage = page;
                    break;
                }
            }
        }
        else
        {
            if (throbber == null)
            {
                throbber = new Throbber();
                if (box != null)
                {
                    throbber.x = box.width / 2 - 16;
                    throbber.y = box.height / 2 - 16;
                }
            }
            if (box != null)
            {
                box.addChild(throbber);
            }
            throbber.start();
            
            _gvars.addEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
            _gvars.loadHighscores(songInfo.level, page * 10);
        }
        pageText.text = sprintf(_lang.string("popup_highscores_page_number"), {
                            page : page + 1
                        });
        
        prevBtn.enabled = (page == 0) ? false : true;
        prevBtn.alpha = (page == 0) ? 0.5 : 1;
        nextBtn.enabled = (page == maxPage) ? false : true;
        nextBtn.alpha = (page == maxPage) ? 0.5 : 1;
    }
    
    private function highscoresLoaded(e : DataEvent) : Void
    {
        _gvars.removeEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
        if (e.data.error == null)
        {
            var newEntriesCount : Int = ObjectUtil.count(e.data);
            // No entries but no error, last page.
            if (newEntriesCount == 0)
            {
                page--;
                maxPage = page;
            }
            // Less then 10 entries, most likely the last page.
            else if (newEntriesCount < 10)
            {
                maxPage = page;
            }
        }
        renderHighscores();
    }
    
    private function refreshPersonalRanks() : Void
    {
        var infoRanks : Dynamic = _gvars.activeUser.getLevelRank(songInfo);
        myUsernameText.text = "#" + infoRanks.rank + ": " + _gvars.activeUser.name;
        myScoreText.text = NumberUtil.numberFormat(infoRanks.rawscore);
        myAVText.text = infoRanks.results;
    }
    
    override public function stageRemove() : Void
    {
        prevBtn.dispose();
        nextBtn.dispose();
        closeBtn.dispose();
        refreshBtn.dispose();
        
        box.dispose();
        this.removeChild(box);
        this.removeChild(bmp);
        bmp = null;
        box = null;
    }
    
    private function clickHandler(e : MouseEvent) : Void
    {
        if (e.target == prevBtn)
        {
            if (page > 0)
            {
                page--;
                renderHighscores();
            }
        }
        if (e.target == nextBtn)
        {
            page++;
            renderHighscores();
        }
        if (e.target == refreshBtn)
        {
            _gvars.clearHighscores();
            _gvars.activeUser.loadLevelRanks();
            refreshPersonalRanks();
            renderHighscores();
        }
        
        //- Close
        if (e.target == closeBtn)
        {
            removePopup();
            return;
        }
    }
}

