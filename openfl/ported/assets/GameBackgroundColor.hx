package assets;

import com.greensock.TweenLite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import r3.air.filesystem.File;
import openfl.geom.Matrix;
import openfl.net.URLRequest;

class GameBackgroundColor extends Sprite
{
    public static var BG_LIGHT                              : Dynamic= 0x1495BD;
    public static var BG_DARK                              : Dynamic= 0x033242;
    public static var BG_STATIC                              : Dynamic= 0x0C6A88;
    public static var BG_POPUP                              : Dynamic= 0x074B62;
    public static var BG_STAGE                              : Dynamic= 0x000000;
    
    public static var BG_IMAGE_EXT                              : Dynamic= [".png", ".jpg", ".jpeg", ".gif"];
    public static var BG_IMG_MENU                              : Dynamic;
    public static var BG_IMG_GAME                              : Dynamic;
    
    private var lastLight                              : Dynamic= BG_LIGHT;
    private var lastDark                              : Dynamic= BG_DARK;
    private var lastFade                              : Dynamic;
    
    public function new()
    {
        super();
        
        this.cacheAsBitmap = true;
        
        redraw();
        reloadImages();
    }
    
    public function redraw() : Void
    {
        if (as3hx.Compat.truthy(BG_IMG_MENU != null))
        {
            this.graphics.clear();
            return;
        }
        
        // Create Background
        var _matrix                              : Dynamic= new Matrix();
        _matrix.createGradientBox(Main.GAME_WIDTH, Main.GAME_HEIGHT, 5.75);
        this.graphics.clear();
        this.graphics.beginGradientFill(GradientType.LINEAR, [BG_LIGHT, BG_DARK], [1, 1], [0x00, 0xFF], _matrix);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        this.cacheAsBitmap = true;
        this.cacheAsBitmapMatrix = _matrix;
        
        var bt                              : Dynamic= new GameBackgroundStripes();
        this.graphics.beginBitmapFill(bt, null, false);
        this.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
        this.graphics.endFill();
        
        if (as3hx.Compat.truthy(lastFade == null && (lastLight != BG_LIGHT || lastDark != BG_DARK)))
        {
            lastFade = new Sprite();
            lastFade.graphics.beginGradientFill(GradientType.LINEAR, [lastLight, lastDark], [1, 1], [0x00, 0xFF], _matrix);
            lastFade.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            lastFade.graphics.endFill();
            lastFade.graphics.beginBitmapFill(bt, null, false);
            lastFade.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            lastFade.graphics.endFill();
            lastFade.cacheAsBitmap = true;
            lastFade.cacheAsBitmapMatrix = _matrix;
            addChild(lastFade);
            TweenLite.to(lastFade, 1, {
                        alpha : 0,
                        onComplete : onFadeComplete
                    });
        }
        
        lastLight = BG_LIGHT;
        lastDark = BG_DARK;
    }
    
    private function onFadeComplete() : Void
    {
        removeChild(lastFade);
        lastFade = null;
    }
    
    public function updateDisplay(gameMode                              : Dynamic= false) : Void
    {
        if (as3hx.Compat.truthy(gameMode))
        {
            if (as3hx.Compat.truthy(BG_IMG_MENU != null))
            {
                BG_IMG_MENU.visible = false;
            }
            
            if (as3hx.Compat.truthy(BG_IMG_GAME != null))
            {
                this.visible = true;
                BG_IMG_GAME.visible = true;
            }
            else
            {
                this.visible = false;
            }
        }
        else
        {
            this.visible = true;
            
            if (as3hx.Compat.truthy(BG_IMG_MENU != null))
            {
                BG_IMG_MENU.visible = true;
            }
            
            if (as3hx.Compat.truthy(BG_IMG_GAME != null))
            {
                BG_IMG_GAME.visible = false;
            }
        }
    }
    
    public function reloadImages() : Void
    {
        var path                              : Dynamic= null;
        var imageLoader                              : Dynamic= null;
        var file                              : Dynamic= null;
        
        // Menu Background
        for (i in 0...BG_IMAGE_EXT.length)
        {
            file = AirContext.getAppFile("bg_menu" + BG_IMAGE_EXT[i]);
            if (as3hx.Compat.truthy(file.exists))
            {
                Logger.debug(this, "Found " + file.name);
                path = "file:///" + file.nativePath;
                imageLoader = new Loader();
                imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_bgMenuLoaded);
                imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bgMenuLoaded);
                imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bgMenuLoaded);
                imageLoader.load(new URLRequest(path), AirContext.getLoaderContext());
                break;
            }
        }
        
        // Gameplay Background
        for (i in 0...BG_IMAGE_EXT.length)
        {
            file = AirContext.getAppFile("bg_game" + BG_IMAGE_EXT[i]);
            
            if (as3hx.Compat.truthy(file.exists))
            {
                Logger.debug(this, "Found " + file.name);
                path = "file:///" + file.nativePath;
                imageLoader = new Loader();
                imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_bgGameLoaded);
                imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bgGameLoaded);
                imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bgGameLoaded);
                imageLoader.load(new URLRequest(path), AirContext.getLoaderContext());
                break;
            }
        }
    }
    
    private function e_bgMenuLoaded(e                              : Dynamic) : Void
    // Position Loaded Banner Image
    {
        
        if (as3hx.Compat.truthy(e.type == Event.COMPLETE && e.target != null && ((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content) != null))
        {
            BG_IMG_MENU = try cast(((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content), Bitmap) catch(e:Dynamic) null;
            positionImage(BG_IMG_MENU);
            this.addChild(BG_IMG_MENU);
        }
    }
    
    private function e_bgGameLoaded(e                              : Dynamic) : Void
    // Position Loaded Banner Image
    {
        
        if (as3hx.Compat.truthy(e.type == Event.COMPLETE && e.target != null && ((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content) != null))
        {
            BG_IMG_GAME = try cast(((try cast(e.target, LoaderInfo) catch(e:Dynamic) null).content), Bitmap) catch(e:Dynamic) null;
            BG_IMG_GAME.visible = false;
            positionImage(BG_IMG_GAME);
            this.addChild(BG_IMG_GAME);
        }
    }
    
    private function positionImage(img                              : Dynamic) : Void
    {
        img.smoothing = true;
        img.pixelSnapping = "always";
        
        var imageScale                              : Dynamic= Main.GAME_WIDTH / img.width;
        
        img.scaleX = img.scaleY = imageScale;
        
        if (as3hx.Compat.truthy(img.height < Main.GAME_HEIGHT))
        {
            img.scaleX = img.scaleY = 1;
            imageScale = Main.GAME_HEIGHT / img.height;
            img.scaleX = img.scaleY = imageScale;
            img.x = -((img.width - Main.GAME_WIDTH) / 2);
        }
        else
        {
            img.y = -((img.height - Main.GAME_HEIGHT) / 2);
        }
    }
}

