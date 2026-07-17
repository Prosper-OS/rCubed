package classes
{
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;

    public class HiResArrowNote extends Sprite
    {
        private static const BASE_SIZE:Number = 64;

        private static const PALETTES:Object = {
            "blue": {shadow: 0x09143f, outline: 0x8b55ff, rim: 0x62d7ff, start: 0x7b3cff, mid: 0x54b8ff, end: 0xadf561, core: 0x2d3c99},
            "red": {shadow: 0x3a0816, outline: 0xff5579, rim: 0xffb25f, start: 0xa51d4d, mid: 0xff4d48, end: 0xffd65b, core: 0x782052},
            "yellow": {shadow: 0x382307, outline: 0xffca44, rim: 0xffffff, start: 0xff7b32, mid: 0xffcf40, end: 0xffff91, core: 0x9b6720},
            "green": {shadow: 0x06321e, outline: 0x58f29a, rim: 0xd6fff2, start: 0x13864e, mid: 0x3fe085, end: 0xc6ff5d, core: 0x166d63},
            "purple": {shadow: 0x1d0a45, outline: 0xb15cff, rim: 0xf0d0ff, start: 0x5e2dda, mid: 0x9c5cff, end: 0xff7bf2, core: 0x38258e},
            "pink": {shadow: 0x3c0a34, outline: 0xff72d8, rim: 0xffe1fb, start: 0xb82792, mid: 0xff61c9, end: 0xffb8eb, core: 0x813070},
            "orange": {shadow: 0x351807, outline: 0xff8f3d, rim: 0xfff2bd, start: 0xbb4318, mid: 0xff833c, end: 0xffe06b, core: 0x8e4726},
            "cyan": {shadow: 0x063443, outline: 0x41eaff, rim: 0xdcffff, start: 0x1670b5, mid: 0x3edcff, end: 0xc7fff3, core: 0x185b97},
            "white": {shadow: 0x252b44, outline: 0xdde8ff, rim: 0xffffff, start: 0x8da4d3, mid: 0xe6f1ff, end: 0xffffff, core: 0x67789f}
        };

        public function HiResArrowNote(colorName:String, noteWidth:Number = 64, noteHeight:Number = 64)
        {
            mouseEnabled = false;
            mouseChildren = false;
            doubleClickEnabled = false;
            tabEnabled = false;

            draw(colorName, noteWidth, noteHeight);
        }

        private function draw(colorName:String, noteWidth:Number, noteHeight:Number):void
        {
            var palette:Object = getPalette(colorName);
            var sx:Number = noteWidth / BASE_SIZE;
            var sy:Number = noteHeight / BASE_SIZE;
            var strokeScale:Number = Math.max(1, Math.min(sx, sy));
            var body:Sprite = new Sprite();
            var g:Graphics = body.graphics;

            g.lineStyle(5 * strokeScale, palette.shadow, 0.9, true);
            drawArrowPath(g, sx, sy);
            g.endFill();

            var gradientMatrix:Matrix = new Matrix();
            gradientMatrix.createGradientBox(noteWidth, noteHeight, Math.PI / 2, 0, 0);

            g.lineStyle(2.5 * strokeScale, palette.outline, 1, true);
            g.beginGradientFill(GradientType.LINEAR, [palette.start, palette.mid, palette.end], [1, 1, 1], [0, 144, 255], gradientMatrix);
            drawArrowPath(g, sx, sy);
            g.endFill();

            g.lineStyle(1.2 * strokeScale, palette.rim, 0.9, true);
            drawArrowPath(g, sx, sy);
            g.endFill();

            drawCore(g, palette, sx, sy, strokeScale);
            body.filters = [new GlowFilter(palette.outline, 0.45, 4, 4, 1.6, 3), new GlowFilter(palette.rim, 0.22, 8, 8, 1.2, 3)];
            addChild(body);
        }

        private static function getPalette(colorName:String):Object
        {
            return PALETTES[colorName] != null ? PALETTES[colorName] : PALETTES["blue"];
        }

        private static function drawArrowPath(g:Graphics, sx:Number, sy:Number):void
        {
            g.moveTo(26 * sx, 4 * sy);
            g.lineTo(38 * sx, 4 * sy);
            g.lineTo(38 * sx, 28 * sy);
            g.lineTo(51 * sx, 17 * sy);
            g.lineTo(62 * sx, 29 * sy);
            g.lineTo(43 * sx, 49 * sy);
            g.lineTo(43 * sx, 43 * sy);
            g.lineTo(32 * sx, 62 * sy);
            g.lineTo(21 * sx, 43 * sy);
            g.lineTo(21 * sx, 49 * sy);
            g.lineTo(2 * sx, 29 * sy);
            g.lineTo(13 * sx, 17 * sy);
            g.lineTo(26 * sx, 28 * sy);
            g.lineTo(26 * sx, 4 * sy);
        }

        private static function drawCore(g:Graphics, palette:Object, sx:Number, sy:Number, strokeScale:Number):void
        {
            g.lineStyle(1.4 * strokeScale, palette.rim, 0.35, true);
            g.beginFill(palette.core, 0.36);
            g.moveTo(29 * sx, 12 * sy);
            g.lineTo(35 * sx, 12 * sy);
            g.lineTo(35 * sx, 34 * sy);
            g.lineTo(42 * sx, 41 * sy);
            g.lineTo(38 * sx, 45 * sy);
            g.lineTo(32 * sx, 38 * sy);
            g.lineTo(26 * sx, 45 * sy);
            g.lineTo(22 * sx, 41 * sy);
            g.lineTo(29 * sx, 34 * sy);
            g.lineTo(29 * sx, 12 * sy);
            g.endFill();

            g.lineStyle(1.6 * strokeScale, palette.rim, 0.45, true);
            g.moveTo(32 * sx, 9 * sy);
            g.lineTo(32 * sx, 34 * sy);
            g.moveTo(23 * sx, 40 * sy);
            g.lineTo(32 * sx, 31 * sy);
            g.lineTo(41 * sx, 40 * sy);
        }
    }
}
