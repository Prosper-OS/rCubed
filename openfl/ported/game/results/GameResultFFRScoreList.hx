package game.results;

import classes.Language;
import classes.mp.mode.ffr.MPMatchResultsFFR;
import classes.mp.mode.ffr.MPMatchResultsTeam;
import classes.mp.mode.ffr.MPMatchResultsUser;
import classes.ui.ScrollBar;
import classes.ui.ScrollPane;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import classes.ImageCache;





import com.flashfla.utils.NumberUtil;

import openfl.display.GradientType;



import openfl.geom.Matrix;

class GameResultFFRScoreList extends Sprite
{
    private static var _lang : Language = Language.instance;
    
    private var _width : Float = 719;
    private var _height : Float = 235;
    
    private var handler : Dynamic;
    
    private var match : MPMatchResultsFFR;
    private var users : Array<MPMatchResultsUser>;
    
    private var pane : ScrollPane;
    
    private var scrollbarWidth(default, never) : Float = 15;
    private var scrollbar : ScrollBar;
    private var scrollbarBG : Sprite;
    
    private var useTeamView : Bool = false;
    
    // Team Dividers
    private var labelHeight(default, never) : Float = 35;
    private var teamLabels : Array<TeamLabel> = [];
    private var userLabels : Array<GameResultFFRScoreListUserLabel> = [];
    
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        if (parent != null)
        {
            parent.addChild(this);
        }
    }
    
    public function setHandler(handler : Dynamic) : Void
    {
        this.handler = handler;
    }
    
    public function setRoom(match : MPMatchResultsFFR) : Void
    {
        this.match = match;
        this.users = match.users;
        
        build();
        update();
    }
    
    public function build() : Void
    {
        pane = new ScrollPane(this, 0, 0, _width, _height, e_scrollMouseWheel);
        pane.content.addEventListener(MouseEvent.CLICK, e_onPaneClick);
        
        // Scroll Bar
        scrollbarBG = new Sprite();
        scrollbarBG.x = _width + 1;
        scrollbarBG.y = -1;
        addChild(scrollbarBG);
        
        scrollbar = new ScrollBar(this, _width + 1, -1, scrollbarWidth, _height + 2, null, new Sprite(), e_scrollbarUpdater);
        
        // Graphics
        redraw();
    }
    
    public function dispose() : Void
    {
        pane.content.removeEventListener(MouseEvent.CLICK, e_onPaneClick);
    }
    
    public function redraw() : Void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        
        // Scroll BG
        scrollbarBG.graphics.clear();
        
        scrollbarBG.graphics.lineStyle(1, 0xFFFFFF, 0.20);
        scrollbarBG.graphics.moveTo(scrollbarWidth, 0);
        scrollbarBG.graphics.lineTo(scrollbarWidth, _height + 2);
    }
    
    public function update() : Void
    {
        var my : Float = 0;
        
        var GameResultFFRScoreListUserLabel : GameResultFFRScoreListUserLabel;
        
        var team : MPMatchResultsTeam;
        var user : MPMatchResultsUser;
        
        // Multiple Teams
        if (match.teamMode)
        {
            var teamLabel : TeamLabel;
            
            for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(match),teams) type: null */ in match.teams)
            {
                teamLabel = getTeamLabel(team);
                teamLabel.y = my;
                
                my += labelHeight;
                
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(team),users) type: null */ in team.users)
                {
                    GameResultFFRScoreListUserLabel = getUserLabel(user);
                    GameResultFFRScoreListUserLabel.y = my;
                    GameResultFFRScoreListUserLabel.textRank.visible = false;
                    my += labelHeight;
                }
            }
        }
        // Single Team
        else
        {
            
            {
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EArray(EField(EIdent(match),teams),EConst(CInt(0))),users) type: null */ in match.teams[0].users)
                {
                    GameResultFFRScoreListUserLabel = getUserLabel(user);
                    GameResultFFRScoreListUserLabel.y = my;
                    my += labelHeight;
                }
            }
        }
        
        pane.update();
        
        scrollbar.visible = (pane.content.height > pane.height - 5);
    }
    
    private function e_onPaneClick(e : MouseEvent) : Void
    {
        if (handler == null)
        {
            return;
        }
        
        if (Std.is(e.target, GameResultFFRScoreListUserLabel))
        {
            handler((try cast(e.target, GameResultFFRScoreListUserLabel) catch(e:Dynamic) null).user.index);
        }
    }
    
    private function e_scrollMouseWheel(e : MouseEvent) : Void
    {
        if (!scrollbar.visible)
        {
            return;
        }
        
        var dist : Float = scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function e_scrollbarUpdater(e : Event) : Void
    {
        if (!scrollbar.visible)
        {
            return;
        }
        
        pane.scrollTo(e.target.scroll);
    }
    
    override private function set_width(value : Float) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value : Float) : Float
    {
        _height = height;
        redraw();
        return value;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    // //////
    // Object Pool
    private function getUserLabel(user : MPMatchResultsUser) : GameResultFFRScoreListUserLabel
    {
        var newLabel : GameResultFFRScoreListUserLabel = new GameResultFFRScoreListUserLabel(user);
        pane.content.addChild(newLabel);
        
        return newLabel;
    }
    
    private function getTeamLabel(team : MPMatchResultsTeam) : TeamLabel
    {
        var newLabel : TeamLabel = new TeamLabel(team);
        pane.content.addChild(newLabel);
        
        return newLabel;
    }
}



