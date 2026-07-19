package game.controls;

import classes.mp.MPUser;
import classes.mp.mode.ffr.MPMatchFFR;
import classes.mp.mode.ffr.MPMatchFFRTeam;
import classes.mp.mode.ffr.MPMatchFFRUser;
import classes.mp.room.MPRoomFFR;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import game.GameOptions;

import classes.mp.Multiplayer;

import classes.mp.room.MPRoom;

import classes.ui.Text;


class MPFFRScoreCompare extends GameControl
{
    public var type(never, set)                       : Dynamic;

    private var options                       : Dynamic;
    private var lastType                       : Dynamic= 0;
    
    private var room                       : Dynamic;
    private var labels                       : Dynamic= [];
    private var labelCount                       : Dynamic= 0;
    private var labelHeight                       : Dynamic= 40;
    private var startY                       : Dynamic= 0;
    
    private var match                       : Dynamic;
    private var useTeamView                       : Dynamic;
    private var isSpectator                       : Dynamic;
    
    public function new(options                       : Dynamic, parent                       : Dynamic, room                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.options = options;
        this.match = room.activeMatch;
        
        useTeamView = match.teams.length > 1;
        isSpectator = options.isSpectator;
        
        lastType = 0;
        addLabels();
    }
    
    public function clearLabels() : Void
    {
        this.removeChildren();
        this.labels.length = 0;
    }
    
    public function addLabels() : Void
    {
        for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(match),teams) type: null */ in as3hx.Compat.iter(match.teams))
        {
            for (user/* AS3HX WARNING could not determine type for var: user exp: EField(EIdent(team),users) type: null */ in as3hx.Compat.iter(team.users))
            {
                var text                       : Dynamic= new PlayerLabel(room, user);
                addChild(text);
                labels.push(text);
            }
        }
        
        labelCount = labels.length;
        labelHeight = (labelCount > 0) ? labels[0].height : 0;
        
        startY = (Main.GAME_HEIGHT / 2) - ((labelCount / 2) * labelHeight);
        
        update();
    }
    
    public function update() : Void
    {
        as3hx.Compat.sortOn(labels, ["position", "score", "username"], [as3hx.Compat.ARRAY_NUMERIC, as3hx.Compat.ARRAY_NUMERIC | as3hx.Compat.ARRAY_DESCENDING, as3hx.Compat.ARRAY_CASEINSENSITIVE]);
        for (i in 0...labelCount)
        {
            labels[i].update();
            labels[i].y = startY + (i * labelHeight);
        }
    }
    
    private function set_type(val                       : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(lastType != val))
        {
            lastType = as3hx.Compat.parseInt(val);
            clearLabels();
            addLabels();
        }
        return val;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_MP_FFR_SCORE;
    }
}



class PlayerLabel extends Sprite
{
    public var position(get, never)                       : Dynamic;
    public var score(get, never)                       : Dynamic;
    public var username(get, never)                       : Dynamic;

    private static var _mp                       : Dynamic= Multiplayer.instance;
    
    private static inline var USER_PLAYING                       : Dynamic= "#FFFFFF";
    private static inline var USER_FINISHED                       : Dynamic= "#F25C5C";
    
    public var room                       : Dynamic;
    public var user                       : Dynamic;
    public var data                       : Dynamic;
    
    public var isSelf                       : Dynamic= false;
    public var isAlive                       : Dynamic= true;
    public var isPlaying                       : Dynamic= true;
    
    public var txtPosition                       : Dynamic;
    public var txtUsername                       : Dynamic;
    public var txtScore                       : Dynamic;
    
    private var _lastPosition                       : Dynamic= -1;
    private var _lastScore                       : Dynamic= -1;
    
    @:allow(game.controls)
    private function new(room                       : Dynamic, data                       : Dynamic)
    {
        super();
        this.room = room;
        this.data = data;
        this.user = data.user;
        
        isSelf = _mp.currentUser == this.user;
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0x000000, 0.75);
        this.graphics.drawRect(0, 0, 152, 41);
        this.graphics.endFill();
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill((isSelf) ? 0x91ff89 : 0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, 151, 40);
        this.graphics.endFill();
        
        txtPosition = new Text(this, 117, 5, "", 20, "#0098CB");
        txtPosition.setAreaParams(30, 30, "right");
        
        txtUsername = new Text(this, 5, 2, user.name);
        txtUsername.width = 107;
        
        txtScore = new Text(this, 4, 18, "", 10, "#EAEAEA");
    }
    
    public function update() : Void
    {
        if (as3hx.Compat.truthy(_lastPosition != data.position))
        {
            txtPosition.text = Std.string(data.position);
            _lastPosition = data.position;
        }
        
        if (as3hx.Compat.truthy(_lastScore != data.raw_score))
        {
            txtScore.text = data.raw_score + " / " + data.good + "-" + data.average + "-" + data.miss + "-" + data.boo;
            _lastScore = data.raw_score;
        }
        
        if (as3hx.Compat.truthy(data.alive != isAlive))
        {
            this.alpha = (data.alive) ? 1 : 0.5;
            isAlive = data.alive;
        }
        else if (as3hx.Compat.truthy(data.playing != isPlaying))
        {
            txtUsername.fontColor = (data.playing) ? USER_PLAYING : USER_FINISHED;
            isPlaying = data.playing;
        }
    }
    
    override private function get_height() : Float
    {
        return 42;
    }
    
    private function get_position() : Float
    {
        return data.position;
    }
    
    private function get_score() : Float
    {
        return data.raw_score;
    }
    
    private function get_username() : String
    {
        return user.name;
    }
}
