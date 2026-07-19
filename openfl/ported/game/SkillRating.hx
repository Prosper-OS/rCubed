package game;

import classes.SongInfo;

class SkillRating
{
    
    public static inline var ALPHA                       : Dynamic= 9.9750396740034;
    public static inline var BETA                       : Dynamic= 0.0193296437339205;
    public static inline var LAMBDA                       : Dynamic= 18206628.7286425;
    
    public static inline var D1                       : Dynamic= 17678803623.9633;
    public static inline var D2                       : Dynamic= 733763392.922176;
    public static inline var D3                       : Dynamic= 28163834.4879901;
    public static var D4                       : Dynamic= -434698.513947563;
    public static inline var D5                       : Dynamic= 3060.24243867853;
    
    public static function getSongWeight(result                       : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(result == null || result.songInfo == null))
        {
            return 0;
        }
        var rawgoods                       : Dynamic= result.raw_goods;
        var songweight                       : Dynamic= 0;
        var difficulty                       : Dynamic= result.songInfo.difficulty;
        var delta                       : Dynamic= D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        if (as3hx.Compat.truthy(delta - rawgoods * LAMBDA > 0))
        {
            songweight = Math.pow((delta - rawgoods * LAMBDA) / delta * Math.pow(difficulty + ALPHA, BETA), 1 / BETA) - ALPHA;
        }
        if (as3hx.Compat.truthy(songweight < 0 || result.score <= 0 || result.options.songRate != 1 || result.songInfo.engine != null))
        {
            songweight = 0;
        }
        return songweight;
    }
    
    public static function calcSongWeightFromScore(rawScore                       : Dynamic, song                       : Dynamic) : Float
    {
        var rawGoods                       : Dynamic= calcRawGoods(rawScore, song);
        
        return calcSongWeightFromRawGoods(rawGoods, song);
    }
    
    public static function calcSongWeightFromRawGoods(rawGoods                       : Dynamic, song                       : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(song == null))
        {
            return 0;
        }
        var songweight                       : Dynamic= 0;
        var difficulty                       : Dynamic= song.difficulty;
        var delta                       : Dynamic= D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        if (as3hx.Compat.truthy(delta - rawGoods * LAMBDA > 0))
        {
            songweight = Math.pow((delta - rawGoods * LAMBDA) / delta * Math.pow(difficulty + ALPHA, BETA), 1 / BETA) - ALPHA;
        }
        if (as3hx.Compat.truthy(songweight < 0))
        {
            songweight = 0;
        }
        return songweight;
    }
    
    public static function getRawGoodsFromEquiv(song                       : Dynamic, targetEquiv                       : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(song == null || targetEquiv == 0))
        {
            return 0;
        }
        
        var rawgoods                       : Dynamic= 0;
        var songweight                       : Dynamic= targetEquiv;
        var difficulty                       : Dynamic= song.difficulty;
        var delta                       : Dynamic= D1 + D2 * difficulty + D3 * Math.pow(difficulty, 2) + D4 * Math.pow(difficulty, 3) + D5 * Math.pow(difficulty, 4);
        
        rawgoods = (delta - delta * Math.pow(songweight + ALPHA, BETA) / Math.pow(difficulty + ALPHA, BETA)) / LAMBDA;
        
        return Math.round(rawgoods * 5) / 5;
    }
    
    public static function getRawGoods(result                       : Dynamic) : Float
    {
        return (result.good) + (result.average * 1.8) + (result.miss * 2.4) + (result.boo * 0.2);
    }
    
    public static function calcRawGoods(rawScore                       : Dynamic, song                       : Dynamic) : Float
    {
        return Math.round(((song.score_raw - rawScore) / 25) * 5) / 5;
    }

    public function new()
    {
    }
}