class BaseLabel extends Sprite
{
    private static var BG_WINNER : Array<Dynamic> = [0xD6BA00, 0xD6BA00];
    private static var BG_NORMAL : Array<Dynamic> = [0xFFFFFF, 0xFFFFFF];
    private static var BG_ALPHA : Array<Dynamic> = [0.10, 0.025];
    private static var BG_RATIO : Array<Dynamic> = [0, 255];
    private static var BG_MATRIX : Matrix = new Matrix();
    
    
    private var _width : Float = 719;
    private var _height : Float = 35;
    
    private var hover : Sprite;
    public var textRank : Text;
    private var textName : Text;
    private var textScore : Text;
    
    @:allow(game.results)
    private function new()
    {
        super();
        this.mouseChildren = false;
        
        this.addEventListener(MouseEvent.ROLL_OVER, e_showHover);
        this.addEventListener(MouseEvent.ROLL_OUT, e_hideHover);
        
        build();
    }
    
    private function build() : Void
    {
        hover = new Sprite();
        hover.visible = false;
        hover.graphics.lineStyle(0, 0, 0);
        hover.graphics.beginFill(0xFFFFFF, 0.05);
        hover.graphics.drawRect(0, 0, _width, _height);
        hover.graphics.endFill();
        addChild(hover);
    }
    
    private function draw(isWinner : Bool) : Void
    {
        this.graphics.lineStyle(1, 0xFFFFFF, 0.15);
        this.graphics.moveTo(0, _height - 1);
        this.graphics.lineTo(_width - 1, _height - 1);
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginGradientFill(GradientType.LINEAR, (isWinner) ? BG_WINNER : BG_NORMAL, BG_ALPHA, BG_RATIO, BG_MATRIX);
        this.graphics.drawRect(0, 0, _width - 1, _height - 1);
        this.graphics.endFill();
    }
    
    private function e_showHover(e : MouseEvent) : Void
    {
        hover.visible = true;
    }
    
    private function e_hideHover(e : MouseEvent) : Void
    {
        hover.visible = false;
    }
    private static var BaseLabel_static_initializer = {
        {
            BG_MATRIX.createGradientBox(719, 35, 0);
        };
        true;
    }

}

class TeamLabel extends BaseLabel
{
    private var team : MPMatchResultsTeam;
    
