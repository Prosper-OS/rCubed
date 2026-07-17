package game.controls
{
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;

    public class ComboHypeOverlay extends Sprite
    {
        private var _combo:int = 0;
        private var _score:int = 0;
        private var _level:Number = 0;
        private var _pulse:Number = 0;
        private var _phase:Number = 0;
        private var _laneX:Number = 0;
        private var _laneY:Number = 0;
        private var _laneWidth:Number = 0;
        private var _laneHeight:Number = 0;

        public function ComboHypeOverlay(parent:Sprite):void
        {
            if (parent)
                parent.addChild(this);

            mouseEnabled = false;
            mouseChildren = false;
            blendMode = BlendMode.ADD;
            alpha = 0;
        }

        public function setLaneBounds(xPos:Number, yPos:Number, laneWidth:Number, laneHeight:Number):void
        {
            _laneX = xPos;
            _laneY = yPos;
            _laneWidth = Math.max(64, laneWidth);
            _laneHeight = Math.max(64, laneHeight);
        }

        public function onJudge(combo:int, score:int):void
        {
            _combo = Math.max(0, combo);
            _score = score;

            if (score > 0)
                _pulse = Math.min(1, _pulse + 0.12 + Math.min(0.28, _combo / 900));
            else if (score == -10)
                _pulse = 0;
        }

        public function tick(frame:int):void
        {
            _phase = frame * 0.055;

            var target:Number = hypeLevel(_combo);
            _level += (target - _level) * 0.09;
            _pulse *= 0.9;

            var visibleLevel:Number = Math.max(_level, _pulse * 0.55);
            alpha = Math.min(0.92, visibleLevel);

            graphics.clear();
            if (visibleLevel < 0.025)
                return;

            drawOverlay(graphics, visibleLevel);
        }

        private function hypeLevel(combo:int):Number
        {
            if (combo < 16)
                return 0;

            if (combo < 64)
                return (combo - 16) / 48 * 0.18;

            if (combo < 160)
                return 0.18 + ((combo - 64) / 96 * 0.22);

            if (combo < 320)
                return 0.4 + ((combo - 160) / 160 * 0.28);

            return Math.min(1, 0.68 + ((combo - 320) / 520 * 0.32));
        }

        private function drawOverlay(g:Graphics, level:Number):void
        {
            var pulseLevel:Number = Math.min(1, level + _pulse);
            var beat:Number = (Math.sin(_phase * 3) + 1) * 0.5;
            var edgeAlpha:Number = 0.12 + (pulseLevel * 0.34);
            var pillAlpha:Number = 0.1 + (pulseLevel * 0.28);
            var thickness:Number = 3 + (pulseLevel * 9);

            drawLaneEdges(g, thickness, edgeAlpha, pillAlpha, pulseLevel, beat);
            drawScanlines(g, level);
        }

        private function drawLaneEdges(g:Graphics, thickness:Number, edgeAlpha:Number, pillAlpha:Number, level:Number, beat:Number):void
        {
            var left:Number = _laneX;
            var right:Number = _laneX + _laneWidth;
            var top:Number = _laneY;
            var heightValue:Number = _laneHeight;
            var segmentHeight:Number = 34 + level * 38;
            var segmentGap:Number = 26 - level * 10;
            var yOffset:Number = (_phase * 34) % (segmentHeight + segmentGap);
            var i:int;
            var y:Number;
            var color:uint;

            for (i = 0; i < 4; i++)
            {
                color = rgbColor(_phase + i * 1.65);
                g.lineStyle(Math.max(1, thickness - i * 1.2), color, edgeAlpha * (1 - i * 0.18), true);
                g.moveTo(left - i * 3, top);
                g.lineTo(left - i * 3, top + heightValue);
                g.moveTo(right + i * 3, top);
                g.lineTo(right + i * 3, top + heightValue);
            }

            for (y = top - yOffset; y < top + heightValue; y += segmentHeight + segmentGap)
            {
                var drawY:Number = Math.max(top, y);
                var drawHeight:Number = Math.min(segmentHeight + beat * 12, top + heightValue - drawY);
                if (drawHeight <= 0)
                    continue;

                color = rgbColor(_phase + y * 0.024);
                g.lineStyle(1, 0xFFFFFF, pillAlpha * 0.65, true);
                g.beginFill(color, pillAlpha);
                g.drawRoundRect(left - thickness * 0.9, drawY, thickness * 1.8, drawHeight, thickness * 1.8, thickness * 1.8);
                g.endFill();

                g.beginFill(rgbColor(_phase + y * 0.024 + 1.25), pillAlpha);
                g.drawRoundRect(right - thickness * 0.9, drawY, thickness * 1.8, drawHeight, thickness * 1.8, thickness * 1.8);
                g.endFill();
            }

            if (level > 0.55)
            {
                var capAlpha:Number = (level - 0.55) * 0.28;
                g.lineStyle(2 + level * 4, rgbColor(_phase + 3), capAlpha, true);
                g.moveTo(left, top + 16);
                g.lineTo(right, top + 16);
                g.moveTo(left, top + heightValue - 16);
                g.lineTo(right, top + heightValue - 16);
            }
        }

        private function drawScanlines(g:Graphics, level:Number):void
        {
            if (level < 0.45)
                return;

            var a:Number = (level - 0.45) * 0.1;
            var offset:Number = (_phase * 18) % 18;
            g.lineStyle(1, 0xFFFFFF, a, true);
            for (var y:Number = _laneY + offset; y < _laneY + _laneHeight; y += 18)
            {
                g.moveTo(_laneX, y);
                g.lineTo(_laneX + _laneWidth, y);
            }
        }

        private function rgbColor(t:Number):uint
        {
            var r:uint = Math.round((Math.sin(t) * 0.5 + 0.5) * 255);
            var g:uint = Math.round((Math.sin(t + 2.094) * 0.5 + 0.5) * 255);
            var b:uint = Math.round((Math.sin(t + 4.188) * 0.5 + 0.5) * 255);
            return (r << 16) | (g << 8) | b;
        }
    }
}
