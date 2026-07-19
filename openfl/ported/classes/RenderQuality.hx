package classes;

import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.display.StageQuality;
import openfl.geom.Matrix;

class RenderQuality
{
    public static inline var SUPERSAMPLE_SCALE                              : Dynamic= 4;
    
    public static function configureStage(stage                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(stage != null))
        {
            stage.quality = StageQuality.BEST;
        }
    }
    
    public static function cacheDisplayObject(target                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(target == null))
        {
            return;
        }
        
        target.cacheAsBitmap = true;
        target.cacheAsBitmapMatrix = cacheMatrix();
    }
    
    public static function useHiResDefaultNotes(noteskin                              : Dynamic) : Bool
    {
        return noteskin == 1;
    }
    
    public static function cacheMatrix() : Matrix
    {
        return new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
    }
    
    public static function bitmapFillMatrix(x                              : Dynamic= 0, y                              : Dynamic= 0) : Matrix
    {
        return new Matrix(1 / SUPERSAMPLE_SCALE, 0, 0, 1 / SUPERSAMPLE_SCALE, x, y);
    }
    
    public static function supersampleBitmap(source                              : Dynamic) : BitmapData
    {
        if (as3hx.Compat.truthy(source == null))
        {
            return null;
        }
        
        var matrix                              : Dynamic= new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
        var output                              : Dynamic= new BitmapData(Std.int(source.width * SUPERSAMPLE_SCALE), Std.int(source.height * SUPERSAMPLE_SCALE), true, 0);
        output.draw(source, matrix, null, null, null, true);
        return output;
    }

    public function new()
    {
    }
}

