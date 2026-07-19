package popups.replays;

import assets.menu.icons.fa.IconCopy;
import classes.SongInfo;
import classes.replay.Replay;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.geom.Matrix;

class ReplayHistoryEntry extends Sprite
{
    public static inline var ENTRY_HEIGHT : Int = 50;
    
    private static var SCORE_BG_MATRIX : Matrix = new Matrix();
    
    
    private static var SCORE_BG : Array<Dynamic> = [[0xbfecff, 75],   // Score  
        [0x12ff00, 45],   // Perfect  
        [0x00ad0f, 45],   // Good  
        [0xff9a00, 45],   // Average  
        [0xff0000, 45],   // Miss  
        [0x874300, 45],   // Boo  
        [0x858585, 55]  // Combo  
    ];
    
    public var replay : Replay;
    public var info : SongInfo;
    
    private var title : Text;
    private var rate : Text;
    private var engine : Text;
    
    private var field_plane : Sprite;
    private var fields : Array<Text>;
    
    public var btn_play : SimpleBoxButton;
    public var btn_copy : SimpleBoxButton;
    
    public var index : Int = 0;
    public var isStale : Bool = true;
    
    public function new()
    {
        super();
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(0, 0, 578, ENTRY_HEIGHT);
        this.graphics.endFill();
        
        this.graphics.moveTo(548, 1);
        this.graphics.lineTo(548, ENTRY_HEIGHT);
        
        this.graphics.lineStyle(0, 0xFFFFFF, 0);
        
        var copyIcon : IconCopy = new IconCopy();
        copyIcon.scaleX = copyIcon.scaleY = (17 / copyIcon.width);
        copyIcon.x = 564;
        copyIcon.y = (ENTRY_HEIGHT / 2) + 1;
        this.addChild(copyIcon);
        
        // Score Fields BG
        field_plane = new Sprite();
        field_plane.x = 1;
        field_plane.y = ENTRY_HEIGHT - 20;
        this.addChild(field_plane);
        
        var field_txt : Text;
        fields = new Array<Text>();
        
        var X_OFF : Float = 0;
        for (index in 0...SCORE_BG.length)
        {
            var score_field : Array<Dynamic> = SCORE_BG[index];
            
            field_plane.graphics.beginGradientFill(GradientType.LINEAR, [score_field[0], score_field[0], score_field[0]], [0.15, 0.22, 0.32], [0x00, 0x77, 0xFF], SCORE_BG_MATRIX);
            field_plane.graphics.drawRect(X_OFF, 0, score_field[1], 20);
            field_plane.graphics.endFill();
            
            field_txt = new Text(field_plane, X_OFF + 2, 0, "");
            field_txt.setAreaParams(score_field[1] - 4, 20, "center");
            fields[index] = field_txt;
            X_OFF += score_field[1];
        }
        
        // Text
        title = new Text(this, 6, 6, "???", 14);
        title.setAreaParams(536, 20);
        
        rate = new Text(this, X_OFF + 5, 6, "", 14);
        rate.setAreaParams(181, 20, "right");
        rate.alpha = 0.4;
        
        engine = new Text(this, X_OFF + 5, ENTRY_HEIGHT - 20, "");
        engine.setAreaParams(181, 20, "right");
        engine.alpha = 0.4;
        
        // Buttons
        btn_play = new SimpleBoxButton(548, ENTRY_HEIGHT);
        this.addChild(btn_play);
        
        btn_copy = new SimpleBoxButton(30, ENTRY_HEIGHT);
        btn_copy.x = 548;
        this.addChild(btn_copy);
    }
    
    public function setData(item : Replay) : Void
    {
        replay = item;
        info = item.song;
        
        title.text = info.name;
        
        if (info.engine != null)
        {
            if (info.engine.name == null)
            {
                engine.text = Std.string(info.engine.id).toUpperCase();
            }
            else
            {
                engine.text = Std.string(info.engine.name);
            }
            
            engine.visible = true;
        }
        else
        {
            engine.visible = false;
        }
        
        if (item.settings.songRate != 1)
        {
            rate.text = "x" + item.settings.songRate;
            rate.visible = true;
        }
        else
        {
            rate.visible = false;
        }
        
        fields[0].text = Std.string(item.score);
        fields[1].text = Std.string(item.perfect);
        fields[2].text = Std.string(item.good);
        fields[3].text = Std.string(item.average);
        fields[4].text = Std.string(item.miss);
        fields[5].text = Std.string(item.boo);
        fields[6].text = Std.string(item.maxcombo);
        
        fields[2].alpha = (item.good > 0) ? 1 : 0.3;
        fields[3].alpha = (item.average > 0) ? 1 : 0.3;
        fields[4].alpha = (item.miss > 0) ? 1 : 0.3;
        fields[5].alpha = (item.boo > 0) ? 1 : 0.3;
    }
    
    public function clear() : Void
    {
        replay = null;
    }
    private static var ReplayHistoryEntry_static_initializer = {
        {
            SCORE_BG_MATRIX.createGradientBox(20, 20, 1.5708);
        };
        true;
    }

}

