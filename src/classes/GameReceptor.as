package classes
{
    import com.greensock.TweenLite;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Matrix;

    public dynamic class GameReceptor extends MovieClip
    {
        private static var DRAW_MATRIX:Matrix = new Matrix();
        private var _note:Sprite;
        public var DIR:String;

        public var animationSpeed:Number = 1;

        public function GameReceptor(dir:String, bitmap:BitmapData)
        {
            this.DIR = dir;

            var logicalWidth:Number = bitmap.width / RenderQuality.SUPERSAMPLE_SCALE;
            var logicalHeight:Number = bitmap.height / RenderQuality.SUPERSAMPLE_SCALE;
            DRAW_MATRIX = RenderQuality.bitmapFillMatrix(-(logicalWidth / 2), -(logicalHeight / 2));

            _note = new Sprite();
            _note.graphics.beginBitmapFill(bitmap, DRAW_MATRIX, false, true);
            _note.graphics.drawRect(-(logicalWidth / 2), -(logicalHeight / 2), logicalWidth, logicalHeight);
            _note.graphics.endFill();
            RenderQuality.cacheDisplayObject(_note);
            this.addChild(_note);
        }

        public function playAnimation(color:uint):void
        {
            _note.scaleX = _note.scaleY = 1;
            TweenLite.to(_note, (0.1 / animationSpeed), {scaleX: 1.25, scaleY: 1.25, tint: color, useFrames: false, onComplete: playAnimationShrink});
        }

        private function playAnimationShrink():void
        {
            TweenLite.to(_note, (0.066 / animationSpeed), {scaleX: 1, scaleY: 1, tint: null, useFrames: false});
        }

        public function dispose():void
        {
            if (_note != null && this.contains(_note))
            {
                this.removeChild(_note);
            }

            _note = null;
        }

    }

}
