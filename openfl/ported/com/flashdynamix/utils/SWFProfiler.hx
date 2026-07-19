package com.flashdynamix.utils;

import openfl.errors.Error;
import classes.Language;
import openfl.display.*;
import openfl.events.*;
import openfl.net.LocalConnection;
import openfl.system.System;
import openfl.ui.*;


import openfl.events.Event;
import openfl.text.*;

/**
 * @author shanem
 */
class SWFProfiler
{
    public static var currentFps(get, never) : Float;
    public static var currentMem(get, never) : Float;
    public static var averageFps(get, never) : Float;
    private static var runningTime(get, never) : Float;
    private static var intervalTime(get, never) : Float;

    private static var _lang : Language = Language.instance;
    
    private static var itvTime : Int;
    private static var initTime : Int;
    private static var currentTime : Int;
    private static var frameCount : Int;
    private static var totalCount : Int;
    
    public static var minFps : Float;
    public static var maxFps : Float;
    public static var minMem : Float;
    public static var maxMem : Float;
    public static var history : Int = 60;
    public static var fpsList : Array<Dynamic> = [];
    public static var memList : Array<Dynamic> = [];
    
    private static var displayed : Bool = false;
    private static var started : Bool = false;
    private static var inited : Bool = false;
    private static var frame : Sprite;
    private static var stage : Stage;
    private static var content : ProfilerContent;
    private static var ci : ContextMenuItem;
    
    public static function init(swf : Stage, context : InteractiveObject) : Void
    {
        if (inited)
        {
            buildContextMenu(context);
            return;
        }
        
        inited = true;
        stage = swf;
        
        content = new ProfilerContent();
        frame = new Sprite();
        
        minFps = as3hx.Compat.FLOAT_MAX;
        maxFps = as3hx.Compat.FLOAT_MIN;
        minMem = as3hx.Compat.FLOAT_MAX;
        maxMem = as3hx.Compat.FLOAT_MIN;
        
        // Add Item to Context Menu
        buildContextMenu(context);
        
        start();
    }
    
    private static function buildContextMenu(context : InteractiveObject) : Void
    {
        var str_show_profiler : String = _lang.stringSimple("show_profiler");
        var str_hide_profiler : String = _lang.stringSimple("hide_profiler");
        
        ci = new ContextMenuItem((displayed) ? str_hide_profiler : str_show_profiler, true);
        addEvent(ci, ContextMenuEvent.MENU_ITEM_SELECT, onSelect);
        (try cast(context.contextMenu, ContextMenu) catch(e:Dynamic) null).customItems.push(ci);
    }
    
    public static function start() : Void
    {
        if (started)
        {
            return;
        }
        
        started = true;
        initTime = itvTime = Math.round(haxe.Timer.stamp() * 1000);
        totalCount = frameCount = 0;
    }
    
    public static function stop() : Void
    {
        if (!started)
        {
            return;
        }
        
        started = false;
    }
    
    public static function gc() : Void
    {
        try
        {
            new LocalConnection().connect("foo");
            new LocalConnection().connect("foo");
        }
        catch (e : Error)
        {
        }
    }
    
    private static function get_currentFps() : Float
    {
        return frameCount / intervalTime;
    }
    
    private static function get_currentMem() : Float
    {
        return (System.totalMemory / 1024) / 1000;
    }
    
    private static function get_averageFps() : Float
    {
        return totalCount / runningTime;
    }
    
    private static function get_runningTime() : Float
    {
        return (currentTime - initTime) / 1000;
    }
    
    private static function get_intervalTime() : Float
    {
        return (currentTime - itvTime) / 1000;
    }
    
    
    public static function onSelect(e : ContextMenuEvent = null) : Void
    {
        if (!displayed)
        {
            show();
        }
        else
        {
            hide();
        }
    }
    
    private static function show() : Void
    {
        ci.caption = _lang.stringSimple("hide_profiler");
        displayed = true;
        addEvent(stage, Event.RESIZE, resize);
        addEvent(frame, Event.ENTER_FRAME, draw);
        stage.addChild(content);
        updateDisplay();
    }
    
