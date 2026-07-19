package classes.mp.components.chatlog;

import classes.Language;
import classes.mp.Multiplayer;
import classes.mp.mode.ffr.MPMatchResultsFFR;
import classes.mp.room.MPRoomFFR;
import classes.ui.BoxButton;
import classes.ui.Text;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.events.Event;

class MPChatLogEntryMatchResults extends MPChatLogEntry
{
    private static var _lang                             : Dynamic= Language.instance;
    private static var _mp                             : Dynamic= Multiplayer.instance;
    
    private var room                             : Dynamic;
    private var results                             : Dynamic;
    private var index                             : Dynamic;
    
    private var btn                             : Dynamic;
    
    public function new(room                             : Dynamic, results                             : Dynamic)
    {
        super();
        this.room = room;
        this.results = results;
    }
    
    override public function build(width                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(built))
        {
            return;
        }
        
        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.beginFill(0xFFFFFF, 0.1);
        this.graphics.drawRect(5, 5, width - 11, 45);
        this.graphics.endFill();
        
        new Text(this, 10, 7, _lang.string("mp_room_ffr_match_end"), 10, "#c3c3c3").setAreaParams(width - 120, 22);
        
        if (as3hx.Compat.truthy(results.wasTie))
        {
            new Text(this, 9, 25, sprintf(results.winnerText), 12).setAreaParams(width - 110, 22);
        }
        else
        {
            new Text(this, 9, 25, sprintf(_lang.string("mp_room_ffr_match_end_results"), {
                                winner : results.winnerText
                            }), 12).setAreaParams(width - 110, 22);
        }
        
        btn = new BoxButton(this, width - 96, 14, 85, 26, _lang.string("mp_room_ffr_match_end_view"), 11, e_viewResults);
        
        _height = 52;
        built = true;
    }
    
    private function e_viewResults(e                             : Dynamic) : Void
    {
        room.lastMatchIndex = results.index;
        
        Reflect.setField(Flags.VALUES, Flags.MP_MENU_RESULTS, true);
        GlobalVariables.instance.gameMain.switchTo(Main.GAME_PLAY_PANEL);
    }
}

