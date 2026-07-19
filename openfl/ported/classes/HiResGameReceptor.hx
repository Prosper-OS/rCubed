package classes;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.ColorTransform;

class HiResGameReceptor extends GameReceptor
{
    private var _hiResNote : Sprite;
    private var _hitNote : Sprite;
    private var _hitColorTransform : ColorTransform = new ColorTransform();
    private var _animationFrame : Int = 0;
    private var _animationActive : Bool = false;
    
    public function new(dir : String, receptorWidth : Float = 64, receptorHeight : Float = 64)
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
    
    override public function playAnimation(color : Int) : Void
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
    
    private function updateAnimation(e : Event) : Void
    {
        _animationFrame++;
        
        var settle : Float = Math.min(1, _animationFrame / Math.max(1, Math.round(3 / animationSpeed)));
        var scale : Float = 1.18 - (0.18 * settle);
        _hiResNote.scaleX = _hiResNote.scaleY = scale;
        _hitNote.scaleX = _hitNote.scaleY = scale;
        
        var fade : Float = Math.min(1, _animationFrame / Math.max(1, Math.round(13 / animationSpeed)));
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
    
    public function playScoreAnimation(score : Int, configuredColor : Int) : Void
    {
        var color : Int = configuredColor;
        switch (score)
        {
            case 100:
                color = 0x1FFBFF;
            case 50:
                color = 0xFFFFFF;
            case 25:
                color = 0x58FF65;
            case 5:
                color = 0xFFE347;
            case -5:
                color = 0xFF8F2A;
            case -10:
                color = 0xFF255D;
        }
        playAnimation(color);
    }
    
    override public function dispose() : Void
    {
        removeEventListener(Event.ENTER_FRAME, updateAnimation);
        
        if (_hiResNote != null && contains(_hiResNote))
        {
            removeChild(_hiResNote);
        }
        if (_hitNote != null && contains(_hitNote))
        {
            removeChild(_hitNote);
        }
        
        _hiResNote = null;
        _hitNote = null;
        super.dispose();
    }
    
    private static function transparentBitmap() : BitmapData
    {
        return new BitmapData(RenderQuality.SUPERSAMPLE_SCALE, RenderQuality.SUPERSAMPLE_SCALE, true, 0);
    }
}