    private static function hide() : Void
    {
        ci.caption = _lang.stringSimple("show_profiler");
        displayed = false;
        removeEvent(stage, Event.RESIZE, resize);
        removeEvent(frame, Event.ENTER_FRAME, draw);
        stage.removeChild(content);
    }
    
    private static function resize(e : Event) : Void
    {
        content.update(runningTime, minFps, maxFps, minMem, maxMem, currentFps, currentMem, averageFps, fpsList, memList, history);
    }
    
    private static function draw(e : Event) : Void
    {
        if (!started)
        {
            return;
        }
        
        currentTime = Math.round(haxe.Timer.stamp() * 1000);
        
        frameCount++;
        totalCount++;
        
        if (intervalTime >= 1)
        {
            if (displayed)
            {
                updateDisplay();
            }
            else
            {
                updateMinMax();
            }
            
            fpsList.unshift(currentFps);
            memList.unshift(currentMem);
            
            if (fpsList.length > history)
            {
                fpsList.pop();
            }
            if (memList.length > history)
            {
                memList.pop();
            }
            
            itvTime = currentTime;
            frameCount = 0;
        }
    }
    
    private static function updateDisplay() : Void
    {
        updateMinMax();
        content.update(runningTime, minFps, maxFps, minMem, maxMem, currentFps, currentMem, averageFps, fpsList, memList, history);
    }
    
    private static function updateMinMax() : Void
    {
        minFps = Math.min(currentFps, minFps);
        maxFps = Math.max(currentFps, maxFps);
        
        minMem = Math.min(currentMem, minMem);
        maxMem = Math.max(currentMem, maxMem);
    }
    
    private static function addEvent(item : EventDispatcher, type : String, listener : Dynamic) : Void
    {
        item.addEventListener(type, listener, false, 0, true);
    }
    
    private static function removeEvent(item : EventDispatcher, type : String, listener : Dynamic) : Void
    {
        item.removeEventListener(type, listener);
    }

    public function new()
    {
    }
}



class ProfilerContent extends Sprite
{
    private var _lang : Language = Language.instance;
    
    private var minFpsTxtBx : TextField;
    private var maxFpsTxtBx : TextField;
    private var minMemTxtBx : TextField;
    private var maxMemTxtBx : TextField;
    private var infoTxtBx : TextField;
    private var box : Shape;
    private var fps : Shape;
    private var mb : Shape;
    
    @:allow(com.flashdynamix.utils)
    private function new()
    {
        super();
        fps = new Shape();
        mb = new Shape();
        box = new Shape();
        
        this.mouseChildren = false;
        this.mouseEnabled = false;
        
        fps.x = 65;
        fps.y = 45;
        mb.x = 65;
        mb.y = 90;
        
        var tf : TextFormat = new TextFormat("_sans", 9, 0xAAAAAA);
        
        infoTxtBx = new TextField();
        infoTxtBx.autoSize = TextFieldAutoSize.LEFT;
        infoTxtBx.defaultTextFormat = new TextFormat("_sans", 11, 0xCCCCCC);
        infoTxtBx.y = 98;
        
        minFpsTxtBx = new TextField();
        minFpsTxtBx.autoSize = TextFieldAutoSize.LEFT;
        minFpsTxtBx.defaultTextFormat = tf;
        minFpsTxtBx.x = 7;
        minFpsTxtBx.y = 37;
        
        maxFpsTxtBx = new TextField();
        maxFpsTxtBx.autoSize = TextFieldAutoSize.LEFT;
        maxFpsTxtBx.defaultTextFormat = tf;
        maxFpsTxtBx.x = 7;
        maxFpsTxtBx.y = 5;
        
        minMemTxtBx = new TextField();
        minMemTxtBx.autoSize = TextFieldAutoSize.LEFT;
        minMemTxtBx.defaultTextFormat = tf;
        minMemTxtBx.x = 7;
        minMemTxtBx.y = 83;
        
        maxMemTxtBx = new TextField();
        maxMemTxtBx.autoSize = TextFieldAutoSize.LEFT;
        maxMemTxtBx.defaultTextFormat = tf;
        maxMemTxtBx.x = 7;
        maxMemTxtBx.y = 50;
        
        addChild(box);
        addChild(infoTxtBx);
        addChild(minFpsTxtBx);
        addChild(maxFpsTxtBx);
        addChild(minMemTxtBx);
        addChild(maxMemTxtBx);
        addChild(fps);
        addChild(mb);
        
        this.addEventListener(Event.ADDED_TO_STAGE, added, false, 0, true);
        this.addEventListener(Event.REMOVED_FROM_STAGE, removed, false, 0, true);
    }
    
