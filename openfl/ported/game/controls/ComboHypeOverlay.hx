package game.controls;

import classes.RenderQuality;
import openfl.display.BlendMode;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class ComboHypeOverlay extends Sprite
{
    public static inline var MODE_FULL : String = "full";
    public static inline var MODE_REDUCED : String = "reduced";
    public static inline var MODE_OFF : String = "off";
    
    private static inline var MAX_PARTICLES : Int = 120;
    private static inline var MAX_PARTICLES_REDUCED : Int = 44;
    private static inline var LANE_TOP_SCALE : Float = 0.70;
    private static inline var LANE_BOTTOM_SCALE : Float = 1.00;
    private static inline var RGB_TABLE_SIZE : Int = 256;
    private static var RGB_TABLE : Array<Int> = buildRgbTable();
    
    private var _combo : Int = 0;
    private var _score : Int = 0;
    private var _level : Float = 0;
    private var _pulse : Float = 0;
    private var _phase : Float = 0;
    private var _hitFlash : Float = 0;
    private var _impactBurst : Float = 0;
    private var _impactFlash : Float = 0;
    private var _hitColor : Int = 0xFFFFFF;
    private var _mode : String = MODE_FULL;
    private var _laneX : Float = 0;
    private var _laneY : Float = 0;
    private var _laneWidth : Float = 0;
    private var _laneHeight : Float = 0;
    private var _laneEdges : Array<Float> = new Array<Float>();
    private var _hasLaneEdges : Bool = false;
    private var _hasJudgeBounds : Bool = false;
    private var _judgeX : Float = 0;
    private var _judgeY : Float = 0;
    private var _judgeWidth : Float = 0;
    private var _judgeHeight : Float = 0;
    
    private var _glassLayer : Sprite;
    private var _vectorLayer : Sprite;
    private var _flashLayer : Sprite;
    private var _particleLayer : Sprite;
    private var _laneGeometryDirty : Bool = true;
    private var _lastGlassAlpha : Float = -1;
    
    private var _particleSprites : Array<Sprite> = [];
    private var _particleActive : Array<Bool> = new Array<Bool>();
    private var _particleActiveIndices : Array<Int> = [];
    private var _particleX : Array<Float> = new Array<Float>();
    private var _particleY : Array<Float> = new Array<Float>();
    private var _particleVX : Array<Float> = new Array<Float>();
    private var _particleVY : Array<Float> = new Array<Float>();
    private var _particleLife : Array<Float> = new Array<Float>();
    private var _particleDecay : Array<Float> = new Array<Float>();
    private var _particleSize : Array<Float> = new Array<Float>();
    private var _activeParticles : Int = 0;
    private var _particleCursor : Int = 0;
    private var _colorTransform : ColorTransform = new ColorTransform();
    private var _rgbGradientColors : Array<Dynamic> = [0, 0, 0, 0, 0];
    private var _rgbGradientAlphas : Array<Dynamic> = [1, 1, 1, 1, 1];
    private var _rgbGradientRatios : Array<Dynamic> = [0, 64, 128, 192, 255];
    private var _rgbGradientMatrix : Matrix = new Matrix();
    
    public var shakeX : Float = 0;
    public var shakeY : Float = 0;
    
    public function new(parent : Sprite, mode : String = "full")
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        mouseEnabled = false;
        mouseChildren = false;
        blendMode = BlendMode.NORMAL;
        alpha = 1;
        
        buildCachedLayers();
        setMode(mode);
    }
    
    public function setMode(mode : String) : Void
    {
        if (mode != MODE_REDUCED && mode != MODE_OFF)
        {
            mode = MODE_FULL;
        }
        
        _mode = mode;
        visible = _mode != MODE_OFF;
        if (_mode == MODE_OFF)
        {
            clearParticles();
            _pulse = 0;
            _hitFlash = 0;
            _impactBurst = 0;
            _impactFlash = 0;
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
    
    public function setLaneBounds(xPos : Float, yPos : Float, laneWidth : Float, laneHeight : Float) : Void
    {
        var newX : Float = Math.round(xPos * 2) / 2;
        var newY : Float = Math.round(yPos * 2) / 2;
        var newWidth : Float = Math.max(64, Math.round(laneWidth * 2) / 2);
        var newHeight : Float = Math.max(64, Math.round(laneHeight * 2) / 2);
        
        if (Math.abs(_laneX - newX) <= 0.25 &&
            Math.abs(_laneY - newY) <= 0.25 &&
            Math.abs(_laneWidth - newWidth) <= 0.25 &&
            Math.abs(_laneHeight - newHeight) <= 0.25)
        {
            return;
        }
        
        _laneX = newX;
        _laneY = newY;
        _laneWidth = newWidth;
        _laneHeight = newHeight;
        _laneGeometryDirty = true;
    }
    
    public function setLaneEdges(edges : Array<Float>) : Void
    {
        if (edges == null || edges.length < 5)
        {
            if (_hasLaneEdges)
            {
                _laneGeometryDirty = true;
            }
            
            _hasLaneEdges = false;
            return;
        }
        
        var changed : Bool = !_hasLaneEdges;
        var value : Float;
        for (i in 0...5)
        {
            value = Math.round(edges[i] * 2) / 2;
            if (Math.abs(_laneEdges[i] - value) > 0.25)
            {
                changed = true;
            }
            
            _laneEdges[i] = value;
        }
        
        _hasLaneEdges = true;
        if (changed)
        {
            _laneGeometryDirty = true;
        }
    }
    
    public function setJudgeBounds(bounds : Rectangle) : Void
    {
        if (bounds == null)
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
    
    public function onJudge(combo : Int, score : Int, dir : String = null, impactArrows : Int = 1) : Void
    {
        _combo = Math.max(0, combo);
        _score = score;
        if (impactArrows < 1)
        {
            impactArrows = 1;
        }
        else if (impactArrows > 4)
        {
            impactArrows = 4;
        }
        
        if (_mode == MODE_OFF)
        {
            return;
        }
        
        if (score > 0)
        {
            var scale : Float = modeScale();
            var impact : Float = impactLevel(impactArrows);
            var comboBoost : Float = 1 + Math.min(0.7, _combo / 520);
            _pulse = Math.min(1, _pulse + (0.13 + Math.min(0.32, _combo / 900) + impact * 0.14) * scale);
            _hitFlash = Math.min(1, _hitFlash + (0.44 + impact * 0.34) * scale);
            _impactBurst = Math.min(1.2, Math.max(_impactBurst, impact * comboBoost * scale));
            if (impactArrows >= 3)
            {
                _impactFlash = Math.min(1, Math.max(_impactFlash, ((impactArrows == 4) ? 0.92 : 0.54) * comboBoost * scale));
            }
            else
            {
                _impactFlash = Math.min(0.5, Math.max(_impactFlash, impact * 0.18 * comboBoost * scale));
            }
            _hitColor = scoreColor(score);
            spawnBurstParticles(score, dir, impactArrows);
        }
        else if (score == -10)
        {
            _pulse = 0;
            _hitFlash = Math.min(1, _hitFlash + 0.35 * modeScale());
            _impactBurst = 0;
            _impactFlash = 0;
            _hitColor = 0xFF255D;
        }
    }
    
    public function tick(frame : Int) : Void
    {
        if (_mode == MODE_OFF)
        {
            shakeX = 0;
            shakeY = 0;
            return;
        }
        
        _phase = frame * 0.055;
        
        var target : Float = hypeLevel(_combo) * modeScale();
        _level += (target - _level) * 0.085;
        _pulse *= ((_mode == MODE_FULL) ? 0.9 : 0.84);
        _hitFlash *= ((_mode == MODE_FULL) ? 0.78 : 0.66);
        _impactBurst *= ((_mode == MODE_FULL) ? 0.68 : 0.55);
        _impactFlash *= ((_mode == MODE_FULL) ? 0.6 : 0.48);
        updateParticles();
        
        var visibleLevel : Float = Math.max(Math.max(Math.max(Math.max(_level, _pulse * 0.62), _hitFlash * 0.34), _impactBurst * 0.46), _impactFlash * 0.42);
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
    
    private function buildCachedLayers() : Void
    {
        _glassLayer = createLayer();
        _vectorLayer = createLayer();
        _flashLayer = createLayer();
        _particleLayer = createLayer();
        
        addChild(_glassLayer);
        addChild(_vectorLayer);
        addChild(_flashLayer);
        addChild(_particleLayer);
        
        for (i in 0...MAX_PARTICLES)
        {
            var particle : Sprite = new Sprite();
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
    
    private function createLayer() : Sprite
    {
        var layer : Sprite = new Sprite();
        layer.mouseEnabled = false;
        layer.mouseChildren = false;
        layer.blendMode = BlendMode.ADD;
        return layer;
    }
    
    private function modeScale() : Float
    {
        return (_mode == MODE_REDUCED) ? 0.42 : 1;
    }
    
    private function maxParticlesForMode() : Int
    {
        return (_mode == MODE_REDUCED) ? MAX_PARTICLES_REDUCED : MAX_PARTICLES;
    }
    
    private function hypeLevel(combo : Int) : Float
    {
        if (combo < 12)
        {
            return 0;
        }
        
        if (combo < 64)
        {
            return 0.08 + ((combo - 12) / 52 * 0.2);
        }
        
        if (combo < 160)
        {
            return 0.28 + ((combo - 64) / 96 * 0.22);
        }
        
        if (combo < 320)
        {
            return 0.5 + ((combo - 160) / 160 * 0.28);
        }
        
        return Math.min(1, 0.78 + ((combo - 320) / 560 * 0.22));
    }
    
    private function impactLevel(impactArrows : Int) : Float
    {
        switch (impactArrows)
        {
            case 2:
                return 0.36;
            case 3:
                return 0.66;
            case 4:
                return 1;
            default:
                return 0.18;
        }
    }
    
    private function updateShake(level : Float) : Void
    {
        var maxShake : Float = (_mode == MODE_FULL) ? 7.5 : 2.25;
        var impactShake : Float = _impactBurst * ((_mode == MODE_FULL) ? 10.5 : 3.1);
        var amount : Float = (Math.max(0, level - 0.18) * maxShake) + (_hitFlash * ((_mode == MODE_FULL) ? 3.2 : 1.15)) + impactShake;
        if (amount < 0.08)
        {
            shakeX = 0;
            shakeY = 0;
            return;
        }
        
        var bang : Float = _impactBurst * _impactBurst;
        shakeX = Math.sin(_phase * 15.7) * amount + Math.sin(_phase * 37.1) * amount * (0.2 + bang * 0.18);
        shakeY = Math.cos(_phase * 13.3) * amount * (0.56 + bang * 0.2) + Math.sin(_phase * 29.8) * amount * 0.18;
    }
    
    private function drawOverlay(level : Float) : Void
    {
        var pulseLevel : Float = Math.min(1, level + _pulse + _hitFlash * 0.38);
        var beat : Float = (Math.sin(_phase * 3) + 1) * 0.5;
        
        drawLaneGlass(_glassLayer.graphics, pulseLevel);
        
        var g : Graphics = _vectorLayer.graphics;
        g.clear();
        drawLaneEdges(g, 3 + (pulseLevel * 11), 0.12 + (pulseLevel * 0.36), 0.1 + (pulseLevel * 0.3), pulseLevel, beat);
        
        g = _flashLayer.graphics;
        g.clear();
        drawHitFlash(g);
    }
    
    private function drawLaneGlass(g : Graphics, level : Float) : Void
    {
        if (!hasLaneBounds())
        {
            g.clear();
            return;
        }
        
        var a : Float = ((_mode == MODE_FULL) ? 0.028 : 0.012) + level * ((_mode == MODE_FULL) ? 0.06 : 0.022);
        if (!_laneGeometryDirty && Math.abs(a - _lastGlassAlpha) < 0.006)
        {
            return;
        }
        
        g.clear();
        _lastGlassAlpha = a;
        _laneGeometryDirty = false;
        
        var top : Float = _laneY;
        var bottom : Float = _laneY + _laneHeight;
        
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
    
    private function drawLaneEdges(g : Graphics, thickness : Float, edgeAlpha : Float, pillAlpha : Float, level : Float, beat : Float) : Void
    {
        if (!hasLaneBounds())
        {
            return;
        }
        
        var top : Float = _laneY;
        var heightValue : Float = _laneHeight;
        var bottom : Float = top + heightValue;
        var i : Int;
        
        drawRgbEdgeLine(g, 0, top, bottom, Math.max(2, thickness * 1.85), edgeAlpha * 0.72, _phase, thickness * 1.3);
        drawRgbEdgeLine(g, 4, top, bottom, Math.max(1, thickness * 0.62), edgeAlpha * 1.08, _phase + 0.85, thickness * 0.28);
        drawRgbEdgeLine(g, 4, top, bottom, Math.max(2, thickness * 1.85), edgeAlpha * 0.72, _phase + 2.1, thickness * 1.3);
        drawRgbEdgeLine(g, 0, top, bottom, Math.max(1, thickness * 0.62), edgeAlpha * 1.08, _phase + 2.95, thickness * 0.28);
        
        g.lineStyle(1, 0xE7F7FF, Math.min(0.16, 0.035 + level * 0.07), true);
        for (i in 1...4)
        {
            g.moveTo(laneEdgeX(i, top), top);
            g.lineTo(laneEdgeX(i, bottom), bottom);
        }
        
        drawEdgeSheen(g, 0, top, bottom, Math.max(1, thickness * 0.32), pillAlpha * 0.45, thickness * 0.18);
        drawEdgeSheen(g, 4, top, bottom, Math.max(1, thickness * 0.32), pillAlpha * 0.45, thickness * 0.18);
        
        if (level > 0.55)
        {
            var capAlpha : Float = (level - 0.55) * 0.32;
            var capTop : Float = top + 16;
            var capBottom : Float = top + heightValue - 16;
            drawRgbHorizontalLine(g, capTop, 2 + level * 4, capAlpha, _phase + 3);
            drawRgbHorizontalLine(g, capBottom, 2 + level * 4, capAlpha, _phase + 4.4);
        }
    }
    
    private function drawRgbEdgeLine(g : Graphics, edgeIndex : Int, top : Float, bottom : Float, thickness : Float, alphaValue : Float, phaseOffset : Float, gutter : Float) : Void
    {
        var xTop : Float = laneEdgeX(edgeIndex, top, gutter);
        var xBottom : Float = laneEdgeX(edgeIndex, bottom, gutter);
        var midX : Float = (xTop + xBottom) * 0.5;
        setupRgbGradient(phaseOffset, alphaValue, midX - 48, top, 96, Math.max(1, bottom - top), Math.PI / 2);
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.lineGradientStyle(GradientType.LINEAR, _rgbGradientColors, _rgbGradientAlphas, _rgbGradientRatios, _rgbGradientMatrix);
        g.moveTo(xTop, top);
        g.lineTo(xBottom, bottom);
    }
    
    private function drawEdgeSheen(g : Graphics, edgeIndex : Int, top : Float, bottom : Float, thickness : Float, alphaValue : Float, gutter : Float) : Void
    {
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.moveTo(laneEdgeX(edgeIndex, top, gutter), top);
        g.lineTo(laneEdgeX(edgeIndex, bottom, gutter), bottom);
    }
    
    private function drawRgbHorizontalLine(g : Graphics, yPos : Float, thickness : Float, alphaValue : Float, phaseOffset : Float) : Void
    {
        var left : Float = laneEdgeX(0, yPos);
        var right : Float = laneEdgeX(4, yPos);
        setupRgbGradient(phaseOffset, alphaValue, left, yPos - 24, Math.max(1, right - left), 48, 0);
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.lineGradientStyle(GradientType.LINEAR, _rgbGradientColors, _rgbGradientAlphas, _rgbGradientRatios, _rgbGradientMatrix);
        g.moveTo(left, yPos);
        g.lineTo(right, yPos);
    }
    
    private function setupRgbGradient(phaseOffset : Float, alphaValue : Float, xPos : Float, yPos : Float, widthValue : Float, heightValue : Float, rotation : Float) : Void
    {
        _rgbGradientColors[0] = rgbColor(phaseOffset);
        _rgbGradientColors[1] = rgbColor(phaseOffset + 1.15);
        _rgbGradientColors[2] = rgbColor(phaseOffset + 2.3);
        _rgbGradientColors[3] = rgbColor(phaseOffset + 3.45);
        _rgbGradientColors[4] = rgbColor(phaseOffset + 4.6);
        
        _rgbGradientAlphas[0] = alphaValue * 0.82;
        _rgbGradientAlphas[1] = alphaValue;
        _rgbGradientAlphas[2] = alphaValue * 0.92;
        _rgbGradientAlphas[3] = alphaValue;
        _rgbGradientAlphas[4] = alphaValue * 0.82;
        
        _rgbGradientMatrix.createGradientBox(widthValue, heightValue, rotation, xPos, yPos);
    }
    
    private function drawHitFlash(g : Graphics) : Void
    {
        var flashPower : Float = Math.max(_hitFlash, _impactFlash);
        if (flashPower < 0.02 || !hasLaneBounds() || !_hasJudgeBounds)
        {
            return;
        }
        
        var centerY : Float = _judgeY + _judgeHeight * 0.12;
        var band : Float = Math.max(18, Math.min(58, _judgeHeight * 0.78 + _hitFlash * 10 + _impactFlash * 18));
        var left : Float = laneEdgeX(0, centerY, 16);
        var right : Float = laneEdgeX(4, centerY, 16);
        var textPad : Float = Math.min(_laneWidth * 0.14, 34);
        var textLeft : Float = _judgeX - textPad;
        var textRight : Float = _judgeX + _judgeWidth + textPad;
        var minWidth : Float = Math.min(_laneWidth * 0.88, Math.max(_judgeWidth * 1.16, _laneWidth * 0.42));
        var centerX : Float = _judgeX + _judgeWidth * 0.5;
        var flashLeft : Float = Math.max(left, Math.min(textLeft, centerX - minWidth * 0.5));
        var flashRight : Float = Math.min(right, Math.max(textRight, centerX + minWidth * 0.5));
        var lineAlpha : Float = flashPower * ((_mode == MODE_FULL) ? 0.32 : 0.11);
        var fillAlpha : Float = flashPower * ((_mode == MODE_FULL) ? 0.18 : 0.06);
        
        if (_impactFlash > 0.03)
        {
            var bangAlpha : Float = _impactFlash * ((_mode == MODE_FULL) ? 0.2 : 0.07);
            var bangLeft : Float = laneEdgeX(0, centerY, 22);
            var bangRight : Float = laneEdgeX(4, centerY, 22);
            drawLensBang(g, centerX, centerY, bangLeft, bangRight, band, bangAlpha);
        }
        
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
    
    private function drawLensBang(g : Graphics, centerX : Float, centerY : Float, left : Float, right : Float, band : Float, alphaValue : Float) : Void
    {
        var widthValue : Float = Math.max(1, right - left);
        var flare : Float = _impactFlash;
        var coreWidth : Float = widthValue * (0.18 + flare * 0.1);
        var coreHeight : Float = band * (0.2 + flare * 0.12);
        var streakAlpha : Float = alphaValue * (1 + flare * 0.35);
        
        g.beginFill(0xFFFFFF, alphaValue * 0.62);
        g.drawEllipse(centerX - coreWidth * 0.5, centerY - coreHeight * 0.5, coreWidth, coreHeight);
        g.endFill();
        
        g.beginFill(_hitColor, alphaValue * 0.42);
        g.drawEllipse(centerX - coreWidth * 0.34, centerY - coreHeight * 0.34, coreWidth * 0.68, coreHeight * 0.68);
        g.endFill();
        
        g.lineStyle(1 + flare * 6, 0xFFFFFF, streakAlpha, true);
        g.moveTo(left, centerY);
        g.lineTo(right, centerY);
        
        g.lineStyle(1 + flare * 3, 0x75F6FF, alphaValue * 0.86, true);
        g.moveTo(left + widthValue * 0.08, centerY - band * 0.16);
        g.lineTo(right - widthValue * 0.08, centerY + band * 0.16);
        g.moveTo(left + widthValue * 0.08, centerY + band * 0.16);
        g.lineTo(right - widthValue * 0.08, centerY - band * 0.16);
        
        g.lineStyle(1, 0xFF77E8, alphaValue * 0.48, true);
        g.moveTo(left + widthValue * 0.18, centerY - band * 0.28);
        g.lineTo(right - widthValue * 0.18, centerY - band * 0.28);
        g.moveTo(left + widthValue * 0.18, centerY + band * 0.28);
        g.lineTo(right - widthValue * 0.18, centerY + band * 0.28);
        
        drawGlint(g, centerX, centerY, band * (0.72 + flare * 0.42), alphaValue * 1.1, 0xFFFFFF);
        drawGlint(g, left + widthValue * 0.29, centerY - band * 0.1, band * 0.36, alphaValue * 0.72, 0x75F6FF);
        drawGlint(g, right - widthValue * 0.23, centerY + band * 0.12, band * 0.3, alphaValue * 0.6, 0xFF77E8);
        
        g.beginFill(0xFFFFFF, alphaValue * 0.22);
        g.drawCircle(left + widthValue * 0.16, centerY, band * 0.11);
        g.drawCircle(right - widthValue * 0.14, centerY, band * 0.08);
        g.endFill();
    }
    
    private function drawGlint(g : Graphics, xPos : Float, yPos : Float, size : Float, alphaValue : Float, color : Int) : Void
    {
        var half : Float = size * 0.5;
        var small : Float = size * 0.22;
        
        g.lineStyle(Math.max(1, size * 0.04), color, alphaValue, true);
        g.moveTo(xPos - half, yPos);
        g.lineTo(xPos + half, yPos);
        g.moveTo(xPos, yPos - half);
        g.lineTo(xPos, yPos + half);
        
        g.lineStyle(1, 0xFFFFFF, alphaValue * 0.55, true);
        g.moveTo(xPos - small, yPos - small);
        g.lineTo(xPos + small, yPos + small);
        g.moveTo(xPos - small, yPos + small);
        g.lineTo(xPos + small, yPos - small);
        
        g.beginFill(0xFFFFFF, alphaValue * 0.58);
        g.drawCircle(xPos, yPos, Math.max(1, size * 0.055));
        g.endFill();
    }
    
    private function spawnBurstParticles(score : Int, dir : String, impactArrows : Int = 1) : Void
    {
        if (!hasLaneBounds())
        {
            return;
        }
        
        var impact : Float = impactLevel(impactArrows);
        var count : Int = as3hx.Compat.parseInt(((_mode == MODE_FULL) ? 8 : 3) + impactArrows * ((_mode == MODE_FULL) ? 4 : 1));
        if (_combo > 96)
        {
            count += (_mode == MODE_FULL) ? 7 : 2;
        }
        if (_combo > 260)
        {
            count += (_mode == MODE_FULL) ? 7 : 2;
        }
        
        var laneCenter : Float = laneCenterForDir(dir);
        var y : Float = _laneY + _laneHeight * 0.5;
        var left : Float = laneEdgeX(0, y);
        var right : Float = laneEdgeX(4, y);
        var color : Int = scoreColor(score);
        for (i in 0...count)
        {
            var side : Float = ((i % 2 == 0)) ? -1 : 1;
            var originX : Float = (impactArrows >= 3) ? left + Math.random() * (right - left) : laneCenter + (Math.random() - 0.5) * (_laneWidth * (0.12 + impact * 0.08));
            spawnParticle(originX, 
                    y + (Math.random() - 0.5) * (_laneHeight * (0.14 + impact * 0.12)), 
                    side * (2.1 + Math.random() * (4.2 + impact * 3.8)), 
                    -3.5 + Math.random() * (7 + impact * 4.5), 
                    1, 
                    0.05 + Math.random() * 0.036, 
                    2.5 + Math.random() * (5.5 + impact * 4.5), 
                    color
            );
        }
    }
    
    private function spawnParticle(xPos : Float, yPos : Float, vx : Float, vy : Float, life : Float, decay : Float, size : Float, color : Int) : Void
    {
        var idx : Int = nextParticleIndex();
        if (_particleActive[idx] == null)
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
        
        var particle : Sprite = _particleSprites[idx];
        particle.visible = true;
        particle.x = xPos;
        particle.y = yPos;
        particle.scaleX = particle.scaleY = size / 6;
        particle.alpha = (_mode == MODE_FULL) ? 0.72 : 0.36;
        tintSprite(particle, color);
    }
    
    private function nextParticleIndex() : Int
    {
        var max : Int = maxParticlesForMode();
        var idx : Int;
        for (i in 0...max)
        {
            idx = as3hx.Compat.parseInt((_particleCursor + i) % max);
            if (_particleActive[idx] == null)
            {
                _particleCursor = as3hx.Compat.parseInt((idx + 1) % max);
                return idx;
            }
        }
        
        idx = as3hx.Compat.parseInt(_particleCursor % max);
        _particleCursor = as3hx.Compat.parseInt((_particleCursor + 1) % max);
        return idx;
    }
    
    private function updateParticles() : Void
    {
        if (_activeParticles <= 0)
        {
            return;
        }
        
        var listIndex : Int = as3hx.Compat.parseInt(_particleActiveIndices.length - 1);
        while (listIndex >= 0)
        {
            var i : Int = _particleActiveIndices[listIndex];
            if (_particleActive[i] == null)
            {
                {listIndex--;continue;
                }
            }
            
            _particleX[i] += _particleVX[i];
            _particleY[i] += _particleVY[i];
            _particleVX[i] *= 0.97;
            _particleVY[i] *= 0.97;
            _particleLife[i] -= _particleDecay[i];
            
            var particle : Sprite = _particleSprites[i];
            if (_particleLife[i] <= 0)
            {
                _particleActive[i] = false;
                particle.visible = false;
                _activeParticles--;
                removeActiveParticleIndex(listIndex);
                {listIndex--;continue;
                }
            }
            
            particle.x = _particleX[i];
            particle.y = _particleY[i];
            particle.alpha = Math.max(0, _particleLife[i]) * ((_mode == MODE_FULL) ? 0.72 : 0.36);
            particle.scaleX = particle.scaleY = (_particleSize[i] / 6) * Math.max(0.25, _particleLife[i]);
            listIndex--;
        }
    }
    
    private function clearParticles() : Void
    {
        for (i in 0...MAX_PARTICLES)
        {
            _particleActive[i] = false;
            _particleSprites[i].visible = false;
        }
        _activeParticles = 0;
        as3hx.Compat.setArrayLength(_particleActiveIndices, 0);
    }
    
    private function removeActiveParticleIndex(index : Int) : Void
    {
        var last : Int = as3hx.Compat.parseInt(_particleActiveIndices.length - 1);
        if (index != last)
        {
            _particleActiveIndices[index] = _particleActiveIndices[last];
        }
        
        as3hx.Compat.setArrayLength(_particleActiveIndices, last);
    }
    
    private function laneCenterForDir(dir : String) : Float
    {
        var idx : Int = 1;
        switch (dir)
        {
            case "L":
                idx = 0;
            case "D":
                idx = 1;
            case "U":
                idx = 2;
            case "R":
                idx = 3;
        }
        
        return laneRatioX((idx + 0.5) / 4, _laneY + _laneHeight * 0.5);
    }
    
    private function hasLaneBounds() : Bool
    {
        return _laneWidth > 0 && _laneHeight > 0;
    }
    
    private function laneEdgeX(index : Int, yPos : Float, gutter : Float = 0) : Float
    {
        if (!_hasLaneEdges)
        {
            return lanePerspectiveX(index / 4, yPos, gutter);
        }
        
        if (index < 0)
        {
            index = 0;
        }
        else if (index > 4)
        {
            index = 4;
        }
        
        var gutterOffset : Float = 0;
        if (index == 0)
        {
            gutterOffset = -gutter;
        }
        else if (index == 4)
        {
            gutterOffset = gutter;
        }
        
        return laneDepthX(_laneEdges[index], yPos, gutterOffset);
    }
    
    private function laneRatioX(ratio : Float, yPos : Float, gutter : Float = 0) : Float
    {
        if (!_hasLaneEdges)
        {
            return lanePerspectiveX(ratio, yPos, gutter);
        }
        
        var gutterOffset : Float = 0;
        if (ratio < 0.5)
        {
            gutterOffset = -gutter;
        }
        else if (ratio > 0.5)
        {
            gutterOffset = gutter;
        }
        
        return laneDepthX(_laneEdges[0] + (_laneEdges[4] - _laneEdges[0]) * ratio, yPos, gutterOffset);
    }
    
    private function laneDepthX(rawX : Float, yPos : Float, gutterOffset : Float = 0) : Float
    {
        var center : Float = (_laneEdges[0] + _laneEdges[4]) * 0.5;
        var t : Float = (yPos - _laneY) / Math.max(1, _laneHeight);
        if (t < 0)
        {
            t = 0;
        }
        else if (t > 1)
        {
            t = 1;
        }
        
        var scale : Float = LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
        return center + ((rawX - center + gutterOffset) * scale);
    }
    
    private function lanePerspectiveX(ratio : Float, yPos : Float, gutter : Float = 0) : Float
    {
        var center : Float = _laneX + _laneWidth * 0.5;
        var t : Float = (yPos - _laneY) / Math.max(1, _laneHeight);
        if (t < 0)
        {
            t = 0;
        }
        else if (t > 1)
        {
            t = 1;
        }
        
        var scale : Float = LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
        var gutterOffset : Float = 0;
        if (ratio < 0.5)
        {
            gutterOffset = -gutter;
        }
        else if (ratio > 0.5)
        {
            gutterOffset = gutter;
        }
        
        return center + ((_laneWidth * (ratio - 0.5) + gutterOffset) * scale);
    }
    
    private function tintSprite(sprite : Sprite, color : Int) : Void
    {
        _colorTransform.color = color;
        sprite.transform.colorTransform = _colorTransform;
    }
    
    private function scoreColor(score : Int) : Int
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
    
    private function rgbColor(t : Float) : Int
    {
        var idx : Int = as3hx.Compat.parseInt(as3hx.Compat.parseInt(t * 24) % RGB_TABLE_SIZE);
        if (idx < 0)
        {
            idx += RGB_TABLE_SIZE;
        }
        
        return RGB_TABLE[idx];
    }
    
    private static function buildRgbTable() : Array<Int>
    {
        var table : Array<Int> = new Array<Int>();
        for (i in 0...RGB_TABLE_SIZE)
        {
            var t : Float = i / 24;
            var r : Int = Math.round((Math.sin(t) * 0.5 + 0.5) * 255);
            var g : Int = Math.round((Math.sin(t + 2.094) * 0.5 + 0.5) * 255);
            var b : Int = Math.round((Math.sin(t + 4.188) * 0.5 + 0.5) * 255);
            table[i] = (r << 16) | (g << 8) | b;
        }
        return table;
    }
}

