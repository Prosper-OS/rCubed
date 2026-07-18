package classes
{
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;

    public dynamic class HiResGameReceptor extends GameReceptor
    {
        private var _hiResNote:Sprite;
        private var _hitNote:Sprite;
        private var _hitColorTransform:ColorTransform = new ColorTransform();
        private var _animationFrame:int = 0;
        private var _animationActive:Boolean = false;

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
            _hiResNote.scaleX = _hiResNote.scaleY = 1.18;
            _hitNote.scaleX = _hitNote.scaleY = 1.18;
            _hitNote.alpha = 0.96;

            _hitColorTransform.color = color;
            _hitNote.transform.colorTransform = _hitColorTransform;
            _animationFrame = 0;

            if (!_animationActive)
            {
                _animationActive = true;
                addEventListener(Event.ENTER_FRAME, updateAnimation, false, 0, true);
            }
        }

        private function updateAnimation(e:Event):void
        {
            _animationFrame++;

            var settle:Number = Math.min(1, _animationFrame / Math.max(1, Math.round(3 / animationSpeed)));
            var scale:Number = 1.18 - (0.18 * settle);
            _hiResNote.scaleX = _hiResNote.scaleY = scale;
            _hitNote.scaleX = _hitNote.scaleY = scale;

            var fade:Number = Math.min(1, _animationFrame / Math.max(1, Math.round(13 / animationSpeed)));
            _hitNote.alpha = 0.96 * (1 - fade);

            if (fade >= 1)
            {
                _animationActive = false;
                removeEventListener(Event.ENTER_FRAME, updateAnimation);
                _hiResNote.scaleX = _hiResNote.scaleY = 1;
                _hitNote.scaleX = _hitNote.scaleY = 1;
                _hitNote.alpha = 0;
            }
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
            removeEventListener(Event.ENTER_FRAME, updateAnimation);

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
