package game.controls
{
    import com.greensock.TweenLite;
    import flash.display.BlendMode;
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import game.GameOptions;

    public class AccuracyBar extends GameControl
    {
        private var options:GameOptions;

        private var bound_lower:int = -117;
        private var bound_upper:int = 117;
        private var bound_range:int = 234;

        private var _width:Number = 200;
        private var _height:Number = 16;

        private var _colors:Array;
        private var _flashLayer:Sprite;
        private var _flashPool:Array = [];

        public function AccuracyBar(options:GameOptions, parent:DisplayObjectContainer):void
        {
            if (parent)
                parent.addChild(this);

            this.options = options;

            updateJudge();

            // Parse Colors
            _colors = [];
            _colors[100] = options.judgeColors[0];
            _colors[50] = options.judgeColors[1];
            _colors[25] = options.judgeColors[2];
            _colors[5] = options.judgeColors[3];

            _flashLayer = new Sprite();
            _flashLayer.mouseEnabled = false;
            _flashLayer.mouseChildren = false;
            _flashLayer.blendMode = BlendMode.ADD;

            draw();
        }

        public function onScoreSignal(_score:int, _judgeMS:int):void
        {
            var color:uint = _colors[_score] != null ? _colors[_score] : 0xFFFFFF;
            var xPos:Number = (_judgeMS / bound_range * (_width - 6));
            xPos = Math.max(-(_width / 2), Math.min(_width / 2, xPos));

            var flash:Sprite = buildAccuracyFlash(color, xPos);
            flash.scaleX = 0.06;
            flash.alpha = 0.95;
            _flashLayer.addChild(flash);

            TweenLite.to(flash, 0.045, {scaleX: 1, alpha: 1, useFrames: false, onComplete: fadeAccuracyFlash, onCompleteParams: [flash]});
        }

        public function onResetSignal():void
        {
            while (_flashLayer != null && _flashLayer.numChildren > 0)
            {
                releaseAccuracyFlash(_flashLayer.getChildAt(0) as Sprite);
            }
        }

        /**
         * Updates Judge Region Min Time, Max Time, and Total Size
         * either from the default judge, or a custom set judge.
         */
        public function updateJudge():void
        {
            // Get Judge Window
            var judge:Array = Constant.JUDGE_WINDOW;
            if (options.judgeWindow)
                judge = options.judgeWindow;

            // Get Judge Window Size
            for (var jn:int = 0; jn < judge.length; jn++)
            {
                var jni:Object = judge[jn];
                if (jni.t < bound_lower)
                    bound_lower = jni.t;

                if (jni.t > bound_upper)
                    bound_upper = jni.t;
            }

            bound_range = bound_upper - bound_lower;
        }

        public function draw():void
        {
            this.graphics.clear();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.08);
            this.graphics.beginFill(0xBFD8FF, 0.018);
            this.graphics.drawRoundRect(-(_width / 2), -(_height / 2), _width, _height, 18, 18);
            this.graphics.endFill();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.2);
            this.graphics.moveTo(0, -(_height / 2));
            this.graphics.lineTo(0, (_height / 2));

            drawJudgeRegions();

            if (_flashLayer.parent != this)
                addChild(_flashLayer);
        }

        private function buildAccuracyFlash(color:uint, xPos:Number):Sprite
        {
            var flash:Sprite = _flashPool.length > 0 ? _flashPool.pop() : new Sprite();
            flash.mouseEnabled = false;
            flash.mouseChildren = false;
            flash.blendMode = BlendMode.ADD;
            flash.visible = true;
            flash.graphics.clear();

            var g:Graphics = flash.graphics;
            var widthHalf:Number = _width / 2;
            var heightHalf:Number = _height / 2;
            var coreHeight:Number = _height;

            g.beginFill(color, 0.07);
            g.drawRoundRect(-widthHalf, -heightHalf, _width, _height, 24, 24);
            g.endFill();

            g.beginFill(color, 0.16);
            g.drawRoundRect(xPos - 38, -heightHalf, 76, _height, 18, 18);
            g.endFill();

            g.beginFill(0xFFFFFF, 0.12);
            g.drawRoundRect(-widthHalf, -6, _width, 12, 12, 12);
            g.endFill();

            g.beginFill(color, 0.68);
            g.drawRect(xPos - 2, -heightHalf, 4, coreHeight);
            g.endFill();

            g.beginFill(0xFFFFFF, 0.76);
            g.drawRect(xPos - 0.75, -heightHalf, 1.5, coreHeight);
            g.endFill();

            return flash;
        }

        private function fadeAccuracyFlash(flash:Sprite):void
        {
            TweenLite.to(flash, 0.16, {scaleX: 1.18, alpha: 0, useFrames: false, onComplete: removeAccuracyFlash, onCompleteParams: [flash]});
        }

        private function removeAccuracyFlash(flash:Sprite):void
        {
            releaseAccuracyFlash(flash);
        }

        private function releaseAccuracyFlash(flash:Sprite):void
        {
            if (flash == null)
                return;

            TweenLite.killTweensOf(flash);

            if (flash.parent != null)
                flash.parent.removeChild(flash);

            flash.visible = false;
            flash.alpha = 1;
            flash.scaleX = flash.scaleY = 1;

            if (_flashPool.length < 24)
                _flashPool.push(flash);
        }

        public function drawJudgeRegions():void
        {
            // Get Judge Window
            var judge:Array = Constant.JUDGE_WINDOW;
            if (options.judgeWindow)
                judge = options.judgeWindow;

            this.graphics.lineStyle(1, 0xFFFFFF, 0.13);

            for (var jn:int = 1; jn < judge.length - 1; jn++)
            {
                var dX:Number = _width * ((judge[jn]["t"] - bound_lower) / bound_range);
                this.graphics.moveTo(-(_width / 2) + dX, -(_height / 2) + 1);
                this.graphics.lineTo(-(_width / 2) + dX, (_height / 2) - 1);
            }
        }

        override public function set width(val:Number):void
        {
            _width = Math.max(1, val);
            draw();
        }

        override public function set height(val:Number):void
        {
            _height = Math.max(1, val);
            draw();
        }

        override public function get width():Number
        {
            return _width;
        }

        override public function get height():Number
        {
            return _height;
        }

        override public function get id():String
        {
            return GameLayoutManager.LAYOUT_ACCURACY_BAR;
        }

        override public function get editorFlags():int
        {
            return FLAG_POSITION | FLAG_SIZE | FLAG_ROTATE | FLAG_OPACITY;
        }
    }

}
