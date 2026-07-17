package game.controls
{
    import classes.RenderQuality;
    import flash.display.BlendMode;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;

    public class GameplayDepthBackground extends Sprite
    {
        private static const FLOW_COUNT:int = 6;
        private static const TOP_SCALE:Number = 0.70;
        private static const BOTTOM_SCALE:Number = 1.00;

        private var _baseLayer:Sprite;
        private var _flowLayer:Sprite;
        private var _runwayLayer:Sprite;
        private var _flowSprites:Vector.<Sprite> = new <Sprite>[];
        private var _colorTransform:ColorTransform = new ColorTransform();

        private var _laneX:Number = 250;
        private var _laneY:Number = 0;
        private var _laneWidth:Number = 280;
        private var _laneHeight:Number = 480;
        private var _phase:Number = 0;

        public function GameplayDepthBackground(parent:Sprite):void
        {
            if (parent)
                parent.addChild(this);

            mouseEnabled = false;
            mouseChildren = false;
            buildLayers();
        }

        public function setLaneBounds(xPos:Number, yPos:Number, laneWidth:Number, laneHeight:Number):void
        {
            _laneX = xPos;
            _laneY = yPos;
            _laneWidth = Math.max(64, laneWidth);
            _laneHeight = Math.max(64, laneHeight);
        }

        public function tick(frame:int, combo:int, mode:String):void
        {
            _phase = frame * 0.035;

            var comboLevel:Number = Math.min(1, Math.max(0, combo) / 420);
            var modeScale:Number = 1;
            if (mode == ComboHypeOverlay.MODE_REDUCED)
                modeScale = 0.58;
            else if (mode == ComboHypeOverlay.MODE_OFF)
                modeScale = 0.36;

            alpha = 0.68 + comboLevel * 0.08;
            updateFlowSprites(comboLevel, modeScale);
            drawRunway(comboLevel, modeScale);
        }

        private function buildLayers():void
        {
            _baseLayer = new Sprite();
            _flowLayer = new Sprite();
            _runwayLayer = new Sprite();

            _flowLayer.blendMode = BlendMode.ADD;
            _runwayLayer.blendMode = BlendMode.ADD;

            addChild(_baseLayer);
            addChild(_flowLayer);
            addChild(_runwayLayer);
            _baseLayer.alpha = 0.82;

            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(Main.GAME_WIDTH, Main.GAME_HEIGHT, Math.PI / 2, 0, 0);
            _baseLayer.graphics.beginGradientFill(GradientType.LINEAR, [0x02050D, 0x06111F, 0x02040A], [0.96, 0.92, 0.98], [0, 142, 255], matrix);
            _baseLayer.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _baseLayer.graphics.endFill();

            RenderQuality.cacheDisplayObject(_baseLayer);

            for (var i:int = 0; i < FLOW_COUNT; i++)
            {
                var flow:Sprite = new Sprite();
                flow.graphics.beginFill(0xFFFFFF, 1);
                flow.graphics.drawEllipse(-150, -28, 300, 56);
                flow.graphics.endFill();
                flow.blendMode = BlendMode.ADD;
                flow.mouseEnabled = false;
                RenderQuality.cacheDisplayObject(flow);
                _flowLayer.addChild(flow);
                _flowSprites.push(flow);
            }
        }

        private function updateFlowSprites(comboLevel:Number, modeScale:Number):void
        {
            if (comboLevel < 0.18)
            {
                _flowLayer.visible = false;
                return;
            }

            var energy:Number = (comboLevel - 0.18) / 0.82;
            var speed:Number = 0.7 + energy * 1.25;
            var bandWidth:Number = Math.min(_laneWidth * 0.82, 110 + energy * 86);
            var bandHeight:Number = 5 + energy * 12;
            var topY:Number = Math.max(42, _laneY + 18);
            var bottomY:Number = Math.min(Main.GAME_HEIGHT - 24, _laneY + _laneHeight - 12);
            var centerX:Number = _laneX + _laneWidth * 0.5;

            _flowLayer.visible = true;
            for (var i:int = 0; i < FLOW_COUNT; i++)
            {
                var flow:Sprite = _flowSprites[i];
                var depth:Number = ((i / FLOW_COUNT) + ((_phase * speed) % 1)) % 1;
                var yPos:Number = interp(topY, bottomY, Math.pow(depth, 1.35));
                var laneScale:Number = TOP_SCALE + ((BOTTOM_SCALE - TOP_SCALE) * depth);
                var xDrift:Number = Math.sin(_phase * 1.8 + i * 1.37) * _laneWidth * 0.12 * laneScale;

                flow.x = centerX + xDrift;
                flow.y = yPos;
                flow.scaleX = (bandWidth / 300) * (0.7 + depth * 0.34);
                flow.scaleY = (bandHeight / 56) * (0.75 + depth * 0.25);
                flow.alpha = (0.002 + energy * 0.008) * modeScale * (1 - i * 0.08);
                tintSprite(flow, ambientColor(_phase + i * 0.6));
            }
        }

        private function drawRunway(comboLevel:Number, modeScale:Number):void
        {
            var g:Graphics = _runwayLayer.graphics;
            g.clear();

            var topY:Number = Math.max(42, _laneY + 18);
            var bottomY:Number = Math.min(Main.GAME_HEIGHT - 24, _laneY + _laneHeight - 12);
            var centerX:Number = _laneX + _laneWidth / 2;
            var topHalf:Number = _laneWidth * TOP_SCALE * 0.5;
            var bottomHalf:Number = _laneWidth * BOTTOM_SCALE * 0.5;
            var pulse:Number = (Math.sin(_phase * 3.1) + 1) * 0.5;
            var baseAlpha:Number = (0.035 + comboLevel * 0.055) * modeScale;

            g.beginFill(0x72DFFF, (0.006 + comboLevel * 0.012) * modeScale);
            g.moveTo(centerX - topHalf, topY);
            g.lineTo(centerX + topHalf, topY);
            g.lineTo(centerX + bottomHalf, bottomY);
            g.lineTo(centerX - bottomHalf, bottomY);
            g.lineTo(centerX - topHalf, topY);
            g.endFill();

            g.lineStyle(1 + comboLevel * 1.4, 0xFFFFFF, baseAlpha * 0.36, true);
            g.moveTo(centerX - topHalf, topY);
            g.lineTo(centerX - bottomHalf, bottomY);
            g.moveTo(centerX + topHalf, topY);
            g.lineTo(centerX + bottomHalf, bottomY);

            for (var lane:int = 1; lane < 4; lane++)
            {
                var ratio:Number = lane / 4;
                g.lineStyle(1, ambientColor(_phase + lane * 0.28), baseAlpha * 0.45, true);
                g.moveTo(interp(centerX - topHalf, centerX + topHalf, ratio), topY);
                g.lineTo(interp(centerX - bottomHalf, centerX + bottomHalf, ratio), bottomY);
            }

            var lines:int = 11;
            for (var i:int = 0; i < lines; i++)
            {
                var t:Number = ((i + ((_phase * 0.82) % 1)) / lines);
                t = Math.pow(t, 1.85);
                var y:Number = interp(topY, bottomY, t);
                var half:Number = interp(topHalf, bottomHalf, t);
                var lineAlpha:Number = (0.012 + comboLevel * 0.024) * modeScale * (0.2 + t * 0.68);
                g.lineStyle(1 + t * 1.5, ambientColor(_phase + i * 0.22), lineAlpha, true);
                g.moveTo(centerX - half, y);
                g.lineTo(centerX + half, y);
            }

            g.lineStyle(2 + comboLevel * 4, ambientColor(_phase + 0.8), (0.018 + pulse * 0.018 + comboLevel * 0.035) * modeScale, true);
            g.moveTo(centerX - bottomHalf * 0.92, bottomY - 6);
            g.lineTo(centerX + bottomHalf * 0.92, bottomY - 6);
        }

        private function interp(a:Number, b:Number, t:Number):Number
        {
            return a + (b - a) * t;
        }

        private function tintSprite(sprite:Sprite, color:uint):void
        {
            _colorTransform.color = color;
            sprite.transform.colorTransform = _colorTransform;
        }

        private function rgbColor(t:Number):uint
        {
            var r:uint = Math.round((Math.sin(t) * 0.5 + 0.5) * 255);
            var g:uint = Math.round((Math.sin(t + 2.094) * 0.5 + 0.5) * 255);
            var b:uint = Math.round((Math.sin(t + 4.188) * 0.5 + 0.5) * 255);
            return (r << 16) | (g << 8) | b;
        }

        private function ambientColor(t:Number):uint
        {
            var mix:Number = (Math.sin(t) * 0.5 + 0.5);
            var r:uint = Math.round(20 + mix * 52);
            var g:uint = Math.round(150 + mix * 58);
            var b:uint = Math.round(185 + mix * 48);
            return (r << 16) | (g << 8) | b;
        }
    }
}
