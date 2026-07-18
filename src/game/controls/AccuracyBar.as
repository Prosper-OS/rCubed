package game.controls
{
    import flash.display.BlendMode;
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import game.GameOptions;

    public class AccuracyBar extends GameControl
    {
        private static const PERSPECTIVE_TOP:Number = 0.70;
        private static const PERSPECTIVE_BOTTOM:Number = 1.00;

        private var options:GameOptions;

        private var bound_lower:int = -117;
        private var bound_upper:int = 117;
        private var bound_range:int = 234;

        private var _width:Number = 200;
        private var _height:Number = 16;

        private var _colors:Array;
        private var _flashLayer:Sprite;
        private var _flashPool:Array = [];
        private var _activeFlashes:Vector.<Sprite> = new <Sprite>[];
        private var _flashAge:Vector.<int> = new <int>[];

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

            _activeFlashes[_activeFlashes.length] = flash;
            _flashAge[_flashAge.length] = 0;
        }

        public function tick():void
        {
            for (var i:int = _activeFlashes.length - 1; i >= 0; i--)
            {
                var flash:Sprite = _activeFlashes[i];
                var age:int = _flashAge[i] + 1;
                _flashAge[i] = age;

                if (age <= 3)
                {
                    var expand:Number = age / 3;
                    flash.scaleX = 0.06 + (0.94 * expand);
                    flash.alpha = 0.95 + (0.05 * expand);
                }
                else
                {
                    var fade:Number = (age - 3) / 10;
                    if (fade >= 1)
                    {
                        releaseActiveFlash(i);
                        continue;
                    }

                    flash.scaleX = 1 + (0.18 * fade);
                    flash.alpha = 1 - fade;
                }
            }
        }

        public function onResetSignal():void
        {
            while (_flashLayer != null && _flashLayer.numChildren > 0)
            {
                releaseAccuracyFlash(_flashLayer.getChildAt(0) as Sprite);
            }
            _activeFlashes.length = 0;
            _flashAge.length = 0;
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

            this.graphics.lineStyle(1, 0xFFFFFF, 0.045);
            this.graphics.beginFill(0xBFD8FF, 0.006);
            drawPerspectiveQuad(this.graphics, -(_width / 2), _width, -(_height / 2), _height);
            this.graphics.endFill();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.13);
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
            drawPerspectiveQuad(g, -widthHalf, _width, -heightHalf, _height);
            g.endFill();

            g.beginFill(color, 0.16);
            drawPerspectiveQuad(g, xPos - 38, 76, -heightHalf, _height);
            g.endFill();

            g.beginFill(0xFFFFFF, 0.12);
            drawPerspectiveQuad(g, -widthHalf, _width, -6, 12);
            g.endFill();

            g.beginFill(color, 0.68);
            drawPerspectiveQuad(g, xPos - 2, 4, -heightHalf, coreHeight);
            g.endFill();

            g.beginFill(0xFFFFFF, 0.76);
            drawPerspectiveQuad(g, xPos - 0.75, 1.5, -heightHalf, coreHeight);
            g.endFill();

            return flash;
        }

        private function releaseActiveFlash(index:int):void
        {
            var flash:Sprite = _activeFlashes[index];
            releaseAccuracyFlash(flash);

            var last:int = _activeFlashes.length - 1;
            if (index != last)
            {
                _activeFlashes[index] = _activeFlashes[last];
                _flashAge[index] = _flashAge[last];
            }

            _activeFlashes.length = last;
            _flashAge.length = last;
        }

        private function releaseAccuracyFlash(flash:Sprite):void
        {
            if (flash == null)
                return;

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

            this.graphics.lineStyle(1, 0xFFFFFF, 0.075);

            for (var jn:int = 1; jn < judge.length - 1; jn++)
            {
                var dX:Number = _width * ((judge[jn]["t"] - bound_lower) / bound_range);
                var baseX:Number = -(_width / 2) + dX;
                this.graphics.moveTo(perspectiveX(baseX, -(_height / 2) + 1), -(_height / 2) + 1);
                this.graphics.lineTo(perspectiveX(baseX, (_height / 2) - 1), (_height / 2) - 1);
            }
        }

        private function drawPerspectiveQuad(g:Graphics, xPos:Number, widthValue:Number, yPos:Number, heightValue:Number):void
        {
            var yTop:Number = yPos;
            var yBottom:Number = yPos + heightValue;
            var left:Number = xPos;
            var right:Number = xPos + widthValue;

            g.moveTo(perspectiveX(left, yTop), yTop);
            g.lineTo(perspectiveX(right, yTop), yTop);
            g.lineTo(perspectiveX(right, yBottom), yBottom);
            g.lineTo(perspectiveX(left, yBottom), yBottom);
            g.lineTo(perspectiveX(left, yTop), yTop);
        }

        private function perspectiveX(xPos:Number, yPos:Number):Number
        {
            var depth:Number = (yPos + (_height / 2)) / Math.max(1, _height);
            var scale:Number = PERSPECTIVE_TOP + ((PERSPECTIVE_BOTTOM - PERSPECTIVE_TOP) * depth);
            return xPos * scale;
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
