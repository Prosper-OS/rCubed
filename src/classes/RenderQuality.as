package classes
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.display.StageQuality;
    import flash.geom.Matrix;

    public class RenderQuality
    {
        public static const SUPERSAMPLE_SCALE:int = 4;

        public static function configureStage(stage:Stage):void
        {
            if (stage)
                stage.quality = StageQuality.BEST;
        }

        public static function cacheDisplayObject(target:DisplayObject):void
        {
            if (!target)
                return;

            target.cacheAsBitmap = true;
            target.cacheAsBitmapMatrix = cacheMatrix();
        }

        public static function useHiResDefaultNotes(noteskin:int):Boolean
        {
            return noteskin == 1;
        }

        public static function cacheMatrix():Matrix
        {
            return new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
        }

        public static function bitmapFillMatrix(x:Number = 0, y:Number = 0):Matrix
        {
            return new Matrix(1 / SUPERSAMPLE_SCALE, 0, 0, 1 / SUPERSAMPLE_SCALE, x, y);
        }

        public static function supersampleBitmap(source:BitmapData):BitmapData
        {
            if (!source)
                return null;

            var matrix:Matrix = new Matrix(SUPERSAMPLE_SCALE, 0, 0, SUPERSAMPLE_SCALE);
            var output:BitmapData = new BitmapData(source.width * SUPERSAMPLE_SCALE, source.height * SUPERSAMPLE_SCALE, true, 0);
            output.draw(source, matrix, null, null, null, true);
            return output;
        }
    }
}