    @:allow(game.results)
    private function new(team : MPMatchResultsTeam)
    {
        this.team = team;
        
        super();
    }
    
    override private function build() : Void
    {
        draw(team.position == 1);
        
        textRank = new Text(this, 0, 0, team.position, 12, "#c7c7c7");
        textRank.setAreaParams(25, _height, "center");
        textRank.cacheAsBitmap = true;
        
        textName = new Text(this, 25, 0, team.name);
        textName.setAreaParams(220, _height);
        textName.cacheAsBitmap = true;
        
        textScore = new Text(this, 230, 0, NumberUtil.numberFormat(team.raw_score));
        textScore.setAreaParams(100, _height, "center");
        textScore.cacheAsBitmap = true;
        
        super.build();
    }
}

class GameResultFFRScoreListUserLabel extends BaseLabel
{
    public var user : MPMatchResultsUser;
    
    private var avatar : Sprite;
    
    private var textRate : Text;
    
    private var textAmazing : Text;
    private var textPerfect : Text;
    private var textGood : Text;
    private var textAverage : Text;
    private var textMiss : Text;
    private var textBoo : Text;
    private var textMaxCombo : Text;
    
    @:allow(game.results)
    private function new(user : MPMatchResultsUser)
    {
        this.user = user;
        this.buttonMode = true;
        
        super();
    }
    
    override private function build() : Void
    {
        draw(user.position == 1);
        
        textRank = new Text(this, 0, 0, user.position, 12, "#c7c7c7");
        textRank.setAreaParams(25, _height, "center");
        
        textName = new Text(this, 50, 0, user.userLabelHTML);
        textName.setAreaParams(185, _height);
        
        avatar = ImageCache.getImage(user.avatarURL, ImageCache.ALIGN_MIDDLE, 25, 25);
        avatar.x = 36 + ((25 - avatar.width) / 2);
        avatar.y = (_height / 2) + ((25 - avatar.height) / 2);
        addChild(avatar);
        
        textRate = new Text(this, 50, 0, "[" + NumberUtil.numberFormat(user.score.options.songRate) + "x]", 12, "#c7c7c7");
        textRate.setAreaParams(185, _height, "right");
        textRate.visible = user.score.options.songRate != 1;
        
        textScore = new Text(this, 230, 0, NumberUtil.numberFormat(user.score.score));
        textScore.setAreaParams(100, _height, "center");
        
        textPerfect = new Text(this, 330, 0, NumberUtil.numberFormat(user.score.amazing + user.score.perfect), 12, "#DCFFCB");
        textPerfect.setAreaParams(64, _height, "center");
        
        textGood = new Text(this, 394, 0, NumberUtil.numberFormat(user.score.good), 12, "#C1FFBD");
        textGood.setAreaParams(64, _height, "center");
        
        textAverage = new Text(this, 458, 0, NumberUtil.numberFormat(user.score.average), 12, "#BCE9C1");
        textAverage.setAreaParams(64, _height, "center");
        
        textMiss = new Text(this, 522, 0, NumberUtil.numberFormat(user.score.miss), 12, "#FFE0E0");
        textMiss.setAreaParams(64, _height, "center");
        
        textBoo = new Text(this, 586, 0, NumberUtil.numberFormat(user.score.boo), 12, "#E7D0B8");
        textBoo.setAreaParams(64, _height, "center");
        
        textMaxCombo = new Text(this, 650, 0, NumberUtil.numberFormat(user.score.max_combo), 12);
        textMaxCombo.setAreaParams(64, _height, "center");
        
        if (!user.alive)
        {
            textRank.alpha = avatar.alpha = textName.alpha = textScore.alpha = textPerfect.alpha = textGood.alpha = textAverage.alpha = textMiss.alpha = textBoo.alpha = textMaxCombo.alpha = 0.4;
        }
        
        super.build();
    }
}
