package game;

import classes.SongInfo;

class SkillRating
{
    
    public static inline var ALPHA : Float = 9.9750396740034;
    public static inline var BETA : Float = 0.0193296437339205;
    public static inline var LAMBDA : Float = 18206628.7286425;
    
    public static inline var D1 : Float = 17678803623.9633;
    public static inline var D2 : Float = 733763392.922176;
    public static inline var D3 : Float = 28163834.4879901;
    public static var D4 : Float = -434698.513947563;
    public static inline var D5 : Float = 3060.24243867853;
    
    public static function getSongWeight(result : GameScoreResult) : Float
    {
        if (result == null || result.songInfo == null)
        {
            return 0;
        }
        var rawgoods : Float = result.raw_goods;
        var songweight : Float = 0;
        var difficulty : Float = result.songInfo.difficulty;
        var delta : Float = D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        if (delta - rawgoods * LAMBDA > 0)
        {
            songweight = Math.pow((delta - rawgoods * LAMBDA) / delta * Math.pow(difficulty + ALPHA, BETA), 1 / BETA) - ALPHA;
        }
        if (songweight < 0 || result.score <= 0 || result.options.songRate != 1 || result.songInfo.engine != null)
        {
            songweight = 0;
        }
        return songweight;
    }
    
    public static function calcSongWeightFromScore(rawScore : Float, song : SongInfo) : Float
    {
        var rawGoods : Float = calcRawGoods(rawScore, song);
        
        return calcSongWeightFromRawGoods(rawGoods, song);
    }
    
    public static function calcSongWeightFromRawGoods(rawGoods : Float, song : SongInfo) : Float
    {
        if (song == null)
        {
            return 0;
        }
        var songweight : Float = 0;
        var difficulty : Float = song.difficulty;
        var delta : Float = D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        if (delta - rawGoods * LAMBDA > 0)
        {
            songweight = Math.pow((delta - rawGoods * LAMBDA) / delta * Math.pow(difficulty + ALPHA, BETA), 1 / BETA) - ALPHA;
        }
        if (songweight < 0)
        {
            songweight = 0;
        }
        return songweight;
    }
    
    public static function getRawGoodsFromEquiv(song : SongInfo, targetEquiv : Float) : Float
    {
        if (song == null || targetEquiv == 0)
        {
            return 0;
        }
        
        var rawgoods : Float = 0;
        var songweight : Float = targetEquiv;
        var difficulty : Float = song.difficulty;
        var delta : Float = D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        
        rawgoods = (delta - delta * Math.pow(songweight + ALPHA, BETA) / Math.pow(difficulty + ALPHA, BETA)) / LAMBDA;
        
        return Math.round(rawgoods * 5) / 5;
    }
    
    public static function getRawGoods(result : Dynamic) : Float
    {
        return (result.good) + (result.average * 1.8) + (result.miss * 2.4) + (result.boo * 0.2);
    }
    
    public static function calcRawGoods(rawScore : Float, song : SongInfo) : Float
    {
        return Math.round(((song.score_raw - rawScore) / 25) * 5) / 5;
    }

    public function new()
    {
    }
}

