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
    private static var _lang                       : Dynamic= Language.instance;
    
    private var _width                       : Dynamic= 719;
    private var _height                       : Dynamic= 235;
    
    private var handler                       : Dynamic;
    
    private var match                       : Dynamic;
    private var users                       : Dynamic;
    
    private var pane                       : Dynamic;
    
    private var scrollbarWidth(default, never)                       : Dynamic= 15;
    private var scrollbar                       : Dynamic;
    private var scrollbarBG                       : Dynamic;
    
    private var useTeamView                       : Dynamic= false;
    
    // Team Dividers
    private var labelHeight(default, never)                       : Dynamic= 35;
    private var teamLabels                       : Dynamic= [];
    private var userLabels                       : Dynamic= [];
    
    public function new(parent                       : Dynamic= null, xpos                       : Dynamic= 0, ypos                       : Dynamic= 0)
    {
        super();
        this.x = xpos;
        this.y = ypos;
        
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
    }
    
    public function setHandler(handler                       : Dynamic) : Void
    {
        this.handler = handler;
    }
    
    public function setRoom(match                       : Dynamic) : Void
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
        var my                       : Dynamic= 0;
        
        var GameResultFFRScoreListUserLabel                       : Dynamic= null;
        
        var team                       : Dynamic= null;
        var user                       : Dynamic= null;
        
        // Multiple Teams
        if (as3hx.Compat.truthy(match.teamMode))
        {
            var teamLabel                       : Dynamic= null;
            
            for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(match),teams) type: null */ in as3hx.Compat.iter(match.teams))
            {
                teamLabel = getTeamLabel(team);
                teamLabel.y = my;
                
                my += labelHeight;
                
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(team),users) type: null */ in as3hx.Compat.iter(team.users))
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
                for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EArray(EField(EIdent(match),teams),EConst(CInt(0))),users) type: null */ in as3hx.Compat.iter(match.teams[0].users))
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
    
    private function e_onPaneClick(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(handler == null))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(Std.is(e.target, GameResultFFRScoreListUserLabel)))
        {
            handler((try cast(e.target, GameResultFFRScoreListUserLabel) catch(e:Dynamic) null).user.index);
        }
    }
    
    private function e_scrollMouseWheel(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        var dist                       : Dynamic= scrollbar.scroll + (pane.scrollFactorVertical / 2) * ((e.delta > 0) ? -1 : 1);
        pane.scrollTo(dist);
        scrollbar.scrollTo(dist);
    }
    
    private function e_scrollbarUpdater(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!scrollbar.visible))
        {
            return;
        }
        
        pane.scrollTo(e.target.scroll);
    }
    
    override private function set_width(value                       : Dynamic) : Float
    {
        _width = value;
        redraw();
        return value;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    override private function set_height(value                       : Dynamic) : Float
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
    private function getUserLabel(user                       : Dynamic) : GameResultFFRScoreListUserLabel
    {
        var newLabel                       : Dynamic= new GameResultFFRScoreListUserLabel(user);
        pane.content.addChild(newLabel);
        
        return newLabel;
    }
    
    private function getTeamLabel(team                       : Dynamic) : TeamLabel
    {
        var newLabel                       : Dynamic= new TeamLabel(team);
        pane.content.addChild(newLabel);
        
        return newLabel;
    }
}



class BaseLabel extends Sprite
{
    private static var BG_WINNER                       : Dynamic= [0xD6BA00, 0xD6BA00];
    private static var BG_NORMAL                       : Dynamic= [0xFFFFFF, 0xFFFFFF];
    private static var BG_ALPHA                       : Dynamic= [0.10, 0.025];
    private static var BG_RATIO                       : Dynamic= [0, 255];
    private static var BG_MATRIX                       : Dynamic= new Matrix();
    
    
    public var _width                       : Dynamic= 719;
    public var _height                       : Dynamic= 35;
    
    private var hover                       : Dynamic;
    public var textRank                       : Dynamic;
    public var textName                       : Dynamic;
    public var textScore                       : Dynamic;
    
    @:allow(game.results)
    private function new()
    {
        super();
        this.mouseChildren = false;
        
        this.addEventListener(MouseEvent.ROLL_OVER, e_showHover);
        this.addEventListener(MouseEvent.ROLL_OUT, e_hideHover);
        
        build();
    }
    
    public function build() : Void
    {
        hover = new Sprite();
        hover.visible = false;
        hover.graphics.lineStyle(0, 0, 0);
        hover.graphics.beginFill(0xFFFFFF, 0.05);
        hover.graphics.drawRect(0, 0, _width, _height);
        hover.graphics.endFill();
        addChild(hover);
    }
    
    public function draw(isWinner                       : Dynamic) : Void
    {
        this.graphics.lineStyle(1, 0xFFFFFF, 0.15);
        this.graphics.moveTo(0, _height - 1);
        this.graphics.lineTo(_width - 1, _height - 1);
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginGradientFill(GradientType.LINEAR, (isWinner) ? BG_WINNER : BG_NORMAL, BG_ALPHA, BG_RATIO, BG_MATRIX);
        this.graphics.drawRect(0, 0, _width - 1, _height - 1);
        this.graphics.endFill();
    }
    
    private function e_showHover(e                       : Dynamic) : Void
    {
        hover.visible = true;
    }
    
    private function e_hideHover(e                       : Dynamic) : Void
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
    private var team                       : Dynamic;
    
    @:allow(game.results)
    private function new(team                       : Dynamic)
    {
        this.team = team;
        
        super();
    }
    
    override public function build() : Void
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
    public var user                       : Dynamic;
    
    private var avatar                       : Dynamic;
    
    private var textRate                       : Dynamic;
    
    private var textAmazing                       : Dynamic;
    private var textPerfect                       : Dynamic;
    private var textGood                       : Dynamic;
    private var textAverage                       : Dynamic;
    private var textMiss                       : Dynamic;
    private var textBoo                       : Dynamic;
    private var textMaxCombo                       : Dynamic;
    
    @:allow(game.results)
    private function new(user                       : Dynamic)
    {
        this.user = user;
        this.buttonMode = true;
        
        super();
    }
    
    override public function build() : Void
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
        
        if (as3hx.Compat.truthy(!user.alive))
        {
            textRank.alpha = avatar.alpha = textName.alpha = textScore.alpha = textPerfect.alpha = textGood.alpha = textAverage.alpha = textMiss.alpha = textBoo.alpha = textMaxCombo.alpha = 0.4;
        }
        
        super.build();
    }
}
