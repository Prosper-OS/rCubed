package game.results;

import assets.results.MPResultsBackground;
import classes.Language;
import classes.SongInfo;
import classes.mp.mode.ffr.MPMatchResultsFFR;
import classes.mp.room.MPRoomFFR;
import classes.score.ScoreHandler;
import classes.ui.Text;
import com.flashfla.utils.TimeUtil;
import com.flashfla.utils.Sprintf.sprintf;
import openfl.display.Sprite;

class GameResultFFRView extends Sprite
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _lang                       : Dynamic= Language.instance;
    private var _score                       : Dynamic= ScoreHandler.instance;
    
    private var resultsDisplay                       : Dynamic;
    
    private var room                       : Dynamic;
    private var matchDetails                       : Dynamic;
    private var scoreSelect                       : Dynamic;
    
    // Title Bar
    private var resultsTime                       : Dynamic= TimeUtil.getCurrentDate();
    private var header                       : Dynamic;
    private var time                       : Dynamic;
    
    // Game Result
    private var songName                       : Dynamic;
    private var songDecription                       : Dynamic;
    private var gameMode                       : Dynamic;
    private var textScore                       : Dynamic;
    private var textAmazing                       : Dynamic;
    private var textPerfect                       : Dynamic;
    private var textGood                       : Dynamic;
    private var textAverage                       : Dynamic;
    private var textMiss                       : Dynamic;
    private var textBoo                       : Dynamic;
    private var textMaxCombo                       : Dynamic;
    
    private var list                       : Dynamic;
    
    public function new(room                       : Dynamic, matchDetails                       : Dynamic, scoreSelect                       : Dynamic)
    {
        super();
        this.room = room;
        this.matchDetails = matchDetails;
        this.scoreSelect = scoreSelect;
        
        resultsDisplay = new MPResultsBackground();
        addChild(resultsDisplay);
        
        // Text
        if (as3hx.Compat.truthy(matchDetails.wasTie))
        {
            header = new Text(this, 20, 10, matchDetails.winnerText, 16, "#E2FEFF");
        }
        else
        {
            header = new Text(this, 20, 10, sprintf(_lang.string("mp_room_ffr_match_end_results"), {
                                winner : matchDetails.winnerText
                            }), 16, "#E2FEFF");
        }
        header.setAreaParams(420, 26);
        
        time = new Text(this, 576, 10, resultsTime, 16, "#E2FEFF");
        time.setAreaParams(196, 26, "center");
        
        var songInfo                       : Dynamic= matchDetails.songInfo;
        
        // Song Title
        var seconds                       : Dynamic= songInfo.time_secs;
        var songLength                       : Dynamic= (Math.floor(seconds / 60)) + ":" + ((seconds % 60 >= 10) ? "" : "0") + (seconds % 60);
        
        var songTitle                       : Dynamic= (songInfo.engine) ? songInfo.name : "<a href=\"" + URLs.resolve(URLs.LEVEL_STATS_URL) + songInfo.level + "\">" + songInfo.name + "</a>";
        var songSubTitle                       : Dynamic= sprintf(_lang.string("game_results_subtitle_difficulty"), {
                    value : songInfo.difficulty
                }) + " - " + sprintf(_lang.string("game_results_subtitle_length"), {
                    value : songLength
                });
        if (as3hx.Compat.truthy(songInfo.author != ""))
        {
            songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_author"), {
                                value : songInfo.author_html
                            }));
        }
        if (as3hx.Compat.truthy(songInfo.stepauthor != ""))
        {
            songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_stepauthor"), {
                                value : songInfo.stepauthor_html
                            }));
        }
        
        songName = new Text(this, 115, 56, songTitle, 16, "#E2FEFF");
        songName.setAreaParams(545, 30, "center");
        songName.mouseEnabled = true;
        songName.buttonMode = true;
        
        songDecription = new Text(this, 115, 83, songSubTitle, 12, "#E2FEFF");
        songDecription.textfield.styleSheet = Constant.STYLESHEET;
        songDecription.setAreaParams(545, 20, "center");
        songDecription.mouseChildren = true;
        songDecription.mouseEnabled = true;
        
        var isTeamMode                       : Dynamic= matchDetails.teams.length > 1;
        
        // Table
        gameMode = new Text(this, 30, 150, _lang.string((isTeamMode) ? "mp_room_ffr_table_mode_team" : "mp_room_ffr_table_mode_ffa"), 12, "#E2FEFF");
        gameMode.setAreaParams(230, 22);
        
        textScore = new Text(this, 260, 150, _lang.string("mp_room_ffr_table_score"), 12, "#E2FEFF");
        textScore.setAreaParams(100, 22, "center");
        
        textPerfect = new Text(this, 360, 150, _lang.string("mp_room_ffr_table_perfect"), 12, "#DCFFCB");
        textPerfect.setAreaParams(64, 22, "center");
        
        textGood = new Text(this, 424, 150, _lang.string("mp_room_ffr_table_good"), 12, "#C1FFBD");
        textGood.setAreaParams(64, 22, "center");
        
        textAverage = new Text(this, 488, 150, _lang.string("mp_room_ffr_table_average"), 12, "#BCE9C1");
        textAverage.setAreaParams(64, 22, "center");
        
        textMiss = new Text(this, 552, 150, _lang.string("mp_room_ffr_table_miss"), 12, "#FFE0E0");
        textMiss.setAreaParams(64, 22, "center");
        
        textBoo = new Text(this, 616, 150, _lang.string("mp_room_ffr_table_boo"), 12, "#E7D0B8");
        textBoo.setAreaParams(64, 22, "center");
        
        textMaxCombo = new Text(this, 680, 150, _lang.string("mp_room_ffr_table_combo"), 12, "#E2FEFF");
        textMaxCombo.setAreaParams(64, 22, "center");
        
        list = new GameResultFFRScoreList(this, 30, 180);
        list.setHandler(scoreSelect);
        list.setRoom(matchDetails);
    }
}

