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
        private static const TOP_SCALE:Number = 0.90;
        private static const BOTTOM_SCALE:Number = 1.10;

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

            alpha = 0.82 + comboLevel * 0.12;
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

            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(Main.GAME_WIDTH, Main.GAME_HEIGHT, Math.PI / 2, 0, 0);
            _baseLayer.graphics.beginGradientFill(GradientType.LINEAR, [0x02050D, 0x06111F, 0x02040A], [0.96, 0.92, 0.98], [0, 142, 255], matrix);
            _baseLayer.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _baseLayer.graphics.endFill();

            _baseLayer.graphics.beginFill(0x0DDCFF, 0.055);
            _baseLayer.graphics.drawEllipse(-90, 54, 310, 150);
            _baseLayer.graphics.endFill();
            _baseLayer.graphics.beginFill(0xFF2FB9, 0.042);
            _baseLayer.graphics.drawEllipse(Main.GAME_WIDTH - 220, 310, 310, 190);
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
            var speed:Number = 34 + comboLevel * 64;
            var bandWidth:Number = 240 + comboLevel * 150;
            var bandHeight:Number = 34 + comboLevel * 32;
            var cycle:Number = Main.GAME_WIDTH + bandWidth * 2;
            var offset:Number = (_phase * speed) % cycle;

            for (var i:int = 0; i < FLOW_COUNT; i++)
            {
                var flow:Sprite = _flowSprites[i];
                var depth:Number = (i + 1) / FLOW_COUNT;
                var xPos:Number = -bandWidth + ((offset + i * 145) % cycle);
                var yPos:Number = 72 + i * 64 + Math.sin(_phase * 1.8 + i) * 18;

                flow.x = xPos;
                flow.y = yPos;
                flow.scaleX = (bandWidth / 300) * (0.75 + depth * 0.35);
                flow.scaleY = (bandHeight / 56) * (0.75 + depth * 0.25);
                flow.alpha = (0.05 + comboLevel * 0.12) * modeScale * (1 - i * 0.08);
                tintSprite(flow, rgbColor(_phase + i * 1.25));
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
            var baseAlpha:Number = (0.12 + comboLevel * 0.16) * modeScale;

            g.beginFill(0x72DFFF, 0.03 + comboLevel * 0.035 * modeScale);
            g.moveTo(centerX - topHalf, topY);
            g.lineTo(centerX + topHalf, topY);
            g.lineTo(centerX + bottomHalf, bottomY);
            g.lineTo(centerX - bottomHalf, bottomY);
            g.lineTo(centerX - topHalf, topY);
            g.endFill();

            g.lineStyle(2 + comboLevel * 3, 0xFFFFFF, baseAlpha * 0.45, true);
            g.moveTo(centerX - topHalf, topY);
            g.lineTo(centerX - bottomHalf, bottomY);
            g.moveTo(centerX + topHalf, topY);
            g.lineTo(centerX + bottomHalf, bottomY);

            for (var lane:int = 1; lane < 4; lane++)
            {
                var ratio:Number = lane / 4;
                g.lineStyle(1, rgbColor(_phase + lane * 0.85), baseAlpha * 0.42, true);
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
                var lineAlpha:Number = (0.09 + comboLevel * 0.11) * modeScale * (0.35 + t * 0.9);
                g.lineStyle(1 + t * 3, rgbColor(_phase + i * 0.62), lineAlpha, true);
                g.moveTo(centerX - half, y);
                g.lineTo(centerX + half, y);
            }

            g.lineStyle(5 + comboLevel * 7, rgbColor(_phase + 2.4), (0.035 + pulse * 0.06 + comboLevel * 0.09) * modeScale, true);
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
    }
}