    public function update(runningTime : Float, minFps : Float, maxFps : Float, minMem : Float, maxMem : Float, currentFps : Float, currentMem : Float, averageFps : Float, fpsList : Array<Dynamic>, memList : Array<Dynamic>, history : Int) : Void
    {
        if (runningTime >= 1)
        {
            minFpsTxtBx.text = as3hx.Compat.toFixed(minFps, 3) + " Fps";
            maxFpsTxtBx.text = as3hx.Compat.toFixed(maxFps, 3) + " Fps";
            minMemTxtBx.text = as3hx.Compat.toFixed(minMem, 3) + " Mb";
            maxMemTxtBx.text = as3hx.Compat.toFixed(maxMem, 3) + " Mb";
        }
        
        var str_current_fps : String = _lang.stringSimple("profiler_current_fps");
        var str_average_fps : String = _lang.stringSimple("profiler_average_fps");
        var str_memory_used : String = _lang.stringSimple("profiler_memory_used");
        
        infoTxtBx.text = str_current_fps + " " + as3hx.Compat.toFixed(currentFps, 3) + "   |   " + str_average_fps + " " + as3hx.Compat.toFixed(averageFps, 3) + "   |   " + str_memory_used + " " + as3hx.Compat.toFixed(currentMem, 3) + " Mb";
        infoTxtBx.x = stage.stageWidth - infoTxtBx.width - 20;
        
        var vec : Graphics = fps.graphics;
        vec.clear();
        vec.lineStyle(1, 0x33FF00, 0.7);
        
        var i : Int = 0;
        var len : Int = fpsList.length;
        var height : Int = 35;
        var width : Int = as3hx.Compat.parseInt(stage.stageWidth - 80);
        var inc : Float = width / (history - 1);
        var rateRange : Float = maxFps - minFps;
        var value : Float;
        
        for (i in 0...len)
        {
            value = (fpsList[i] - minFps) / rateRange;
            if (i == 0)
            {
                vec.moveTo(0, -value * height);
            }
            else
            {
                vec.lineTo(i * inc, -value * height);
            }
        }
        
        vec = mb.graphics;
        vec.clear();
        vec.lineStyle(1, 0x0066FF, 0.7);
        
        i = 0;
        len = memList.length;
        rateRange = maxMem - minMem;
        for (i in 0...len)
        {
            value = (memList[i] - minMem) / rateRange;
            if (i == 0)
            {
                vec.moveTo(0, -value * height);
            }
            else
            {
                vec.lineTo(i * inc, -value * height);
            }
        }
    }
    
    private function added(e : Event) : Void
    {
        resize();
        stage.addEventListener(Event.RESIZE, resize, false, 0, true);
    }
    
    private function removed(e : Event) : Void
    {
        stage.removeEventListener(Event.RESIZE, resize);
    }
    
    private function resize(e : Event = null) : Void
    {
        var vec : Graphics = box.graphics;
        vec.clear();
        
        vec.beginFill(0x000000, 0.5);
        vec.drawRect(0, 0, stage.stageWidth, 120);
        vec.lineStyle(1, 0xFFFFFF, 0.2);
        
        vec.moveTo(65, 45);
        vec.lineTo(65, 10);
        vec.moveTo(65, 45);
        vec.lineTo(stage.stageWidth - 15, 45);
        
        vec.moveTo(65, 90);
        vec.lineTo(65, 55);
        vec.moveTo(65, 90);
        vec.lineTo(stage.stageWidth - 15, 90);
        
        vec.endFill();
        
        infoTxtBx.x = stage.stageWidth - infoTxtBx.width - 20;
    }
}
