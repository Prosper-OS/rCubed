package game.controls
{
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;

    public class ComboHypeOverlay extends Sprite
    {
        public static const MODE_FULL:String = "full";
        public static const MODE_REDUCED:String = "reduced";
        public static const MODE_OFF:String = "off";

        private var _combo:int = 0;
        private var _score:int = 0;
        private var _level:Number = 0;
        private var _pulse:Number = 0;
        private var _phase:Number = 0;
        private var _hitFlash:Number = 0;
        private var _hitColor:uint = 0xFFFFFF;
        private var _mode:String = MODE_FULL;
        private var _particles:Array = [];
        private var _laneX:Number = 0;
        private var _laneY:Number = 0;
        private var _laneWidth:Number = 0;
        private var _laneHeight:Number = 0;

        public var shakeX:Number = 0;
        public var shakeY:Number = 0;

        public function ComboHypeOverlay(parent:Sprite, mode:String = "full"):void
        {
            if (parent)
                parent.addChild(this);

            mouseEnabled = false;
            mouseChildren = false;
            blendMode = BlendMode.ADD;
            alpha = 0;
            setMode(mode);
        }

        public function setMode(mode:String):void
        {
            if (mode != MODE_REDUCED && mode != MODE_OFF)
                mode = MODE_FULL;

            _mode = mode;
            if (_mode == MODE_OFF)
            {
                _particles.length = 0;
                _pulse = 0;
                _hitFlash = 0;
                shakeX = 0;
                shakeY = 0;
                alpha = 0;
                graphics.clear();
            }
        }

        public function setLaneBounds(xPos:Number, yPos:Number, laneWidth:Number, laneHeight:Number):void
        {
            _laneX = xPos;
            _laneY = yPos;
            _laneWidth = Math.max(64, laneWidth);
            _laneHeight = Math.max(64, laneHeight);
        }

        public function onJudge(combo:int, score:int, dir:String = null):void
        {
            _combo = Math.max(0, combo);
            _score = score;

            if (_mode == MODE_OFF)
                return;

            if (score > 0)
            {
                var scale:Number = modeScale();
                _pulse = Math.min(1, _pulse + (0.16 + Math.min(0.36, _combo / 820)) * scale);
                _hitFlash = Math.min(1, _hitFlash + 0.72 * scale);
                _hitColor = scoreColor(score);
                spawnBurstParticles(score, dir);
            }
            else if (score == -10)
            {
                _pulse = 0;
                _hitFlash = Math.min(1, _hitFlash + 0.35 * modeScale());
                _hitColor = 0xFF255D;
            }
        }

        public function tick(frame:int):void
        {
            if (_mode == MODE_OFF)
            {
                graphics.clear();
                shakeX = 0;
                shakeY = 0;
                alpha = 0;
                return;
            }

            _phase = frame * 0.055;

            var target:Number = hypeLevel(_combo) * modeScale();
            _level += (target - _level) * 0.085;
            _pulse *= (_mode == MODE_FULL ? 0.9 : 0.84);
            _hitFlash *= (_mode == MODE_FULL ? 0.78 : 0.66);
            updateParticles();

            var visibleLevel:Number = Math.max(_level, _pulse * 0.62, _hitFlash * 0.34);
            alpha = Math.min(_mode == MODE_FULL ? 0.95 : 0.56, visibleLevel);
            updateShake(visibleLevel);

            graphics.clear();
            if (visibleLevel < 0.015 && _particles.length == 0)
                return;

            drawOverlay(graphics, visibleLevel);
        }

        private function modeScale():Number
        {
            return _mode == MODE_REDUCED ? 0.42 : 1;
        }

        private function hypeLevel(combo:int):Number
        {
            if (combo < 12)
                return 0.05;

            if (combo < 64)
                return 0.08 + ((combo - 12) / 52 * 0.2);

            if (combo < 160)
                return 0.28 + ((combo - 64) / 96 * 0.22);

            if (combo < 320)
                return 0.5 + ((combo - 160) / 160 * 0.28);

            return Math.min(1, 0.78 + ((combo - 320) / 560 * 0.22));
        }

        private function updateShake(level:Number):void
        {
            var maxShake:Number = _mode == MODE_FULL ? 7.5 : 2.25;
            var amount:Number = (Math.max(0, level - 0.18) * maxShake) + (_hitFlash * (_mode == MODE_FULL ? 4.2 : 1.4));
            if (amount < 0.08)
            {
                shakeX = 0;
                shakeY = 0;
                return;
            }

            shakeX = Math.sin(_phase * 15.7) * amount + Math.sin(_phase * 37.1) * amount * 0.22;
            shakeY = Math.cos(_phase * 13.3) * amount * 0.62 + Math.sin(_phase * 29.8) * amount * 0.18;
        }

        private function drawOverlay(g:Graphics, level:Number):void
        {
            var pulseLevel:Number = Math.min(1, level + _pulse + _hitFlash * 0.38);
            var beat:Number = (Math.sin(_phase * 3) + 1) * 0.5;

            drawFullScreenFlow(g, pulseLevel, beat);
            drawGlassHudFrame(g, pulseLevel);
            drawLaneGlass(g, pulseLevel);
            drawLaneEdges(g, 3 + (pulseLevel * 11), 0.12 + (pulseLevel * 0.36), 0.1 + (pulseLevel * 0.3), pulseLevel, beat);
            drawHitFlash(g, pulseLevel);
            drawParticles(g);
            drawScanlines(g, level);
        }

        private function drawFullScreenFlow(g:Graphics, level:Number, beat:Number):void
        {
            var w:Number = Main.GAME_WIDTH;
            var h:Number = Main.GAME_HEIGHT;
            var a:Number = (_mode == MODE_FULL ? 0.035 : 0.015) + level * (_mode == MODE_FULL ? 0.075 : 0.025);
            var flowW:Number = 180 + level * 160;
            var offset:Number = (_phase * 42) % (w + flowW);

            g.beginFill(0x06111F, 0.16 + level * 0.08);
            g.drawRect(0, 0, w, h);
            g.endFill();

            for (var i:int = 0; i < 5; i++)
            {
                var x:Number = -flowW + ((offset + i * 165) % (w + flowW * 2));
                var y:Number = 58 + i * 92 + Math.sin(_phase * 1.4 + i) * 28;
                var color:uint = rgbColor(_phase + i * 1.35);
                g.beginFill(color, a * (0.58 - i * 0.045));
                g.drawEllipse(x, y, flowW, 54 + beat * 20);
                g.endFill();
            }

            g.beginFill(rgbColor(_phase + 1.7), level * (_mode == MODE_FULL ? 0.09 : 0.03));
            g.drawRect(0, h - 96 - beat * 16, w, 34 + beat * 18);
            g.endFill();
        }

        private function drawGlassHudFrame(g:Graphics, level:Number):void
        {
            var w:Number = Main.GAME_WIDTH;
            var h:Number = Main.GAME_HEIGHT;
            var a:Number = 0.08 + level * 0.18;
            var colorA:uint = rgbColor(_phase);
            var colorB:uint = rgbColor(_phase + 2.2);

            g.beginFill(0xFFFFFF, 0.02 + level * 0.025);
            g.drawRect(0, 0, w, 44);
            g.drawRect(0, h - 42, w, 42);
            g.endFill();

            g.lineStyle(1.5, 0xFFFFFF, 0.12 + level * 0.16, true);
            g.moveTo(0, 44);
            g.lineTo(w, 44);
            g.moveTo(0, h - 42);
            g.lineTo(w, h - 42);

            g.lineStyle(3 + level * 4, colorA, a, true);
            g.moveTo(12, 45);
            g.lineTo(178 + level * 110, 45);
            g.moveTo(w - 12, h - 43);
            g.lineTo(w - 178 - level * 110, h - 43);

            g.lineStyle(2 + level * 3, colorB, a * 0.78, true);
            g.moveTo(w - 12, 45);
            g.lineTo(w - 142 - level * 80, 45);
            g.moveTo(12, h - 43);
            g.lineTo(142 + level * 80, h - 43);
        }

        private function drawLaneGlass(g:Graphics, level:Number):void
        {
            if (_laneWidth <= 0 || _laneHeight <= 0)
                return;

            var a:Number = (_mode == MODE_FULL ? 0.028 : 0.012) + level * (_mode == MODE_FULL ? 0.06 : 0.022);
            g.beginFill(0xBDEBFF, a);
            g.drawRoundRect(_laneX - 14, _laneY, _laneWidth + 28, _laneHeight, 24, 24);
            g.endFill();

            g.lineStyle(1, 0xFFFFFF, 0.05 + level * 0.08, true);
            g.drawRoundRect(_laneX - 14, _laneY + 1, _laneWidth + 28, _laneHeight - 2, 24, 24);
        }

        private function drawLaneEdges(g:Graphics, thickness:Number, edgeAlpha:Number, pillAlpha:Number, level:Number, beat:Number):void
        {
            var left:Number = _laneX;
            var right:Number = _laneX + _laneWidth;
            var top:Number = _laneY;
            var heightValue:Number = _laneHeight;
            var segmentHeight:Number = 34 + level * 44;
            var segmentGap:Number = 24 - level * 11;
            var yOffset:Number = (_phase * 36) % (segmentHeight + segmentGap);
            var i:int;
            var y:Number;
            var color:uint;

            for (i = 0; i < 5; i++)
            {
                color = rgbColor(_phase + i * 1.5);
                g.lineStyle(Math.max(1, thickness - i * 1.15), color, edgeAlpha * (1 - i * 0.16), true);
                g.moveTo(left - i * 3, top);
                g.lineTo(left - i * 3, top + heightValue);
                g.moveTo(right + i * 3, top);
                g.lineTo(right + i * 3, top + heightValue);
            }

            for (y = top - yOffset; y < top + heightValue; y += segmentHeight + segmentGap)
            {
                var drawY:Number = Math.max(top, y);
                var drawHeight:Number = Math.min(segmentHeight + beat * 14, top + heightValue - drawY);
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
                var capAlpha:Number = (level - 0.55) * 0.32;
                g.lineStyle(2 + level * 4, rgbColor(_phase + 3), capAlpha, true);
                g.moveTo(left, top + 16);
                g.lineTo(right, top + 16);
                g.moveTo(left, top + heightValue - 16);
                g.lineTo(right, top + heightValue - 16);
            }
        }

        private function drawHitFlash(g:Graphics, level:Number):void
        {
            if (_hitFlash < 0.02)
                return;

            var h:Number = Main.GAME_HEIGHT;
            var w:Number = Main.GAME_WIDTH;
            var band:Number = 26 + _hitFlash * 68;
            var centerY:Number = h * 0.5 + Math.sin(_phase * 2.4) * 24;

            g.beginFill(_hitColor, _hitFlash * (_mode == MODE_FULL ? 0.2 : 0.08));
            g.drawRect(0, centerY - band * 0.5, w, band);
            g.endFill();

            g.lineStyle(2 + _hitFlash * 7, 0xFFFFFF, _hitFlash * (_mode == MODE_FULL ? 0.26 : 0.1), true);
            g.moveTo(0, centerY);
            g.lineTo(w, centerY);
        }

        private function drawScanlines(g:Graphics, level:Number):void
        {
            if (level < 0.3)
                return;

            var a:Number = (level - 0.3) * (_mode == MODE_FULL ? 0.09 : 0.03);
            var offset:Number = (_phase * 18) % 18;
            g.lineStyle(1, 0xFFFFFF, a, true);
            for (var y:Number = offset; y < Main.GAME_HEIGHT; y += 18)
            {
                g.moveTo(0, y);
                g.lineTo(Main.GAME_WIDTH, y);
            }
        }

        private function spawnBurstParticles(score:int, dir:String):void
        {
            var count:int = _mode == MODE_FULL ? 10 : 4;
            if (_combo > 96)
                count += _mode == MODE_FULL ? 7 : 2;
            if (_combo > 260)
                count += _mode == MODE_FULL ? 7 : 2;

            var laneCenter:Number = laneCenterForDir(dir);
            var y:Number = _laneY + _laneHeight * 0.5;
            var color:uint = scoreColor(score);
            for (var i:int = 0; i < count; i++)
            {
                var side:Number = (i % 2 == 0) ? -1 : 1;
                _particles.push({
                    x: laneCenter + (Math.random() - 0.5) * (_laneWidth * 0.16),
                    y: y + (Math.random() - 0.5) * (_laneHeight * 0.2),
                    vx: side * (2.1 + Math.random() * 4.8),
                    vy: -3.5 + Math.random() * 7,
                    life: 1,
                    decay: 0.055 + Math.random() * 0.035,
                    size: 2.5 + Math.random() * 5.5,
                    color: color
                });
            }

            while (_particles.length > (_mode == MODE_FULL ? 120 : 44))
                _particles.shift();
        }

        private function updateParticles():void
        {
            for (var i:int = _particles.length - 1; i >= 0; i--)
            {
                var p:Object = _particles[i];
                p.x += p.vx;
                p.y += p.vy;
                p.vx *= 0.97;
                p.vy *= 0.97;
                p.life -= p.decay;
                if (p.life <= 0)
                    _particles.splice(i, 1);
            }
        }

        private function drawParticles(g:Graphics):void
        {
            for each (var p:Object in _particles)
            {
                var a:Number = Math.max(0, p.life) * (_mode == MODE_FULL ? 0.72 : 0.36);
                g.beginFill(p.color, a);
                g.drawCircle(p.x, p.y, p.size * Math.max(0.25, p.life));
                g.endFill();

                g.lineStyle(1, 0xFFFFFF, a * 0.45, true);
                g.drawCircle(p.x, p.y, p.size * 0.38);
            }
        }

        private function laneCenterForDir(dir:String):Number
        {
            var idx:int = 1;
            switch (dir)
            {
                case "L":
                    idx = 0;
                    break;
                case "D":
                    idx = 1;
                    break;
                case "U":
                    idx = 2;
                    break;
                case "R":
                    idx = 3;
                    break;
            }

            return _laneX + _laneWidth * ((idx + 0.5) / 4);
        }

        private function scoreColor(score:int):uint
        {
            switch (score)
            {
                case 100:
                    return 0x1FFBFF;
                case 50:
                    return 0xFFFFFF;
                case 25:
                    return 0x58FF65;
                case 5:
                    return 0xFFE347;
                case -5:
                    return 0xFF8F2A;
                case -10:
                    return 0xFF255D;
            }
            return 0xFFFFFF;
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
