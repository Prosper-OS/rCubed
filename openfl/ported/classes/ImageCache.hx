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
    public static inline var ALIGN_MIDDLE : Float = 1;
    
    public static var cacheData : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>();
    
    public static function getImage(url : String, imageAlign : Float = 0, scaleWidth : Float = Math.NaN, scaleHeight : Float = Math.NaN) : ImageCacheSprite
    {
        var cache : CacheData = Reflect.field(cacheData, url);
        
        if (cache == null)
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
    public var url : String;
    public var data : BitmapData;
    
    private var _loader : Loader;
    
    @:allow(classes)
    private function new(url : String)
    {
        super();
        this.url = url;
        
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_onLoad);
        _loader.load(new URLRequest(url));
    }
    
    private function e_onLoad(e : Event) : Void
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
    public var url : String;
    public var cache : CacheData;
    
    public var imageAlign : Float;
    public var scaleWidth : Float;
    public var scaleHeight : Float;
    
    private var useArea : Bool;
    
    @:allow(classes)
    private function new(cache : CacheData, imageAlign : Float = 0, scaleWidth : Float = Math.NaN, scaleHeight : Float = Math.NaN)
    {
        super();
        this.cache = cache;
        this.imageAlign = imageAlign;
        this.scaleWidth = scaleWidth;
        this.scaleHeight = scaleHeight;
        
        this.useArea = !Math.isNaN(scaleWidth) && !Math.isNaN(scaleHeight);
        
        if (cache.data != null)
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
        var spr : DisplayObject = cache.getSprite();
        
        if (useArea)
        {
            SpriteUtil.scaleTo(spr, scaleWidth, scaleHeight);
        }
        
        if (imageAlign == ImageCache.ALIGN_MIDDLE)
        {
            spr.x = -(scaleWidth >> 1);
            spr.y = -(scaleHeight >> 1);
        }
        
        if (useArea)
        {
            spr.x += (scaleWidth - spr.width) / 2;
            spr.y += (scaleHeight - spr.height) / 2;
        }
        
        addChild(spr);
    }
    
    private function e_onComplete(e : Event) : Void
    {
        cache.removeEventListener(Event.COMPLETE, e_onComplete);
        
        if (cache.data != null)
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
