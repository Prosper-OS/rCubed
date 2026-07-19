package com.flashfla.utils;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.IBitmapDrawable;
import openfl.filters.BlurFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;

class SpriteUtil
{
    /*
       public static function setRegistrationPoint(s                          : Dynamic, regx                          : Dynamic, regy                          : Dynamic):void {
       s.transform.matrix = new Matrix(1, 0, 0, 1, -regx, -regy);
       }

       public static function getAbsolutePosition(t                          : Dynamic):Object {
       var aX                          : Dynamic= t.x;
       var aY                          : Dynamic= t.y;
       if (as3hx.Compat.truthy(t.stage == null))
       return { x:aX, y:aY };

       var p                          : Dynamic= t.parent;
       while (as3hx.Compat.truthy(!(p is Stage))) {
       aX += p.x;
       aY += p.y;
       p = p.parent;
       }
       return { x:aX, y:aY };
       }

       public static function isVisible(t                          : Dynamic):Boolean {
       if (as3hx.Compat.truthy(t.stage == null))
       return false;

       var p                          : Dynamic= t.parent;
       while (as3hx.Compat.truthy(!(p is Stage))) {
       if (as3hx.Compat.truthy(!p.visible))
       return false;
       p = p.parent;
       }
       return true;
       }
     */
    
    /**
     * Scales a sprite to fit a max width/height.
     * @param	sprite Sprite to scale
     * @param	maxWidth Max Width
     * @param	maxHeight Max Height
     */
    public static function scaleTo(sprite                           : Dynamic, maxWidth                           : Dynamic, maxHeight                           : Dynamic) : Void
    {
        sprite.scaleX = sprite.scaleY = 1;
        sprite.scaleX = sprite.scaleY = Math.min(Math.min(maxWidth / sprite.width, maxHeight / sprite.height), 1);
    }
    
    public static function getBitmapSprite(drawable                           : Dynamic, darkness                           : Dynamic= 1) : Bitmap
    {
        var bmd                           : Dynamic= new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
        bmd.draw(drawable);
        bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
        
        if (as3hx.Compat.truthy(darkness < 1))
        {
            bmd.colorTransform(bmd.rect, new ColorTransform(darkness, darkness, darkness));
        }
        
        return new Bitmap(bmd);
    }

    public function new()
    {
    }
}

