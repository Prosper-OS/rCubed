package classes;

import openfl.utils.Dictionary;
import classes.ImageCache;
import com.flashfla.utils.SpriteUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.net.URLRequest;

class ImageCache
{
    public static inline var ALIGN_MIDDLE                              : Dynamic= 1;
    
    public static var cacheData                              : Dynamic= new Dictionary<Dynamic, Dynamic>();
    
    public static function getImage(url                              : Dynamic, imageAlign                              : Dynamic= 0, scaleWidth                              : Dynamic= null, scaleHeight                              : Dynamic= null) : ImageCacheSprite
    {
        var cache                              : Dynamic= Reflect.field(cacheData, url);
        
        if (as3hx.Compat.truthy(cache == null))
        {
            cache = new CacheData(url);
            cacheData[cache.url] = cache;
        }
        
        return new ImageCacheSprite(cache, imageAlign, scaleWidth, scaleHeight);
    }

    public function new()
    {
    }
}



class CacheData extends EventDispatcher
{
    public var url                              : Dynamic;
    public var data                              : Dynamic;
    
    private var _loader                              : Dynamic;
    
    @:allow(classes)
    private function new(url                              : Dynamic)
    {
        super();
        this.url = url;
        
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_onLoad);
        _loader.load(new URLRequest(url));
    }
    
    private function e_onLoad(e                              : Dynamic) : Void
    {
        _loader.removeEventListener(Event.COMPLETE, e_onLoad);
        data = (try cast(_loader.content, Bitmap) catch(e:Dynamic) null).bitmapData;
        
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    public function getSprite() : DisplayObject
    {
        return new Bitmap(data.clone());
    }
}

class ImageCacheSprite extends Sprite
{
    public var url                              : Dynamic;
    public var cache                              : Dynamic;
    
    public var imageAlign                              : Dynamic;
    public var scaleWidth                              : Dynamic;
    public var scaleHeight                              : Dynamic;
    
    private var useArea                              : Dynamic;
    
    @:allow(classes)
    private function new(cache                              : Dynamic, imageAlign                              : Dynamic= 0, scaleWidth                              : Dynamic= null, scaleHeight                              : Dynamic= null)
    {
        super();
        this.cache = cache;
        this.imageAlign = imageAlign;
        this.scaleWidth = scaleWidth;
        this.scaleHeight = scaleHeight;
        
        this.useArea = !Math.isNaN(scaleWidth) && !Math.isNaN(scaleHeight);
        
        if (as3hx.Compat.truthy(cache.data != null))
        {
            addImage();
        }
        else
        {
            cache.addEventListener(Event.COMPLETE, e_onComplete);
        }
    }
    
    private function addImage() : Void
    {
        var spr                              : Dynamic= cache.getSprite();
        
        if (as3hx.Compat.truthy(useArea))
        {
            SpriteUtil.scaleTo(spr, scaleWidth, scaleHeight);
        }
        
        if (as3hx.Compat.truthy(imageAlign == ImageCache.ALIGN_MIDDLE))
        {
            spr.x = -(scaleWidth >> 1);
            spr.y = -(scaleHeight >> 1);
        }
        
        if (as3hx.Compat.truthy(useArea))
        {
            spr.x += (scaleWidth - spr.width) / 2;
            spr.y += (scaleHeight - spr.height) / 2;
        }
        
        addChild(spr);
    }
    
    private function e_onComplete(e                              : Dynamic) : Void
    {
        cache.removeEventListener(Event.COMPLETE, e_onComplete);
        
        if (as3hx.Compat.truthy(cache.data != null))
        {
            addImage();
        }
    }
    
    override private function get_width() : Float
    {
        return scaleWidth;
    }
    
    override private function get_height() : Float
    {
        return scaleHeight;
    }
}
