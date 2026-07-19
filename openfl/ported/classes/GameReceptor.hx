package classes;

import com.greensock.TweenLite;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Matrix;

class GameReceptor extends MovieClip
{
    private static var DRAW_MATRIX : Matrix = new Matrix();
    private var _note : Sprite;
    public var DIR : String;
    
    public var animationSpeed : Float = 1;
    
    public function new(dir : String, bitmap : BitmapData)
    {
        super();
        this.DIR = dir;
        
        var logicalWidth : Float = bitmap.width / RenderQuality.SUPERSAMPLE_SCALE;
        var logicalHeight : Float = bitmap.height / RenderQuality.SUPERSAMPLE_SCALE;
        DRAW_MATRIX = RenderQuality.bitmapFillMatrix(-(logicalWidth / 2), -(logicalHeight / 2));
        
        _note = new Sprite();
        _note.graphics.beginBitmapFill(bitmap, DRAW_MATRIX, false, true);
        _note.graphics.drawRect(-(logicalWidth / 2), -(logicalHeight / 2), logicalWidth, logicalHeight);
        _note.graphics.endFill();
        RenderQuality.cacheDisplayObject(_note);
        this.addChild(_note);
    }
    
    public function playAnimation(color : Int) : Void
    {
        _note.scaleX = _note.scaleY = 1;
        TweenLite.to(_note, 0.1 / animationSpeed, {
                    scaleX : 1.25,
                    scaleY : 1.25,
                    tint : color,
                    useFrames : false,
                    onComplete : playAnimationShrink
                });
    }
    
    private function playAnimationShrink() : Void
    {
        TweenLite.to(_note, 0.066 / animationSpeed, {
                    scaleX : 1,
                    scaleY : 1,
                    tint : null,
                    useFrames : false
                });
    }
    
    public function dispose() : Void
    {
        if (_note != null && this.contains(_note))
        {
            this.removeChild(_note);
        }
        
        _note = null;
    }
}


