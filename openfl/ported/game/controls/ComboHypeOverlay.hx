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
    public static inline var MODE_FULL                       : Dynamic= "full";
    public static inline var MODE_REDUCED                       : Dynamic= "reduced";
    public static inline var MODE_OFF                       : Dynamic= "off";
    
    private static inline var MAX_PARTICLES                       : Dynamic= 120;
    private static inline var MAX_PARTICLES_REDUCED                       : Dynamic= 44;
    private static inline var LANE_TOP_SCALE                       : Dynamic= 0.70;
    private static inline var LANE_BOTTOM_SCALE                       : Dynamic= 1.00;
    private static inline var RGB_TABLE_SIZE                       : Dynamic= 256;
    private static var RGB_TABLE                       : Dynamic= buildRgbTable();
    
    private var _combo                       : Dynamic= 0;
    private var _score                       : Dynamic= 0;
    private var _level                       : Dynamic= 0;
    private var _pulse                       : Dynamic= 0;
    private var _phase                       : Dynamic= 0;
    private var _hitFlash                       : Dynamic= 0;
    private var _impactBurst                       : Dynamic= 0;
    private var _impactFlash                       : Dynamic= 0;
    private var _hitColor                       : Dynamic= 0xFFFFFF;
    private var _mode                       : Dynamic= MODE_FULL;
    private var _laneX                       : Dynamic= 0;
    private var _laneY                       : Dynamic= 0;
    private var _laneWidth                       : Dynamic= 0;
    private var _laneHeight                       : Dynamic= 0;
    private var _laneEdges                       : Dynamic= new Array<Float>();
    private var _hasLaneEdges                       : Dynamic= false;
    private var _hasJudgeBounds                       : Dynamic= false;
    private var _judgeX                       : Dynamic= 0;
    private var _judgeY                       : Dynamic= 0;
    private var _judgeWidth                       : Dynamic= 0;
    private var _judgeHeight                       : Dynamic= 0;
    
    private var _glassLayer                       : Dynamic;
    private var _vectorLayer                       : Dynamic;
    private var _flashLayer                       : Dynamic;
    private var _particleLayer                       : Dynamic;
    private var _laneGeometryDirty                       : Dynamic= true;
    private var _lastGlassAlpha                       : Dynamic= -1;
    
    private var _particleSprites                       : Dynamic= [];
    private var _particleActive                       : Dynamic= new Array<Bool>();
    private var _particleActiveIndices                       : Dynamic= [];
    private var _particleX                       : Dynamic= new Array<Float>();
    private var _particleY                       : Dynamic= new Array<Float>();
    private var _particleVX                       : Dynamic= new Array<Float>();
    private var _particleVY                       : Dynamic= new Array<Float>();
    private var _particleLife                       : Dynamic= new Array<Float>();
    private var _particleDecay                       : Dynamic= new Array<Float>();
    private var _particleSize                       : Dynamic= new Array<Float>();
    private var _activeParticles                       : Dynamic= 0;
    private var _particleCursor                       : Dynamic= 0;
    private var _colorTransform                       : Dynamic= new ColorTransform();
    private var _rgbGradientColors                       : Dynamic= [0, 0, 0, 0, 0];
    private var _rgbGradientAlphas                       : Dynamic= [1, 1, 1, 1, 1];
    private var _rgbGradientRatios                       : Dynamic= [0, 64, 128, 192, 255];
    private var _rgbGradientMatrix                       : Dynamic= new Matrix();
    
    public var shakeX                       : Dynamic= 0;
    public var shakeY                       : Dynamic= 0;
    
    public function new(parent                       : Dynamic, mode                       : Dynamic= "full")
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
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
    
    public function setMode(mode                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(mode != MODE_REDUCED && mode != MODE_OFF))
        {
            mode = MODE_FULL;
        }
        
        _mode = mode;
        visible = _mode != MODE_OFF;
        if (as3hx.Compat.truthy(_mode == MODE_OFF))
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
    
    public function setLaneBounds(xPos                       : Dynamic, yPos                       : Dynamic, laneWidth                       : Dynamic, laneHeight                       : Dynamic) : Void
    {
        var newX                       : Dynamic= Math.round(xPos * 2) / 2;
        var newY                       : Dynamic= Math.round(yPos * 2) / 2;
        var newWidth                       : Dynamic= Math.max(64, Math.round(laneWidth * 2) / 2);
        var newHeight                       : Dynamic= Math.max(64, Math.round(laneHeight * 2) / 2);
        
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
    
    public function setLaneEdges(edges                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(edges == null || edges.length < 5))
        {
            if (as3hx.Compat.truthy(_hasLaneEdges))
            {
                _laneGeometryDirty = true;
            }
            
            _hasLaneEdges = false;
            return;
        }
        
        var changed                       : Dynamic= !_hasLaneEdges;
        var value                       : Dynamic= null;
        for (i in 0...5)
        {
            value = Math.round(edges[i] * 2) / 2;
            if (as3hx.Compat.truthy(Math.abs(_laneEdges[i] - value) > 0.25))
            {
                changed = true;
            }
            
            _laneEdges[i] = value;
        }
        
        _hasLaneEdges = true;
        if (as3hx.Compat.truthy(changed))
        {
            _laneGeometryDirty = true;
        }
    }
    
    public function setJudgeBounds(bounds                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(bounds == null))
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
    
    public function onJudge(combo                       : Dynamic, score                       : Dynamic, dir                       : Dynamic= null, impactArrows                       : Dynamic= 1) : Void
    {
        _combo = Math.max(0, combo);
        _score = score;
        if (as3hx.Compat.truthy(impactArrows < 1))
        {
            impactArrows = 1;
        }
        else if (as3hx.Compat.truthy(impactArrows > 4))
        {
            impactArrows = 4;
        }
        
        if (as3hx.Compat.truthy(_mode == MODE_OFF))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(score > 0))
        {
            var scale                       : Dynamic= modeScale();
            var impact                       : Dynamic= impactLevel(impactArrows);
            var comboBoost                       : Dynamic= 1 + Math.min(0.7, _combo / 520);
            _pulse = Math.min(1, _pulse + (0.13 + Math.min(0.32, _combo / 900) + impact * 0.14) * scale);
            _hitFlash = Math.min(1, _hitFlash + (0.44 + impact * 0.34) * scale);
            _impactBurst = Math.min(1.2, Math.max(_impactBurst, impact * comboBoost * scale));
            if (as3hx.Compat.truthy(impactArrows >= 3))
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
        else if (as3hx.Compat.truthy(score == -10))
        {
            _pulse = 0;
            _hitFlash = Math.min(1, _hitFlash + 0.35 * modeScale());
            _impactBurst = 0;
            _impactFlash = 0;
            _hitColor = 0xFF255D;
        }
    }
    
    public function tick(frame                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(_mode == MODE_OFF))
        {
            shakeX = 0;
            shakeY = 0;
            return;
        }
        
        _phase = frame * 0.055;
        
        var target                       : Dynamic= hypeLevel(_combo) * modeScale();
        _level += (target - _level) * 0.085;
        _pulse *= ((_mode == MODE_FULL) ? 0.9 : 0.84);
        _hitFlash *= ((_mode == MODE_FULL) ? 0.78 : 0.66);
        _impactBurst *= ((_mode == MODE_FULL) ? 0.68 : 0.55);
        _impactFlash *= ((_mode == MODE_FULL) ? 0.6 : 0.48);
        updateParticles();
        
        var visibleLevel                       : Dynamic= Math.max(Math.max(Math.max(Math.max(_level, _pulse * 0.62), _hitFlash * 0.34), _impactBurst * 0.46), _impactFlash * 0.42);
        visible = as3hx.Compat.orValue(visibleLevel >= 0.015, _activeParticles > 0);
        updateShake(visibleLevel);
        
        if (as3hx.Compat.truthy(visibleLevel < 0.015 && _activeParticles == 0))
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
            var particle                       : Dynamic= new Sprite();
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
        var layer                       : Dynamic= new Sprite();
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
    
    private function hypeLevel(combo                       : Dynamic) : Float
    {
        if (as3hx.Compat.truthy(combo < 12))
        {
            return 0;
        }
        
        if (as3hx.Compat.truthy(combo < 64))
        {
            return 0.08 + ((combo - 12) / 52 * 0.2);
        }
        
        if (as3hx.Compat.truthy(combo < 160))
        {
            return 0.28 + ((combo - 64) / 96 * 0.22);
        }
        
        if (as3hx.Compat.truthy(combo < 320))
        {
            return 0.5 + ((combo - 160) / 160 * 0.28);
        }
        
        return Math.min(1, 0.78 + ((combo - 320) / 560 * 0.22));
    }
    
    private function impactLevel(impactArrows                       : Dynamic) : Float
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
    
    private function updateShake(level                       : Dynamic) : Void
    {
        var maxShake                       : Dynamic= (_mode == MODE_FULL) ? 7.5 : 2.25;
        var impactShake                       : Dynamic= _impactBurst * ((_mode == MODE_FULL) ? 10.5 : 3.1);
        var amount                       : Dynamic= (Math.max(0, level - 0.18) * maxShake) + (_hitFlash * ((_mode == MODE_FULL) ? 3.2 : 1.15)) + impactShake;
        if (as3hx.Compat.truthy(amount < 0.08))
        {
            shakeX = 0;
            shakeY = 0;
            return;
        }
        
        var bang                       : Dynamic= _impactBurst * _impactBurst;
        shakeX = Math.sin(_phase * 15.7) * amount + Math.sin(_phase * 37.1) * amount * (0.2 + bang * 0.18);
        shakeY = Math.cos(_phase * 13.3) * amount * (0.56 + bang * 0.2) + Math.sin(_phase * 29.8) * amount * 0.18;
    }
    
    private function drawOverlay(level                       : Dynamic) : Void
    {
        var pulseLevel                       : Dynamic= Math.min(1, level + _pulse + _hitFlash * 0.38);
        var beat                       : Dynamic= (Math.sin(_phase * 3) + 1) * 0.5;
        
        drawLaneGlass(_glassLayer.graphics, pulseLevel);
        
        var g                       : Dynamic= _vectorLayer.graphics;
        g.clear();
        drawLaneEdges(g, 3 + (pulseLevel * 11), 0.12 + (pulseLevel * 0.36), 0.1 + (pulseLevel * 0.3), pulseLevel, beat);
        
        g = _flashLayer.graphics;
        g.clear();
        drawHitFlash(g);
    }
    
    private function drawLaneGlass(g                       : Dynamic, level                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!hasLaneBounds()))
        {
            g.clear();
            return;
        }
        
        var a                       : Dynamic= ((_mode == MODE_FULL) ? 0.028 : 0.012) + level * ((_mode == MODE_FULL) ? 0.06 : 0.022);
        if (as3hx.Compat.truthy(!_laneGeometryDirty && Math.abs(a - _lastGlassAlpha) < 0.006))
        {
            return;
        }
        
        g.clear();
        _lastGlassAlpha = a;
        _laneGeometryDirty = false;
        
        var top                       : Dynamic= _laneY;
        var bottom                       : Dynamic= _laneY + _laneHeight;
        
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
    
    private function drawLaneEdges(g                       : Dynamic, thickness                       : Dynamic, edgeAlpha                       : Dynamic, pillAlpha                       : Dynamic, level                       : Dynamic, beat                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!hasLaneBounds()))
        {
            return;
        }
        
        var top                       : Dynamic= _laneY;
        var heightValue                       : Dynamic= _laneHeight;
        var bottom                       : Dynamic= top + heightValue;
        var i                       : Dynamic= null;
        
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
        
        if (as3hx.Compat.truthy(level > 0.55))
        {
            var capAlpha                       : Dynamic= (level - 0.55) * 0.32;
            var capTop                       : Dynamic= top + 16;
            var capBottom                       : Dynamic= top + heightValue - 16;
            drawRgbHorizontalLine(g, capTop, 2 + level * 4, capAlpha, _phase + 3);
            drawRgbHorizontalLine(g, capBottom, 2 + level * 4, capAlpha, _phase + 4.4);
        }
    }
    
    private function drawRgbEdgeLine(g                       : Dynamic, edgeIndex                       : Dynamic, top                       : Dynamic, bottom                       : Dynamic, thickness                       : Dynamic, alphaValue                       : Dynamic, phaseOffset                       : Dynamic, gutter                       : Dynamic) : Void
    {
        var xTop                       : Dynamic= laneEdgeX(edgeIndex, top, gutter);
        var xBottom                       : Dynamic= laneEdgeX(edgeIndex, bottom, gutter);
        var midX                       : Dynamic= (xTop + xBottom) * 0.5;
        setupRgbGradient(phaseOffset, alphaValue, midX - 48, top, 96, Math.max(1, bottom - top), Math.PI / 2);
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.lineGradientStyle(GradientType.LINEAR, _rgbGradientColors, _rgbGradientAlphas, _rgbGradientRatios, _rgbGradientMatrix);
        g.moveTo(xTop, top);
        g.lineTo(xBottom, bottom);
    }
    
    private function drawEdgeSheen(g                       : Dynamic, edgeIndex                       : Dynamic, top                       : Dynamic, bottom                       : Dynamic, thickness                       : Dynamic, alphaValue                       : Dynamic, gutter                       : Dynamic) : Void
    {
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.moveTo(laneEdgeX(edgeIndex, top, gutter), top);
        g.lineTo(laneEdgeX(edgeIndex, bottom, gutter), bottom);
    }
    
    private function drawRgbHorizontalLine(g                       : Dynamic, yPos                       : Dynamic, thickness                       : Dynamic, alphaValue                       : Dynamic, phaseOffset                       : Dynamic) : Void
    {
        var left                       : Dynamic= laneEdgeX(0, yPos);
        var right                       : Dynamic= laneEdgeX(4, yPos);
        setupRgbGradient(phaseOffset, alphaValue, left, yPos - 24, Math.max(1, right - left), 48, 0);
        g.lineStyle(thickness, 0xFFFFFF, alphaValue, true, "normal", CapsStyle.NONE);
        g.lineGradientStyle(GradientType.LINEAR, _rgbGradientColors, _rgbGradientAlphas, _rgbGradientRatios, _rgbGradientMatrix);
        g.moveTo(left, yPos);
        g.lineTo(right, yPos);
    }
    
    private function setupRgbGradient(phaseOffset                       : Dynamic, alphaValue                       : Dynamic, xPos                       : Dynamic, yPos                       : Dynamic, widthValue                       : Dynamic, heightValue                       : Dynamic, rotation                       : Dynamic) : Void
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
    
    private function drawHitFlash(g                       : Dynamic) : Void
    {
        var flashPower                       : Dynamic= Math.max(_hitFlash, _impactFlash);
        if (as3hx.Compat.truthy(flashPower < 0.02 || !hasLaneBounds() || !_hasJudgeBounds))
        {
            return;
        }
        
        var centerY                       : Dynamic= _judgeY + _judgeHeight * 0.12;
        var band                       : Dynamic= Math.max(18, Math.min(58, _judgeHeight * 0.78 + _hitFlash * 10 + _impactFlash * 18));
        var left                       : Dynamic= laneEdgeX(0, centerY, 16);
        var right                       : Dynamic= laneEdgeX(4, centerY, 16);
        var textPad                       : Dynamic= Math.min(_laneWidth * 0.14, 34);
        var textLeft                       : Dynamic= _judgeX - textPad;
        var textRight                       : Dynamic= _judgeX + _judgeWidth + textPad;
        var minWidth                       : Dynamic= Math.min(_laneWidth * 0.88, Math.max(_judgeWidth * 1.16, _laneWidth * 0.42));
        var centerX                       : Dynamic= _judgeX + _judgeWidth * 0.5;
        var flashLeft                       : Dynamic= Math.max(left, Math.min(textLeft, centerX - minWidth * 0.5));
        var flashRight                       : Dynamic= Math.min(right, Math.max(textRight, centerX + minWidth * 0.5));
        var lineAlpha                       : Dynamic= flashPower * ((_mode == MODE_FULL) ? 0.32 : 0.11);
        var fillAlpha                       : Dynamic= flashPower * ((_mode == MODE_FULL) ? 0.18 : 0.06);
        
        if (as3hx.Compat.truthy(_impactFlash > 0.03))
        {
            var bangAlpha                       : Dynamic= _impactFlash * ((_mode == MODE_FULL) ? 0.2 : 0.07);
            var bangLeft                       : Dynamic= laneEdgeX(0, centerY, 22);
            var bangRight                       : Dynamic= laneEdgeX(4, centerY, 22);
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
    
    private function drawLensBang(g                       : Dynamic, centerX                       : Dynamic, centerY                       : Dynamic, left                       : Dynamic, right                       : Dynamic, band                       : Dynamic, alphaValue                       : Dynamic) : Void
    {
        var widthValue                       : Dynamic= Math.max(1, right - left);
        var flare                       : Dynamic= _impactFlash;
        var coreWidth                       : Dynamic= widthValue * (0.18 + flare * 0.1);
        var coreHeight                       : Dynamic= band * (0.2 + flare * 0.12);
        var streakAlpha                       : Dynamic= alphaValue * (1 + flare * 0.35);
        
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
    
    private function drawGlint(g                       : Dynamic, xPos                       : Dynamic, yPos                       : Dynamic, size                       : Dynamic, alphaValue                       : Dynamic, color                       : Dynamic) : Void
    {
        var half                       : Dynamic= size * 0.5;
        var small                       : Dynamic= size * 0.22;
        
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
    
    private function spawnBurstParticles(score                       : Dynamic, dir                       : Dynamic, impactArrows                       : Dynamic= 1) : Void
    {
        if (as3hx.Compat.truthy(!hasLaneBounds()))
        {
            return;
        }
        
        var impact                       : Dynamic= impactLevel(impactArrows);
        var count                       : Dynamic= as3hx.Compat.parseInt(((_mode == MODE_FULL) ? 8 : 3) + impactArrows * ((_mode == MODE_FULL) ? 4 : 1));
        if (as3hx.Compat.truthy(_combo > 96))
        {
            count += (_mode == MODE_FULL) ? 7 : 2;
        }
        if (as3hx.Compat.truthy(_combo > 260))
        {
            count += (_mode == MODE_FULL) ? 7 : 2;
        }
        
        var laneCenter                       : Dynamic= laneCenterForDir(dir);
        var y                       : Dynamic= _laneY + _laneHeight * 0.5;
        var left                       : Dynamic= laneEdgeX(0, y);
        var right                       : Dynamic= laneEdgeX(4, y);
        var color                       : Dynamic= scoreColor(score);
        for (i in 0...count)
        {
            var side                       : Dynamic= ((i % 2 == 0)) ? -1 : 1;
            var originX                       : Dynamic= (impactArrows >= 3) ? left + Math.random() * (right - left) : laneCenter + (Math.random() - 0.5) * (_laneWidth * (0.12 + impact * 0.08));
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
    
    private function spawnParticle(xPos                       : Dynamic, yPos                       : Dynamic, vx                       : Dynamic, vy                       : Dynamic, life                       : Dynamic, decay                       : Dynamic, size                       : Dynamic, color                       : Dynamic) : Void
    {
        var idx                       : Dynamic= nextParticleIndex();
        if (as3hx.Compat.truthy(_particleActive[idx] == null))
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
        
        var particle                       : Dynamic= _particleSprites[idx];
        particle.visible = true;
        particle.x = xPos;
        particle.y = yPos;
        particle.scaleX = particle.scaleY = size / 6;
        particle.alpha = (_mode == MODE_FULL) ? 0.72 : 0.36;
        tintSprite(particle, color);
    }
    
    private function nextParticleIndex() : Int
    {
        var max                       : Dynamic= maxParticlesForMode();
        var idx                       : Dynamic= null;
        for (i in 0...max)
        {
            idx = as3hx.Compat.parseInt((_particleCursor + i) % max);
            if (as3hx.Compat.truthy(_particleActive[idx] == null))
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
        if (as3hx.Compat.truthy(_activeParticles <= 0))
        {
            return;
        }
        
        var listIndex                       : Dynamic= as3hx.Compat.parseInt(_particleActiveIndices.length - 1);
        while (as3hx.Compat.truthy(listIndex >= 0))
        {
            var i                       : Dynamic= _particleActiveIndices[listIndex];
            if (as3hx.Compat.truthy(_particleActive[i] == null))
            {
                {listIndex--;continue;
                }
            }
            
            _particleX[i] += _particleVX[i];
            _particleY[i] += _particleVY[i];
            _particleVX[i] *= 0.97;
            _particleVY[i] *= 0.97;
            _particleLife[i] -= _particleDecay[i];
            
            var particle                       : Dynamic= _particleSprites[i];
            if (as3hx.Compat.truthy(_particleLife[i] <= 0))
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
    
    private function removeActiveParticleIndex(index                       : Dynamic) : Void
    {
        var last                       : Dynamic= as3hx.Compat.parseInt(_particleActiveIndices.length - 1);
        if (as3hx.Compat.truthy(index != last))
        {
            _particleActiveIndices[index] = _particleActiveIndices[last];
        }
        
        as3hx.Compat.setArrayLength(_particleActiveIndices, last);
    }
    
    private function laneCenterForDir(dir                       : Dynamic) : Float
    {
        var idx                       : Dynamic= 1;
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
    
    private function laneEdgeX(index                       : Dynamic, yPos                       : Dynamic, gutter                       : Dynamic= 0) : Float
    {
        if (as3hx.Compat.truthy(!_hasLaneEdges))
        {
            return lanePerspectiveX(index / 4, yPos, gutter);
        }
        
        if (as3hx.Compat.truthy(index < 0))
        {
            index = 0;
        }
        else if (as3hx.Compat.truthy(index > 4))
        {
            index = 4;
        }
        
        var gutterOffset                       : Dynamic= 0;
        if (as3hx.Compat.truthy(index == 0))
        {
            gutterOffset = -gutter;
        }
        else if (as3hx.Compat.truthy(index == 4))
        {
            gutterOffset = gutter;
        }
        
        return laneDepthX(_laneEdges[index], yPos, gutterOffset);
    }
    
    private function laneRatioX(ratio                       : Dynamic, yPos                       : Dynamic, gutter                       : Dynamic= 0) : Float
    {
        if (as3hx.Compat.truthy(!_hasLaneEdges))
        {
            return lanePerspectiveX(ratio, yPos, gutter);
        }
        
        var gutterOffset                       : Dynamic= 0;
        if (as3hx.Compat.truthy(ratio < 0.5))
        {
            gutterOffset = -gutter;
        }
        else if (as3hx.Compat.truthy(ratio > 0.5))
        {
            gutterOffset = gutter;
        }
        
        return laneDepthX(_laneEdges[0] + (_laneEdges[4] - _laneEdges[0]) * ratio, yPos, gutterOffset);
    }
    
    private function laneDepthX(rawX                       : Dynamic, yPos                       : Dynamic, gutterOffset                       : Dynamic= 0) : Float
    {
        var center                       : Dynamic= (_laneEdges[0] + _laneEdges[4]) * 0.5;
        var t                       : Dynamic= (yPos - _laneY) / Math.max(1, _laneHeight);
        if (as3hx.Compat.truthy(t < 0))
        {
            t = 0;
        }
        else if (as3hx.Compat.truthy(t > 1))
        {
            t = 1;
        }
        
        var scale                       : Dynamic= LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
        return center + ((rawX - center + gutterOffset) * scale);
    }
    
    private function lanePerspectiveX(ratio                       : Dynamic, yPos                       : Dynamic, gutter                       : Dynamic= 0) : Float
    {
        var center                       : Dynamic= _laneX + _laneWidth * 0.5;
        var t                       : Dynamic= (yPos - _laneY) / Math.max(1, _laneHeight);
        if (as3hx.Compat.truthy(t < 0))
        {
            t = 0;
        }
        else if (as3hx.Compat.truthy(t > 1))
        {
            t = 1;
        }
        
        var scale                       : Dynamic= LANE_TOP_SCALE + (LANE_BOTTOM_SCALE - LANE_TOP_SCALE) * t;
        var gutterOffset                       : Dynamic= 0;
        if (as3hx.Compat.truthy(ratio < 0.5))
        {
            gutterOffset = -gutter;
        }
        else if (as3hx.Compat.truthy(ratio > 0.5))
        {
            gutterOffset = gutter;
        }
        
        return center + ((_laneWidth * (ratio - 0.5) + gutterOffset) * scale);
    }
    
    private function tintSprite(sprite                       : Dynamic, color                       : Dynamic) : Void
    {
        _colorTransform.color = color;
        sprite.transform.colorTransform = _colorTransform;
    }
    
    private function scoreColor(score                       : Dynamic) : Int
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
    
    private function rgbColor(t                       : Dynamic) : Int
    {
        var idx                       : Dynamic= as3hx.Compat.parseInt(as3hx.Compat.parseInt(t * 24) % RGB_TABLE_SIZE);
        if (as3hx.Compat.truthy(idx < 0))
        {
            idx += RGB_TABLE_SIZE;
        }
        
        return RGB_TABLE[idx];
    }
    
    private static function buildRgbTable() : Array<Int>
    {
        var table                       : Dynamic= new Array<Int>();
        for (i in 0...RGB_TABLE_SIZE)
        {
            var t                       : Dynamic= i / 24;
            var r                       : Dynamic= Math.round((Math.sin(t) * 0.5 + 0.5) * 255);
            var g                       : Dynamic= Math.round((Math.sin(t + 2.094) * 0.5 + 0.5) * 255);
            var b                       : Dynamic= Math.round((Math.sin(t + 4.188) * 0.5 + 0.5) * 255);
            table[i] = (r << 16) | (g << 8) | b;
        }
        return table;
    }
}

