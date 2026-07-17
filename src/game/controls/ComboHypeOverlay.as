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

        public function ComboHypeOverlay(parent:Sprite):void
        {
            if (parent)
                parent.addChild(this);

            mouseEnabled = false;
            mouseChildren = false;
            blendMode = BlendMode.ADD;
            alpha = 0;
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
            var w:Number = Main.GAME_WIDTH;
            var h:Number = Main.GAME_HEIGHT;
            var pulseLevel:Number = Math.min(1, level + _pulse);
            var beat:Number = (Math.sin(_phase * 3) + 1) * 0.5;
            var edgeAlpha:Number = 0.12 + (pulseLevel * 0.24);
            var pillAlpha:Number = 0.08 + (pulseLevel * 0.22);
            var thickness:Number = 2 + (pulseLevel * 5);

            drawRgbFrame(g, w, h, thickness, edgeAlpha, beat);
            drawPills(g, w, h, pillAlpha, beat);
            drawCornerBursts(g, w, h, pulseLevel, beat);
            drawScanlines(g, w, h, level);
        }

        private function drawRgbFrame(g:Graphics, w:Number, h:Number, thickness:Number, a:Number, beat:Number):void
        {
            var inset:Number;
            var color:uint;
            for (var i:int = 0; i < 3; i++)
            {
                inset = 5 + (i * 8) + (beat * 2);
                color = rgbColor(_phase + i * 2.1);
                g.lineStyle(thickness - i * 0.8, color, a * (1 - i * 0.18), true);
                g.drawRoundRect(inset, inset, w - inset * 2, h - inset * 2, 22 + i * 7, 22 + i * 7);
            }
        }

        private function drawPills(g:Graphics, w:Number, h:Number, a:Number, beat:Number):void
        {
            var pillWidth:Number = 92 + (beat * 28);
            var pillHeight:Number = 7;
            var margin:Number = 18;
            var lanes:Array = [0.16, 0.36, 0.62, 0.84];

            for (var i:int = 0; i < lanes.length; i++)
            {
                var xPos:Number = (w * lanes[i]) - pillWidth / 2;
                var yTop:Number = margin + (i % 2) * 10;
                var yBottom:Number = h - margin - pillHeight - (i % 2) * 10;
                var color:uint = rgbColor(_phase + i * 1.55);

                g.lineStyle(1, 0xFFFFFF, a * 0.75, true);
                g.beginFill(color, a);
                g.drawRoundRect(xPos, yTop, pillWidth, pillHeight, pillHeight, pillHeight);
                g.endFill();

                g.beginFill(rgbColor(_phase + i * 1.55 + 1.1), a * 0.9);
                g.drawRoundRect(w - xPos - pillWidth, yBottom, pillWidth, pillHeight, pillHeight, pillHeight);
                g.endFill();
            }
        }

        private function drawCornerBursts(g:Graphics, w:Number, h:Number, level:Number, beat:Number):void
        {
            var len:Number = 42 + level * 80 + beat * 16;
            var a:Number = 0.07 + level * 0.18;
            var colors:Array = [0x00F5FF, 0xFF2BD6, 0xB6FF2E, 0x7B61FF];

            for (var i:int = 0; i < 4; i++)
            {
                g.lineStyle(3 + level * 4, colors[i], a, true);
                var x:Number = (i == 1 || i == 2) ? w : 0;
                var y:Number = i >= 2 ? h : 0;
                var sx:int = x == 0 ? 1 : -1;
                var sy:int = y == 0 ? 1 : -1;

                g.moveTo(x, y + sy * 34);
                g.lineTo(x + sx * len, y + sy * 34);
                g.moveTo(x + sx * 34, y);
                g.lineTo(x + sx * 34, y + sy * len);
            }
        }

        private function drawScanlines(g:Graphics, w:Number, h:Number, level:Number):void
        {
            if (level < 0.45)
                return;

            var a:Number = (level - 0.45) * 0.1;
            var offset:Number = (_phase * 18) % 18;
            g.lineStyle(1, 0xFFFFFF, a, true);
            for (var y:Number = offset; y < h; y += 18)
            {
                g.moveTo(0, y);
                g.lineTo(w, y);
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
