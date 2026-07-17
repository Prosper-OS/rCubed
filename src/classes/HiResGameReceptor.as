package classes
{
    import com.greensock.TweenLite;
    import flash.display.BitmapData;
    import flash.display.Sprite;

    public class HiResGameReceptor extends GameReceptor
    {
        private var _hiResNote:Sprite;

        public function HiResGameReceptor(dir:String, receptorWidth:Number = 64, receptorHeight:Number = 64)
        {
            super(dir, transparentBitmap());

            mouseEnabled = false;
            mouseChildren = false;
            doubleClickEnabled = false;
            tabEnabled = false;

            _hiResNote = new HiResArrowNote("white", receptorWidth, receptorHeight);
            _hiResNote.x = -(receptorWidth / 2);
            _hiResNote.y = -(receptorHeight / 2);
            addChild(_hiResNote);
        }

        override public function playAnimation(color:uint):void
        {
            _hiResNote.scaleX = _hiResNote.scaleY = 1;
            TweenLite.to(_hiResNote, (0.1 / animationSpeed), {scaleX: 1.25, scaleY: 1.25, tint: color, useFrames: false, onComplete: playAnimationShrink});
        }

        public function playScoreAnimation(score:int, configuredColor:uint):void
        {
            var color:uint = configuredColor;
            switch (score)
            {
                case 100:
                    color = 0x1FFBFF;
                    break;
                case 50:
                    color = 0xFFFFFF;
                    break;
                case 25:
                    color = 0x58FF65;
                    break;
                case 5:
                    color = 0xFFE347;
                    break;
                case -5:
                    color = 0xFF8F2A;
                    break;
                case -10:
                    color = 0xFF255D;
                    break;
            }
            playAnimation(color);
        }

        private function playAnimationShrink():void
        {
            TweenLite.to(_hiResNote, (0.066 / animationSpeed), {scaleX: 1, scaleY: 1, tint: null, useFrames: false});
        }

        override public function dispose():void
        {
            if (_hiResNote != null && contains(_hiResNote))
                removeChild(_hiResNote);

            _hiResNote = null;
            super.dispose();
        }

        private static function transparentBitmap():BitmapData
        {
            return new BitmapData(RenderQuality.SUPERSAMPLE_SCALE, RenderQuality.SUPERSAMPLE_SCALE, true, 0);
        }
    }
}
