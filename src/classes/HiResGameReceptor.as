package classes
{
    import com.greensock.TweenLite;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;

    public dynamic class HiResGameReceptor extends GameReceptor
    {
        private var _hiResNote:Sprite;
        private var _hitNote:Sprite;

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

            _hitNote = new HiResArrowNote("white", receptorWidth, receptorHeight);
            _hitNote.x = -(receptorWidth / 2);
            _hitNote.y = -(receptorHeight / 2);
            _hitNote.alpha = 0;
            _hitNote.blendMode = BlendMode.ADD;
            addChild(_hitNote);
        }

        override public function playAnimation(color:uint):void
        {
            TweenLite.killTweensOf(_hiResNote);
            TweenLite.killTweensOf(_hitNote);

            _hiResNote.scaleX = _hiResNote.scaleY = 1.18;
            _hitNote.scaleX = _hitNote.scaleY = 1.18;
            _hitNote.alpha = 0.96;

            var colorTransform:ColorTransform = _hitNote.transform.colorTransform;
            colorTransform.color = color;
            _hitNote.transform.colorTransform = colorTransform;

            TweenLite.to(_hiResNote, (0.045 / animationSpeed), {scaleX: 1, scaleY: 1, useFrames: false});
            TweenLite.to(_hitNote, (0.045 / animationSpeed), {scaleX: 1, scaleY: 1, useFrames: false});
            TweenLite.to(_hitNote, (0.22 / animationSpeed), {alpha: 0, useFrames: false});
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

        override public function dispose():void
        {
            if (_hiResNote != null && contains(_hiResNote))
                removeChild(_hiResNote);
            if (_hitNote != null && contains(_hitNote))
                removeChild(_hitNote);

            _hiResNote = null;
            _hitNote = null;
            super.dispose();
        }

        private static function transparentBitmap():BitmapData
        {
            return new BitmapData(RenderQuality.SUPERSAMPLE_SCALE, RenderQuality.SUPERSAMPLE_SCALE, true, 0);
        }
    }
}
