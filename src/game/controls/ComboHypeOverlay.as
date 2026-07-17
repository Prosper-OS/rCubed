package game.controls
{
    import classes.RenderQuality;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;

    public class ComboHypeOverlay extends Sprite
    {
        public static const MODE_FULL:String = "full";
        public static const MODE_REDUCED:String = "reduced";
        public static const MODE_OFF:String = "off";

        private static const FLOW_COUNT:int = 5;
        private static const MAX_PARTICLES:int = 120;
        private static const MAX_PARTICLES_REDUCED:int = 44;
        private static const LANE_TOP_SCALE:Number = 0.70;
        private static const LANE_BOTTOM_SCALE:Number = 1.00;

        private var _combo:int = 0;
        private var _score:int = 0;
        private var _level:Number = 0;
        private var _pulse:Number = 0;
        private var _phase:Number = 0;
        private var _hitFlash:Number = 0;
        private var _hitColor:uint = 0xFFFFFF;
        private var _mode:String = MODE_FULL;
        private var _laneX:Number = 0;
        private var _laneY:Number = 0;
        private var _laneWidth:Number = 0;
        private var _laneHeight:Number = 0;

        private var _flowLayer:Sprite;
        private var _vectorLayer:Sprite;
        private var _particleLayer:Sprite;
        private var _scanlineLayer:Sprite;
        private var _flowWash:Sprite;
        private var _floorBand:Sprite;
        private var _flowSprites:Vector.<Sprite> = new <Sprite>[];

        private var _particleSprites:Vector.<Sprite> = new <Sprite>[];
        private var _particleActive:Vector.<Boolean> = new Vector.<Boolean>(MAX_PARTICLES, true);
        private var _particleX:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleY:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleVX:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleVY:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleLife:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleDecay:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _particleSize:Vector.<Number> = new Vector.<Number>(MAX_PARTICLES, true);
        private var _activeParticles:int = 0;
        private var _particleCursor:int = 0;
        private var _colorTransform:ColorTransform = new ColorTransform();

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

            buildCachedLayers();
            setMode(mode);
        }

        public function setMode(mode:String):void
        {
            if (mode != MODE_REDUCED && mode != MODE_OFF)
                mode = MODE_FULL;

            _mode = mode;
            visible = _mode != MODE_OFF;
            if (_mode == MODE_OFF)
            {
                clearParticles();
                _pulse = 0;
                _hitFlash = 0;
                shakeX = 0;
                shakeY = 0;
                alpha = 0;
                _vectorLayer.graphics.clear();
                _flowLayer.visible = false;
                _scanlineLayer.visible = false;
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
                shakeX = 0;
                shakeY = 0;
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

            if (visibleLevel < 0.015 && _activeParticles == 0)
            {
                _vectorLayer.graphics.clear();
                _flowLayer.visible = false;
                _scanlineLayer.visible = false;
                return;
            }

            drawOverlay(visibleLevel);
        }

        private function buildCachedLayers():void
        {
            _flowLayer = createLayer();
            _vectorLayer = createLayer();
            _particleLayer = createLayer();
            _scanlineLayer = createLayer();

            addChild(_flowLayer);
            addChild(_vectorLayer);
            addChild(_particleLayer);
            addChild(_scanlineLayer);

            _flowWash = new Sprite();
            _flowWash.graphics.beginFill(0x06111F, 1);
            _flowWash.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _flowWash.graphics.endFill();
            RenderQuality.cacheDisplayObject(_flowWash);
            _flowLayer.addChild(_flowWash);

            _floorBand = new Sprite();
            _floorBand.graphics.beginFill(0xFFFFFF, 1);
            _floorBand.graphics.drawRect(0, -30, Main.GAME_WIDTH, 60);
            _floorBand.graphics.endFill();
            RenderQuality.cacheDisplayObject(_floorBand);
            _flowLayer.addChild(_floorBand);

            for (var i:int = 0; i < FLOW_COUNT; i++)
            {
                var flow:Sprite = new Sprite();
                flow.graphics.beginFill(0xFFFFFF, 1);
                flow.graphics.drawEllipse(-170, -50, 340, 100);
                flow.graphics.endFill();
                flow.blendMode = BlendMode.ADD;
                flow.mouseEnabled = false;
                RenderQuality.cacheDisplayObject(flow);
                _flowLayer.addChild(flow);
                _flowSprites.push(flow);
            }

            _scanlineLayer.graphics.lineStyle(1, 0xFFFFFF, 1, true);
            for (var y:Number = -18; y < Main.GAME_HEIGHT + 36; y += 18)
            {
                _scanlineLayer.graphics.moveTo(0, y);
                _scanlineLayer.graphics.lineTo(Main.GAME_WIDTH, y);
            }
            RenderQuality.cacheDisplayObject(_scanlineLayer);
            _scanlineLayer.visible = false;

            for (i = 0; i < MAX_PARTICLES; i++)
            {
                var particle:Sprite = new Sprite();
                particle.graphics.beginFill(0xFFFFFF, 0.82);
                particle.graphics.drawCircle(0, 0, 6);
                particle.graphics.endFill();
                particle.graphics.lineStyle(1, 0xFFFFFF, 0.55, true);
                particle.graphics.drawCircle(0, 0, 2.3);
                particle.blendMode = BlendMode.ADD;
                particle.mouseEnabled = false;
                particle.visible = false;
                RenderQuality.cacheDisplayObject(particle);
                _particleLayer.addChild(particle);
                _particleSprites.push(particle);
                _particleActive[i] = false;
            }
        }

        private function createLayer():Sprite
        {
            var layer:Sprite = new Sprite();
            layer.mouseEnabled = false;
            layer.mouseChildren = false;
            layer.blendMode = BlendMode.ADD;
            return layer;
        }

        private function modeScale():Number
        {
            return _mode == MODE_REDUCED ? 0.42 : 1;
        }

        private function maxParticlesForMode():int
        {
            return _mode == MODE_REDUCED ? MAX_PARTICLES_REDUCED : MAX_PARTICLES;
        }

        private function hypeLevel(combo:int):Number
        {
            if (combo < 12)
                return 0;

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

        private function drawOverlay(level:Number):void
        {
            var pulseLevel:Number = Math.min(1, level + _pulse + _hitFlash * 0.38);
            var beat:Number = (Math.sin(_phase * 3) + 1) * 0.5;

            updateFlowSprites(pulseLevel, beat);
            updateScanlines(level);

            var g:Graphics = _vectorLayer.graphics;
            g.clear();
            drawGlassHudFrame(g, pulseLevel);
            drawLaneGlass(g, pulseLevel);
            drawLaneEdges(g, 3 + (pulseLevel * 11), 0.12 + (pulseLevel * 0.36), 0.1 + (pulseLevel * 0.3), pulseLevel, beat);
            drawHitFlash(g);
        }

        private function updateFlowSprites(level:Number, beat:Number):void
        {
            var h:Number = Main.GAME_HEIGHT;
            if (level < 0.08)
            {
                _flowLayer.visible = false;
                return;
            }

            var a:Number = (level - 0.08) * (_mode == MODE_FULL ? 0.055 : 0.018);
            var flowW:Number = Math.min(_laneWidth * 0.78, 90 + level * 150);
            var flowH:Number = 16 + beat * 12;
            var centerX:Number = _laneX + _laneWidth * 0.5;
            var topY:Number = Math.max(42, _laneY + 18);
            var bottomY:Number = Math.min(Main.GAME_HEIGHT - 24, _laneY + _laneHeight - 12);

            _flowLayer.visible = true;
            _flowWash.alpha = 0.035 + level * 0.035;

            _floorBand.y = h - 96 - beat * 16 + 30;
            _floorBand.scaleY = (18 + beat * 10) / 60;
            _floorBand.alpha = level * (_mode == MODE_FULL ? 0.025 : 0.01);
            tintSprite(_floorBand, rgbColor(_phase + 1.7));

            for (var i:int = 0; i < FLOW_COUNT; i++)
            {
                var flow:Sprite = _flowSprites[i];
                var depth:Number = ((i / FLOW_COUNT) + ((_phase * (0.5 + level * 1.2)) % 1)) % 1;
                var yPos:Number = topY + ((bottomY - topY) * Math.pow(depth, 1.28));
                var xDrift:Number = Math.sin(_phase * 1.5 + i * 1.72) * _laneWidth * 0.16 * (LANE_TOP_SCALE + ((LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * depth));
                flow.x = centerX + xDrift;
                flow.y = yPos;
                flow.scaleX = (flowW / 340) * (0.68 + depth * 0.36);
                flow.scaleY = (flowH / 100) * (0.76 + depth * 0.22);
                flow.alpha = Math.max(0, a * (0.42 - i * 0.035));
                tintSprite(flow, rgbColor(_phase + i * 1.35));
            }
        }

        private function updateScanlines(level:Number):void
        {
            if (level < 0.3)
            {
                _scanlineLayer.visible = false;
                return;
            }

            _scanlineLayer.visible = true;
            _scanlineLayer.alpha = (level - 0.3) * (_mode == MODE_FULL ? 0.09 : 0.03);
            _scanlineLayer.y = (_phase * 18) % 18;
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
            var top:Number = _laneY;
            var bottom:Number = _laneY + _laneHeight;

            g.beginFill(0xBDEBFF, a);
            g.moveTo(lanePerspectiveX(0, top, 14), top);
            g.lineTo(lanePerspectiveX(1, top, 14), top);
            g.lineTo(lanePerspectiveX(1, bottom, 14), bottom);
            g.lineTo(lanePerspectiveX(0, bottom, 14), bottom);
            g.lineTo(lanePerspectiveX(0, top, 14), top);
            g.endFill();

            g.lineStyle(1, 0xFFFFFF, 0.05 + level * 0.08, true);
            g.moveTo(lanePerspectiveX(0, top + 1, 14), top + 1);
            g.lineTo(lanePerspectiveX(1, top + 1, 14), top + 1);
            g.lineTo(lanePerspectiveX(1, bottom - 1, 14), bottom - 1);
            g.lineTo(lanePerspectiveX(0, bottom - 1, 14), bottom - 1);
            g.lineTo(lanePerspectiveX(0, top + 1, 14), top + 1);
        }

        private function drawLaneEdges(g:Graphics, thickness:Number, edgeAlpha:Number, pillAlpha:Number, level:Number, beat:Number):void
        {
            var top:Number = _laneY;
            var heightValue:Number = _laneHeight;
            var bottom:Number = top + heightValue;
            var segmentHeight:Number = 34 + level * 44;
            var segmentGap:Number = 24 - level * 11;
            var yOffset:Number = (_phase * 36) % (segmentHeight + segmentGap);
            var i:int;
            var y:Number;
            var color:uint;
            var drawY:Number;
            var drawHeight:Number;

            for (i = 0; i < 5; i++)
            {
                color = rgbColor(_phase + i * 1.5);
                g.lineStyle(Math.max(1, thickness - i * 1.15), color, edgeAlpha * (1 - i * 0.16), true);
                g.moveTo(lanePerspectiveX(0, top, i * 3), top);
                g.lineTo(lanePerspectiveX(0, bottom, i * 3), bottom);
                g.moveTo(lanePerspectiveX(1, top, i * 3), top);
                g.lineTo(lanePerspectiveX(1, bottom, i * 3), bottom);
            }

            for (y = top - yOffset; y < top + heightValue; y += segmentHeight + segmentGap)
            {
                drawY = Math.max(top, y);
                drawHeight = Math.min(segmentHeight + beat * 14, top + heightValue - drawY);
                if (drawHeight <= 0)
                    continue;

                color = rgbColor(_phase + y * 0.024);
                g.lineStyle(Math.max(2, thickness * 1.5), color, pillAlpha, true);
                g.moveTo(lanePerspectiveX(0, drawY, thickness * 0.85), drawY);
                g.lineTo(lanePerspectiveX(0, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(1, thickness * 0.42), 0xFFFFFF, pillAlpha * 0.65, true);
                g.moveTo(lanePerspectiveX(0, drawY, thickness * 0.85), drawY);
                g.lineTo(lanePerspectiveX(0, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(2, thickness * 1.5), rgbColor(_phase + y * 0.024 + 1.25), pillAlpha, true);
                g.moveTo(lanePerspectiveX(1, drawY, thickness * 0.85), drawY);
                g.lineTo(lanePerspectiveX(1, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(1, thickness * 0.42), 0xFFFFFF, pillAlpha * 0.65, true);
                g.moveTo(lanePerspectiveX(1, drawY, thickness * 0.85), drawY);
                g.lineTo(lanePerspectiveX(1, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);
            }

            if (level > 0.55)
            {
                var capAlpha:Number = (level - 0.55) * 0.32;
                var capTop:Number = top + 16;
                var capBottom:Number = top + heightValue - 16;
                g.lineStyle(2 + level * 4, rgbColor(_phase + 3), capAlpha, true);
                g.moveTo(lanePerspectiveX(0, capTop), capTop);
                g.lineTo(lanePerspectiveX(1, capTop), capTop);
                g.moveTo(lanePerspectiveX(0, capBottom), capBottom);
                g.lineTo(lanePerspectiveX(1, capBottom), capBottom);
            }
        }

        private function drawHitFlash(g:Graphics):void
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
                spawnParticle(laneCenter + (Math.random() - 0.5) * (_laneWidth * 0.16),
                    y + (Math.random() - 0.5) * (_laneHeight * 0.2),
                    side * (2.1 + Math.random() * 4.8),
                    -3.5 + Math.random() * 7,
                    1,
                    0.055 + Math.random() * 0.035,
                    2.5 + Math.random() * 5.5,
                    color);
            }
        }

        private function spawnParticle(xPos:Number, yPos:Number, vx:Number, vy:Number, life:Number, decay:Number, size:Number, color:uint):void
        {
            var idx:int = nextParticleIndex();
            if (!_particleActive[idx])
                _activeParticles++;

            _particleActive[idx] = true;
            _particleX[idx] = xPos;
            _particleY[idx] = yPos;
            _particleVX[idx] = vx;
            _particleVY[idx] = vy;
            _particleLife[idx] = life;
            _particleDecay[idx] = decay;
            _particleSize[idx] = size;

            var particle:Sprite = _particleSprites[idx];
            particle.visible = true;
            particle.x = xPos;
            particle.y = yPos;
            particle.scaleX = particle.scaleY = size / 6;
            particle.alpha = _mode == MODE_FULL ? 0.72 : 0.36;
            tintSprite(particle, color);
        }

        private function nextParticleIndex():int
        {
            var max:int = maxParticlesForMode();
            var idx:int;
            for (var i:int = 0; i < max; i++)
            {
                idx = (_particleCursor + i) % max;
                if (!_particleActive[idx])
                {
                    _particleCursor = (idx + 1) % max;
                    return idx;
                }
            }

            idx = _particleCursor % max;
            _particleCursor = (_particleCursor + 1) % max;
            return idx;
        }

        private function updateParticles():void
        {
            if (_activeParticles <= 0)
                return;

            var max:int = maxParticlesForMode();
            for (var i:int = 0; i < max; i++)
            {
                if (!_particleActive[i])
                    continue;

                _particleX[i] += _particleVX[i];
                _particleY[i] += _particleVY[i];
                _particleVX[i] *= 0.97;
                _particleVY[i] *= 0.97;
                _particleLife[i] -= _particleDecay[i];

                var particle:Sprite = _particleSprites[i];
                if (_particleLife[i] <= 0)
                {
                    _particleActive[i] = false;
                    particle.visible = false;
                    _activeParticles--;
                    continue;
                }

                particle.x = _particleX[i];
                particle.y = _particleY[i];
                particle.alpha = Math.max(0, _particleLife[i]) * (_mode == MODE_FULL ? 0.72 : 0.36);
                particle.scaleX = particle.scaleY = (_particleSize[i] / 6) * Math.max(0.25, _particleLife[i]);
            }
        }

        private function clearParticles():void
        {
            for (var i:int = 0; i < MAX_PARTICLES; i++)
            {
                _particleActive[i] = false;
                _particleSprites[i].visible = false;
            }
            _activeParticles = 0;
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

            return lanePerspectiveX((idx + 0.5) / 4, _laneY + _laneHeight * 0.5);
        }

        private function lanePerspectiveX(ratio:Number, yPos:Number, gutter:Number = 0):Number
        {
            var center:Number = _laneX + _laneWidth * 0.5;
            var t:Number = (yPos - _laneY) / Math.max(1, _laneHeight);
            if (t < 0)
                t = 0;
            else if (t > 1)
                t = 1;

            var scale:Number = LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
            var gutterOffset:Number = 0;
            if (ratio < 0.5)
                gutterOffset = -gutter;
            else if (ratio > 0.5)
                gutterOffset = gutter;

            return center + ((_laneWidth * (ratio - 0.5) + gutterOffset) * scale);
        }

        private function tintSprite(sprite:Sprite, color:uint):void
        {
            _colorTransform.color = color;
            sprite.transform.colorTransform = _colorTransform;
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
