package game;

import by.blooddy.crypto.Base64;
import classes.SongInfo;
import classes.User;
import classes.chart.Song;
import classes.replay.ReplayBinFrame;
import classes.replay.ReplayPack;
import openfl.utils.ByteArray;

class GameScoreResult
{
    public var is_aaa(get, never) : Bool;
    public var is_fc(get, never) : Bool;
    public var raw_goods(get, never) : Float;
    public var accuracy_frames(get, never) : Float;
    public var accuracy_deviation_frames(get, never) : Float;
    public var replayBin(get, never) : ByteArray;
    public var replay_bin_encoded(get, never) : String;
    public var score_total(get, set) : Float;
    public var pa_string(get, never) : String;
    public var screenshot_path(get, never) : String;
    public var replay_cache_object(get, never) : Dynamic;

    public var game_index : Int;
    public var level : Int;
    public var song : Song;
    public var songInfo : SongInfo;
    public var note_count : Int;
    
    public var is_preview : Bool = false;
    
    public var legacyLastRank : Dynamic;
    
    public var user : User;
    public var options : GameOptions;
    
    public var amazing : Int = 0;
    public var perfect : Int = 0;
    public var good : Int = 0;
    public var average : Int = 0;
    public var boo : Int = 0;
    public var miss : Int = 0;
    public var combo : Int = 0;
    public var max_combo : Int = 0;
    public var score : Int = 0;
    
    private var _score_total : Float = Math.NaN;
    
    private function get_is_aaa() : Bool
    {
        return (((amazing + perfect) == note_count) && max_combo == note_count && good == 0 && average == 0 && boo == 0 && miss == 0);
    }
    
    private function get_is_fc() : Bool
    {
        return (max_combo == note_count && miss == 0);
    }
    
    private function get_raw_goods() : Float
    {
        return good + (average * 1.8) + (miss * 2.4) + (boo * 0.2);
    }
    
    public var credits : Int = 0;
    
    public var restarts : Int;
    public var restart_stats : Dynamic;
    public var last_note : Int;
    
    // Accuracy
    public var accuracy : Float;
    public var accuracy_deviation : Float;
    
    private function get_accuracy_frames() : Float
    {
        return 30 * accuracy / 1000;
    }
    
    private function get_accuracy_deviation_frames() : Float
    {
        return 30 * accuracy_deviation / 1000;
    }
    
    // Replay v3
    public var replayData : Array<Dynamic>;  // Probably array of ReplayNote  
    public var replay_hit : Array<Dynamic>;
    
    // Binary Replays (aka Replay v4)
    public var replay_bin_notes : Array<ReplayBinFrame>;
    public var replay_bin_boos : Array<ReplayBinFrame>;
    private var _replay_bin : ByteArray;
    
    private function get_replayBin() : ByteArray
    {
        if (_replay_bin == null)
        {
            var judgementsEncode : String = haxe.Json.stringify({
                        amazing : amazing,
                        perfect : perfect,
                        good : good,
                        average : average,
                        boo : boo,
                        miss : miss,
                        maxcombo : max_combo
                    });
            _replay_bin = ReplayPack.writeReplay(user, options, judgementsEncode, replay_bin_notes, replay_bin_boos);
        }
        
        return _replay_bin;
    }
    
    private function get_replay_bin_encoded() : String
    {
        if (replayBin == null || replayBin.length == 0)
        {
            return null;
        }
        
        return ReplayPack.MAGIC + "|" + Base64.encode(replayBin);
    }
    
    public var start_time : String;
    public var start_hash : String;
    public var end_time : String;
    
    /** Ratio of Song Completion: 0 -> 1 */
    public var song_progress : Float;
    
    // Judge Settings
    public var MIN_TIME : Int = 0;
    public var MAX_TIME : Int = 0;
    public var GAP_TIME : Int = 0;
    public var judge : Array<Dynamic>;
    
    /**
     * Updates variables that need to be calculated after others are set.
     * @param _gvars GlobalVariables reference.
     */
    public function update(_gvars : GlobalVariables) : Void
    {
        this.credits = Math.max(0, Math.min(Math.floor(score_total / _gvars.SCORE_PER_CREDIT), _gvars.MAX_CREDITS));
        updateJudge();
    }
    
    /**
     * Updates Judge Region Min Time, Max Time, and Total Size
     * either from the default judge, or a custom set judge.
     */
    public function updateJudge() : Void
    // Get Judge Window
    {
        
        judge = Constant.JUDGE_WINDOW;
        if (options.judgeWindow)
        {
            judge = options.judgeWindow;
        }
        
        // Get Judge Window Size
        for (jn in 0...judge.length)
        {
            var jni : Dynamic = judge[jn];
            if (jni.t < MIN_TIME)
            {
                MIN_TIME = jni.t;
            }
            
            if (jni.t > MAX_TIME)
            {
                MAX_TIME = jni.t;
            }
        }
        
        GAP_TIME = as3hx.Compat.parseInt(MAX_TIME - MIN_TIME);
    }
    
    /**
     * Gets the judge region for the given ms difference.
     * @param time Judge Time
     * @return Judge Region
     */
    public function getJudgeRegion(time : Int) : Dynamic
    {
        var lastJudge : Dynamic;
        
        for (j in judge)
        {
            if (time > j.t)
            {
                lastJudge = j;
            }
        }
        
        return lastJudge;
    }
    
    /**
     * Gets the total score for the result.
     * @return
     */
    private function get_score_total() : Float
    {
        if (!Math.isNaN(_score_total))
        {
            return _score_total;
        }
        
        return Math.max(0, ((amazing + perfect) * 500) + (good * 250) + (average * 50) + (max_combo * 1000) - (miss * 300) - (boo * 15) + score);
    }
    
    private function set_score_total(val : Float) : Float
    {
        _score_total = val;
        return val;
    }
    
    /**
     * Gets the PA string displayed in several places.
     * Example: 1653-1-0-0-0
     * @return
     */
    private function get_pa_string() : String
    {
        return (amazing + perfect) + "-" + good + "-" + average + "-" + miss + "-" + boo;
    }
    
    /**
     * Gets a friendly screenshot path based on the song name, score, and pa string.
     * @return
     */
    private function get_screenshot_path() : String
    {
        var rateString : String = (options.songRate != 1) ? " (" + options.songRate + "x Rate)" : "";
        
        return "R^3 - " + songInfo.name + rateString + " - " + score + " - " + pa_string;
    }
    
    /**
     * Get a simple object used for replay caching with only the needed display info.
     * @return
     */
    private function get_replay_cache_object() : Dynamic
    {
        var out : Dynamic = {
            name : songInfo.name,
            rate : options.songRate,
            score : score,
            judge : [(amazing + perfect), good, average, miss, boo, max_combo]
        };
        
        if (songInfo.engine != null)
        {
            Reflect.setField(out, "engine", songInfo.engine.id);
        }
        
        return out;
    }
    
    public function compare(i : GameScoreResult) : Bool
    {
        return this.user.siteId == i.user.siteId && this.amazing == i.amazing && this.perfect == i.perfect && this.good == i.good && this.average == i.average && this.miss == i.miss && this.boo == i.boo;
    }

    public function new()
    {
    }
}

