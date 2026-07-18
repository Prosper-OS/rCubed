package game.controls
{
    import classes.RenderQuality;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;

    public class ComboHypeOverlay extends Sprite
    {
        public static const MODE_FULL:String = "full";
        public static const MODE_REDUCED:String = "reduced";
        public static const MODE_OFF:String = "off";

        private static const MAX_PARTICLES:int = 120;
        private static const MAX_PARTICLES_REDUCED:int = 44;
        private static const LANE_TOP_SCALE:Number = 0.70;
        private static const LANE_BOTTOM_SCALE:Number = 1.00;
        private static const RGB_TABLE_SIZE:int = 256;
        private static var RGB_TABLE:Vector.<uint> = buildRgbTable();

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
        private var _laneEdges:Vector.<Number> = new Vector.<Number>(5, true);
        private var _hasLaneEdges:Boolean = false;
        private var _hasJudgeBounds:Boolean = false;
        private var _judgeX:Number = 0;
        private var _judgeY:Number = 0;
        private var _judgeWidth:Number = 0;
        private var _judgeHeight:Number = 0;

        private var _glassLayer:Sprite;
        private var _vectorLayer:Sprite;
        private var _flashLayer:Sprite;
        private var _particleLayer:Sprite;
        private var _laneGeometryDirty:Boolean = true;
        private var _lastGlassAlpha:Number = -1;

        private var _particleSprites:Vector.<Sprite> = new <Sprite>[];
        private var _particleActive:Vector.<Boolean> = new Vector.<Boolean>(MAX_PARTICLES, true);
        private var _particleActiveIndices:Vector.<int> = new <int>[];
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
            blendMode = BlendMode.NORMAL;
            alpha = 1;

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
                alpha = 1;
                _laneGeometryDirty = true;
                _lastGlassAlpha = -1;
                _glassLayer.graphics.clear();
                _vectorLayer.graphics.clear();
                _flashLayer.graphics.clear();
            }
        }

        public function setLaneBounds(xPos:Number, yPos:Number, laneWidth:Number, laneHeight:Number):void
        {
            var newX:Number = Math.round(xPos * 2) / 2;
            var newY:Number = Math.round(yPos * 2) / 2;
            var newWidth:Number = Math.max(64, Math.round(laneWidth * 2) / 2);
            var newHeight:Number = Math.max(64, Math.round(laneHeight * 2) / 2);

            if (Math.abs(_laneX - newX) <= 0.25 &&
                Math.abs(_laneY - newY) <= 0.25 &&
                Math.abs(_laneWidth - newWidth) <= 0.25 &&
                Math.abs(_laneHeight - newHeight) <= 0.25)
                return;

            _laneX = newX;
            _laneY = newY;
            _laneWidth = newWidth;
            _laneHeight = newHeight;
            _laneGeometryDirty = true;
        }

        public function setLaneEdges(edges:Vector.<Number>):void
        {
            if (!edges || edges.length < 5)
            {
                if (_hasLaneEdges)
                    _laneGeometryDirty = true;

                _hasLaneEdges = false;
                return;
            }

            var changed:Boolean = !_hasLaneEdges;
            var value:Number;
            for (var i:int = 0; i < 5; i++)
            {
                value = Math.round(edges[i] * 2) / 2;
                if (Math.abs(_laneEdges[i] - value) > 0.25)
                    changed = true;

                _laneEdges[i] = value;
            }

            _hasLaneEdges = true;
            if (changed)
                _laneGeometryDirty = true;
        }

        public function setJudgeBounds(bounds:Rectangle):void
        {
            if (!bounds)
            {
                _hasJudgeBounds = false;
                return;
            }

            _hasJudgeBounds = true;
            _judgeX = bounds.x;
            _judgeY = bounds.y;
            _judgeWidth = bounds.width;
            _judgeHeight = bounds.height;
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
            visible = visibleLevel >= 0.015 || _activeParticles > 0;
            updateShake(visibleLevel);

            if (visibleLevel < 0.015 && _activeParticles == 0)
            {
                _glassLayer.graphics.clear();
                _vectorLayer.graphics.clear();
                _flashLayer.graphics.clear();
                _lastGlassAlpha = -1;
                return;
            }

            drawOverlay(visibleLevel);
        }

        private function buildCachedLayers():void
        {
            _glassLayer = createLayer();
            _vectorLayer = createLayer();
            _flashLayer = createLayer();
            _particleLayer = createLayer();

            addChild(_glassLayer);
            addChild(_vectorLayer);
            addChild(_flashLayer);
            addChild(_particleLayer);

            for (var i:int = 0; i < MAX_PARTICLES; i++)
            {
                var particle:Sprite = new Sprite();
                particle.graphics.beginFill(0xFFFFFF, 0.82);
                particle.graphics.drawRect(-1.8, -7, 3.6, 14);
                particle.graphics.endFill();
                particle.graphics.lineStyle(1, 0xFFFFFF, 0.55, true);
                particle.graphics.moveTo(0, -7);
                particle.graphics.lineTo(0, 7);
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

            drawLaneGlass(_glassLayer.graphics, pulseLevel);

            var g:Graphics = _vectorLayer.graphics;
            g.clear();
            drawLaneEdges(g, 3 + (pulseLevel * 11), 0.12 + (pulseLevel * 0.36), 0.1 + (pulseLevel * 0.3), pulseLevel, beat);

            g = _flashLayer.graphics;
            g.clear();
            drawHitFlash(g);
        }

        private function drawLaneGlass(g:Graphics, level:Number):void
        {
            if (!hasLaneBounds())
            {
                g.clear();
                return;
            }

            var a:Number = (_mode == MODE_FULL ? 0.028 : 0.012) + level * (_mode == MODE_FULL ? 0.06 : 0.022);
            if (!_laneGeometryDirty && Math.abs(a - _lastGlassAlpha) < 0.006)
                return;

            g.clear();
            _lastGlassAlpha = a;
            _laneGeometryDirty = false;

            var top:Number = _laneY;
            var bottom:Number = _laneY + _laneHeight;

            g.beginFill(0xBDEBFF, a);
            g.moveTo(laneEdgeX(0, top, 14), top);
            g.lineTo(laneEdgeX(4, top, 14), top);
            g.lineTo(laneEdgeX(4, bottom, 14), bottom);
            g.lineTo(laneEdgeX(0, bottom, 14), bottom);
            g.lineTo(laneEdgeX(0, top, 14), top);
            g.endFill();

            g.lineStyle(1, 0xFFFFFF, 0.05 + level * 0.08, true);
            g.moveTo(laneEdgeX(0, top + 1, 14), top + 1);
            g.lineTo(laneEdgeX(4, top + 1, 14), top + 1);
            g.lineTo(laneEdgeX(4, bottom - 1, 14), bottom - 1);
            g.lineTo(laneEdgeX(0, bottom - 1, 14), bottom - 1);
            g.lineTo(laneEdgeX(0, top + 1, 14), top + 1);
        }

        private function drawLaneEdges(g:Graphics, thickness:Number, edgeAlpha:Number, pillAlpha:Number, level:Number, beat:Number):void
        {
            if (!hasLaneBounds())
                return;

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
                g.moveTo(laneEdgeX(0, top, i * 3), top);
                g.lineTo(laneEdgeX(0, bottom, i * 3), bottom);
                g.moveTo(laneEdgeX(4, top, i * 3), top);
                g.lineTo(laneEdgeX(4, bottom, i * 3), bottom);
            }

            g.lineStyle(1, 0xE7F7FF, Math.min(0.16, 0.035 + level * 0.07), true);
            for (i = 1; i < 4; i++)
            {
                g.moveTo(laneEdgeX(i, top), top);
                g.lineTo(laneEdgeX(i, bottom), bottom);
            }

            for (y = top - yOffset; y < top + heightValue; y += segmentHeight + segmentGap)
            {
                drawY = Math.max(top, y);
                drawHeight = Math.min(segmentHeight + beat * 14, top + heightValue - drawY);
                if (drawHeight <= 0)
                    continue;

                color = rgbColor(_phase + y * 0.024);
                g.lineStyle(Math.max(2, thickness * 1.5), color, pillAlpha, true);
                g.moveTo(laneEdgeX(0, drawY, thickness * 0.85), drawY);
                g.lineTo(laneEdgeX(0, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(1, thickness * 0.42), 0xFFFFFF, pillAlpha * 0.65, true);
                g.moveTo(laneEdgeX(0, drawY, thickness * 0.85), drawY);
                g.lineTo(laneEdgeX(0, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(2, thickness * 1.5), rgbColor(_phase + y * 0.024 + 1.25), pillAlpha, true);
                g.moveTo(laneEdgeX(4, drawY, thickness * 0.85), drawY);
                g.lineTo(laneEdgeX(4, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);

                g.lineStyle(Math.max(1, thickness * 0.42), 0xFFFFFF, pillAlpha * 0.65, true);
                g.moveTo(laneEdgeX(4, drawY, thickness * 0.85), drawY);
                g.lineTo(laneEdgeX(4, drawY + drawHeight, thickness * 0.85), drawY + drawHeight);
            }

            if (level > 0.55)
            {
                var capAlpha:Number = (level - 0.55) * 0.32;
                var capTop:Number = top + 16;
                var capBottom:Number = top + heightValue - 16;
                g.lineStyle(2 + level * 4, rgbColor(_phase + 3), capAlpha, true);
                g.moveTo(laneEdgeX(0, capTop), capTop);
                g.lineTo(laneEdgeX(4, capTop), capTop);
                g.moveTo(laneEdgeX(0, capBottom), capBottom);
                g.lineTo(laneEdgeX(4, capBottom), capBottom);
            }
        }

        private function drawHitFlash(g:Graphics):void
        {
            if (_hitFlash < 0.02 || !hasLaneBounds() || !_hasJudgeBounds)
                return;

            var centerY:Number = _judgeY + _judgeHeight * 0.12;
            var band:Number = Math.max(18, Math.min(44, _judgeHeight * 0.78 + _hitFlash * 10));
            var left:Number = laneEdgeX(0, centerY, 16);
            var right:Number = laneEdgeX(4, centerY, 16);
            var textPad:Number = Math.min(_laneWidth * 0.14, 34);
            var textLeft:Number = _judgeX - textPad;
            var textRight:Number = _judgeX + _judgeWidth + textPad;
            var minWidth:Number = Math.min(_laneWidth * 0.88, Math.max(_judgeWidth * 1.16, _laneWidth * 0.42));
            var centerX:Number = _judgeX + _judgeWidth * 0.5;
            var flashLeft:Number = Math.max(left, Math.min(textLeft, centerX - minWidth * 0.5));
            var flashRight:Number = Math.min(right, Math.max(textRight, centerX + minWidth * 0.5));
            var lineAlpha:Number = _hitFlash * (_mode == MODE_FULL ? 0.32 : 0.11);
            var fillAlpha:Number = _hitFlash * (_mode == MODE_FULL ? 0.18 : 0.06);

            g.beginFill(_hitColor, fillAlpha * 0.45);
            g.drawRect(flashLeft, centerY - band * 0.5, flashRight - flashLeft, band);
            g.endFill();

            g.beginFill(_hitColor, fillAlpha);
            g.drawRect(flashLeft + 8, centerY - band * 0.24, Math.max(0, flashRight - flashLeft - 16), band * 0.48);
            g.endFill();

            g.lineStyle(1 + _hitFlash * 3, 0xFFFFFF, lineAlpha, true);
            g.moveTo(flashLeft, centerY);
            g.lineTo(flashRight, centerY);

            g.lineStyle(1, _hitColor, lineAlpha * 0.58, true);
            g.moveTo(flashLeft + 4, centerY - band * 0.34);
            g.lineTo(flashRight - 4, centerY - band * 0.34);
            g.moveTo(flashLeft + 4, centerY + band * 0.34);
            g.lineTo(flashRight - 4, centerY + band * 0.34);
        }

        private function spawnBurstParticles(score:int, dir:String):void
        {
            if (!hasLaneBounds())
                return;

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
            {
                _activeParticles++;
                _particleActiveIndices[_particleActiveIndices.length] = idx;
            }

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

            for (var listIndex:int = _particleActiveIndices.length - 1; listIndex >= 0; listIndex--)
            {
                var i:int = _particleActiveIndices[listIndex];
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
                    removeActiveParticleIndex(listIndex);
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
            _particleActiveIndices.length = 0;
        }

        private function removeActiveParticleIndex(index:int):void
        {
            var last:int = _particleActiveIndices.length - 1;
            if (index != last)
                _particleActiveIndices[index] = _particleActiveIndices[last];

            _particleActiveIndices.length = last;
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

            return laneRatioX((idx + 0.5) / 4, _laneY + _laneHeight * 0.5);
        }

        private function hasLaneBounds():Boolean
        {
            return _laneWidth > 0 && _laneHeight > 0;
        }

        private function laneEdgeX(index:int, yPos:Number, gutter:Number = 0):Number
        {
            if (!_hasLaneEdges)
                return lanePerspectiveX(index / 4, yPos, gutter);

            if (index < 0)
                index = 0;
            else if (index > 4)
                index = 4;

            var gutterOffset:Number = 0;
            if (index == 0)
                gutterOffset = -gutter;
            else if (index == 4)
                gutterOffset = gutter;

            return laneDepthX(_laneEdges[index], yPos, gutterOffset);
        }

        private function laneRatioX(ratio:Number, yPos:Number, gutter:Number = 0):Number
        {
            if (!_hasLaneEdges)
                return lanePerspectiveX(ratio, yPos, gutter);

            var gutterOffset:Number = 0;
            if (ratio < 0.5)
                gutterOffset = -gutter;
            else if (ratio > 0.5)
                gutterOffset = gutter;

            return laneDepthX(_laneEdges[0] + (_laneEdges[4] - _laneEdges[0]) * ratio, yPos, gutterOffset);
        }

        private function laneDepthX(rawX:Number, yPos:Number, gutterOffset:Number = 0):Number
        {
            var center:Number = (_laneEdges[0] + _laneEdges[4]) * 0.5;
            var t:Number = (yPos - _laneY) / Math.max(1, _laneHeight);
            if (t < 0)
                t = 0;
            else if (t > 1)
                t = 1;

            var scale:Number = LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
            return center + ((rawX - center + gutterOffset) * scale);
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
            var idx:int = int(t * 24) % RGB_TABLE_SIZE;
            if (idx < 0)
                idx += RGB_TABLE_SIZE;

            return RGB_TABLE[idx];
        }

        private static function buildRgbTable():Vector.<uint>
        {
            var table:Vector.<uint> = new Vector.<uint>(RGB_TABLE_SIZE, true);
            for (var i:int = 0; i < RGB_TABLE_SIZE; i++)
            {
                var t:Number = i / 24;
                var r:uint = Math.round((Math.sin(t) * 0.5 + 0.5) * 255);
                var g:uint = Math.round((Math.sin(t + 2.094) * 0.5 + 0.5) * 255);
                var b:uint = Math.round((Math.sin(t + 4.188) * 0.5 + 0.5) * 255);
                table[i] = (r << 16) | (g << 8) | b;
            }
            return table;
        }
    }
}
