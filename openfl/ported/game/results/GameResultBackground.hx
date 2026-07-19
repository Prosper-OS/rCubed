package game.results;

import assets.GameBackgroundStripes;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.geom.Matrix;

class GameResultBackground extends Sprite
{
    public static var BG_LIGHT : Int = 0x1495BD;
    public static var BG_DARK : Int = 0x033242;
    
    public function new()
    {
        super();
        // Create Background
        var _matrix : Matrix = new Matrix();
        _matrix.createGradientBox(Main.GAME_WIDTH, Main.GAME_HEIGHT, 5.75);
        this.graphics.clear();
        this.graphics.beginGradientFill(GradientType.LINEAR, [BG_LIGHT, BG_DARK], [1, 1], [0x00, 0xFF], _matrix);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        this.cacheAsBitmap = true;
        this.cacheAsBitmapMatrix = _matrix;
        
        var bt : BitmapData = new GameBackgroundStripes();
        this.graphics.beginBitmapFill(bt, null, false);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
    }
}

