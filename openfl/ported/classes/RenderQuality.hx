package classes;

import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.display.StageQuality;
import openfl.geom.Matrix;

class RenderQuality
{
    public static inline var SUPERSAMPLE_SCALE : Int = 4;
    
    public static function configureStage(stage : Stage) : Void
    {
        if (stage != null)
        {
            stage.quality = StageQuality.BEST;
        }
    }
    
    public static function cacheDisplayObject(target : DisplayObject) : Void
    {
        if (target == null)
        {
            return;
        }
        
        target.cacheAsBitmap = true;
        target.cacheAsBitmapMatrix = cacheMatrix();
    }
    
    public static function useHiResDefaultNotes(noteskin : Int) : Bool
    {
        return noteskin == 1;
    }
    
    public static function cacheMatrix() : Matrix
    {
        return new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
    }
    
    public static function bitmapFillMatrix(x : Float = 0, y : Float = 0) : Matrix
    {
        return new Matrix(1 / SUPERSAMPLE_SCALE, 0, 0, 1 / SUPERSAMPLE_SCALE, x, y);
    }
    
    public static function supersampleBitmap(source : BitmapData) : BitmapData
    {
        if (source == null)
        {
            return null;
        }
        
        var matrix : Matrix = new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
        var output : BitmapData = new BitmapData(source.width * SUPERSAMPLE_SCALE, source.height * SUPERSAMPLE_SCALE, true, 0);
        output.draw(source, matrix, null, null, null, true);
        return output;
    }

    public function new()
    {
    }
}

